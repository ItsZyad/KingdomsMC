##
## [KAPI]
## Common scripts, tasks, and procedures relating to the core and castle territory of a kingdom
## only.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2023
## @Script Ver: v1.2
##
## ------------------------------------------END HEADER-------------------------------------------

IsPlayerInCore:
    type: procedure
    definitions: player[PlayerTag]
    description:
    - Checks if a player is in their own kingdom's core claims.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Checks if a player is in their own kingdom's core claims.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [ElementTag<Boolean>]

    - if !<[player].has_flag[kingdom]>:
        - determine false

    - define kingdom <[player].flag[kingdom]>

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot check kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine false

    - determine <[player].location.chunk.is_in[<proc[GetClaims].context[<[kingdom]>|core]>]>


IsPlayerInCastle:
    type: procedure
    definitions: player[PlayerTag]
    description:
    - Checks if a player is in their own castle claims.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Checks if a player is in their own castle claims.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [ElementTag<Boolean>]

    - if !<[player].has_flag[kingdom]>:
        - determine false

    - define kingdom <[player].flag[kingdom]>

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot check kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine false

    - determine <[player].location.chunk.is_in[<proc[GetClaims].context[<[kingdom]>|castle]>]>


GetAllClaims:
    type: procedure
    debug: false
    definitions: type[?ElementTag(String)]
    description:
    - Gets all claims of the provided type made by all kingdoms.
    - If no type is specified, the procedure will return all claims of all types.
    - ---
    - → [ListTag(ChunkTag)]

    script:
    ## Gets all claims of the provided type made by all kingdoms. If no type is specified, the
    ## procedure will return all claims of all types.
    ##
    ## type : ?[ElementTag<String>]
    ##
    ## >>> [ListTag<ChunkTag>]

    - define allClaims <list[]>
    - define type <[type].if_null[null]>

    - if <[type]> == null:
        - define allClaims <server.flag[kingdoms.claimInfo.allClaims].if_null[<list[]>]>

    - else:
        - foreach <proc[GetKingdomList]> as:kingdom:
            - define allClaims <[allClaims].include[<server.flag[kingdoms.<[kingdom]>.claims.<[type]>].if_null[<list[]>]>]>

    - determine <[allClaims]>


GetClaims:
    type: procedure
    definitions: kingdom[ElementTag(String)]|type[?ElementTag(String)]
    description:
    - Gets a list of the provided claim type belonging to the kingdom provided.
    - If no claim type is specified the procedure will return both core and castle claims.
    - ---
    - → [ListTag(ChunkTag)]

    script:
    ## Gets a list of the provided claim type pertaining to the provided kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ## type    : ?[ElementTag<String>]
    ##
    ## >>> [ListTag<ChunkTag>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - define type <[type].if_null[corecastle]>

    - choose <[type]>:
        - case castle:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.castle].if_null[<list[]>]>

        - case core:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.core].if_null[<list[]>]>

        - default:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.castle].if_null[<list[]>].include[<server.flag[kingdoms.<[kingdom]>.claims.core].if_null[<list[]>]>]>


AddClaim:
    type: task
    definitions: kingdom[ElementTag(String)]|type[ElementTag(String)]|chunk[?ElementTag(String)]
    description:
    - Adds the provided chunk to the claims of the provided kingdom. Claim types can be core or
    - castle. If no claim type is provided, the script will assume 'castle'.
    - ---
    - → [Void]

    script:
    ## Adds the provided chunk to the claims of the provided kingdom. Claim types can be core or
    ## castle. If no claim type is provided, the script will assume 'castle'.
    ##
    ## kingdom : [ElementTag<String>]
    ## chunk   : [ChunkTag]
    ## type    : ?[ElementTag<String>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if <[chunk].object_type.to_lowercase> != chunk:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot add claim. Must be of type <&sq>Chunk<&sq>, type recieved: <[chunk].object_type>]>
        - determine cancelled

    - define type castle if:<[type].exists.not>

    - if !<[type].to_lowercase.is_in[core|castle]>:
        - run GenerateInternalError def.category:ValueError def.message:<element[Cannot add claim. Invalid claim type: <&sq><[type]><&sq> provided. Must match enum: Core, Castle]>
        - determine cancelled

    - flag server kingdoms.claimInfo.allClaims:->:<[chunk]>

    - if <[type].to_lowercase> == core:
        - flag server kingdoms.<[kingdom]>.claims.core:->:<[chunk]>
        - flag server kingdoms.<[kingdom]>.claims.core:<server.flag[kingdoms.<[kingdom]>.claims.core].deduplicate>

        - determine cancelled

    - flag server kingdoms.<[kingdom]>.claims.castle:->:<[chunk]>
    - flag server kingdoms.<[kingdom]>.claims.castle:<server.flag[kingdoms.<[kingdom]>.claims.castle].deduplicate>


