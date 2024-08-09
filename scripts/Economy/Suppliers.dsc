##
## All files related to the simulated supplier mechanic which provides Kingdoms merchants with all
## the necessary materials to sell players as well as the market creator code (temp).
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Oct 2022
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

SupplyAmountCalculator:
    type: task
    debug: false
    definitions: marketSize
    script:
    - yaml load:economy_data/worth.yml id:worth
    - define rawItems <server.flag[economy.itemCategories].values.parse_tag[<[parse_value].get[items]>].combine>
    - define marketSize <[marketSize].round.if_null[1].mul[5]>
    - define spawnChances <map[]>

    - foreach <[rawItems]> as:itemName:
        - define supplyMod <yaml[worth].read[items.<[itemName]>.supplyProb]>
        - define amountMod <yaml[worth].read[items.<[itemName]>.amountMod].if_null[1]>
        - define supplyAmount <util.random.int[1].to[128].mul[<[supplyMod]>].mul[<[marketSize]>].mul[<[amountMod]>].round_up>
        - define spawnChances.<[itemName]>:<[supplyAmount]>

    - yaml id:worth unload
    - run FlagVisualizer def.flag:<[spawnChances]> def.flagName:SpawnChances
    - determine <[spawnChances]>