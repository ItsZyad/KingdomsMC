##
## All tasks and helpers related to making squads move will be found here.
##
## @Author: Zyad <ITSZYAD#9280>
## @Date: Mar 2023
## @Updated: Jun 2023
##           -- All useless helper functions and test scripts were removed and remaining items
##              cleaned in prep for A4.
## @Script Ver: v2.0
##
## ------------------------------------------END HEADER-------------------------------------------

# TODO: Add if case in caller function which throws an error to the player if the squad isn't assigned a leader yet

ClosestSquadMember:
    type: task
    debug: false
    definitions: npcList[ListTag(NPCTag)]|location[LocationTag]
    description:
    - @Helper

    script:
    - define closestNpc <[npcList].get[1]>
    - define closestDist 99999

    - foreach <[npcList]> as:npc:
        - if <[closestNpc]> == null || <[npc].location.distance[<[location]>]> < <[closestDist]>:
            - define closestNpc <[npc]>
            - define closestDist <[npc].location.distance[<[location]>]>

    - determine <[closestNpc]>


DiagonalLineHelper:
    type: procedure
    definitions: loc[LocationTag]|length[ElementTag(Integer)]
    description:
    - @Helper

    script:
    - define locRight <[loc].with_yaw[<[loc].yaw.add[90]>]>
    - define locLeft <[loc].with_yaw[<[loc].yaw.sub[90]>]>
    - define pointOne <[locRight].add[<[locRight].direction.vector.mul[<[length]>]>]>
    - define pointTwo <[locLeft].add[<[locLeft].direction.vector.mul[<[length]>]>]>
    - determine <list[<[pointOne]>|<[pointTwo]>]>


FormationWalk:
    type: task
    definitions: npcList[ListTag(NPCTag)]|npcsPerRow[ElementTag(Integer)]|squadLeader[NPCTag]|finalLocation[LocationTag]|lineLength[ElementTag(Integer)]|player[PlayerTag]
    description:
    - Will arrange the provided list of NPCs into a set of rows as per the provided parameters: 'lineLength' and 'npcsPerRow'. Will take the parameter 'finalLocation' as the position to be assumed by the squadLeader.
    - ---
    - → [Void]

    script:
    ## Will arrange the provided list of NPCs into a set of rows as per the provided parameters:
    ## 'lineLength' and 'npcsPerRow'. Will take the parameter 'finalLocation' as the position to be
    ## assumed by the squadLeader.
    ##
    ## npcList       : [ListTag<NPCTag>]
    ## npcsPerRow    : [ElementTag<Integer>]
    ## squadLeader   : [NPCTag]
    ## finalLocation : [LocationTag]
    ## lineLength    : [ElementTag<Integer>]
    ## player        : [PlayerTag]
    ##
    ## >>> [Void]

    - define lineLength <[lineLength].if_null[6]>

    # Note: adding one to the npcList size to account for squad leader;
    - define rows <[npcList].size.add[1].div[<[npcsPerRow]>].round_up>
    #- define verticalSpacing <[lineLength].div[<[npcsPerRow]>]>
    - define verticalSpacing 3
    - define sentNPCs <list[<[squadLeader]>]>

    - repeat <[rows]> as:row:
        - define formationLinePoints <proc[DiagonalLineHelper].context[<[finalLocation].backward_flat[<[row].sub[1].mul[<[verticalSpacing]>]>]>|<[lineLength]>]>
        - define formationLine <[formationLinePoints].get[1].points_between[<[formationLinePoints].get[2]>].include[<[formationLinePoints]>]>
        # - define spacing <[formationLine].size.div[<[npcsPerRow]>].round>
        - define spacing 2

        # - showfake green_wool <[formationLine]> players:<[player]>

        - repeat <[npcsPerRow]> as:col:
            - if <[npcList].exclude[<[sentNPCs]>].is_empty>:
                - repeat stop

            - if <[row]> == 1 && <[col]> == <[npcsPerRow].div[2].round>:
                - walk <[squadLeader]> <[finalLocation].center.with_y[<[finalLocation].y.add[1]>]>
                - flag <[squadLeader]> dataHold.formationPathfinding:<[finalLocation].with_y[<[finalLocation].y.add[1]>]>
                - showfake red_wool <[finalLocation].center.with_y[<[finalLocation].y.add[1]>]> players:<[player]>

            - else:
                - define lineDistanceVector <[formationLinePoints].get[1].sub[<[formationLinePoints].get[1].direction.vector.mul[<[col].sub[1].mul[<[spacing]>]>]>]>
                - define lineDistanceVector <[lineDistanceVector].center.with_y[<[lineDistanceVector].y.add[1]>]>

                - define locOnLine <[formationLine].get[<[col].mul[<[spacing]>]>]>
                - run ClosestSquadMember def.npcList:<[npcList].exclude[<[sentNPCs]>]> def.location:<[lineDistanceVector]> save:closest
                - define closestSquadMember <entry[closest].created_queue.determination.get[1]>

                - walk <[closestSquadMember]> <[lineDistanceVector]>
                - showfake green_wool <[lineDistanceVector]> players:<[player]>

                - flag <[closestSquadMember]> dataHold.formationPathfinding:<[lineDistanceVector]>
                - define sentNPCs:->:<[closestSquadMember]>


