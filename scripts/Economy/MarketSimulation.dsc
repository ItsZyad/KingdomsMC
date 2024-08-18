##
## Contains all scripts relating to the daily simulation of the Kingdoms markets system.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Sep 2023
## @Updated: May 2024
## @Script Ver: v3.0
##
## ------------------------------------------END HEADER-------------------------------------------

AssignPurchaseStrategy:
    type: task
    definitions: merchant[NPCTag]
    description:
    - Assigns the given merchant an appropriate item purchase strategy based on its biases, wealth and balance by modifying its merchantData flag with an assignedStrategy sub-flag.
    - ---
    - → [Void]

    script:
    ## Assigns the given merchant an appropriate item purchase strategy based on its biases, wealth
    ## and balance by modifying its merchantData flag with an assignedStrategy sub-flag.
    ##
    ## merchant : [NPCTag]
    ##
    ## >>> [Void]

    - define strategyQuals <script[MerchantStrategy_Qualifiers].data_key[strategy_list]>
    - define merchantData <[merchant].flag[merchantData]>
    - define closenessMap <map[]>

    - foreach <[strategyQuals]> key:strat as:stratInfo:
        - define stratCloseness 0

        - foreach <[stratInfo]>:
            - define realStat <[merchantData].get[<[key]>]>

            - if <[realStat].is_decimal>:
                - define val <list[min|<[value].get[min]>]> if:<[value].contains[min]>
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

    - definemap closestStrat:
        name: null
        closeness: 0

    - foreach <[closenessMap]> key:strat as:info:
        - define stratCloseness <[info].get[totalCloseness]>

        - if <[stratCloseness]> > <[closestStrat].get[closeness]>:
            - define closestStrat.closeness:<[stratCloseness]>
            - define closestStrat.name:<[strat]>

    - flag <[merchant]> merchantData.assignedStrategy:<[closestStrat]>


