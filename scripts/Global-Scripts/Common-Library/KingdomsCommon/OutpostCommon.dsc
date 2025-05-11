##
## [KAPI]
## Common scripts, tasks, and procedures relating to the outposts of a kingdom.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Oct 2024
## Original Scripts: Aug 2023
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

DoesOutpostExist:
    type: procedure
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]
    description:
    - Returns true if the provided outpost exists as a part of the provided kingdom.
    - Will return null if the provided kingdom does not exist.
    - ---
    - → ?[ElementTag(Boolean)]

    script:
    ## Returns true if the provided outpost exists as a part of the provided kingdom.
    ##
    ## Will return null if the provided kingdom does not exist.
    ##
    ## kingdom : [ElementTag<String>]
    ## outpost : [ElementTag<String>]
    ##
    ## >>> ?[ElementTag<Boolean>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot check if outpost exists. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <proc[GetOutposts].context[<[kingdom]>].keys.contains[<[outpost]>]>


GetAllOutpostsByKingdom:
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


GetAllOutposts:
    type: procedure
    description:
    - Returns a list of all outposts there are on the server, across all kingdoms. The kingdom that each outpost belongs to is added to the outpost data MapTag.
    - Will return null if the action fails.
    - ---
    - → [MapTag]

    script:
    ## Returns a list of all outposts there are on the server, across all kingdoms. The kingdom
    ## that each outpost belongs to is added to the outpost data MapTag.
    ##
    ## Will return null if the action fails.
    ##
    ## >>> [MapTag]

    - define kingdomList <proc[GetKingdomList]>
    - define outpostMap <map[]>

    - foreach <[kingdomList]> as:kingdom:
        - define outpostMap <[outpostMap].include[<proc[GetOutposts].context[<[kingdom]>].parse_value_tag[<[parse_value].include[kingdom=<[kingdom]>]>]>]>

    - determine <[outpostMap]>


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
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].if_null[<list[]>].is_empty>:
        - determine <map[]>

    - determine <server.flag[kingdoms.<[kingdom]>.outposts.outpostList]
        .parse_value_tag[<[parse_value].contains[cornerone].if_true[<[parse_value]
        .include[area=<cuboid[<[parse_value].get[cornerone].world.name>,<[parse_value].get[cornerone].simple.split[,].remove[last].separated_by[,]>,<[parse_value].get[cornertwo].simple.split[,].remove[last].separated_by[,]>]>]
        .exclude[cornerone|cornertwo]>].if_false[<[parse_value]>]>]>


GetOutpostSize:
    type: procedure
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]
    description:
    - Returns the number of blocks on just one y-level of the provided outpost's cuboid area.
    - Will return null if either the kingdom or the outpost provided are invalid.
    - ---
    - → ?[ElementTag(Integer)]

    script:
    ## Returns the number of blocks on just one y-level of the provided outpost's cuboid area.
    ##
    ## Will return null if either the kingdom or the outpost provided are invalid.
    ##
    ## kingdom : [ElementTag<String>]
    ## outpost : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost size. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost size. Invalid outpost name provided: <[outpost]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.size]>


GetOutpostNote:
    type: procedure
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]
    description:
    - Returns a cuboid representing the noted area of the provided outpost in the provided kingdom.
    - Will return null if the action fails.
    - ---
    - → ?[CuboidTag]

    script:
    ## Returns a cuboid representing the noted area of the provided outpost in the provided
    ## kingdom.
    ##
    ## Will return null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## outpost : [ElementTag<String>]
    ##
    ## >>> ?[CuboidTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost note. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost note. Invalid outpost name provided: <[outpost]>]>
        - determine null

    - determine <cuboid[<server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.noteName]>].if_null[null]>


GetOutpostArea:
    type: procedure
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]
    description:
    - Returns the CuboidTag which designates the provided outpost's area.
    - Returns null if the action fails.
    - ---
    - → ?[CuboidTag]

    script:
    ## Returns the CuboidTag which designates the provided outpost's area.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## outpost : [ElementTag<String>]
    ##
    ## >>> ?[CuboidTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost area. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost area. Invalid outpost name provided: <[outpost]>]>
        - determine null

    - if <server.has_flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.cornerone]>:
        - define cornerOne <server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.cornerone]>
        - define cornerTwo <server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.cornertwo]>
        - define world <[cornerOne].world>
        - define cuboid <cuboid[<[world].name>,<[cornerOne].xyz>,<[cornerTwo].xyz>]>

    - else:
        - define cuboid <server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.area]>

    - determine <[cuboid]>


