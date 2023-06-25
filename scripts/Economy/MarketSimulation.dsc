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
    definitions: marketName|merchant
    CalculateCloseness:
    - define merchantData <[merchant].flag[merchantData]>
    - define closenessMap <map[]>

    - foreach <[strategyQuals]> key:strat as:stratInfo:
        - define stratCloseness 0

        - foreach <[stratInfo]>:
            - define realStat <[merchantData].get[<[key]>]>

            - if <[realStat].is_decimal>:
                - define val <list[min|<[value].get[min]>]>
                - define val <list[max|<[value].get[max]>]> if:<[value].contains[max]>
                - define val <list[is|<[value].get[is]>]> if:<[value].contains[is]>

                - if <[val].get[2]> < <[realStat]>:
                    - define closeness <[val].get[2].div[<[realStat]>].round_to_precision[0.0001]>

                - else:
                    - define closeness <[realStat].div[<[val].get[2]>].round_to_precision[0.0001]>

                - if <[val].get[1]> == is:
                    - define tolerance <[value].get[tolerance].if_null[0]>
                    - define valFrac <[val].get[2].mul[0.1]>
                    - define rangeLow <[val].get[2].sub[<[valFrac].mul[<[tolerance]>]>]>
                    - define rangeHigh <[val].get[2].add[<[valFrac].mul[<[tolerance]>]>]>

                    # Check how close the real stat is to both the high and low end of the estimate
                    # and take an average of the two
                    - if <[realStat]> > <[val].get[2]>:
                        - define closenessLow <[rangeLow].div[<[realStat]>]>
                        - define closenessHigh <[rangeHigh].div[<[realStat]>]>

                    - else:
                        - define closenessLow <[realStat].div[<[rangeLow]>]>
                        - define closenessHigh <[realStat].div[<[rangeHigh]>]>

                    - define compositeCloseness <[closenessHigh].add[<[closenessLow]>].div[2]>
                    - define closenessMap.<[strat]>.<[key]>:<[compositeCloseness].round_to_precision[0.0001]>
                    - define stratCloseness:+:<[compositeCloseness]>

                - else if <[val].get[1]> == max:
                    - define closenessMap.<[strat]>.<[key]>:<[closeness]>
                    - define closeness 0 if:<[realStat].is[MORE].than[<[val].get[2]>]>

                    # Closeness will always be 0 if it is higher than the maximum...
                    - define closenessMap.<[strat]>.<[key]>:<[closeness]>
                    - define stratCloseness:+:<[closeness]>

                - else if <[val].get[1]> == min:
                    - define closenessMap.<[strat]>.<[key]>:<[closeness]>
                    - define closeness 0 if:<[realStat].is[LESS].than[<[val].get[2]>]>

                    # ...or lower than the minimum
                    - define closenessMap.<[strat]>.<[key]>:<[closeness]>
                    - define stratCloseness:+:<[closeness]>

        # Calculate the total closeness for the entire strategy by taking the average of all the
        # individual stats' closeness
        - define stratCloseness <[stratCloseness].div[<[stratInfo].size>]>
        - define closenessMap.<[strat]>.totalCloseness:<[stratCloseness].round_to_precision[0.0001]>

    script:
    - yaml load:economy_data/price-info.yml id:prices

    - define allItems <list[]>
    - define market <server.flag[economy.markets.<[marketName]>]>
    - define spec <[merchant].flag[merchantData.spec]>
    - define balance <[merchant].flag[merchantData.balance]>
    - define wealth <[merchant].flag[merchantData.wealth]>
    - define sBias <[merchant].flag[merchantData.spendBias]>
    - define supplyPriceMod <[market].get[supplierPriceMod]>
    - define qBias <[merchant].flag[merchantData.quantityBias].round_to_precision[0.05]>
    - define qBias:+:0.05 if:<[qBias].equals[0]>

    - if <[spec]> == null || !<[spec].exists>:
        - define group items
        - define allItemsRaw <yaml[prices].read[price_info.<[group]>]>

        - foreach <[allItemsRaw]> as:group:
            - foreach <[group]> as:item key:itemName:
                - define allItems:->:<[item].include[<map[name=<[itemName]>]>]>

    - else:
        - define group items.<[spec]>
        - define allItemsRaw <yaml[prices].read[price_info.<[group]>]>

        - foreach <[allItemsRaw]> as:item key:itemName:
            - define allItems:->:<[item].include[<map[name=<[itemName]>]>]>

    # - narrate format:debug <[group]>

    - define strategyQuals <script[MerchantStrategy_Qualifiers].data_key[strategy_list]>
    - inject <script.name> path:CalculateCloseness

    - run FlagVisualizer def.flag:<[closenessMap]> def.flagName:closenessMap

    - definemap closestStrat:
        name: null
        closeness: 0

    - foreach <[closenessMap]> key:strat as:info:
        - define stratCloseness <[info].get[totalCloseness]>

        - if <[stratCloseness]> > <[closestStrat].get[closeness]>:
            - define closestStrat.closeness:<[stratCloseness]>
            - define closestStrat.name:<[strat]>


    - define strategyBehaviour <script[MerchantStrategy_Behaviour].data_key[strategy_list.<[closestStrat].get[name]>]>
    - define strategyLoopIter <[strategyBehaviour].get[loop_iterations].if_null[2]>
    - define strategyLoopIter 7 if:<[strategyLoopIter].is[MORE].than[7]>

    - define strategyPriceBias <[strategyBehaviour].deep_get[price_filter.bias].if_null[0.5]>
    - define priceFilterLow <[strategyBehaviour].deep_get[price_filter.low].if_null[0]>
    - define priceFilterHigh <[strategyBehaviour].deep_get[price_filter.high].if_null[1000]>
    - define priceControlledItems <[allItems].filter_tag[<[filter_value].get[base].is[OR_LESS].than[<[priceFilterHigh]>].and[<[filter_value].get[base].is[OR_MORE].than[<[priceFilterLow]>]>]>].sort_by_value[get[base]]>

    # - narrate format:debug ALL:<[allItems]>
    #- narrate format:debug PCI_OLD:<[priceControlledItems]>

    - if <[priceControlledItems].size> < 2:
        - define allItemsSorted <[allItems].sort_by_value[get[base]]>
        - define allPrices <[allItemsSorted].parse_tag[<[parse_value].get[base]>]>

        - if <[strategyBehaviour].contains[price_shift]>:
            - define strategyPriceBias <[strategyBehaviour].get[price_shift]>

        # Regenerate priceFilter based on the item group's max and min prices.
        # Depending on whether price_shift was ommitted, this will be scaled based on either
        # price_filter.bias or price_shift
        - define priceFilterLow <[allPrices].lowest.mul[<[strategyPriceBias]>]>
        - define priceFilterHigh <[allPrices].highest.mul[<[strategyPriceBias]>]>

        # Regenerate PCI
        - define priceControlledItems <[allItems].filter_tag[<[filter_value].get[base].is[OR_LESS].than[<[priceFilterHigh]>].and[<[filter_value].get[base].is[OR_MORE].than[<[priceFilterLow]>]>]>].sort_by_value[get[base]]>

    # - narrate format:debug PFL:<[priceFilterLow]>
    # - narrate format:debug PFH:<[priceFilterHigh]>

    - define priceBiasThreshold <[priceControlledItems].size.mul[<[strategyPriceBias]>].round>
    - define afterThresholdItems <[priceControlledItems].get[<[priceBiasThreshold]>].to[last]>
    - define newFirstItemIndex <[priceBiasThreshold].sub[<[afterThresholdItems].size>]>
    - define newFirstItemIndex 0 if:<[newFirstItem].is[LESS].than[0]>
    - define beforeThresholdItems <[priceControlledItems].get[<[newFirstItemIndex]>].to[<[priceBiasThreshold]>]>

    # - narrate format:debug PBT:<[priceBiasThreshold]>
    # - narrate format:debug ATI:<[afterThresholdItems]>
    # - narrate format:debug BTI:<[beforeThresholdItems]>

    - define biasControlledItems <[beforeThresholdItems].include[<[afterThresholdItems]>]>
    - define itemAmount <[biasControlledItems].size>
    - define originalBalance <[merchant].flag[merchantData.balance]>
    - define originalSpendableBalance <[balance].mul[<util.random.decimal[<[sBias]>].to[1]>]>
    - define iterations 0

    # - run FlagVisualizer def.flagName:BCI_NEW def.flag:<[biasControlledItems]>

    # - narrate format:debug BAL:<[balance]>
    # - narrate format:debug COR_BAL:<[merchant].flag[merchantData.balance].sub[<[originalBalance].div[50]>]>
    # - narrate format:debug STR:<[strategyLoopIter]>

    - while <[iterations]> < <[strategyLoopIter]> && <[merchant].flag[merchantData.balance].sub[<[originalBalance].div[50]>]> > <[originalBalance].sub[<[originalSpendableBalance]>]>:
        - foreach <[biasControlledItems].random[<[biasControlledItems].size>]> as:item:
            - if !<server.flag[economy.markets.<[marketName]>.supplyMap.current].keys.contains[<[item].get[name]>]>:
                - foreach next

            - define base <[item].get[base]>
            - define balance <[merchant].flag[merchantData.balance]>
            - define availableSupply <server.flag[economy.markets.<[marketName]>.supplyMap.current.<[item].get[name]>]>
            - define spendableBalance <[balance].mul[<util.random.decimal[<[sBias]>].to[1]>]>

            # Buy Multiplier Equation:
            # y = (xs / 2i) + (s / i) + 0.45
            # where: x = current item index
            #        s = sBias
            #        i = total items in BCI
            - define purchaseAmountMultiplier <element[<[loop_index].mul[<[sBias]>]>].div[<[biasControlledItems].size.mul[2]>].add[<[sBias].div[<[biasControlledItems].size.mul[2]>]>].add[0.45]>

            - define reasonablePurchaseAmount <[spendableBalance].div[<[base].div[<[itemAmount]>]>].power[0.37].round>
            - define reasonablePurchaseAmount <[reasonablePurchaseAmount].mul[<[purchaseAmountMultiplier]>].round>
            - define supplyPrice <[reasonablePurchaseAmount].mul[<[base].mul[<[supplyPriceMod]>]>]>

            - if <[spendableBalance].is[LESS].than[<[supplyPrice]>]>:
                - foreach next

            # Only tries to buy anything if there is supply in the supply matrix
            - if <[availableSupply]> > 0:
                # - narrate format:debug RPA_OLD:<[reasonablePurchaseAmount]>

                # Rescales the amount that the merchant wants to purchase if the amount in the supply
                # matrix is less than the original purchase amount
                - if <[reasonablePurchaseAmount]> > <[availableSupply]>:
                    # Purchase multiplier equation:
                    # y = round(x / (r / 20))
                    # where: r = reasonablePurchaseAmount
                    #        x = availableSupply
                    - define reasonablePurchaseAmount <[availableSupply].div[<element[<[reasonablePurchaseAmount].div[20]>]>].round>

                # If there is market demand off which to base future purchases on then run the market
                # demand script (which only works with non-zero values, so that's why I'm doing my
                # checks over here).
                - if <[market].keys.contains[marketDemand]> && <[market].get[marketDemand].keys.contains[<[item]>]>:
                    - foreach next

                - else if <[reasonablePurchaseAmount]> > 0:
                    - flag <[merchant]> merchantData.balance:-:<[supplyPrice]>
                    - flag <[merchant]> merchantData.supply.<[item].get[name]>.quantity:+:<[reasonablePurchaseAmount].round>
                    - flag <[merchant]> merchantData.supply.<[item].get[name]>.price:<[base]>
                    - flag server economy.markets.<[marketName]>.supplyMap.current.<[item].get[name]>:-:<[reasonablePurchaseAmount].round>
                    # - narrate format:debug "ADDED <[reasonablePurchaseAmount].round> OF <[item].get[name]> FOR $<[supplyPrice].round_to_precision[0.001]>"

            - else:
                - foreach next

            # - narrate format:debug -------------------------------

        - define iterations:++

    - flag <[merchant]> cachedInterface:!

    - run MarketDemandScript path:MarketAnalysisGenerator def.market:<[marketName]> save:demandInfo
    - define demandInfo <entry[demandInfo].created_queue.determination.get[1]>
    - define sortedItemDemand <[demandInfo].get[items].to_pair_lists.sort_by_value[get[2].get[saleToAmountRatio]]>

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
        - define qAdjustedMin <[amountMin].mul[<[qBias].add[1]>].round>
        - define reasonablePurchaseAmount <util.random.int[<[qAdjustedMin]>].to[<util.random.int[<[amountReg].round>].to[<[amountMax].round>]>]>

        # - narrate format:debug ITM_DEM:<[itemName]>
        # - narrate format:debug PUR_ORI:<[reasonablePurchaseAmount]>

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

        # - narrate format:debug PUR_NEW:<[reasonablePurchaseAmount]>
        # - narrate format:debug SEL_ORI:<[mean]>
        # - narrate format:debug SEL_NEW:<[newSellPrice]>
        # - narrate format:debug ----------------------------------

        - flag <[merchant]> merchantData.balance:-:<[supplyPrice]>
        - flag <[merchant]> merchantData.supply.<[itemName]>.quantity:+:<[reasonablePurchaseAmount]>
        - flag <[merchant]> merchantData.supply.<[itemName]>.price:<[newSellPrice]>
        - flag <[merchant]> merchantData.supply.<[itemName]>.lastWeekAvg:<[mean]>
        - flag server economy.markets.<[marketName]>.supplyMap.current.<[item].get[name]>:-:<[reasonablePurchaseAmount]>

    # - narrate format:debug SPM:<[supplyPriceMod]>
    # - narrate format:debug SPEN:<[spendableBalance]>

    - yaml id:prices unload


