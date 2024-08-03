##
## All scripts related to the generation of statistical analysis for the purposes of the Kingdoms
## economic mechanics. Scripts here should be used to inform the decisions made by both regular
## and black market merchants on how to adjust prices based on player input.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Nov 2022 - First created
## @Updated: Aug 2023 - Migrated to new file
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

# Always note that sell and buy here are from the perspective of the player!
# I.e. SellAnalysisGenerator generates the data related to the stuff that the player(s) sold to
# different merchants in a given market

SellAnalysisGenerator:
    type: task
    definitions: market
    script:
    ## Generates some stats about the items that players sold to all merchants in a given market
    ## including the total value of all items sold, standard deviation of different pricepoints,
    ## maximum, minimum, average of such data etc.
    ##
    ## Also, see note above this script.
    ##
    ## market : [ElementTag<String>]
    ##
    ## >>> ?[MapTag
    ##         <MapTag<
    ##             ElementTag<Float>;
    ##             ElementTag<Integer>;
    ##             ElementTag<Integer>;
    ##             MapTag<
    ##                 ElementTag<Float>;
    ##                 ElementTag<Float>;
    ##                 ElementTag<Float>;
    ##                 ElementTag<Float>;
    ##             >;
    ##         >
    ##     >]
    ##
    ## howdya like my eight inch d....
    ## ..ocstring? ;)))

    - if !<server.has_flag[economy.markets.<[market]>.sellData]>:
        - determine null

    - define sellData <server.flag[economy.markets.<[market]>.sellData]>
    - define marketAnalysis <map[]>

    - foreach <[sellData].exclude[totalAmount|totalValue]> as:itemData key:itemName:
        - run <script.name> path:ItemAnalysisGenerator def.market:<[market]> def.item:<[itemName]> save:ItemAnalysis
        - define itemAnalysis <entry[ItemAnalysis].created_queue.determination.get[1]>
        - define marketAnalysis.items.<[itemName]>:<[itemAnalysis]>
        - define marketAnalysis.totalAmount:<[sellData].get[totalAmount]>
        - define marketAnalysis.totalValue:<[sellData].get[totalValue]>

    - determine <[marketAnalysis]>

    ## SUBPATHS
    ItemAnalysisGenerator:
    - define supplyAmounts <server.flag[economy.markets.<[market]>.supplyMap.original]>
    - define sellData <server.flag[economy.markets.<[market]>.sellData]>
    - define saleToAmountRatio <[sellData].deep_get[<[item]>.totalAmount].div[<[supplyAmounts].get[<[item]>]>]>
    - define allPrices <[sellData].deep_get[<[item]>.transactions].parse_tag[<[parse_value].get[price]>]>
    - define averageSellPrice <[allPrices].average>
    - inject <script.name> path:StandardDevCalculator

    - definemap itemAnalysis:
        saleToAmountRatio: <[saleToAmountRatio].round_to_precision[0.0001]>
        totalAmountItem: <[sellData].deep_get[<[item]>.totalAmount]>
        totalValueItem: <[sellData].deep_get[<[item]>.totalValue]>
        sellPriceInfo:
            average: <[averageSellPrice]>
            stDev: <[stDev].round_to_precision[0.0001]>
            max: <[allPrices].highest>
            min: <[allPrices].lowest>

    - determine <[itemAnalysis]>

    StandardDevCalculator:
    - define n <[sellData].get[<[item]>].size>
    - define sum 0

    - foreach <[allPrices]> as:price:
        - define sum:+:<[price].sub[<[averageSellPrice]>].power[2]>

    - define stDev <[sum].div[<[n]>].sqrt>


