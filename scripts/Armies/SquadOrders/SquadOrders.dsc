##
## All of the smaller squad order scripts can be found here + some move/attack related helper tasks.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: May 2023
## @Script Ver: v1.1
##
## ----------------END HEADER-----------------


SoldierManager_Assignment:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true

        on click:
        - if !<npc.has_flag[soldier]>:
            - determine cancelled

        - define kingdom <npc.flag[soldier.kingdom]>
        - define squadName <npc.flag[soldier.squad]>

        - flag <player> datahold.squadInfo:<server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>

        - if <player.flag[kingdom]> != <[kingdom]>:
            - determine cancelled

        - inventory close
        - run GiveSquadTools def.player:<player>


SquadRecall_Item:
    type: item
    material: player_head
    display name: <white><bold>Recall to Base
    mechanisms:
        skull_skin: bd2c2584-f53e-4829-81a3-5cff044e4979|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOGFhMTg3ZmVkZTg4ZGUwMDJjYmQ5MzA1NzVlYjdiYTQ4ZDNiMWEwNmQ5NjFiZGM1MzU4MDA3NTBhZjc2NDkyNiJ9fX0=


MiscOrders_Item:
    type: item
    material: player_head
    display name: <blue><bold>Show Misc Orders
    mechanisms:
        skull_skin: 49821769-c171-4288-9b95-ba04b799186f|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvY2EzYjlkNzFiYjU5NDI2NTdkNjZhNjMwMzMyZGIyYjk2MTg5ZjI1MTI3MTBlYzhjMzE0OTIxOGM4NTNmZGRiNiJ9fX0=


ExitSquadControls_Item:
    type: item
    material: barrier
    display name: <red><bold>Exit Squad Controls


SquadMoveTool_Item:
    type: item
    material: blaze_rod
    display name: <gold><bold>Move Order
    enchantments:
    - sharpness:1
    mechanisms:
        hides: enchants


SquadAttackTool_Item:
    type: item
    material: tipped_arrow
    display name: <light_purple><bold>Attack Order
    mechanisms:
        potion_effects:
        - [type=TURTLE_MASTER]
        hides: ALL


SquadOptions_Handler:
    type: world
    events:
        ## MISC ORDERS
        on player right clicks block with:MiscOrders_Item flagged:datahold.armies.squadTools:
        - if <player.flag[datahold.armies.squadTools]> != 1:
            - run GiveSquadTools def.player:<player> def.saveInv:false

        - else:
            - repeat 7:
                - inventory slot:<[value]> set origin:air

            - give to:<player.inventory> SquadRecall_Item

        - determine cancelled

        ## RECALL SQUAD
        on player right clicks block with:SquadRecall_Item:
        - define kingdom <player.flag[kingdom]>
        - define squadInfo <player.flag[datahold.squadInfo]>
        - define npcList <[squadInfo].get[npcList].include[<[squadInfo].get[squadLeader]>]>
        - define stationInfo <server.flag[kingdoms.<[kingdom]>.armies.barracks].parse_value_tag[<[parse_value].get[stationedSquads]>]>
        - define barrackID 0

        - foreach <[stationInfo]>:
            - if <[value].contains[<[squadInfo].get[name]>]>:
                - define barrackID <[key]>
                - foreach stop

        - if <[barrackID]> == 0:
            - narrate format:debug "<red>[Internal Error SQA111] <&gt><&gt> <gold>Cannot associate squad with barrack."
            - determine cancelled

        - run ResetSquadTools def.player:<player>

        - define SMLocation <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.location]>
        - inject SpawnSquadNPCs path:FindSpacesAroundSM

        - foreach <[npcList]> as:npc:
            - run WalkSoldierToSM_Helper def.npc:<[npc]> def.location:<[spawnLocation]>

        - run SquadEquipmentChecker def.squadName:<[squadInfo].get[internalName]> def.kingdom:<[kingdom]>

        - narrate format:callout "Stashing squad at barracks: <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.name].color[red]>..."
        - narrate format:callout "To respawn the squad click on their icon in the squad list option in your SM."
        - determine cancelled

        ## ATTACK ORDER: ALL
        on player right clicks block with:SquadAttackTool_Item:
        - define <player.flag[kingdom]>
        - define squadInfo <player.flag[datahold.squadInfo]>
        - define squadName <[squadInfo].get[name]>
        - run GetSquadSMLocation def.kingdom:<[kingdom]> def.squadName:<[squadName]> save:SMLocation
        - define SMLocation <entry[SMLocation].created_queue.determination.get[1]>
        - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.attack:all expire:1h

        ## REG. MOVE SQUAD
        on player right clicks block with:SquadMoveTool_Item:
        - ratelimit <player> 1s
        - define kingdom <player.flag[kingdom]>
        - define location <player.cursor_on_solid[50]>
        - define squadInfo <player.flag[datahold.squadInfo]>
        - define squadName <[squadInfo].get[internalName]>
        - define npcList <[squadInfo].get[npcList]>
        - define squadLeader <[squadInfo].get[squadLeader]>
        - define displayName <[squadInfo].get[displayName]>

        - run FormationWalk def.npcList:<[npcList]> def.squadLeader:<[squadLeader]> def.npcsPerRow:3 def.finalLocation:<[location].with_yaw[<player.location.yaw.round_to_precision[5]>]> def.lineLength:6 def.player:<player>

        ## EXITS ORDERS
        on player clicks block with:ExitSquadControls_Item:
        - flag <player> datahold.squadInfo:!
        - run ResetSquadTools def.player:<player>

        on player places ExitSquadControl_Item:
        - determine cancelled

        on player drops SquadMoveTool_Item:
        - determine cancelled

        on player drops ExitSquadControls_Item:
        - determine cancelled