MerchantPurchaseDecider:
    type: task
    debug: false
    definitions: marketName[ElementTag(String)]|merchant[NPCTag]
    script:
    ## Uses the given merchant's chosen strategy, past market demand, and sale data if they exist.
    ## If no past market data exists, it will simply assign the merchant items and prices based on
    ## how they show up in price-info.yml
    ##
    ## marketName : [ElementTag<String>]
    ## merchant   : [NPCTag]

    - yaml load:economy_data/worth.yml id:worth

    - narrate format:admincallout "Generating Market Items..."

    - define allItems <list[]>
    - define market <server.flag[economy.markets.<[marketName]>]>
    - define spec <[merchant].flag[merchantData.spec]>
    - define balance <[merchant].flag[merchantData.balance]>
    - define sBias <[merchant].flag[merchantData.spendBias]>
    - define supplyPriceMod <[market].get[supplierPriceMod].if_null[1]>
    - define qBias <[merchant].flag[merchantData.quantityBias].round_to_precision[0.05]>
    - define qBias:+:0.05 if:<[qBias].equals[0]>

    - if <[spec]> == null || !<[spec].exists>:
        - narrate format:admincallout "Unable to generate items for merchant: <[merchant].color[red]>. Merchant does not have a specialization!"
        - stop

    - if !<server.has_flag[economy.itemCategories.<[spec]>]>:
        - narrate format:admincallout "Unable to generate items for merchant: <[merchant].color[red]>. Merchant specialization: <[spec].color[red]> is invalid!"
        - stop

    - foreach <server.flag[economy.itemCategories.<[spec]>.items]> as:item:
        - definemap itemMap:
            base: <yaml[worth].read[items.<[item]>.base]>
            name: <[item]>

        - define allItems:->:<[itemMap]>

    # - run flagvisualizer def.flag:<[allItems]> def.flagName:ALL

    - yaml id:worth unload

    - define closestStrat <[merchant].flag[merchantData.assignedStrategy]>
    - define strategyBehaviour <script[MerchantStrategy_Behaviour].data_key[strategy_list.<[closestStrat].get[name]>]>
    - define strategyLoopIter <[strategyBehaviour].get[loop_iterations].if_null[2]>
    - define strategyLoopIter 7 if:<[strategyLoopIter].is[MORE].than[7]>

    - define allItemsSorted <[allItems].sort_by_value[get[base]]>
    - define allPrices <[allItemsSorted].parse_tag[<[parse_value].get[base]>]>
    - define maxPrice <[allPrices].highest>

    - define strategyPriceBias <[strategyBehaviour].deep_get[price_filter.bias].if_null[0.5]>
    - define priceFilterLow <[strategyBehaviour].deep_get[price_filter.low].div[100].mul[<[allPrices].size>].round_down.add[1].if_null[1]>
    - define priceFilterHigh <[strategyBehaviour].deep_get[price_filter.high].div[100].mul[<[allPrices].size>].round.if_null[<[allPrices].size>]>
    - define priceControlledItems <[allItems].get[<[priceFilterLow]>].to[<[priceFilterHigh]>].sort_by_value[get[base]]>

    # - narrate format:debug MAX:<[maxPrice]>
    # - narrate format:debug AVG:<[allPrices].average.round_to_precision[0.001]>
    # - narrate format:debug PFL:<[priceFilterLow]>
    # - narrate format:debug PFH:<[priceFilterHigh]>

    # From the way I redesigned price filtering, this section shouldn't be needed anymore. But I
    # think I'll keep it around as a comment until I'm absolutely sure.
    # - if <[priceControlledItems].size> < 2:
    #     - if <[strategyBehaviour].contains[price_shift]>:
    #         - define strategyPriceBias <[strategyBehaviour].get[price_shift]>

    #     # Regenerate priceFilter based on the item group's max and min prices.
    #     # Depending on whether price_shift was ommitted, this will be scaled based on either
    #     # price_filter.bias or price_shift
    #     - define priceFilterLow <[allPrices].lowest.mul[<[strategyPriceBias]>]>
    #     - define priceFilterHigh <[allPrices].highest.mul[<[strategyPriceBias]>]>

    #     # Regenerate PCI
    #     - define priceControlledItems <[allItems].get[<[priceFilterLow]>].to[<[priceFilterHigh]>].sort_by_value[get[base]]>

    - define priceBiasThreshold <[priceControlledItems].size.mul[<[strategyPriceBias]>].round>
    - define afterThresholdItems <[priceControlledItems].get[<[priceBiasThreshold]>].to[last]>
    - define newFirstItemIndex <[priceBiasThreshold].sub[<[afterThresholdItems].size>]>
    - define newFirstItemIndex 1 if:<[newFirstItemIndex].is[OR_LESS].than[0]>
    - define beforeThresholdItems <[priceControlledItems].get[<[newFirstItemIndex]>].to[<[priceBiasThreshold]>]>

    - define biasControlledItems <[beforeThresholdItems].include[<[afterThresholdItems]>]>
    - define originalBalance <[merchant].flag[merchantData.balance]>
    - define originalSpendableBalance <[balance].mul[<util.random.decimal[<[sBias]>].to[1]>].mul[0.5]>

    # Duplicate items as per the chosen strategy's iterations value
    - repeat <[strategyLoopIter].sub[1]>:
        - define biasControlledItems <[biasControlledItems].include[<[biasControlledItems]>]>

    # Get market demand info if it exists
    - if <server.has_flag[economy.markets.<[marketName]>.buyData]>:
        - run PurchaseAnalysisGenerator def.market:<[marketName]> save:demandInfo
        - define sortedItemDemand <entry[demandInfo].created_queue.determination.get[1].get[items].to_pair_lists.sort_by_value[get[2].get[saleToAmountRatio]]>

    - else:
        - define sortedItemDemand <list[]>

    # - run flagvisualizer def.flag:<[sortedItemDemand].parse_tag[<[parse_value].get[1]>]> def.flagName:SID

    - foreach <[biasControlledItems].random[<[biasControlledItems].size>]> as:item:
        - define availableSupply <server.flag[economy.markets.<[marketName]>.supplyMap.current.<[item].get[name]>].if_null[0]>

        - if <[availableSupply]> <= 0:
            - foreach next

        # If the item has a demand history then skip; relegate to the demand price handler
        - if <[item].get[name].is_in[<[sortedItemDemand].parse_tag[<[parse_value].get[1]>]>]>:
            - define itemAnalysis <[sortedItemDemand].get[<[sortedItemDemand].parse_tag[<[parse_value].get[1]>].find[<[item].get[name]>]>].get[2]>
            - define SAR <[itemAnalysis].get[saleToAmountRatio]>
            - define totalSold <[itemAnalysis].get[totalAmountItem]>
            - define lowest <[itemAnalysis].deep_get[sellPriceInfo.min]>
            - define highest <[itemAnalysis].deep_get[sellPriceInfo.max]>
            - define mean <[itemAnalysis].deep_get[sellPriceInfo.average]>

            - inject <script.name> path:CalculateItemPurchaseAmount

            - if <[reasonablePurchaseAmount]> <= 0:
                - foreach next

            - inject <script.name> path:CalculatePurchasedItemsPrice

            - narrate format:admincallout "<light_purple>Adujsted Price Data For: <[item].get[name].color[red]>"
            - narrate format:admincallout "<green>quantity: <[reasonablePurchaseAmount].round>"
            - narrate format:admincallout "<blue>old price: <[merchant].flag[merchantData.supply.<[item].get[name]>.price]>"
            - narrate format:admincallout "<red>new price: <[newSellPrice]>"
            - narrate format:admincallout <gray>---------------------------

            - flag <[merchant]> merchantData.balance:-:<[supplyPrice]>
            - flag <[merchant]> merchantData.supply.<[item].get[name]>.quantity:+:<[reasonablePurchaseAmount].round>
            - flag <[merchant]> merchantData.supply.<[item].get[name]>.price:<[newSellPrice]>
            - flag server economy.markets.<[marketName]>.supplyMap.current.<[item].get[name]>:-:<[reasonablePurchaseAmount].round>

            - foreach next

        # If the balance drops below the point where the merchant's spend bias no longer allows
        # purchases, then skip
        - if <[merchant].flag[merchantData.balance].sub[<[originalBalance].div[50]>]> <= <[originalBalance].sub[<[originalSpendableBalance]>]>:
            - narrate format:debug "Merchant balance too low!"
            - foreach stop

        # If the market does not contain the current item then skip
        - if !<server.flag[economy.markets.<[marketName]>.supplyMap.current].keys.contains[<[item].get[name]>]>:
            - narrate format:debug "Market does not contain current item: <[item].get[name].color[white]>!"
            - foreach next

        # Initialize this loop's balance/sBias-affected balance values
        - define balance <[merchant].flag[merchantData.balance]>
        - define spendableBalance <[balance].mul[<util.random.decimal[<[sBias]>].to[1]>]>

        # Buy Multiplier Equation:
        # y = (xs / 2i) + (s / i) + 0.45
        # where: x = current item index
        #        s = sBias
        #        i = total items in BCI
        - define purchaseAmountMultiplier <element[<[loop_index].mul[<[sBias]>]>].div[<[biasControlledItems].size.mul[2]>].add[<[sBias].div[<[biasControlledItems].size.mul[2]>]>].add[0.45]>

        - define reasonablePurchaseAmount <[spendableBalance].div[<[item].get[base].div[<[biasControlledItems].size>]>].power[0.37].mul[<[purchaseAmountMultiplier]>].round>
        - define supplyPrice <[reasonablePurchaseAmount].mul[<[item].get[base].mul[<[supplyPriceMod]>]>]>

        # Rescales the amount that the merchant wants to purchase if the amount in the supply
        # matrix is less than the original purchase amount
        - if <[reasonablePurchaseAmount]> > <[availableSupply]>:

            # Purchase multiplier equation:
            # y = round(x / (r / 20))
            # where: r = reasonablePurchaseAmount
            #        x = availableSupply
            - define reasonablePurchaseAmount <[availableSupply].div[<element[<[reasonablePurchaseAmount].div[20]>]>].round>

        # If there is market demand off which to base future purchases on then run the market
        # demand script (which only works with non-zero values, so that's why I'm doing my checks
        # over here).
        - if <[market].keys.contains[marketDemand]> && <[market].get[marketDemand].keys.contains[<[item]>]>:
            - foreach next

        - else if <[reasonablePurchaseAmount]> > 0:
            - narrate format:admincallout "<gold>Adujsted Price Data For: <[item].get[name].color[red]>"
            - narrate format:admincallout "<green>quantity: <[reasonablePurchaseAmount].round>"
            - narrate format:admincallout "<red>price: <[item].get[base]>"
            - narrate format:admincallout <gray>---------------------------

            - flag <[merchant]> merchantData.balance:-:<[supplyPrice]>
            - flag <[merchant]> merchantData.supply.<[item].get[name]>.quantity:+:<[reasonablePurchaseAmount].round>
            - flag <[merchant]> merchantData.supply.<[item].get[name]>.price:<[item].get[base]>
            - flag server economy.markets.<[marketName]>.supplyMap.current.<[item].get[name]>:-:<[reasonablePurchaseAmount].round>

    # - run flagvisualizer def.flag:<[biasControlledItems]>
    - flag <[merchant]> cachedInterface:!

    CalculateItemPurchaseAmount:
    # Demand amount response equation:
    # y.1 = 6 * sqrt(x + 49.57255xs ^ 2)
    - define amountReg <element[6].mul[<[totalSold].add[<element[49.57255].mul[<[totalSold].mul[<[SAR].power[2]>]>]>].sqrt>]>

    # Demand amount response randomization maximum:
    # y.2 = (0.8 + s) * 1.6 * y.1 + y.1^s
    - define amountMax <element[0.8].add[<[SAR]>].mul[1.6].mul[<[amountReg]>].add[<[amountReg].power[<[SAR]>]>]>

    # Demand amount response randomization minimum:
    # y.3 = abs(y.1 - y.2 / 3)
    - define amountMin <element[<[amountReg].sub[<[amountMax]>]>].div[3].abs>

    - define qAdjustedMin <[amountMin].mul[<[qBias].add[1]>].round>
    - define reasonablePurchaseAmount <util.random.int[<[qAdjustedMin]>].to[<util.random.int[<[amountReg].round>].to[<[amountMax].round>]>]>

    - if <[reasonablePurchaseAmount]> > <[availableSupply]>:
        # Purchase multiplier equation:
        # m = (3a / sqrt(r/a) * 4r) ^ 2
        # where: a: availableBalance
        #        r: reasonablePurchaseAmount
        - define purchaseMultiplier <element[<[availableSupply].mul[3]>].div[<element[<[reasonablePurchaseAmount].div[<[availableSupply]>]>].sqrt.mul[4].mul[<[reasonablePurchaseAmount]>]>].power[2].add[0.2].if_null[0]>
        - define reasonablePurchaseAmount <[purchaseMultiplier].mul[<[availableSupply]>].round>

    CalculatePurchasedItemsPrice:
    # The combined price of all the purchased item as sold by the static supplier price
    - define supplyPrice <[allItems].filter_tag[<[filter_value].get[name]>].get[1].get[base].mul[<[reasonablePurchaseAmount]>]>

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