SetOutpostArea:
    type: task
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]|newArea[CuboidTag]
    description:
    - Sets the area of the outpost in the provided kingdom to the newArea provided.
    - Returns null if the action fails.
    - Note: This will not actually check if the provided kingdom *can* actually have an outpost with the provided area. Any artificial limitation to the size of an outpost must be imposed outside this task.
    - ---
    - → [Void]

    script:
    ## Sets the area of the outpost in the provided kingdom to the newArea provided.
    ##
    ## Returns null if the action fails.
    ##
    ## Note: This will not actually check if the provided kingdom *can* actually have an outpost
    ## with the provided area. Any artificial limitation to the size of an outpost must be imposed
    ## outside this task.
    ##
    ## kingdom     : [ElementTag<String>]
    ## outpostName : [ElementTag<String>]
    ## newArea     : [CuboidTag]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set outpost area. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set outpost area. Invalid outpost name provided: <[outpost]>]>
        - determine null

    - if <[newArea].object_type> != Cuboid:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot set outpost area. Provided argument: <[newArea]> is not of type: CuboidTag]>
        - determine null

    - define oldUpkeep <proc[GetOutpostUpkeep].context[<[kingdom]>|<[outpost]>]>

    - if <server.has_flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.cornerone]>:
        - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.cornerone:!
        - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.cornertwo:!

    - define size <[newArea].size.x.mul[<[newArea].size.z>].round_up>

    - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.area:<[newArea]>
    - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.size:<[size].round>

    - run SetOutpostUpkeep def.kingdom:<[kingdom]> def.outpost:<[outpost]> def.amount:<[size].mul[<server.flag[kingdoms.<[kingdom]>.outposts.upkeepMultiplier].if_null[1]>].round>


GetOutpostUpkeep:
    type: procedure
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]
    description:
    - Returns the daily upkeep of the provided outpost.
    - Returns null if the action fails.
    - ---
    - → ?[ElementTag(Float)]

    script:
    ## Returns the daily upkeep of the provided outpost.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## outpost : [ElementTag<String>]
    ##
    ## >>> ?[ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost upkeep. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost upkeep. Invalid outpost name provided: <[outpost]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.upkeep]>


SetOutpostUpkeep:
    type: task
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Sets the upkeep for the provided outpost in the provided kingdom.
    - Returns null if the action fails.
    - ---
    - → [Void]

    script:
    ## Sets the upkeep for the provided outpost in the provided kingdom.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## outpost : [ElementTag<String>]
    ## amount  : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set outpost upkeep. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set outpost upkeep. Invalid outpost name provided: <[outpost]>]>
        - determine null

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:ValueError def.message:<element[Cannot set outpost upkeep to a value below zero!]>
        - determine null

    - define oldUpkeep <proc[GetOutpostUpkeep].context[<[kingdom]>|<[outpost]>]>
    - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.upkeep:<[amount]>
    - define upkeepDiff <[oldUpkeep].sub[<proc[GetOutpostSize].context[<[kingdom]>|<[outpost]>].mul[3].mul[<server.flag[kingdoms.<[kingdom]>.outposts.upkeepMultiplier].if_null[1]>].round>]>

    - run AddUpkeep def.kingdom:<[kingdom]> def.amount:<[upkeepDiff]>
    - run CalculateTotalOutpostUpkeep def.kingdom:<[kingdom]>
    - run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>


GetOutpostDisplayName:
    type: procedure
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]
    description:
    - Returns the display name of the provided outpost in the provided kingdom.
    - Returns null if the action fails.
    - ---
    - → [ElementTag(String)]

    script:
    ## Returns the display name of the provided outpost in the provided kingdom.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## outpost : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost display name. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost display name. Invalid outpost name provided: <[outpost]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.name]>


