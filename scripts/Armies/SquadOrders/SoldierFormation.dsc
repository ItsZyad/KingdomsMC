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
    - define rows <[npcList].size.div[<[npcsPerRow]>].round_up>
    #- define verticalSpacing <[lineLength].div[<[npcsPerRow]>]>
    - define verticalSpacing 2
    - define sentNPCs <list[<[squadLeader]>]>

    - repeat <[rows]> as:row:
        - define formationLinePoints <proc[DiagonalLineHelper].context[<[finalLocation].backward_flat[<[row].sub[1].mul[<[verticalSpacing]>]>]>|<[lineLength]>]>
        - define formationLine <[formationLinePoints].get[1].points_between[<[formationLinePoints].get[2]>].include[<[formationLinePoints]>]>
        - define spacing <[formationLine].size.div[<[npcsPerRow]>].round>

        - showfake green_wool <[formationLine]> players:<[player]>

        - repeat <[npcsPerRow]> as:col:
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
    events:
        on npc completes navigation:
        - if <npc.has_flag[dataHold.formationPathfinding]>:
            - ratelimit <npc> 10t
            - define location <npc.flag[dataHold.formationPathfinding]>
            - teleport <npc> <[location].with_yaw[<npc.location.yaw>].with_pitch[<npc.location.pitch>]>
            - flag <npc> dataHold.formationPathfinding:!


# Have a menu that allows you to enter garrison definition mode which first
# clears all other fake blocks before letting you start.

# It will then give the player a garrison definition flag and keep the fake
# blocks until that flag is removed/player exits garrison mode.


DEBUG_RefreshGarrisonArea:
    type: task
    definitions: target
    script:
    - define fakeBlockList <[target].flag[definingGarrison]>

    - if <[target].has_flag[definingGarrison]>:
        - foreach <[fakeBlockList]>:
            - showfake players:<server.online_players> red_stained_glass <[value]> d:100s
            #- flag <[target]> definingGarrison:!


DEBUG_GarrisonBrush_ITEM:
    type: item
    material: spectral_arrow
    display name: <light_purple><bold>Garrison Brush


DEBUG_GarrisonBrush_HANDLER:
    type: world
    events:
        on player left clicks block with:DEBUG_GarrisonBrush_ITEM:
        - flag <player> definingGarrison:!
        - showfake cancel target:<server.online_players> <player.fake_block_locations>

        on player right clicks block with:DEBUG_GarrisonBrush_ITEM:
        - ratelimit <player> 1t

        - define posRelative <list[-2|-1|0|1|2]>
        - define elevatedBy 1

        - if <player.cursor_on[100].material.name> == grass:
            - define elevatedBy 0

        - else if <player.cursor_on[100].material> == <material[tall_grass[half=BOTTOM]]>:
            - define elevatedBy 0

        - else if <player.cursor_on[100].material> == <material[tall_grass[half=TOP]]>:
            - define elevatedBy -1

        - foreach <[posRelative]> as:leftRight:
            #- if !<player.fake_block_locations.contains[<player.cursor_on[100].above[<[elevatedBy]>].left[<[leftRight]>]>]>:

            - foreach <[posRelative]> as:upDown:
                #- if !<player.fake_block_locations.contains[<player.cursor_on[100].above[<[elevatedBy]>].left[<[leftRight]>].backward[<[upDown]>]>]>:

                - define fakeBlockloc <player.cursor_on[100].above[<[elevatedBy]>].left[<[leftRight]>].backward[<[upDown]>]>

                - showfake players:<server.online_players> red_stained_glass <[fakeBlockLoc]> d:100
                - flag <player> definingGarrison:->:<[fakeBlockLoc]>

            #- narrate targets:<player[ZyadTheBoss]> <player.flag[definingGarrison].size>

        - runlater DEBUG_RefreshGarrisonArea def.target:<player> def.fakeBlockList:<player.flag[definingGarrison]> delay:99s