PurchaseAnalysisGenerator:
    type: task
    definitions: market
    script:
    ## Generates some stats about the items that players purchased from all merchants in a given
    ## market including the total value of all items sold, standard deviation of different
    ## pricepoints, maximum, minimum, average of such data etc.
    ##
    ## Also, see note above SellAnalysisGenerator.
    ##
    ## market : [ElementTag<String>]
    ##
    ## >>> ?[MapTag
    ##         <MapTag<
    ##             ElementTag<Float>;
    ##             ElementTag<Integer>;
    ##             ElementTag<Integer>;
    ##             MapTag<
    ##                 ElementTag<Float>;
    ##                 ElementTag<Float>;
    ##                 ElementTag<Float>;
    ##                 ElementTag<Float>;
    ##             >;
    ##         >
    ##     >]

    - if !<server.has_flag[economy.markets.<[market]>.buyData]>:
        - determine null

    - define marketDemand <server.flag[economy.markets.<[market]>.buyData]>
    - define marketAnalysis <map[]>

    - foreach <[marketDemand].exclude[totalAmount|totalValue]> as:itemData key:itemName:
        - run <script.name> path:ItemAnalysisGenerator def.market:<[market]> def.item:<[itemName]> save:ItemAnalysis
        - define itemAnalysis <entry[ItemAnalysis].created_queue.determination.get[1]>
        - define marketAnalysis.items.<[itemName]>:<[itemAnalysis]>
        - define marketAnalysis.totalAmount:<[marketDemand].get[totalAmount]>
        - define marketAnalysis.totalValue:<[marketDemand].get[totalValue]>

    - determine <[marketAnalysis]>

    ## SUBPATHS
    ItemAnalysisGenerator:
    # TODO: Make sure that this is supposed to be supplyMap.original and not .current
    - define supplyAmounts <server.flag[economy.markets.<[market]>.supplyMap.original]>
    - define marketDemand <server.flag[economy.markets.<[market]>.buyData]>

    # This value is a ratio between the amount of an item that was sold in the past week
    # and the average amount of that item that gets spawned in merchant inventories weekly
    - define saleToAmountRatio <element[<[marketDemand].deep_get[<[item]>.totalAmount].div[<[supplyAmounts].get[<[item]>]>]>]>
    ## NOTE: Uncomment when you introduce new transaction scheme
    # - define allPrices <[marketDemand].deep_get[<[item]>.transactions].parse_tag[<[parse_value].deep_get[buy.price]>].if_null[null]>
    - define allPrices <[marketDemand].deep_get[<[item]>.transactions].parse_tag[<[parse_value].get[price]>]>
    - define averageSellPrice <[allPrices].average>
    - inject <script.name> path:StandardDevCalculator

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

    StandardDevCalculator:
    - define n <[marketDemand].get[<[item]>].size>
    - define sum 0

    - foreach <[allPrices]> as:price:
        - define sum:+:<[price].sub[<[averageSellPrice]>].power[2]>

    - define stDev <[sum].div[<[n]>].sqrt>

########################
## OLD DATA & RELATED ##
########################