GetKingdomOutpostMaxSize:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    description:
    - Returns the maximum size that the provided kingdom's outposts can be in blocks.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Returns the maximum size that the provided kingdom's outposts can be in blocks.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom maximum outpost size. Invalid kingdom code provided: <[kingdom]>]> def.silent:true
        - determine <proc[GetConfigNode].context[Territory.maximum-outpost-size]>

    - determine <server.flag[kingdoms.<[kingdom]>.outposts.maxSize].if_null[<proc[GetConfigNode].context[Territory.maximum-outpost-size]>]>


## @Alias
GetKingdomMaxOutpostSize:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    description:
    - `[This procedure is an alias of GetKingdomOutpostMaxSize]`
    - Returns the maximum size that the provided kingdom's outposts can be in blocks.
    - ---
    - → [ElementTag(Integer)]

    script:
    - inject GetKingdomOutpostMaxSize


GetOutpostSpecialization:
    type: procedure
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]
    description:
    - Returns the specialization of the given outpost in the given kingdom. If the outpost has no specialization, the procedure will return 'None'.
    - Returns null if the action fails.
    - ---
    - → [ElementTag(String)]

    script:
    ## Returns the specialization of the given outpost in the given kingdom. If the outpost has no
    ## specialization, the procedure will return 'None'.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## outpost : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost specialization. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine null

    - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost specialization. Invalid outpost name provided: <[outpost].color[red]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.specType].if_null[None]>


SetOutpostSpecialization:
    type: task
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]|spec[ElementTag(String)]
    description:
    - Sets the specialization of the given outpost in the given kingdom.
    - Returns null if the action fails.
    - ---
    - → [Void]

    script:
    ## Sets the specialization of the given outpost in the given kingdom.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## outpost : [ElementTag<String>]
    ## spec    : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set outpost specialization. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine null

    - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set outpost specialization. Invalid outpost name provided: <[outpost].color[red]>]>
        - determine null

    - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.specType:<[spec]>


GetOutpostSpecializationModifier:
    type: procedure
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]
    description:
    - Returns the specialization modifier of the given outpost in the given kingdom. The specialization modifier is the multiplier that the outpost's specialized production will increase by.
    - Returns null if the action fails.
    - ---
    - → [ElementTag(String)]

    script:
    ## Returns the specialization modifier of the given outpost in the given kingdom. The
    ## specialization modifier is the multiplier that the outpost's specialized production will
    ## increase by.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## outpost : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost specialization modifier. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine null

    - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost specialization modifier. Invalid outpost name provided: <[outpost].color[red]>]>
        - determine null

    - if <proc[GetOutpostSpecialization].context[<[kingdom]>|<[outpost]>].is_in[None|null]>:
        - determine 1

    - determine <server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.specMod].if_null[null]>


SetOutpostSpecializationModifier:
    type: task
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]|modifier[ElementTag(Float)]
    description:
    - Sets the specialization modifier of the given outpost in the given kingdom. The specialization modifier is the multiplier that the outpost's specialized production will increase by.
    - Returns null if the action fails.
    - ---
    - → [Void]

    script:
    ## Sets the specialization modifier of the given outpost in the given kingdom. The
    ## specialization modifier is the multiplier that the outpost's specialized production will
    ## increase by.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom  : [ElementTag<String>]
    ## outpost  : [ElementTag<String>]
    ## modifier : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set outpost specialization modifier. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine null

    - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set outpost specialization modifier. Invalid outpost name provided: <[outpost].color[red]>]>
        - determine null

    - if <proc[GetOutpostSpecialization].context[<[kingdom]>|<[outpost]>].is_in[None|null]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set outpost specialization modifier. Outpost provided: <[outpost].color[red]> does not have a specialization]>
        - determine null

    - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.specMod:<[modifier]>


PlayerInWhichOutpost:
    type: procedure
    definitions: player[PlayerTag]
    description:
    - Checks if a player is in one of their own kingdom's outposts.
    - Returns null if the action fails.
    - ---
    - → ?[ElementTag(String)]

    script:
    ## Checks if a player is in one of their own kingdom's outposts.
    ##
    ## Returns null if the action fails.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> ?[ElementTag<String>]

    - if !<[player].has_flag[kingdom]>:
        - determine null

    - define kingdom <[player].flag[kingdom]>

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot check kingdom claims. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - define areas <proc[GetOutposts].context[<[kingdom]>].parse_value_tag[<[parse_value].get[area]>]>

    - foreach <[areas]> key:name as:area:
        - if <[area].contains[<[player].location>]>:
            - determine <[name]>

    - determine null


