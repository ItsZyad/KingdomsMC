##
## * All scripts that record notable locations the
## * the player has been and alerting them when they
## * discover a new area.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Apr 2022
## @Script Ver: v1.0
##
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

AreaAlert_Handler:
    type: world
    events:
        on player enters *:
        - if <context.area.split[@].get[2].starts_with[INTERNAL_STORY]>:
            # Gets rid of INTERNAL_STORY at the start of names
            - define realName <context.area.flag[name].replace[_].with[<&sp>].to_titlecase>

            - if <player.flag[foundAreas].contains[<context.area>]> || <server.has_flag[PreGameStart]>:

                - repeat 2:
                    - actionbar targets:<player> "<gold>Now Re-entering: <bold><[realName].to_uppercase>"
                    - wait 2s

            - else:
                - playsound sound:ui_toast_in <player> volume:0.5 pitch:0.6
                - title "subtitle:<bold><element[You Have Discovered: <[realName]>].color[gold]>" targets:<player>

                - if !<server.has_flag[PreGameStart]>:
                    - flag <player> foundAreas:->:<context.area>

AreaCreation_Item:
    type: item
    material: blaze_rod
    display name: "<gold><bold>Area Creation Tool"

AreaCreation_Command:
    type: command
    name: createarea
    usage: /createarea
    permission: kingdoms.admin
    description: "Command that allows server admins to create discoverable areas."
    tab complete:
        - if <player.has_flag[areaCreation]>:
            - if <context.args.first> == complete:
                - determine NAME_HERE
            - else:
                - determine cancel|complete
        - else:
            - determine cuboid|polygon
    script:
    # If the player selects either polygon or cuboid as their chosen areaType
    - if <list[cuboid|polygon].contains[<context.args.get[1]>]> && !<player.has_flag[areaCreation]>:
        - give <player.inventory> AreaCreation_Item
        - flag <player> areaCreation.mode:<context.args.get[1]>
        - flag <player> areaCreation.points:<list>

        - if <context.args.get[1]> == polygon:
            - narrate format:admincallout "Please ensure that no points overlap one another while creating the polygon shape. It does not cause any game-breaking behaviour however can make areas act a bit odd."
            - narrate format:admincallout "Right click to remove points in the order that you added them. Or type /createarea cancel to stop the area creation process altogether"

    - else if <context.args.get[1]> == complete:
        # Refresh fake blocks for every point the player clicked
        - foreach <player.flag[areaCreation].get[points]>:
            - showfake red_stained_glass <[value]> d:100s

        - if <context.args.size.is[MORE].than[2]>:
            - narrate format:callout "Ensure that the name is underscore-separated!"

        - else:
            - define name <context.args.get[2]>
            - define areaType <context.args.get[1]>
            - define posList <player.flag[areaCreation].get[points]>
            - define world <player.location.world>

            # Default vals for if the area type is a cuboid
            - define cornerOne <[posList].get[1].xyz>
            - define cornerTwo <[posList].get[2].xyz>
            - define area <cuboid[<[world].name>,<[cornerOne]>,<[cornerTwo]>]>

            - if <player.flag[areaCreation].get[mode]> == polygon:
                - define minY 999
                - define maxY -999
                - define coordList <list>

                # Find the highest and lowest Y points in the polygon
                - foreach <[posList]>:
                    - if <[value].y.is[MORE].than[<[maxY]>]>:
                        - define maxY <[value].y>

                    - else if <[value].y.is[LESS].than[<[minY]>]>:
                        - define minY <[value].y>

                    - define coordList:->:<[value].x>
                    - define coordList:->:<[value].z>

                - define area <polygon[<[world].name>,<[minY]>,<[maxY]>,<[coordList].comma_separated.replace_text[<&sp>].with[]>]>

                - showfake red_stained_glass <[area].outline_2d[<[maxY]>]> d:10s

            - else:
                - showfake red_stained_glass <[area].outline_2d[<player.location.y>]> d:10s

            # Clear all fake blocks
            - foreach <player.flag[areaCreation].get[points]>:
                - showfake cancel <[value]> players:<player>

            - define index <util.notes.find[<cuboid[INTERNAL_STORY_<[name]>]>]>

            - define region <util.notes.get[<[index]>]>

            - narrate format:debug NAME:<[name]>
            - narrate format:debug AREA:<[area]>

            - flag <player> areaCreation:!
            - take from:<player.inventory> item:AreaCreation_Item
            - note <[area]> as:INTERNAL_STORY_<[name]>

            - if <[index]> == -1:
                - define index <util.notes.find[<polygon[INTERNAL_STORY_<[name]>]>]>

            - narrate format:debug INDEX:<[index]>

            - flag <util.notes.get[<[index]>]> teleport:<player.location>
            - flag <util.notes.get[<[index]>]> name:<[name]>

            - determine cancelled

    - else if <context.args.get[1]> == cancel:
        # Clear all fake blocks
        - foreach <player.flag[areaCreation].get[points]>:
            - showfake cancel <[value]> players:<player>

        - flag <player> areaCreation:!
        - take from:<player.inventory> item:AreaCreation_Item
        - determine cancelled


AreaCreation_Handler:
    type: world
    events:
        on player right clicks block with:AreaCreation_Item:
        - define areaMode <player.flag[areaCreation].get[mode]>

        - flag <player> areaCreation.points:->:<player.cursor_on>

        # Refresh fake blocks for every point the player clicked
        - foreach <player.flag[areaCreation].get[points]>:
            - showfake red_stained_glass <[value]> d:100s

        - choose <[areaMode]>:
            - case cuboid:
                - if <player.flag[areaCreation].get[points].size.is[MORE].than[1].if_null[false]>:
                    - narrate format:admincallout "Alternatively, right click to remove points in the order that you added them."
                    - narrate format:admincallout "Stand where you wish to have the fast travel point be and type <element[/createarea complete].color[red]> followed by an underscore-separated name to finish"

            - case polygon:
                - if <player.flag[areaCreation].get[points].size.is[MORE].than[99].if_null[false]>:
                    - narrate format:admincallout "For performance purposes polygon areas cannot have more than 100 points, sorry :/"
                    - narrate format:admincallout "Right click to remove points in the order that you added them. Or type /createarea cancel to stop the area creation process altogether"
                    - narrate format:admincallout "Alternatively, <element[Stand where you wish to have the fast travel point be].bold> and type <element[/createarea complete].color[red]> followed by an underscore-separated name to finish"

        on player left clicks block with:AreaCreation_Item:
        # Remove last item in the points list on right click
        - if <player.flag[areaCreation].get[points].size.is[OR_MORE].than[1]>:
            - showfake <player.flag[areaCreation].get[points].last> cancel
            - flag <player> areaCreation.points:<-:<player.flag[areaCreation].get[points].last>

DEBUG_ParticleTest:
    type: task
    definitions: target
    script:
    - playeffect at:<[target].location> effect:witch_magic quantity:200 offset:2
    - playsound sound:ITEM_TRIDENT_THUNDER <player> volume:0.4 pitch:0.5