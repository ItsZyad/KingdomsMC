DailySimulationUpdate:
    type: task
    script:
    - define markets <server.flag[economy.markets]>

    - foreach <[markets]> as:market:
        - define marketName <[key]>
        - define merchants <[market].get[merchants]>
        - define attrac <[market].get[attractiveness]>

        - foreach <[merchants]> as:merc:
            - define balance <[merc].flag[merchantData.balance]>
            - define wealth <[merc].flag[merchantData.wealth]>
            - flag <[merc]> merchantData.balance:<[wealth]> if:<[balance].exists.not>
            - flag <[merc]> merchantData.balance:<[wealth].add[<[balance]>]> if:<[balance].exists>

            - run MerchantPurchaseDecider def.merchant:<[merc]> def.marketName:<[marketName]> save:purchaseDecider


# Runs for every merchant in a market and calculates what items it should prioritize buying
MerchantPurchaseDecider:
    type: task
    definitions: merchant|marketName
    script:
    - yaml load:economy_data/price-info.yml id:prices

    - define allItems <list[]>
    - define market <server.flag[economy.markets.<[marketName]>]>
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
    #TODO: Remove this line before going into prod.
    - flag <[merchant]> merchantData.supply:!

    - define iterations 0

    #- run FlagVisualizer def.flag:<[qControlledItems]> def.flagName:qControlled

    - run MarketDemandScript path:MarketAnalysisGenerator def.market:<[marketName]> save:demandInfo
    - define demandInfo <entry[demandInfo].created_queue.determination.get[1]>
    - define sortedItemDemand <[demandInfo].get[items].to_pair_lists.sort_by_value[get[2].get[saleToAmountRatio]]>

    - foreach <[qControlledItems]> as:item:
        - if !<server.flag[economy.markets.<[marketName]>.supplyMap.current].keys.contains[<[item].get[name]>]>:
            - foreach next

        - define base <[item].get[base]>
        - define balance <[merchant].flag[merchantData.balance]>
        - define availableSupply <server.flag[economy.markets.<[marketName]>.supplyMap.current.<[item].get[name]>]>
        - define spendableBalance <[balance].mul[<util.random.decimal[<[sBias]>].to[1]>]>
        - define reasonablePurchaseAmount <[spendableBalance].div[<[itemAmount]>].div[<[base]>].round>
        - define supplyPrice <[reasonablePurchaseAmount].mul[<[base].mul[<[supplyPriceMod]>]>]>

        # - narrate format:debug ----------------------
        # - narrate format:debug ITM:<[item].get[name]>
        # - narrate format:debug RPA:<[reasonablePurchaseAmount]>
        # - narrate format:debug PRI:<[supplyPrice]>
        # - narrate format:debug AVI:<[availableSupply]>
        # - narrate format:debug SPB:<[spendableBalance]>
        # - narrate format:debug ----------------------

        # Only tries to buy anything if there is supply in the supply matrix
        - if <[spendableBalance].is[OR_MORE].than[<[supplyPrice]>]> && <[availableSupply]> > 0:

            # Rescales the amount that the merchant wants to purchase if the amount in the supply
            # matrix is less than the original purchase amount
            - if <[reasonablePurchaseAmount]> > <[availableSupply]>:
                # Purchase multiplier equation:
                # m = (3a / sqrt(r/a) * 4r) ^ 2
                # where: a: availableBalance
                #        r: reasonablePurchaseAmount
                - define purchaseMultiplier <element[<[availableSupply].mul[3]>].div[<element[<[reasonablePurchaseAmount].div[<[availableSupply]>]>].sqrt.mul[4].mul[<[reasonablePurchaseAmount]>]>].power[2].add[0.2]>
                - define reasonablePurchaseAmount <[purchaseMultiplier].mul[<[availableSupply]>].round>

            # If there is market demand off which to base future purchases on then run the market
            # demand script (which only works with non-zero values, so that's why I'm doing my
            # checks over here).
            - if <[market].keys.contains[marketDemand]> && <[market].get[marketDemand].keys.contains[<[item]>]>:
                - foreach next

            - else:
                - flag <[merchant]> merchantData.balance:-:<[supplyPrice]>
                - flag <[merchant]> merchantData.supply.<[item].get[name]>.quantity:+:<[reasonablePurchaseAmount]>
                - flag <[merchant]> merchantData.supply.<[item].get[name]>.price:<[base]>
                - flag server economy.markets.<[marketName]>.supplyMap.current.<[item].get[name]>:-:<[reasonablePurchaseAmount]>

        - else:
            - foreach stop

        - define iterations:+:1

    - define realQBias <element[1].sub[<[qBias]>]>

    - foreach <[sortedItemDemand]>:
        - define itemName <[value].get[1]>
        - define itemAnalysis <[value].get[2]>
        - define trueBase <[allItems].get[<[itemName]>]>
        - define SAR <[itemAnalysis].get[saleToAmountRatio]>
        - define totalSold <[itemAnalysis].get[totalAmountItem]>
        - define lowest <[itemAnalysis].deep_get[sellPriceInfo.min]>
        - define stDev <[itemAnalysis].deep_get[sellPriceInfo.stDev]>
        - define highest <[itemAnalysis].deep_get[sellPriceInfo.max]>
        - define mean <[itemAnalysis].deep_get[sellPriceInfo.average]>
        - define availableSupply <server.flag[economy.markets.<[marketName]>.supplyMap.current.<[itemName]>]>

        # Demand amount response equation:
        # y.1 = 6 * sqrt(x + 49.57255xs ^ 2)
        - define amountReg <element[6].mul[<[totalSold].add[<element[49.57255].mul[<[totalSold].mul[<[SAR].power[2]>]>]>].sqrt>]>

        # Demand amount response randomization maximum:
        # y.2 = (0.8 + s) * 1.6 * y.1 + y.1^s
        - define amountMax <element[0.8].add[<[SAR]>].mul[1.6].mul[<[amountReg]>].add[<[amountReg].power[<[SAR]>]>]>

        # Demand amount response randomization minimum:
        # y.3 = abs(y.1 - y.2 / 3)
        - define amountMin <element[<[amountReg].sub[<[amountMax]>]>].div[3].abs>

        # Adjusting the minimum value by multiplying it by the merchant's qBias to narrow the
        # randomization space.
        - define qAdjustedMin <[amountMin].mul[<[realQBias].add[1]>].round>
        - define reasonablePurchaseAmount <util.random.int[<[qAdjustedMin]>].to[<util.random.int[<[amountReg].round>].to[<[amountMax].round>]>]>

        - narrate format:debug ITM_DEM:<[itemName]>
        - narrate format:debug PUR_ORI:<[reasonablePurchaseAmount]>

        - if <[reasonablePurchaseAmount]> > <[availableSupply]>:
            # Purchase multiplier equation:
            # m = (3a / sqrt(r/a) * 4r) ^ 2
            # where: a: availableBalance
            #        r: reasonablePurchaseAmount
            - define purchaseMultiplier <element[<[availableSupply].mul[3]>].div[<element[<[reasonablePurchaseAmount].div[<[availableSupply]>]>].sqrt.mul[4].mul[<[reasonablePurchaseAmount]>]>].power[2].add[0.2]>
            - define reasonablePurchaseAmount <[purchaseMultiplier].mul[<[availableSupply]>].round>

        # The combined price of all the purchased item as sold by the static supplier price
        - define supplyPrice <[allItems].deep_get[<[itemName]>.base].mul[<[reasonablePurchaseAmount]>]>

        # Demand price response equation:
        # y.1 = x * (0.66 + s)^2 * h / 1.15l
        - define priceReg <[mean].mul[<element[0.66].add[<[SAR]>].power[2]>].mul[<element[<[highest].div[<element[1.15].mul[<[lowest]>]>]>]>]>

        # Demand price response randomization maximum:
        # y.2 = (0.2 + s) * x + y.1
        - define priceMax <element[0.2].add[<[SAR]>].mul[<[mean]>].add[<[priceReg]>]>

        - if <[SAR].is[OR_LESS].than[0.34]>:
            # Demand price response randomization minimum:
            # y.3 = (0.5s - 0.19) * x + y.1
            - define priceMin <[SAR].mul[0.5].sub[0.19].mul[<[mean]>].add[<[priceReg]>]>

            # Adjusting the minimum value by multiplying it by the merchant's sBias to narrow the
            # randomization space.
            - define sAdjustedMin <[priceMin].mul[<[sBias].add[1]>]>
            - define newSellPrice <util.random.decimal[<util.random.decimal[<[sAdjustedMin]>].to[<[priceReg]>]>].to[<[priceMax]>].round_to_precision[0.025]>

        - else:
            - define newSellPrice <util.random.decimal[<[priceReg]>].to[<[priceMax]>]>

        - narrate format:debug PUR_NEW:<[reasonablePurchaseAmount]>
        - narrate format:debug SEL_ORI:<[mean]>
        - narrate format:debug SEL_NEW:<[newSellPrice]>
        - narrate format:debug ----------------------------------

        - flag <[merchant]> merchantData.balance:-:<[supplyPrice]>
        - flag <[merchant]> merchantData.supply.<[item].get[name]>.quantity:+:<[reasonablePurchaseAmount]>
        - flag <[merchant]> merchantData.supply.<[item].get[name]>.price:<[newSellPrice]>
        - flag server economy.markets.<[marketName]>.supplyMap.current.<[item].get[name]>:-:<[reasonablePurchaseAmount]>

    # - narrate format:debug SPM:<[supplyPriceMod]>
    # - narrate format:debug SPEN:<[spendableBalance]>

    - yaml id:prices unload


