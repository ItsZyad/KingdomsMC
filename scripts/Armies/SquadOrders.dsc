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

        - run OpenSquadControlOptions def.kingdom:<[kingdom]> def.squadName:<[squadName]> def.player:<player> def.fromSM:false


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

        on player clicks AltExitSquadControls_Item in SquadControlOptions_Window:
        - inventory close

        on player clicks ExitSquadControls_Item in SquadControlOptions_Window:
        - run SquadSelectionGUI def.player:<player>
