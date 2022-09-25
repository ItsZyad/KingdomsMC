##
## * All code related to how farmers operate. Their AOEs
## * and their experience gain etc.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2021
## @Updated: Jul 2022
## @Script Ver: v1.0
## @ Clean Code Classification: 3
##
## ----------------END HEADER-----------------

FarmerRangeFinder:
    type: task
    definitions: npc|radius
    script:
    - narrate format:debug "For debug purposes, an AOE border will be shown"

    - define npcLoc <[npc].location>
    - define locOne <[npcLoc].right[<[radius]>].forward[<[radius]>]>
    - define locTwo <[npcLoc].left[<[radius]>].backward[<[radius]>]>
    - define areaOfEffect <cuboid[<[npc].location.world.name>,<[locOne].x>,<[npcLoc].y.add[2]>,<[locOne].z>,<[locTwo].x>,<[npcLoc].y.sub[2]>,<[locTwo].z>]>
    - define world <[npc].location.world.name>
    - define areaOfEffect_DEBUG <cuboid[<[world]>,<[npcLoc].add[<[radius]>,3,<[radius]>].xyz>,<[npcLoc].sub[<[radius]>,3,<[radius]>].xyz>]>

    #- narrate format:debug <[npcLoc]>
    #- narrate format:debug <[locOne]>
    #- narrate format:debug <[areaOfEffect]>
    #- narrate --------------
    #- narrate format:debug <[npcLoc].y.sub[radius]>

    #- showfake red_stained_glass|blue_stained_glass <[areaOfEffect].outline_2d[<player.location.y>]> duration:5s

    - showfake glass <[areaOfEffect_DEBUG].outline> duration:5s

    - define farmerBlocks <list[wheat|carrot|potato|beetroot|sweet_berries]>
    - define numBlocks 0

    - foreach <[farmerBlocks]>:
        - define numBlocks:+:<[areaOfEffect_DEBUG].blocks[<[value]>].size>

    - narrate format:debug <[numBlocks]>

    - note <[areaOfEffect_DEBUG]> as:INTERNAL_farm_<[npc].flag[kingdom]>_<[npc].id>

    - chunkload add <[areaOfEffect_DEBUG].chunks>

FoodExperienceGain:
    type: data
    carrots: 0.5
    potato: 0.5
    potatoes: 0.5
    wheat: 0.3
    beetroot: 0.25
    sugar_cane: 0.1

FoodSingulars:
    type: data
    carrots: carrot
    potatoes: potato
    wheat: wheat
    beetroot: beetroot

FarmerGenerationHandler:
    type: world
    debug: false
    events:
        on block grows in:INTERNAL_farm_*:
        - wait 1t
        - if <context.material.age> == 7:
            - define foodTypes <script[FoodExperienceGain].list_keys>
            - define isMaterialFood <[foodTypes].contains[<context.material.name>]>
            - define farmArea <context.location.cuboids.get[<context.location.cuboids.find_partial[INTERNAL_farm_]>]>
            - define kingdom <[farmArea].split[_].get[3]>
            - define npcID <[farmArea].split[_].get[4]>
            - define npc <npc[<[npcID]>]>
            - define outpostMod <[npc].flag[outpostMod]>
            - define kingdomBalance <yaml[kingdoms].read[<[kingdom]>.balance]>

            - yaml load:kingdoms.yml id:kingdoms

            # Loop through all the blocks in the farm area that are valid food types...
            - foreach <[farmArea].blocks> as:block:

                # ...and are fully grown
                - if <[block].material.name.is_in[<[foodTypes]>]> && <[block].material.age> == 7:

                    - define foodSingular <script[FoodSingulars].data_key[<[block].material.name>]>
                    - define expGain <script[FoodExperienceGain].data_key[<[block].material.name>]>
                    - define baseDropMax <[outpostMod].mul[4].round.if_null[1]>
                    - define baseDrop <util.random.int[1].to[<[baseDropMax]>]>
                    - define bonusDrop <util.random.int[0].to[<[npc].flag[Level].round_down>]>
                    - define totalDrop <[bonusDrop].add[<[baseDrop]>].mul[<[outpostMod].get[1]>]>

                    # - narrate format:debug targets:<server.online_ops> BMAX:<[baseDropMax]>
                    # - narrate format:debug targets:<server.online_ops> BASE:<[baseDrop]>
                    # - narrate format:debug targets:<server.online_ops> BONU:<[bonusDrop]>
                    # - narrate format:debug targets:<server.online_ops> TOTA:<[totalDrop]>

                    # Ensure the farmer's kingdom is not bankrupt
                    - if !<proc[IsKingdomBankrupt].context[<[kingdomBalance]>|<[kingdom]>]>:
                        - if <[npc].inventory.can_fit[<[block].material.name>].quantity[<[totalDrop]>]>:
                            - define plantableFood <[block].material>
                            - adjust def:plantableFood age:0

                            - modifyblock <[block]> air no_physics
                            - modifyblock <[block]> <[plantableFood]>

                            - give to:<[npc].inventory> <[foodSingular]> quantity:<[totalDrop]>

                            # following 14 lines compare the NPCs level and exp before and after the items
                            # spawn and decide if the NPC has levelled up. If yes then it changes the NPC's
                            # display name

                            - define prevBaseLevel <[npc].flag[Level].round_down>
                            - flag <[npc]> Level:+:<[expGain].div[55]>

                            - if <[npc].flag[Level].round_down> != <[prevBaseLevel]>:
                                - rename t:<[npc]> <[npc].nickname.split[<&sp>].get[1].to[-2].space_separated><&sp><[npc].flag[Level].round_down>

                                # Level to output bonus ratio:
                                # y = Level * 0.01

                                - define bonusRatio <[npc].flag[Level].mul[0.01]>

                                - flag <[npc]> outputMod:<[bonusRatio].round_to_precision[0.01]>

            - yaml id:kingdoms unload

