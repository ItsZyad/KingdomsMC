##
## [KAPI]
## Denizen's location system is often medicore and unpredictable in the way that it acts. Sometimes
## it's also just not suitable for the uses that Kingdoms requires. This KAPI file contains my own
## implementation of basic location and pathfinding functions that Denizen does not handle well
## enough.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Nov 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

RoundCoordinates:
    type: procedure
    debug: false
    definitions: location[LocationTag]
    description:
    - Returns a version of the provided location with only its XYZ components rounded.
    - Will return null if the location provided is invalid.
    - ---
    - → ?[LocationTag]

    script:
    ## Returns a version of the provided location with only its XYZ components rounded.
    ##
    ## Will return null if the location provided is invalid.
    ##
    ## location : [LocationTag]
    ##
    ## >>> ?[LocationTag]

    - if !<[location].x.is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot round coordinate. Provided parameter: <[location].color[red]> is not a LocationTag.]>
        - determine null

    - determine <[location].round_down.with_pitch[<[location].pitch>].with_yaw[<[location].yaw>]>


TruncateLocation:
    type: procedure
    definitions: location[LocationTag]
    description:
    - Truncates the coordinate components of the location provided.
    - Will return null if the location provided is invalid.
    - ---
    - → ?[LocationTag]

    script:
    ## Truncates the coordinate components of the location provided.
    ##
    ## Will return null if the location provided is invalid.
    ##
    ## location : [LocationTag]
    ##
    ## >>> ?[LocationTag]

    - if !<[location].x.is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot truncate location coordinates. Provided parameter: <[location].color[red]> is not a LocationTag.]>
        - determine null

    - determine <[location].with_x[<[location].x.truncate>].with_y[<[location].y.truncate>].with_z[<[location].z.truncate>]>


AddDirection:
    type: procedure
    definitions: location[LocationTag]|addMatrix[ElementTag(String)]
    description:
    - Works much in the same way as LocationTag.add[] but instead this takes into account the direction that the player is facing.
    - For example, using AddDirection(LocationTag|1,0,1) while facing north will return a location 1 block north and 1 block east of the player.
    - Will return null if the action fails.
    - ---
    - → ?[LocationTag]

    script:
    ## Works much in the same way as LocationTag.add[] but instead this takes into account the
    ## direction that the player is facing.
    ##
    ## For example, using AddDirection(LocationTag|1,0,1) while facing north will return a location
    ## 1 block north and 1 block east of the player.
    ##
    ## Will return null if the action fails.
    ##
    ## location  : [LocationTag]
    ## addMatrix : [ElementTag(String)]
    ##
    ## >>> ?[LocationTag]

    - if !<[location].x.is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Provided parameter: <[location].color[red]> is not a LocationTag.]>
        - determine null

    - if <[addMatrix].split[,].size> != 3:
        - run GenerateInternalError def.category:GenericError def.message:<element[Provided addMatrix: <[addMatrix].color[red]> is not in a valid format. The addMatrix must be three comma-separated numbers.]>
        - determine null

    - define simpleLocation <[location].with_pitch[0]>
    - define matrixX <[addMatrix].split[,].get[1]>
    - define matrixY <[addMatrix].split[,].get[2]>
    - define matrixZ <[addMatrix].split[,].get[3]>

    - if <[simpleLocation].direction.contains[north]>:
        - define simpleLocation <[simpleLocation].add[<[matrixZ]>,<[matrixY]>,<[matrixX].proc[Invert]>]>

    - if <[simpleLocation].direction.contains[south]>:
        - define simpleLocation <[simpleLocation].add[<[matrixZ].proc[Invert]>,<[matrixY]>,<[matrixX]>]>

    - if <[simpleLocation].direction.contains[east]>:
        - define simpleLocation <[simpleLocation].add[<[matrixX]>,<[matrixY]>,<[matrixZ].proc[Invert]>]>

    - if <[simpleLocation].direction.contains[west]>:
        - define simpleLocation <[simpleLocation].add[<[matrixX].proc[Invert]>,<[matrixY]>,<[matrixZ]>]>

    - determine <[simpleLocation]>


