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
            - define kingdomBalance <server.flag[kingdoms.<[kingdom]>.balance]>

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
