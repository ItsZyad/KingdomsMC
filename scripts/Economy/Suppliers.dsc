##
## * All files related to the simulated supplier mechanic which
## * provides Kingdoms merchants with all the necessary materials
## * to sell players as well as the market creator code (temp)
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Oct 2022
## @Script Ver: INDEV
##
## ----------------END HEADER-----------------

## UNTESTED! TEST EVERYTHING BEFORE MOVING FORWARD
MarketCreation_Command:
    type: command
    name: market
    usage: /market create|remove [name]
    permission: kingdoms.admin.markets
    description: Designates a market with a given name and area
    tab completions:
        1: create|remove
        2: [Name]

    tab complete:
    - define args <context.raw_args.split_args>

    - if <[args].get[1]> == create:
         - choose <[args].size>:
            - case 2:
                - determine <list[[Market Size]]>
            - case 3:
                - determine <list[[Attractiveness]]>

    script:
    - define args <context.raw_args.split_args>
    - define action <[args].get[1]>
    - define name <[args].get[2]>
    - define size <[args].get[3]>
    - define attractiveness <[args].get[4]>

    - if <server.has_flag[economy.markets.<[name]>]>:
        - narrate format:admincallout "There already exists a market with that name. Please choose a different name."
        - determine cancelled

    - if <[action].exists> && <[name].exists>:
        - choose <[action].to_lowercase>:
            - case create:
                - flag server economy.markets.<[name]>.ID:<server.flag[economy.markets].size.add[1]>
                - flag server economy.markets.<[name]>.size:<[size]>
                - flag server economy.markets.<[name]>.attractiveness:<[attractiveness]>

                - clickable save:make_area until:10m usages:1 for:<player>:
                    - give to:<player.inventory> MarketCreation_Item
                    - narrate format:admincallout "Click the blocks you would like to constitute the borders of the market area. Drop the market wand to cancel the process.<n>Type <element[/market complete].color[green]> to finish the process."

                - narrate format:admincallout "You may optionally define an area that a market operates in. This will restrict the places where merchants can spawn."
                - narrate "<blue>Would you like to do that?"
                - narrate "<n><element[Yes].color[green].on_click[<entry[make_area].command>]> / <element[No].color[red].on_click[<green>Created market area: '<[name]>']>"

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


SupplyAmountCalculator:
    type: task
    script:
    - yaml load:economy_data/price-info.yml id:prices
    - define rawItems <yaml[prices].read[price_info.items]>
    - define items <list[]>

    - foreach <[rawItems]> as:group:
        - define items <[items].include[<[group]>]>

    - define rawItems:!

    - yaml id:prices unload