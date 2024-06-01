FormationLineTool_Item:
    type: item
    material: arrow
    display name: <blue>Draw Squad Formation
    enchantments:
    - sharpness:1

    mechanisms:
        hides: ALL


FormationLineTool_Handler:
    type: world
    debug: false
    events:
        on player right clicks block with:FormationLineTool_Item flagged:!datahold.armies.drawingFormation:
        - if !<player.cursor_on[100].exists>:
            - ratelimit <player> 1s

            - narrate format:callout "Cannot detect any blocks near you! Please get closer to your target location."
            - determine cancelled

        - narrate format:callout "P1: <player.cursor_on[100]>"
        - flag <player> datahold.armies.drawingFormation.pointOne:<player.cursor_on[100]>

        on player right clicks block with:FormationLineTool_Item flagged:datahold.armies.drawingFormation:
        - ratelimit <player> 3t

        - define pointTwo <player.cursor_on[100]>
        - define pointOne <player.flag[datahold.armies.drawingFormation.pointOne]>
        - flag <player> datahold.armies.drawingFormation.pointTwo:<[pointTwo]>

        - run CreateParticleLine path:ClearParticleLineFlag def.flagName:formationLine
        - wait 1t
        - run CreateParticleLine def.pointOne:<[pointOne]> def.pointTwo:<[pointTwo]> def.particle:CLOUD def.flagName:formationLine def.targets:<player>

        on player drops FormationLineTool_Item flagged:datahold.armies.drawingFormation:
        - determine passively cancelled

        - run CreateParticleLine path:ClearParticleLineFlag def.flagName:formationLine

        - flag <player> datahold.armies.drawingFormation:!
        - narrate format:callout "Cleared current location selection."


CreateParticleLine:
    type: task
    debug: false
    definitions: pointOne[LocationTag]|pointTwo[LocationTag]|particle[ElementTag(String)]|flagName[ElementTag(String)]|targets[Union[[ListTag(PlayerTag)][PlayerTag]]
    description:
    - Creates a straight line of the provided particles between two points.
    - ---
    - → [Void]

    script:
    ## Creates a straight line of the provided particles between two points.
    ##
    ## pointOne : [LocationTag]
    ## pointTwo : [LocationTag]
    ## particle : [ElementTag(String)]
    ## flagName : [ElementTag(String)]
    ## targets  : [ListTag(PlayerTag)] | [PlayerTag]
    ##
    ## >>> [Void]

    - if !<list[<[pointOne].object_type>|<[pointOne].object_type>].deduplicate.get[1]> == Location:
        - run GenerateInternalError def.message:<element[Cannot create particle line without two valid locations. Instead got: <[pointOne].color[gray]> and <[pointTwo].color[gray]>.]>
        - stop

    - if !<[targets].object_type.is_in[List|Player|Entity]>:
        - run GenerateInternalError def.message:<element[Cannot create particle line without a target or list of targets. Instead got: <[targets].color[gray]>]>
        - stop

    - flag server datahold.particle.<[flagName]>:!
    - flag server datahold.particle.<[flagName]>

    - define particleLine <[pointOne].points_between[<[pointTwo]>].distance[0.5].parse_tag[<[parse_value].add[0,1,0]>]>

    - while <server.has_flag[datahold.particle.<[flagName]>]>:
        - playeffect at:<[particleLine]> effect:<[particle]> quantity:1 targets:<[targets]> offset:0,0,0
        - wait 6t

    ClearParticleLineFlag:
    - flag server datahold.particle.<[flagName]>:!
