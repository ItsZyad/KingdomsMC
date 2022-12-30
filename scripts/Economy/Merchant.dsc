KMerchant_Menu:
    type: inventory
    inventory: chest
    gui: true
    title: Merchant
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []


KMerchant_Assignment:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true

        on click:
        - if <server.has_flag[RestrictedCreative]>:
            - narrate format:callout "Trading with the market is disabled when restricted creative is on."
            - determine cancelled

        - flag <player> dataHold.interactingMerchant:<npc>
        - flag <npc> dataHold.interactingPlayers:->:<player>

        - if <npc.has_flag[cachedInterface]>:
            - define interactingPlayers <npc.flag[dataHold.interactingPlayers]>
            - define windowInstance <inventory[KMerchant_Menu]>
            - adjust def:windowInstance contents:<npc.flag[cachedInterface]>
            - inject RunMerchantInterface path:OpenInterface

        - else:
            - run RunMerchantInterface def.merchant:<npc> def.player:<player>


RunMerchantInterface:
    type: task
    definitions: merchant|player
    CacheInterface:
    - flag <[merchant]> cachedInterface:<player.open_inventory>

    OpenInterface:
    - foreach <[interactingPlayers]> as:target:
        - inventory open d:<[windowInstance]> player:<[target]>

    script:
    - define windowInstance <inventory[KMerchant_Menu]>
    - define interactingPlayers <[merchant].flag[dataHold.interactingPlayers]>

    - foreach <[merchant].flag[merchantData.supply]>:
        - define quantity <[value].get[quantity]>

        - if <[quantity]> <= 0:
            - foreach next

        - define name <[key]>
        - define price <[value].get[price]>
        - define lastWeekAvg <[value].get[lastWeekAvg]>
        - define item <[name].as[item]>
        - flag <[item]> quantity:<[quantity]>
        - flag <[item]> price:<[price]>

        - adjust def:item "lore:<element[Price: ].bold><element[$<[price].format_number[#,##0.00]>].color[red]>|<element[Quantity: ].bold><[quantity].color[green]>"

        - if <[lastWeekAvg].is_decimal>:
            - define percentageDiff <element[<[price].sub[<[lastWeekAvg]>]>].div[<[lastWeekAvg]>].round_to_precision[0.01].mul[100]>
            - define pDElement <element[<[percentageDiff]>%].color[green]> if:<[percentageDiff].is[LESS].than[0]>
            - define pDElement <element[<[percentageDiff]>%].color[red]> if:<[percentageDiff].is[OR_MORE].than[0]>
            - adjust def:item "lore:<[item].lore.include[<element[Price Change From Last Week: ].bold><[pDElement]>]>"

        - give to:<[windowInstance]> <[item]>

    - inject RunMerchantInterface path:OpenInterface

# KMerchant_Interact:
#     type: interact
#     steps:
#         1:
#             click trigger:
#                 script:


KMerchantWindow_Handler:
    type: world
    events:
        on player clicks in KMerchant_Menu:
        - ratelimit player 3t
        - define price <context.item.flag[price]>
        - define merchant <player.flag[dataHold.interactingMerchant]>
        - define quantity <[merchant].flag[merchantData.supply.<context.item.material.name>.quantity]>
        - define market <[merchant].flag[merchantData.linkedMarket]>

        # If player shift clicks, buy 10 of the item instead of
        # just 1

        - if <context.click> == SHIFT_LEFT:
            - define purchaseAmount 10

        - else:
            - define purchaseAmount 1

        - if <[quantity].is[OR_MORE].than[<[purchaseAmount]>]>:
            - if <player.money.is[OR_MORE].than[<[price].mul[<[purchaseAmount]>]>]>:
                - flag <[merchant]> merchantData.supply.<context.item.material.name>.quantity:-:<[purchaseAmount]>

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
                    - inventory adjust d:<[target].open_inventory> slot:<context.slot> "lore:<element[Price: ].bold><element[$<[price].format_number[#,##0.00]>].color[red]>|<element[Quantity: ].bold><[quantity].color[green]>" player:<[target]>

                - run MarketDemandScript def.price:<[price]> def.item:<context.item.material.name> def.amount:<[purchaseAmount]> def.merchant:<[merchant]> def.player:<player> def.market:<[market]>

            - else:
                # Clicking outside the window returns -998 for some reason
                - if <context.slot> != -998 || <context.slot.is[OR_LESS].than[36]>:
                    - if <context.item> != <item[air]>:
                        - narrate format:callout "You do not have enough money to buy this item."

        - else:
            - if <context.item> != <item[air]>:
                - narrate format:callout "There is not enough of this item to buy."

        - determine cancelled

        on player closes KMerchant_Menu:
        - wait 2t
        - if <player.open_inventory> == <player.inventory>:
            - define inventoryContents <context.inventory>
            - define merchant <player.flag[dataHold.interactingMerchant]>
            - flag <[merchant]> cachedInterface:<[inventoryContents].list_contents>
            - flag <[merchant]> dataHold.interactingPlayers:<-:<player>
            - flag <player> dataHold.interactingMerchant:!
