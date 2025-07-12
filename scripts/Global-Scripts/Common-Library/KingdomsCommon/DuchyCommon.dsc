##
## [KAPI]
## All scripts here are related to the common aspects of 'Duchies' mechanic, which allows kingdoms
## to divvy up their territory into smaller sub-divisions (duchies) and handing them off to
## separate players who would then be dukes.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jul 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

IsPlayerDuke:
    type: procedure
    definitions: player[PlayerTag]
    description:
    - Returns true if the provided player is a duke of any duchy in their kingdom.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns true if the provided player is a duke of any duchy in their kingdom.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [ElementTag<Boolean>]

    - if <[player].object_type> != Player:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot get if player is a duke. Definition: <[player]> provided is not a valid player.]> def.silent:false
        - determine false

    - define kingdom <player.flag[kingdom]>

    - determine <[kingdom].proc[GetKingdomDuchies].parse_tag[<[kingdom].proc[GetDuke].context[<[parse_value]>]>].contains[<[player]>]>


GetPlayerDuchy:
    type: procedure
    definitions: player[PlayerTag]
    description:
    - Returns the name of the duchy that the provided player is the duke of.
    - If the provided player is not a duke, this procedure will return null.
    - ---
    - → ?[ElementTag(String)]

    script:
    ## Returns the name of the duchy that the provided player is the duke of.
    ## If the provided player is not a duke, this procedure will return null.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> ?[ElementTag<String>]

    - if <[player].object_type> != Player:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot get player duchy. Definition: <[player]> provided is not a valid player.]> def.silent:false
        - determine null

    - define kingdom <player.flag[kingdom]>

    - foreach <[kingdom].proc[GetKingdomDuchies]> as:duchy:
        - if <[kingdom].proc[GetDuke].context[<[duchy]>]> == <[player]>:
            - determine <[duchy]>

    - determine null


GetKingdomDuchies:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    description:
    - Gets all the duchies under the kingdom with the provided name.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Gets all the duchies under the kingdom with the provided name.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom duchies. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine <list[]>

    - determine <server.flag[kingdoms.<[kingdom]>.duchies].keys.if_null[<list[]>]>


GetDuke:
    type: procedure
    definitions: kingdom[ElementTag(String)]|duchy[ElementTag(String)]
    description:
    - Gets the duke of the provided duchy, in the kingdom with the provided name.
    - Will return null if no such duchy exists.
    - ---
    - → ?[PlayerTag]

    script:
    ## Gets the duke of the provided duchy, in the kingdom with the provided name.
    ## Will return null if no such duchy exists.
    ##
    ## kingdom : [ElementTag<String>]
    ## duchy   : [ElementTag<String>]
    ##
    ## >>> ?[PlayerTag]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get duke. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get duke. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.duchies.<[duchy]>.duke].if_null[null]>


SetDuke:
    type: procedure
    definitions: kingdom[ElementTag(String)]|duchy[ElementTag(String)]|player[PlayerTag]
    description:
    - Sets the provided player as the duke of the provided duchy.
    - Will return null if the action fails.
    - ---
    - → ?[Void]

    script:
    ## Sets the provided player as the duke of the provided duchy.
    ## Will return null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## duchy   : [ElementTag<String>]
    ## player  : [PlayerTag]
    ##
    ## >>> ?[Void]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set duke. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set duke. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine null

    - if <[player].object_type> != Player:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set duke. Provided parameter: <[player]> is not a valid player.]> def.silent:false
        - determine null

    - if !<[player].is_in[<[kingdom].proc[GetMembers]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set duke. Provided player is not a part of this kingdom.]> def.silent:false
        - determine null

    - flag server kingdoms.<[kingdom]>.duchies.<[duchy]>.duke:<[player]>


RemoveDuke:
    type: procedure
    definitions: kingdom[ElementTag(String)]|duchy[ElementTag(String)]
    description:
    - Removes the duke of the provided duchy from their role.
    - Will return null if the action fails.
    - ---
    - → ?[Void]

    script:
    ## Removes the duke of the provided duchy from their role.
    ## Will return null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## duchy   : [ElementTag<String>]
    ##
    ## >>> ?[Void]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot unset duke. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot unset duke. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine null

    - flag server kingdoms.<[kingdom]>.duchies.<[duchy]>.duke:!


