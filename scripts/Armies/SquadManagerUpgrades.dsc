##
## [ WIP ]
## All scripts related to upgrading the SM will be found here.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2023
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

SquadManagerAOEUpgrade_Item:
    type: item
    material: player_head
    display name: <light_purple><bold>Upgrade AOE
    mechanisms:
        skull_skin: 6c2e2223-8f50-4bc8-8ac2-31d0c991d0ec|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMTE1MjBlYTQzODRlOGM0ODI1ODY1ZWU3ZGNmMTA5MmFmNDQzZjE1MGFhYjE3MDQxODA4YzlkMzFjZDAxZmRmNyJ9fX0=
    flags:
        upgradeType: AOE


SquadManagerUpgrade_Interface:
    type: inventory
    inventory: chest
    gui: true
    title: Squad Manager Upgrades
    slots:
    - [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item]
    - [] [SquadManagerAOEUpgrade_Item] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [barrier] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item]


LevelOneInactive_Item:
    type: item
    material: player_head
    display name: <red><bold>Level 1
    lore:
    - <red><bold>LOCKED
    - <element[                    ].strikethrough.bold.color[red]>
    mechanisms:
        skull_skin: c024d5ba-3692-41c4-b901-04e7d61a1c99|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYTM5Yzg0NmY2NWQ1ZjI3MmE4MzlmZDljMmFlYjExYmRjOGUzZjgyMjlmYmUzNTgzNDg2ZTc4ZjRjMjNjOGI1YiJ9fX0=


LevelTwoInactive_Item:
    type: item
    material: player_head
    display name: <red><bold>Level 2
    lore:
    - <red><bold>LOCKED
    - <element[                    ].strikethrough.bold.color[red]>
    mechanisms:
        skull_skin: 4ae31ef1-df6f-4708-92fe-606308cd660e|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNTQxNWM0ZDBjN2I4MTQxNTAxOTQ5ZjczY2UwYzc4YjJiMWU5OTAyNTUzNzFhN2ZjNzE5OTk2MGM5YjAzN2Q1MSJ9fX0=


LevelThreeInactive_Item:
    type: item
    material: player_head
    display name: <red><bold>Level 3
    lore:
    - <red><bold>LOCKED
    - <element[                    ].strikethrough.bold.color[red]>
    mechanisms:
        skull_skin: 52bde801-c1d6-44c0-bac3-5cfb6decd49a|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNWY4ZDNjOGNiMDk4M2E0ZjU2Y2MyNmE3MWZmY2VkYmQ3YmVjYzUyMTI5MWM3ODM2MWZmMWU5OWRmNDE0NGNiYyJ9fX0=


LevelFourInactive_Item:
    type: item
    material: player_head
    display name: <red><bold>Level 4
    lore:
    - <red><bold>LOCKED
    - <element[                    ].strikethrough.bold.color[red]>
    mechanisms:
        skull_skin: d01d149b-4c64-4669-83fb-998eda89fdb8|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNjEyNzgxMjE2NmUxNDE4NmRlY2YxNzUxOTYwM2IzNTU2OTk0OTlhNTQ1Mzk3Zjg5MzE3OTRmYWQ2ZTllZmQ5MiJ9fX0=


LevelFiveInactive_Item:
    type: item
    material: player_head
    display name: <red><bold>Level 5
    lore:
    - <red><bold>LOCKED
    - <element[                    ].strikethrough.bold.color[red]>
    mechanisms:
        skull_skin: a0089496-62c7-4781-a525-d40d1258b82f|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZmUxMDA4NTkyZTNhZDI0ZDY1ZGZhNGZmNWEzYzgwMGQ3OGEzZGIxMzRjYmQ4ZTllYzNjYmFjMWVhODM5MWI5ZCJ9fX0=


LevelOneActive_Item:
    type: item
    material: player_head
    display name: <dark_green><bold>Level 1
    lore:
    - <green><bold>UNLOCKED
    - <element[                    ].strikethrough.bold.color[green]>
    mechanisms:
        skull_skin: 6a2d0124-d34b-4422-931d-0f923327cf92|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNmQ2NWNlODNmMWFhNWI2ZTg0ZjliMjMzNTk1MTQwZDViNmJlY2ViNjJiNmQwYzY3ZDFhMWQ4MzYyNWZmZCJ9fX0=