## IMPORTANT! DO NOT USE ##
FarmerGenerationHandler_OLD:
    type: task
    script:
    #debug: false
    #events:
    #    on block grows in:farm_*:
        - if <script[FoodExperienceGain].list_keys.contains[<context.material.name>]>:

            # farmArea holds the name of the farmerNPC area of effect they are located in
            # and -1 if they are not located within one

            - define farmArea <context.location.cuboids.get[<context.location.cuboids.find_partial[farm_]>]>

            #- narrate targets:<server.online_players> <[farmArea]>

            # material age 7 refers to fully-grown crops
            - if <context.material.age> == 7:
                - foreach <[farmArea].blocks> as:block:
                    - if !<[block].material.name.is_in[wheat|carrots|potatoes|beetroots|sugar_cane]>:
                        - foreach next

                    - else if <[block].material.age> != 7:
                        - foreach next

                    - narrate format:debug <[block].material.name> targets:<server.online_ops>

                    #- narrate targets:<server.online_players> <[block].location.add[1,1,1]> format:debug

                    #- narrate targets:<server.online_players> <[block].material.name> format:debug

                    - modifyblock <[block]> air no_physics
                    - wait 5t
                    - modifyblock <[block]> <[block].material.name>

                    - if <[farmArea]> != -1:
                        - define npcID <[farmArea].split[_].get[3]>
                        - define npc <npc[<[npcID]>]>

                        # If the NPC's kingdom is not currently in a state of bankruptcy (4+
                        # days in debt)

                        - yaml load:kingdoms.yml id:kingdoms

                        - if !<proc[IsKingdomBankrupt].context[<yaml[kingdoms].parsed_key[].deep_get[<player.flag[kingdom]>.balance]>|<[npc].flag[kingdom]>]>:
                            - define kingdom <[farmArea].split[_].get[2]>
                            - define expGain <script[FoodExperienceGain].data_key[<[block].material.name>]>

                            - define outpostMod <[npc].flag[outpostMod]>

                            # A bunch of RNG code to ensure that the farmer makes pseudo-random
                            # crop spawns every NPC tick

                            - define baseDropMax <[npc].flag[outputMod].mul[4].round>
    #                        - narrate targets:<player[ZyadTheBoss]> format:debug <[baseDropMax]>
                            - define baseDrop <util.random.int[1].to[<[baseDropMax]>]>
                            - define bonusDrop <util.random.int[0].to[<[npc].flag[Level].round_down>]>
                            - define totalDrop <[bonusDrop].add[<[baseDrop]>].mul[<[outpostMod].get[1]>]>

                            - if <[totalDrop]> == 0:
                                - define totalDrop 1

                            - if <[npc].inventory.can_fit[<[block].material.name>].quantity[<[totalDrop]>]>:
    #                            - narrate targets:<server.online_players> format:debug "Total Drop: <[totalDrop]>"

                                - if <[block].material.name> == wheat:
                                    - give to:<[npc].inventory> <[block].material.name> quantity:<[totalDrop]>

                                # most crop types in the game have plural names when still in the ground
                                # however have singular names when they are just inventory items

                                # this line ensures that the NPC is being given singular-name items

                                - else:
                                    - give to:<[npc].inventory> <[block].material.name.substring[1,<[block].material.name.length.sub[1]>]> quantity:<[totalDrop]>

                                # following 14 lines compare the NPCs level and exp before and after the items
                                # spawn and decide if the NPC has levelled up. If yes then it changes the NPC's
                                # display name

                                - define prevBaseLevel <[npc].flag[Level].round_down>

                                - flag <[npc]> Level:+:<[expGain].div[65]>

                                - if <[npc].flag[Level].round_down> != <[prevBaseLevel]>:
                                    - rename t:<[npc]> <[npc].nickname.substring[1,<[npc].nickname.length.sub[1]>]><[npc].flag[Level].round_down>

                                    # Level to output bonus ratio:
                                    # y = Level * 0.01

                                    - define bonusRatio <[npc].flag[Level].mul[0.01]>

                                    - flag <[npc]> outputMod:<[bonusRatio].round_to_precision[0.01]>

                    - yaml id:kingdoms unload



