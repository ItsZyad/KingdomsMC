##
## All scripts related to upgrading the Squad manager will be found here.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2023
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

SquadManagerAOEUpgrade_Item:
    type: item
    material: player_head
    display name: <light_purple><bold>Upgrade AOE
    mechanisms:
        skull_skin: 6c2e2223-8f50-4bc8-8ac2-31d0c991d0ec|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMTE1MjBlYTQzODRlOGM0ODI1ODY1ZWU3ZGNmMTA5MmFmNDQzZjE1MGFhYjE3MDQxODA4YzlkMzFjZDAxZmRmNyJ9fX0=
    flags:
        upgradeType: AOE
        upgradeTitle: <element[Upgrade SM AOE]>


SquadManagerLimitUpgrade_Item:
    type: item
    material: player_head
    display name: <light_purple><bold>Upgrade Squad Limit
    mechanisms:
        skull_skin: 1c1a29a3-769f-4080-b90e-beaf561cddcd|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOWVhMjk5Zjk3NmUyYzE0MmY5MmY4N2NkNWQyYjQ5N2E4MDk4NzM4NDRhZDY4ZTRjMzZiZjA1NWNkMjI0YTlmNSJ9fX0=
    flags:
        upgradeType: SquadAmount
        upgradeTitle: <element[Upgrade Squad Limit]>


SquadManagerSizeUpgrade_Item:
    type: item
    material: player_head
    display name: <light_purple><bold>Upgrade Squad Size
    mechanisms:
        skull_skin: 86324d7a-d1ae-4682-bf77-c1c272fc3523|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNjBiNTVmNzQ2ODFjNjgyODNhMWMxY2U1MWYxYzgzYjUyZTI5NzFjOTFlZTM0ZWZjYjU5OGRmMzk5MGE3ZTcifX19
    flags:
        upgradeType: SquadSize
        upgradeTitle: <element[Upgrade Squad Size]>