ChessForward:
    type: procedure
    definitions: location[LocationTag]|amount[?ElementTag(Float) = 1]|round[?ElementTag(Boolean) = true]
    description:
    - Returns the location that is in front of the provided location by the amount of blocks provided in a chess-like fashion.
    - Essentially, this procedure will treat the Minecraft world like a chess board and assume the player's yaw can only be multiples of 45, thus only being able to move forward, backward, or diagonally.
    - If no amount is provided, the value will default to 1.
    - If the 'round' parameter is set to true, the procedure will only return rounded locations.
    - Will return null if either the location provided is invalid or is the amount provided is not a number.
    - ---
    - → ?[LocationTag]

    script:
    ## Returns the location that is in front of the provided location by the amount of blocks
    ## provided in a chess-like fashion.
    ##
    ## Essentially, this procedure will treat the Minecraft world like a chess board and assume the
    ## player's yaw can only be multiples of 45, thus only being able to move forward, backward, or
    ## diagonally.
    ##
    ## If no amount is provided, the value will default to 1.
    ##
    ## If the 'round' parameter is set to true, the procedure will only return rounded locations.
    ##
    ## Will return null if either the location provided is invalid or is the amount provided is not
    ## a number.
    ##
    ## location :  [LocationTag]
    ## amount   : ?[ElementTag<Float>]
    ## round    : ?[ElementTag<Boolean>]
    ##
    ## >>> ?[LocationTag]

    - if !<[location].x.is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Provided parameter: <[location].color[red]> is not a LocationTag.]>
        - determine null

    - if <[amount].exists> && !<[amount].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Provided parameter: <[amount].color[red]> is not a decimal value.]>
        - determine null

    - if <[round].exists> && !<[round].is_boolean>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Provided parameter: <[amount].color[red]> is not a boolean value.]>
        - determine null

    - define amount <[amount].if_null[1]>
    - define round <[round].if_null[true]>
    - define adjustedLocation <[location].center.with_y[<[location].y>].with_pitch[0].with_yaw[<[location].yaw.round_to_precision[45]>]>

    - if <[adjustedLocation].direction.contains[north]>:
        - define adjustedLocation <[adjustedLocation].add[0,0,<[amount].proc[Invert]>]>

    - if <[adjustedLocation].direction.contains[south]>:
        - define adjustedLocation <[adjustedLocation].add[0,0,<[amount]>]>

    - if <[adjustedLocation].direction.contains[east]>:
        - define adjustedLocation <[adjustedLocation].add[<[amount]>,0,0]>

    - if <[adjustedLocation].direction.contains[west]>:
        - define adjustedLocation <[adjustedLocation].add[<[amount].proc[Invert]>,0,0]>

    - if <[round]>:
        - define adjustedLocation <[adjustedLocation].proc[RoundCoordinates]>

    - determine <[adjustedLocation]>


ChessBackward:
    type: procedure
    definitions: location[LocationTag]|amount[?ElementTag(Float) = 1]|round[?ElementTag(Boolean) = true]
    description:
    - Returns the location that is behind the provided location by the amount of blocks provided in a chess-like fashion.
    - Essentially, this procedure will treat the Minecraft world like a chess board and assume the player's yaw can only be multiples of 45, thus only being able to move forward, backward, or diagonally.
    - If no amount is provided, the value will default to 1.
    - If the 'round' parameter is set to true, the procedure will only return rounded locations.
    - Will return null if either the location provided is invalid or is the amount provided is not a number.
    - ---
    - → ?[LocationTag]

    script:
    ## Returns the location that is behind of the provided location by the amount of blocks
    ## provided in a chess-like fashion.
    ##
    ## Essentially, this procedure will treat the Minecraft world like a chess board and assume the
    ## player's yaw can only be multiples of 45, thus only being able to move forward, backward, or
    ## diagonally.
    ##
    ## If no amount is provided, the value will default to 1.
    ##
    ## If the 'round' parameter is set to true, the procedure will only return rounded locations.
    ##
    ## Will return null if either the location provided is invalid or is the amount provided is not
    ## a number.
    ##
    ## location :  [LocationTag]
    ## amount   : ?[ElementTag<Float>]
    ## round    : ?[ElementTag<Boolean>]
    ##
    ## >>> ?[LocationTag]

    - if !<[location].x.is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Provided parameter: <[location].color[red]> is not a LocationTag.]>
        - determine null

    - if <[amount].exists> && !<[amount].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Provided parameter: <[amount].color[red]> is not a decimal value.]>
        - determine null

    - if <[round].exists> && !<[round].is_boolean>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Provided parameter: <[amount].color[red]> is not a boolean value.]>
        - determine null

    - define amount <[amount].if_null[1]>
    - define round <[round].if_null[true]>

    - determine <[location].proc[ChessForward].context[<[amount].proc[Invert]>|<[round]>]>


