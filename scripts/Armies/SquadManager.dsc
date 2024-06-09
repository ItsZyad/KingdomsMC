##
## All items, menus, tasks, and helpers related to creating, managing, and removing squads through
## the squad manager (SM) will be found here.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jun 2023
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

SquadManager_Item:
    type: item
    material: lodestone
    display name: <light_purple><bold>Squad Manager
    lore:
    - Interactive block which manages army squads
    - <&r><bold>Costs $2000 to activate.
    - <&3><bold>Costs $500 to upkeep daily
    enchantments:
    - sharpness:1
    mechanisms:
        hides: enchants
    recipes:
        1:
            type: shaped
            input:
            - material:iron_ingot|material:iron_ingot|material:iron_ingot
            - material:paper|redstone_block|material:paper
            - stone|stone|stone


SquadInfoSeparator_Item:
    type: item
    material: black_stained_glass_pane
    display name: <&r>


SquadManagerInfo_Item:
    type: item
    material: player_head
    display name: <gold><bold>Barracks Info
    mechanisms:
        skull_skin: da4d885d-2505-4f25-bfee-a0de07950191|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDAxYWZlOTczYzU0ODJmZGM3MWU2YWExMDY5ODgzM2M3OWM0MzdmMjEzMDhlYTlhMWEwOTU3NDZlYzI3NGEwZiJ9fX0=


SquadListInfo_Item:
    type: item
    material: player_head
    display name: <gray><bold>Squad List
    lore:
        - The squads currently stationed at these barracks
    mechanisms:
        skull_skin: 95f861ba-b989-4b73-a754-f5228512ec9d|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYTEzZDExNzU0ZGY2ZmE0NjBiNDliZjJkOWUxODdhMmM1OWUwMGNlYzU5YjRkYWJiYjE5ZDNmM2M1NGI2NmI3YSJ9fX0=


SquadManagerUpgradesDark_Item:
    type: item
    material: player_head
    display name: <gray><bold>Squad Manager Upgrades
    mechanisms:
        skull_skin: 853a0c68-0ff8-4c82-acb6-f70613e36b8c|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvM2Y0NmFiYWQ5MjRiMjIzNzJiYzk2NmE2ZDUxN2QyZjFiOGI1N2ZkZDI2MmI0ZTA0ZjQ4MzUyZTY4M2ZmZjkyIn19fQ==


SquadManagerUgradesLight_Item:
    type: item
    material: player_head
    display name: <green><bold>Squad Manager Upgrades
    lore:
        - Upgrades Available
    mechanisms:
        skull_skin: 8ad84923-ef1c-4d63-9cac-1c882ce14547|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNWRhMDI3NDc3MTk3YzZmZDdhZDMzMDE0NTQ2ZGUzOTJiNGE1MWM2MzRlYTY4YzhiN2JjYzAxMzFjODNlM2YifX19


SquadManagerShowAOE_Item:
    type: item
    material: player_head
    display name: <red><bold>Show Squad Manager AOE
    lore:
        - <&r><red>INACTIVE
        - Show the limits of the barracks
        - <italic>(Helpful while building)
    mechanisms:
        skull_skin: 7ee4a2d5-3ac2-48cb-94a1-689f87c836fd|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNmJkMmY5MzQ3NmFiNjlmYWY1YTUxOWViNTgzMmRiODQxYzg1MjY2ZTAwMWRlNWIyNmU0MjdmNDFkOThlNWM3ZSJ9fX0=


SquadManagerShowAOEActive_Item:
    type: item
    material: player_head
    display name: <green><bold>Show Squad Manager AOE
    lore:
        - <&r><green>ACTIVE
        - Show the limits of the barracks
        - <italic>(Helpful while building)
    mechanisms:
        skull_skin: a80e42d6-f307-40b3-ba5e-80602638d4d9|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZTNiMjI4ZjcwYTM1ZDBhYTMyMzUwNDY3ZDllOGMwOWFhZTlhZTBhZTA4NzVmZGM4YzMxMWE4NzZiZTE5MDcxNyJ9fX0=


SquadManagerSetAOE_Item:
    type: item
    material: nether_star
    display name: <light_purple><bold>Set Squad Manager AOE


SquadComposer_Item:
    type: item
    material: player_head
    display name: <blue><bold>Compose a New Squad
    lore:
        - Opens the squad creation window
    mechanisms:
        skull_skin: 99d1db69-a107-4227-b575-cb40c9f37092|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYTVkNzZkOTBiMzc4MDgzZDE0Nzc1NjgwNTA1ZGRiMWU2YzJjNmRjZjRkZGU3ZjliMWY1ODgwOWJlYzZjNjVjOCJ9fX0=


SquadStationingEval_Item:
    type: item
    material: player_head
    display name: <aqua><bold>Revaluate Stationing Capacity
    lore:
        - Each barrack must contain a certain
        - number of beds on its premises to
        - spawn the squads created in it.
        - <italic>(This value will always be a little
        - bit higher than the number of beds)
    mechanisms:
        skull_skin: 06ca0142-cdb9-4a4d-9f3d-1fb220dd2003|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNmZiMjkwYTEzZGY4ODI2N2VhNWY1ZmNmNzk2YjYxNTdmZjY0Y2NlZTVjZDM5ZDQ2OTcyNDU5MWJhYmVlZDFmNiJ9fX0=


RenameBarracks_Item:
    type: item
    material: name_tag
    display name: <&2><bold>Rename Barracks


