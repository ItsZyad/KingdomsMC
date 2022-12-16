DailySimulationUpdate:
    type: task
    script:
    - define markets <server.flag[economy.markets]>

    - foreach <[markets]> as:market:
        - define marketName <[market].key>
        - define merchants <[market].get[merchants]>
        - define attrac <[market].get[attractiveness]>

        - foreach <[merchants]> as:merc:
            - define balance <[merc].flag[merchantData.balance]>
            - define wealth <[merc].flag[merchantData.wealth]>
            - flag <[merc]> merchantData.balance:<[wealth]> if:<[balance].exists.not>
            - flag <[merc]> merchantData.balance:<[wealth].add[<[balance]>]> if:<[balance].exists>

            - run MerchantPurchaseDecider def.merchant:<[merc]> def.market:<[market]> save:purchaseDecider


# Runs for every merchant in a market and calculates what items it should prioritize buying
MerchantPurchaseDecider:
    type: task
    definitions: merchant|market
    script:
    - yaml load:economy_data/price-info.yml id:prices

    - define allItems <list[]>
    - define spec <[merchant].flag[merchantData.spec]>
    - define balance <[merchant].flag[merchantData.balance]>
    - define wealth <[merchant].flag[merchantData.wealth]>
    - define sBias <[merchant].flag[merchantData.spendBias]>
    - define supplyPriceMod <[market].get[supplierPriceMod]>

    # Lower qBias should favor quantity very highly
    - define qBias 0.05
    ##- define qBias <element[1].sub[<[merchant].flag[merchantData.quantityBias]>].round_to_precision[0.05]>
    - define qBias:+:0.05 if:<[qBias].equals[0]>

    # Lower qSensitivity will capture fewer items
    - define qSensitivity 5
    ##- define qSensitivity <util.random.decimal[1].to[10]>

    - if <[spec]> == null || !<[spec].exists>:
        - define group items

    - else:
        - define group items.<[spec]>

    - if <[market].keys.contains[purchaseData]>:
        # TODO: Finish after completing MarketDemandAnalyzer
        #- define qControlledItems <[qControlledItems].random[<[qControlledItems].size>]>
        - narrate format:debug WIP

        # Run through in-demand items and if the merchant still has money left then run through
        # the while loop in the else block. Copy over priceControlledItems and qControlledItems
        # as needed.

    - else:
        - define allItemsRaw <yaml[prices].read[price_info.<[group]>]>

        - foreach <[allItemsRaw]> as:group:
            - foreach <[group]> as:item key:itemName:
                - define allItems:->:<[item].include[<map[name=<[itemName]>]>]>

        # Generates a list containing only the items that cost at most a tenth of the merchant's
        # current balance
        - define singlePriceThreshold <[wealth].div[10].round>
        - define priceControlledItems <[allItems].filter_tag[<[filter_value].get[base].is[OR_LESS].than[<[singlePriceThreshold]>]>]>
        - define qControlledItems <[priceControlledItems].filter_tag[<[filter_value].get[base].mul[<[qBias]>].is[LESS].than[<[qSensitivity]>]>]>
        - define qControlledItems <[qControlledItems].filter_tag[<[filter_value].get[base].mul[<[qBias]>].is[OR_LESS].than[<[qSensitivity].mul[<[qBias]>].add[<[qBias]>]>]>]>
        - define qControlledItems <[qControlledItems].sort_by_value[get[base]]>
        - define qControlledItems <[qControlledItems].reverse> if:<[qBias].is[OR_MORE].than[0.5]>
        - define spendableBalance <[balance].sub[<[balance].mul[<util.random.decimal[<[sBias]>].to[<util.random.decimal[<[sBias].add[1]>].to[1]>]>]>]>
        - define itemAmount <[qControlledItems].size>

        #TODO: VERY IMPORTANT!!!
        #TODO: Remove these two lines before going into prod.
        - flag <[merchant]> merchantData.supply:!
        - flag server economy.markets.<[merchant].flag[merchantData.linkedMarket]>.supplyAmounts:!

        - define iterations 0

        - while <[merchant].flag[merchantData.balance].is[MORE].than[<[spendableBalance]>]> && <[iterations]> < 5:
            - foreach <[qControlledItems]> as:item:
                - define base <[item].get[base]>
                - define balance <[merchant].flag[merchantData.balance]>
                - define spendableBalance <[balance].mul[<util.random.decimal[<[sBias]>].to[1]>]>
                - define reasonablePurchaseAmount <[spendableBalance].div[<[itemAmount]>].div[<[base]>].round>
                - define supplyPrice <[reasonablePurchaseAmount].mul[<[base].mul[<[supplyPriceMod]>]>]>

                # - narrate format:debug NAM:<[item].get[name]>
                # - narrate format:debug RPA:<[reasonablePurchaseAmount]>
                # - narrate format:debug SUP:<[supplyPrice]>
                # - narrate format:debug SPB:<[spendableBalance]>
                # - narrate format:debug ----------------------

                - if <[spendableBalance].is[OR_MORE].than[<[supplyPrice]>]>:
                    - flag <[merchant]> merchantData.balance:-:<[supplyPrice]>
                    - flag <[merchant]> merchantData.supply.<[item].get[name]>.quantity:+:<[reasonablePurchaseAmount]>
                    - flag <[merchant]> merchantData.supply.<[item].get[name]>.price:<[base]>

                    - flag server economy.markets.<[merchant].flag[merchantData.linkedMarket]>.supplyAmounts.<[item]>:+:<[reasonablePurchaseAmount]>

                - else:
                    - foreach stop

                - define iterations:+:1

        - narrate format:debug SPM:<[supplyPriceMod]>
        - narrate format:debug SPEN:<[spendableBalance]>

    - yaml id:prices unload


