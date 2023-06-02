SquadManager_Item:
    type: item
    material: lodestone
    display name: <light_purple><bold>Squad Manager
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
    material: red_stained_glass
    display name: <red><bold>Show Squad Manager AOE
    lore:
        - <&r><red>INACTIVE
        - Show the limits of the barracks
        - <italic>(Helpful while building)


SquadManagerShowAOEActive_Item:
    type: item
    material: green_stained_glass
    display name: <green><bold>Show Squad Manager AOE
    lore:
        - <&r><green>ACTIVE
        - Show the limits of the barracks
        - <italic>(Helpful while building)


SquadManagerSetAOE_Item:
    type: item
    material: purple_stained_glass
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


SquadManager_Interface:
    type: inventory
    inventory: chest
    gui: true
    title: Squad Manager
    slots:
    - [] [] [SquadComposer_Item] [] [RenameBarracks_Item] [] [] [] []
    - [] [] [SquadStationingEval_Item] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadManagerInfo_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item]
    - [] [] [SquadListInfo_Item] [] [SquadManagerUpgradesDark_Item] [] [] [] []
    - [] [] [SquadManagerShowAOE_Item] [] [] [] [SquadManagerSetAOE_Item] [] []


SquadManagerUpgrade_Interface:
    type: inventory
    inventory: chest
    gui: true
    title: Squad Manager Upgrades
    slots:
    - [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item]
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [barrier] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item] [SquadInfoSeparator_Item]


# Later: Move to unified config file
SquadManagerLevelData:
    type: data
    levelData:
        AOELevel:
            1: 20
            2: 40
            3: 80


SquadManager_Handler:
    type: world
    events:
        on player places SquadManager_Item:
        - define kingdom <player.flag[kingdom]>
        - define existingBarracks <server.flag[kingdoms.<[kingdom]>.armies.barracks]>
        - define barrackLocations <[existingBarracks].parse_value_tag[<[parse_value].get[location]>]>
        - define numberOfExistingBarracks <[existingBarracks].size.if_null[0]>
        - define defaultName Barracks-<[numberOfExistingBarracks].add[1]>

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
                AOELevel: 1
                squadLimit: 1
                squadSizeLimit: 30
            AOESize: 40

        # Generate cuboid consisting of all the kingdom's core claims
        - define coreClaims <server.flag[kingdoms.<[kingdom]>.claims.core]>
        - define coreClaimsCuboid <[coreClaims].get[1].cuboid>

        - foreach <[coreClaimsCuboid].remove[1]>:
            - define coreClaimsCuboid <[coreClaimsCuboid].include[<[value]>]>

        # Running path:AreaCalculation returns a cuboid of the barracks' area
        - run RecalculateSquadManagerAOE path:AreaCalculation def.AOESize:<[squadManagerData].get[AOESize]> def.SMLocation:<context.location> save:area
        - define barracksArea <entry[area].created_queue.determination.get[1]>

        - if <[barracksArea].is_within[<[coreClaimsCuboid]>]> || <player.is_op>:
            - flag <context.location> squadManager:<[squadManagerData]>
            - define squadManagerLocation <player.flag[datahold.armies.squadManagerLocation]>
            - define bedCount <proc[CountBedsInSquadManagerArea].context[<[squadManagerLocation]>]>

            # Station count equation:
            # s = round(sqrt(b) * b ^ 0.7)
            - define stationCapacity <[bedCount].sqrt.mul[<[bedCount].power[0.7]>].round>

            - flag <[squadManagerLocation]> squadManager.levels.stationCapacity:<[stationCapacity]>

            # Running Recalc. task without path generates the barracks area and adds to the main
            # kingdoms flag the corresponding cuboid
            - run RecalculateSquadManagerAOE def.barracksArea:<[barracksArea]> def.SMLocation:<context.location> def.player:<player>

        - else:
            - narrate format:callout "Please ensure that the squad manager is at least 20 blocks within your kingdom's core claims."
            - narrate format:callout "<italic>Note: Barracks cannot be placed inside your kingdom's castle territory."
            - determine cancelled

        on player breaks lodestone location_flagged:squadManager:
        - flag <context.location> squadManager:!

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

        on player opens SquadManager_Interface:
        - define squadManagerData <player.flag[datahold.armies.squadManagerData]>
        - define barracksInfoSlot <context.inventory.find_item[SquadManagerInfo_Item]>
        - inventory adjust slot:<[barracksInfoSlot]> "lore:<gray>Name: <&r><[squadManagerData].get[name]>|<gray>Squad Limit: <&r><[squadManagerData].deep_get[levels.squadLimit]>|<gray>Squad Size Limit: <&r><[squadManagerData].deep_get[levels.squadSizeLimit]>|<gray>Stationing Capacity: <&r><[squadManagerData].deep_get[levels.stationCapacity]>" destination:<context.inventory>

        on player opens SquadManager_Interface flagged:datahold.armies.showAOE:
        - define AOEItemSlot <context.inventory.find_item[SquadManagerShowAOE_Item]>
        - inventory set slot:<[AOEItemSlot]> o:SquadManagerShowAOEActive_Item d:<context.inventory>

        ## Squad Sel.
        on player clicks SquadListInfo_Item in SquadManager_Interface:
        - run SquadSelectionGUI def.player:<player>

        ## Stationing Re-eval.
        on player clicks SquadStationingEval_Item in SquadManager_Interface:
        - define squadManagerLocation <player.flag[datahold.armies.squadManagerLocation]>
        - define bedCount <proc[CountBedsInSquadManagerArea].context[<[squadManagerLocation]>]>
        - define stationCapacity <[bedCount].sqrt.mul[<[bedCount].power[0.7]>].round>
        - flag <[squadManagerLocation]> squadManager.levels.stationCapacity:<[stationCapacity]>
        - ~run WriteArmyDataToKingdom def.player:<player> def.SMLocation:<[squadManagerLocation]>

        ## AOE Show
        on player clicks SquadManagerShowAOE_Item in SquadManager_Interface:
        - determine passively cancelled

        # Runs the AOE show task script and replaces the SM interface button with a different
        # colored button that cancels the AOE effect
        - if !<player.has_flag[datahold.armies.showAOE]>:
            - define squadManagerData <player.flag[datahold.armies.squadManagerData]>
            - flag <player> datahold.armies.showAOE expire:1h
            - run ShowSquadManagerAOE def.area:<[squadManagerData].get[area]> def.player:<player>
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
        - define squadManagerData <player.flag[datahold.armies.squadManagerData]>
        - define AOELevel <[squadManagerData].deep_get[levels.AOELevel]>
        - define maxAOESize <script[SquadManagerLevelData].data_key[levelData.AOELevel.<[AOELevel]>]>

        - flag <player> noChat.armies.settingAOE:<[maxAOESize]>

        - narrate format:callout "Type in the size of the squad manager's area of effect (or type 'cancel'):"
        - inventory close

        ## AOE Set
        on player chats flagged:noChat.armies.settingAOE:
        - define maxAOESize <player.flag[noChat.armies.settingAOE]>
        - define squadManagerData <player.flag[datahold.armies.squadManagerData]>
        - define squadManagerLocation <player.flag[datahold.armies.squadManagerLocation]>

        - if <context.message.is_integer>:
            - if <context.message.is[MORE].than[<[maxAOESize]>]>:
                - narrate format:callout "The maximum AOE size that can be set at this level is: <[maxAOESize]>. Try again or type 'cancel'."
                - determine cancelled

            - flag <[squadManagerLocation]> squadManager.AOESize:<context.message>
            - flag <player> noChat.armies:!
            - narrate format:callout "Set squad manager AOE to: <white><context.message>"
            - inventory open d:SquadManager_Interface

            - run RecalculateSquadManagerAOE def.AOESize:<context.message> def.SMLocation:<[squadManagerLocation]> def.player:<player>

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
        - define squadManagerData <player.flag[datahold.armies.squadManagerData]>
        - define squadManagerLocation <player.flag[datahold.armies.squadManagerLocation]>
        - define existingName <[squadManagerData].get[name]>

        - if <context.message> == <[existingName]>:
            - narrate format:callout "These barracks already have this name. Try again or type 'cancel'."
            - determine cancelled

        - if <context.message.to_lowercase> == cancel:
            - flag <player> noChat.armies:!
            - inventory open d:SquadManager_Interface
            - narrate format:callout "Cancelled operation."
            - determine cancelled

        - flag <[squadManagerLocation]> squadManager.name:<context.message>
        - run WriteArmyDataToKingdom def.SMLocation:<[squadManagerLocation]> def.player:<player>
        - flag <player> noChat.armies:!

        - narrate format:callout "Renamed barracks to: <context.message.color[red]>"
        - inventory open d:SquadManager_Interface

        - determine cancelled

        ## Close Window
        on player closes SquadManager_Interface flagged:datahold.armies.squadManagerData:
        - if !<player.has_flag[noChat.armies]>:
            - wait 5t
            - if <player.open_inventory> == <player.inventory>:
                - flag <player> datahold.armies.squadManagerData:!
                - flag <player> datahold.armies.squadManagerLocation:!

        ## Leave Game
        on player quits flagged:datahold.armies:
        - flag <player> datahold.armies:!


