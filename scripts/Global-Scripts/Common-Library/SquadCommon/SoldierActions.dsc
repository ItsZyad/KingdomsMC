##
## [KAPI]
## All scripts relating to the reading and modification of soldier-specific information.
##
## @Author: Zyad (ITSZYAD#9280)
## @Original Scripts: Jun 2023
## @Date: Oct 2023
## @Script Ver: v0.1
##
## ----------------END HEADER-----------------

GiveSoldierItemFromArmory:
    type: task
    definitions: soldier|squadName|kingdom|armories|item
    script:
    ## Gives the provided soldier an item from their squad's armory if it exists
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ## soldier   : [NPCTag]
    ## item      : [ItemTag]
    ## armories  : ?[ListTag<LocationTag>]
    ##
    ## >>> [Void]

    - if !<[armories].exists>:
        - run GetSquadSMLocation def.squadName:<[squadName]> def.kingdom:<[kingdom]> save:SMLocation
        - define SMLocation <entry[SMLocation].created_queue.determination.get[1]>
        - define filledArmories <[SMLocation].flag[squadManager.armories].filter_tag[<[filter_value].inventory.is_empty.not>]>

    - else:
        - define filledArmories <[armories].filter_tag[<[filter_value].inventory.is_empty.not>]>

    - define anyInvHasItem <[filledArmories].parse_tag[<[parse_value].inventory.list_contents.find_all_matches[<[item]>]>]>

    # TODO(Medium): next-best-item search.
    # - if !<[anyInvHasItem]>:
    #     - define expandedSearch <[filledArmories].parse_tag[<[parse_value].inventory.list_contents.parse_tag[<[parse_value].material.name>]>]>
    #     - define anyInvHasItem <[expandedSearch]>

    - determine cancelled if:<[anyInvHasItem].is_empty>

    - foreach <[filledArmories]> as:loc:
        - if <[loc].inventory.list_contents.contains[<[item]>]>:
            - if <[item].advanced_matches[*_boots|*_chestplate|*_leggings|*_helmet]>:
                - define oldArmor <[soldier].equipment>

                - equip <[soldier]> boots:<[item]> if:<[item].advanced_matches[*_boots]>
                - equip <[soldier]> head:<[item]> if:<[item].advanced_matches[*_helmet]>
                - equip <[soldier]> legs:<[item]> if:<[item].advanced_matches[*_leggings]>
                - equip <[soldier]> chest:<[item]> if:<[item].advanced_matches[*_chestplate]>

                - define replacedItem <[soldier].equipment.exclude[<[oldArmor]>]>
                - give to:<[loc].inventory> <[soldier].slot[<[replacedItem]>]>

            - else:
                - define nextHotbarItemSlot <[soldier].inventory.find_item[*]>
                - give to:<[loc].inventory> <[soldier].slot[<[nextHotbarItemSlot]>]>
                - give to:<[soldier].inventory> <[item]>
                - adjust <[soldier]> item_slot:1

            - take from:<[loc].inventory> item:<[item]>
