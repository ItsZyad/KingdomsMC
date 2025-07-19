##
## [KAPI]
## This file contains a number of scripts the create standardized particle patterns and shapes.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: May 2025
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

##### PARTICLE SHAPE GENERATORS
#################################################

GenerateParticleLine:
    type: procedure
    debug: false
    definitions: posOne[LocationTag]|posTwo[LocationTag]|spread[?ElementTag(Float) = 1]
    description:
    - Returns a line of particles of the provided type between the two positions provided. Each particle is spread out one block apart by default, but this distance can be changed by specifying a custom `spread`.
    - Will return null if the action fails.
    - ---
    - → [ListTag(LocationTag)]

    script:
    - if <list[<[posOne]>|<[posTwo]>].parse_tag[<[parse_value].object_type>]> != <list[Location|Location]>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to generate particle line. One or more of the provided start or end locations: <element[<[posOne]>, <[posTwo]>].color[red]> are invalid.]>
        - determine null

    - define spread <[spread].if_null[1]>

    - if !<[spread].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to generate particle line. Provided particle spread value: <[spread].color[red]> must be a decimal.]>
        - determine null

    - inject <script.name> path:GenerateLine

    - determine <[locationList]>

    GenerateLine:
    - define locationList <list[]>

    - define locationStep <[posOne].face[<[posTwo]>]>

    - repeat <[posOne].distance[<[posTwo]>].div[<[spread]>]>:
        - define locationList:->:<[locationStep].add[<[locationStep].sub[<[posTwo]>].direction.vector.mul[<[spread]>]>]>
        - define locationStep <[locationStep].add[<[locationStep].sub[<[posTwo]>].direction.vector.mul[<[spread]>]>]>


GenerateParticleCube:
    type: procedure
    debug: false
    definitions: cornerOne[LocationTag]|cornerTwo[LocationTag]|spread[?ElementTag(Float) = 1]
    description:
    - Returns a cube of particles of the provided type between the two positions provided. Each particle is spread out one block apart by default, but this distance can be changed by specifying a custom `spread`.
    - Will return null if the action fails.
    - ---
    - → [ListTag(LocationTag)]

    script:
    - if <list[<[cornerOne]>|<[cornerTwo]>].parse_tag[<[parse_value].object_type>]> != <list[Location|Location]>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to generate particle cube. One or more of the provided start or end locations: <element[<[cornerOne]>, <[cornerTwo]>].color[red]> are invalid.]>
        - determine null

    - define spread <[spread].if_null[1]>

    - if !<[spread].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to generate particle cube. Provided particle spread value: <[spread].color[red]> must be a decimal.]>
        - determine null

    - define cuboid <cuboid[<[cornerOne].world.name>,<[cornerOne].xyz>,<[cornerTwo].xyz>]>
    - define cuboidCornersBottom <[cuboid].corners.get[1].to[4]>
    - define cuboidCornersTop <[cuboid].corners.get[5].to[8]>
    - define cuboidCorners <[cuboidCornersBottom].get[1|2|4|3|1].include[<[cuboidCornersTop].get[1|2|4|3|1]>]>
    - define cubeLocations <list[]>

    - foreach <[cuboidCorners]> as:posOne:
        - define posTwo <[cuboidCorners].get[<[loop_index].add[1]>].if_null[null]>

        - if <[posTwo]> == null:
            - foreach stop

        - inject GenerateParticleLine path:GenerateLine
        - define cubeLocations <[cubeLocations].include[<[locationList]>]>

    - define posOne:!
    - define posTwo:!

    - foreach <[cuboidCorners].get[2|7|3|8|4|9]>:
        - define posTwo <[value]> if:<[posTwo].exists.not.and[<[posOne].exists>]>
        - define posOne <[value]> if:<[posOne].exists.not>

        - if <[posOne].exists> && <[posTwo].exists>:
            - inject GenerateParticleLine path:GenerateLine
            - define cubeLocations <[cubeLocations].include[<[locationList]>]>

            - define posOne:!
            - define posTwo:!

    - determine <[cubeLocations]>


