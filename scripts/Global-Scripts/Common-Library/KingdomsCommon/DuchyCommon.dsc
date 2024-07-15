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

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom duchies. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
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

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get duke. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get duke. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.duchies.<[duchy]>.duke]>


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

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get duchy territory. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine <list[]>

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get duchy territory. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine <list[]>

    - determine <server.flag[kingdoms.<[kingdom]>.duchies.<[duchy]>.territory]>


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

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot add duchy territory. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot add duchy territory. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine null

    - if <[chunk].object_type> != Chunk:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot add duchy territory. Provided parameter: <[chunk]> is not a valid chunk]> def.silent:false
        - determine null

    - define kingdomCore <proc[GetClaims].context[<[kingdom]>|core]>

    - if !<[chunk].is_in[<[kingdomCore]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot add duchy territory. Provided chunk does not belong to the provided kingdom: <[kingdom]>.<n> Additionally, duchy chunks cannot be claimed from a kingdom<&sq>s castle chunks]> def.silent:false
        - determine null

    - if <[kingdomCore].size> <= 1:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot add duchy territory. Kingdom must have more than one core chunk to designate duchies]> def.silent:false
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

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot remove duchy territory. Invalid kingdom code provided: <[kingdom]>]> def.silent:false
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot remove duchy territory. Invalid duchy name provided: <[duchy]>]> def.silent:false
        - determine null

    - if <[chunk].object_type> != Chunk:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot remove duchy territory. Provided parameter: <[chunk]> is not a valid chunk]> def.silent:false
        - determine null

    - if <[chunk].is_in[<server.flag[kingdoms.<[kingdom]>.duchies.<[duchy]>.territory]>]>:
        - flag server kingdoms.<[kingdom]>.duchies.<[duchy]>.territory:<-:<[chunk]>
