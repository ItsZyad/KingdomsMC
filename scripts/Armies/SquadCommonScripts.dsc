DeleteSquad:
    type: task
    definitions: SMLocation|kingdom|deletedSquad
    script:
    ## Removes the provided squad from all flag structures that contain it as well as the actual
    ## NPCs that comprise it.
    ##
    ## SMLocation   : [LocationTag]
    ## kingdom      : [ElementTag<String>]
    ## deletedSquad : [MapTag]
    ##                Format: [internalName;displayName;npcList]

    - define npcList <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[deletedSquad].get[internalName]>]>

    - if <[npcList].size> > 0:
        - foreach <[npcList]> as:soldier:
            - remove <[soldier]>

    - run DeleteSquadReference def.SMLocation:<[SMLocation]> def.kingdom:<[kingdom]> def.deletedSquad:<[deletedSquad]>


DeleteSquadReference:
    type: task
    definitions: SMLocation|kingdom|deletedSquad
    script:
    ## Removes the provided squad from all flag structures that contain it.
    ##
    ## SMLocation   : [LocationTag]
    ## kingdom      : [ElementTag<String>]
    ## deletedSquad : [MapTag]
    ##                Format: [internalName;displayName;npcList]

    - flag <[SMLocation]> squadManager.squads.squadList.<[deletedSquad].get[internalName]>:!
    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[deletedSquad].get[internalName]>:!

    - foreach <server.flag[kingdoms.<[kingdom]>.armies.barracks]> as:barrack:
        - if <[barrack].get[stationedSquads].contains[<[deletedSquad].get[internalName]>]>:
            - flag server kingdoms.<[kingdom]>.armies.barracks.<[key]>.stationedSquads:<-:<[deletedSquad].get[internalName]>


CreateSquadReference:
    type: task
    definitions: SMLocation|kingdom|displayName
    script:
    ## Creates a new squad reference in the kingdoms.<...>.armies flag and the squadManager flag
    ## attached to the provided SMLocation. But does not create NPCs
    ##
    ## SMLocation  : [LocationTag]
    ## kingdom     : [ElementTag<String>]
    ## displayName : [ElementTag<String>]

    - define barrackID <[SMLocation].xyz.replace_text[,]>

    - if <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.stationedSquads].size> >= <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.levels.squadLimit]>:
        - narrate format:callout "These barracks have already reached their stationing capacity!<n>You must upgrade your squad manager to increase its stationing capacity."
        - determine cancelled

    - define internalName <[displayName].replace_text[ ].with[-]>
    - define squadID <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList].last.get[ID].add[1].if_null[1]>
    - define squadMap <player.flag[datahold.armies.squadMap].include[name=<[internalName]>;displayName=<[displayName]>;ID=<[squadID]>]>

    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[internalName]>:<[squadMap]>
    - flag server kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.stationedSquads:->:<[internalName]>
    - flag <[SMLocation]> squadManager.squads.squadList.<[internalName]>:<[squadMap]>

    - narrate format:callout "Created squad with name: <[displayName]>"


WriteArmyDataToKingdom:
    type: task
    definitions: SMLocation|player
    script:
    ## Ensures that the kingdom.armies flag contains the same information as the squad manager
    ## flag of the provided SMLocation
    ##
    ## SMLocation : [LocationTag]
    ## player     : [PlayerTag]

    - define kingdom <[player].flag[kingdom]>
    - define squadManagerID <[SMLocation].simple.split[,].remove[last].unseparated>
    - define SMData <[SMLocation].flag[squadManager]>
    - define stationedSquads <[SMData].deep_get[squads.squadList].keys>
    - define SMData <[SMData].exclude[kingdom].exclude[id].deep_exclude[squads]>

    - flag server kingdoms.<[kingdom]>.armies.barracks.<[squadManagerID]>:<[SMData]>
    - flag server kingdoms.<[kingdom]>.armies.barracks.<[squadManagerID]>.location:<[SMLocation]>
    - flag server kingdoms.<[kingdom]>.armies.barracks.<[squadManagerID]>.stationedSquads:<[stationedSquads]>

    - foreach <[SMLocation].flag[squadManager.squads.squadList]>:
        - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[key]>:<[value]>


GiveSquadTools:
    type: task
    definitions: player
    script:
    ## Replaces the provided player's hotbar with squad management tools
    ##
    ## player : [PlayerTag]

    - define __player <[player]>
    - flag <player> datahold.armies.previousItemSlot:<player.held_item_slot>

    - run TempSaveInventory def.player:<player>
    - give SquadMoveTool_Item
    - inventory set slot:9 origin:ExitSquadControls_Item
    - adjust <player> item_slot:1


ResetSquadTools:
    type: task
    definitions: player
    script:
    ## Gives the player back the inventory they had before selecting the squad tools
    ##
    ## player : [PlayerTag]

    - define __player <[player]>

    - run LoadTempInventory def.player:<player>

    - if <player.has_flag[datahold.armies.previousItemSlot]>:
        - adjust <player> item_slot:<player.flag[datahold.armies.previousItemSlot]>
        - flag <player> datahold.armies.previousItemSlot:!