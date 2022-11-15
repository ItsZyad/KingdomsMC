##
## * All files related to the creation of regular market
## * and regular merchants in Kingdoms
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Nov 2022
## @Script Ver: INDEV
##
## ----------------END HEADER-----------------


MarketCreation_Command:
    type: command
    name: market
    usage: /market create|remove [name] [attractiveness] [max size]
    permission: kingdoms.admin.markets
    description: Designates a market with a given name and area
    tab completions:
        1: create|remove
        2: [Name]
        3: [Attractiveness]
        4: [?MaxSize]
    script:
    - define args <context.raw_args.split_args>
    - define action <[args].get[1]>
    - define name <[args].get[2]>
    - define attractiveness <[args].get[3]>
    - define maxSize <[args].get[4].if_null[n/a]>

    - if <[args].size> < 3:
        - narrate format:admincallout "You must provide all the details for market creation as shown in the command's tab-complete"
        - determine cancelled

    - if <server.has_flag[economy.markets.<[name]>]>:
        - narrate format:admincallout "There already exists a market with that name. Please choose a different name."
        - determine cancelled

    - if <[action].exists> && <[name].exists>:
        - choose <[action].to_lowercase>:
            - case create:
                - flag server economy.markets.<[name]>.ID:<server.flag[economy.markets].size.if_null[0].add[1]>
                - flag server economy.markets.<[name]>.size:0
                - flag server economy.markets.<[name]>.attractiveness:<[attractiveness]>
                - flag server economy.markets.<[name]>.maxSize:<[maxSize]> if:<[maxSize].equals[n/a].not>
                #- flag server economy.markets.<[name]>.supplyMap:<entry[supplyAmount].created_queue.determination.get[1]>

                - clickable save:make_area until:10m usages:1 for:<player>:
                    - give to:<player.inventory> MarketCreation_Item
                    - narrate format:admincallout "Click the blocks you would like to constitute the borders of the market area. Drop the market wand to cancel the process.<n>Type <element[/market complete].color[green]> to finish the process."
                    - narrate format:admincallout "<gray><italic>Note: This does not need to be an exact area. You will still be able to determine where individual merchants can go."

                - clickable save:no_make_area until:10m usages:1 for:<player>:
                    - narrate "<green>Created market area: '<[name].bold.underline>'"

                - narrate format:admincallout "You may optionally define an area that a market operates in. This will restrict the places where merchants can spawn."
                - narrate "<blue>Would you like to do that?"
                - narrate "<n><element[Yes].color[green].on_click[<entry[make_area].command>]> / <element[No].color[red].on_click[<entry[no_make_area].command>]>"

            - case complete:
                - define minY 999
                - define maxY -999
                - define world <player.location.world>
                - define coordList <list[]>

                - foreach <player.flag[marketPoints]> as:point:
                    - define coordList:->:<[point].x>
                    - define coordList:->:<[point].z>

                    - if <[point].y> > <[maxY]>:
                        - define maxY <[point].y>
                    - if <[point].y> < <[minY]>:
                        - define minY <[point].y>

                - define marketArea <polygon[<[world].name>,<[minY]>,<[maxY]>,<[coordList].comma_separated.replace_text[<&sp>].with[]>]>

                - take from:<player.inventory> item:MarketCreation_Item

                - foreach <player.flag[marketPoints]> as:point:
                    - showfake cancel <[point]>

                - flag <player> marketPoints:!
                - showfake red_stained_glass <[marketArea].outline_2d[<player.location.y.add[10]>]>
                - note <[marketArea]> as:<[name]>
                - narrate format:admincallout "Created market area: '<[name]>'!"

            - case remove:
                - if <server.has_flag[economy.markets.<[name]>]>:
                    - narrate format:admincallout "Removed market with name: <[name]>"
                    - flag server economy.markets.<[name]>:!

                - else:
                    - narrate format:admincallout "There exists no market with the name"

            - default:
                - narrate format:admincallout "<[action].color[red]> is not a valid argument."

    - else:
        - narrate format:admincallout "You must provide a create/remove action and an ID to create a market."


MarketCreation_Item:
    type: item
    material: blaze_rod
    display name: <gold><bold>Market Designation Wand


MarketCreation_Handler:
    type: world
    events:
        on player clicks block with:MarketCreation_Item:
        - flag <player> marketPoints:->:<player.cursor_on>

        - foreach <player.flag[marketPoints]> as:point:
            - showfake red_stained_glass <[point]> d:100s

        on player drops MarketCreation_Item:
        - determine passively cancelled
        - narrate "Cancelled market creation process!"
        - take from:<player.inventory> item:MarketCreation_Item

        - foreach <player.flag[marketPoints]> as:point:
            - showfake cancel <[point]>

        - flag <player> marketPoints:!


MerchantCreation_Command:
    type: command
    name: merchant
    usage: /merchant create|remove [market]|[ID] [name]
    permission: kingdoms.admin.merchants
    description: Creates, removes, or edits regular Kingdoms merchants
    script:
    - define args <context.raw_args.split_args>
    - define action <[args].get[1]>

    - choose <[action]>:
        - case create:
            - define market <[args].get[2]>
            - define mercName <[args].get[3]>

        - case remove:
            - define mercID <[args].get[2]>

MerchantPlacement_Item:
    type: item
    material: armor_stand
    display name: <blue><bold>Merchant Placement Stand
    mechanisms:
        hides: ALL
    enchantments:
    - sharpness: 1

MerchantPlacement_Handler:
    type: world
    debug: false
    events:
        # When player selects merchant tool for the first time
        on player holds item item:MerchantPlacement_Item:
        - if !<player.has_flag[PlacingMerchant]>:
            - flag <player> PlacingMerchant

        # When player deselects merchant tool
        on player holds item flagged:PlacingMerchant:
        - if <player.inventory.slot[<context.new_slot>].script.name.to_lowercase.if_null[null]> != merchantplacement_item:
            - fakespawn cancel <player.flag[PlacingMerchant].get[1]>
            - flag <player> PlacingMerchant:!

        on player walks flagged:PlacingMerchant:
        - ratelimit <player> 1t
        - if <player.flag[PlacingMerchant].get[2].if_null[<player.cursor_on>]> != <player.cursor_on.up[1].add[0.5,0,0.5]>:
            - fakespawn armor_stand <player.cursor_on.up[1].add[0.5,0,0.5]> save:fake_stand
            - fakespawn cancel <player.flag[PlacingMerchant].get[1]> if:<player.flag[PlacingMerchant].get[1].exists>
            - flag <player> PlacingMerchant:<list[<entry[fake_stand].faked_entity>|<player.cursor_on.up[1].add[0.5,0,0.5]>]>