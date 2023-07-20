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
        - wait 3t
        - run GiveSquadTools def.player:<player>
        - run ActionBarToggler def.player:<player> def.message:<element[Now Commanding: <player.flag[datahold.squadInfo.displayName].color[red]>]> def.toggleType:true


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
    display name: <red><bold>Attack All Order
    mechanisms:
        potion_effects:
        - [type=INSTANT_HEAL]
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

        - run SquadEquipmentChecker def.squadName:<[squadInfo].get[name]> def.kingdom:<[kingdom]>
        - run ActionBarToggler def.player:<player> def.toggleType:false

        - narrate format:callout "Stashing squad at barracks: <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.name].color[red]>..."
        - narrate format:callout "To respawn the squad click on their icon in the squad list option in your SM."
        - determine cancelled

        ## ATTACK ORDER: ALL
        on player right clicks block with:SquadAttackTool_Item:
        - ratelimit <player> 10t

        - define kingdom <player.flag[kingdom]>
        - define squadInfo <player.flag[datahold.squadInfo]>
        - define squadName <[squadInfo].get[name]>
        - define squadLeader <[squadInfo].get[squadLeader]>
        - define npcList <[squadInfo].get[npcList]>

        # If the squad already has the attackAll order
        - if <[squadLeader].has_flag[soldier.order]> && <[squadLeader].flag[soldier.order]> == attackAll:
            - flag <[squadLeader]> datahold.armies.particles:!
            - flag <[squadLeader]> soldier.order:!

            - run SquadRemoveAllOrders def.kingdom:<[kingdom]> def.squadName:<[squadName]>

        - else:
            - flag <[squadLeader]> datahold.armies.particles
            - flag <[squadLeader]> soldier.order:attackAll

            - run SquadAttackAllOrder def.kingdom:<[kingdom]> def.squadName:<[squadName]>
            - run SoldierParticleGenerator def.npcList:<[npcList]> def.squadLeader:<[squadLeader]> def.orderType:attackAll

        ## REG. MOVE SQUAD
        on player right clicks block with:SquadMoveTool_Item:
        - ratelimit <player> 1s
        - define kingdom <player.flag[kingdom]>
        - define location <player.cursor_on_solid[50]>
        - define squadInfo <player.flag[datahold.squadInfo]>
        - define squadName <[squadInfo].get[name]>
        - define npcList <[squadInfo].get[npcList]>
        - define squadLeader <[squadInfo].get[squadLeader]>
        - define displayName <[squadInfo].get[displayName]>

        - run FormationWalk def.npcList:<[npcList]> def.squadLeader:<[squadLeader]> def.npcsPerRow:3 def.finalLocation:<[location].with_yaw[<player.location.yaw.round_to_precision[5]>]> def.lineLength:6 def.player:<player>

        ## EXITS ORDERS
        on player clicks block with:ExitSquadControls_Item:
        - flag <player> datahold.squadInfo:!
        - run ResetSquadTools def.player:<player>
        - run ActionBarToggler def.player:<player> def.toggleType:false

        - determine cancelled

        on player quits flagged:datahold.armies.squadTools:
        - run ActionBarToggler def.player:<player> def.toggleType:false
        - run ResetSquadTools def.player:<player>

        on player places ExitSquadControl_Item:
        - determine cancelled

        on player drops SquadMoveTool_Item:
        - determine cancelled

        on player drops ExitSquadControls_Item:
        - determine cancelled


SoldierParticleGenerator:
    type: task
    debug: false
    definitions: npcList|squadLeader|orderType
    script:
    ## Applies a particle effect to a list of soldiers which changes depending on the type of order
    ## they are given.
    ##
    ## npcList     : [ListTag<NPCTag>]
    ## squadLeader : [NPCTag]
    ## orderType   : ?[ElementTag<String>]
    ##               Accepted Values: attackAll, attackSome

    - define waitTime 7t
    - definemap orderFormats:
        attackAll: 2|red
        attackSome: 1.5|orange

    - define orderType attackAll if:<[orderType].exists.not.or[<[orderType].is_in[<[orderFormats].keys>]>]>

    - while <[squadLeader].exists> && <[squadLeader].has_flag[datahold.armies.particles]>:
        - foreach <[npcList].include[<[squadLeader]>]> as:soldier:
            - playeffect at:<[soldier].location.up[3]> effect:REDSTONE special_data:<[orderFormats].get[<[orderType]>]> quantity:3 offset:0,0,0

        - wait <[waitTime]>


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


