##
## [KAPI]
## Common scripts, tasks, and procedures relating to the territory of a kingdom.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2023
## @Script Ver: v1.1
##
## ----------------END HEADER-----------------


GetAllClaims:
    type: procedure
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

    - if <[type].is_in[core|castle]>:
        - foreach <proc[GetKingdomList]> as:kingdom:
            - define allClaims <[allClaims].include[<server.flag[kingdoms.<[kingdom]>.claims.<[type]>].if_null[<list[]>]>]>

    - else:
        - define allClaims <server.flag[kingdoms.claimInfo.allClaims].if_null[<list[]>]>

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
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

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
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if <[chunk].object_type.to_lowercase> != chunk:
        - run GenerateInternalError def.category:TypeError message:<element[Cannot add claim. Must be of type <&sq>Chunk<&sq>, type recieved: <[chunk].object_type>]>
        - determine cancelled

    - define type castle if:<[type].exists.not>

    - if !<[type].to_lowercase.is_in[core|castle]>:
        - run GenerateInternalError def.category:ValueError message:<element[Cannot add claim. Invalid claim type: <&sq><[type]><&sq> provided. Must match enum: Core, Castle]>
        - determine cancelled

    - flag server kingdoms.claimInfo.allClaims:->:<[chunk]>

    - if <[type].to_lowercase> == core:
        - flag server kingdoms.<[kingdom]>.claims.core:->:<[chunk]>
        - flag server kingdoms.<[kingdom]>.claims.core:<server.flag[kingdoms.<[kingdom]>.claims.core].deduplicate>

        - determine cancelled

    - flag server kingdoms.<[kingdom]>.claims.castle:->:<[chunk]>
    - flag server kingdoms.<[kingdom]>.claims.castle:<server.flag[kingdoms.<[kingdom]>.claims.castle].deduplicate>


GetClaimsCuboid:
    type: procedure
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
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
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
    definitions: kingdom[ElementTag(String)]|world[WorldTag]
    description:
    - Returns a polygon created of all the chunks consisting a kingdom's core/castle claims.
    - ---
    - → ?[PolygonTag]

    script:
    ## Returns a polygon created of all the chunks consisting a kingdom's core/castle claims.
    ##
    ## kingdom : [ElementTag<String>]
    ## world   : [WorldTag]
    ##
    ## >>> ?[PolygonTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if <[world].has_flag[dynmap.cache.<[kingdom]>.cornerList]>:
        - define formattedCornerList <[world].flag[dynmap.cache.<[kingdom]>.cornerList].parse_tag[<[parse_value].x>,<[parse_value].z>]>
        - determine <polygon[<[world].name>,0,255,<[formattedCornerList]>]>

    # TODO: make it fire the dynmap polygon generator when a permanent name is decided upon

    - determine null


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
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - choose <[type]>:
        - case castle:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.castleMax].if_null[0]>

        - case core:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.coreMax].if_null[0]>

        - default:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.castleMax].if_null[0].add[<server.flag[kingdoms.<[kingdom]>.claims.coreMax].if_null[0]>]>


GetOutposts:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    description:
    - Generates a MapTag of all the kingdom's outposts with an additional key added for the
    - outpost's area represented as a cuboid.
    - ---
    - → [MapTag(CuboidTag;ElementTag)]

    script:
    ## Generates a MapTag of all the kingdom's outposts with an additional key added for the
    ## outpost's area represented as a cuboid.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [MapTag<CuboidTag;ElementTag;>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].if_null[<list[]>].is_empty>:
        - determine <map[]>

    - determine <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].parse_value_tag[<[parse_value].include[area=<cuboid[<[parse_value].get[cornerone].world.name>,<[parse_value].get[cornerone].simple.split[,].remove[last].separated_by[,]>,<[parse_value].get[cornertwo].simple.split[,].remove[last].separated_by[,]>]>].exclude[cornerone|cornertwo]>]>


GetAllOutposts:
    type: procedure
    description:
    - Generates a MapTag representing the outpost information of every kingdom.
    - ---
    -     → [MapTag(CuboidTag;
    -               ElementTag(Integer);
    -               ElementTag(Float);
    -               ElementTag(String)
    -       )]

    script:
    ## Generates a MapTag representing the outpost information of every kingdom.
    ##
    ## >>> [MapTag<CuboidTag;
    ##             ElementTag<Integer>;
    ##             ElementTag<Float>;
    ##             ElementTag<String>
    ##      >]

    - define kingdomList <proc[GetKingdomList]>
    - define outpostMap <map[]>

    - foreach <[kingdomList]> as:kingdom:
        - define outpostMap.<[kingdom]>:<proc[GetOutposts].context[<[kingdom]>]>

    - determine <[outpostMap]>


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
        - run GenerateInternalError def.category:GenericError message:<element[Cannot check kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
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
        - run GenerateInternalError def.category:GenericError message:<element[Cannot check kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine false

    - determine <[player].location.chunk.is_in[<proc[GetClaims].context[<[kingdom]>|castle]>]>


PlayerInWhichOutpost:
    type: procedure
    definitions: player[PlayerTag]
    description:
    - Checks if a player is in one of their own kingdom's outposts.
    - ---
    - → ?[ElementTag(String)]

    script:
    ## Checks if a player is in one of their own kingdom's outposts.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> ?[ElementTag<String>]

    - if !<[player].has_flag[kingdom]>:
        - determine null

    - define kingdom <[player].flag[kingdom]>

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot check kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - define areas <proc[GetOutposts].context[<[kingdom]>].parse_value_tag[<[parse_value].get[area]>]>

    - foreach <[areas]> key:name as:area:
        - debug DEBUG <[area]>

        - if <[area].contains[<[player].location>]>:
            - determine <[name]>

    - determine null
