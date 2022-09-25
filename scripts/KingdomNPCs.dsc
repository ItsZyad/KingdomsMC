# Dev Note: I may just be retarded but I cannot for the life of me understand how Denizen handles locations. It elludes me. So if you're reading through this and wondering why the code quality here is utter ass, that would be why.

MinerAction:
    type: assignment
    actions:
        on assignment:
            - modifyblock <npc.location> torch

            - repeat 10:
                - if <npc.location.direction> == north:
                    - define newLoc <location[<npc.location.x>,<npc.location.y>,<npc.location.z.sub[1]>,0,180,<npc.location.world>]>

                - if <npc.location.direction> == south:
                    - define newLoc <location[<npc.location.x>,<npc.location.y>,<npc.location.z.add[1]>,0,0,<npc.location.world>]>

                - if <npc.location.direction> == west:
                    - define newLoc <location[<npc.location.x.sub[1]>,<npc.location.y>,<npc.location.z>,0,90,<npc.location.world>]>

                - if <npc.location.direction> == east:
                    - define newLoc <location[<npc.location.x.add[1]>,<npc.location.y>,<npc.location.z>,0,270,<npc.location.world>]>

                - ~break <definition[newLoc]> <npc> radius:6
                - ~break <definition[newLoc].right[1]> <npc> radius:6
                - ~break <definition[newLoc].up[1]> <npc> radius:6
                - ~break <definition[newLoc].up[1].right[1]> <npc> radius:6

                #- narrate format:debug <definition[newLoc].down[1].left[1]>

                - teleport <npc> <definition[newLoc]>
                #- ~look <npc> <definition[newLoc]>
                - wait 0.25s

StripMiner_Old:
    type: assignment
    actions:
        on assignment:
            - define newLoc <npc.location>

            - if <npc.location.direction> == east:
                - define newLoc <location[<npc.location.x>,<npc.location.y>,<npc.location.z.sub[1]>,0,270,KingdomsUTD]>

            - if <npc.location.direction> == west:
                - define newLoc <location[<npc.location.x>,<npc.location.y>,<npc.location.z.add[1]>,0,90,KingdomsUTD]>

            - if <npc.location.direction> == south:
                - define newLoc <location[<npc.location.x.add[1]>,<npc.location.y>,<npc.location.z>,0,0,KingdomsUTD]>

            - if <npc.location.direction> == north:
                - define newLoc <location[<npc.location.x.sub[1]>,<npc.location.y>,<npc.location.z>,0,180,KingdomsUTD]>


            - ~walk <npc.location.forward_flat[4]>
            - break <definition[newLoc]>
            - break <definition[newLoc].up[1]>
            - look <definition[newLoc]>
            - wait 2s

            - repeat 10:
                - teleport <npc> <location[<npc.location.x.round>,<npc.location.y.round>,<npc.location.z.round>,<npc.location.pitch>,90,KingdomsUTD]>
                - break <npc.location.forward[1]> radius:3
                - break <npc.location.forward[1].up[1]> radius:3
                - teleport <npc> <npc.location.forward[1]>
                - look <npc.location.right[90]>
                - wait 0.25s

StripMiner:
    type: assignment
    actions:
        on assignment:
            - define minerYaw 180

            - if <proc[IsFacingWall]>:
                - if <npc.location.direction> == east:
                    - define minerYaw 270

                - if <npc.location.direction> == west:
                    - define minerYaw 90

                - if <npc.location.direction> == south:
                    - define minerYaw 0

                - if <proc[IsRightCloser]>:
                    - teleport <npc> <location[<npc.location.x.round_up.sub[0.5]>,<npc.location.y.round>,<npc.location.z.round_up.sub[0.5]>,0,<definition[minerYaw]>,<npc.location.world>]>
                    - look <npc.location.right[90]>
                - else:
                    - teleport <npc> <location[<npc.location.x.round_up.sub[0.5]>,<npc.location.y.round>,<npc.location.z.round_up.sub[0.5]>,0,<definition[minerYaw]>,<npc.location.world>]>
                    - look <npc.location.right[-90]>

            - wait 0.5s

            - repeat 10:
                - break <npc> <npc.location.forward_flat[1]> radius:3
                - break <npc> <npc.location.forward_flat[1].up[1]> radius:3
                - teleport <npc> <location[<npc.location.forward[1].x>,<npc.location.forward[1].y>,<npc.location.forward[1].z>,0,<definition[minerYaw].sub[90]>,<npc.location.world>]>
                - wait 0.25s

IsFacingWall:
    type: procedure
    script:
    - if <npc.location.forward[1]>:
        - determine true
    - else:
        - determine false

IsRightCloser:
    type: procedure
    script:
    - define rightLen <npc.location>
    - define leftLen <npc.location>
    - define loopKill 0

    - while <definition[rightLen].material> != <material[air]> || <definition[loopKill].is[OR_MORE].than[999]>:
        - define rightLen <definition[rightLen].right[1]>
        - define loopKill <definition[loopKill].add[1]>

    - define loopKill 0

    - while <definition[leftLen].material> != <material[air]> || <definition[loopKill].is[OR_MORE].than[999]>:
        - define rightLen <definition[leftLen].left[1]>
        - define loopKill <definition[loopKill].add[1]>

    - if <definition[rightLen].is[OR_MORE].than[<definition[leftLen]>]>:
        - determine true
    - else:
        - determine false
