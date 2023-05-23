##ignorewarning invalid_data_line_quotes

SquadEditConfirm_Item:
    type: item
    material: green_wool
    display name: <green>Edit Squad


SquadEditReject_Item:
    type: item
    material: red_wool
    display name: <red>Cancel


SquadEditConfirm_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Confirm Editing Squad
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [SquadEditConfirm_Item] [] [SquadEditReject_Item] [] [] []
    - [] [] [] [] [] [] [] [] []


SquadSelectionGUI_OLD:
    type: task
    script:
    - define kingdom <player.flag[kingdom]>
    - define squadList <server.flag[armies.<[kingdom]>.squads].keys>
    - define itemList <list[]>

    - if <server.flag[armies.<[kingdom]>.squads].keys.size.if_null[0]> == 0:
        - run PaginatedInterface def.itemList:<list[]> def.page:1 def.player:<player> def.title:Squads
        - determine cancelled

    - foreach <[squadList]> as:squadName:
        - define squadItem <item[SquadInterface_Item]>
        - define squad <server.flag[armies.<[kingdom]>.squads.<[squadName]>]>
        - define name <[squadName]>

        - if <[squad].contains[displayName]>:
            - define name <[squad].get[displayName]>

        - adjust def:squadItem display:<gold><bold><[name]>

        - define npcListShort <[squad].get[npcList].get[1].to[4]>

        - if <[npcListShort].size> < <[squad].get[npcList]>:
            - define remainingNpcNumber <[squad].get[npcList].size.sub[<[npcListShort].size>]>
            - define npcListShort:->:<element[And <[remainingNpcNumber]> Others...].color[gray]>

        - adjust def:squadItem lore:<[npcListShort].separated_by[<n>]>

        - definemap squadInfo:
            internalName: <[squadName]>
            displayName: <[name]>
            npcList: <[squad].get[npcList]>

        - flag <[squadItem]> squadInfo:<[squadInfo]>
        - define itemList:->:<[squadItem]>

    - run PaginatedInterface def.itemList:<[itemList]> def.page:1 def.player:<player> def.title:Squads def.flag:viewingSquads


####################################################################################################
############################################# NEW SHIT #############################################
####################################################################################################


SquadCommand:
    type: command
    name: squad
    usage: /squad list
    description: "Brings up the squad selection window"
    permission: kingdoms.squads
    script:
    - define args <context.raw_args.split_args>

    - if <[args].get[1]> == list:
        - run SquadSelectionGUI


ExitSquadSelector_Item:
    type: item
    material: barrier
    display name: <red><bold>Back


SquadInterfaceFooter_Inventory:
    type: inventory
    inventory: chest
    slots:
    - [] [] [] [] [ExitSquadSelector_Item] [] [] [] []


SquadInterface_Item:
    type: item
    material: player_head
    display name: "<gold><bold>Squad"
    mechanisms:
        skull_skin: 67f11d3f-bd61-4dcf-9675-d0b8919bcad2|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDZjYzZiODM3NjNhNjdmY2FkYTFlYTE4NGMyZDE3NTJhZDI0MDc0NmM2YmUyNThhNzM5ODNkOGI2NTdmNGJiNSJ9fX0=


SquadSelectionGUI:
    type: task
    definitions: player
    script:
    - define __player <[player]>
    - define kingdom <player.flag[kingdom]>
    - define squadList <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList].keys>
    - define itemList <list[]>

    - if <[squadList].size.if_null[0]> == 0:
        - run PaginatedInterface def.itemList:<list[]> def.page:1 def.player:<player> def.title:Squads def.footer:<inventory[SquadInterfaceFooter_Inventory]> def.flag:viewingSquads
        - determine cancelled

    - foreach <[squadList]> as:squadName:
        - define squadItem <item[SquadInterface_Item]>
        - define squad <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>
        - define displayName <[squad].get[displayName]>

        - adjust def:squadItem display:<gold><bold><[displayName]>

        - if <[squad].get[npcList].size.if_null[0]> > 0:
            - define npcListShort <[squad].get[npcList].get[1].to[4]>

            - if <[npcListShort].size> < <[squad].get[npcList]>:
                - define remainingNpcNumber <[squad].get[npcList].size.sub[<[npcListShort].size>]>
                - define npcListShort:->:<element[And <[remainingNpcNumber]> Others...].color[gray]>

            - adjust def:squadItem lore:<[npcListShort].separated_by[<n>]>

        - else:
            - adjust def:squadItem "lore:<gray>Squad Not Spawned Yet."

        - definemap squadInfo:
            internalName: <[squadName]>
            displayName: <[displayName]>
            npcList: <[squad].get[npcList].if_null[<list[]>]>

        - flag <[squadItem]> squadInfo:<[squadInfo]>
        - define itemList:->:<[squadItem]>

    - run PaginatedInterface def.itemList:<[itemList]> def.page:1 def.player:<player> def.footer:<inventory[SquadInterfaceFooter_Inventory]> def.title:Squads def.flag:viewingSquads