OldMarketDataRecorder:
    type: task
    script:
    ## Writes every market's statistical data to a yaml file for it to be used by merchants to
    ## inform price-setting information in the long-run.
    ##
    ## >>> [Void]

    - define allMarketsMap <map[]>
    - yaml load:economy_data/past-economy-data.yml id:past
    # Note: future confirgurable
    - define maxQueueSize 31

    - foreach <server.flag[economy.markets].keys> as:market:
        - run PurchaseAnalysisGenerator def.market:<[market]> save:buyAnalysis
        - define buyAnalysis <entry[buyAnalysis].created_queue.determination.get[1]>

        - run SellAnalysisGenerator def.market:<[market]> save:sellAnalysis
        - define sellAnalysis <entry[sellAnalysis].created_queue.determination.get[1]>

        - define marketAnalysis <map[]>
        - define marketAnalysis.buyAnalysis:<[buyAnalysis]> if:<[buyAnalysis].is_truthy>
        - define marketAnalysis.sellAnalysis:<[sellAnalysis]> if:<[sellAnalysis].is_truthy>

        - define allMarketsMap.<[market]>.items:<[marketAnalysis]>
        - define allMarketsMap.<[market]>:<[allMarketsMap].get[<[market]>].include[<[marketAnalysis].get_subset[totalValue|totalAmount]>]>

    # - run flagvisualizer def.flag:<[allMarketsMap]> "def.flagName:Kowalski, Analysis"

    - define queueSize <yaml[past].read[past_data].size.if_null[0]>

    - if <yaml[past].contains[past_data.<[maxQueueSize]>]>:
        - yaml id:past set past_data.<[maxQueueSize]>:!

    - if <[queueSize]> == 0:
        - narrate format:debug "Setting zero-size yaml map."
        - yaml id:past set past_data.1:<[allMarketsMap]>
        - yaml id:past savefile:economy_data/past-economy-data.yml
        - yaml id:past unload
        - stop

    - else if <[queueSize]> == 1:
        - yaml id:past set past_data.2:<yaml[past].read[past_data.1]>
        - yaml id:past set past_data.1:<[allMarketsMap]>
        - yaml id:past savefile:economy_data/past-economy-data.yml
        - yaml id:past unload
        - stop

    # I just spent the better part of an hour trying to work this segment of code a certain way
    # and in the end got so angry that I decided to re-write the whole thing using the method
    # below that I previously thought would be less efficient and made it run faster and in less
    # space than the original in one shot... oh and it ran on the first time.
    # roid rage works.
    - define staticPastData <yaml[past].read[past_data]>

    - foreach <[staticPastData]> as:data:
        - define index <[queueSize].add[2].sub[<[loop_index]>]>

        - if <[index]> == 1:
            - foreach stop

        - define prevData <yaml[past].read[past_data.<[index].sub[1]>]>
        - yaml id:past set past_data.<[index]>:<[prevData]>

    - yaml id:past set past_data.1:<[allMarketsMap]>
    - yaml id:past savefile:economy_data/past-economy-data.yml
    - yaml id:past unload

    - narrate format:debug Saved!

    # AppendQueue:
    # - define joinedQueue <[queue].get[recent].include[<[stack].get[old]>]>
    # - define lastItemIndex <[joinedQueue].keys.highest>
    # - define firstItemIndex <[joinedQueue].keys.lowest>
    # - define tempNewQueue <map[]>
    # - define newQueue <map[]>

    # - foreach <[joinedQueue]>:
    #     - define tempNewQueue.<[key].add[1]>:<[value]>

    # - define tempNewQueue.<[lastItemIndex]>:!
    # - define tempNewQueue.1:<[allMarketsMap]>

    # - if <[tempNewQueue].size> > <[recentMaxQueueSize]>:
    #     - foreach <[tempNewQueue].get[<[recentMaxQueueSize].add[1]>]> as:market:
    #         - define marketDemand <[market].get[market_demand]>
    #         # Creates definition: marketMap
    #         - inject <script.name> path:GenerateOldData
    #         - define tempNewQueue.<[recentMaxQueueSize].add[1]>.<[key]>:<[marketMap]>

    #     - define newQueue.recent:<[tempNewQueue].parse_value_tag[<[parse_key].is[OR_LESS].than[<[recentMaxQueueSize]>]>]>
    #     - define newQueue.old:<[tempNewQueue].parse_value_tag[<[parse_key].is[MORE].than[<[recentMaxQueueSize]>]>]>
    #     - define tempNewQueue:!

    # - else:
    #     - define newQueue.recent:<[tempNewQueue]>
    #     - define tempNewQueue:!

    # - run flagvisualizer def.flag:<[newQueue]> def.flagName:newQueue


GenerateCompressedOldData:
    type: task
    definitions: marketName|day
    script:
    ## Compresses the old data of a given market for a given amount of days ago for ease of use.
    ##
    ## marketName : [ElementTag<String>]
    ## day        : [ElementTag<Integer>]
    ##
    ## >>> [MapTag<
    ##         <ElementTag<Integer>>
    ##         <ElementTag<Float>>
    ##         <ElementTag<Float>>
    ##         <ElementTag<Float>>
    ##         <ElementTag<Integer>>
    ##     >]

    - yaml load:economy_data/past-economy-data.yml id:past

    # TODO: Throw internal errors for these when branch is merged back!
    - if !<[day].is_integer>:
        - determine null

    - if !<server.has_flag[economy.markets.<[marketName]>]>:
        - determine null

    - define marketPastData <yaml[past].read[past_data.<[day]>.<[marketName]>]>
    - define SARMap <[marketPastData].get[items].parse_value_tag[<[parse_value].get[saleToAmountRatio]>]>
    - define SARList <[SARMap].values>
    - define oSAR <[SARList].average>
    - define itemsSold <[marketPastData].keys>
    - define totalValue <[marketPastData].get[totalValue]>
    - define totalAmount <[marketPastData].get[totalAmount]>
    - define averagePrice <[totalValue].div[<[totalAmount]>]>

    - definemap marketMap:
        total_amount: <[totalAmount]>
        total_value: <[totalValue]>
        avg_price: <[averagePrice]>
        o_sar: <[oSAR]>
        items_sold: <[itemsSold]>

    - determine <[marketMap]>


## Save previous market tendancies to YAML perhaps also save along with it global market demand
## figures for analysis by blackmarket factions or other omni-present economic forces.
MarketDemandHandler:
    type: world
    events:
        on system time hourly every:24:
        - run OldMarketDataRecorder

        - foreach <server.flag[economy.markets].keys> as:market:
            - flag server economy.markets.<[market]>.buyData:!
