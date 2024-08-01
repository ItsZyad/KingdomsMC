##
## [SCENARIO I]
## All scripts in this file relate to the Vexell river tracker mechanic. This mechanic is going to
## work differently depending on if its being viewed from either the Jalerad or Talpenhern perspec-
## -tive.
##
## The river area will be encompassed by a Polygon Object which will have a snapshot of what the
## river looks like sans obstructions and each additional obstruction will reduce the amount of
## trade that Jalerad can get from Fyndalin.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jul 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

RiverTradeEfficiencyImpact:
    type: data
    Impacts:
        talpenhern: 0.45
        jalerad: 0.75


SetRiverEmptyState:
    type: task
    debug: false
    description:
    - Will go through the current Vexell river AreaObject and set its current state as the 'default', so that any additions onto this state are treated as obstructions.
    - ---
    - → [Void]

    script:
    ## Will go through the current Vexell river AreaObject and set its current state as the
    ## 'default', so that any additions onto this state are treated as obstructions.
    ##
    ## >>> [Void]

    - define riverArea <proc[GetRiverArea]>

    - if !<[riverArea].is_truthy>:
        - stop

    - define emptyBlocks <[riverArea].blocks[air|water]>
    - flag server kingdoms.scenario-1.river.default.emptyBlocks:<[emptyBlocks].utf8_encode.zlib_compress>


CompareRiverState:
    type: task
    debug: false
    description:
    - Will compare the Vexell river's current state to the default to check if any obstructions are present.
    - Will return null if no river area is defined.
    - ---
    - → ?[MapTag(ElementTag(Integer))]

    script:
    ## Will compare the Vexell river's current state to the default to check if any obstructions
    ## are present.
    ##
    ## Will return null if no river area is defined.
    ##
    ## >>> ?[MapTag<
    ##         ElementTag<Integer>
    ##     >]

    - define riverArea <proc[GetRiverArea]>

    - if !<[riverArea].is_truthy>:
        - determine null

    - define currEmptyBlocks <[riverArea].blocks[air|water]>
    - define defEmptyBlocks <server.flag[kingdoms.scenario-1.river.default.emptyBlocks].zlib_decompress.utf8_decode>

    - definemap determination:
        currentEmptyBlocks: <[currEmptyBlocks]>
        defaultEmptyBlocks: <[defEmptyBlocks]>

    - determine <[determination]>


CalculateObstructionRate:
    type: task
    debug: false
    description:
    - Will generate a percentage (number between 0-1) on the extent to which the Vexell river is obstructed.
    - Will return null on failure.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Will generate a percentage (number between 0-1) on the extent to which the Vexell river is
    ## obstructed.
    ##
    ## Will return null on failure.
    ##
    ## >>> [ElementTag<Float>]

    - run CompareRiverState save:riverState
    - define riverState <entry[riverState].created_queue.determination.get[1]>

    - if <[riverState]> == null:
        - determine null

    - define currEmpty <[riverState].get[currentEmptyBlocks].as[list].size>
    - define defEmpty <[riverState].get[defaultEmptyBlocks].as[list].size>

    - define proportion <[defEmpty].div[<[currEmpty]>].sub[1].mul[100].round_to_precision[0.0001].proc[Invert]>

    - if <[proportion]> < 0:
        - define proportion <[proportion].div[2]>

    - determine <[proportion]>


RecalculateTradeEfficiency:
    type: task
    script:
    - run CalculateObstructionRate save:proportion
    - define proportion <entry[proportion].created_queue.determination.get[1]>

    - foreach <proc[GetKingdomList]> as:kingdom:
        - define kingdomImpact <script[RiverTradeEfficiencyImpact].data_key[Impacts.<[kingdom]>]>
        - define adjustedProportion <element[<element[<[proportion].abs>].mul[<[kingdomImpact]>]>].power[0.68]>

        - if <[proportion]> < 0:
            - define adjustedProportion <[adjustedProportion].proc[Invert]>

        - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.tradeEfficiency:<[adjustedProportion]>


TradeEfficiencyUpdate_Handler:
    type: world
    debug: false
    events:
        on time 0:
        - inject RecalculateTradeEfficiency