RecalculateSquadManagerAOE:
    type: task
    debug: false
    definitions: AOESize|SMLocation|player|barracksArea
    AreaCalculation:
    - define AOEHalf <[AOESize].div[2].round_up>
    - define topCorner <[SMLocation].add[<[AOEHalf]>,<[AOEHalf]>,<[AOEHalf]>]>
    - define bottomCorner <[SMLocation].sub[<[AOEHalf]>,<[AOEHalf]>,<[AOEHalf]>]>
    - define barracksArea <cuboid[<[topCorner].world.name>,<[topCorner].xyz>,<[bottomCorner].xyz>]>

    - determine <[barracksArea]>

    script:
    - if !<[barracksArea].exists>:
        - run <script.name> path:AreaCalculation def.AOESize:<[AOESize]> def.SMLocation:<[SMLocation]> save:area
        - define barracksArea <entry[area].created_queue.determination.get[1]>

    - flag <[SMLocation]> squadManager.area:<[barracksArea]>
    - ~run WriteArmyDataToKingdom def.player:<[player]> def.SMLocation:<[SMLocation]>
    - run ShowSquadManagerAOE def.area:<[barracksArea]> def.player:<[player]>


CountBedsInSquadManagerArea:
    type: procedure
    debug: false
    definitions: location
    script:
    - define squadManagerData <[location].flag[squadManager]>
    - define SMArea <[squadManagerData].get[area]>
    - define bedCount <[SMArea].blocks[*_bed].size.div[2]>
    - determine <[bedCount]>


ShowSquadManagerAOE:
    type: task
    debug: false
    definitions: area|player
    script:
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