GenerateParticlePyramid:
    type: procedure
    debug: false
    definitions: cornerOne[LocationTag]|cornerTwo[LocationTag]|spread[?ElementTag(Float) = 1]
    description:
    - Returns a pyramid of particles of the provided type between the two positions provided. Each particle is spread out one block apart by default, but this distance can be changed by specifying a custom `spread`.
    - Will return null if the action fails.
    - ---
    - → [ListTag(LocationTag)]

    script:
    - if <list[<[cornerOne]>|<[cornerTwo]>].parse_tag[<[parse_value].object_type>]> != <list[Location|Location]>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to generate particle pyramid. One or more of the provided start or end locations: <element[<[cornerOne]>, <[cornerTwo]>].color[red]> are invalid.]>
        - determine null

    - define spread <[spread].if_null[1]>

    - if !<[spread].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to generate particle pyramid. Provided particle spread value: <[spread].color[red]> must be a decimal.]>
        - determine null

    - define cuboid <cuboid[<[cornerOne].world.name>,<[cornerOne].xyz>,<[cornerTwo].xyz>]>
    - define topPoint <[cuboid].center.with_y[<[cuboid].corners.get[5].y>]>
    - define cuboidCornersBottom <[cuboid].corners.get[1].to[4]>
    - define cuboidCorners <[cuboidCornersBottom].get[1|2|4|3|1].include[<[topPoint]>]>
    - define cubeLocations <list[]>

    - foreach <[cuboidCorners]> as:posOne:
        - define posTwo <[cuboidCorners].get[<[loop_index].add[1]>].if_null[null]>

        - if <[posTwo]> == null:
            - foreach stop

        - inject GenerateParticleLine path:GenerateLine
        - define cubeLocations <[cubeLocations].include[<[locationList]>]>

    - define posOne:!
    - define posTwo:!

    - foreach <[cuboidCorners].get[2|6|3|6|4|6]>:
        - define posTwo <[value]> if:<[posTwo].exists.not.and[<[posOne].exists>]>
        - define posOne <[value]> if:<[posOne].exists.not>

        - if <[posOne].exists> && <[posTwo].exists>:
            - inject GenerateParticleLine path:GenerateLine
            - define cubeLocations <[cubeLocations].include[<[locationList]>]>

            - define posOne:!
            - define posTwo:!

    - determine <[cubeLocations]>


GenerateParticleVortex:
    type: procedure
    debug: false
    definitions: center[LocationTag]|radius[ElementTag(Float)]|spread[?ElementTag(Float) = 1]
    description:
    - Returns a pyramid of particles of the provided type between the two positions provided. Each particle is spread out one block apart by default, but this distance can be changed by specifying a custom `spread`.
    - Will return null if the action fails.
    - ---
    - → [ListTag(LocationTag)]

    script:
    - if <[center].object_type> != Location:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to generate particle vortex. The provided center location: <[center].color[red]> is invalid.]>
        - determine null

    - define spread <[spread].if_null[1]>

    - if !<[spread].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to generate particle vortex. Provided particle spread value: <[spread].color[red]> must be a decimal.]>
        - determine null

    - define points <[radius].mul[10]>
    - define pointList <list[]>

    - repeat <[radius].div[<[spread]>]>:
        - define radiusDropOff <[value].power[2].sub[<[value]>].mul[<[spread]>].div[<[radius]>]>
        - define pointSpacingDropOff <[radiusDropOff].add[1].power[1.5].round_up>

        - define pointList <[pointList].include[<[center].add[<[spread].mul[<[value]>]>,0,0].points_around_x[radius=<[radiusDropOff]>;points=<[pointSpacingDropOff]>]>]>
        - define pointList <[pointList].include[<[center].sub[<[spread].mul[<[value]>]>,0,0].points_around_x[radius=<[radiusDropOff]>;points=<[pointSpacingDropOff]>]>]>

    - determine <[pointList]>


