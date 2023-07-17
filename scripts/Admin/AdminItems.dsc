NPCYeet_Item:
    type: item
    material: blaze_rod
    display name: <gold><bold>NPC YEETER


NPCYeet_Handler:
    type: world
    events:
        on player right clicks entity with:NPCYeet_Item:
        - if <player.is_op> && !<context.entity.is_player>:
            - narrate format:admincallout "Removed entity: <context.entity.id>"
            - remove <context.entity>


SuperWheat_Item:
    type: item
    material: wheat
    display name: <light_purple><bold>Super Wheat Tool
    mechanisms:
        enchantments:
        - fortune:1


SuperWheat_Handler:
    type: world
    debug: false
    events:
        on player clicks block with:SuperWheat_Item:
        - ratelimit <player> 1t
        - define acceptableBlocks <list[grass_block|dirt|corse_dirt|podzol|farmland]>

        - if <[acceptableBlocks].contains_text[<player.cursor_on[10].block.material.name>]>:
            - modifyblock <player.cursor_on[10]> farmland
            - modifyblock <player.cursor_on[10].up[1]> wheat
            - adjustblock <player.cursor_on[10]> age:7


NetherKey_Item:
    type: item
    material: carrot_on_a_stick
    display name: <light_purple><bold>Nether Key
    lore:
        - A mysterious key, that
        - shimmers in the sunlight
    mechanisms:
        custom_model_data: 123456
