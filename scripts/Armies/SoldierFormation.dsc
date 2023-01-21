########################
## THIS FILE IS INDEV ##
########################

# TODO: Add if case in caller function which throws an error to the player if the squad isn't assigned a leader yet
# Also TODO: Compensate for Denizen's shitty definition handling


DEBUG_RunFormationWalk:
    type: task
    script:
    - run FormationWalkTwo def.npcList:<server.flag[armies.cambrian.squads.test-1.npcList]> def.squadLeader:<npc[385]> def.npcsPerRow:3


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

FormationWalkTwo:
    type: task
    definitions: npcList|squadLeader|npcsPerRow
    script:
    - define spacing 2
    - define totalRows <[npcList].size.div[<[npcsPerRow]>].round_up>
    - define sentNPCs <list[<[squadLeader]>]>

    - repeat <[totalRows]> as:row:
        - narrate format:debug ROW:<[row]>

        - repeat <[npcsPerRow]> from:<[npcsPerRow].div[2].round_up.sub[<[npcsPerRow]>]> as:col:
            - narrate format:debug COL:<[col]>

            - if <[row]> == 1 && <[col]> == 0:
                - repeat next

            - else:
                - define newX <[col].mul[<[spacing]>]>
                - define location <[squadLeader].location.round.sub[<[newX]>,0,<[row]>].center>

                - run ClosestSquadMember def.npcList:<[npcList].exclude[<[sentNPCs]>]> def.location:<[location]> save:closest
                - define closestSquadMember <entry[closest].created_queue.determination.get[1]>
                - walk <[closestSquadMember]> <[location]>
                - flag <[closestSquadMember]> dataHold.formationPathfinding:<[location]>

                - define sentNPCs:->:<[closestSquadMember]>

                - narrate format:debug LOC:<[location]>
                - narrate format:debug ----------------------


FormationWalk:
    type: task
    definitions: npcList|squadLeader|npcsPerRow
    script:
    - define spacing 1
    - define leftOfLeader <list[]>
    - define npcList <[npcList].exclude[<[squadLeader]>]>

    - foreach <[npcList]> as:npc:
        - if <[npc].location.x> > <[squadLeader].location.x>:
            - define leftOfLeader:->:<[npc]>

    - narrate format:debug LEFT:<[leftOfLeader]>

    - define rightOfLeader <[npcList].exclude[<[leftOfLeader]>]>
    - define roundedLeaderPos <[squadLeader].location.round>

    - narrate format:debug RIGHT:<[rightOfLeader]>

    - foreach <[leftOfLeader]> as:npc:
        - define finalLocation <[roundedLeaderPos].add[<[spacing].mul[<[loop_index]>].add[1]>,0,-1].center>
        - walk <[npc]> <[finalLocation]>
        - flag <[npc]> dataHold.formationPathfinding:<[finalLocation]>

    - foreach <[rightOfLeader]> as:npc:
        - define finalLocation <[roundedLeaderPos].sub[<[spacing].mul[<[loop_index]>].add[1]>,0,1].center>
        - walk <[npc]> <[finalLocation]>
        - flag <[npc]> dataHold.formationPathfinding:<[finalLocation]>


FormationWalkFix_Handler:
    type: world
    events:
        on npc completes navigation:
        - if <npc.has_flag[dataHold.formationPathfinding]>:
            - ratelimit <npc> 10t
            - define location <npc.flag[dataHold.formationPathfinding]>
            - teleport <npc> <[location]>
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