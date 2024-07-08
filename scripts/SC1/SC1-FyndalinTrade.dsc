##
## [SCENARIO I]
## The scripts in this file all relate to the mechanic that will allow both kingdoms to trade with
## Fyndalin (which is now purely simulated off-map).
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jul 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

FyndalinTrade_Command:
    type: command
    name: fyndalintrade
    usage: /fyndalintrade
    description: Opens the menu which allows kingdoms to trade with the off-map Empire of Fyndalin
    script:
    - if <player.has_flag[kingdom]>:
        - inventory open d:FyndalinTrade_Window

    - else:
        - narrate format:callout "You cannot use this command if you're not in a kingdom!"


FyndalinTrade_BuildingBlocks_Item:
    type: item
    material: stone_bricks
    display name: <&0>Building Blocks


FyndalinTrade_Organics_Item:
    type: item
    material: oak_sapling
    display name: Organics


FyndalinTrade_Resources_Item:
    type: item
    material: coal
    display name: Natural Resources & Ores


FyndalinTrade_Food_Item:
    type: item
    material: bread
    display name: Foodstuffs


FyndalinTrade_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Fyndalin Trade
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [FyndalinTrade_BuildingBlocks_Item] [] [FyndalinTrade_Organics_Item] [] [FyndalinTrade_Resources_Item] [] [FyndalinTrade_Food_Item] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []


FyndalinTrade_Handler:
    type: world
    debug: false
    events:
        on player clicks FyndalinTrade* in FyndalinTrade_Window:
        - ratelimit player 3t

        - if !<server.has_flag[kingdoms.scenario-1.kingdomList.<player.flag[kingdom]>.trade.itemMap]>:
            - narrate format:callout "Cannot trade with Fyndalin at the moment!"
            - determine cancelled

        - define tradeMap <server.flag[kingdoms.scenario-1.kingdomList.<player.flag[kingdom]>.trade.itemMap]>
        - define category <context.item.script.name.split[_].get[2]>

        - flag <player> datahold.scenario-1.fyndalinTrade.category:<[category]>

        - define itemList <list[]>

        - foreach <[tradeMap].get[<[category]>]> as:itemData key:itemName:
            - define item <item[<[itemName]>]>
            - define amount <[itemData].get[amount]>
            - define price <[itemData].get[price]>

            - adjust def:item lore:<element[Price: ].bold><element[$<[price].format_number[#,##0.00].if_null[null]>].color[red]>|<element[Quantity: ].bold><[amount].color[green]>

            - define itemList:->:<[item]>

        - run PaginatedInterface def.itemList:<[itemList]> def.player:<player> def.page:1 def.title:<element[Trade With Fyndalin]>

        on player clicks item in PaginatedInterface_Window flagged:datahold.scenario-1.fyndalinTrade:
        - ratelimit player 3t

        # Clicking outside the window returns -998 for some reason
        - if <context.slot> == -998 || <context.item.material.name> == air:
            - determine cancelled

        - define category <player.flag[datahold.scenario-1.fyndalinTrade.category]>
        - define amount <server.flag[kingdoms.scenario-1.kingdomList.<player.flag[kingdom]>.trade.itemMap.<[category]>.<context.item.material.name>.amount]>
        - define price <server.flag[kingdoms.scenario-1.kingdomList.<player.flag[kingdom]>.trade.itemMap.<[category]>.<context.item.material.name>.price]>

        # If player shift clicks, buy 10 of the item instead of just 1
        - if <context.click> == SHIFT_LEFT:
            - define purchaseAmount 10

            - if <[amount]> < 10:
                - define purchaseAmount <[amount]>

        - else:
            - define purchaseAmount 1

        - if <[amount].is[OR_MORE].than[<[purchaseAmount]>]>:
            - if <player.money.is[OR_MORE].than[<[price].mul[<[purchaseAmount]>]>]>:

                # take the appropriate amount of money and give
                # the player the items;
                - money take quantity:<[price].mul[<[purchaseAmount]>]>

                # Create item without any of the BM Item's flags or lore
                - define selectedItem <context.item>
                - adjust def:selectedItem lore:<list[]>
                - adjust def:selectedItem flag_map:<map[]>

                - give <[selectedItem]> quantity:<[purchaseAmount]>

                - flag server kingdoms.scenario-1.kingdomList.<player.flag[kingdom]>.trade.itemMap.<player.flag[datahold.scenario-1.fyndalinTrade.category]>.<context.item.material.name>.amount:-:<[purchaseAmount]>

                - define amount <[amount].sub[<[purchaseAmount]>]>

                - inventory adjust d:<context.inventory> slot:<context.slot> lore:<element[Price: ].bold><element[$<[price].format_number[#,##0.00].if_null[null]>].color[red]>|<element[Quantity: ].bold><[amount].color[green]>

            - else:
                - narrate format:callout "You do not have enough money to buy this item."

        - else:
            - narrate format:callout "There is not enough of this item to buy."


GenerateFyndalinTradeList:
    type: task
    debug: false
    definitions: kingdom[`ElementTag(String)`]
    description:
    - Will return a MapTag of all the Fyndalin-traded items available, their amount and price, for the kingdom with the specified name.
    - Will return null if the provided kingdom code is invalid.
    - ---
    - `→ [MapTag( ElementTag(Float), ElementTag(Integer) )]`

    script:
    ## Will return a MapTag of all the Fyndalin-traded items available, their amount and price, for
    ## the kingdom with the specified name.
    ##
    ## Will return null if the provided kingdom code is invalid.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> ?[MapTag<
    ##         ElementTag<Float>,
    ##         ElementTag<Integer>
    ##     >]

    - if !<[kingdom].proc[ValidateKingdomCode]>:
        - determine null

    - yaml load:economy_data/worth.yml id:worth

    - define tradeCategoryData <script[TradableItems_Data].data_key[TradableItems.Fyndalin]>
    - define tradeConfigData <script[TradableItems_Data].data_key[ConfigData]>
    - define itemMap <map[]>

    - foreach <[tradeCategoryData]> key:catName as:catData:
        - define amountMul <util.random.decimal[0.9].to[1.15]>
        - define priceMul <util.random.decimal[<[tradeConfigData].deep_get[priceMultipliers.Fyndalin.min]>].to[<[tradeConfigData].deep_get[priceMultipliers.Fyndalin.max]>]>

        - foreach <[catData].get[items]> key:item as:amount:
            - define itemMap.<[catName]>.<[item]>.amount:<[amount].mul[<[amountMul]>].round>
            - define itemMap.<[catName]>.<[item]>.price:<yaml[worth].read[items.<[item]>.base].round_to_precision[0.01]>

    - yaml id:worth unload

    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.trade.itemMap:<[itemMap]>
    - determine <[itemMap]>


FyndalinTradeRefresh_Handler:
    type: world
    events:
        on time 23:
        - define worldDay <context.world.time.full.in_days.round>

        - if <[worldDay].mod[7]> == 0:
            - foreach <proc[GetKingdomList]> as:kingdom:
                - run GenerateFyndalinTradeList def.kingdom:<[kingdom]>