SquadEquipmentChecker:
    type: task
    definitions: squadName|kingdom
    script:
    ## Checks that a given squad has its standard equipment. If not this task will assign as many
    ## soldiers as possible their gear from the barracks' assigned armory.
    ##
    ## squadName : [ElementTag<String>]
    ## kingdom   : [ElementTag<String>]
    ##
    ## >>> [Void]

    # GetSquadInfo and find standard equipment assigned to this squad
    - run GetSquadInfo def.squadName:<[squadName]> def.kingdom:<[kingdom]> save:squadInfo
    - define squadInfo <entry[squadInfo].created_queue.determination.get[1]>
    - define standardEquipment <[squadInfo].deep_get[standardEquipment]>

    # Get SMLocation and find armory locations
    - run GetSquadSMLocation def.squadName:<[squadName]> def.kingdom:<[kingdom]> save:SMLocation
    - define SMLocation <entry[SMLocation].created_queue.determination.get[1]>
    - define filledArmories <[SMLocation].flag[squadManager.armories].filter_tag[<[filter_value].inventory.is_empty.not>]>

    # Loop through all squad soldiers with squad leader coming first to give them priority for
    # equipment
    - foreach <[squadInfo].get[npcList].insert[<[squadInfo].get[squadLeader]>].at[1]> as:soldier:

        # Compare the armor and equipment that the soldier has against the standard equipment
        - define soldierArmor <[soldier].equipment>
        - define standardArmor <[standardEquipment].exclude[hotbar].values>
        - define missingEquipment <list[]>
        - define soldierHotbar <[soldier].inventory.list_contents.get[1].to[9].if_null[<list[]>].sort_by_value[material.name]>
        - define standardHotbar <[standardEquipment].get[hotbar].sort_by_value[material.name]>

        - if <[standardArmor]> != <[soldierArmor]> || <[soldierHotbar]> != <[standardHotbar]>::
            - define missingEquipment <[missingEquipment].include[<[standardArmor].exclude[<[soldierArmor]>]>]>
            - define missingEquipment <[missingEquipment].include[<[standardHotbar].exclude[<[soldierHotbar]>]>]>

        #...Skip soldier if their equipment needs are met
        - if <[missingEquipment].is_empty>:
            - foreach next

        - foreach <[missingEquipment]>:
            - run GiveSoldierItemFromArmory def.soldier:<[soldier]> def.squadName:<[squadName]> def.kingdom:<[kingdom]> def.item:<[value]> def.armories:<[filledArmories]>


DEBUG_ClearSquadEquipment:
    type: task
    definitions: squadName|kingdom
    script:
    - run GetSquadInfo def.squadName:<[squadName]> def.kingdom:<[kingdom]> save:squadInfo
    - define squadInfo <entry[squadInfo].created_queue.determination.get[1]>
    - define npcList <[squadInfo].get[npcList]>

    - foreach <[npcList]> as:soldier:
        - equip <[soldier]> boots:air
        - equip <[soldier]> chest:air
        - equip <[soldier]> legs:air
        - equip <[soldier]> head:air
        - inventory clear d:<[soldier].inventory>


WalkSoldierToSM_Helper:
    type: task
    definitions: npc|location
    script:
    - walk <[npc]> <[location]> auto_range
    - waituntil <[npc].is_navigating.not> rate:1s
    - despawn <[npc]>
