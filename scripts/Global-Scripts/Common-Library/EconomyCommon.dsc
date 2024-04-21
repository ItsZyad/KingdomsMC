##
## [KAPI]
## Assorted scripts relating to the economy, markets, and global financial system of Kingdoms
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Oct 2023
## @Script Ver: v0.1
##
## ----------------END HEADER-----------------

# TODO: make this into a namespace and create a separate file for merchant-specific data.

GetAllMarkets:
    type: procedure
    description:
    - Gets all markets in the game by name.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Gets all markets in the game by name.
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - determine <server.flag[economy.markets].keys>


# @Stopgap
GetMarketMap:
    type: procedure
    definitions: name[ElementTag(String)]
    description:
    - @Stopgap
    - <&sp>
    - Gets all market data by the given internal name of the market.
    - Note: This is a stopgap only to be used until specific getters are made for other attrs.
    - ---
    - → [MapTag]

    script:
    ## Gets all market data by the given internal name of the market.
    ## Note: This is a stopgap only to be used until specific getters are made for other attrs.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [MapTag]

    - determine <server.flag[economy.markets.<[name]>]>


GetMarketByID:
    type: procedure
    definitions: id[ElementTag(Integer)]
    description:
    - Gets a market by its auto-assigned numerical ID.
    - ---
    - → [MapTag]

    script:
    ## Gets a market by its auto-assigned numerical ID.
    ##
    ## id : [ElementTag<Integer>]
    ##
    ## >>> [MapTag]

    - determine <server.flag[economy.markets].values.filter_tag[<[filter_value].get[ID].equals[<[id]>]>].get[1]>


GetMarketName:
    type: procedure
    definitions: id[ElementTag(Integer)]
    description:
    - Gets a market's internal name provided its auto-assigned numerical ID.
    - ---
    - → [ElementTag(String)]

    script:
    ## Gets a market's internal name provided its auto-assigned numerical ID.
    ##
    ## id : [ElementTag<Integer>]
    ##
    ## >>> [ElementTag<String>]

    - foreach <server.flag[economy.markets]> as:market key:marketName:
        - if <[market].get[id]> == <[id]>:
            - determine <[marketName]>


GetMarketAttractiveness:
    type: procedure
    definitions: name[ElementTag(String)]
    description:
    - Gets a market's attractiveness stat.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Gets a market's attractiveness stat.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - determine <server.flag[economy.markets.<[name]>.attractiveness].if_null[0]>


GetMarketSupplyPriceMod:
    type: procedure
    definitions: name[ElementTag(String)]
    description:
    - Gets the supplierPriceMod value (which multiplies the value of items when they are being
    - mass-purchased from the market's suppliers) for the given market.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Gets the supplierPriceMod value (which multiplies the value of items when they are being
    ## mass-purchased from the market's suppliers) for the given market.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - determine <server.flag[economy.markets.<[name]>.supplierPriceMod].if_null[1]>


GetMarketArea:
    type: procedure
    definitions: name[ElementTag(String)]
    description:
    - Gets a market's defined area as a PolygonTag.
    - ---
    - → [PolygonTag]

    script:
    ## Gets a market's defined area as a PolygonTag.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [PolygonTag]

    - determine <server.flag[economy.markets.<[name]>.marketArea].as[polygon]>


GetMarketMerchants:
    type: procedure
    definitions: name[ElementTag(String)]
    description:
    - Gets a list of all the merchants currently situated in the provided market.
    - ---
    - → [ListTag(NPCTag)]

    script:
    ## Gets a list of all the merchants currently situated in the provided market.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [ListTag<NPCTag>]

    - determine <server.flag[economy.markets.<[name]>.merchants].if_null[<list[]>]>


GetCurrentMarketSupply:
    type: procedure
    definitions: marketName[ElementTag(String)]
    description:
    - Gets a map of all the currently available resources in a given market.
    - ---
    - → [MapTag(ElementTag(String); ElementTag(Integer))]

    script:
    ## Gets a map of all the currently available resources in a given market.
    ##
    ## marketName : [ElementTag<String>]
    ##
    ## >>> [MapTag<ElementTag<String>;ElementTag<Integer>>]

    - determine <server.flag[economy.markets.<[marketName]>.supplyMap.current]>


GetOriginalMarketSupply:
    type: procedure
    definitions: marketName[ElementTag(String)]
    description:
    - Gets a map of all the resources available as supply in a given market upon initial generation.
    - ---
    - → [MapTag(ElementTag(String); ElementTag(Integer))]

    script:
    ## Gets a map of all the resources available as supply in a given market upon initial
    ## generation.
    ##
    ## marketName : [ElementTag<String>]
    ##
    ## >>> [MapTag<ElementTag<String>;ElementTag<Integer>>]

    - determine <server.flag[economy.markets.<[marketName]>.supplyMap.original]>