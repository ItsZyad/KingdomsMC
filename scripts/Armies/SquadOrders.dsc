SoldierManager_Assignment:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true

        on click:
        - if !<npc.has_flag[soldier]>:
            - determine cancelled

        - if <player.has_flag[datahold.squadInfo]>:
            - determine cancelled

        - define kingdom <npc.flag[soldier.kingdom]>
        - define squadName <npc.flag[soldier.squad]>
        - flag <player> datahold.squadInfo:<server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>

        - inventory open d:SquadControlOptions_Window


# Note: Items referenced here are in SquadMove.dsc file
SquadControlOptions_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Squad Controls
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [SquadMoveTool_Item] [] [] [] [] [] [] []
    - [] [] [] [] [ExitSquadControls_Item] [] [] [] []


SquadOptions_Handler:
    type: world
    events:
        on player clicks SquadMoveTool_Item in SquadControlOptions_Window:
        - inventory close
        - run GiveSquadTools def.player:<player>

        on player clicks ExitSquadControls_Item in SquadControlOptions_Window:
        - run SquadSelectionGUI def.player:<player>
