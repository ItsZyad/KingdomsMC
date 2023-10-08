##
## [KAPI]
## All scripts that read and modify data at the squad-level of the army mechanic.
##
## @Author: Zyad (ITSZYAD#9280)
## @Original Scripts: Jun 2023
## @Date: Oct 2023
## @Script Ver: v0.1
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