RelocateSquadManager_Item:
    type: item
    material: player_head
    display name: <aqua><bold>Relocate Squad Manager
    mechanisms:
        skull_skin: 80286a7d-6180-47da-a7a0-fa7c2f1e9ffe|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMzA5ZDY1NTBhOGI4OTZkZTMxMjMxYjNjZDE2MWY0N2IxNGI4NDUzMDM4MGExZDU2NWMzNjhkNzY3YmEwZmE0MiJ9fX0=


SetArmoryLocations_Item:
    type: item
    material: player_head
    display name: <white><bold>Set Armory Locations
    mechanisms:
        skull_skin: 554d6e02-1065-4867-876e-b0fd8b6fe76d|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZWRjMzZjOWNiNTBhNTI3YWE1NTYwN2EwZGY3MTg1YWQyMGFhYmFhOTAzZThkOWFiZmM3ODI2MDcwNTU0MGRlZiJ9fX0=


SeeArmoryLocations_Item:
    type: item
    material: player_head
    display name: <gold><bold>Show Armory Locations
    lore:
        - Note: Armory locations may not show
        - through walls.
    mechanisms:
        skull_skin: 85f60aef-4945-4790-8a6e-853dd6a33617|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZjM3Y2FlNWM1MWViMTU1OGVhODI4ZjU4ZTBkZmY4ZTZiN2IwYjFhMTgzZDczN2VlY2Y3MTQ2NjE3NjEifX19


HideArmoryLocations_Item:
    type: item
    material: player_head
    display name: <gray><bold>Hide Armory Locations
    mechanisms:
        skull_skin: 0f180111-6cc0-4789-8c7c-0dd0871857d3|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNmU5NzNiNTBkMGIyZGE2ZTJhNTFlY2VlYTBkMjJkNjdhNjE3OThlOTc1OGZkZjViOTIzYjJhNTk1YzYxNzYifX19


SquadManager_Interface:
    type: inventory
    inventory: chest
    gui: true
    title: Squad Manager
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [SquadComposer_Item] [] [RenameBarracks_Item] [] [RelocateSquadManager_Item] [] []
    - [] [] [SquadManagerUpgradesDark_Item] [] [SquadManagerSetAOE_Item] [] [SetArmoryLocations_Item] [] []
    - [] [] [] [] [] [] [] [] []
    - [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadManagerInfo_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item]
    - [] [] [SquadListInfo_Item] [] [SeeArmoryLocations_Item] [] [SquadManagerShowAOE_Item] [] []


ArmoryWand_Item:
    type: item
    material: tipped_arrow
    display name: <blue><bold>Armory Selection Wand


