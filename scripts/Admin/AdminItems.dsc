##
## This file contains all items, and their handlers, which admins can use to make their lives a bit
## easier (or just to cheese the game ;)).
##
## Split-off from the admin tools file just to keep things tidy...
##
## @Author: Zyad (@itszyad / ITSZYAD@9280)
## @Date: Sep 2023
## @Script Ver: v1.0

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


ChunkClaim_Item:
    type: item
    material: blaze_rod
    display name: <gold><bold>Claiming Wand


ChunkClaim_Handler:
    type: world
    events:
        on player clicks block with:ChunkClaim_Item:
        - if <player.is_op> || <player.has_permission[kingdoms.admin.claimingWand]>:
            - execute as_player "k claim core"
