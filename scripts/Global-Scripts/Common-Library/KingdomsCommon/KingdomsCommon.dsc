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
        penaltea: The Republic of Penaltea
        muspelheim: The Duchy of Muspelheim

    ShortNames:
        jalerad: Jalerad
        talpenhern: Talpenhern
        penaltea: Penaltea
        muspelheim: Muspelheim


KingdomTextColors:
    type: data
    jalerad: light_blue
    talpenhern: orange
    penaltea: red
    muspelheim: purple

# Process of adding a new kingdom:
# Add new kingdom data to kingdoms.yml such as balance etc.
# Add influence data for new kingdom to powerstruggle.yml
# Add new kingdom name to kingdoms.yml -> kingdom_real_names
# Copy real kingdom name to KingdomRealNames in this file

GetKingdomList:
    type: procedure
    debug: false
    definitions: isCodeNames[?ElementTag(Boolean) = true]
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
    ## isCodeNames : ?[ElementTag<Boolean> = true]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - define kingdomCodeNames <server.flag[kingdoms.kingdomList].keys.if_null[<list[]>]>
    - define kingdomRealNames <server.flag[kingdoms.kingdomList].parse_value_tag[<[parse_value].get[name]>].values.if_null[<list[]>]>
    - define isCodeNames <[isCodeNames].if_null[true]>

    - if <[isCodeNames]>:
        - determine <[kingdomCodeNames]>

    - determine <[kingdomRealNames]>


GetKingdomCode:
    type: procedure
    definitions: kingdomName[ElementTag(String)]
    description:
    - Takes either the short or long name of a kingdom and returns its kingdom code.
    - Will return null if the provided kingdom name is invalid.
    - ---
    - → ?[ElementTag(String)]

    script:
    ## Takes either the short or long name of a kingdom and returns its kingdom code.
    ##
    ## Will return null if the provided kingdom name is invalid.
    ##
    ## kingdomName : [ElementTag<String>]
    ##
    ## >>> ?[ElementTag<String>]

    - define kingdomRealNames <server.flag[kingdoms.kingdomList].parse_value_tag[<[parse_value].get[name]>].values.if_null[<list[]>]>
    - define kingdomRealShortNames <server.flag[kingdoms.kingdomList].parse_value_tag[<[parse_value].get[shortName]>].values.if_null[<list[]>]>

    - if <[kingdomName].is_in[<[kingdomRealShortNames].get[ShortNames].values>]>:
        - determine <[kingdomRealNames].get[ShortNames].invert.get[<[kingdomName]>]>

    - else if <[kingdomName].is_in[<[kingdomRealNames].get[Names].values>]>:
        - determine <[kingdomRealNames].get[Names].invert.get[<[kingdomName]>]>

    - determine null


IsKingdomCodeValid:
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

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - define balance <proc[GetBalance].context[<[kingdom]>]>

    - if <[balance].is[LESS].than[0]>:
        - if <server.flag[indebtedKingdoms].get[<[kingdom]>].is[OR_MORE].than[4]>:
            - determine true

    - determine false


IsPlayerKingdomless:
    type: procedure
    definitions: player[PlayerTag]
    description:
    - Returns true if the provided player is not a member of any kingdom.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns true if the provided player is not a member of any kingdom.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [ElementTag(Boolean)]

    - if !<[player].is_player>:
        - debug ERROR "Provided argument: <[player].color[red]> is not a valid player object."
        - determine true

    - define allMembers <proc[GetKingdomList].parse_tag[<[parse_value].proc[GetMembers]>].combine>

    - if <[allMembers].contains[<[player]>]>:
        - determine false

    - determine true