DrawLineFormationWalk:
    type: task
    definitions: npcList[ListTag(NPCTag)]|soldierSpacing[ElementTag(Float)]|squadLeader[NPCTag]|player[PlayerTag]|pointOne[LocationTag]|pointTwo[LocationTag]
    description:
    - Will assign the provided list of npcs walk orders to a location along a line between the two provided points with the specified distance 'soldierSpacing' between them (in blocks).
    - If there are too many NPCs to fit on one line of the provided parameters, it will create the appropriate number of rows behind the initial line.
    - ---
    - → [Void]

    script:
    ## Will assign the provided list of npcs walk orders to a location along a line between the
    ## two provided points with the specified distance 'soldierSpacing' between them (in blocks).
    ##
    ## If there are too many NPCs to fit on one line of the provided parameters, it will create the
    ## appropriate number of rows behind the initial line.
    ##
    ## npcList        : [ListTag<NPCTag>]
    ## soldierSpacing : [ElementTag<Float>]
    ## squadLeader    : [NPCTag]
    ## player         : [PlayerTag]
    ## pointOne       : [LocationTag]
    ## pointTwo       : [LocationTag]
    ##
    ## >>> [Void]

    - define npcList <[npcList].include[<[squadLeader]>]>
    - define soliderSpacing 2 if:<[soldierSpacing].exists.not>
    - define formationLine <[pointOne].points_between[<[pointTwo]>].include[<[pointOne]>|<[pointTwo]>]>
    - define soldiersPerLine <[formationLine].size.div[<[soldierSpacing]>].round_down>
    - define lines <[npcList].size.div[<[soldiersPerLine]>].round_up>
    - define directionFacing <[player].location.yaw>

    - define unsentSoldiers <[npcList]>

    - flag <[player]> datahold.armies.lineLength:<[pointOne].sub[<[pointTwo]>].vector_length>
    - flag <[player]> datahold.armies.npcsPerRow:<[soldiersPerLine]>

    - repeat <[lines]> as:lineNum:
        - foreach <[formationLine]> as:pos:
            - if <[unsentSoldiers].is_empty>:
                - stop

            - if <[loop_index].mod[<[soldierSpacing]>]> != 0:
                - foreach next

            - define pos <[pos].with_pitch[0]>

            - if <[unsentSoldiers]> == <[npcList]>:
                - define closestSquadMember <[squadLeader]>

            - else:
                - run ClosestSquadMember def.npcList:<[unsentSoldiers]> def.location:<[pos]> save:closest
                - define closestSquadMember <entry[closest].created_queue.determination.get[1]>

            - flag <[closestSquadMember]> dataHold.formationPathfinding:<[pos].add[0,1,0].with_yaw[<[directionFacing]>]>
            - define unsentSoldiers:<-:<[closestSquadMember]>

            - run StaggeredPathfind def.npc:<[closestSquadMember]> def.endLocation:<[pos].center.add[0,1,0].with_yaw[<[directionFacing]>]> def.speed:1.15

        # Shifts the entire line back two blocks relative to the player's yaw
        - define pointOne <[pointOne].with_yaw[<[directionFacing]>].backward_flat[2]>
        - define pointTwo <[pointTwo].with_yaw[<[directionFacing]>].backward_flat[2]>
        - define formationLine <[pointOne].points_between[<[pointTwo]>].include[<[pointOne]>|<[pointTwo]>]>

        - if <[unsentSoldiers].is_empty>:
            - stop

        - define avgSecondLineDistance -1

        - while <[avgSecondLineDistance]> < 4:
            - if <[loop_index]> > 5:
                - while stop

            - define avgSecondLineDistance <[unsentSoldiers].parse_tag[<[parse_value].location.distance[<[closestSquadMember].location>]>].average>
            - wait 1s
