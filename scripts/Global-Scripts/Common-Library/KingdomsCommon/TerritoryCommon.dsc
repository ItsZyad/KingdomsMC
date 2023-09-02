##
## [KAPI]
## Common scripts, tasks, and procedures relating to the territory of a kingdom.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2023
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

GetClaims:
    type: procedure
    definitions: kingdom[ElementTag(String)]|type[?ElementTag(String)]
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
            - determine <server.flag[kingdoms.<[kingdom]>.claims.castle]>

        - case core:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.core]>

        - default:
            - determine <server.flag[kingdoms.<[kingdom]>.claims.castle].include[<server.flag[kingdoms.<[kingdom]>.claims.core]>]>


AddClaim:
    type: task
    definitions: kingdom[ElementTag(String)]|type[ChunkTag]|chunk[?ElementTag(String)]
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

    - if <[type].to_lowercase> == core:
        - flag server kingdoms.<[kingdom]>.claims.core:->:<[chunk]>
        - flag server kingdoms.<[kingdom]>.claims.core:<server.flag[kingdoms.<[kingdom]>.claims.core].deduplicate>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.claims.castle:->:<[chunk]>
    - flag server kingdoms.<[kingdom]>.claims.castle:<server.flag[kingdoms.<[kingdom]>.claims.castle].deduplicate>


GetClaimsCuboid:
    type: procedure
    definitions: kingdom[ElementTag(String)]|type[?ElementTag(String)]
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
    script:
    ## Returns a polygon created of all the chunks consisting a kingdom's core/castle claims
    ##
    ## kingdom : [ElementTag<String>]
    ## world   : [WorldTag]
    ##
    ## >>> [PolygonTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if <[world].has_flag[dynmap.cache.<[kingdom]>.cornerList]>:
        - define formattedCornerList <[world].flag[dynmap.cache.<[kingdom]>.cornerList].parse_tag[<[parse_value].x>,<[parse_value].z>]>
        - determine <polygon[<[world].name>,0,255,<[formattedCornerList]>]>

    # TODO: make it fire the dynmap polygon generator when a permanent name is decided upon

    - determine null


GetOutposts:
    type: procedure
    definitions: kingdom[ElementTag(String)]
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

    - if <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].if_null[<list>].is_empty>:
        - determine <map[]>

    - determine <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].parse_value_tag[<[parse_value].include[area=<cuboid[<[parse_value].get[cornerone].world.name>,<[parse_value].get[cornerone].simple.split[,].remove[last].separated_by[,]>,<[parse_value].get[cornertwo].simple.split[,].remove[last].separated_by[,]>]>].exclude[cornerone|cornertwo]>]>


GetAllOutposts:
    type: procedure
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
    script:
    ## Checks if a player is in their own kingdom's core claims
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

    - determine <[player].location.chunk.is_in[<server.flag[kingdoms.<[kingdom]>.claims.core]>]>


IsPlayerInCastle:
    type: procedure
    definitions: player[PlayerTag]
    script:
    ## Checks if a player is in their own castle claims
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

    - determine <[player].location.chunk.is_in[<server.flag[kingdoms.<[kingdom]>.claims.castle]>]>


PlayerInWhichOutpost:
    type: procedure
    definitions: player[PlayerTag]
    script:
    ## Checks if a player is in one of their own kingdom's outposts
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [ElementTag<String>]

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