CreateKingdom:
    type: task
    definitions: kingdomShortName[ElementTag(String)]|kingdomLongName[ElementTag(String)]|codeName[?ElementTag(String)]
    description:
    - [Experimental]
    - Creates a new kingdom and returns the code name assigned to it.
    - Requires 'short' and 'long' names, and optionally a pre-set code name. Kingdoms must have a short and long name, however they can be both set to the same name.
    - If a kingdom's long name is, for example, 'The United Duchies of Jalerad', its short name would just be 'Jalerad'. Alternatively, a player could choose to have both names simply be 'Jalerad'.
    - A code name is then automatically generated from the first word of the short name, if no custom code name is provided.
    - ---
    - → [ElementTag(String)]

    script:
    ## [Experimental]
    ## Creates a new kingdom and returns the code name assigned to it.
    ## Requires 'short' and 'long' names, and optionally a pre-set code name. Kingdoms must have a
    ## short and long name, however they can be both set to the same name.
    ##
    ## If a kingdom's long name is, for example, 'The United Duchies of Jalerad', its short name
    ## would just be 'Jalerad'. Alternatively, a player could choose to have both names simply be
    ## 'Jalerad'.
    ##
    ## A code name is then automatically generated from the first word of the short name, if no custom code name is provided.
    ##
    ## kingdomShortName :  [ElementTag(String)]
    ## kingdomLongName  :  [ElementTag(String)]
    ## codeName         : ?[ElementTag(String)]
    ##
    ## >>> [ElementTag(String)]

    - if <proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomShortName]>].contains[<[kingdomShortName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot create new kingdom. Kingdom with provided name: <[kingdomShortName].color[red]> already exists.]>
        - determine null

    - if <proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomName]>].contains[<[kingdomLongName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot create new kingdom. Kingdom with provided name: <[kingdomLongName].color[red]> already exists.]>
        - determine null

    - if <[codeName].exists> && <proc[GetKingdomList].contains[<[codeName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot create new kingdom. Provided with custom code name that already exists: <[codeName].color[red]>.]>
        - determine null

    # Extracts the first word of the shortName and makes that the code name. If the first word is
    # 'The', it is ignored and the next valid word is selected.
    - define codeName <[codeName].if_null[<[kingdomShortName].split[ ].filter_tag[<[filter_value].to_lowercase.equals[the].not>].get[1].to_lowercase>]>

    - flag server kingdoms.kingdomList.<[codeName]>.shortName:<[kingdomShortName]>
    - flag server kingdoms.kingdomList.<[codeName]>.name:<[kingdomLongName]>

    - determine <[codeName]>


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

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]>
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
        - run GenerateInternalError def.category:ValueError def.message:<element[Cannot set kingdom balance to a value less than zero.]>
        - determine cancelled

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.balance:<[amount]>
    - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>


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
        - run GenerateInternalError def.category:ValueError def.message:<element[Cannot add a value to the kingdom balance less than zero.]>
        - determine cancelled

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.balance:+:<[amount]>
    - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>


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
        - run GenerateInternalError def.category:ValueError def.message:<element[Cannot subtract a value to the kingdom balance less than zero.]>
        - determine cancelled

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.balance:-:<[amount]>
    - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>


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

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - definemap allUpkeep:
        coreClaimsCost: <proc[GetClaims].context[<[kingdom]>|core].size.mul[<proc[GetConfigNode].context[Territory.core-chunk-upkeep]>]>
        castleClaimsCost: <proc[GetClaims].context[<[kingdom]>|castle].size.mul[<proc[GetConfigNode].context[Territory.castle-chunk-upkeep]>]>
        standaloneUpkeep: <server.flag[kingdoms.<[kingdom]>.upkeep].if_null[0]>

    - determine <[allUpkeep].values.sum>


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
        - run GenerateInternalError def.category:ValueError def.message:<element[Cannot set kingdom upkeep to a value less than zero.]>
        - determine cancelled

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom upkeep. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.upkeep:<[amount]>
    - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>


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
        - run GenerateInternalError def.category:ValueError def.message:<element[Cannot add a value to the kingdom upkeep less than zero.]>
        - determine cancelled

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom upkeep. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.upkeep:+:<[amount]>
    - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>


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
        - run GenerateInternalError def.category:ValueError def.message:<element[Cannot subtract a value to the kingdom upkeep that is less than zero.]>
        - determine cancelled

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom upkeep. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.upkeep:-:<[amount]>
    - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>


## |-------------------------------------------------------------------------------------------| ##
## *--- IMPORTANT NOTICE!                                                                        ##
## *--- The scripts in the enclosed section are testing an experimental feature which reworks a  ##
## *--- fundemental system in Kingdoms - upkeep.                                                 ##
## |-------------------------------------------------------------------------------------------| ##

AddUpkeepObject:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Float)]|object[ObjectTag]|objectInfo[ListTag(ObjectTag)]
    description:
    - [Experimental]
    - Alternative way of managing kingdom upkeep. Pre-coded 'objects' that upkeep can be 'attached' to must be provided to the `object` parameter as well as the kingdom and upkeep amount.
    - Later, if upkeep needs to be removed from a kingdom (upkeep object no longer exists - e.g. squad is deleted, or territory is unclaimed).
    - In addition to the object, additional information about the object may be provided in the form of a ListTag - for example if the object is a claimed chunk, objectInfo may be provided in the form [233,76,world]
    - ---
    - → [Void]

    script:
    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot change kingdom upkeep. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine cancelled

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot change kingdom upkeep. Provided amount value: <[amount].color[red]> is not a valid decimal.]>
        - determine cancelled

    - if !<[object].is_in[<script.data_key[ObjectBehavior].keys>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot change kingdom upkeep. Provided value: <[object].color[red]> is not a valid upkeep object. Unclassified upkeep can be filed under the <element[<&sq>generic<&sq>].color[aqua]> object]>
        - determine cancelled

    - inject <script> path:ObjectBehavior.<[object].to_titlecase>

    # Each valid object should have a subpath here which stores and handles its information
    # accordingly.
    ObjectBehavior:
        Claim:
        - define objectInfo <[objectInfo].if_null[<list[]>]>

        - if <[objectInfo].is_empty>:
            - run GenerateInternalError def.category:GenericError def.message:<element[Cannot change kingdom upkeep. ObjectInfo required!]>
            - determine cancelled

        - if <[objectInfo].get[1].object_type> != Chunk:
            - run GenerateInternalError def.category:TypeError def.message:<element[Cannot change kingdom upkeep. Provided chunk information is not valid or incorrectly formatted!]>
            - determine cancelled

        - flag server kingdoms.<[kingdom]>.upkeepData.claims.<[objectInfo].get[1]>:<[amount]>