SquadManager_Handler:
    type: world
    events:
        ## Crafts SM
        on SquadManager_Item recipe formed:
        - define kingdom <player.flag[kingdom]>
        - define maxAllowedSMs <proc[GetMaxAllowedSMs].context[<[kingdom]>]>
        - define SMCount <proc[GetKingdomSquadManagers].context[<[kingdom]>].size>

        - if <[SMCount]> >= <[maxAllowedSMs]>:
            - narrate format:callout "You have already created the maximum amount of barracks in your kingdom. Consider upgrading existing squad managers, instead!"
            - determine air

        ## Places SM
        on player places SquadManager_Item flagged:!datahold.armies.movingSM:
        - define kingdom <player.flag[kingdom]>

        - if <server.flag[kingdoms.<[kingdom]>.balance]> < 2000:
            - narrate format:callout "Your kingdom does not have sufficient funds to activate this squad manager.<n>You require at least $2000 in your kingdom's bank."
            - determine cancelled

        - define existingBarracks <proc[GetKingdomSquadManagers].context[<[kingdom]>].if_null[<list[]>]>
        - define barrackLocations <[existingBarracks].parse_value_tag[<[parse_value].get[location]>]>
        - define defaultName Barracks-<[existingBarracks].size.if_null[0].add[1]>

        # Closeness check to other SMs
        - foreach <[barrackLocations]> as:loc:
            # Note: future configurable
            - if <context.location.distance[<[loc]>]> < 200:
                - narrate format:callout "Invalid location! This location is too close to another squad manager belonging to your kingdom. Please relocate and try again."
                - determine cancelled

        - definemap squadManagerData:
            name: <[defaultName]>
            kingdom: <[kingdom]>
            id: <context.location.simple.split[,].remove[last].unseparated>
            levels:
                AOELevel: 0
                squadLimitLevel: 1
                squadSizeLevel: 0
                stationCapacity: 0
            AOESize: 20
            # Note: future configurable
            upkeep: 500

        # Generate cuboid consisting of all the kingdom's core claims
        - define coreClaimsCuboid <proc[GetClaimsCuboid].context[<[kingdom]>|core]>

        # Running path:AreaCalculation returns a cuboid of the barracks' area
        - run RecalculateSquadManagerAOE path:AreaCalculation def.AOESize:<[squadManagerData].get[AOESize]> def.SMLocation:<context.location> save:area
        - define barracksArea <entry[area].created_queue.determination.get[1]>

        - define withinOutpost false

        # Check if barracks are contained within outpost cuboids
        - foreach <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].if_null[<list[]>]> key:outpostName as:outpost:
            - define cornerOne <[outpost].get[cornerone].simple.split[,].remove[last].separated_by[,]>
            - define cornerTwo <[outpost].get[cornertwo].simple.split[,].remove[last].separated_by[,]>
            - define outpostCuboid <cuboid[<player.location.world.name>,<[cornerOne]>,<[cornerTwo]>]>

            - if <[barracksArea].is_within[<[outpostCuboid]>]>:
                - define withinOutpost false
                - foreach stop

        - if <[barracksArea].is_within[<[coreClaimsCuboid]>]> || <[withinOutpost]> || <player.is_op>:
            - flag <context.location> squadManager:<[squadManagerData]>
            - define bedCount <proc[CountBedsInSquadManagerArea].context[<context.location>]>

            # Station count equation:
            # s = round(sqrt(b) * b ^ 0.7)
            - define stationCapacity <[bedCount].sqrt.mul[<[bedCount].power[0.7]>].round>

            - flag <context.location> squadManager.levels.stationCapacity:<[stationCapacity]>

            # Running Recalc. task without path generates the barracks area and adds to the main
            # kingdoms flag the corresponding cuboid
            - run RecalculateSquadManagerAOE def.barracksArea:<[barracksArea]> def.SMLocation:<context.location> def.player:<player>

            - if !<server.has_flag[PauseUpkeep]>:
                - run AddUpkeep def.kingdom:<[kingdom]> def.amount:500
                - run SubBalance def.kingdom:<[kingdom]> def.amount:2000

        - else:
            - narrate format:callout "Please ensure that the squad manager is at least 20 blocks within your kingdom's core/outpost claims."
            - narrate format:callout "<italic>Note: Barracks cannot be placed inside your kingdom's castle territory."
            - determine cancelled

        ## Clicks SM
        on player clicks lodestone location_flagged:squadManager:
        - if <context.location.flag[squadManager.kingdom]> != <player.flag[kingdom]>:
            - determine cancelled

        - if <context.click_type.is_in[RIGHT_CLICK_BLOCK]> || <player.is_sneaking>:
            - animate <player> animation:ARM_SWING
            - flag <player> datahold.armies.squadManagerData:<context.location.flag[squadManager]>
            - flag <player> datahold.armies.squadManagerLocation:<context.location>
            - inventory open d:SquadManager_Interface
            - determine cancelled

        on player clicks barrier in SquadManagerUpgrade_Interface:
        - inventory open d:SquadManager_Interface

        on player clicks SquadManagerUpgradesDark_Item in SquadManager_Interface:
        - inventory open d:SquadManagerUpgrade_Interface

        on player clicks SquadManagerUgradesLight_Item in SquadManager_Interface:
        - inventory open d:SquadManagerUpgrade_Interface

        on player clicks SquadComposer_Item in SquadManager_Interface:
        - inventory open d:SquadComposition_Interface

        ## Setup SM Interface
        on player opens SquadManager_Interface:
        - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
        - define barracksInfoSlot <context.inventory.find_item[SquadManagerInfo_Item]>

        - inventory adjust slot:<[barracksInfoSlot]> "lore:<gray>Name: <&r><proc[GetSMName].context[<[SMLocation]>]>|<gray>Squad Limit: <&r><proc[GetSquadLimit].context[<[SMLocation]>]>|<gray>Squad Size Limit: <&r><proc[GetMaxSquadSize].context[<[SMLocation]>]>|<gray>Stationing Capacity: <&r><proc[GetStationingCapacity].context[<[SMLocation]>]>|<gray>Max AOE Size: <&r><proc[GetMaxSMAOESize].context[<[SMLocation]>]>" destination:<context.inventory>

        on player opens SquadManager_Interface flagged:datahold.armies.showAOE:
        - define AOEItemSlot <context.inventory.find_item[SquadManagerShowAOE_Item]>
        - inventory set slot:<[AOEItemSlot]> o:SquadManagerShowAOEActive_Item d:<context.inventory>

        on player opens SquadManager_Interface flagged:datahold.armies.showArmories:
        - define AOEItemSlot <context.inventory.find_item[SeeArmoryLocations_Item]>
        - inventory set slot:<[AOEItemSlot]> o:HideArmoryLocations_Item d:<context.inventory>

        ## Squad Sel.
        on player clicks SquadListInfo_Item in SquadManager_Interface:
        - run SquadSelectionGUI def.player:<player>

        # TODO(Low): Do something about code duplication

        ## Breaks Bed in SM Area
        on player breaks *_bed:
        - define SMLocation <proc[BedSMLocation].context[<player>|<context.location>]>

        - if <[SMLocation].exists> && <[SMLocation].world> == <player.location.world>:
            - define bedCount <proc[CountBedsInSquadManagerArea].context[<[SMLocation]>]>
            - define stationCapacity <[bedCount].sqrt.mul[<[bedCount].power[0.7]>].round>

            - flag <[SMLocation]> squadManager.levels.stationCapacity:<[stationCapacity]>
            - ~run WriteArmyDataToKingdom def.kingdom:<player.flag[kingdom]> def.SMLocation:<[SMLocation]>

        ## Places Bed in SM Area
        on player places *_bed:
        - define SMLocation <proc[BedSMLocation].context[<player>|<context.location>]>

        - if <[SMLocation].exists> && <[SMLocation].world> == <player.location.world>:
            - define bedCount <proc[CountBedsInSquadManagerArea].context[<[SMLocation]>]>
            - define stationCapacity <[bedCount].sqrt.mul[<[bedCount].power[0.7]>].round>

            - flag <[SMLocation]> squadManager.levels.stationCapacity:<[stationCapacity]>
            - ~run WriteArmyDataToKingdom def.kingdom:<player.flag[kingdom]> def.SMLocation:<[SMLocation]>

        ## AOE Show
        on player clicks SquadManagerShowAOE_Item in SquadManager_Interface:
        - determine passively cancelled

        # Runs the AOE show task script and replaces the SM interface button with a different
        # colored button that cancels the AOE effect
        - if !<player.has_flag[datahold.armies.showAOE]>:
            - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
            - flag <player> datahold.armies.showAOE expire:1h
            - run ShowSquadManagerAOE def.area:<proc[GetSMArea].context[<[SMLocation]>]> def.player:<player>
            - inventory set slot:<context.slot> o:SquadManagerShowAOEActive_Item d:<context.inventory>
            - inventory close

        # Fallback in case inventory adjustment command goes fucky.
        - else:
            - flag <player> datahold.armies.showAOE:!

        ## AOE Show Cancel
        on player clicks SquadManagerShowAOEActive_Item in SquadManager_Interface:
        - determine passively cancelled

        - if <player.has_flag[datahold.armies.showAOE]>:
            - flag <player> datahold.armies.showAOE:!
            - inventory set slot:<context.slot> o:SquadManagerShowAOE_Item d:<context.inventory>
            - inventory close

        ## AOE Set
        on player clicks SquadManagerSetAOE_Item in SquadManager_Interface:
        - define SMLocation <player.flag[datahold.armies.SMLocation]>
        - define maxAOESize <proc[GetMaxSMAOESize].context[<[SMLocation]>]>

        - flag <player> noChat.armies.settingAOE:<[maxAOESize]>

        - narrate format:callout "Type in the size of the squad manager's area of effect (or type 'cancel'):"
        - inventory close

        ## AOE Set
        on player chats flagged:noChat.armies.settingAOE:
        - define maxAOESize <player.flag[noChat.armies.settingAOE]>
        - define SMLocation <player.flag[datahold.armies.SMLocation]>

        - if <context.message.is_integer>:
            - if <context.message.is[MORE].than[<[maxAOESize]>]>:
                - narrate format:callout "The maximum AOE size that can be set at this level is: <[maxAOESize]>. Try again or type 'cancel'."
                - determine cancelled

            # Note: Future setter
            - flag <[SMLocation]> squadManager.AOESize:<context.message>
            - flag <player> noChat.armies:!
            - narrate format:callout "Set squad manager AOE to: <white><context.message>"
            - inventory open d:SquadManager_Interface

            - flag <player> datahold.armies.showAOE:!

            - run RecalculateSquadManagerAOE def.AOESize:<context.message> def.SMLocation:<[SMLocation]> def.player:<player>

        - else if <context.message.to_lowercase> == cancel:
            - flag <player> noChat.armies:!
            - inventory open d:SquadManager_Interface
            - narrate format:callout "Cancelled operation."

        - else:
            - narrate format:callout "The AOE value must be a valid number! Try again or type 'cancel'."

        - determine cancelled

        ## Barrack Rename
        on player clicks RenameBarracks_Item in SquadManager_Interface:
        - flag <player> noChat.armies.renamingBarracks
        - narrate format:callout "Type in a new name for these barracks (or type 'cancel'):"
        - inventory close

        ## Barrack Rename
        on player chats flagged:noChat.armies.renamingBarracks:
        - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
        - define existingName <proc[GetSMName].context[<[SMLocation]>]>

        - if <context.message> == <[existingName]>:
            - narrate format:callout "These barracks already have this name. Try again or type 'cancel'."
            - determine cancelled

        - if <context.message.to_lowercase> == cancel:
            - flag <player> noChat.armies:!
            - inventory open d:SquadManager_Interface
            - narrate format:callout "Cancelled operation."
            - determine cancelled

        - flag <[SMLocation]> squadManager.name:<context.message>
        - run WriteArmyDataToKingdom def.SMLocation:<[SMLocation]> def.kingdom:<player.flag[kingdom]>
        - flag <player> noChat.armies:!

        - narrate format:callout "Renamed barracks to: <context.message.color[red]>"
        - inventory open d:SquadManager_Interface

        - determine cancelled

        ## SM Move Click
        on player clicks RelocateSquadManager_Item in SquadManager_Interface:
        - define squadManagerLocation <player.flag[datahold.armies.squadManagerLocation]>
        - define squadManagerData <player.flag[datahold.armies.squadManagerData]>
        - flag <player> datahold.armies.movingSM.data:<[squadManagerData]>
        - flag <player> datahold.armies.movingSM.location:<[squadManagerLocation]>
        - flag <player> datahold.armies.showAOE:!

        - narrate format:callout "Place down this Squad Manager item at the new desired location. Drop it to cancel."

        - inventory close
        - modifyblock <[squadManagerLocation]> air
        - run TempSaveInventory def.player:<player>
        - give to:<player.inventory> SquadManager_Item
        - adjust <player> item_slot:1

        ## SM Place After Move
        on player places SquadManager_Item flagged:datahold.armies.movingSM:
        - define kingdom <player.flag[kingdom]>
        - define squadManagerData <player.flag[datahold.armies.movingSM.data]>
        - define oldSMLocation <player.flag[datahold.armies.movingSM.location]>
        - define newSMLocation <context.location>
        - define existingBarrackID <[oldSMLocation].simple.split[,].remove[last].unseparated>
        - define existingBarracks <proc[GetKingdomSquadManagers].context[<[kingdom]>].exclude[<[existingBarrackID]>]>
        - define barrackLocations <[existingBarracks].parse_value_tag[<[parse_value].get[location]>]>

        - foreach <[barrackLocations]> as:loc:
            # Note: future configurable
            - if <context.location.distance[<[loc]>]> < 200:
                - narrate format:callout "Invalid location! This location is too close to another squad manager belonging to your kingdom. Try another spot..."
                - determine cancelled

        # Get cuboid consisting of all the kingdom's core claims
        - define coreClaimsCuboid <proc[GetClaimsCuboid].context[<[kingdom]>|core]>

        # Running path:AreaCalculation returns a cuboid of the barracks' area
        - run RecalculateSquadManagerAOE path:AreaCalculation def.AOESize:<proc[GetSMAOESize].context[<[oldSMLocation]>]> def.SMLocation:<[newSMLocation]> save:area
        - define barracksArea <entry[area].created_queue.determination.get[1]>

        - if <[barracksArea].is_within[<[coreClaimsCuboid]>]> || <player.is_op>:
            - flag <context.location> squadManager:<[squadManagerData]>
            - define bedCount <proc[CountBedsInSquadManagerArea].context[<[newSMLocation]>]>

            # Station count equation:
            # s = round(sqrt(b) * b ^ 0.7)
            - define stationCapacity <[bedCount].sqrt.mul[<[bedCount].power[0.7]>].round>

            - define newBarrackID <context.location.simple.split[,].remove[last].unseparated>

            # Flag new squad manager location with corrected data + remove old data
            - define squadManagerData.area:<[barracksArea]>
            - define squadManagerData.id:<[newBarrackID]>
            - flag <[newSMLocation]> squadManager:<[squadManagerData]>
            - flag <[oldSMLocation]> squadManager:!

            # Remove old server-level reference to barrack and copy adjusted version over to new key
            - define kingdomsFlagBarrackData <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[existingBarrackID]>]>
            - define kingdomsFlagBarrackData.area:<[barracksArea]>
            - define kingdomsFlagBarrackData.location:<[newSMLocation]>
            - flag server kingdoms.<[kingdom]>.armies.barracks.<[newBarrackID]>:<[kingdomsFlagBarrackData]>
            - flag server kingdoms.<[kingdom]>.armies.barracks.<[existingBarrackID]>:!

            # Update datahold flags so that if the player interacts with the SM without re-opening
            # it, the references aren't all wrong
            - flag <player> datahold.armies.movingSM.data:!
            - flag <player> datahold.armies.movingSM.location:!
            - flag <player> datahold.armies.squadManagerLocation:<[newSMLocation]>
            - flag <player> datahold.armies.squadManagerData:<[squadManagerData]>

            # Running Recalc. task without path generates the barracks area and adds to the main
            # kingdoms flag the corresponding cuboid
            - run RecalculateSquadManagerAOE def.barracksArea:<[barracksArea]> def.SMLocation:<[newSMLocation]> def.player:<player>

            - run LoadTempInventory def.player:<player>

        - else:
            - narrate format:callout "Please ensure that the squad manager is at least 20 blocks within your kingdom's core/outpost claims."
            - narrate format:callout "<italic>Note: Barracks cannot be placed inside your kingdom's castle territory."
            - determine cancelled

        ## Player Drops SM While Moving
        on player drops SquadManager_Item flagged:datahold.armies.movingSM:
        - determine passively cancelled

        - define SMLocation <player.flag[datahold.armies.movingSM.location]>

        - take from:<player.inventory>
        - run LoadTempInventory def.player:<player>
        - modifyblock <[SMLocation]> Lodestone

        ## Player Clicks Armory Set
        on player clicks SetArmoryLocations_Item in SquadManager_Interface:
        - inventory close

        - flag <player> datahold.armies.keepCache

        - narrate format:callout "Use the armory wand to designate chests, barrels, and other storage items as armories. Your squads will use these to get weapons and ammunition."
        - narrate format:callout "<bold>Drop the armory wand when finished."

        - run TempSaveInventory def.player:<player>
        - give to:<player.inventory> ArmoryWand_Item
        - adjust <player> item_slot:1

        ## Player Selects Armory
        on player right clicks block with:ArmoryWand_Item:
        - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>

        - if <context.location.has_inventory>:
            - if <[SMLocation].flag[squadManager.armories].contains[<context.location>]>:
                - flag <[SMLocation]> squadManager.armories:<-:<context.location>
                - determine cancelled

            - flag <[SMLocation]> squadManager.armories:->:<context.location>
            - narrate format:callout "Designated <context.location.simple.split[,].remove[last].comma_separated.color[red].bold> as an armory <context.location.material.name>"

        - determine cancelled

        ## Drops Armory Wand
        on player drops ArmoryWand_Item:
        - determine passively cancelled
        - wait 1t
        - take from:<player.inventory> item:ArmoryWand_Item
        - run LoadTempInventory def.player:<player>

        - flag <player> datahold.armies.keepCache:!
        - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
        - run WriteArmyDataToKingdom def.SMLocation:<[SMLocation]> def.kingdom:<player.flag[kingdom]>

        ## Clicks Armory Wand In Inv.
        on player clicks ArmoryWand_Item in inventory:
        - determine passively cancelled
        - wait 3t
        - narrate format:callout "You are not allowed to move this item in your inventory."

        - take from:<player.inventory> item:ArmoryWand_Item
        - adjust <player> item_on_cursor:<item[air]>
        - flag <player> datahold.armies.keepCache:!

        - run LoadTempInventory def.player:<player>
        - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
        - run WriteArmyDataToKingdom def.SMLocation:<[SMLocation]> def.kingdom:<player.flag[kingdom]>

        ## Player Clicks Armories AOE
        on player clicks SeeArmoryLocations_Item in SquadManager_Interface:
        - determine passively cancelled

        - if <player.has_flag[datahold.armies.showArmories]>:
            - flag <player> datahold.armies.showArmories:!

        - else:
            - define squadManagerData <player.flag[datahold.armies.squadManagerData]>

            - if !<[squadManagerData].contains[armories]>:
                - narrate format:callout "You have not set any armories for these barracks yet!"
                - determine cancelled

            - flag <player> datahold.armies.showArmories expire:1h
            - run ShowArmoriesAOE def.player:<player> def.locationList:<[squadManagerData].get[armories]>
            - inventory set slot:<context.slot> o:HideArmoryLocations_Item d:<context.inventory>
            - inventory close

        ## Player Cancels Armories AOE
        on player clicks HideArmoryLocations_Item in SquadManager_Interface:
        - determine passively cancelled

        - if <player.has_flag[datahold.armies.showArmories]>:
            - flag <player> datahold.armies.showArmories:!
            - inventory set slot:<context.slot> o:SeeArmoryLocations_Item d:<context.inventory>

        ## Close Window
        on player closes SquadManager_Interface flagged:datahold.armies.squadManagerData:
        - wait 10t
        - if <player.has_flag[noChat.armies]>:
            - stop

        - if <player.has_flag[datahold.armies.keepCache]>:
            - stop

        - if <player.open_inventory> == <player.inventory>:
            - flag <player> datahold.armies.squadManagerData:!
            - flag <player> datahold.armies.squadManagerLocation:!

        ## Leave Game
        on player quits flagged:datahold.armies:
        - flag <player> datahold.armies:!
        - flag <player> noChat.armies:!

        ## Player Breaks SM
        on player breaks lodestone location_flagged:squadManager:
        - define kingdom <player.flag[kingdom]>
        - define SMInfo <context.location.flag[squadManager]>
        - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>

        - if <[kingdom]> != <proc[GetSMKingdom].context[<[SMLocation]>]>:
            - determine cancelled

        - define SMID <context.location.proc[GenerateSMID]>
        - define squadList <proc[GetSMSquads].context[<[SMLocation]>].keys>
        - define barrackList <proc[GetKingdomSquadManagers].context[<[kingdom]>]>

        - flag <player> datahold.armies.showAOE:!
        - flag <player> datahold.armies.squadManagerLocation:<context.location>

        - if <[barrackList].size> == 1:
            - flag <player> datahold.armies.SMDelete.squadList:<[squadList]> if:<[squadList].is_empty.not>

            - clickable for:<player> usages:1 until:10m save:YesDelete:
                - inventory open d:SquadManagerDeletionConfirmation_Window

            - clickable for:<player> usages:1 until:10m save:NoDelete:
                - narrate format:callout "Cancelled deletion process."
                - clickable cancel:<entry[YesDelete].id>

            - narrate format:callout "<red><element[WARNING!].bold> Deleting this squad manager will result in some of its squads being deleted!"
            - narrate format:callout "<red>Please ensure that you make space or upgrade other SMs, or transfer all squads manually!"
            - narrate format:callout "<red>Are you sure you want to delete this squad manager?<n><n><element[Yes].color[green].bold.on_click[<entry[YesDelete].command>]> / <element[No].color[gray].bold.on_click[<entry[NoDelete].command>]>"

            - determine cancelled

        - define movableSquads <list[]>

        - foreach <[barrackList].filter_tag[<[filter_value].get[name].equals[<[SMInfo].get[name]>].not>]> as:barrack:
            - define barrackLocation <[barrack].get[location]>
            - define barrackSquadLimit <proc[GetSquadLimit].context[<[barrackLocation]>]>
            - define barrackStationingCap <proc[GetStationingCapacity].context[<[barrackLocation]>]>

            - foreach <[squadList].exclude[<[movableSquads].parse_value_tag[<[parse_key]>]>]> as:squadName:
                - define passedConditions 0
                - define squad <proc[GetSMSquads].context[<[SMLocation]>].get[<[squadName]>]>

                - if <[squad].get[npcList].size> <= <[barrackStationingCap]>:
                    - define passedConditions:++

                - if <[barrack].deep_get[squads.squadList].size.if_null[0]> < <[barrackSquadLimit]>:
                    - define passedConditions:++

                - if <[passedConditions]> == 2:
                    - define movableSquads.<[squadName]>.kingdom:<[barrack].get[kingdom]>
                    - define movableSquads.<[squadName]>.barrackID:<[barrack].get[id]>

        - flag <player> datahold.armies.SMDelete.squadList:<[squadList]>
        - flag <player> datahold.armies.SMDelete.movableSquads:<[movableSquads]>
        - flag <player> datahold.armies.SMDelete.SMID:<[SMID]>

        - narrate format:callout "<red><element[WARNING!].bold> Deleting this squad manager will result in some of its squads being deleted!"
        - narrate format:callout "<red>Please ensure that you make space or upgrade other SMs, or transfer all squads manually!"

        - inventory open d:SquadManagerDeletionConfirmation_Window
        - determine cancelled


