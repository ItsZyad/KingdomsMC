##
## [KAPI]
## All scripts relating to the reading and modification of soldier-specific information.
##
## @Author: Zyad (ITSZYAD#9280)
## @Original Scripts: Jun 2023
## @Date: Oct 2023
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

GetSoldierMissingStandardEquipment:
    type: procedure
    definitions: soldier[NPCTag]
    description:
    - Returns a list of all the squad-standard equipment missing from the provided soldier.
    - Will return null if the provided NPC is not a soldier.
    - ---
    - → [ListTag(ItemTag)]

    script:
    ## Returns a list of all the squad-standard equipment missing from the provided soldier.
    ##
    ## Will return null if the provided NPC is not a soldier.
    ##
    ## soldier : [NPCTag]
    ##
    ## >>> [ListTag<ItemTag>]

    - if !<[soldier].has_flag[soldier]>:
        - determine null

    - define kingdom <[soldier].flag[soldier.kingdom]>
    - define squadName <[soldier].flag[soldier.squad]>
    - define standardEquipment <proc[GetSquadEquipment].context[<[kingdom]>|<[squadName]>]>

    # Compare the armor and equipment that the soldier has against the standard equipment
    - define soldierArmor <[soldier].equipment>
    - define standardArmor <[standardEquipment].exclude[hotbar].values>
    - define missingEquipment <list[]>
    - define soldierHotbar <[soldier].inventory.list_contents.get[1].to[9].if_null[<list[]>].sort_by_value[material.name]>
    - define standardHotbar <[standardEquipment].get[hotbar].sort_by_value[material.name]>

    - if <[standardArmor]> != <[soldierArmor]> || <[soldierHotbar]> != <[standardHotbar]>:
        - define missingEquipment <[missingEquipment].include[<[standardArmor].exclude[<[soldierArmor]>]>]>
        - define missingEquipment <[missingEquipment].include[<[standardHotbar].exclude[<[soldierHotbar]>]>]>

    - determine <[missingEquipment]>


GiveSoldierItemFromArmory:
    type: task
    definitions: soldier[NPCTag]|squadName[ElementTag(String)]|kingdom[ElementTag(String)]|armories[?ListTag(LocationTag)]|item[ItemTag]
    description:
    - Gives the provided soldier an item from their squad's armory if it exists.
    - ---
    - → [Void]

    script:
    ## Gives the provided soldier an item from their squad's armory if it exists.
    ##
    ## kingdom   :  [ElementTag<String>]
    ## squadName :  [ElementTag<String>]
    ## soldier   :  [NPCTag]
    ## item      :  [ItemTag]
    ## armories  : ?[ListTag<LocationTag>]
    ##
    ## >>> [Void]

    - if !<[armories].exists>:
        - define SMLocation <proc[GetSquadSMLocation].context[<[kingdom]>|<[squadName]>]>
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
        - if !<[loc].inventory.list_contents.contains[<[item]>]>:
            - foreach next

        - if <[item].advanced_matches[*_boots|*_chestplate|*_leggings|*_helmet]>:
            - define oldArmor <[soldier].equipment>

            - equip <[soldier]> boots:<[item]> if:<[item].advanced_matches[*_boots]>
            - equip <[soldier]> head:<[item]> if:<[item].advanced_matches[*_helmet]>
            - equip <[soldier]> legs:<[item]> if:<[item].advanced_matches[*_leggings]>
            - equip <[soldier]> chest:<[item]> if:<[item].advanced_matches[*_chestplate]>

            - define replacedItem <[soldier].equipment.exclude[<[oldArmor]>]>
            - give to:<[loc].inventory> <[soldier].slot[<[replacedItem]>]>

        - else:
            - inject <script.name> path:GiveItemBackToArmory
            - give to:<[soldier].inventory> <[item]>

        - take from:<[loc].inventory> item:<[item]>
        - stop

    GiveItemBackToArmory:
    - define giveBackLoc <[loc]>

    - if <[loc].inventory.find_empty_slots.size> == 0:
        - foreach <[armories]> as:armory:
            - if <[armory].inventory.find_empty_slots.size> > 0:
                - define giveBackLoc <[armory]>
                - foreach stop

    - define nextHotbarItemSlot <[soldier].inventory.find_item[air]>
    - define nextHotbarItemSlot <[soldier].inventory.find_item[*]> if:<[soldier].inventory.slot[1|2|3|4|5|6|7|8|9].filter_tag[<[filter_value].material.name.equals[air]>].size.equals[0]>

    - if <[soldier].inventory.slot[<[nextHotbarItemSlot]>].material.name> != air:
        - give <[soldier].inventory.slot[<[nextHotbarItemSlot]>]> to:<[giveBackLoc].inventory>