RemoveUpkeepObject:
    type: task
    definitions: kingdom[ElementTag(String)]|object[ObjectTag]|objectInfo[ListTag(ObjectTag)]
    description:
    - [Experimental]
    - Searches the provided kingdom for the provided upkeep object and removes it. Automatically recalculates total upkeep.
    - ---
    - → [Void]

    script:
    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot change kingdom upkeep. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine cancelled

    - if !<[object].is_in[<script.data_key[ObjectBehavior].keys>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot change kingdom upkeep. Provided value: <[object].color[red]> is not a valid upkeep object. Unclassified upkeep can be filed under the <element[<&sq>generic<&sq>].color[aqua]> object]>
        - determine cancelled

    - inject <script> path:ObjectBehavior.<[object].to_titlecase>

    # Each valid object should have a subpath here which stores and handles its information
    # accordingly.
    ObjectBehavior:
        Claim:
        - define objectInfo <[objectInfo].if_null[<list[]>]>

        - if <[objectInfo].is_empty>:
            - run GenerateInternalError def.category:GenericError def.message:<element[Cannot change kingdom upkeep. ObjectInfo required!]>
            - determine cancelled

        - if <[objectInfo].get[1].object_type> != Chunk:
            - run GenerateInternalError def.category:TypeError def.message:<element[Cannot change kingdom upkeep. Provided chunk information is not valid or incorrectly formatted!]>
            - determine cancelled

        - if <server.has_flag[kingdoms.<[kingdom]>.upkeepData.claims.<[objectInfo].get[1]>]>:
            - flag server kingdoms.<[kingdom]>.upkeepData.claims.<[objectInfo].get[1]>:!


