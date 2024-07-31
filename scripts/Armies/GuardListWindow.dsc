##
## This file contains all the scripts needed to show the window which displays all the kingdom's
## currently active guards.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Dec 2023
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------


KingdomGuardList_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Kingdom Guards
    procedural items:
    - determine <player.flag[kingdomGuardItems]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [Page_Back] [] [Page_Forward] [] [] []


KingdomGuardRespawn_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Respawn Guard?
    slots:
    - [] [] [] [] [GuardRespawn_Item] [] [] [] []


GuardList_Item:
    type: item
    material: player_head
    display name: <gray><bold>Unknown Guard


GuardRespawn_Item:
    type: item
    material: respawn_anchor
    display name: Respawn Guard
    lore:
    - Cost: <element[$100].color[red].bold>
    flags:
        cost: 100


KingdomGuardList_Handler:
    type: world
    events:
        on player clicks Page_Back in KingdomGuardList_Window:
        - if <player.flag[guardListPage].is[MORE].than[1]>:
            - flag <player> guardListPage:--

        on player clicks Page_Forward in KingdomGuardList_Window:
        - flag <player> guardListPage:++

        on player closes KingdomGuardList_Window:
        - flag <player> guardListPage:!
        - flag <player> kingdomGuardItems:!

        on player clicks GuardList_Item in KingdomGuardList_Window:
        - define guard <context.item.flag[referencedGuard]>

        - if <[guard].exists> && <[guard].is_spawned>:
            - inventory open d:Guard_Window

        - else:
            - inventory open d:KingdomGuardRespawn_Window

        - flag <player> clickedNPC:<[guard]>

        on player clicks GuardRespawn_Item in KingdomGuardRespawn_Window:
        - define kingdom <player.flag[kingdom]>
        - define kingdomBalance <server.flag[kingdoms.<[kingdom]>.balance]>
        - define respawnCost <context.item.flag[cost]>

        - if <[kingdomBalance]> >= <[respawnCost]>:
            - flag server kingdoms.<[kingdom]>.balance:-:<[respawnCost]>
            - ~run SidebarLoader def:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>
            - narrate format:callout "Respawned castle guard at their previously defined anchor position!"

        - else:
            - narrate format:callout "Your kingdom does not have enough funds in its treasury to replace this guard!"

        - inventory close
