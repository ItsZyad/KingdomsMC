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
        - inventory open d:FyndalinTradeType_Window

    - else:
        - narrate format:callout "You cannot use this command if you're not in a kingdom!"


FyndalinTrade_BuildingBlocks_Item:
    type: item
    material: stone_bricks
    display name: Building Blocks


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
    title: Fyndalin Trade - <player.flag[datahold.scenario-1.fyndalinTrade.type].if_null[buy].to_titlecase>ing
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [FyndalinTrade_BuildingBlocks_Item] [] [FyndalinTrade_Organics_Item] [] [FyndalinTrade_Resources_Item] [] [FyndalinTrade_Food_Item] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [barrier] [] [] [] []


FyndalinTradeBuy_Item:
    type: item
    material: player_head
    display name: <green><bold>Buy Items
    mechanisms:
        skull_skin: 13e9f695-f508-4680-ab69-bffb0b9e4bd2|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOWYyNjI4NzA4NjZlMzYxNzU3ZWQ4ZGNmYWJkMTAzZWJkNjRkNTczODQ1NWQwYzkyOWIyNjYyNzRlN2M0YzdkYyJ9fX0=


FyndalinTradeSell_Item:
    type: item
    material: player_head
    display name: <gold><bold>Sell Items
    mechanisms:
        skull_skin: 7193fa7b-4dbe-4e92-a840-3d95d2839240|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDllOTA2OGQxNWI0ZDhhNGI2NGZiYjA2NzQ0MTBkYjM0OWE2YzZhYWQ3OWZlOGE1YWI3MWU5NGRhMjQwZmZmNiJ9fX0=


FyndalinTradeType_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Select Trade Type
    slots:
    - [] [] [FyndalinTradeBuy_Item] [] [] [] [FyndalinTradeSell_Item] [] []


FyndalinTradeFooter_Interface:
    type: inventory
    inventory: chest
    gui: true
    title: null
    slots:
    - [] [] [] [] [barrier] [] [] [] []


