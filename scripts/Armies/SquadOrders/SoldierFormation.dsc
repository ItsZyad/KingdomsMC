##
## All tasks and helpers related to making squads move will be found here.
##
## @Author: Zyad (ITSZYAD#9280)
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
    definitions: npcList|location
    script:
    - define closestNpc null
    - define closestDist 99999

    - foreach <[npcList]> as:npc:
        - if <[closestNpc]> == null || <[npc].location.distance[<[location]>]> < <[closestDist]>:
            - define closestNpc <[npc]>
            - define closestDist <[npc].location.distance[<[location]>]>

    - determine <[closestNpc]>


DiagonalLineHelper:
    type: procedure
    definitions: loc|length
    script:
    - define locRight <[loc].with_yaw[<[loc].yaw.add[90]>]>
    - define locLeft <[loc].with_yaw[<[loc].yaw.sub[90]>]>
    - define pointOne <[locRight].add[<[locRight].direction.vector.mul[<[length]>]>]>
    - define pointTwo <[locLeft].add[<[locLeft].direction.vector.mul[<[length]>]>]>
    - determine <list[<[pointOne]>|<[pointTwo]>]>


FormationWalk:
    type: task
    definitions: npcList|npcsPerRow|squadLeader|finalLocation|lineLength|player
    script:
    - define lineLength <[lineLength].if_null[6]>

    # Note: adding one to the npcList size to account for squad leader;
    - define rows <[npcList].size.add[1].div[<[npcsPerRow]>].round_up>
    #- define verticalSpacing <[lineLength].div[<[npcsPerRow]>]>
    - define verticalSpacing 2
    - define sentNPCs <list[<[squadLeader]>]>

    - repeat <[rows]> as:row:
        - define formationLinePoints <proc[DiagonalLineHelper].context[<[finalLocation].backward_flat[<[row].sub[1].mul[<[verticalSpacing]>]>]>|<[lineLength]>]>
        - define formationLine <[formationLinePoints].get[1].points_between[<[formationLinePoints].get[2]>].include[<[formationLinePoints]>]>
        - define spacing <[formationLine].size.div[<[npcsPerRow]>].round>

        - showfake green_wool <[formationLine]> players:<[player]>

        - repeat <[npcsPerRow]> as:col:
            - if <[npcList].exclude[<[sentNPCs]>].is_empty>:
                - repeat stop

            - if <[row]> == 1 && <[col]> == <[npcsPerRow].div[2].round>:
                - walk <[squadLeader]> <[finalLocation].with_y[<[finalLocation].y.add[1]>]>
                - flag <[squadLeader]> dataHold.formationPathfinding:<[finalLocation].with_y[<[finalLocation].y.add[1]>]>
                - showfake red_wool <[finalLocation]> players:<[player]>

            - else:
                - define lineDistanceVector <[formationLinePoints].get[1].sub[<[formationLinePoints].get[1].direction.vector.mul[<[col].sub[1].mul[<[spacing]>]>]>]>
                - define lineDistanceVector <[lineDistanceVector].with_y[<[lineDistanceVector].y.add[1]>]>

                - define locOnLine <[formationLine].get[<[col].mul[<[spacing]>]>]>
                - run ClosestSquadMember def.npcList:<[npcList].exclude[<[sentNPCs]>]> def.location:<[lineDistanceVector]> save:closest
                - define closestSquadMember <entry[closest].created_queue.determination.get[1]>

                - walk <[closestSquadMember]> <[lineDistanceVector]>

                - flag <[closestSquadMember]> dataHold.formationPathfinding:<[lineDistanceVector]>
                - define sentNPCs:->:<[closestSquadMember]>


FormationWalkFix_Handler:
    type: world
    debug: false
    events:
        on npc completes navigation:
        - if <npc.has_flag[dataHold.formationPathfinding]>:
            - ratelimit <npc> 10t
            - define location <npc.flag[dataHold.formationPathfinding]>
            - teleport <npc> <[location].with_yaw[<npc.location.yaw>].with_pitch[<npc.location.pitch>]>
            - flag <npc> dataHold.formationPathfinding:!