MarketDemandScript:
    type: task
    definitions: price|item|amount|merchant|player|market
    StandardDevCalculator:
    - define n <[marketDemand].get[<[item]>].size>
    - define sum 0

    - foreach <[allPrices]> as:price:
        - define sum:+:<[price].sub[<[averageSellPrice]>].power[2]>

    - define stDev <[sum].div[<[n]>].sqrt>

    ## DEFS REQUIRED: ITEM, MARKET
    ItemAnalysisGenerator:
    - define supplyAmounts <server.flag[economy.markets.<[market]>.supplyMap.original]>
    - define marketDemand <server.flag[economy.markets.<[market]>.marketDemand]>

    # This value is a ratio between the amount of an item that was sold in the past week
    # and the average amount of that item that gets spawned in merchant inventories weekly
    - define saleToAmountRatio <element[<[marketDemand].deep_get[<[item]>.totalAmount].div[<[supplyAmounts].get[<[item]>]>]>]>
    - define allPrices <[marketDemand].deep_get[<[item]>.transactions].parse_tag[<[parse_value].get[price]>]>
    - define averageSellPrice <[allPrices].average>
    - inject MarketDemandScript path:StandardDevCalculator

    - definemap itemAnalysis:
        saleToAmountRatio: <[saleToAmountRatio].round_to_precision[0.0001]>
        totalAmountItem: <[marketDemand].deep_get[<[item]>.totalAmount]>
        totalValueItem: <[marketDemand].deep_get[<[item]>.totalValue]>
        sellPriceInfo:
            average: <[averageSellPrice]>
            stDev: <[stDev].round_to_precision[0.0001]>
            max: <[allPrices].highest>
            min: <[allPrices].lowest>

    - determine <[itemAnalysis]>

    ## DEFS REQUIRED: MARKET
    MarketAnalysisGenerator:
    - define marketDemand <server.flag[economy.markets.<[market]>.marketDemand]>
    - define marketAnalysis <map[]>
    - yaml load:economy_data/price-info.yml id:prices

    - foreach <[marketDemand].exclude[totalAmount|totalValue]> as:itemData key:itemName:
        - run MarketDemandScript path:ItemAnalysisGenerator def.market:<[market]> def.item:<[itemName]> save:ItemAnalysis
        - define itemAnalysis <entry[ItemAnalysis].created_queue.determination.get[1]>
        - define marketAnalysis.items.<[itemName]>:<[itemAnalysis]>
        - define marketAnalysis.totalAmount:<[marketDemand].get[totalAmount]>
        - define marketAnalysis.totalValue:<[marketDemand].get[totalValue]>

    #- run FlagVisualizer def.flag:<[marketAnalysis]> "def.flagName:Kowalski, Analysis"
    - determine <[marketAnalysis]>

    #TODO: Finish full analysis -- generate a unified value that helps inform NPC buying patterns.

    script:
    - define marketDemandItem <server.flag[economy.markets.<[market]>.marketDemand.<[item]>.transactions]>
    - define containsSameItem <[marketDemandItem].parse_tag[<[parse_value].exclude[amount]>].contains[<map[price=<[price]>;merchant=<[merchant]>]>]>

    # - narrate format:debug CSI:<[containsSameItem]>
    # - narrate format:debug MDI:<[marketDemandItem]>

    - if <[containsSameItem]>:
        - define sameItemIndex <[marketDemandItem].parse_tag[<[parse_value].exclude[amount]>].find[<map[price=<[price]>;amount=<[amount]>;merchant=<[merchant]>]>]>
        - define newAmount <[marketDemandItem].get[<[sameItemIndex]>].get[amount].add[1]>
        - flag server economy.markets.<[market]>.marketDemand.<[item]>.transactions:<[marketDemandItem].overwrite[<map[price=<[price]>;amount=<[newAmount]>;merchant=<[merchant]>]>].at[<[sameItemIndex]>]>

    - else:
        - flag server economy.markets.<[market]>.marketDemand.<[item]>.transactions:->:<map[price=<[price]>;amount=<[amount]>;merchant=<[merchant].as[entity]>]>

    - flag server economy.markets.<[market]>.marketDemand.totalAmount:+:<[amount]>
    - flag server economy.markets.<[market]>.marketDemand.totalValue:+:<[price]>
    - flag server economy.markets.<[market]>.marketDemand.<[item]>.totalAmount:+:<[amount]>
    - flag server economy.markets.<[market]>.marketDemand.<[item]>.totalValue:+:<[price]>


## Save previous market tendancies to YAML perhaps also save along with it global market demand
## figures for analysis by blackmarket factions or other omni-present economic forces.
# MarketDemandHandler:
#     type: world
#     events:
#         on system time hourly every:24:
#         - foreach <server.flag[economy.markets].keys> as:market:
#             - flag server economy.markets.<[market]>.marketDemand:!