LevelTwoActive_Item:
    type: item
    material: player_head
    display name: <dark_green><bold>Level 2
    lore:
    - <green><bold>UNLOCKED
    - <element[                    ].strikethrough.bold.color[green]>
    mechanisms:
        skull_skin: 1bf386e7-3668-4820-a181-cc25bf7be2d8|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZGQ1NGQxZjhmYmY5MWIxZTdmNTVmMWJkYjI1ZTJlMzNiYWY2ZjQ2YWQ4YWZiZTA4ZmZlNzU3ZDMwNzVlMyJ9fX0=


LevelThreeActive_Item:
    type: item
    material: player_head
    display name: <dark_green><bold>Level 3
    lore:
    - <green><bold>UNLOCKED
    - <element[                    ].strikethrough.bold.color[green]>
    mechanisms:
        skull_skin: 50bd85a9-5784-4de2-83b2-029127448536|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMjFlNGVhNTliNTRjYzk5NDE2YmM5ZjYyNDU0OGRkYWMyYTM4ZWVhNmEyZGJmNmU0Y2NkODNjZWM3YWM5NjkifX19


LevelFourActive_Item:
    type: item
    material: player_head
    display name: <dark_green><bold>Level 4
    lore:
    - <green><bold>UNLOCKED
    - <element[                    ].strikethrough.bold.color[green]>
    mechanisms:
        skull_skin: 65e22d4d-a0f4-42a1-919e-51d434337644|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOGI1MjdiMjRiNWQyYmNkYzc1NmY5OTVkMzRlYWU1NzlkNzQxNGIwYTVmMjZjNGZmYTRhNTU4ZWNhZjZiNyJ9fX0=


LevelFiveActive_Item:
    type: item
    material: player_head
    display name: <dark_green><bold>Level 5
    lore:
    - <green><bold>UNLOCKED
    - <element[                    ].strikethrough.bold.color[green]>
    mechanisms:
        skull_skin: 7daa0bbf-0916-4f56-aabe-fbf2bb8a9fc3|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvODRjOGMzNzEwZGEyNTU5YTI5MWFkYzM5NjI5ZTljY2VhMzFjYTlkM2QzNTg2YmZlYTZlNmUwNjEyNGIzYyJ9fX0=


SquadManagerUpgrade_Subwindow:
    type: inventory
    inventory: chest
    gui: true
    title: Upgrade SM AOE
    slots:
    - [] [] [] [] [Info_Item] [] [] [] []
    - [] [] [LevelOneInactive_Item] [LevelTwoInactive_Item] [LevelThreeInactive_Item] [LevelFourInactive_Item] [LevelFiveInactive_Item] [] []
    - [] [] [] [] [] [] [] [] []


SquadManagerUpgrade_Data:
    type: data
    levels:
        AOE:
            0:
                value: 20
                upkeepAdd: 0
            1:
                value: 25
                upkeepAdd: 50
            2:
                value: 30
                upkeepAdd: 50
            3:
                value: 35
                upkeepAdd: 60
            4:
                value: 40
                upkeepAdd: 65
            5:
                value: 45
                upkeepAdd: 75


SquadManagerUpgrade_Handler:
    type: world
    events:
        ## Player Exits Upgrade Window
        on player clicks barrier in SquadManagerUpgrade_Interface:
        - inventory open d:SquadManager_Interface

        ## Player Clicks AOE Upgrade
        on player clicks SquadManagerAOEUpgrade_Item in SquadManagerUpgrade_Interface:
        - inventory open d:SquadManagerUpgrade_Subwindow
        - flag <player> datahold.armies.upgradingSM:<context.item.flag[upgradeType]>

        ## Player Opens Upgrade Subwindow
        on player opens SquadManagerUpgrade_Subwindow:
        - define squadManagerData <player.flag[datahold.armies.squadManagerData]>
        - define squadManagerLocation <player.flag[datahold.armies.squadManagerLocation]>
        - define upgradeType <player.flag[datahold.armies.upgradingSM]>
        - define currentLevel <[squadManagerData].deep_get[levels.AOELevel]>

        - repeat <[currentLevel]> from:20:
            - narrate format:debug <context.inventory.slot[<[value]>]>

        ## Player Closes Subwindow
        on player closes SquadManagerUpgrade_Subwindow:
        - wait 10t

        - if <player.open_inventory> == <player.inventory>:
            - flag <player> datahold.armies.upgradingSM:!

        ## Player Closes Upgrade Window
        on player closes SquadManagerUpgrade_Interface:
        - wait 10t

        - if <player.open_inventory> == <player.inventory>:
            - flag <player> datahold.armies.upgradingSM:!