RecalculateKingdomUpkeep:
    type: task
    definitions: kingdom[ElementTag(String)]|upkeepData[ObjectTag]
    description:
    - [Experimental]
    - Adds together all of the provided kingdom's upkeep objects and returns the sum.
    - ---
    - → [ElementTag(Float)]

    script:
    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot calculate kingdom upkeep. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine cancelled

    - define runningTotal 0

    - if <[upkeepData].object_type.is_in[List|Map]>:
        - foreach <[upkeepData]>:
            - run <script.name> def.kingdom:<[kingdom]> def.upkeepData:<[value]> save:recurTotal
            - define runningTotal:+:<entry[recurTotal].created_queue.determination.get[1]>

    - else:
        - define runningTotal:+:<[upkeepData]>

    - narrate format:debug <[runningTotal]>
    - determine <[runningTotal]>


## |-------------------------------------------------------------------------------------------| ##

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

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom prestige. Invalid kingdom code provided: <[kingdom]>]>
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

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom prestige. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot set prestige to a non-number value.]>
        - determine cancelled

    - if <[amount]> > 100 || <[amount]> < 0:
        - run GenerateInternalError def.category:ValueError def.message:<element[Cannot set prestige to amount higher than 100 or lower than 0.]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.prestige:<[amount]>
    - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>


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

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom prestige. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot set prestige to a non-number value.]>
        - determine cancelled

    - define prestige <proc[GetPrestige].context[<[kingdom]>]>

    - if <[amount].add[<[prestige]>]> > 100:
        - run GenerateInternalError def.category:ValueError def.message:<element[Cannot set prestige to amount higher than 100.]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.prestige:+:<[amount]>
    - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>


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

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom prestige. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot set prestige to a non-number value.]>
        - determine cancelled

    - define prestige <proc[GetPrestige].context[<[kingdom]>]>

    - if <[amount].sub[<[prestige]>]> < 0:
        - run GenerateInternalError def.category:ValueError def.message:<element[Cannot set prestige to amount lower than 0.]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.prestige:-:<[amount]>
    - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>


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

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom description. Invalid kingdom code provided: <[kingdom]>]>
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

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom description. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if <[description].object_type.to_lowercase> != element:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot set description to a non-element value. Value provided is of: <&sq><[description].object_type><&sq> type!]>
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

    - if !<proc[IsKingdomCodeValid].context[<[kingdomCode]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom name. Invalid kingdom code provided: <[kingdomCode]>]>
        - determine null

    - determine <server.flag[kingdoms.kingdomList.<[kingdomCode]>.name]>


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

    - if !<proc[IsKingdomCodeValid].context[<[kingdomCode]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom name. Invalid kingdom code provided: <[kingdomCode]>]>
        - determine null

    - determine <server.flag[kingdoms.kingdomList.<[kingdomCode]>.shortName]>


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

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom color. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - define rawKingdomColor <server.flag[kingdoms.<[kingdom]>.color].if_null[<color[#ffffff]>]>
    - define outputColor <color[#ffffff]>

    - if <[rawKingdomColor].as[color].exists>:
        - define outputColor <[rawKingdomColor].as[color]>

    - else:
        - define outputColor <proc[GetColor].context[Default.<[rawKingdomColor]>].as[color]>

    - determine <[outputColor]>


GetKingdomMaxDuchyCount:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    description:
    - Gets the maximum number of duchies that this kingdom can create.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Gets the maximum number of duchies that this kingdom can create.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom max duchy count. Invalid kingdom code provided: <[kingdom]>]>
        - determine 0

    - determine <server.flag[kingdoms.<[kingdom]>.duchies.maxDuchies].if_null[0]>