MerchantSellDecider:
    type: task
    definitions: marketName[ElementTag(String)]|merchant[NPCTag]
    script:
    ## Will utilize market demand and sale data to determine how much each merchant in a given
    ## market should allocate to the sale of each item in their inventory. If the 'merchant' param
    ## is provided, it will only do this for the specified merchant.
    ##
    ## marketName : [ElementTag<String>]
    ## merchant   : [NPCTag]
    ##
    ## >>> [Void]

    - define sBias <[merchant].flag[merchantData.spendBias]>
    - define wealth <[merchant].flag[merchantData.wealth]>
    - define totalSupply <[merchant].flag[merchantData.supply].values.parse_tag[<[parse_value].get[quantity].if_null[0]>].sum>

    - yaml load:economy_data/past-economy-data.yml id:past
    - define pastData <yaml[past].read[past_data]>
    - yaml id:past unload

    - define sellAnalyses <[pastData].parse_value_tag[<[parse_value].deep_get[<[marketName]>.items.sellAnalysis]>].if_null[null]>

    - if !<server.has_flag[economy.markets.<[marketName]>.sellData]> || <[sellAnalyses]> == null:
        - define average <[merchant].flag[merchantData.supply].parse_value_tag[<[parse_value].get[price]>].values.average>

        - foreach <[merchant].flag[merchantData.supply]> key:item as:itemData:
            - define buyPrice <[itemData].get[price]>
            - define sellPrice <[buyPrice].mul[<element[1].sub[<[sBias].div[3]>]>].round_up_to_precision[0.05]>
            - define supplyRatio <[itemData].get[quantity].div[<[totalSupply]>]>

            - flag <[merchant]> merchantData.sellData.items.<[item]>.alloc:<[merchant].flag[merchantData.balance].mul[<[supplyRatio]>].mul[<[sellPrice].div[<[average]>]>].round_up>
            - flag <[merchant]> merchantData.sellData.items.<[item]>.spent:0
            - flag <[merchant]> merchantData.sellData.items.<[item]>.price:<[sellPrice]>

        - stop

    - inject <script.name> path:FindItemTrend

    - if !<[merchant].exists>:
        - foreach <server.flag[economy.markets.<[marketName]>.merchants]> as:merchant:
            - inject <script.name> path:AnalyzeTrends

    - else:
        - inject <script.name> path:AnalyzeTrends

    AnalyzeTrends:
    # - define spendableBalance <[merchant].flag[merchantData.balance].mul[<util.random.decimal[<[sBias]>].to[1]>]>
    - define spendableBalance <[merchant].flag[merchantData.balance]>
    - define sellEffectors <map[]>
    - define allocations <map[]>

    - foreach <[itemTrends]> key:item:
        - if !<[merchant].has_flag[merchantData.supply.<[item]>]>:
            - foreach next

        - define realAvgValue <[value].get[averageValue].mul[<[sBias]>]>
        - define positiveEffector <[value].get[averageSAR].mul[<[realAvgValue]>].add[<[value].get[SARRange]>]>
        - define realFluctuationValue <[value].get[totalFluctuation].mul[<element[1].add[<[sBias]>]>]>
        - define negativeEffector <[realFluctuationValue].sub[<[value].get[SARRange]>]>

        - define sellEffectors.<[item]>:<[positiveEffector].sub[<[negativeEffector]>].round_to_precision[0.00001]>
        - define sellEffectors.total:+:<[positiveEffector].sub[<[negativeEffector]>].round_to_precision[0.00001]>

    - foreach <[sellEffectors].exclude[total]> key:item as:effector:
        - define proportion <[effector].div[<[sellEffectors].get[total]>]>
        - define itemAllocatedBalance <[spendableBalance].mul[<[proportion]>]>
        - define buyPrice <[merchant].flag[merchantData.supply.<[item]>.price]>
        - define sellPrice <[buyPrice].mul[<element[1].sub[<[sBias].div[2]>]>].round_up_to_precision[0.05]>
        - define alloc <[itemAllocatedBalance].div[<[sellPrice]>].round_down>

        - define allocations.<[item]>:<[alloc]>

        - flag <[merchant]> merchantData.sellData.items.<[item]>.alloc:<[alloc]>
        - flag <[merchant]> merchantData.sellData.items.<[item]>.spent:0
        - flag <[merchant]> merchantData.sellData.items.<[item]>.price:<[sellPrice]>

    - define average <[merchant].flag[merchantData.supply].parse_value_tag[<[parse_value].get[price]>].values.average>

    - foreach <[merchant].flag[merchantData.supply]> key:item as:itemData:
        - if <[item].is_in[<[sellEffectors].keys>]>:
            - foreach next

        - define buyPrice <[itemData].get[price]>
        - define sellPrice <[buyPrice].mul[<element[1].sub[<[sBias].div[3]>]>].round_up_to_precision[0.05]>
        - define supplyRatio <[itemData].get[quantity].div[<[totalSupply]>]>
        - define allocations.<[item]>:<[merchant].flag[merchantData.balance].mul[<[supplyRatio]>].mul[<[sellPrice].div[<[average]>]>].round>

        - flag <[merchant]> merchantData.sellData.items.<[item]>.alloc:<[merchant].flag[merchantData.balance].mul[<[supplyRatio]>].mul[<[sellPrice].div[<[average]>]>].round>
        - flag <[merchant]> merchantData.sellData.items.<[item]>.spent:0
        - flag <[merchant]> merchantData.sellData.items.<[item]>.price:<[sellPrice]>

    FindItemTrend:
    - define itemTrends <map[]>

    - foreach <[sellAnalyses]> key:day as:data:
        - foreach <[data].get[items]> key:item as:itemData:
            - define itemTrends.<[item]>.SARList:->:<[itemData].get[saleToAmountRatio]>
            - define itemTrends.<[item]>.totalAmountItem:+:<[itemData].get[totalAmountItem]>
            - define itemTrends.<[item]>.totalValueItem:+:<[itemData].get[totalValueItem]>

    - foreach <[itemTrends]>:
        - define itemTrends.<[key]>.SARRange:<[value].get[SARList].last.sub[<[value].get[SARList].first>]>
        - define itemTrends.<[key]>.averageValue:<[value].get[totalValueItem].div[<[value].get[totalAmountItem]>]>
        - define itemTrends.<[key]>.totalFluctuation:0

        - foreach <[value].get[SARList]> as:currSAR:
            - define itemTrends.<[key]>.totalFluctuation:+:<[value].get[SARList].get[<[loop_index].sub[1]>].if_null[<[currSAR].sub[<[currSAR]>].abs>]>

        - define itemTrends.<[key]>.averageSAR:<[value].get[SARList].average>


