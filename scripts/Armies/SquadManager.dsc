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
    lore:
        - No Upgrades Available
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
        - <&r><green>INACTIVE
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


SquadManager_Interface:
    type: inventory
    inventory: chest
    gui: true
    title: Squad Manager
    slots:
    - [SquadComposer_Item] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
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
        - definemap squadManagerData:
            kingdom: <player.flag[kingdom]>
            levels:
                AOELevel: 1
                squadLimit: 1
                squadSizeLimit: 30
            AOESize: 40

        - flag <context.location> squadManager:<[squadManagerData]>

        on player breaks lodestone location_flagged:squadManager:
        - flag <context.location> squadManager:!

        on player clicks lodestone location_flagged:squadManager:
        - if <context.click_type.is_in[RIGHT_CLICK_BLOCK]> || <player.is_sneaking>:
            - animate <player> animation:ARM_SWING
            - inventory open d:SquadManager_Interface
            - flag <player> datahold.armies.squadManagerData:<context.location.flag[squadManager]>
            - flag <player> datahold.armies.squadManagerLocation:<context.location>
            - determine cancelled

        on player clicks barrier in SquadManagerUpgrade_Interface:
        - inventory open d:SquadManager_Interface

        on player clicks SquadManagerUpgradesDark_Item in SquadManager_Interface:
        - inventory open d:SquadManagerUpgrade_Interface

        on player clicks SquadManagerUgradesLight_Item in SquadManager_Interface:
        - inventory open d:SquadManagerUpgrade_Interface

        on player clicks SquadComposer_Item in SquadManager_Interface:
        - inventory open d:SquadComposition_Interface

        on player opens SquadManager_Interface flagged:datahold.armies.showAOE:
        - define slot <context.inventory.find_item[SquadManagerShowAOE_Item]>
        - inventory set slot:<[slot]> o:SquadManagerShowAOEActive_Item d:<context.inventory>

        on player clicks SquadManagerShowAOE_Item in SquadManager_Interface:
        - determine passively cancelled

        - if !<player.has_flag[datahold.armies.showAOE]>:
            - define squadManagerData <player.flag[datahold.armies.squadManagerData]>
            - flag <player> datahold.armies.showAOE expire:1h
            - run ShowSquadManagerAOE def.area:<[squadManagerData].get[area]> def.player:<player>
            - inventory set slot:<context.slot> o:SquadManagerShowAOEActive_Item d:<context.inventory>
            - inventory close

        # Fallback in case inventory adjustment command goes fucky.
        - else:
            - flag <player> datahold.armies.showAOE:!

        ##
        on player clicks SquadManagerShowAOEActive_Item in SquadManager_Interface:
        - determine passively cancelled

        - if <player.has_flag[datahold.armies.showAOE]>:
            - flag <player> datahold.armies.showAOE:!
            - inventory set slot:<context.slot> o:SquadManagerShowAOE_Item d:<context.inventory>
            - inventory close

        ##
        on player clicks SquadManagerSetAOE_Item in SquadManager_Interface:
        - define squadManagerData <player.flag[datahold.armies.squadManagerData]>
        - define AOELevel <[squadManagerData].deep_get[levels.AOELevel]>
        - define maxAOESize <script[SquadManagerLevelData].data_key[levelData.AOELevel.<[AOELevel]>]>

        - flag <player> noChat.armies.settingAOE:<[maxAOESize]>

        - narrate format:callout "Type in the size of the squad manager's area of effect:"
        - inventory close

        ##
        on player chats flagged:noChat.armies.settingAOE:
        - define maxAOESize <player.flag[noChat.armies.settingAOE]>
        - define squadManagerData <player.flag[datahold.armies.squadManagerData]>
        - define squadManagerLocation <player.flag[datahold.armies.squadManagerLocation]>

        - if <context.message.is_integer>:
            - if <context.message.is[MORE].than[<[maxAOESize]>]>:
                - narrate format:callout "The maximum AOE size that can be set at this level is: <[maxAOESize]>. Try again or type 'cancel'."
                - determine cancelled

            - flag <[squadManagerLocation]> squadManager.AOESize:<context.message>
            - flag <player> noChat.armies.settingAOE:!
            - narrate format:callout "Set squad manager AOE to: <white><context.message>"
            - inventory open d:SquadManager_Interface

            - run RecalculateSquadManagerAOE def.AOESize:<context.message> def.SMLocation:<[squadManagerLocation]> def.player:<player>

        - else if <context.message.to_lowercase> == cancel:
            - flag <player> noChat.armies.settingAOE:!
            - inventory open d:SquadManager_Interface
            - narrate format:callout "Cancelled operation."

        - else:
            - narrate format:callout "The AOE value must be a valid number! Try again or type 'cancel'."

        - determine cancelled

        ##
        on player closes inventory flagged:datahold.armies.squadManagerData:
        - if !<player.has_flag[noChat.armies]>:
            - wait 1t
            - if <player.open_inventory> == <player.inventory>:
                - flag <player> datahold.armies.squadManagerData:!
                - flag <player> datahold.armies.squadManagerLocation:!

        ##
        on player quits flagged:datahold.armies:
        - flag <player> datahold.armies:!


RecalculateSquadManagerAOE:
    type: task
    definitions: AOESize|SMLocation|player
    script:
    - define AOEHalf <[AOESize].div[2].round_up>
    - define topCorner <[SMLocation].add[<[AOEHalf]>,<[AOEHalf]>,<[AOEHalf]>]>
    - define bottomCorner <[SMLocation].sub[<[AOEHalf]>,<[AOEHalf]>,<[AOEHalf]>]>
    - define barracksArea <cuboid[<[topCorner].world.name>,<[topCorner].xyz>,<[bottomCorner].xyz>]>

    - flag <[SMLocation]> squadManager.area:<[barracksArea]>

    - run ShowSquadManagerAOE def.area:<[barracksArea]> def.player:<[player]>


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