MarketDemandScript:
    type: task
    definitions: price|item|amount|merchant|player|market
    StandardDevCalculator:
    - define mean <[marketDemand].get[totalValue].div[<[marketDemand].get[<[item]>].size>]>
    - define n <[marketDemand].get[<[item]>].size>
    - define sum 0

    - foreach <[allPrices]> as:price:
        - define sum:+:<[price].sub[<[mean]>].power[2]>

    - define stDev <[sum].div[<[n].sub[1]>].sqrt>

    MarketDemandAnalyzer:
    # TODO: UNCOMMENT WHEN IN PROD!
    #- define supplyAmounts <server.flag[economy.markets.<[market]>.supplyAmounts]>
    - define supplyAmounts <server.flag[economy.markets.<[market]>.supplyMap]>
    - define marketDemand <server.flag[economy.markets.<[market]>.marketDemand]>

    # This value is a ratio between the amount of an item that was sold in the past week
    # and the average amount of that item that gets spawned in merchant inventories weekly
    - define saleToAmountRatio <[marketDemand].get[totalAmount].div[<[supplyAmounts].get[<[item]>]>]>
    - define averageSellPrice <[marketDemand].get[totalValue].div[<[marketDemand].get[<[item]>].size>]>
    - define allPrices <[marketDemand].get[<[item]>].parse_tag[<[parse_value].get[price]>]>
    - inject MarketDemandScript path:StandardDevCalculator

    - definemap marketAnalysis:
        saleToAmountRatio: <[saleToAmountRatio].round_to_precision[0.0001]>
        totalAmount: <[marketDemand].get[totalAmount]>
        totalValue: <[marketDemand].get[totalValue]>
        sellPriceInfo:
            average: <[averageSellPrice]>
            stDev: <[stDev].round_to_precision[0.0001]>
            max: <[allPrices].highest>
            min: <[allPrices].lowest>

    - run FlagVisualizer def.flag:<[marketAnalysis]> def.flagName:Market

    script:
    - flag server economy.markets.<[market]>.marketDemand.<[item]>:->:<map[price=<[price]>;amount=<[amount]>;merchant=<[merchant]>]>
    - flag server economy.markets.<[market]>.marketDemand.totalAmount:+:<[amount]>
    - flag server economy.markets.<[market]>.marketDemand.totalValue:+:<[price]>


## Save previous market tendancies to YAML
## perhaps also save along with it global
## market demand figures for analysis by
## blackmarket factions or other omni-present
## economic forces.
# MarketDemandHandler:
#     type: world
#     events:
#         on system time hourly every:24:
#         - foreach <server.flag[economy.markets].keys> as:market:
#             - flag server economy.markets.<[market]>.marketDemand:!