MarketSubTickPriceAdjuster:
    type: task
    definitions: marketName[ElementTag(String)]|merchant[NPCTag]
    script:
    ## Generates a map containing the degree to which a market's item prices must be adjusted in
    ## line with supply & demand. This data is used at the sub-tick level (by default, every in-
    ## game day) to inform on-the-fly merchant price adjustments.
    ##
    ## Note: sub-tick adjustments in the merchants' going prices for goods may or may not carry
    ## over into the next week. Main tick adjustments should take into account the final changed
    ## price each item was at in the end of the last sub-tick adjustment however, they may be lower
    ## than the (yet-to-be-implemented) minimum reasonable price for every item.
    ##
    ## marketName : [ElementTag<String>]
    ## merchant   : [NPCTag]
    ##
    ## >>> [ListTag<ElementTag>]

    # Note: replace with KAPI calls
    - if <server.has_flag[economy.markets.<[marketName]>.sellData]>:
        - run SellAnalysisGenerator def.market:<[marketName]> save:sellAnalysis
        - define sellAnalysis <entry[sellAnalysis].created_queue.determination.get[1]>

    - if <server.has_flag[economy.markets.<[marketName]>.buyData]>:
        - run PurchaseAnalysisGenerator def.market:<[marketName]> save:buyAnalysis
        - define buyAnalysis <entry[buyAnalysis].created_queue.determination.get[1]>

    - if !<[buyAnalysis].is_truthy>:
        - define validMerchants <server.flag[economy.markets.<[marketName]>.merchants].filter_tag[<[filter_value].flag[merchantData.supply].keys.contains[<[sellAnalysis].get[items].keys>]>].parse_tag[<[parse_value].as[npc]>]>
        - inject <script.name> path:AnalyzeSellDataOnly

        - determine <[sellAnalysis].get[items].keys>

    - else if !<[sellAnalysis].is_truthy>:
        - define validMerchants <server.flag[economy.markets.<[marketName]>.merchants].filter_tag[<[filter_value].flag[merchantData.supply].keys.contains[<[buyAnalysis].get[items].keys>]>].parse_tag[<[parse_value].as[npc]>]>
        - inject <script.name> path:AnalyzeBuyDataOnly

        - determine <[buyAnalysis].get[items].keys>

    - else:
        - foreach <[sellAnalysis].get[items]> key:item as:data:
            - if !<[merchant].flag[merchantData.supply].keys.contains[<[item]>]>:
                - foreach next

            - define newSAR <[data].get[saleToAmountRatio].sub[<[buyAnalysis].deep_get[items.<[item]>.saleToAmountRatio].if_null[0]>]>
            - define newSAR <[newSAR].sub[<[newSAR].mul[2]>]>

            - if <[newSAR]> > 0:
                - define priceIncrease <[merchant].flag[merchantData.supply.<[item]>.price].mul[<[newSAR].add[1]>].round_to_precision[0.01]>

                - flag <[merchant]> merchantData.supply.<[item]>.lastWeekAvg:<[merchant].flag[merchantData.supply.<[item]>.price]>
                - flag <[merchant]> merchantData.supply.<[item]>.price:<[priceIncrease]>

                - narrate format:debug "SAR: <[newSAR]>"
                - narrate format:debug "INCREASE: <[item].color[red].pad_right[20]>; <[merchant].flag[merchantData.supply.<[item]>.price].color[gold]> -<&gt> <[priceIncrease].color[red]>"

            - else:
                - define priceDecrease <[merchant].flag[merchantData.supply.<[item]>.price].sub[<[merchant].flag[merchantData.supply.<[item]>.price].mul[<[newSAR].abs>]>].round_to_precision[0.01]>

                - flag <[merchant]> merchantData.supply.<[item]>.lastWeekAvg:<[merchant].flag[merchantData.supply.<[item]>.price]>
                - flag <[merchant]> merchantData.supply.<[item]>.price:<[priceDecrease]>

                - narrate format:debug "SAR: <[newSAR]>"
                - narrate format:debug "DECREASE: <[item].color[aqua].pad_right[20]>; <[merchant].flag[merchantData.supply.<[item]>.price].color[gold]> -<&gt> <[priceDecrease].color[aqua]>"

            - narrate format:debug -------------------

            # - else:
            #     - define SAR <[data].get[saleToAmountRatio]>

            #     - if <[SAR]> > <[priceIncreaseThreshold]>:
            #         - foreach next

            #     - define priceDecrease <[merchant].flag[merchantData.supply.<[item]>.price].sub[<[merchant].flag[merchantData.supply.<[item]>.price].mul[<[SAR]>]>].round_to_precision[0.01]>

            #     # - flag <[merchant]> merchantData.supply.<[item]>.lastWeekAvg:<[merchant].flag[merchantData.supply.<[item]>.price]>
            #     # - flag <[merchant]> merchantData.supply.<[item]>.price:<[priceIncrease]>

            #     - narrate format:debug "DECREASE: <[item].color[red]>; <[merchant].flag[merchantData.supply.<[item]>.price].color[gold]> -<&gt> <[priceDecrease].color[red]>"

        - determine <[buyAnalysis].get[items].keys.include[<[sellAnalysis].get[items].keys>].deduplicate>

    AnalyzeSellDataOnly:
    - define sBias <[merchant].flag[merchantData.spendBias]>

    # If the SAR for a given item is below this threshold then the price won't be changed
    - define priceIncreaseThreshold <[sBias].power[1.941629877]>

    - foreach <[sellAnalysis].get[items]> key:item as:data:
        # - if !<[merchant].has_flag[merchantData.supply.<[item]>]>:
        #     - foreach next

        - define SAR <[data].get[saleToAmountRatio]>

        - if <[SAR]> > <[priceIncreaseThreshold]>:
            - foreach next

        - define priceIncrease <[merchant].flag[merchantData.supply.<[item]>.price].mul[<[SAR].add[1]>].round_to_precision[0.01]>

        - flag <[merchant]> merchantData.supply.<[item]>.lastWeekAvg:<[merchant].flag[merchantData.supply.<[item]>.price]>
        - flag <[merchant]> merchantData.supply.<[item]>.price:<[priceIncrease]>

        - narrate format:debug "INCREASE: <[item].color[red]> from: <[merchant].flag[merchantData.supply.<[item]>.price].color[gold]> to: <[priceIncrease].color[red]>"

    AnalyzeBuyDataOnly:
    - define sBias <[merchant].flag[merchantData.spendBias]>

    # If the SAR for a given item is below this threshold then the price won't be changed
    - define priceDecreaseThreshold <[sBias].power[1.941629877]>

    - foreach <[buyAnalysis].get[items]> key:item as:data:
        # - if !<[merchant].has_flag[merchantData.supply.<[item]>]>:
        #     - foreach next

        - define SAR <[data].get[saleToAmountRatio]>

        - if <[SAR]> > <[priceDecreaseThreshold]>:
            - foreach next

        - define priceDecrease <[merchant].flag[merchantData.supply.<[item]>.price].sub[<[merchant].flag[merchantData.supply.<[item]>.price].mul[<[SAR]>]>].round_to_precision[0.01]>

        - flag <[merchant]> merchantData.supply.<[item]>.lastWeekAvg:<[merchant].flag[merchantData.supply.<[item]>.price]>
        - flag <[merchant]> merchantData.supply.<[item]>.price:<[priceDecrease]>

        - narrate format:debug "DECREASE: <[item].color[aqua]> from: <[merchant].flag[merchantData.supply.<[item]>.price].color[gold]> to: <[priceDecrease].color[aqua]>"


