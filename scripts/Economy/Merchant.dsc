##
## * All scripts, inventories, and interaction handlers related to player-merchant interactions.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2023
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

MerchantInterfaceNewFooter_Window:
    type: inventory
    inventory: chest
    slots:
    - [] [] [] [] [] [] [] [] [MerchantInterfaceChangeMode_Item]


MerchantInterfaceChangeMode_Item:
    type: item
    material: player_head
    display name: Change to<&co><blue> Sell Mode
    mechanisms:
        skull_skin: e9667d86-78a7-40ee-bcb9-bd1595f5fbaa|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOTk5YWY0ODZjZTcyYmJiMWQ0ZmU5NWJiY2ZjZGY1OTY2ODFkOWQ2MTA4YjU2MzJmYjg5OTNkZmU5ZGJmMzI5MyJ9fX0=


KMerchant_Assignment:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true

        on click:
        - ratelimit <player> 1t

        - if <server.has_flag[PreGameStart]>:
            - narrate format:callout "Trading with the market is disabled when build mode is active."
            - determine cancelled

        - flag <player> dataHold.interactingMerchant:<npc>
        - flag <npc> dataHold.interactingPlayers:->:<player>

        - if <npc.has_flag[cachedInterface]>:
            - define interactingPlayers <npc.flag[dataHold.interactingPlayers]>
            - define itemList <npc.flag[cachedInterface]>
            - define title "Buy Menu"
            - inject RunMerchantInterface path:OpenInterface

        - else:
            - run RunMerchantInterface def.merchant:<npc> def.player:<player>

        - flag <player> dataHold.merchantMode:buy