GenerateParticleSphere:
    type: procedure
    debug: false
    definitions: center[LocationTag]|radius[ElementTag(Float)]|spread[?ElementTag(Float) = 1]
    description:
    - Returns a pyramid of particles of the provided type between the two positions provided. Each particle is spread out one block apart by default, but this distance can be changed by specifying a custom `spread`.
    - Will return null if the action fails.
    - ---
    - → [ListTag(LocationTag)]

    script:
    - if <[center].object_type> != Location:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to generate particle sphere. The provided center location: <[center].color[red]> is invalid.]>
        - determine null

    - if !<[spread].is_decimal>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to generate particle sphere. Provided particle spread value: <[spread].color[red]> must be a decimal.]>
        - determine null

    - define sphereRadius <[radius]>
    - define thetaIncrements 10
    - define oneTheta <element[90].div[<[thetaIncrements]>]>
    - define location <[center]>
    - define pointList <list[]>

    - repeat <[thetaIncrements]>:
        - define theta <[oneTheta].mul[<[value]>]>
        - define circleRadius <[theta].to_radians.cos.mul[<[sphereRadius]>]>
        - define heightAboveLocation <[theta].to_radians.sin.mul[<[sphereRadius]>]>

        - define pointList <[pointList].include[<[location].up[<[heightAboveLocation]>].points_around_y[radius=<[circleRadius]>;points=<[circleRadius].mul[2].mul[<util.pi>]>]>]>
        - define pointList <[pointList].include[<[location].up[0.5].down[<[heightAboveLocation]>].points_around_y[radius=<[circleRadius]>;points=<[circleRadius].mul[2].mul[<util.pi>]>]>]>

    - determine <[pointList]>


##### PARTICLE DISPLAY TRIGGERS
#################################################

DisplayParticleShape:
    type: task
    debug: false
    definitions: locationList[ListTag(LocationTag)]|players[Union[PlayerTag / ListTag(PlayerTag)]]|particle[ElementTag(String)]
    description:
    - Displays a single batch of particles at the provided locations, visible to the provided players.
    - Will return null if the action fails.
    - ---
    - → [Void]

    script:
    - inject <script.name> path:ValidateParticleParams
    - inject <script.name> path:PlayEffect

    PlayEffect:
    - if <[specialData].exists>:
        - playeffect effect:<[particle]> offset:0,0,0 targets:<[players]> at:<[locationList]> special_data:<[specialData]> quantity:1

    - else:
        - playeffect effect:<[particle]> offset:0,0,0 targets:<[players]> at:<[locationList]> quantity:1

    ValidateParticleParams:
    - if <[players].is_player>:
        - define players <list[<[players]>]>

    - if <[players].object_type> != List:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to display particle shape. Parameter `players` must by a list.]>
        - determine null

    - if !<[players].get[1].is_player>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to display particle shape. Provided parameter: <[players].color[red]> must be a list consisting only of valid players.]>
        - determine null

    - if <[locationList].get[1].object_type> != Location:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to display particle shape. Provided parameter: <[locationList].color[red]> must be a list consisting only of valid locations.]>
        - determine null

    - if !<[particle].is_in[<server.particle_types.include[<server.effect_types>]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Unable to display particle shape. Provided particle name: <[particle].color[red]> is not a valid particle type.]>
        - determine null


ParticleDisplayDurationTrigger:
    type: task
    debug: false
    definitions: locationList[ListTag(LocationTag)]|players[Union[PlayerTag / ListTag(PlayerTag)]]|particle[ElementTag(String)]|duration[DurationTag]
    description:
    - Displays a particle shape at the provided locations, visible to the provided players, repeatedly for a specified duration.
    - Will return null if the action fails.
    - ---
    - → [Void]

    script:
    - inject DisplayParticleShape path:ValidateParticleParams

    - if <[duration].object_type> != Duration:
        - run GenerateInternalError def.category:TypeError def.message:<element[Unable to display particle shape. Provided parameter: <[duration].color[red]> must be a valid duration.]>
        - determine null

    - define stopTime <util.time_now.add[<[duration]>]>

    - while <util.time_now.is_before[<[stopTime]>]>:
        - inject DisplayParticleShape path:PlayEffect
        - wait 5t


ParticleDisplayStaggeredTrigger:
    type: task
    debug: false
    definitions: locationList[ListTag(LocationTag)]|players[Union[PlayerTag / ListTag(PlayerTag)]]|particle[ElementTag(String)]
    script:
    - inject DisplayParticleShape path:ValidateParticleParams

    - foreach <[locationList]> as:loc:
        - inject DisplayParticleShape path:PlayEffect
        - wait 1t