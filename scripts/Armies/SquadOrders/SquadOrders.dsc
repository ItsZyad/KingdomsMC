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
    display name: <red>Exit Squad Controls


SquadMoveTool_Item:
    type: item
    material: blaze_rod
    display name: <gold><bold>Move Order
    enchantments:
    - sharpness:1
    mechanisms:
        hides: enchants


SquadOptions_Handler:
    type: world
    events:
        on player right clicks block with:MiscOrders_Item flagged:datahold.armies.squadTools:
        - if <player.flag[datahold.armies.squadTools]> != 1:
            - run GiveSquadTools def.player:<player> def.saveInv:false

        - else:
            - repeat 7:
                - inventory slot:<[value]> set origin:air

            - give to:<player.inventory> SquadRecall_Item

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

        - narrate format:callout "Stashing squad at barracks: <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.name].color[red]>..."
        - narrate format:callout "To respawn the squad click on their icon in the squad list option in your SM."

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

        on player clicks block with:ExitSquadControls_Item:
        - flag <player> datahold.squadInfo:!
        - run ResetSquadTools def.player:<player>

        on player places ExitSquadControl_Item:
        - determine cancelled

        on player drops SquadMoveTool_Item:
        - determine cancelled

        on player drops ExitSquadControls_Item:
        - determine cancelled


WalkSoldierToSM_Helper:
    type: task
    definitions: npc|location
    script:
    - walk <[npc]> <[location]> auto_range
    - waituntil <[npc].is_navigating.not> rate:1s
    - despawn <[npc]>