RunMerchantInterface:
    type: task
    debug: false
    definitions: merchant|player
    OpenInterface:
    - foreach <[interactingPlayers]> as:target:
        - run PaginatedInterface def.itemList:<[itemList]> def.player:<[target]> def.page:1 def.footer:<[footer].if_null[<inventory[MerchantInterfaceNewFooter_Window]>]> def.title:<[title].if_null[Menu]>

    script:
    - define interactingPlayers <[merchant].flag[dataHold.interactingPlayers]>
    - define itemList <list[]>

    - foreach <[merchant].flag[merchantData.supply]>:
        - define quantity <[value].get[quantity]>

        - if <[quantity]> <= 0:
            - foreach next

        - define name <[key]>
        - define price <[value].get[price]>
        - define lastWeekAvg <[value].get[lastWeekAvg].if_null[null]>
        - define item <[name].as[item]>
        - flag <[item]> quantity:<[quantity]>
        - flag <[item]> price:<[price]>

        - adjust def:item lore:<element[Price: ].bold><element[$<[price].format_number[#,##0.00].if_null[null]>].color[red]>|<element[Quantity: ].bold><[quantity].color[green]>

        - if <[lastWeekAvg].is_decimal>:
            - define percentageDiff <element[<[price].sub[<[lastWeekAvg]>]>].div[<[lastWeekAvg]>].round_to_precision[0.01].mul[100]>
            - define pDElement <element[<[percentageDiff]>%].color[green]> if:<[percentageDiff].is[LESS].than[0]>
            - define pDElement <element[<[percentageDiff]>%].color[red]> if:<[percentageDiff].is[OR_MORE].than[0]>
            - adjust def:item lore:<[item].lore.include[<element[Price Change From Last Week: ].bold><[pDElement]>]>

        - define itemList:->:<[item]>

    - define footer <inventory[MerchantInterfaceNewFooter_Window]>
    - inject RunMerchantInterface path:OpenInterface


KMerchantWindow_Handler:
    type: world
    debug: false
    events:
        on player clicks MerchantInterfaceChangeMode_Item in inventory flagged:dataHold.merchantMode:
        - define merchant <player.flag[dataHold.interactingMerchant]>
        - define interactingPlayers <[merchant].flag[dataHold.interactingPlayers]>

        - if !<player.has_flag[datahold.merchantMode]>:
            - determine cancelled

        # SWITCHING TO SELL MODE
        - if <player.flag[dataHold.merchantMode]> == buy:
            - define itemList <list[]>

            - if <[merchant].has_flag[merchantData.sellData.items]>:
                - foreach <[merchant].flag[merchantData.sellData.items]>:
                    - define name <[key]>
                    - define item <[name].as[item]>
                    - define price <[value].get[price]>
                    - flag <[item]> price:<[price]>

                    - adjust def:item lore:<element[Going Price: ].bold><element[$<[price].format_number[#,##0.00]>].color[red]>

                    - if <player.is_op> || <player.has_permission[kingdoms.admin]>:
                        - adjust def:item lore:<[item].lore.include[<&sp>|<italic><element[Alloc: ].color[white]><[value].get[alloc].color[aqua]>|<element[Spent: ].color[white]><[value].get[spent].color[aqua]>]>

                    # - inventory adjust d:<[target].open_inventory> slot:<context.slot> "lore:<element[Price: ].bold><element[$<[price].format_number[#,##0.00]>].color[red]>|<element[Quantity: ].bold><[quantity].color[green]>" player:<[target]>

                    - define itemList:->:<[item]>

            - define newChangeModeItem <inventory[MerchantInterfaceNewFooter_Window].slot[9]>
            - define footer <inventory[MerchantInterfaceNewFooter_Window]>
            - define title "Sell Menu"
            - adjust def:newChangeModeItem "display:Change to<&co><green> Buy Mode"
            - adjust def:newChangeModeItem skull_skin:13e9f695-f508-4680-ab69-bffb0b9e4bd2|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOWYyNjI4NzA4NjZlMzYxNzU3ZWQ4ZGNmYWJkMTAzZWJkNjRkNTczODQ1NWQwYzkyOWIyNjYyNzRlN2M0YzdkYyJ9fX0=
            - adjust def:footer contents:<list[<item[air]>|<item[air]>|<item[air]>|<item[air]>|<item[air]>|<item[air]>|<item[air]>|<item[air]>|<[newChangeModeItem]>]>

            - foreach <[interactingPlayers]> as:target:
                - run PaginatedInterface def.itemList:<[itemList]> def.player:<[target]> def.page:1 def.footer:<[footer].if_null[<inventory[MerchantInterfaceNewFooter_Window]>]> def.title:<[title].if_null[Menu]>

            - flag <player> dataHold.merchantMode:sell

        # SWITCHING BACK TO BUY MODE
        - else:
            - if <[merchant].has_flag[cachedInterface]>:
                - define title "Buy Menu"
                - define itemList <[merchant].flag[cachedInterface]>
                - inject RunMerchantInterface path:OpenInterface

            - else:
                - run RunMerchantInterface def.merchant:<[merchant]> def.player:<player>

            - flag <player> dataHold.merchantMode:buy

        on player clicks in PaginatedInterface_Window flagged:dataHold.interactingMerchant priority:1:
        - ratelimit player 3t

        - if <context.slot> == -998:
            - determine cancelled

        - if <player.flag[dataHold.merchantMode]> == buy:
            - if !<context.item.has_flag[price]>:
                - determine cancelled

            - define price <context.item.flag[price]>
            - define merchant <player.flag[dataHold.interactingMerchant]>
            - define quantity <[merchant].flag[merchantData.supply.<context.item.material.name>.quantity]>
            - define market <[merchant].flag[merchantData.linkedMarket]>

            # If player shift clicks, buy 10 of the item instead of just 1
            - if <context.click> == SHIFT_LEFT:
                - define purchaseAmount 10

                - if <[quantity]> < 10:
                    - define purchaseAmount <[quantity]>

            - else:
                - define purchaseAmount 1

            - if <[quantity].is[OR_MORE].than[<[purchaseAmount]>]>:
                - if <player.money.is[OR_MORE].than[<[price].mul[<[purchaseAmount]>]>]>:
                    - flag <[merchant]> merchantData.supply.<context.item.material.name>.quantity:-:<[purchaseAmount]>
                    - flag <[merchant]> merchantData.balance:+:<[price].mul[<[purchaseAmount]>]>

                    # take the appropriate amount of money and give
                    # the player the items;
                    - take money quantity:<[price].mul[<[purchaseAmount]>]>

                    # Create item without any of the BM Item's flags or lore
                    - define selectedItem <context.item>
                    - adjust def:selectedItem lore:<list[]>
                    - adjust def:selectedItem flag_map:<map[]>

                    - give <[selectedItem]> quantity:<[purchaseAmount]>

                    - define quantity <[merchant].flag[merchantData.supply.<context.item.material.name>.quantity]>
                    - define interactingPlayers <[merchant].flag[dataHold.interactingPlayers]>

                    - foreach <[interactingPlayers]> as:target:
                        - inventory adjust d:<[target].open_inventory> slot:<context.slot> lore:<element[Price: ].bold><element[$<[price].format_number[#,##0.00]>].color[red]>|<element[Quantity: ].bold><[quantity].color[green]> player:<[target]>

                    - run TransactionRecorder def.price:<[price]> def.item:<context.item.material.name> def.amount:<[purchaseAmount]> def.merchant:<[merchant]> def.player:<player> def.market:<[market]>

                - else:
                    # Clicking outside the window returns -998 for some reason
                    - if <context.slot> != -998 || <context.slot.is[OR_LESS].than[36]>:
                        - if <context.item> != <item[air]>:
                            - narrate format:callout "You do not have enough money to buy this item."

            - else:
                - if <context.item> != <item[air]>:
                    - narrate format:callout "There is not enough of this item to buy."

        - else:
            - if !<context.item.has_flag[price]>:
                - determine cancelled

            - define itemName <context.item.material.name>
            - define price <context.item.flag[price]>
            - define merchant <player.flag[dataHold.interactingMerchant]>
            - define market <[merchant].flag[merchantData.linkedMarket]>
            - define wealth <[merchant].flag[merchantData.wealth]>
            - define sBias <[merchant].flag[merchantData.spendBias]>
            - define merchantItemBudget <[merchant].flag[merchantData.sellData.items.<[itemName]>.alloc]>
            - define merchantSpentItemBudget <[merchant].flag[merchantData.sellData.items.<[itemName]>.spent]>

            # Minimum budget equation:
            # x = 4.588y * (0.85 + s)
            # where: y: wealth
            #        s: sBias
            - define minimumBudget <[wealth].mul[4.588].mul[<element[<[sbias].add[0.85]>]>]>

            # If player shift clicks, sell 10 of the item instead of just 1
            - if <context.click> == SHIFT_LEFT:
                - define sellAmount 10

                - if <[quantity]> < 10:
                    - define sellAmount <[quantity]>

            - else:
                - define sellAmount 1

            - if <[merchant].flag[merchantData.balance].sub[<[price].mul[<[sellAmount]>]>]> > <[minimumBudget]>:
                - ratelimit <player> 10t
                - narrate format:callout "The merchant does not have enough money to buy this from you!"
                - determine cancelled

            - if <[merchantItemBudget].add[<[price].mul[<[sellAmount]>]>]> < <[merchantSpentItemBudget]>:
                - ratelimit <player> 10t
                - narrate format:callout "The merchant is not accepting anymore of this item!"
                - determine cancelled

            - if !<player.inventory.contains_item[<[itemName]>].quantity[<[sellAmount]>]>:
                - ratelimit <player> 10t
                - narrate format:callout "You do not have enough of this item to sell!"
                - determine cancelled

            - take from:<player.inventory> item:<[itemName]> quantity:<[sellAmount]>
            - money give players:<player> quantity:<[price].mul[<[sellAmount]>]>

            - flag <[merchant]> merchantData.balance:-:<[price].mul[<[sellAmount]>]>
            - flag <[merchant]> merchantData.sellData.items.<[itemName]>.spent:+:<[price].mul[<[sellAmount]>]>
            - flag <[merchant]> merchantData.supply.<[itemName]>.quantity:+:<[sellAmount]>
            - narrate format:callout "Sold <[itemName].color[white].italicize> for: <red>$<[price].mul[<[sellAmount]>].format_number[#,##0.0]>"

            - run TransactionRecorder def.price:<[price]> def.item:<context.item.material.name> def.amount:<[sellAmount]> def.merchant:<[merchant]> def.player:<player> def.market:<[market]> def.mode:sell

        - determine cancelled

        on player closes PaginatedInterface_Window flagged:dataHold.interactingMerchant:
        - wait 2t
        - if <player.open_inventory> == <player.inventory>:
            - define inventoryContents <context.inventory.list_contents>
            - define merchant <player.flag[dataHold.interactingMerchant]>

            - if <player.flag[dataHold.merchantMode]> == buy:
                - flag <[merchant]> cachedInterface:<[inventoryContents].get[1].to[<[inventoryContents].size.sub[9]>]>

            - flag <[merchant]> dataHold.interactingPlayers:<-:<player>
            - flag <player> dataHold.merchantMode:!
            - flag <player> dataHold.interactingMerchant:!


TransactionRecorder:
    type: task
    definitions: price|item|amount|merchant|market|mode
    script:
    - define mode <[mode].if_null[buy]>

    - if <[mode]> == buy:
        - define transactions <server.flag[economy.markets.<[market]>.buyData.<[item]>.transactions]>
        - define transactionIndex <[transactions].parse_tag[<[parse_value].exclude[amount]>].find[<map[price=<[price]>;merchant=<[merchant]>]>].if_null[-1]>

        - if <[transactionIndex]> != -1:
            - define transaction <[transactions].get[<[transactionIndex]>]>
            - define transaction.amount:+:<[amount]>
            - flag server economy.markets.<[market]>.buyData.<[item]>.transactions:<[transactions].overwrite[<[transaction]>].at[<[transactionIndex]>]>

        - else:
            - flag server economy.markets.<[market]>.buyData.<[item]>.transactions:->:<map[price=<[price]>;amount=<[amount]>;merchant=<[merchant].as[entity]>]>

        - flag server economy.markets.<[market]>.buyData.totalAmount:+:<[amount]>
        - flag server economy.markets.<[market]>.buyData.totalValue:+:<[price].mul[<[amount]>]>
        - flag server economy.markets.<[market]>.buyData.<[item]>.totalAmount:+:<[amount]>
        - flag server economy.markets.<[market]>.buyData.<[item]>.totalValue:+:<[price].mul[<[amount]>]>

    - else:
        - define transactions <server.flag[economy.markets.<[market]>.sellData.<[item]>.transactions]>
        - define transactionIndex <[transactions].parse_tag[<[parse_value].exclude[amount]>].find[<map[price=<[price]>;merchant=<[merchant]>]>].if_null[-1]>

        - if <[transactionIndex]> != -1:
            - define transaction <[transactions].get[<[transactionIndex]>]>
            - define transaction.amount:+:<[amount]>
            - flag server economy.markets.<[market]>.sellData.<[item]>.transactions:<[transactions].overwrite[<[transaction]>].at[<[transactionIndex]>]>

        - else:
            - flag server economy.markets.<[market]>.sellData.<[item]>.transactions:->:<map[price=<[price]>;amount=<[amount]>;merchant=<[merchant].as[entity]>]>

        - flag server economy.markets.<[market]>.sellData.totalAmount:+:<[amount]>
        - flag server economy.markets.<[market]>.sellData.totalValue:+:<[price].mul[<[amount]>]>
        - flag server economy.markets.<[market]>.sellData.<[item]>.totalAmount:+:<[amount]>
        - flag server economy.markets.<[market]>.sellData.<[item]>.totalValue:+:<[price].mul[<[amount]>]>