RemoveClaim:
    type: task
    definitions: kingdom[ElementTag(String)]|chunk[ElementTag(String)]
    description:
    - Removes the provided chunk from the claims of the provided kingdom.
    - Returns null if the action fails.
    - ---
    - → [Void]

    script:
    ## Removes the provided chunk from the claims of the provided kingdom.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## chunk   : [ChunkTag]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if <[chunk].object_type.to_lowercase> != chunk:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot add claim. Must be of type <&sq>Chunk<&sq>, type recieved: <[chunk].object_type>]>
        - determine null

    - flag server kingdoms.claimInfo.allClaims:->:<[chunk]>

    - if <server.flag[kingdoms.<[kingdom]>.claims.core].contains[<[chunk]>]>:
        - flag server kingdoms.<[kingdom]>.claims.core:->:<[chunk]>
        - flag server kingdoms.<[kingdom]>.claims.core:<server.flag[kingdoms.<[kingdom]>.claims.core].deduplicate>

        - determine cancelled

    - flag server kingdoms.<[kingdom]>.claims.castle:->:<[chunk]>
    - flag server kingdoms.<[kingdom]>.claims.castle:<server.flag[kingdoms.<[kingdom]>.claims.castle].deduplicate>


GetClaimsCuboid:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]|type[?ElementTag(String)]
    description:
    - Returns a nested cuboid of the given kingdom's claims. Should a claim type not be specified
    - the procedure will assume 'core/castle'.
    - ---
    - → ?[CuboidTag]

    script:
    ## Returns a nested cuboid of the given kingdom's claims. Should a claim type not be specified
    ## the procedure will assume 'core/castle'.
    ##
    ## kingdom : [ElementTag<String>]
    ## type    : ?[ElementTag<String>]
    ##         | Valid values:   core, castle, castlecore
    ##         | Default values: castlecore
    ##
    ## >>> ?[CuboidTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - choose <[type]>:
        - case castle:
            - define claims <server.flag[kingdoms.<[kingdom]>.claims.castle].if_null[<list[]>]>

        - case core:
            - define claims <server.flag[kingdoms.<[kingdom]>.claims.core].if_null[<list[]>]>

        - default:
            - define claims <server.flag[kingdoms.<[kingdom]>.claims.castle].if_null[<list[]>].include[<server.flag[kingdoms.<[kingdom]>.claims.core].if_null[<list[]>]>]>

    - if <[claims].is_empty>:
        - determine null

    - define claimCuboid <[claims].get[1].cuboid>

    - foreach <[claims].remove[1]>:
        - define claimCuboid <[claimCuboid].add_member[<[value].cuboid>]>

    - determine <[claimCuboid]>


GetClaimsPolygon:
    type: procedure
    definitions: kingdom[ElementTag(String)]|world[WorldTag]|type[?ElementTag(String)]
    description:
    - Returns a polygon created of all the chunks consisting a kingdom's core/castle claims.
    - Optionally, a type can be specificed to filter either core or castle claims. By default the type is set to include both.
    - ---
    - → ?[PolygonTag]

    script:
    ## Returns a polygon created of all the chunks consisting a kingdom's core/castle claims.
    ##
    ## Optionally, a type can be specificed to filter either core or castle claims. By default the
    ## type is set to include both.
    ##
    ## kingdom :  [ElementTag<String>]
    ## world   :  [WorldTag]
    ## type    : ?[ElementTag<String>]
    ##
    ## >>> ?[PolygonTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - define type <[type].if_null[corecastle]>

    - run GenerateDynmapCorners def.chunks:<[kingdom].proc[GetClaims].context[<[type]>]> save:corners
    - define formattedCornerList <entry[corners].created_queue.determination.get[1].parse_tag[<[parse_value].x>,<[parse_value].z>].separated_by[,]>

    - determine <polygon[<[world].name>,0,255,<[formattedCornerList]>]>


GetMaxClaims:
    type: procedure
    definitions: kingdom[ElementTag(String)]|type[?ElementTag(String) = core]
    description:
    - Gets the maximum number of claims (of the type provided) that the provided kingdom can make.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Gets the maximum number of claims (of the type provided) that the provided kingdom can make.
    ##
    ## kingdom :  [ElementTag<String>]
    ## type    : ?[ElementTag<String>]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - choose <[type]>:
        - case castle:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.castleMax].if_null[0]>

        - case core:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.coreMax].if_null[0]>

        - default:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.castleMax].if_null[0].add[<server.flag[kingdoms.<[kingdom]>.claims.coreMax].if_null[0]>]>


SetMaxClaims:
    type: task
    definitions: kingdom[ElementTag(String)]|amount[ElementTag(Integer)]|type[?ElementTag(String) = core]
    description:
    - Sets the maximum number of claims (of the provided type) that the provided kingdom can make to the provided amount.
    - Will return null if the action fails.
    - ---
    - → [Void]

    script:
    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom max claims. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine null

    - if !<[amount].is_integer>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom max claims. Provided claim amount: <[amount].color[red]> is not a valid integer]>
        - determine null

    - define type <[type].if_null[core]>

    - if !<[type].is_in[core|castle]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set kingdom max claims. Provided claim type: <[type].color[red]> is invalid]>
        - determine null

    - flag server kingdoms.<[kingdom]>.claims.<[type]>Max:<[amount]>