ConfirmSMDeletion_Item:
    type: item
    material: player_head
    display name: <green><bold>Confirm Deletion
    mechanisms:
        skull_skin: afb405c1-16ea-4a23-883f-97867e7db3f9|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYTc5YTVjOTVlZTE3YWJmZWY0NWM4ZGMyMjQxODk5NjQ5NDRkNTYwZjE5YTQ0ZjE5ZjhhNDZhZWYzZmVlNDc1NiJ9fX0=


RejectSMDeletion_Item:
    type: item
    material: player_head
    display name: <red><bold>Reject Deletion
    mechanisms:
        skull_skin: 5ecfabf0-5253-47b0-a44d-9a0c924081b9|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYmViNTg4YjIxYTZmOThhZDFmZjRlMDg1YzU1MmRjYjA1MGVmYzljYWI0MjdmNDYwNDhmMThmYzgwMzQ3NWY3In19fQ==


SMDeletionHeader_Item:
    type: item
    material: player_head
    display name: <gold><bold>Confirm Squad Manager Deletion?
    mechanisms:
        skull_skin: da4d885d-2505-4f25-bfee-a0de07950191|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDAxYWZlOTczYzU0ODJmZGM3MWU2YWExMDY5ODgzM2M3OWM0MzdmMjEzMDhlYTlhMWEwOTU3NDZlYzI3NGEwZiJ9fX0=