SquadFirstSpawnInfo_Item:
    type: item
    material: player_head
    display name: <white><bold>Spawn Squad For First Time?
    mechanisms:
        skull_skin: da4d885d-2505-4f25-bfee-a0de07950191|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDAxYWZlOTczYzU0ODJmZGM3MWU2YWExMDY5ODgzM2M3OWM0MzdmMjEzMDhlYTlhMWEwOTU3NDZlYzI3NGEwZiJ9fX0=
    lore:
    - This squad has been created but not
    - spawned yet. Do you want to spawn it?


SquadConfirm_Item:
    type: item
    material: green_wool
    display name: <dark_green><bold>Confirm


SquadReject_Item:
    type: item
    material: red_wool
    display name: <red><bold>Cancel


SquadDelete_Item:
    type: item
    material: barrier
    display name: <red><bold><underline>Delete Squad


SquadFirstTimeSpawnConfirmation_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Squad First Time Spawn
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [SquadFirstSpawnInfo_Item] [] [] [] []
    - [] [] [SquadConfirm_Item] [] [] [] [SquadReject_Item] [] []
    - [] [] [] [] [SquadDelete_Item] [] [] [] []
    - [] [] [] [] [] [] [] [] []


SquadSelection_Handler:
    type: world
    events:
        ## CLICK SQUAD LIST ICON
        on player clicks SquadInterface_Item in PaginatedInterface_Window flagged:viewingSquads:
        #- inventory open d:SquadControlOptions_Window
        - run flagvisualizer def.flag:<context.item.flag[squadInfo]>
        - define kingdom <player.flag[kingdom]>
        - define hasSpawned <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<context.item.flag[squadInfo.internalName]>.hasSpawned]>

        - if !<[hasSpawned]>:
            - inventory open d:SquadFirstTimeSpawnConfirmation_Window
            - flag <player> datahold.armies.squadInfo:<context.item.flag[squadInfo]>

        ## EXITS SQUAD LIST
        on player clicks ExitSquadSelector_Item in PaginatedInterface_Window flagged:viewingSquads:
        - if <player.has_flag[datahold.armies]>:
            - inventory open d:SquadManager_Interface

        - else:
            - inventory close

        ## SPAWN FIRST TIME
        on player clicks SquadConfirm_Item in SquadFirstTimeSpawnConfirmation_Window:
        - define squadInfo <player.flag[datahold.armies.squadInfo]>
        - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>

        - run SpawnSquadNPCs def.atManager:true def.SMLocation:<[SMLocation]> def.squadName:<[squadInfo].get[internalName]> def.player:<player>

        - inventory close

        ## DELETE FIRST TIME
        on player clicks SquadDelete_Item in SquadFirstTimeSpawnConfirmation_Window:
        - inventory open d:SquadDeleteConfirmation_Window


SquadDeleteConfirmation_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Delete Squad?
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [SquadConfirm_Item] [] [] [] [SquadReject_Item] [] []
    - [] [] [] [] [] [] [] [] []


SquadDeletion_Handler:
    type: world
    events:
        on player clicks SquadConfirm_Item in SquadDeleteConfirmation_Window:
        - define squadInfo <player.flag[datahold.armies.squadInfo]>
        - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
        - define kingdom <player.flag[kingdom]>

        - narrate format:callout "Deleted squad with name: <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadInfo].get[internalName]>.displayName].color[red]>"

        - run DeleteSquad def.SMLocation:<[SMLocation]> def.kingdom:<[kingdom]> def.deletedSquad:<[squadInfo]>


