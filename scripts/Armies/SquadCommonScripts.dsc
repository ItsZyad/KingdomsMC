##
## All general-purpose, reusable functions related to the squads mechanics can be found here.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2023
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

DeleteSquad:
    type: task
    definitions: SMLocation|kingdom|squadName
    script:
    ## Removes the provided squad from all flag structures that contain it as well as the actual
    ## NPCs that comprise it.
    ##
    ## SMLocation   : [LocationTag]
    ## kingdom      : [ElementTag<String>]
    ## squadName    : [ElementTag<String>]
    ##
    ## >>> [Void]

    - define npcList <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>

    - if <[npcList].size> > 0:
        - foreach <[npcList]> as:soldier:
            - remove <[soldier]>

    - run DeleteSquadReference def.SMLocation:<[SMLocation]> def.kingdom:<[kingdom]> def.squadName:<[squadName]>


DeleteSquadReference:
    type: task
    definitions: SMLocation|kingdom|squadName
    script:
    ## Removes the provided squad from all flag structures that contain it.
    ##
    ## SMLocation   : [LocationTag]
    ## kingdom      : [ElementTag<String>]
    ## squadName    : [ElementTag<String>]
    ##
    ## >>> [Void]

    - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>:!
    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>:!

    - foreach <server.flag[kingdoms.<[kingdom]>.armies.barracks]> as:barrack:
        - if <[barrack].get[stationedSquads].contains[<[squadName]>]>:
            - flag server kingdoms.<[kingdom]>.armies.barracks.<[key]>.stationedSquads:<-:<[squadName]>


CreateSquadReference:
    type: task
    definitions: SMLocation|kingdom|displayName|squadComp|totalManpower
    script:
    ## Creates a new squad reference in the kingdoms.___.armies flag and the squadManager flag
    ## attached to the provided SMLocation. But does not create NPCs
    ##
    ## SMLocation    : [LocationTag]
    ## kingdom       : [ElementTag<String>]
    ## displayName   : [ElementTag<String>]
    ## squadComp     : [MapTag<[ElementTag<String>];[ElementTag<Integer>]>]
    ## totalManpower : [ElementTag<Integer>]
    ##
    ## >>> [Void]

    - define barrackID <[SMLocation].xyz.replace_text[,]>
    - define squadLimitLevel <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.levels.squadLimitLevel]>
    - define squadLimit <script[SquadManagerUpgrade_Data].data_key[levels.SquadAmount.<[squadLimitLevel]>.value]>

    - if <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.stationedSquads].size.if_null[0]> >= <[squadLimit]>:
        - narrate format:callout "These barracks have already reached their stationing capacity!<n>You must upgrade your squad manager to increase its stationing capacity."
        - determine cancelled

    - define internalName <[displayName].replace_text[ ].with[-]>
    - define squadID <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList].last.get[ID].add[1].if_null[1]>
    - define kingdomColor <script[KingdomTextColors].data_key[<[kingdom]>]>
    - definemap squadMap:
        npcList: <list[]>
        squadComp: <[squadComp]>
        totalManpower: <[totalManpower]>
        hasSpawned: false
        displayName: <[displayName]>
        ID: <[squadID]>
        name: <[internalName]>
        # Note: could be an upgrade to allow for better default equipment(?)
        standardEquipment:
            helmet: <item[leather_helmet[color=<[kingdomColor]>]].with_flag[defaultArmor]>
            chestplate: <item[leather_chestplate].with_flag[defaultArmor]>
            leggings: <item[leather_leggings].with_flag[defaultArmor]>
            boots: <item[leather_boots].with_flag[defaultArmor]>
            hotbar: <list[wooden_sword]>

    - flag <[SMLocation]> squadManager.squads.squadList.<[internalName]>:<[squadMap]>
    - run WriteArmyDataToKingdom def.SMLocation:<[SMLocation]> def.kingdom:<[kingdom]>

    - if <player.exists>:
        - narrate format:callout "Created squad with name: <[displayName]>"