SquadManagerDeletionConfirmation_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Re-Confirm SM Deletion
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [ConfirmSMDeletion_Item] [] [] [] [RejectSMDeletion_Item] [] []
    - [] [] [] [] [SMDeletionHeader_Item] [] [] [] []
    - [] [] [] [] [] [] [] [] []


SquadManagerDeletion_Handler:
    type: world
    events:
        on player opens SquadManagerDeletionConfirmation_Window:
        - define deletionInfo <player.flag[datahold.armies.SMDelete]>

        - if !<[deletionInfo].get[squadList].is_empty>:
            - define movableSquads <[deletionInfo].get[movableSquads].keys.if_null[<list[]>]>
            - define deletedSquads <[deletionInfo].get[squadList].exclude[<[movableSquads].keys>].if_null[<list[]>]>

            - define loreList <list[<element[Following squads will be moved:].color[aqua]>].include[<[movableSquads]>]>
            - define loreList <list[<element[Following squads will be moved:].color[aqua]>].include[None]> if:<[movableSquads].is_empty>

            - define loreList <[loreList].include[<element[Following squads will be deleted:].color[aqua]>].include[<[deletedSquads].parse_tag[<white>- <[parse_value]>]>]> if:<[deletedSquads].is_empty.not>
            - define loreList <[loreList].include[<element[Following squads will be deleted:].color[aqua]>].include[None]> if:<[deletedSquads].is_empty>

            - define infoItemSlot <context.inventory.find_item[SMDeletionHeader_Item]>

            - inventory adjust slot:<[infoItemSlot]> lore:<[loreList]> d:<context.inventory>

        on player clicks ConfirmSMDeletion_Item in SquadManagerDeletionConfirmation_Window:
        - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
        - define deletionInfo <player.flag[datahold.armies.SMDelete]>

        - if !<[deletionInfo].get[squadList].is_empty>:
            - define movableSquads <list[]>

            - if <[movableSquads].exists>:
                - define movableSquads <[deletionInfo].get[movableSquads]>

                - foreach <[movableSquads]> key:squad:
                    - define kingdom <[value].get[kingdom]>
                    - define barrackID <[value].get[barrackID]>
                    - define newSMLocation <proc[GetSMLocation].context[<[barrackID]>|<[kingdom]>]>

                    - run GetSquadInfo def.kingdom:<player.flag[kingdom]> def.squadName:<[squad]> save:squadInfo
                    - define squadInfo <entry[squadInfo].created_queue.determination.get[1]>

                    - flag <[newSMLocation]> squadManager.squads.squadList.<[squad]>:<[squadInfo]>

                    - run WriteArmyDataToKingdom def.kingdom:<[kingdom]> def.SMLocation:<[newSMLocation]>

            - narrate "<gold>Moved the following squads: <n><[movableSquads].keys.parse_tag[<white>- <[parse_value]>].separated_by[<n>]>" if:<[movableSquads].is_empty.not>

            - define deletedSquads <[deletionInfo].get[squadList].exclude[<[movableSquads].keys>].if_null[<list[]>]>

            - if <[deletedSquads].size.is[MORE].than[0]>:
                - narrate "<gold>Deleted the following squads: <n><[deletedSquads].parse_tag[<white>- <[parse_value]>].separated_by[<n>]>" if:<[deletedSquads].is_empty.not>

        - run SubUpkeep def.kingdom:<player.flag[kingdom]> def.amount:<[SMLocation].flag[squadManager.upkeep]>

        # TODO: Find a way to determine the value of an SM and return a suitable fraction of that
        # TODO/ value to the kingdom balance as a refund.
        - run AddBalance def.kingdom:<player.flag[kingdom]> def.amount:1000

        - flag server kingdoms.<player.flag[kingdom]>.armies.barracks.<[SMLocation].flag[squadManager.id]>:!
        - flag <[SMLocation]> squadManager:!
        - modifyblock <[SMLocation]> air source:<player>
        - drop SquadManager_Item location:<[SMLocation]> quantity:1


