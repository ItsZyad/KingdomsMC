##
## [KAPI]
## Main file of the KAPI common file for kingdom-related common tasks, procedures, and properties
## that allow the dev and contributor to interact with the Kingdoms backend in a more efficient
## and standardized manner.
##
## This file contains the tasks and procs that interact with the related "atomic" values (i.e.
## bools, strings, numbers etc.) like balance, upkeep, and prestige and so forth.
##
## Other files under this folder will include other related aspects of a kingdom.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2023
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

# Note: future configurable(?)
KingdomRealNames:
    type: data
    centran: Dominion of Muspelheim
    viridian: Commonwealth of Viriditas
    raptoran: Republic of Altea
    cambrian: Grovelian Empire
    fyndalin: Fyndalin Trust Territory


KingdomRealShortNames:
    type: data
    centran: Muspelheim
    viridian: Viridia
    raptoran: Altea
    cambrian: Grovelia
    fyndalin: Fyndalin


KingdomTextColors:
    type: data
    centran: blue
    viridian: lime
    raptoran: red
    cambrian: gold
    fyndalin: gray


# Process of adding a new kingdom:
# Add new kingdom data to kingdoms.yml such as balance etc.
# Add influence data for new kingdom to powerstruggle.yml
# Add new kingdom name to kingdoms.yml -> kingdom_real_names
# Copy real kingdom name to KingdomRealNames in this file

GetKingdomList:
    type: procedure
    debug: false
    definitions: isCodeNames[ElementTag(Boolean)]
    script:
    ## Generates a list of all the valid kingdom code names. When isCodeNames is set to false
    ## the procedure generates a list of the full/real kingdom names. isCodeNames is true by default
    ##
    ## isCodeNames : ?[ElementTag<Boolean>]
    ##
    ## >>> [ListTag<[ElementTag<String>]>]

    - define kingdomRealNames <script[KingdomRealNames].data_key[].values.exclude[data]>
    - define kingdomCodeNames <script[KingdomRealNames].data_key[].keys.exclude[type]>
    - define isCodeNames <[isCodeNames].if_null[true]>

    - if <[isCodeNames]>:
        - determine <[kingdomCodeNames]>

    - determine <[kingdomRealNames]>


# TODO: Change name to 'IsValidKingdomCode'
ValidateKingdomCode:
    type: procedure
    definitions: kingdomCode[ElementTag(String)]
    script:
    ## Checks id the kingdom code provided is a valid one.
    ##
    ## kingdomCode : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - determine <[kingdomCode].is_in[<proc[GetKingdomList]>]>


IsKingdomBankrupt:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    script:
    ## Checks if the provided kingdom is bankrupt
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - define balance <proc[GetBalance].context[<[kingdom]>]>

    - if <[balance].is[LESS].than[0]>:
        - if <server.flag[indebtedKingdoms].get[<[kingdom]>].is[OR_MORE].than[4]>:
            - determine true

    - determine false


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
## ATOMIC VALUES
##_________________________________________________________________________________________________
##
## Get/Set/Add/Sub
## - Balance
## - Upkeep
## - Prestige
##
## Get/Set
## - Description
##
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

GetBalance:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    script:
    ## Returns the balance of a given kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.balance]>


SetBalance:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    script:
    ## Sets the balance of a given kingdom to a given amount.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:ValueError message:<element[Cannot set kingdom balance to a value less than zero.]>
        - determine cancelled

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.balance:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


AddBalance:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    script:
    ## Adds a given amount to the provided kingdom's balance
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:ValueError message:<element[Cannot add a value to the kingdom balance less than zero.]>
        - determine cancelled

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.balance:+:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


SubBalance:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    script:
    ## Subtracts a given amount to the provided kingdom's balance
    ##
    ## amount  : [ElementTag<Float>]
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:ValueError message:<element[Cannot subtract a value to the kingdom balance less than zero.]>
        - determine cancelled

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.balance:-:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


GetUpkeep:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    script:
    ## Gets a given kingdom's total daily upkeep
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.upkeep]>


SetUpkeep:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    script:
    ## Sets the upkeep of a given kingdom to a given amount.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:ValueError message:<element[Cannot set kingdom upkeep to a value less than zero.]>
        - determine cancelled

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom upkeep. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.upkeep:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


AddUpkeep:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    script:
    ## Adds a given amount to the provided kingdom's upkeep
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:ValueError message:<element[Cannot add a value to the kingdom upkeep less than zero.]>
        - determine cancelled

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom upkeep. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.upkeep:+:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


SubUpkeep:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    script:
    ## Subtracts a given amount from the kingdom's upkeep
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:ValueError message:<element[Cannot subtract a value to the kingdom upkeep that is less than zero.]>
        - determine cancelled

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom upkeep. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.upkeep:-:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


GetPrestige:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    script:
    ## Gets the given kingdom's prestige.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom prestige. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.prestige]>


SetPrestige:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    script:
    ## Sets the prestige of a kingdom to a given amount.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom prestige. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:TypeError message:<element[Cannot set prestige to a non-number value.]>
        - determine cancelled

    - if <[amount]> > 100 || <[amount]> < 0:
        - run GenerateInternalError def.category:ValueError message:<element[Cannot set prestige to amount higher than 100 or lower than 0.]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.prestige:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


AddPrestige:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    script:
    ## Adds a given amount of prestige to a kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom prestige. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:TypeError message:<element[Cannot set prestige to a non-number value.]>
        - determine cancelled

    - define prestige <proc[GetPrestige].context[<[kingdom]>]>

    - if <[amount].add[<[prestige]>]> > 100:
        - run GenerateInternalError def.category:ValueError message:<element[Cannot set prestige to amount higher than 100.]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.prestige:+:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


SubPrestige:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    script:
    ## Subtracts a given amount of prestige from a kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom prestige. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:TypeError message:<element[Cannot set prestige to a non-number value.]>
        - determine cancelled

    - define prestige <proc[GetPrestige].context[<[kingdom]>]>

    - if <[amount].sub[<[prestige]>]> < 0:
        - run GenerateInternalError def.category:ValueError message:<element[Cannot set prestige to amount lower than 0.]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.prestige:-:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


GetDescription:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    script:
    ## Gets the description of a kingdom. Returns null if there is none.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom description. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if <server.has_flag[kingdoms.<[kingdom]>.description]>:
        - determine <server.has_flag[kingdoms.<[kingdom]>.description]>

    - determine null


SetDescription:
    type: task
    definitions: kingdom[ElementTag(String)]|description[ElementTag(String)]
    script:
    ## Sets the description of a kingdom.
    ##
    ## kingdom     : [ElementTag<String>]
    ## description : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom description. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if <[description].object_type.to_lowercase> != element:
        - run GenerateInternalError def.category:TypeError message:<element[Cannot set description to a non-element value. Value provided is of: <&sq><[description].object_type><&sq> type!]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.description:<[description]>