OLD_SquadAttackAllOrder:
    type: task
    definitions: kingdom|squadName
    DEBUG_OldApproach:
    - define squadInfo <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>
    - define npcList <[squadInfo].get[npcList]>
    - define squadLeader <[squadInfo].get[squadLeader]>
    - define unassignedFriendlies <[npcList]>
    # Note: Future configurable
    - define nearbyNPCs <[squadLeader].location.find_npcs_within[40]>
    - define nearbySquads <map[]>

    - if <[nearbyNPCs].if_null[<list[]>].is_empty>:
        - determine cancelled

    - foreach <[nearbyNPCs]> as:npc:
        - if !<[npc].has_flag[soldier.squadName]>:
            - foreach next

        - if <[npc].flag[soldier.kingdom]> == <[squadLeader].flag[soldier.kingdom]>:
            - foreach next

        - if <[npc].flag[soldier.squadName]> == <[squadLeader].flag[soldier.squadName]>:
            - foreach next

        - define nearbySquads.npcs:->:<[npc]>

        - if <[unassignedFriendlies].size> != 0:
            - define nearbySquads.<[npc].id>:->:<[unassignedFriendlies].first>
            - define unassignedFriendlies:<-:<[unassignedFriendlies].first>

    - while (<[unassignedFriendlies].size> != 0 || <queue.flag[iterations]> > 5) && !<[nearbySquads].is_empty>:
        - flag <queue> iterations:<queue.flag[iterations].if_null[0].add[1]>

        - foreach <[nearbySquads]> as:assignments key:npc:
            - narrate format:debug "Assigning Excess Friendly To: <[npc]>"
            - define nearbySquads.<[npc].id>:->:<[unassignedFriendlies].get[<[loop_index]>]>
            - define unassignedFriendlies:<-:<[unassignedFriendlies].get[<[loop_index]>]>

    - if <queue.flag[iterations]> > 5:
        - narrate format:debug "While loop iteration cap exceeded. Killing Queue..."

    - run flagvisualizer def.flag:<[nearbySquads]> def.flagName:nearby

    script:
    - define squadInfo <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>
    - define npcList <[squadInfo].get[npcList]>
    - define squadLeader <[squadInfo].get[squadLeader]>
    - define unassignedFriendlies <[npcList]>
    # Note: Future configurable
    - define nearbyNPCs <[squadLeader].location.find_npcs_within[40].filter_tag[<[filter_value].flag[soldier.squad].equals[<[squadName]>].not>]>
    #- define nearbySquads <[nearbyNPCs].parse_tag[<map[<[parse_value].flag[soldier.squad]>=<[parse_value].flag[soldier.kingdom]>]>].deduplicate>
    - define nearbySquads <map[]>

    - foreach <[nearbyNPCs]> as:npc:
        - if !<[npc].has_flag[soldier]>:
            - foreach next

        - else:
            - define enemySquadName <[npc].flag[soldier.squad]>
            - define enemySquadKingdom <[npc].flag[soldier.kingdom]>
            - define enemySquad <server.flag[kingdoms.<[enemySquadKingdom]>.armies.squads.squadList.<[enemySquadName]>]>
            - define nearbySquads.<[enemySquadName]>:<[enemySquad].get[npcList].include[<[enemySquad].get[squadLeader]>]>

    # - run flagvisualizer def.flag:<[nearbyNPCs]> def.flagName:nearbyNPCs
    - run flagvisualizer def.flag:<[nearbySquads]> def.flagName:nearbySquads

    - define assignedSoldiers <map[]>

    # yes, second for loop that could be combined into previous one, i know.
    # i have deadlines.
    - foreach <[nearbySquads]> as:squad:
        - if <[npcList].size> >= <[squad].size>:
            - narrate "More or equal friendlies!"

            # oh look, another for loop!
            - foreach <[npcList]>:
                - define assignmentIndex <[loop_index].mod[<[squad].size.add[1]>]>
                - define assignmentIndex <[assignmentIndex].add[1]> if:<[loop_index].is[MORE].than[<[squad].size>]>
                - narrate format:debug <[squad].get[<[assignmentIndex]>].id>
                - define assignedSoldiers.<[squad].get[<[assignmentIndex]>].as[npc].id>:->:<[value].id>

        - else:
            - narrate "More enemies!"

    - run flagvisualizer def.flag:<[assignedSoldiers]> def.flagName:assSoldiers