RecalculateSquadManagerAOE:
    type: task
    debug: false
    definitions: AOESize[ElementTag(Integer)]|SMLocation[LocationTag]|player[PlayerTag]|barracksArea[CuboidTag]
    description:
    - Generates the cuboid object representing the SM's area
    - ---
    - → [CuboidTag]

    AreaCalculation:
    ## Generates the cuboid object representing the SM's area
    ##
    ## AOESize      : [ElementTag<Integer>]
    ## SMLocation   : [LocationTag]
    ##
    ## >>> [CuboidTag]

    - define AOEHalf <[AOESize].div[2].round_up>
    - define topCorner <[SMLocation].add[<[AOEHalf]>,<[AOEHalf]>,<[AOEHalf]>]>
    - define bottomCorner <[SMLocation].sub[<[AOEHalf]>,<[AOEHalf]>,<[AOEHalf]>]>
    - define barracksArea <cuboid[<[topCorner].world.name>,<[topCorner].xyz>,<[bottomCorner].xyz>]>

    - determine <[barracksArea]>

    script:
    ## Based on the provided AOESize definition, this task resizes the area of effect of a given SM
    ## identified by its location.
    ##
    ## AOESize      : [ElementTag<Integer>]
    ## SMLocation   : [LocationTag]
    ## player       : [PlayerTag]
    ## barracksArea : [CuboidTag]
    ##
    ## >>> [Void]

    - if !<[barracksArea].exists>:
        - run <script.name> path:AreaCalculation def.AOESize:<[AOESize]> def.SMLocation:<[SMLocation]> save:area
        - define barracksArea <entry[area].created_queue.determination.get[1]>

    - flag <[SMLocation]> squadManager.area:<[barracksArea]>
    - ~run WriteArmyDataToKingdom def.kingdom:<[player].flag[kingdom]> def.SMLocation:<[SMLocation]>
    - run ShowSquadManagerAOE def.area:<[barracksArea]> def.player:<[player]>


