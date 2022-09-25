## WORK ON THIS LATER ##
##ignorewarning invalid_data_line_quotes

GiveBlockCheckWand:
    type: command
    name: blockcheckwand
    usage: /blockcheckwand
    permission: kingdoms.admin
    description: ADMIN
    script:
    - flag player ChestCheckDef2:!
    - flag player ChestCheckDef1:!
    - give to:<player.inventory> item:blockCheckWand

BlockChecker:
    type: task
    definitions: cornerOne|cornerTwo|query
    script:
    - narrate format:admincallout "Please wait while the search function handles your query..."

    - define searchRange <cuboid[<player.world.name>,<[cornerOne].xyz>,<[cornerTwo].xyz>]>
    - narrate <[searchRange]>

    - if <[query].split[,].get[1]> == chests:
        - define itemSearch <[query].split[,].get[2]>
        - narrate ----------------------------------

        - if <[itemSearch]> == all:
            - define itemSearch *

        - foreach <[searchRange].blocks[*]>:
            - if <[value].has_inventory>:
                - if <[value].inventory.list_contents.size> != 0:
                    - if <proc[ChestItemChecker].context[<[value]>|<[itemSearch]>].size.is[MORE].than[1]>:
                        - narrate <proc[ChestItemChecker].context[<[value]>|<[itemSearch]>]>
                        - narrate Location:<&sp><blue><[value].xyz>
                        - narrate ----------------------------------

        - narrate format:admincallout Done!

    - if <[query].split[,].get[1]> == blocks:
        - define blockType <[query].split[,].get[2]>

        - narrate <[searchRange].blocks[<[blockType]>]>
        - narrate format:admincallout Done!

ChestItemChecker:
    type: procedure
    definitions: itemList|itemSearch
    script:
    - define outList <list[]>
    - define conspiciousItems <list[]>

    - foreach <[itemList].inventory.list_contents>:
        - if <[value].material.name.advanced_matches[<[itemSearch]>]>:
            - define conspiciousItems:->:<red><[value].material.name>

        - else:
            - define outList:->:<[value].material.name>

    - determine <[conspiciousItems].separated_by[<&sp><yellow>||<&sp>]>

BlockChecker_Handler:
    type: world
    events:
        on player clicks block with:BlockCheckWand:
        - if <player.has_flag[ChestCheckDef1]>:
            - flag player ChestCheckDef2:<context.location>
            - narrate format:admincallout "Location 2 Marked"
            - take from:<player.inventory> item:BlockCheckWand

            - flag player blockSearchQuery
            - narrate format:admincallout "Please give a search query with each parameter separated by a ','"

        - else:
            - flag player ChestCheckDef1:<context.location>
            - narrate format:admincallout "Location 1 Marked"

        on player chats:
        - if <player.has_flag[blockSearchQuery]>:
            - run BlockChecker def:<player.flag[ChestCheckDef1]>|<player.flag[ChestCheckDef2]>|<context.message>
            - flag player blockSearchQuery:!
            - determine cancelled

BlockCheckWand:
    type: item
    material: blaze_rod
    display name: "<dark_purple><bold>Chest Search Wand"