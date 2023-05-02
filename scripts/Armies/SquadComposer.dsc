SquadCompositionOneSoldier_Item:
    type: item
    material: leather_helmet
    display name: <italic><bold>Add One Swordsman
    mechanisms:
        hides: all
    flags:
        displayItem: true
        amount: 1


SquadCompositionFiveSoldiers_Item:
    type: item
    material: chainmail_helmet
    display name: <gray><italic><bold>Add Five Swordsmen
    mechanisms:
        hides: all
    flags:
        displayItem: true
        amount: 5


SquadCompositionOneArcher_Item:
    type: item
    material: bow
    display name: <italic><bold>Add One Archer
    mechanisms:
        hides: all
    flags:
        displayItem: true
        amount: 1


SquadCompositionFiveArchers_Item:
    type: item
    material: bow
    display name: <gray><italic><bold>Add Five Archers
    mechanisms:
        hides: all
    flags:
        displayItem: true
        amount: 5


SquadCompositionCancel_Item:
    type: item
    material: player_head
    display name: <red><bold>Cancel
    mechanisms:
        skull_skin: 5ecfabf0-5253-47b0-a44d-9a0c924081b9|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYmViNTg4YjIxYTZmOThhZDFmZjRlMDg1YzU1MmRjYjA1MGVmYzljYWI0MjdmNDYwNDhmMThmYzgwMzQ3NWY3In19fQ==


SquadCompositionAccept_Item:
    type: item
    material: player_head
    display name: <green><bold>Accept
    mechanisms:
        skull_skin: afb405c1-16ea-4a23-883f-97867e7db3f9|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYTc5YTVjOTVlZTE3YWJmZWY0NWM4ZGMyMjQxODk5NjQ5NDRkNTYwZjE5YTQ0ZjE5ZjhhNDZhZWYzZmVlNDc1NiJ9fX0=


SquadCompositionInfo_Item:
    type: item
    material: player_head
    display name: <gold><bold>Squad Info
    lore:
        - Total Manpower Required<&co>
        - <bold>0
    mechanisms:
        skull_skin: da4d885d-2505-4f25-bfee-a0de07950191|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDAxYWZlOTczYzU0ODJmZGM3MWU2YWExMDY5ODgzM2M3OWM0MzdmMjEzMDhlYTlhMWEwOTU3NDZlYzI3NGEwZiJ9fX0=


SquadComposition_Interface:
    type: inventory
    inventory: chest
    gui: true
    title: Compose a Squad
    slots:
    - [SquadCompositionOneSoldier_Item] [SquadCompositionFiveSoldiers_Item] [SquadInfoSeparator_Item] [] [] [] [] [] []
    - [SquadCompositionOneArcher_Item] [SquadCompositionFiveArchers_Item] [SquadInfoSeparator_Item] [] [] [] [] [] []
    - [] [] [SquadInfoSeparator_Item] [] [] [] [] [] []
    - [] [] [SquadInfoSeparator_Item] [] [] [] [] [] []
    - [] [] [SquadInfoSeparator_Item] [] [] [] [] [] []
    - [SquadCompositionCancel_Item] [SquadCompositionAccept_Item] [SquadCompositionInfo_Item] [] [] [] [] [] []


SquadComposition_Handler:
    type: world
    events:
        on player clicks item in SquadComposition_Interface:
        - if <context.item.has_flag[displayItem]>:
            - determine passively cancelled
            - adjust <player> item_on_cursor:<context.item>

        - else if <player.item_on_cursor.has_flag[displayItem]> && <context.click> == LEFT && <context.item.material.name> == air:
            - ratelimit <player> 1t

            - define placeItem <player.item_on_cursor>
            - define squadInfoItemSlot <context.inventory.find_item[SquadCompositionInfo_Item]>
            - define squadInfoItem <context.inventory.slot[<[squadInfoItemSlot]>]>
            - flag <player> datahold.armies.manpower:<player.flag[datahold.armies.manpower].if_null[0].add[<[placeItem].flag[amount]>]>
            - inventory adjust slot:<[squadInfoItemSlot]> "lore:Total Manpower Required:|<bold><player.flag[datahold.armies.manpower].if_null[0]>" destination:<context.inventory>

            - adjust def:placeItem display:<[placeItem].display.split[ ].remove[1].space_separated>
            - flag <[placeItem]> displayItem:!

            - inventory set slot:<context.slot> origin:<[placeItem]> destination:<context.inventory>
            - determine cancelled

        on player right clicks in SquadComposition_Interface:
        - if <player.item_on_cursor.material.name> != air:
            - adjust <player> item_on_cursor:<item[air]>
            - determine cancelled

        - else if <context.item.material.name> != air:
            - ratelimit <player> 1t

            - define squadInfoItemSlot <context.inventory.find_item[SquadCompositionInfo_Item]>
            - define squadInfoItem <context.inventory.slot[<[squadInfoItemSlot]>]>
            - flag <player> datahold.armies.manpower:<player.flag[datahold.armies.manpower].if_null[0].sub[<context.item.flag[amount]>]>
            - inventory adjust slot:<[squadInfoItemSlot]> "lore:Total Manpower Required:|<bold><player.flag[datahold.armies.manpower].if_null[0]>" destination:<context.inventory>

            - inventory set slot:<context.slot> origin:air destination:<context.inventory>

            - determine cancelled

        on player closes SquadComposition_Interface:
        - flag <player> datahold.armies.manpower:!