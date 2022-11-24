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
        #- define qControlledItems <[qControlledItems].random[<[qControlledItems].size>]>
        - narrate format:debug WIP

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
        - define spendableBalance <[balance].mul[<util.random.decimal[<[sBias]>].to[1]>]>
        - define itemAmount <[qControlledItems].size>

        #TODO: VERY IMPORTANT!!!
        #TODO: Remove this line before going into prod.
        - flag <[merchant]> merchantData.supply:!

        #- while <[merchant].flag[merchantData.balance].is[MORE].than[<[spendableBalance]>]> || <[loop_index]> < 29:
        - foreach <[qControlledItems]> as:item:
            - define base <[item].get[base]>
            - define balance <[merchant].flag[merchantData.balance]>
            - define spendableBalance <[balance].mul[<util.random.decimal[<[sBias]>].to[1]>]>
            - define reasonablePurchaseAmount <[spendableBalance].div[<[itemAmount]>].div[<[base]>].round>
            - define supplyPrice <[reasonablePurchaseAmount].mul[<[base].mul[<[supplyPriceMod]>]>]>

            - narrate format:debug NAM:<[item].get[name]>
            - narrate format:debug RPA:<[reasonablePurchaseAmount]>
            - narrate format:debug SUP:<[supplyPrice]>
            - narrate format:debug SPB:<[spendableBalance]>
            - narrate format:debug ----------------------

            - if <[spendableBalance].is[OR_MORE].than[<[supplyPrice]>]>:
                - flag <[merchant]> merchantData.balance:-:<[supplyPrice]>
                - flag <[merchant]> merchantData.supply.<[item].get[name]>.quantity:+:<[reasonablePurchaseAmount]>

            - else:
                - foreach stop

        - narrate format:debug SPM:<[supplyPriceMod]>

    - yaml id:prices unload