CreateOutpost:
    type: task
    definitions: kingdom[ElementTag(String)]|cornerList[ListTag(LocationTag)]|outpostName[ElementTag(String)]
    description:
    - Creates a new outpost with the provided name for the provided kingdom in the area between the first two points provided in the corner list.
    - Returns null if the action fails.
    - ---
    - → [Void]

    script:
    ## Creates a new outpost with the provided name for the provided kingdom in the area between
    ## the first two points provided in the corner list.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom     : [ElementTag<String>]
    ## cornerList  : [ListTag<LocationTag>]
    ## outpostName : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot create outpost. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if <[cornerList].size> < 2:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot create outpost. Insufficient corner points provided.]>
        - determine null

    - if <[outpostName].is_in[<[kingdom].proc[GetOutposts].keys>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot create outpost. Outpost with the provided name already exists.]>
        - determine null

    - define cornerOne <[cornerList].get[1]>
    - define cornerTwo <[cornerList].get[2]>

    - if <list[<[cornerOne].object_type>|<[cornerTwo].object_type>]> != <list[Location|Location]>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot create outpost. Location list entries provided are not actual locations.]>
        - determine null

    - define outpostArea <cuboid[<player.world.name>,<[cornerOne].x>,0,<[cornerOne].z>,<[cornerTwo].x>,255,<[cornerTwo].z>]>
    - define escapedName <[outpostName].replace[ ].with[-]>
    - define noteName outpost_<[escapedName]>
    - define size <[outpostArea].size.x.mul[<[outpostArea].size.z>].round_up>

    - note <[outpostArea]> as:<[noteName]>

    - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.area:<[outpostArea]>
    - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.noteName:<[noteName]>
    - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.size:<[size]>
    - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.upkeep:<[size].mul[<server.flag[kingdoms.<[kingdom]>.outposts.upkeepMultiplier].if_null[1]>].round>
    - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.name:<[outpostName]>

    - run CalculateTotalOutpostUpkeep def.kingdom:<[kingdom]>


RemoveOutpost:
    type: task
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]
    description:
    - Removes the outpost with the provided name from the provided kingdom and returns all of its data.
    - Returns null if the action fails.
    - ---
    - → ?[MapTag]

    script:
    ## Removes the outpost with the provided name from the provided kingdom and returns all of its
    ## data.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ## outpost : [ElementTag<String>]
    ##
    ## >>> ?[MapTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot delete outpost upkeep. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot delete outpost upkeep. Invalid outpost name provided: <[outpost]>]>
        - determine null

    - determine passively <proc[GetOutposts].context[<[kingdom]>|<[outpost]>].values.get[1]>

    - note as:<proc[GetOutpostNote].context[<[kingdom]>|<[outpost]>].note_name> remove

    - run SubUpkeep def.kingdom:<[kingdom]> def.amount:<proc[GetOutpostUpkeep].context[<[kingdom]>|<[outpost]>]>
    - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>:!

    - run CalculateTotalOutpostUpkeep def.kingdom:<[kingdom]>


GetTotalOutpostUpkeep:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    description:
    - Returns the total amount of upkeep required of every outpost that a given kingdom has.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Returns the total amount of upkeep required of every outpost that a given kingdom has.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get total outpost upkeep. Invalid kingdom code provided: <[kingdom]>]> def.silent:true
        - determine 0

    - determine <[kingdom].proc[GetOutposts].values.parse_tag[<[parse_value].get[upkeep]>].sum.if_null[0]>


CalculateTotalOutpostUpkeep:
    type: task
    definitions: kingdom[ElementTag(String)]
    description:
    - Sets the total amount of upkeep required of every outpost that a given kingdom has.
    - Returns null if the action fails.
    - ---
    - → [Void]

    script:
    ## Sets the total amount of upkeep required of every outpost that a given kingdom has.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set total outpost upkeep. Invalid kingdom code provided: <[kingdom]>]> def.silent:true
        - determine null

    - define total <[kingdom].proc[GetTotalOutpostUpkeep]>

    - flag server kingdoms.<[kingdom]>.outposts.totalUpkeep:<[total]>
