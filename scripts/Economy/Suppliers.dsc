##
## * All files related to the simulated supplier mechanic which
## * provides Kingdoms merchants with all the necessary materials
## * to sell players as well as the market creator code (temp)
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Oct 2022
## @Script Ver: INDEV
##
## ----------------END HEADER-----------------

SupplyAmountCalculator:
    type: task
    debug: false
    definitions: marketSize|spawnChance
    script:
    - yaml load:economy_data/price-info.yml id:prices
    - define rawItems <yaml[prices].read[price_info.items]>
    - define globalMod <yaml[prices].read[price_info.global_supply_mod].if_null[1]>
    - define marketSize <[marketSize].round.if_null[1].mul[5]>
    - define spawnChance <[spawnChance].if_null[<util.random.decimal[0].to[1]>]>
    - define spawnChances <map[]>

    - foreach <[rawItems]> as:group key:groupName:
        - foreach <[group]> as:item key:itemName:
            - define supplyProb <[item].get[supply_prob].if_null[<util.random.decimal[0].to[1]>]>

            - if <[supplyProb]> <= <[spawnChance]>:
                - define probabilityDiff <[spawnChance].sub[<[supplyProb]>]>
                - define amountMod <[item].get[amount_mod].if_null[1]>
                - define supplyAmount <util.random.int[1].to[128].mul[<[supplyProb]>].mul[<[probabilityDiff].add[1]>].mul[<[amountMod]>].mul[<[marketSize]>].round>
                - define spawnChances.<[itemName]>:<[supplyAmount].mul[<[globalMod]>]>

    - yaml id:prices unload
    - run FlagVisualizer def.flag:<[spawnChances]> def.flagName:SpawnChances
    - determine <[spawnChances]>