CalculateSMCost:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Calculates the amount of funds needed to activate an SM
    - ---
    - → [ElementTag(Float)]

    script:
    ## Calculates the amount of funds needed to activate an SM
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    # TODO: Temp calculation-- make sure you come back to this later and factor in prestige!
    - define maxAllowedSMs <server.flag[kingdoms.<[kingdom]>.armies.maximumAllowedSMs].if_null[4]>
    - define SMCount <proc[GetKingdomSquadManagers].context[<[kingdom]>].size>
    - determine <element[2000].mul[<[maxAllowedSMs].mul[<[SMCount].sqrt>]>]>


BedSMLocation:
    type: procedure
    definitions: player[PlayerTag]|bedLocation[LocationTag]
    description:
    - Returns the cuboid area that contains the provided location, if any.
    - ---
    - → [?LocationTag]

    script:
    ## Returns the cuboid area that contains the provided location, if any.
    ##
    ## bedLocation : [LocationTag]
    ## player      : [PlayerTag]
    ##
    ## >>> [?LocationTag]

    - define kingdom <[player].flag[kingdom]>
    - define barracks <proc[GetKingdomSquadManagers].context[<[kingdom]>]>

    - if !<[barracks].exists>:
        - determine cancelled

    - foreach <[barracks].keys>:
        - define barrackLocation <proc[GetSMLocation].context[<[value]>|<[kingdom]>]>

        - if <proc[GetSMArea].context[<[barrackLocation]>].contains[<[bedLocation]>]>:
            - determine <[barrackLocation]>


