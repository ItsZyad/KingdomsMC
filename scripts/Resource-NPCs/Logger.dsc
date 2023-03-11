##
## * All code related to how loggers/woodcutters operate
## * in addition to their AOEs.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2021
## @Script Ver: v0.1
## @ Clean Code Classification: 2
##
## ----------------END HEADER-----------------

##ignorewarning raw_object_notation

LoggerRangeFinder:
    type: task
    definitions: npc|radius
    script:
    - define npcLoc <[npc].location>
    - define locOne <[npcLoc].right[<[radius]>].forward[<[radius]>]>
    - define locTwo <[npcLoc].left[<[radius]>].backward[<[radius]>]>
    - define areaOfEffect <cuboid[<[npc].location.world.name>,<[locOne].x>,<[npcLoc].y.add[20]>,<[locOne].z>,<[locTwo].x>,<[npcLoc].y.sub[20]>,<[locTwo].z>]>

    - narrate format:debug <[areaOfEffect]>

    - if <[areaOfEffect].if_null[true]>:
        - narrate "<red><bold>An internal error has occured!"
        - narrate "<red>Please contact the server admin about this issue ASAP!"
        - narrate "<gray><bold>Reference Info:"
        - narrate "<gray>File: Logger.dsc, Script: LoggerRangeFinder/TASK"

    - else:
        - note <[areaOfEffect]> as:INTERNAL_ranch_<[npc].flag[kingdom]>_<[npc].id>


LoggerGenerationHandler_NEW:
    #type: task
    #script:
    type: world
    debug: false
    events:
        on system time secondly every:50:
        - foreach <util.notes[cuboids].filter_tag[<[filter_value].starts_with[cu@INTERNAL_ranch]>]> as:ranch:
            - define npcID <[ranch].split[_].get[4]>
            - define npc <npc[<[npcID]>]>
            - define kingdom <[ranch].split[_].get[3]>
            - define isKingdomBankrupt <proc[IsKingdomBankrupt].context[<server.flag[kingdoms.<[kingdom]>.balance]>|<[kingdom]>]>
            - define npcLevel <[npc].flag[Level]>
            - define npcIteration <element[100].sub[<[npcLevel]>].round_up_to_precision[10].div[10]>
            - define lowestY 1000
            - define treeStarts <list[]>

            - if <[npc].inventory.is_full>:
                - foreach next

            - foreach <[ranch].blocks[*_log]> as:block:
                - define yLoc <[block].y>

                - if <[yLoc].is[LESS].than[<[lowestY]>]>:
                    - define lowestY <[yLoc]>

            - foreach <[ranch].blocks[*_log]> as:block:
                - if <[block].y> == <[lowestY]>:
                    - define treeStarts:->:<[block]>

            #- narrate format:debug <[treeStarts]>
            - define currentBlock <[treeStarts].random>
            - define startBlock <[currentBlock]>
            - define numOfLogs 0

            - while <[currentBlock].material.name.advanced_matches[*_log]>:
                - define searchArea <cuboid[<[currentBlock].world.name>,<[currentBlock].add[2,0,2].xyz>,<[currentBlock].sub[2,0,2].xyz>]>

                #- showfake red_stained_glass <[searchArea].outline_2d[<[currentBlock].y>]> duration:1s target:<[npc].find_players_within[20]>

                - define prevBaseLevel <[npc].flag[Level].round_down>

                - flag <[npc]> Level:+:0.007

                - if <[npc].flag[Level].round_down> != <[prevBaseLevel]>:
                    - rename t:<[npc]> <[npc].nickname.split[<&sp>].get[1].to[-2].space_separated><&sp><[npc].flag[Level].round_down>
                    - define kingdom <[npc].flag[kingdom]>
                    - define prestige <server.flag[kingdoms.<[kingdom]>.prestige]>
                    - define level <[npc].flag[Level]>

                    - flag <[npc]> outputMod:+:<[level].mul[<[prestige].div[20]>]>

                - if <[loop_index]> >= 50:
                    - narrate format:debug "Oops... Loop index exceeded 50! Killing queue: <script.queues.get[1]>"

                - define searchIndexes <[searchArea].blocks.parse_tag[<[parse_value].material.name>].find_all_matches[*_log]>
                - modifyblock <[searchArea].blocks.get[<[searchIndexes]>]> air
                - define currentBlock <[currentBlock].add[0,1,0]>
                - define numOfLogs:++

                - wait 10t

            - if <util.random.int[1].to[50].is[OR_MORE].than[25]>:
                - give <[npc].inventory> stick quantity:<util.random.int[1].to[5]>

            - give to:<[npc].inventory> <[currentBlock].material.name.split[_].get[1]>_log quantity:<[numOfLogs].mul[<[npc].flag[outputMod].add[1]>].round>
            - give to:<[npc].inventory> <[currentBlock].material.name.split[_].get[1]>_sapling quantity:<util.random.int[1].to[<util.random.int[1].to[4]>]>
            - modifyblock <[startBlock]> <[currentBlock].material.name.split[_].get[1]>_sapling