MerchantSellDecider:
    type: task
    definitions: merchant|marketName
    AnalyzeOneDay:
    - define sellAttractivenessIndex <map[]>
    - define marketTotalValue <[data].get[totalValue]>

    - foreach <[data].get[items]> as:item key:itemName:
        - if !<[itemName].is_in[<[merchant].flag[merchantData.supply].keys>]>:
            - foreach next

        - define SAR <[item].get[saleToAmountRatio]>
        - define totalValue <[item].get[totalValueItem]>
        - define totalAmount <[item].get[totalAmountItem]>
        - define adjustedStDev <[totalAmount].div[<[item].deep_get[sellPriceInfo.stDev]>]>
        - define adjustedStDev 0 if:<[adjustedStDev].equals[infinity]>

        # Sell attractiveness equation:
        # x = (20yv) / t * (d + 1)
        # where: y: SAR
        #        v: totalValue
        #        t: marketTotalValue
        #        d: adjustedStDev
        - define sellAttractiveness <element[<[SAR].mul[<[totalValue]>].mul[20]>].div[<element[<[adjustedStDev].add[1]>].mul[<[marketTotalValue]>]>]>
        - define sellAttractivenessIndex.<[itemName]>:<[sellAttractiveness].round_to_precision[0.0001]>

    - define SAR:!
    - define totalValue:!
    - define totalAmount:!
    - define adjustedStDev:!

    AnalyzeOldData:
    # Note: You could do something liek checking which items have been sold that day and then
    #       just doing a general calculation using the overall SAR and then add a certain flat
    #       value to to the attractiveness of every item that was sold that day
    - narrate WIP

    script:
    - yaml load:economy_data/past-economy-data.yml id:p
    - define marketFilteredRecentData <yaml[p].read[past_data.recent].as[map].parse_value_tag[<[parse_value].get[<[marketName]>]>]>
    - define marketFilteredOldData <yaml[p].read[past_data.old].as[map].parse_value_tag[<[parse_value].get[<[marketName]>]>].if_null[null]>
    - define grandTotalValue 0
    - define grandTotalAmount 0

    - if <[marketFilteredRecentData].is_empty>:
        - determine cancelled

    - if <yaml[p].contains[past_data.old]> || <[marketFilteredOldData]> != null:
        - inject <script.name> path:AnalyzeOldData

    - define overallSAI <map[]>

    - foreach <[marketFilteredRecentData]> as:data:
        - define grandTotalValue:+:<[data].get[totalValue]>
        - define grandTotalAmount:+:<[data].get[totalAmount]>

        - inject <script.name> path:AnalyzeOneDay

        - define overallSAI <[overallSAI].parse_value_tag[<[parse_value].add[<[sellAttractivenessIndex].get[<[parse_key]>]>]>]>
        - define overallSAI <[sellAttractivenessIndex]> if:<[overallSAI].is_empty>

    - yaml id:p unload

    - define overallSAI <[overallSAI].parse_value_tag[<[parse_value].div[<[marketFilteredRecentData].size>]>]>

    # TODO: Do some analysis on the old data that would generated from path:AnalyzeOldData

    - run flagvisualizer def.flag:<[overallSAI]> def.flagName:overall

    - define sBias <[merchant].flag[merchantData.spendBias]>

    - foreach <[overallSAI]> as:index:
        ##
        ## BIG NOTE: If ever you need to add large world economic events like financial crashes etc.
        ##           and you need it to impact the way that merchants price their goods this is
        ##           where you would modify that. VVV
        ##
        - define buyPrice <[merchant].flag[merchantData.supply.<[key]>.price]>
        - define sellPrice <[buyPrice].mul[<element[1].sub[<[sBias].div[2]>]>].round_up_to_precision[0.05]>

        - flag <[merchant]> merchantData.sellData.items.<[key]>.alloc:<[merchant].flag[merchantData.balance].mul[<[index]>]>
        - flag <[merchant]> merchantData.sellData.items.<[key]>.spent:0
        - flag <[merchant]> merchantData.sellData.items.<[key]>.price:<[sellPrice]>