SquadManagerUpgrade_Interface:
    type: inventory
    inventory: chest
    gui: true
    title: Squad Manager Upgrades
    slots:
    - [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item]
    - [SquadInfoSeparator_Item] [] [] [SquadManagerAOEUpgrade_Item] [SquadManagerLimitUpgrade_Item] [SquadManagerSizeUpgrade_Item] [] [] [SquadInfoSeparator_Item]
    - [SquadInfoSeparator_Item] [] [] [] [] [] [] [] [SquadInfoSeparator_Item]
    - [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [Back_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item]


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


LevelZeroActive_Item:
    type: item
    material: player_head
    display name: <dark_green><bold>Level 0
    lore:
    - <green><bold>UNLOCKED
    - <element[                    ].strikethrough.bold.color[green]>
    mechanisms:
        skull_skin: 0a13b38e-b819-42db-909e-911a5f564c20|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMjQ1ODFkMzk1NWU5YWNkNTEzZDI4ZGQzMjI1N2FlNTFmZjdmZDZkZjA1YjVmNGI5MjFmMWRlYWU0OWIyMTcyIn19fQ==


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
    slots:
    - [] [] [] [] [LevelZeroActive_Item] [] [] [] []
    - [] [] [LevelOneInactive_Item] [LevelTwoInactive_Item] [LevelThreeInactive_Item] [LevelFourInactive_Item] [LevelFiveInactive_Item] [] []
    - [] [] [] [] [Back_Item] [] [] [] []


SquadManagerUpgrade_Data:
    type: data
    levels:
        AOE:
            0:
                value: 20
                cost: 0
                upkeepAdd: 0
                message:
                - <element[Base maximum AOE size:].color[green]>
                - <aqua><[currentLevelData].get[value]>
            1:
                value: 23
                cost: 1500
                upkeepAdd: 200
                message:
                - <element[Increases maximum AOE size to:].color[green]>
                - <aqua><[currentLevelData].get[value]>
            2:
                value: 25
                cost: 2000
                upkeepAdd: 250
                message:
                - <element[Increases maximum AOE size to:].color[green]>
                - <aqua><[currentLevelData].get[value]>
            3:
                value: 28
                cost: 2500
                upkeepAdd: 320
                message:
                - <element[Increases maximum AOE size to:].color[green]>
                - <aqua><[currentLevelData].get[value]>
            4:
                value: 30
                cost: 3000
                upkeepAdd: 350
                message:
                - <element[Increases maximum AOE size to:].color[green]>
                - <aqua><[currentLevelData].get[value]>
            5:
                value: 33
                cost: 3500
                upkeepAdd: 420
                message:
                - <element[Increases maximum AOE size to:].color[green]>
                - <aqua><[currentLevelData].get[value]>

        SquadAmount:
            0:
                value: 1
                cost: 0
                upkeepAdd: 0
                message:
                - <element[Base SM squad limit:]>
                - <aqua><[currentLevelData].get[value]>
            1:
                value: 2
                cost: 600
                upkeepAdd: 100
                message:
                - <element[Increases this SM's maximum amount].color[green]>
                - <element[of held squads to:].color[green]> <aqua><[currentLevelData].get[value]>
            2:
                value: 3
                cost: 800
                upkeepAdd: 150
                message:
                - <element[Increases this SM's maximum amount].color[green]>
                - <element[of held squads to:].color[green]> <aqua><[currentLevelData].get[value]>
            3:
                value: 4
                cost: 1000
                upkeepAdd: 200
                message:
                - <element[Increases this SM's maximum amount].color[green]>
                - <element[of held squads to:].color[green]> <aqua><[currentLevelData].get[value]>
            4:
                value: 5
                cost: 1200
                upkeepAdd: 250
                message:
                - <element[Increases this SM's maximum amount].color[green]>
                - <element[of held squads to:].color[green]> <aqua><[currentLevelData].get[value]>
            5:
                value: 6
                cost: 1400
                upkeepAdd: 300
                message:
                - <element[Increases this SM's maximum amount].color[green]>
                - <element[of held squads to:].color[green]> <aqua><[currentLevelData].get[value]>

        SquadSize:
            0:
                value: 15
                cost: 0
                upkeepAdd: 0
                message:
                - <element[Base squad size:]>
                - <aqua><[currentLevelData].get[value]>
            1:
                value: 25
                cost: 3500
                upkeepAdd: 500
                message:
                - <element[Increases this SM's maximum squad size to:].color[green]>
                - <aqua><[currentLevelData].get[value]>
            2:
                value: 35
                cost: 4250
                upkeepAdd: 650
                message:
                - <element[Increases this SM's maximum squad size to:].color[green]>
                - <aqua><[currentLevelData].get[value]>
            3:
                value: 50
                cost: 6000
                upkeepAdd: 850
                message:
                - <element[Increases this SM's maximum squad size to:].color[green]>
                - <aqua><[currentLevelData].get[value]>
            4:
                value: 60
                cost: 7000
                upkeepAdd: 1000
                message:
                - <element[Increases this SM's maximum squad size to:].color[green]>
                - <aqua><[currentLevelData].get[value]>
            5:
                value: 75
                cost: 8250
                upkeepAdd: 1200
                message:
                - <element[Increases this SM's maximum squad size to:].color[green]>
                - <aqua><[currentLevelData].get[value]>


SquadManagerUpgrade_Handler:
    type: world
    events:
        ## Player Exits Upgrade Window
        on player clicks Back_Item in SquadManagerUpgrade_Interface:
        - inventory open d:SquadManager_Interface

        ## Player Clicks AOE Upgrade
        on player clicks *Upgrade_Item in SquadManagerUpgrade_Interface:
        - if <context.item.has_flag[upgradetype]>:
            - flag <player> datahold.armies.upgradingSM.type:<context.item.flag[upgradeType]>
            - define upgradeSubwindow <inventory[SquadManagerUpgrade_Subwindow]>

            - adjust def:upgradeSubwindow title:<context.item.flag[upgradeTitle]>
            - inventory open d:<[upgradeSubwindow]>

        ## Setup Upgrade Subwindow
        on player opens SquadManagerUpgrade_Subwindow:
        - define squadManagerData <player.flag[datahold.armies.squadManagerData]>
        - define squadManagerLocation <player.flag[datahold.armies.squadManagerLocation]>
        - define upgradeType <player.flag[datahold.armies.upgradingSM.type]>
        - definemap upgradeTypeToPath:
            AOE: levels.AOELevel
            SquadAmount: levels.squadLimitLevel
            SquadSize: levels.squadSizeLevel

        - flag <player> datahold.armies.upgradingSM.typeToPath:<[upgradeTypeToPath].get[<[upgradeType]>].split[.].get[2]>

        - define currentLevel <[squadManagerData].deep_get[<[upgradeTypeToPath].get[<[upgradeType]>]>]>
        - define levelData <script[SquadManagerUpgrade_Data].data_key[levels.<[upgradeType]>]>
        - define levelZeroItemIndex <context.inventory.find_item[LevelZeroActive_Item]>
        - define currentLevelData <[levelData].get[0]>

        - inventory adjust slot:<[levelZeroItemIndex]> lore:<item[LevelZeroActive_Item].lore.include[<[levelData].deep_get[0.message]>].parsed.unescaped> d:<context.inventory>

        - define currentLevelData:!

        - repeat 5 from:12 as:index:
            - define currentLevelData <[levelData].get[<[index].sub[11]>]>

            - if <[index].sub[12]> < <[currentLevel]>:
                - define inactiveItem <context.inventory.slot[<[index]>].script.name>
                - define activeItem <element[<[inactiveItem].split[Inactive].get[1]>active_item].as[item]>

                - adjust def:activeItem lore:<[activeItem].lore.include[<[levelData].deep_get[<[currentLevel]>.message]>].parsed.unescaped>

                - inventory set slot:<[index]> o:<[activeItem]> d:<context.inventory>

            - else:
                - define message <[currentLevelData].get[message].parse_tag[<[parse_value].parsed.unescaped.strip_color.color[red]>]>
                - define newLore <list[<dark_purple>Costs <element[$<[currentLevelData].get[cost]>].color[red]> upfront|<dark_purple>Costs additional <element[$<[currentLevelData].get[upkeepAdd]>].color[red]> in upkeep].include[<&sp>].include[<[message]>]>

                - inventory flag slot:<[index]> upgradeInfo:<[currentLevelData].include[level=<[index].sub[11]>]> d:<context.inventory>
                - inventory adjust slot:<[index]> lore:<context.inventory.slot[<[index]>].lore.include[<[newLore]>]> d:<context.inventory>

        ## Player Upgrades SM
        on player clicks *Inactive_Item in SquadManagerUpgrade_Subwindow:
        - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
        - define chosenLevel <context.item.flag[upgradeInfo.level]>
        - define currentLevel <[SMLocation].flag[squadManager.levels.AOELevel]>

        - if <[chosenLevel].sub[<[currentLevel]>]> > 1:
            - narrate format:callout "You cannot select that level yet!"
            - determine cancelled

        - define kingdom <player.flag[kingdom]>
        - define kingdomBalance <proc[GetBalance].context[<[kingdom]>]>

        - if <context.item.flag[upgradeInfo.cost]> > <[kingdomBalance]>:
            - narrate format:callout "Your kingdom does not have enough funds to purchase this upgrade!"
            - determine cancelled

        - flag <[SMLocation]> squadManager.levels.<player.flag[datahold.armies.upgradingSM.typeToPath]>:<[chosenLevel]>

        - run SubBalance def.kingdom:<[kingdom]> def.amount:<context.item.flag[upgradeInfo.cost]>
        - run AddUpkeep def.kingdom:<[kingdom]> def.amount:<context.item.flag[upgradeInfo.upkeepAdd]>
        - run WriteArmyDataToKingdom def.kingdom:<[kingdom]> def.SMLocation:<[SMLocation]>

        - define itemName <context.item.script.name>
        - define activeItem <element[<[itemName].split[Inactive].get[1]>active_item].as[item]>
        - define upgradeType <player.flag[datahold.armies.upgradingSM.type]>
        - define currentLevelData <script[SquadManagerUpgrade_Data].data_key[levels.<[upgradeType]>.<[chosenLevel]>]>

        - adjust def:activeItem lore:<[activeItem].lore.include[<[currentLevelData].get[message]>].parsed.unescaped>
        - inventory set slot:<context.slot> o:<[activeItem]> d:<context.inventory>

        - narrate format:callout "Succesfully activated level <[chosenLevel].color[red]>!"

        - flag <player> datahold.armies.upgradingSM:!

        ## Player Exits Subwindow
        on player clicks Back_Item in SquadManagerUpgrade_Subwindow:
        - inventory open d:SquadManagerUpgrade_Interface

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