ChessRight:
    type: procedure
    definitions: location[LocationTag]|amount[?ElementTag(Float) = 1]|round[?ElementTag(Boolean) = true]
    description:
    - Returns the location that is to the right of the provided location by the amount of blocks provided in a chess-like fashion.
    - Essentially, this procedure will treat the Minecraft world like a chess board and assume the player's yaw can only be multiples of 45, thus only being able to move forward, backward, or diagonally.
    - If no amount is provided, the value will default to 1.
    - If the 'round' parameter is set to true, the procedure will only return rounded locations.
    - Will return null if either the location provided is invalid or is the amount provided is not a number.
    - ---
    - → ?[LocationTag]

    script:
    ## Returns the location that is to the right of the provided location by the amount of blocks
    ## provided in a chess-like fashion.
    ##
    ## Essentially, this procedure will treat the Minecraft world like a chess board and assume the
    ## player's yaw can only be multiples of 45, thus only being able to move forward, backward, or
    ## diagonally.
    ##
    ## If no amount is provided, the value will default to 1.
    ##
    ## If the 'round' parameter is set to true, the procedure will only return rounded locations.
    ##
    ## Will return null if either the location provided is invalid or is the amount provided is not
    ## a number.
    ##
    ## location :  [LocationTag]
    ## amount   : ?[ElementTag<Float>]
    ## round    : ?[ElementTag<Boolean>]
    ##
    ## >>> ?[LocationTag]

    - if !<[location].x.is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Provided parameter: <[location].color[red]> is not a LocationTag.]>
        - determine null

    - if <[amount].exists> && !<[amount].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Provided parameter: <[amount].color[red]> is not a decimal value.]>
        - determine null

    - if <[round].exists> && !<[round].is_boolean>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Provided parameter: <[amount].color[red]> is not a boolean value.]>
        - determine null

    - define amount <[amount].if_null[1]>
    - define round <[round].if_null[true]>
    - define adjustedLocation <[location].center.with_y[<[location].y>].with_pitch[0].with_yaw[<[location].yaw.round_to_precision[45]>]>

    - if <[adjustedLocation].direction.contains[north]>:
        - define adjustedLocation <[adjustedLocation].add[<[amount]>,0,0]>

    - if <[adjustedLocation].direction.contains[south]>:
        - define adjustedLocation <[adjustedLocation].add[<[amount].proc[Invert]>,0,0]>

    - if <[adjustedLocation].direction.contains[east]>:
        - define adjustedLocation <[adjustedLocation].add[0,0,<[amount]>]>

    - if <[adjustedLocation].direction.contains[west]>:
        - define adjustedLocation <[adjustedLocation].add[0,0,<[amount].proc[Invert]>]>

    - if <[round]>:
        - define adjustedLocation <[adjustedLocation].proc[RoundCoordinates]>

    - determine <[adjustedLocation]>


ChessLeft:
    type: procedure
    definitions: location[LocationTag]|amount[?ElementTag(Float) = 1]|round[?ElementTag(Boolean) = true]
    description:
    - Returns the location that is to the left the provided location by the amount of blocks provided in a chess-like fashion.
    - Essentially, this procedure will treat the Minecraft world like a chess board and assume the player's yaw can only be multiples of 45, thus only being able to move forward, backward, or diagonally.
    - If no amount is provided, the value will default to 1.
    - If the 'round' parameter is set to true, the procedure will only return rounded locations.
    - Will return null if either the location provided is invalid or is the amount provided is not a number.
    - ---
    - → ?[LocationTag]

    script:
    ## Returns the location that is to the left of the provided location by the amount of blocks
    ## provided in a chess-like fashion.
    ##
    ## Essentially, this procedure will treat the Minecraft world like a chess board and assume the
    ## player's yaw can only be multiples of 45, thus only being able to move forward, backward, or
    ## diagonally.
    ##
    ## If no amount is provided, the value will default to 1.
    ##
    ## If the 'round' parameter is set to true, the procedure will only return rounded locations.
    ##
    ## Will return null if either the location provided is invalid or is the amount provided is not
    ## a number.
    ##
    ## location :  [LocationTag]
    ## amount   : ?[ElementTag<Float>]
    ## round    : ?[ElementTag<Boolean>]
    ##
    ## >>> ?[LocationTag]

    - if !<[location].x.is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Provided parameter: <[location].color[red]> is not a LocationTag.]>
        - determine null

    - if <[amount].exists> && !<[amount].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Provided parameter: <[amount].color[red]> is not a decimal value.]>
        - determine null

    - if <[round].exists> && !<[round].is_boolean>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Provided parameter: <[amount].color[red]> is not a boolean value.]>
        - determine null

    - define amount <[amount].if_null[1]>
    - define round <[round].if_null[true]>

    - determine <[location].proc[ChessRight].context[<[amount].proc[Invert]>|<[round]>]>


ContainsAllLocations:
    type: procedure
    definitions: area[AreaObject]|locationList[ListTag(LocationTag)]
    description:
    - Returns true if and only if the provided area contains every single location in the provided location list.
    - Will return null if the action fails.
    - ---
    - → ?[ElementTag(Boolean)]

    script:
    ## Returns true if and only if the provided area contains every single location in the provided
    ## location list.
    ##
    ## Will return null if the action fails.
    ##
    ## area         : [AreaObject]
    ## locationList : [ListTag<LocationTag>]
    ##
    ## >>> ?[ElementTag<Boolean>]

    - define locationList <queue.definition_map.exclude[raw_context].values.get[3].to[last].if_null[<list[]>].insert[<[locationList]>].at[1]>

    - debug LOG <[locationList]>

    - if !<[locationList].get[1].exists> && !<[locationList].is_empty>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot check area contains. Provided parameter: <[locationList].color[red]> is not a list.]>
        - determine null

    - if !<[locationList].get[1].xyz.exists>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot check area contains. LocationList contains non-location values.]>
        - determine null

    - if !<[area].object_type.is_in[Polygon|Cuboid|Ellipsoid]>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot check area contains. Provided parameter: <[area].color[red]> is not of type: AreaObject.]>
        - determine null

    - foreach <[locationList]> as:loc:
        - if !<[area].contains[<[loc]>]>:
            - determine false

    - determine true