CountBedsInSquadManagerArea:
    type: procedure
    debug: false
    definitions: location[LocationTag]
    description:
    - Counts the number of beds contained within the area of a squadManager. the SM is identified by its location, passed in by definition.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Counts the number of beds contained within the area of a squadManager. the SM is identified
    ## by its location, passed in by definition.
    ##
    ## location : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - define SMArea <proc[GetSMArea].context[<[location]>]>
    - define bedCount <[SMArea].blocks[*_bed].size.div[2]>
    - determine <[bedCount]>


ShowArmoriesAOE:
    type: task
    debug: false
    definitions: locationList[ListTag(LocationTag)]|player[PlayerTag]
    description:
    - Displays to the given player a set of glimmering particles indicating at the given list of locations.
    - ---
    - → [Void]

    script:
    ## Displays to the given player a set of glimmering particles indicating at the given list of
    ## locations.
    ##
    ## locationList : [ListTag<LocationTag>]
    ## player       : [PlayerTag]
    ##
    ## >>> [Void]

    - if <[locationList].filter_tag[<[filter_value].object_type.to_lowercase.equals[location]>].size> != <[locationList].size>:
        - determine cancelled

    - while <[player].has_flag[datahold.armies.showArmories]>:
        - foreach <list[0.5|-0.5]> as:offset:
            - playeffect at:<[locationList].parse_tag[<[parse_value].center.up[0.5].forward[<[offset]>].left[<[offset]>]>]> effect:WAX_OFF offset:0,0,0 quantity:1 targets:<[player]>
            - playeffect at:<[locationList].parse_tag[<[parse_value].center.up[0.5].backward[<[offset]>].left[<[offset]>]>]> effect:WAX_OFF offset:0,0,0 quantity:1 targets:<[player]>
            - playeffect at:<[locationList].parse_tag[<[parse_value].center.down[0.5].forward[<[offset]>].left[<[offset]>]>]> effect:WAX_OFF offset:0,0,0 quantity:1 targets:<[player]>
            - playeffect at:<[locationList].parse_tag[<[parse_value].center.down[0.5].backward[<[offset]>].left[<[offset]>]>]> effect:WAX_OFF offset:0,0,0 quantity:1 targets:<[player]>

        - wait 6t


ShowSquadManagerAOE:
    type: task
    debug: false
    definitions: area[CuboidTag]|player[PlayerTag]
    description:
    - Displays to the given player a box-shaped outline of the given area.
    - ---
    - → [Void]

    script:
    ## Displays to the given player a box-shaped outline of the given area.
    ##
    ## area   : [CuboidTag]
    ## player : [PlayerTag]
    ##
    ## >>> [Void]

    - define waitTime 3t
    - define effect CLOUD
    - define location <[area].outline.parse_tag[<[parse_value].center>]>

    - while <[player].has_flag[datahold.armies.showAOE]>:
        - playeffect at:<[location]> effect:<[effect]> quantity:1 targets:<[player]> offset:0,0,0
        - wait <[waitTime]>
        - playeffect at:<[location]> effect:<[effect]> quantity:1 targets:<[player]> offset:0,0,0
        - wait <[waitTime]>
        - playeffect at:<[location]> effect:<[effect]> quantity:1 targets:<[player]> offset:0,0,0
        - wait <[waitTime]>
        - playeffect at:<[location]> effect:<[effect]> quantity:1 targets:<[player]> offset:0,0,0
        - wait <[waitTime]>
        - playeffect at:<[location]> effect:<[effect]> quantity:1 targets:<[player]> offset:0,0,0
        - wait <[waitTime]>
        - playeffect at:<[location]> effect:<[effect]> quantity:1 targets:<[player]> offset:0,0,0
        - wait <[waitTime]>