SpawnSquadNPCs:
    type: task
    definitions: atManager|spawnLocation|SMLocation|squadName|player
    FindSpacesAroundSM:
    - define areasAroundSM <list[<[SMLocation].left[1]>|<[SMLocation].right[1]>|<[SMLocation].forward[1]>|<[SMLocation].backward[1]>]>

    - foreach <[areasAroundSM]> as:location:
        - if <[location].material.name> == air && <[location].up[1].material.name> == air:
            - define spawnLocation <[location]>
            - foreach stop

    SpawnSoldiers:
    - define SMData <[SMLocation].flag[squadManager]>
    - define hasSpawned <[SMData].deep_get[squads.squadList.<[squadName]>.hasSpawned]>
    - define soldiers <[SMData].deep_get[squads.squadList.<[squadName]>.totalManpower]>
    - define soldierList <list[]>

    - inject <script.name> path:SpawnSquadLeader

    - if !<[hasSpawned]>:
        - foreach <[SMData].deep_get[squads.squadList.<[squadName]>.squadComp]> key:type as:amount:
            - run SpawnNewSoldiers def.type:<[type]> def.location:<[spawnLocation]> def.amount:<[amount]> def.squadName:<[squadName]> def.SMLocation:<[SMLocation]> def.kingdom:<[kingdom]> save:soldiers
            - define soldierList <[soldierList].include[<entry[soldiers].created_queue.determination.get[1]>]>

    - flag <player> datahold.squadInfo.npcList:<[soldierList]>
    - flag <player> datahold.squadInfo.squadLeader:<[squadLeader]>
    - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.hasSpawned:true
    - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.npcList:<[soldierList]>

    - ~run WriteArmyDataToKingdom def.SMLocation:<[SMLocation]> def.player:<[player]>
    - run GiveSquadTools def.player:<player>

    SpawnSquadLeader:
    - define kingdomColor <script[KingdomTextColors].data_key[<[kingdom]>]>

    - create player <element[Squad Leader].color[<[kingdomColor]>]> <[spawnLocation]> traits:sentinel save:squad_leader
    - define squadLeader <entry[squad_leader].created_npc>
    - flag <[squadLeader]> soldier.isSquadLeader:true
    - flag <[squadLeader]> soldier.squad:<[squadName]>
    - flag <[squadLeader]> soldier.kingdom:<[kingdom]>
    - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.squadLeader:<[squadLeader]>

    - execute as_server "sentinel squad <[kingdom]>_<[squadName]> --id <[squadLeader].id>" silent
    - execute as_server "sentinel respawntime -1 --id <[squadLeader].id>" silent

    script:
    - define kingdom <[player].flag[kingdom]>

    - if <[atManager].if_null[false]>:
        - inject <script.name> path:FindSpacesAroundSM

        - if <[spawnLocation].exists>:
            - inject <script.name> path:SpawnSoldiers

        - else:
            - narrate format:debug "Invalid Location."

    - else:
        - if <[spawnLocation].exists>:
            - inject <script.name> path:SpawnSoldiers

        - else:
            # TODO: Make it so that it gives the player the placement/soldier wand and allow them
            # TODO/ to determine the intial spawn location.
            - narrate WIP


# TODO: Make this differentiate between different soldier types
# TODO Also: Make different soldier types lol
SpawnNewSoldiers:
    type: task
    definitions: type|location|amount|squadName|kingdom|SMLocation
    script:
    - define kingdomColor <script[KingdomTextColors].data_key[<[kingdom]>]>
    - define soldierList <list[]>

    - repeat <[amount]>:
        - create player <element[Squad Member]> <[location]> traits:sentinel save:new_soldier
        - define soldier <entry[new_soldier].created_npc>
        - define soldierList <[soldierList].include[<[soldier]>]>

        - flag <[soldier]> soldier.squad:<[squadName]>
        - flag <[soldier]> soldier.kingdom:<[kingdom]>
        - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.npcList:->:<[soldier]>

        - execute as_server "sentinel squad <[kingdom]>_<[squadName]> --id <[soldier].id>" silent
        - execute as_server "sentinel respawntime -1 --id <[soldier].id>" silent

    - narrate format:debug LST:<[soldierList]>
    - determine <[soldierList]>