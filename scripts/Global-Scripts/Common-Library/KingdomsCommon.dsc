##
## Common scripts, procedures, and properties that allow the dev and contributor to interact with
## the Kingdoms backend in a more efficient and standardized manner.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2023
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

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
    definitions: isCodeNames
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


ValidateKingdomCode:
    type: procedure
    definitions: kingdomCode
    script:
    ## Checks id the kingdom code provided (e.g. 'raptoran') is a valid one.
    ##
    ## kingdomCode : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - determine <[kingdomCode].is_in[<proc[GetKingdomList]>]>


GetBalance:
    type: procedure
    definitions: kingdom
    script:
    ## Returns the balance of a given kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - determine <server.flag[kingdoms.<[kingdom]>.balance]>


SetBalance:
    type: task
    definitions: kingdom|amount
    script:
    ## Sets the balance of a given kingdom to a given amount.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:generic message:<element[Cannot set kingdom balance to a value less than zero.]> def.id:002
        - determine cancelled

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.balance:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


AddBalance:
    type: task
    definitions: kingdom|amount
    script:
    ## Adds a given amount to the provided kingdom's balance
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:generic message:<element[Cannot add a value to the kingdom balance less than zero.]> def.id:002
        - determine cancelled

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.balance:+:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


SubBalance:
    type: task
    definitions: kingdom|amount
    script:
    ## Subtracts a given amount to the provided kingdom's balance
    ##
    ## amount  : [ElementTag<Float>]
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:generic message:<element[Cannot subtract a value to the kingdom balance less than zero.]> def.id:002
        - determine cancelled

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.balance:-:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


GetUpkeep:
    type: procedure
    definitions: kingdom
    script:
    ## Gets a given kingdom's total daily upkeep
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set kingdom balance. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - determine <server.flag[kingdoms.<[kingdom]>.upkeep]>


SetUpkeep:
    type: task
    definitions: kingdom|amount
    script:
    ## Sets the upkeep of a given kingdom to a given amount.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:generic message:<element[Cannot set kingdom upkeep to a value less than zero.]> def.id:002
        - determine cancelled

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set kingdom upkeep. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.upkeep:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


AddUpkeep:
    type: task
    definitions: kingdom|amount
    script:
    ## Adds a given amount to the provided kingdom's upkeep
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:generic message:<element[Cannot add a value to the kingdom upkeep less than zero.]> def.id:002
        - determine cancelled

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set kingdom upkeep. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.upkeep:+:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


SubUpkeep:
    type: task
    definitions: kingdom|amount
    script:
    ## Subtracts a given amount from the kingdom's upkeep
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:generic message:<element[Cannot subtract a value to the kingdom upkeep that is less than zero.]> def.id:002
        - determine cancelled

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set kingdom upkeep. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.upkeep:-:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


IsKingdomBankrupt:
    type: procedure
    definitions: kingdom
    script:
    ## Checks if the provided kingdom is bankrupt
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - define balance <proc[GetBalance].context[<[kingdom]>]>

    - if <[balance].is[LESS].than[0]>:
        - if <server.flag[indebtedKingdoms].get[<[kingdom]>].is[OR_MORE].than[4]>:
            - determine true

    - determine false


GetMembers:
    type: procedure
    definitions: kingdom
    script:
    ## Returns a list of all the members currently in the kingdom
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ListTag<PlayerTag>]

    - determine <server.flag[kingdoms.<[kingdom]>.members]>


GetAllMembers:
    type: procedure
    script:
    ## Returns a list of all the members in all kingdoms
    ##
    ## >>> [ListTag<PlayerTag>]

    - define allKingdoms <proc[GetKingdomList]>
    - determine <[allKingdoms].parse_tag[<server.flag[kingdoms.<[parse_value]>.members]>].combine.deduplicate>


GetClaims:
    type: procedure
    definitions: kingdom|type
    script:
    ## Gets a list of the provided claim type pertaining to the provided kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ## type    : ?[ElementTag<String>]
    ##         | Default Val: core
    ##
    ## >>> [ListTag<ChunkTag>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - define type <[type].if_null[core]>

    - choose <[type]>:
        - case castle:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.castle]>

        - default:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.core]>


GetAllOutposts:
    type: procedure
    definitions: kingdom
    script:
    ## Generates a MapTag of all the kingdom's outposts with an additional key added for the
    ## outpost's area represented as a cuboid.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [MapTag<CuboidTag;ElementTag(...);>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - if <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].if_null[<list>].is_empty>:
        - determine <map[]>

    - define outpostMap <map[]>

    - foreach <server.flag[kingdoms.<[kingdom]>.outposts.outpostList]> key:outpostName as:outpost:
        - define cornerOne <[outpost].get[cornerone].simple.split[,].remove[last].separated_by[,]>
        - define cornerTwo <[outpost].get[cornertwo].simple.split[,].remove[last].separated_by[,]>
        - define outpostCuboid <cuboid[<player.location.world.name>,<[cornerOne]>,<[cornerTwo]>]>
        - define outpostData <[outpost].exclude[cornerone|cornertwo].include[area=<[outpostCuboid]>]>
        - define outpostMap.<[outpostName]>:<[outpostData]>

    - determine <[outpostMap]>


# TODO: Check which one of these is more performant
ALT_GetAllOutposts:
    type: procedure
    definitions: kingdom
    script:
    ## Generates a MapTag of all the kingdom's outposts with an additional key added for the
    ## outpost's area represented as a cuboid.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [MapTag<CuboidTag;ElementTag;>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - if <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].if_null[<list>].is_empty>:
        - determine <map[]>

    - determine <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].parse_value_tag[<[parse_value].exclude[cornerone|cornertwo]>].include[<cuboid[<player.location.world.name>,<[parse_value].get[cornerone].simple.split[,].remove[last].separated_by[,]>,<[parse_value].get[cornertwo].simple.split[,].remove[last].separated_by[,]>]>]>


GetClaimsPolygon:
    type: procedure
    definitions: kingdom|world
    script:
    ## Returns a polygon created of all the chunks consisting a kingdom's core/castle claims
    ##
    ## kingdom : [ElementTag<String>]
    ## world   : [WorldTag]
    ##
    ## >>> [PolygonTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - if <[world].has_flag[dynmap.cache.<[kingdom]>.cornerList]>:
        - define formattedCornerList <[world].flag[dynmap.cache.<[kingdom]>.cornerList].parse_tag[<[parse_value].x>,<[parse_value].z>]>
        - determine <polygon[<[world].name>,0,255,<[formattedCornerList]>]>

    # TODO: make it fire the dynmap polygon generator when a permanent name is decided upon

    - determine cancelled