LoggerGenerationHandler:
    type: task
    script:
    #type: world
    #events:
    #    on system time secondly every:50:
        # Loop through all the noted regions that start with 'ranch'
        # and run the generation code relating to their NPCs.

        - foreach <util.notes[cuboids].filter_tag[<[filter_value].starts_with[cu@INTERNAL_ranch]>]>:
            #- narrate <[value].blocks[oak_log]>

            - define npcID <[value].split[_].get[4]>
            - define npc <npc[<[npcID]>]>

            - if !<proc[IsKingdomBankrupt].context[<server.flag[kingdoms.<[npc].flag[kingdom]>.balance]>|<[npc].flag[kingdom]>]>:
                - define npcLevel <[npc].flag[Level]>
                - define npcIteration <element[100].sub[<[npcLevel]>].round_up_to_precision[10].div[10]>

                - define kingdom <[value].split[_].get[2]>
                - define levelRounded25 <[npcLevel].round_up_to_precision[25]>

                - define treeStarts <list[]>
                - define lowestY 1000

                #- if <util.random.int[<[levelRounded25]>].to[100].is[OR_MORE].than[50]>:
                - foreach <[value].blocks[*_log]> as:block:
                    - define yLoc <[block].y>

                    - if <[yLoc].is[LESS].than[<[lowestY]>]>:
                        - define lowestY <[yLoc]>

                - foreach <[value].blocks[*_log]> as:block:

                    - if <[block].y> == <[lowestY]>:
                        - define treeStarts:->:<[block]>

                #- narrate <[treeStarts]>

                - define currentTree <list[]>
                - define treeIndex <util.random.int[1].to[<[treeStarts].size>]>
                - define currentBlock <[treeStarts].get[<[treeIndex]>]>

                - while <[currentBlock].material.name.advanced_matches[*_log]>:
                    - define currentTree:->:<[treeStarts].get[<[treeIndex]>].up[<[loop_index]>]>

                    - if <[npc].inventory.can_fit[<[currentBlock]>]>:
                        - define prevBaseLevel <[npc].flag[Level].round_down>

                        - flag <[npc]> Level:+:0.002

                        - if <[npc].flag[Level].round_down> != <[prevBaseLevel]>:
                            - rename t:<[npc]> <[npc].nickname.substring[1,<[npc].nickname.length.sub[1]>]><[npc].flag[Level].round_down>

                            - define kingdom <[npc].flag[kingdom]>
                            - define prestige <server.flag[kingdoms.<[kingdom]>.prestige]>
                            - define level <[npc].flag[Level]>

                            - flag <[npc]> outputMod:+:<[level].mul[<[prestige].div[20]>]>

                    - define removalCuboid <cuboid[<[npc].location.world.name>,<[currentBlock].add[2,0,2].xyz>,<[currentBlock].sub[2,0,2].xyz>]>
                    - modifyblock <[removalCuboid].filter_tag[<[filter_value].material.name.advanced_matches[*_log]>]> air
                    - narrate format:debug CUB:<[removalCuboid]>
                    - narrate format:debug NPC:<[npc]>

                    - if <list[dirt|grass_block|coarse_dirt].contains[<[currentBlock].down[1].material.name>]>:
                        - narrate <[currentBlock].up[1].material.name.split[_].get[1]>_sapling

                        - modifyblock <[currentBlock]> <[currentBlock].up[1].material.name.split[_].get[1]>_sapling

                    - define currentBlock <[currentBlock].add[0,1,0]>
                    - narrate format:debug CURR:<[currentBlock].material>

                - give to:<[npc].inventory> <[currentBlock].material.name.split[_].get[1]>_log quantity:<[currentTree].size.mul[<[npc].flag[outputMod].add[1]>].round>
                - give to:<[npc].inventory> <[currentBlock].material.name.split[_].get[1]>_sapling quantity:<util.random.int[1].to[<util.random.int[1].to[4]>]>

                - if <util.random.int[1].to[50].is[OR_MORE].than[25]>:
                    - give <[npc].inventory> stick quantity:<util.random.int[1].to[5]>

                - narrate format:debug <[currentTree]>