GetDuchyTerritory:
    type: procedure
    definitions: kingdom[ElementTag(String)]|duchy[ElementTag(String)]
    description:
    - Gets the territory associated with the provided duchy.
    - ---
    - → [ListTag?(ChunkTag)]

    script:
    ## Gets the territory associated with the provided duchy.
    ##
    ## kingdom : [ElementTag<String>]
    ## duchy   : [ElementTag<String>]
    ##
    ## >>> [ListTag?<ChunkTag>]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get duchy territory. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine <list[]>

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get duchy territory. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine <list[]>

    - determine <server.flag[kingdoms.<[kingdom]>.duchies.<[duchy]>.territory]>


AddDuchy:
    type: task
    definitions: kingdom[ElementTag(String)]|duchy[ElementTag(String)]
    description:
    - Creates a new duchy for the provided kingdom with the provided name.
    - ---
    - → ?[Void]

    script:
    ## Creates a new duchy for the provided kingdom with the provided name.
    ##
    ## kingdom : [ElementTag<String>]
    ## duchy   : [ElementTag<String>]
    ##
    ## >>> ?[Void]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot create duchy. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - if <server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy].replace[ ].with[-]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot create duchy. Duchy with provided name: <[duchy]> already exists.]> def.silent:false
        - determine null

    - flag server kingdoms.<[kingdom]>.duchies.<[duchy].replace[ ].with[-]>.territory:<list[]>
    - flag server kingdoms.<[kingdom]>.duchies.<[duchy].replace[ ].with[-]>.name:<[duchy]>


RemoveDuchy:
    type: task
    definitions: kingdom[ElementTag(String)]|duchy[ElementTag(String)]
    description:
    - Deletes a duchy from the provided kingdom with the provided name, along with it all data associated with it.
    - ---
    - → ?[Void]

    script:
    ## Deletes a duchy from the provided kingdom with the provided name, along with it all data
    ## associated with it.
    ##
    ## kingdom : [ElementTag<String>]
    ## duchy   : [ElementTag<String>]
    ##
    ## >>> ?[Void]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot remove duchy. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot remove duchy. Duchy with provided name: <[duchy]> does not exist.]> def.silent:false
        - determine null

    - flag server kingdoms.<[kingdom]>.duchies.<[duchy]>:!


AddDuchyClaim:
    type: task
    definitions: kingdom[ElementTag(String)]|duchy[ElementTag(String)]|chunk[ChunkTag]
    description:
    - Adds the provided chunk to the territory of the provided duchy.
    - Will return null if the action fails.
    - ---
    - → ?[Void]

    script:
    ## Adds the provided chunk to the territory of the provided duchy.
    ## Will return null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## duchy   : [ElementTag<String>]
    ## chunk   : [ChunkTag]
    ##
    ## >>> ?[Void]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot add duchy territory. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot add duchy territory. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine null

    - if <[chunk].object_type> != Chunk:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot add duchy territory. Provided parameter: <[chunk]> is not a valid chunk]> def.silent:false
        - determine null

    - define kingdomCore <proc[GetClaims].context[<[kingdom]>|core]>

    - if !<[chunk].is_in[<[kingdomCore]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot add duchy territory. Provided chunk does not belong to the provided kingdom: <[kingdom]>.<n> Additionally, duchy chunks cannot be claimed from a kingdom<&sq>s castle chunks]> def.silent:false
        - determine null

    - if <[kingdomCore].size> <= 1:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot add duchy territory. Kingdom must have more than one core chunk to designate duchies]> def.silent:false
        - determine null

    - foreach <server.flag[kingdoms.<[kingdom]>.duchies]> as:duchyData:
        - if <[duchyData].get[territory].contains[<[chunk]>]>:
            - run GenerateInternalError def.category:GenericError def.message:<element[Cannot add duchy territory. Provided chunk already belongs to a duchy.]> def.silent:false
            - determine null

    - if !<[chunk].is_in[<server.flag[kingdoms.<[kingdom]>.duchies.<[duchy]>.territory]>]>:
        - flag server kingdoms.<[kingdom]>.duchies.<[duchy]>.territory:->:<[chunk]>


