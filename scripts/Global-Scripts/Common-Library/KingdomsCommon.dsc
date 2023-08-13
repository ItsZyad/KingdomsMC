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


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
## ATOMIC VALUES
##_________________________________________________________________________________________________
##
## Get/Set/Add/Sub
## - Balance
## - Upkeep
## - Prestige
##
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

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


GetPrestige:
    type: procedure
    definitions: kingdom
    script:
    ## Gets the given kingdom's prestige.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot get kingdom prestige. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - determine <server.flag[kingdoms.<[kingdom]>.prestige]>


SetPrestige:
    type: task
    definitions: kingdom|amount
    script:
    ## Sets the prestige of a kingdom to a given amount.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set kingdom prestige. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set prestige to a non-number value.]> def.id:005
        - determine cancelled

    - if <[amount]> > 100 || <[amount]> < 0:
        - run GenerateInternalError def.category:generic message:<element[Cannot set prestige to amount higher than 100 or lower than 0.]> def.id:004
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.prestige:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


AddPrestige:
    type: task
    definitions: kingdom|amount
    script:
    ## Adds a given amount of prestige to a kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set kingdom prestige. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set prestige to a non-number value.]> def.id:005
        - determine cancelled

    - define prestige <proc[GetPrestige].context[<[kingdom]>]>

    - if <[amount].add[<[prestige]>]> > 100:
        - run GenerateInternalError def.category:generic message:<element[Cannot set prestige to amount higher than 100.]> def.id:004
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.prestige:+:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


SubPrestige:
    type: task
    definitions: kingdom|amount
    script:
    ## Subtracts a given amount of prestige from a kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set kingdom prestige. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:generic message:<element[Cannot set prestige to a non-number value.]> def.id:005
        - determine cancelled

    - define prestige <proc[GetPrestige].context[<[kingdom]>]>

    - if <[amount].sub[<[prestige]>]> < 0:
        - run GenerateInternalError def.category:generic message:<element[Cannot set prestige to amount lower than 0.]> def.id:004
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.prestige:-:<[amount]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


GetMembers:
    type: procedure
    definitions: kingdom
    script:
    ## Returns a list of all the members currently in the kingdom
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ListTag<PlayerTag>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.members]>


AddMember:
    type: task
    definitions: kingdom|player
    script:
    ## Adds a player to a given kingdom
    ##
    ## kingdom : [ElementTag<String>]
    ## player  : [PlayerTag]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - if !<[player].as[entity].is_player>:
        # TODO: Add new error system
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.members:->:<[player]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


RemoveMember:
    type: task
    definitions: kingdom|player
    script:
    ## Removes the given player from a kingdom if they are a member.
    ##
    ## kingdom : [ElementTag<String>]
    ## player  : [PlayerTag]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - if !<[player].as[entity].is_player>:
        # TODO: Add new error system
        - determine cancelled

    - if <proc[GetMembers].context[<[kingdom]>].contains[<[player]>]>:
        - flag server kingdoms.<[kingdom]>.members:<-:<[player]>
        - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


GetAllMembers:
    type: procedure
    script:
    ## Returns a list of all the members in all kingdoms
    ##
    ## >>> [ListTag<PlayerTag>]

    - determine <proc[GetKingdomList].parse_tag[<server.flag[kingdoms.<[parse_value]>.members]>].combine.deduplicate>


IsKingdomBankrupt:
    type: procedure
    definitions: kingdom
    script:
    ## Checks if the provided kingdom is bankrupt
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - define balance <proc[GetBalance].context[<[kingdom]>]>

    - if <[balance].is[LESS].than[0]>:
        - if <server.flag[indebtedKingdoms].get[<[kingdom]>].is[OR_MORE].than[4]>:
            - determine true

    - determine false


GetClaims:
    type: procedure
    definitions: kingdom|type
    script:
    ## Gets a list of the provided claim type pertaining to the provided kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ## type    : ?[ElementTag<String>]
    ##
    ## >>> [ListTag<ChunkTag>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - choose <[type]>:
        - case castle:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.castle]>

        - case core:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.core]>

        - default:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.castle].include[<server.flag[kingdoms.<[kingdom]>.claims.core]>]>


GetClaimsCuboid:
    type: procedure
    definitions: kingdom|type
    script:
    ## Returns a nested cuboid of the given kingdom's claims. Should a claim type not be specified
    ## the procedure will assume 'core/castle'.
    ##
    ## kingdom : [ElementTag<String>]
    ## type    : ?[ElementTag<String>]
    ##         | Valid values:   core, castle, castlecore
    ##         | Default values: castlecore
    ##
    ## >>> [CuboidTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:generic message:<element[Invalid kingdom code provided: <[kingdom]>]> def.id:003
        - determine cancelled

    - choose <[type]>:
        - case castle:
            - define claims <server.flag[kingdoms.<[kingdom]>.claims.castle].if_null[<list[]>]>

        - case core:
            - define claims <server.flag[kingdoms.<[kingdom]>.claims.core].if_null[<list[]>]>

        - default:
            - define claims <server.flag[kingdoms.<[kingdom]>.claims.castle].if_null[<list[]>].include[<server.flag[kingdoms.<[kingdom]>.claims.core].if_null[<list[]>]>]>

    - if <[claims].is_empty>:
        - determine cancelled

    - define claimCuboid <[claims].get[1].cuboid>

    - foreach <[claims].remove[1]>:
        - define claimCuboid <[claimCuboid].add_member[<[value].cuboid>]>

    - determine <[claimCuboid]>


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


GetAllOutposts:
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

    - determine <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].parse_value_tag[<[parse_value].include[area=<cuboid[<[parse_value].get[cornerone].world.name>,<[parse_value].get[cornerone].simple.split[,].remove[last].separated_by[,]>,<[parse_value].get[cornertwo].simple.split[,].remove[last].separated_by[,]>]>].exclude[cornerone|cornertwo]>]>