WriteArmyDataToKingdom:
    type: task
    definitions: SMLocation|kingdom
    script:
    ## Ensures that the kingdom.armies flag contains the same information as the squad manager
    ## flag of the provided SMLocation
    ##
    ## SMLocation : [LocationTag]
    ## kingdom    : [ElementTag<String>]
    ##
    ## >>> [Void]

    - define squadManagerID <[SMLocation].simple.split[,].remove[last].unseparated>
    - define SMData <[SMLocation].flag[squadManager]>
    - define stationedSquads <[SMData].deep_get[squads.squadList].keys> if:<[SMData].deep_get[squads.squadList].exists>
    - define SMData <[SMData].exclude[kingdom].exclude[id].deep_exclude[squads]>

    - flag server kingdoms.<[kingdom]>.armies.barracks.<[squadManagerID]>:<[SMData]>
    - flag server kingdoms.<[kingdom]>.armies.barracks.<[squadManagerID]>.location:<[SMLocation]>
    - flag server kingdoms.<[kingdom]>.armies.barracks.<[squadManagerID]>.stationedSquads:<[stationedSquads]> if:<[stationedSquads].exists>
    - flag server kingdoms.<[kingdom]>.armies.squads.squadList:!

    - foreach <[SMLocation].flag[squadManager.squads.squadList].if_null[<list[]>]>:
        - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[key]>:<[value]>


GiveSquadTools:
    type: task
    definitions: player|saveInv
    script:
    ## Replaces the provided player's hotbar with squad management tools
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [Void]

    - define __player <[player]>
    - define saveInv true if:<[saveInv].exists.not>
    - flag <player> datahold.armies.previousItemSlot:<player.held_item_slot>
    - flag <player> datahold.armies.squadTools:1

    - if <[saveInv]>:
        - run TempSaveInventory def.player:<player>

    - give SquadMoveTool_Item
    - give SquadAttackAllTool_Item
    - give SquadAttackTool_Item
    - inventory set slot:9 origin:ExitSquadControls_Item
    - inventory set slot:8 origin:MiscOrders_Item
    - adjust <player> item_slot:1


ResetSquadTools:
    type: task
    definitions: player
    script:
    ## Gives the player back the inventory they had before selecting the squad tools
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [Void]

    - define __player <[player]>

    - run LoadTempInventory def.player:<player>

    - if <player.has_flag[datahold.armies.previousItemSlot]>:
        - adjust <player> item_slot:<player.flag[datahold.armies.previousItemSlot]>
        - flag <player> datahold.armies.previousItemSlot:!


GetSquadInfo:
    type: task
    definitions: kingdom|squadName
    script:
    ## Gets the full squad information of a given squad under the given kingdom
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [MapTag]

    # GlobalRef refers to the version of army data stored on the kingdoms.___.armies flag while
    # LocalRef refers to the copy of data stored on each SM belonging to the kingdom
    - define globalRef <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>
    - define barrackList <server.flag[kingdoms.<[kingdom]>.armies.barracks]>
    - define barrackLocation null
    - define localRef null

    - foreach <[barrackList]> as:barrack:
        - if <[barrack].get[stationedSquads].contains[<[squadName]>]>:
            - define barrackLocation <[barrack].get[location]>
            - foreach stop

    - if <[barrackLocation].has_flag[squadManager]>:
        - define localRef <[barrackLocation].flag[squadManager].deep_get[squads.squadList.<[squadName]>]>

        # TODO: find a way to properly compare these maps
        - if !<[localRef].equals[<[globalRef]>]>:
            # - run flagvisualizer def.flag:<[localRef]> def.flagName:localRef
            - determine <[localRef]>

    # - run flagvisualizer def.flag:<[globalRef]> def.flagName:globalRef
    - determine <[globalRef]>


GetSquadSMLocation:
    type: task
    definitions: kingdom|squadName
    script:
    ## Gets the SM associated with the squad provided
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [LocationTag]

    - define barracks <server.flag[kingdoms.<[kingdom]>.armies.barracks]>
    - define stationingInfo <[barracks].parse_value_tag[<[parse_value].get[stationedSquads]>]>

    - foreach <[stationingInfo]>:
        - if <[value].contains[<[squadName]>]>:
            - define SMID <[key]>
            - define location <[barracks].get[<[SMID]>].get[location]>
            - determine <[location]>


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


GenerateSMID:
    type: task
    definitions: location
    script:
    ## Generates the ID used to refer to SMs in the kingdom flag using the location of the SM
    ##
    ## location : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - determine <[location].simple.split[,].remove[last].unseparated>


GetMaxSMAOESize:
    type: procedure
    definitions: SMLocation
    script:
    ## Gets the maximum size that a squad manager's AOE can be at its current level.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>

    - run GetSquadInfo def.kingdom:<[kingdom]> def.SMLocation:<[SMLocation]> save:squadInfo
    - define squadInfo <entry[squadInfo].created_queue.determination.get[1]>
    - define AOELevel <[squadInfo].deep_get[levels.AOELevel]>

    - determine <script[SquadManagerUpgrade_Data].data_key[levels.AOE.<[AOELevel]>.value]>