MarketDemandScript:
    type: task
    definitions: price|item|amount|merchant|player|market|mode
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
    ## NOTE: Uncomment when you introduce new transaction scheme
    #- define allPrices <[marketDemand].deep_get[<[item]>.transactions].parse_tag[<[parse_value].deep_get[buy.price]>].if_null[null]>
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

    - determine <[marketAnalysis]>

    script:
    - define mode <[mode].if_null[buy]>

    - if <[mode]> == buy:
        - define transactions <server.flag[economy.markets.<[market]>.marketDemand.<[item]>.transactions.<[mode]>]>
        - define transactionIndex <[transactions].parse_tag[<[parse_value].exclude[amount]>].find[<map[price=<[price]>;merchant=<[merchant]>]>]>

        - if <[transactionIndex]> != -1:
            - define transaction <[transactions].get[<[transactionIndex]>]>
            - define transaction.amount:+:<[amount]>
            - flag server economy.markets.<[market]>.marketDemand.<[item]>.transactions.buy:<[transactions].overwrite[<[transaction]>].at[<[transactionIndex]>]>

        - else:
            - flag server economy.markets.<[market]>.marketDemand.<[item]>.transactions.buy:->:<map[price=<[price]>;amount=<[amount]>;merchant=<[merchant].as[entity]>]>

        - flag server economy.markets.<[market]>.marketDemand.totalAmount:+:<[amount]>
        - flag server economy.markets.<[market]>.marketDemand.totalValue:+:<[price]>
        - flag server economy.markets.<[market]>.marketDemand.<[item]>.totalAmount:+:<[amount]>
        - flag server economy.markets.<[market]>.marketDemand.<[item]>.totalValue:+:<[price]>

    - else:
        - define transactions <server.flag[economy.markets.<[market]>.sellData.<[item]>.transactions.<[mode]>]>
        - define transactionIndex <[transactions].parse_tag[<[parse_value].exclude[amount]>].find[<map[price=<[price]>;merchant=<[merchant]>]>]>

        - if <[transactionIndex]> != -1:
            - define transaction <[transactions].get[<[transactionIndex]>]>
            - define transaction.amount:+:<[amount]>
            - flag server economy.markets.<[market]>.sellData.<[item]>.transactions.sell:<[transactions].overwrite[<[transaction]>].at[<[transactionIndex]>]>

        - else:
            - flag server economy.markets.<[market]>.sellData.<[item]>.transactions.sell:->:<map[price=<[price]>;amount=<[amount]>;merchant=<[merchant].as[entity]>]>

        - flag server economy.markets.<[market]>.sellData.totalAmount:+:<[amount]>
        - flag server economy.markets.<[market]>.sellData.totalValue:+:<[price]>
        - flag server economy.markets.<[market]>.sellData.<[item]>.totalAmount:+:<[amount]>
        - flag server economy.markets.<[market]>.sellData.<[item]>.totalValue:+:<[price]>


