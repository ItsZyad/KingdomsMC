ExitSquadControls_Item:
    type: item
    material: barrier
    display name: <red>Exit Squad Controls


AltExitSquadControls_Item:
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


SquadOrders_Handler:
    type: world
    events:
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

        on player drops SquadMoveTool_Item:
        - determine cancelled

        on player drops ExitSquadControls_Item:
        - determine cancelled