MarketSubTick:
    type: task
    script:
    - run OldMarketDataRecorder

    - foreach <server.flag[economy.markets]> as:market key:marketName:
        - foreach <[market].get[merchants]> as:merchant:
            - run MarketSubTickPriceAdjuster def.marketName:<[marketName]> def.merchant:<[merchant]>


MarketTick:
    type: task
    script:
    # - run OldMarketDataRecorder

    - foreach <server.flag[economy.markets]> key:marketName as:market:
        - define merchants <[market].get[merchants]>
        - define merchantAmount <[merchants].size.mul[1.5].round_up>

        - run SupplyAmountCalculator def.marketSize:<[merchantAmount].mul[1.5].round> def.spawnChance:1 save:supplyAmount
        - define supply <entry[supplyAmount].created_queue.determination.get[1]>

        - flag server economy.markets.<[marketName]>.supplyMap.original:<[supply]>
        - flag server economy.markets.<[marketName]>.supplyMap.current:<[supply]>

        - foreach <[merchants]> as:merchant:
            - define balance <[merchant].flag[merchantData.balance]>
            - define wealth <[merchant].flag[merchantData.wealth]>

            # Note: future configurable(?)
            # How much of the merchant's wealth should be earned back by them each week? As of
            # now I'm settled on 1/4 of wealth returned weekly to simulate a monthly paycheck.
            - if !<[balance].exists> || <[balance].is[MORE].than[<[wealth].mul[2]>]>:
                - flag <[merchant]> merchantData.balance:<[wealth]>

            - else:
                - flag <[merchant]> merchantData.balance:+:<[wealth].mul[0.77]> if:<[balance].exists>

            - run AssignPurchaseStrategy def.merchant:<[merchant]>
            - run MerchantPurchaseDecider def.marketName:<[marketName]> def.merchant:<[merchant]>
            - run MerchantSellDecider def.marketName:<[marketName]> def.merchant:<[merchant]>

        ## UNCOMMENT WHEN IN PROD.
        # - flag server economy.markets.<[marketName]>.sellData:!
        # - flag server economy.markets.<[marketName]>.buyData:!

    # The main tick should handle:
    #x 1. Merchant re-purchasing new resources (See old demand response code + NewMerchantPriceDecider)
    #* 2. Proper re-adjustments of prices (based on old data as well as recent)
    #x 3. Merchant refreshing balance (see if a yearly or monthly salary makes more sense)
    #x 4. Market supply refresh (this one should probably be first)


MarketTick_Handler:
    type: world
    enabled: false
    events:
        on system time minutely every:60:
        - run MarketSubTick

        on system time minutely every:120:
        - run MarketTick
