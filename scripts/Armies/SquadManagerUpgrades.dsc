SquadManagerAOEUpgrade_Item:
    type: item
    material: player_head
    display name: <light_purple><bold>Upgrade AOE
    mechanisms:
        skull_skin: 6c2e2223-8f50-4bc8-8ac2-31d0c991d0ec|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMTE1MjBlYTQzODRlOGM0ODI1ODY1ZWU3ZGNmMTA5MmFmNDQzZjE1MGFhYjE3MDQxODA4YzlkMzFjZDAxZmRmNyJ9fX0=


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


SquadManagerUpgrade_Handler:
    type: world
    events:
        on player clicks barrier in SquadManagerUpgrade_Interface:
        - inventory open SquadManager_Interface
