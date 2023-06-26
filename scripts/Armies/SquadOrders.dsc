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

        - if <player.flag[kingdom]> != <[kingdom]>:
            - determine cancelled

        - run OpenSquadControlOptions def.kingdom:<[kingdom]> def.squadName:<[squadName]> def.player:<player> def.fromSM:false


SquadRecall_Item:
    type: item
    material: player_head
    display name: <white><bold>Recall to Base
    mechanisms:
        skull_skin: bd2c2584-f53e-4829-81a3-5cff044e4979|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOGFhMTg3ZmVkZTg4ZGUwMDJjYmQ5MzA1NzVlYjdiYTQ4ZDNiMWEwNmQ5NjFiZGM1MzU4MDA3NTBhZjc2NDkyNiJ9fX0=


# Note: Items referenced here are in SquadMove.dsc file
SquadControlOptions_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Squad Controls
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [SquadMoveTool_Item] [] [] [] [] [] [SquadRecall_Item] []
    - [] [] [] [] [ExitSquadControls_Item] [] [] [] []


SquadOptions_Handler:
    type: world
    events:
        on player clicks SquadMoveTool_Item in SquadControlOptions_Window:
        - inventory close
        - run GiveSquadTools def.player:<player>

        ## RECALL SQUAD
        on player clicks SquadRecall_Item in SquadControlOptions_Window:
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

        - inventory close

        - define SMLocation <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.location]>
        - inject SpawnSquadNPCs path:FindSpacesAroundSM

        - foreach <[npcList]> as:npc:
            - run WalkSoldierToSM_Helper def.npc:<[npc]> def.location:<[spawnLocation]>

        - narrate format:callout "Stashing squad at barracks: <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.name].color[red]>..."
        - narrate format:callout "To respawn squad click on their icon in the squad list option in your SM."

        on player clicks AltExitSquadControls_Item in SquadControlOptions_Window:
        - inventory close

        on player clicks ExitSquadControls_Item in SquadControlOptions_Window:
        - run SquadSelectionGUI def.player:<player>


WalkSoldierToSM_Helper:
    type: task
    definitions: npc|location
    script:
    - walk <[npc]> <[location]> auto_range
    - waituntil <[npc].is_navigating.not> rate:1s
    - despawn <[npc]>