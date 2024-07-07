##
## [KAPI - SCENARIO I]
## This file is the package-specific KAPI module for the Scenario I package. It contains all the
## common scripts and APIs for all things related to the 'River Crisis' scenario.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jun 2024
## @Script Ver: v1.0
##
##ignorewarning invalid_data_line_quotes
## ------------------------------------------END HEADER-------------------------------------------

GetKingdomPopulation:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    description:
    - Gets the current simulated population of the kingdom with the provided name.
    - If the kingdom provided does not have any population data then this procedure will return null.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Gets the current simulated population of the kingdom with the provided name.
    ##
    ## If the kingdom provided does not have any population data then this procedure will return
    ## null.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[[PACK/SC1] Cannot get kingdom population. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - determine <server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.population].if_null[<script[SC1_PopulationData].data_key[<[kingdom]>.population]>].if_null[null]>


SetKingdomPopulation:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Integer)]
    description:
    - Sets the population of the kingdom with the provided name to the provided amount.
    - ---
    - → [Void]

    script:
    ## Sets the population of the kingdom with the provided name to the provided amount.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Integer>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[[PACK/SC1] Cannot set kingdom population. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - stop

    - if !<[amount].is_integer>:
        - run GenerateInternalError def.category:ValueError message:<element[[PACK/SC1] Cannot set kingdom population. Invalid amount specified: <[amount].bold>. Amount must be an integer.]>
        - stop

    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.population:<[amount]>


AddKingdomPopulation:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Integer)]
    description:
    - Adds the amount specified to the provided kingdom's population.
    - ---
    - → [Void]

    script:
    ## Adds the amount specified to the provided kingdom's population.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Integer>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[[PACK/SC1] Cannot set kingdom population. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - stop

    - if !<[amount].is_integer>:
        - run GenerateInternalError def.category:ValueError message:<element[[PACK/SC1] Cannot set kingdom population. Invalid amount specified: <[amount].bold>. Amount must be an integer.]>
        - stop

    - define newAmount <[kingdom].proc[GetKingdomPopulation].add[<[amount]>]>
    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.population:<[newAmount]>


GetKingdomPopGrowth:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    description:
    - Gets the current population growth rate (in %) for the kingdom with the provided name.
    - If the kingdom provided does not have any population growth rate data then this procedure will return null.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Gets the current population growth rate (in %) for the kingdom with the provided name.
    ##
    ## If the kingdom provided does not have any population growth rate data then this procedure
    ## will return null.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[[PACK/SC1] Cannot get kingdom population growth. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - determine <server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.popGrowth].if_null[<script[SC1_PopulationData].data_key[<[kingdom]>.basePopGrowth]>].if_null[null]>


SetKingdomPopulationGrowth:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Sets the population growth of the kingdom with the provided name to the provided amount.
    - ---
    - → [Void]

    script:
    ## Sets the population growth of the kingdom with the provided name to the provided amount.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[[PACK/SC1] Cannot set kingdom population growth rate. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - stop

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:ValueError message:<element[[PACK/SC1] Cannot set kingdom population growth rate. Invalid amount specified: <[amount].bold>. Amount must be a number.]>
        - stop

    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.popGrowth:<[amount]>


AddKingdomPopulationGrowth:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Adds the amount specified to the provided kingdom's population growth rate and returns the new rate.
    - If the operation fails then the script will return null
    - ---
    - → ?[ElementTag(Float)]

    script:
    ## Adds the amount specified to the provided kingdom's population growth rate and returns the
    ## new rate.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> ?[ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[[PACK/SC1] Cannot set kingdom population growth rate. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - stop

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:ValueError message:<element[[PACK/SC1] Cannot set kingdom population growth rate. Invalid amount specified: <[amount].bold>. Amount must be a number.]>
        - stop

    - define newAmount <[kingdom].proc[GetKingdomPopGrowth].add[<[amount]>]>
    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.popGrowth:<[newAmount]>


GetKingdomFoodReserves:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    description:
    - Gets the current food reserves of the kingdom with the provided name. Each food reserve unit equates to half a vanilla Minecraft saturation point.
    - If the kingdom provided does not have any food data then this procedure will return null.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Gets the current food reserves of the kingdom with the provided name. Each food reserve unit
    ## equates to half a vanilla Minecraft saturation point.
    ##
    ## If the kingdom provided does not have any food data then this procedure will return null.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[[PACK/SC1] Cannot get kingdom population growth. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - determine <server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.food].if_null[<script[SC1_PopulationData].data_key[<[kingdom]>.baseFoodReserves]>].if_null[null]>


SetKingdomFoodReserves:
    type: procedure
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Integer)]
    description:
    - Sets the food reserves of the kingdom with the provided name to the provided amount.
    - If the operation fails then the script will return null.
    - ---
    - → [Void]

    script:
    ## Sets the food reserves of the kingdom with the provided name to the provided amount.
    ## If the operation fails then the script will return null.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[[PACK/SC1] Cannot set kingdom food reserves. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - stop

    - if !<[amount].is_integer>:
        - run GenerateInternalError def.category:ValueError message:<element[[PACK/SC1] Cannot set kingdom food reserves. Invalid amount specified: <[amount].bold>. Amount must be a number.]>
        - stop

    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.food:<[amount]>


AddKingdomFoodReserves:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Integer)]
    description:
    - Adds the amount specified to the provided kingdom's food reserves and returns the new rate.
    - If the operation fails then the script will return null
    - ---
    - → ?[ElementTag(Integer)]

    script:
    ## Adds the amount specified to the provided kingdom's food reserves and returns the
    ## new rate.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Integer>]
    ##
    ## >>> ?[ElementTag<Integer>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[[PACK/SC1] Cannot set kingdom food reserves. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - stop

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:ValueError message:<element[[PACK/SC1] Cannot set kingdom food reserves. Invalid amount specified: <[amount].bold>. Amount must be a number.]>
        - stop

    - define newAmount <[kingdom].proc[GetKingdomFoodReserves].add[<[amount]>]>
    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.food:<[newAmount]>


GetRiverArea:
    type: procedure
    description:
    - Gets the AreaObject which encompasses the Vexell river area.
    - Will return null if no such object exists.
    - ---
    - → [AreaObject]

    script:
    ## Gets the AreaObject which encompasses the Vexell river area.
    ## Will return null if no such object exists.
    ##
    ## >>> [AreaObject]

    - if !<server.has_flag[kingdoms.scenario-1.river.default.area]>:
        - run GenerateInternalError def.category:GenericError message:<element[[PACK/SC1] River area flag is not set! Please make sure that it is defined before using this addon further!]> def.silent:false
        - determine null

    - determine <server.flag[kingdoms.scenario-1.river.default.area]>


GetKingdomTradeEfficiency:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    description:
    - Gets the provided kingdom's current trade efficiency percentage with Fyndalin.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Gets the provided kingdom's current trade efficiency percentage with Fyndalin.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[[PACK/SC1] Cannot get river obstrustion rate. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - determine <server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.tradeEfficiency].if_null[0]>