OpenFyndalinTradeWindowCategory:
    type: task
    debug: false
    definitions: player[PlayerTag]|category[ElementTag(String)]
    script:
    - define tradeMap <server.flag[kingdoms.scenario-1.trade.itemMap]>
    - flag <[player]> datahold.scenario-1.fyndalinTrade.category:<[category]>

    - define tradeEfficiency <player.flag[kingdom].proc[GetKingdomTradeEfficiency]>
    - define itemList <list[]>
    - define title <element[Buy From Fyndalin]>

    - if <[player].flag[datahold.scenario-1.fyndalinTrade.type]> == buy:
        - foreach <[tradeMap].get[<[category]>]> as:itemData key:itemName:
            - define item <item[<[itemName]>]>
            - define amount <[itemData].get[amount].mul[<element[1].sub[<[tradeEfficiency]>].round>]>
            - define price <[itemData].get[price].mul[1.35].mul[<element[1].sub[<[tradeEfficiency]>].abs>]>

            - definemap lore:
                1: <element[Price: ].bold><element[$<[price].format_number[#,##0.00].if_null[null]>].color[red]>
                2: <element[Quantity: ].bold><[amount].color[green]>
                3: <element[(<[tradeEfficiency].mul[100].round_to_precision[0.01]>%) River Blockage Modifier].color[red].italicize>
                4: <element[This decreases the quantity of goods from].color[gray].italicize>
                5: <element[Fyndalin, as well as increasing the price.].color[gray].italicize>

            - adjust def:item lore:<[lore].values>
            - adjust def:item flag:price:<[price]>

            - define itemList:->:<[item]>

    - else:
        - define title <element[Sell To Fyndalin]>

        - foreach <[tradeMap].get[<[category]>]> as:itemData key:itemName:
            - define item <item[<[itemName]>]>
            - define maxAmount <[itemData].get[amount].mul[<element[1].sub[<[tradeEfficiency]>].round>]>
            - define amountSold <server.flag[kingdoms.scenario-1.trade.alreadySold.<[itemName]>].if_null[0]>
            - define price <[itemData].get[price].mul[0.8].mul[<element[1].add[<[tradeEfficiency]>]>]>

            - definemap lore:
                1: <element[Going Price: ].bold><element[$<[price].format_number[#,##0.00].if_null[null]>].color[red]>
                2: <element[Allocation: ].bold><[amountSold].color[green]>/<[maxAmount].color[red]>
                3: <element[(<[tradeEfficiency].mul[100].round_to_precision[0.01]>%) River Blockage Modifier].color[red].italicize>
                4: <element[This decreases the quantity of goods from].color[gray].italicize>
                5: <element[Fyndalin, as well as increasing the price.].color[gray].italicize>

            - adjust def:item flag:maxAmount:<[maxAmount]>
            - adjust def:item flag:price:<[price]>
            - adjust def:item lore:<[lore].values>

            - define itemList:->:<[item]>

    - flag server datahold.scenario-1.fyndalinTrade.playersViewing.<[category]>:->:<[player]>
    - run PaginatedInterface def.itemList:<[itemList]> def.player:<[player]> def.page:1 def.title:<[title]> def.flag:fyndalinTrade def.footer:<inventory[FyndalinTradeFooter_Interface]>


FyndalinTrade_Handler:
    type: world
    debug: false
    events:
        on player clicks FyndalinTradeBuy_Item in FyndalinTradeType_Window:
        - flag <player> datahold.scenario-1.fyndalinTrade.type:buy
        - inventory open d:FyndalinTrade_Window

        on player clicks FyndalinTradeSell_Item in FyndalinTradeType_Window:
        - flag <player> datahold.scenario-1.fyndalinTrade.type:sell
        - inventory open d:FyndalinTrade_Window

        on player clicks FyndalinTrade* in FyndalinTrade_Window:
        - ratelimit player 3t

        - if !<server.has_flag[kingdoms.scenario-1.trade.itemMap]>:
            - narrate format:callout "Cannot trade with Fyndalin at the moment!"
            - determine cancelled

        - define category <context.item.script.name.split[_].get[2]>

        - run OpenFyndalinTradeWindowCategory def.player:<player> def.category:<[category]>

        on player clicks barrier in PaginatedInterface_Window flagged:datahold.scenario-1.fyndalinTrade:
        - inventory open d:FyndalinTrade_Window

        on player clicks barrier in FyndalinTrade_Window:
        - inventory open d:FyndalinTradeType_Window

        on player clicks item in PaginatedInterface_Window flagged:datahold.scenario-1.fyndalinTrade:
        - ratelimit player 3t

        # Clicking outside the window returns -998 for some reason
        - if <context.slot> == -998 || <context.item.material.name> == air || <context.item.material.name> == barrier:
            - determine cancelled

        - define tradeEfficiency <player.flag[kingdom].proc[GetKingdomTradeEfficiency]>
        - define category <player.flag[datahold.scenario-1.fyndalinTrade.category]>
        - define price <context.item.flag[price]>

        - if <player.flag[datahold.scenario-1.fyndalinTrade.type].if_null[buy]> == buy:
            - define amount <server.flag[kingdoms.scenario-1.trade.itemMap.<[category]>.<context.item.material.name>.amount].mul[<element[1].sub[<[tradeEfficiency]>]>].round>
            - define purchaseAmount 1

            # If player shift clicks, buy 10 of the item instead of just 1
            - if <context.click> == SHIFT_LEFT:
                - define purchaseAmount 10

                - if <[amount]> < 10:
                    - define purchaseAmount <[amount]>

            - if <[amount].is[LESS].than[<[purchaseAmount]>]>:
                - narrate format:callout "There is not enough of this item to buy."
                - determine cancelled

            - if <player.money.is[LESS].than[<[price].mul[<[purchaseAmount]>]>]>:
                - narrate format:callout "You do not have enough money to buy this item."
                - determine cancelled

            # take the appropriate amount of money and give the player the items
            - money take quantity:<[price].mul[<[purchaseAmount]>]>

            # Create item without any of the BM Item's flags or lore
            - define selectedItem <context.item>
            - adjust def:selectedItem lore:<list[]>
            - adjust def:selectedItem flag_map:<map[]>

            - give <[selectedItem]> quantity:<[purchaseAmount]>

            - flag server kingdoms.scenario-1.trade.itemMap.<player.flag[datahold.scenario-1.fyndalinTrade.category]>.<context.item.material.name>.amount:-:<[purchaseAmount]>

            - define amount <[amount].sub[<[purchaseAmount]>]>

            - inventory adjust d:<context.inventory> slot:<context.slot> lore:<element[Price: ].bold><element[$<[price].format_number[#,##0.00].if_null[null]>].color[red]>|<element[Quantity: ].bold><[amount].color[green]>

        - else:
            - define amountSold <server.flag[kingdoms.scenario-1.trade.alreadySold.<context.item.material.name>].if_null[0]>
            - define maxAmount <context.item.flag[maxAmount]>
            - define purchaseAmount 1

            - if !<player.inventory.contains_item[<context.item.material.name>]>:
                - narrate format:callout "You do not have any of this item to sell Fyndalin!"
                - determine cancelled

            - if <context.click> == SHIFT_LEFT:
                - define purchaseAmount 10

                - if <[purchaseAmount].add[<[amountSold]>]> > <[maxAmount]>:
                    - define purchaseAmount <[maxAmount].sub[<[amountSold]>].abs>

            - if <[purchaseAmount]> > <[maxAmount].sub[<[amountSold]>]>:
                - narrate format:callout "Fyndalin is not willing to buy any more of this item."
                - determine cancelled

            - money give quantity:<[price].mul[<[purchaseAmount]>]>

            # Create item without any of the BM Item's flags or lore
            - define selectedItem <context.item>
            - adjust def:selectedItem lore:<list[]>
            - adjust def:selectedItem flag_map:<map[]>

            - take slot:<player.inventory.find_item[<context.item.material.name>]> quantity:<[purchaseAmount]>

            - flag server kingdoms.scenario-1.trade.alreadySold.<context.item.material.name>:+:<[purchaseAmount]>
            - define amountSold <server.flag[kingdoms.scenario-1.trade.alreadySold.<context.item.material.name>].if_null[0]>

            - inventory adjust d:<context.inventory> slot:<context.slot> lore:<context.item.lore.remove[2].insert[<element[Allocation: ].bold><[amountSold].color[green]>/<[maxAmount].color[red]>].at[2]>

        - foreach <server.flag[datahold.scenario-1.fyndalinTrade.playersViewing.<[category]>].exclude[<player>]> as:player:
            - run OpenFyndalinTradeWindowCategory def.player:<[player]> def.category:<[category]>

        on custom event id:PaginatedInvClose flagged:fyndalinTrade:
        - define category <player.flag[datahold.scenario-1.fyndalinTrade.category]>
        - flag server datahold.scenario-1.fyndalinTrade.playersViewing.<[category]>:<-:<player>

        - flag <player> datahold.scenario-1.fyndalinTrade:!


GenerateFyndalinTradeList:
    type: task
    debug: false
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
    ## >>> ?[MapTag<
    ##         ElementTag<Float>,
    ##         ElementTag<Integer>
    ##     >]

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

    - flag server kingdoms.scenario-1.trade.itemMap:<[itemMap]>
    - determine <[itemMap]>


FyndalinTradeRefresh_Handler:
    type: world
    events:
        on time 23:
        - define worldDay <context.world.time.full.in_days.round>

        - if <[worldDay].mod[7]> == 0:
            - foreach <proc[GetKingdomList]> as:kingdom:
                - run GenerateFyndalinTradeList def.kingdom:<[kingdom]>