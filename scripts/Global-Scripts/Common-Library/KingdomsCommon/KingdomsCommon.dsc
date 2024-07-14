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
## ------------------------------------------END HEADER-------------------------------------------

# Note: future configurable(?)
KingdomRealNames:
    type: data
    Names:
        jalerad: The United Duchies of Jalerad
        talpenhern: The Empire of Talpenhern

    ShortNames:
        jalerad: Jalerad
        talpenhern: Talpenhern


KingdomTextColors:
    type: data
    jalerad: light_blue
    talpenhern: orange

# Process of adding a new kingdom:
# Add new kingdom data to kingdoms.yml such as balance etc.
# Add influence data for new kingdom to powerstruggle.yml
# Add new kingdom name to kingdoms.yml -> kingdom_real_names
# Copy real kingdom name to KingdomRealNames in this file

GetKingdomList:
    type: procedure
    debug: false
    definitions: isCodeNames[?ElementTag(Boolean)]
    description:
    - Generates a list of all the valid kingdom code names.
    - When isCodeNames is set to false the procedure generates a list of the full/real kingdom names.
    - isCodeNames is true by default.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Generates a list of all the valid kingdom code names. When isCodeNames is set to false
    ## the procedure generates a list of the full/real kingdom names. isCodeNames is true by default
    ##
    ## isCodeNames : ?[ElementTag<Boolean>]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - define kingdomRealNames <script[KingdomRealNames].data_key[Names].values>
    - define kingdomCodeNames <script[KingdomRealNames].data_key[Names].keys>
    - define isCodeNames <[isCodeNames].if_null[true]>

    - if <[isCodeNames]>:
        - determine <[kingdomCodeNames]>

    - determine <[kingdomRealNames]>


# TODO: Change name to 'IsValidKingdomCode'
ValidateKingdomCode:
    type: procedure
    debug: false
    definitions: kingdomCode[ElementTag(String)]
    description:
    - Checks id the kingdom code provided is a valid one.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Checks id the kingdom code provided is a valid one.
    ##
    ## kingdomCode : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - determine <[kingdomCode].is_in[<proc[GetKingdomList]>]>


IsKingdomBankrupt:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Checks if the provided kingdom is bankrupt
    - ---
    - → [ElementTag(Boolean)]

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
## Get
## - Name/ShortName
## - Color
## - War Status
##
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

GetBalance:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Returns the balance of a given kingdom.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Returns the balance of a given kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.balance].if_null[0]>


SetBalance:
    type: task
    debug: false
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Sets the balance of a given kingdom to a given amount.
    - ---
    - → [Void]

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
    debug: false
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Adds a given amount to the provided kingdom's balance.
    - ---
    - → [Void]

    script:
    ## Adds a given amount to the provided kingdom's balance.
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
    debug: false
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Subtracts a given amount to the provided kingdom's balance.
    - ---
    - → [Void]

    script:
    ## Subtracts a given amount to the provided kingdom's balance.
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
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Gets a given kingdom's total daily upkeep.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Gets a given kingdom's total daily upkeep.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.upkeep].if_null[0]>


SetUpkeep:
    type: task
    debug: false
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Sets the upkeep of a given kingdom to a given amount.
    - ---
    - → [Void]

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
    debug: false
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Adds a given amount to the provided kingdom's upkeep.
    - ---
    - → [Void]

    script:
    ## Adds a given amount to the provided kingdom's upkeep.
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
    debug: false
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Subtracts a given amount from the kingdom's upkeep.
    - ---
    - → [Void]

    script:
    ## Subtracts a given amount from the kingdom's upkeep.
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
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Gets the given kingdom's prestige.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Gets the given kingdom's prestige.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom prestige. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.prestige].if_null[0]>


SetPrestige:
    type: task
    debug: false
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Sets the prestige of a kingdom to a given amount.
    - ---
    - → [Void]

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
    debug: false
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Adds a given amount of prestige to a kingdom.
    - ---
    - → [Void]

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
    debug: false
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Subtracts a given amount of prestige from a kingdom.
    - ---
    - → [Void]

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
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Gets the description of a kingdom. Returns null if there is none.
    - ---
    - → [ElementTag(String)]

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
    debug: false
    definitions: kingdom[ElementTag(String)]|description[ElementTag(String)]
    description:
    - Sets the description of a kingdom.
    - ---
    - → [Void]

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


GetKingdomName:
    type: procedure
    debug: false
    definitions: kingdomCode[ElementTag(String)]
    description:
    - Gets the current display name for the kingdom with the provided kingdom code.
    - ---
    - → [ElementTag(String)]

    script:
    ## Gets the current display name for the kingdom with the provided kingdom code.
    ##
    ## kingdomCode : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - if !<proc[ValidateKingdomCode].context[<[kingdomCode]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom name. Invalid kingdom code provided: <[kingdomCode]>]>
        - determine null

    - determine <script[KingdomRealNames].data_key[Names.<[kingdomCode]>]>


GetKingdomShortName:
    type: procedure
    debug: false
    definitions: kingdomCode
    description:
    - Gets the current shorthand display name for the kingdom with the provided kingdom code.
    - For example a kingdom called 'The Duchy of Jalerad' would have a shorthand of 'Jalerad'.
    - ---
    - → [ElementTag(String)]

    script:
    ## Gets the current shorthand display name for the kingdom with the provided kingdom code.
    ## For example a kingdom called 'The Duchy of Jalerad' would have a shorthand of 'Jalerad'.
    ##
    ## kingdomCode : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - if !<proc[ValidateKingdomCode].context[<[kingdomCode]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom name. Invalid kingdom code provided: <[kingdomCode]>]>
        - determine null

    - determine <script[KingdomRealNames].data_key[ShortNames.<[kingdomCode]>]>


GetKingdomColor:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Gets the provided kingdom's color.
    - ---
    - → [ColorTag]

    script:
    ## Gets the provided kingdom's color.
    ##
    ## kingdom :  [ElementTag<String>]
    ##
    ## >>> [ColorTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom color. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - define rawKingdomColor <script[KingdomTextColors].data_key[<[kingdom]>]>
    - define outputColor <color[#ffffff]>

    - if <[rawKingdomColor].as[color].exists>:
        - define outputColor <[rawKingdomColor].as[color]>

    - else:
        - define outputColor <proc[GetColor].context[Default.<[rawKingdomColor]>].as[color]>

    - determine <[outputColor]>
