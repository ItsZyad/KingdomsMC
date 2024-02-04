##ignorewarning invalid_data_line_quotes

## No header will be added :: file slated for deletion or rework.

BlockData:
    type: data
    legal_items:
        - *_planks
        - *_log
        - *_glass_pane
        - *_carpet
        - *_diorite
        - *_granite
        - *_cobblestone
        - *_stone_bricks
        - *_wool
        - *_slab
        - *_stairs
        - *_bed
        - *_door
        - *_trapdoor
        - *_fence_gate
        - *_button
        - dirt
        - grass_block
        - stone
        - smooth_stone
        - iron_bar
        - hay_block
        - ladder

    exceptions:
        - *prismarine*
        - *purpur*
        - *nether*
        - *quartz*
        - *crimson*
        - *warped*
        - *sponge*
        - *_ore
        - *_end_stone*

    categories:
        wood:
            items:
            - *birch*
            - *oak*
            - *spruce*
            - *dark_oak*
            - *acacia*
            - *jungle*

            exclusions:
            - *_trapdoor
            - *_fence_gate
            - *_door
            - *_button

        stone:
            items:
            - cobblestone*
            - stone*
            - stone_bricks*
            - *andesite*
            - *granite*
            - *diorite*

            exclusions:
            - end_stone*
            - *blackstone*
            - *_trapdoor
            - *_fence_gate
            - *_door
            - *_button


BuildInterfaceSelector:
    type: inventory
    title: "Select Block Category"
    inventory: chest
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [WoodCategory_Item] [] [StoneCategory_Item] [] [InteractablesCategory_Item] [] [GlassCategory_Item] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []


WoodCategory_Item:
    type: item
    display name: "<bold>Wood Blocks"
    material: oak_log
    flags:
        category: wood


StoneCategory_Item:
    type: item
    display name: "<bold>Stone Blocks"
    material: cobblestone
    flags:
        category: stone


InteractablesCategory_Item:
    type: item
    display name: "<bold>Interactable Blocks"
    material: oak_door
    flags:
        category: interactable


GlassCategory_Item:
    type: item
    display name: "<bold>Glass Blocks"
    material: glass
    flags:
        category: glass


BuildInterface:
    type: inventory
    title: "Build Menu"
    inventory: chest
    gui: true
    procedural items:
    - determine <player.flag[BuildItemList]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [Page_back] [Main_Menu] [Page_Forward] [] [] []


Build_Command:
    type: command
    name: build
    usage: /build
    description: "Opens the build mode menu"
    script:
    - inventory open d:BuildInterfaceSelector


BuildCategoryInterface:
    type: task
    definitions: category
    subpaths:
        GUI_Init:
        - define outList <list>

        - narrate format:debug BUILD:<server.flag[BuildMode].deep_get[items.<[category]>]>

        - if !<server.flag[BuildMode].deep_get[items.<[category]>].exists>:
            - narrate if
            - define itemList <server.flag[BuildModeItems]>
            - define blockData <script[BlockData].data_key[categories]>

            - foreach <[itemList]> as:item:
                - foreach <[BlockData].deep_get[<[category]>.items]> as:matcher:
                    - if <[item].advanced_matches[<[matcher]>]>:

                        - define foundExclusion false

                        - foreach <[blockData].deep_get[<[category]>.exclusions]> as:exc:
                            - if <[item].advanced_matches[<[exc]>]>:
                                - define foundExclusion true
                                - foreach stop

                        - if !<[foundExclusion]>:
                            - define outList:->:<[item].as[item]>
                            - flag server BuildMode.items.<[category]>:->:<[item].as[item]>
                            - narrate format:debug <[item]>

        - else:
            - narrate else
            - define outList <server.flag[BuildMode].deep_get[items.<[category]>]>

        - narrate format:debug LIST:<[outList]>
        - narrate format:debug SIZE:<[outList].size>
        - narrate format:debug PAGE:<player.flag[BuildGUIPage]>

        - define page <player.flag[BuildGUIPage]>
        - define itemsPerPage 36

        - if <[page].mul[<[itemsPerPage]>].is[OR_MORE].than[<[outList].size>]>:
            - flag <player> BuildGUIPage:--

        - run Paginate_Task def.itemArray:<[outList]> def.itemsPerPage:<[itemsPerPage]> def.page:<[page]> save:paginate
        - flag <player> BuildItemList:<entry[paginate].created_queue.determination.get[1]>

        - inventory open d:BuildInterface

        GUI_Page_Reset:
        - if !<player.has_flag[BuildGUIPage]> || <player.flag[BuildGUIPage].is[LESS].than[1]>:
            - flag <player> BuildGUIPage:1

        GUI_Next:
        - define category <player.flag[BuildGUICat]>

        - inject BuildCategoryInterface.subpaths.GUI_Page_Reset
        - flag <player> BuildGUIPage:++
        - inject BuildCategoryInterface.subpaths.GUI_Init

        GUI_Prev:
        - define category <player.flag[BuildGUICat]>

        - inject BuildCategoryInterface.subpaths.GUI_Page_Reset
        - flag <player> BuildGUIPage:--
        - inject BuildCategoryInterface.subpaths.GUI_Init

    script:
    - inject BuildCategoryInterface.subpaths.GUI_Page_Reset
    - inject BuildCategoryInterface.subpaths.GUI_Init


BuildInterface_Handler:
    type: world
    events:
        on player clicks Page_Forward in BuildInterface:
        - inject BuildCategoryInterface.subpaths.GUI_Next
        - determine passively cancelled

        on player clicks Page_back in BuildInterface:
        - inject BuildCategoryInterface.subpaths.GUI_Prev
        - determine passively cancelled

        on player clicks Main_Menu in BuildInterface:
        - inventory open d:BuildInterfaceSelector
        - determine passively cancelled

        on player closes BuildInterface:
        - wait 3t

        - if <player.open_inventory> == <player.inventory>:
            - flag <player> BuildGUIPage:!
            - flag <player> BuildGUICat:!

        on player clicks item in BuildInterfaceSelector:
        - if <context.item.material.name> != air:
            - define category <context.item.flag[category]>
            - flag <player> BuildGUICat:<[category]>

            - run BuildCategoryInterface def:<[category]>

        - determine passively cancelled

        on player clicks item in BuildInterface:
        - if <context.clicked_inventory.script.if_null[other]> != other:
            - give to:<player.inventory> <context.item> quantity:64


## THIS FUNCTION FUCKING SUCKS TO RUN. USE SPARINGLY!
GenerateLegalItemList:
    type: task
    script:
    - define legalItemMatchers <script[BlockData].data_key[legal_items]>
    - define exceptionMatchers <script[BlockData].data_key[exceptions]>

    - narrate format:debug "Generating Build Mode Items..."

    - foreach <[legalItemMatchers]> as:legalItem:
        - foreach <server.material_types> as:item:

            - if <[item].name.advanced_matches[<[legalItem]>]>:
                - narrate format:debug <[item].name>
                - define foundException false

                - foreach <[exceptionMatchers]>:

                    - if <[item].advanced_matches[<[value]>]>:
                        - define foundException true
                        - foreach stop

                - if !<[foundException]>:
                    - flag server BuildModeItems:->:<[item].name>

    - narrate format:debug Done!

ViewLegalBuildItems:
    type: task
    script:
    - foreach <server.flag[BuildModeItems]>:
        - narrate <[value]>