OldMarketDataRecorder:
    type: task
    AppendQueue:
    - define joinedQueue <[queue].get[recent].include[<[stack].get[old]>]>
    - define lastItemIndex <[joinedQueue].keys.highest>
    - define firstItemIndex <[joinedQueue].keys.lowest>
    - define tempNewQueue <map[]>
    - define newQueue <map[]>

    - foreach <[joinedQueue]>:
        - define tempNewQueue.<[key].add[1]>:<[value]>

    - define tempNewQueue.<[lastItemIndex]>:!
    - define tempNewQueue.1:<[allMarketsMap]>

    - if <[tempNewQueue].size> > <[recentMaxQueueSize]>:
        - foreach <[tempNewQueue].get[<[recentMaxQueueSize].add[1]>]> as:market:
            - define marketDemand <[market].get[market_demand]>
            - run GenerateOldData def.marketAnalysis:<[marketDemand]> save:old_data_format
            - define generatedOldData <entry[old_data_format].created_queue.determination.get[1]>
            - define tempNewQueue.<[recentMaxQueueSize].add[1]>.<[key]>:<[generatedOldData]>

        - define newQueue.recent:<[tempNewQueue].parse_value_tag[<[parse_key].is[OR_LESS].than[<[recentMaxQueueSize]>]>]>
        - define newQueue.old:<[tempNewQueue].parse_value_tag[<[parse_key].is[MORE].than[<[recentMaxQueueSize]>]>]>
        - define tempNewQueue:!

    - else:
        - define newQueue.recent:<[tempNewQueue]>
        - define tempNewQueue:!

    - run flagvisualizer def.flag:<[newQueue]> def.flagName:newQueue

    # TODO: Write RefreshQueue/CheckQueueIntegrity which makes sure the past data queue remains in
    # TODO/ the correct format.

    script:
    - define allMarketsMap <map[]>
    - yaml load:economy_data/past-economy-data.yml id:past
    # Note: future confirgurables
    - define recentMaxQueueSize 7
    - define maxQueueSize 31

    - foreach <server.flag[economy.markets].keys> as:market:
        - run MarketDemandScript path:MarketAnalysisGenerator def.market:<[market]> save:analysis
        - define marketAnalysis <entry[analysis].created_queue.determination.get[1]>
        - define marketTotals <[marketAnalysis].get_subset[totalValue|totalAmount]>
        - define marketAnalysis <[marketAnalysis].get[items].parse_value_tag[<[parse_value].deep_exclude[sellPriceInfo.max|sellPriceInfo.min]>]>
        - define allMarketsMap.<[market]>.items:<[marketAnalysis]>
        - define allMarketsMap.<[market]>:<[allMarketsMap].get[<[market]>].include[<[marketTotals]>]>
        - define marketTotals:!

    - run flagvisualizer def.flag:<[allMarketsMap]> "def.flagName:Kowalski, Analysis"

    - if <yaml[past].contains[past_data.recent]>:
        - inject <script.name> path:AppendQueue

    - else:
        - define recentQueueSize <yaml[past].read[past_data.recent].size.if_null[0]>
        - yaml id:past set past_data.recent.<[recentQueueSize].add[1]>:<[allMarketsMap]>

    - yaml id:past savefile:economy_data/past-economy-data.yml
    - yaml id:past unload

    - narrate format:debug Saved!


GenerateOldData:
    type: task
    definitions: marketAnalysis
    script:
    - define SARMap <[marketAnalysis].get[items].parse_value_tag[<[parse_value].get[saleToAmountRatio]>]>
    - define SARList <[SARMap].values>
    - define oSAR <[SARList].average>
    - define itemsSold <[marketAnalysis].keys>
    - define totalValue <[marketAnalysis].get[totalValue]>
    - define totalAmount <[marketAnalysis].get[totalAmount]>
    - define averagePrice <[totalValue].div[<[totalAmount]>]>

    - definemap marketMap:
        total_amount: <[totalAmount]>
        total_value: <[totalValue]>
        avg_price: <[averagePrice]>
        o_sar: <[oSAR]>
        items_sold: <[itemsSold]>


## Save previous market tendancies to YAML perhaps also save along with it global market demand
## figures for analysis by blackmarket factions or other omni-present economic forces.
MarketDemandHandler:
    type: world
    events:
        on system time hourly every:24:
        - run OldMarketDataRecorder

        - foreach <server.flag[economy.markets].keys> as:market:
            - flag server economy.markets.<[market]>.marketDemand:!