RemoveDuchyClaim:
    type: task
    definitions: kingdom[ElementTag(String)]|duchy[ElementTag(String)]|chunk[ChunkTag]
    description:
    - Removes the provided chunk from the territory of the provided duchy.
    - Will return null if the action fails.
    - ---
    - → ?[Void]

    script:
    ## Removes the provided chunk from the territory of the provided duchy.
    ## Will return null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## duchy   : [ElementTag<String>]
    ## chunk   : [ChunkTag]
    ##
    ## >>> ?[Void]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot remove duchy territory. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot remove duchy territory. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine null

    - if <[chunk].object_type> != Chunk:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot remove duchy territory. Provided parameter: <[chunk]> is not a valid chunk]> def.silent:false
        - determine null

    - if <[chunk].is_in[<server.flag[kingdoms.<[kingdom]>.duchies.<[duchy]>.territory]>]>:
        - flag server kingdoms.<[kingdom]>.duchies.<[duchy]>.territory:<-:<[chunk]>


GetDuchyBalance:
    type: procedure
    definitions: kingdom[ElementTag(String)]|duchy[ElementTag(String)]
    description:
    - Returns the balance of the provided duchy in the provided kingdom.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Returns the balance of the provided duchy in the provided kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ## duchy   : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get duchy balance. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine 0

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get duchy balance. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine 0

    - determine <server.flag[kingdoms.<[kingdom]>.duchies.<[duchy]>.balance].if_null[0]>


SetDuchyBalance:
    type: task
    definitions: kingdom[ElementTag(String)]|duchy[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Sets the balance of the provided duchy in the provided kingdom to the provided amount.
    - Will return null if the action fails.
    - ---
    - → ?[Void]

    script:
    ## Sets the balance of the provided duchy in the provided kingdom to the provided amount.
    ## Will return null if the actions fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## duchy   : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> ?[Void]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set duchy balance. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set duchy balance. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine null

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot set duchy balance. Amount provided is not a valid number.]> def.silent:false
        - determine null

    - flag server kingdoms.<[kingdom]>.duchies.<[duchy]>.balance:<[amount]>


GetDuchyTaxRate:
    type: procedure
    definitions: kingdom[ElementTag(String)]|duchy[ElementTag(String)]
    description:
    - Returns a number between 0-1 representing the tax rate placed by the overall kingdom on the provided duchy (with 1 meaning 100%).
    - ---
    - → [ElementTag(Float)]

    script:
    ## Returns a number between 0-1 representing the tax rate placed by the overall kingdom on the
    ## provided duchy (with 1 meaning 100%).
    ##
    ## kingdom : [ElementTag<String>]
    ## duchy   : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot remove duchy territory. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine 0

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot remove duchy territory. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine 0

    - determine <server.flag[kingdoms.<[kingdom]>.duchies.<[duchy]>.tax].if_null[0]>


SetDuchyTaxRate:
    type: task
    definitions: kingdom[ElementTag(String)]|duchy[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Sets the tax rate levied on the provided duchy in the provided kingdom to the given amount.
    - Will return null if the action fails.
    - ---
    - → ?[Void]

    script:
    ## Sets the tax rate levied on the provided duchy in the provided kingdom to the given amount.
    ## Will return null if the actions fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## duchy   : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> ?[Void]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set duchy tax rate. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set duchy tax rate. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine null

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot set duchy tax rate. Amount provided is not a valid number.]> def.silent:false
        - determine null

    - if <[amount]> > 1 || <[amount]> < 0:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot set duchy tax rate. Amount provided is not a valid percentage.]> def.silent:false
        - determine null

    - flag server kingdoms.<[kingdom]>.duchies.<[duchy]>.tax:<[amount]>


GetDuchyDisplayName:
    type: procedure
    definitions: kingdom[ElementTag(String)]|duchy[ElementTag(String)]
    description:
    - Will return the display name associated with the provided duchy.
    - Will return null if the provided duchy does not exist.
    - ---
    - → ?[ElementTag(String)]

    script:
    ## Will return the display name associated with the provided duchy.
    ## Will return null if the provided duchy does not exist.
    ##
    ## kingdom : [ElementTag<String>]
    ## duchy   : [ElementTag<String>]
    ##
    ## >>> ?[ElementTag<String>]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get duchy display name. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get duchy display name. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.duchies.<[duchy]>.name].if_null[<[duchy]>]>
