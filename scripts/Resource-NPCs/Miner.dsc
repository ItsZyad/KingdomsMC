##
## * All code related to how loggers/woodcutters operate
## * in addition to their AOEs.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2021
## @Script Ver: v0.9
##
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

MinerSpecialization_Window:
    type: inventory
    inventory: chest
    gui: true
    title: "Select Miner Specialization"
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []


MinerSpecOres:
    type: item
    material: iron_ore
    display name: "Specialize in Ores"
    flags:
        specType: ores


MinerSpecStones:
    type: item
    material: stone
    display name: "Specialize in Stones"
    flags:
        specType: stones


MinerSpec_Handler:
    type: world
    events:

        # It is important that nothing tampers with the RNPCs server
        # flag between setting it and the player interaction with this
        # menu
        # 2023/06/10 Note - Yeah well too bad, I'm tampering with it.

        on player clicks MinerSpec* in MinerSpecialization_Window:
        - define latestRNPC <npc[<server.flag[RNPCs].last.get[1]>]>

        - flag <[latestRNPC]> spec:<context.item.flag[specType]>


MinerRangeFinder:
    type: task
    debug: false
    definitions: npc|radius|regenAOE
    script:

    # Have it check that the NPC is at least 10 blocks below ground
    # then have it carry out the checks relating to what block types
    # are around it.

    # Occasionally it should sprinkle in some ores/stones that aren't
    # in it's direct vicinity but that will be rare and will heavily
    # depend on NPC level and exp.

    - define regenAOE <[regenAOE].if_null[true]>
    - define npcLoc <[npc].location>
    - define locOne <[npcLoc].add[<[radius]>,<[radius].div[2].round>,<[radius]>]>
    - define locTwo <[npcLoc].sub[<[radius]>,<[radius].div[2].round>,<[radius]>]>
    - define areaOfEffect <cuboid[<[npc].location.world.name>,<[locOne].simple.split[,].remove[last].separated_by[,]>,<[locTwo].simple.split[,].remove[last].separated_by[,]>]>

    - if <[regenAOE]>:
        - flag <[npc]> blockbuildup:!

        - foreach <[areaOfEffect].blocks> as:block:
            - if <[block].material.name> == air:
                - foreach next

            - flag <[npc]> blockBuildup.<[block].material.name>:++
            - flag <[npc]> blockBuildup.totalBlocks:++

    - narrate format:debug <[areaOfEffect].blocks.size>
    - narrate format:debug <[npc].flag[blockBuildup]>

    - showfake red_stained_glass <[areaOfEffect].outline> if:<[areaOfEffect].exists>

    #                              1      2            3               4
    - note <[areaOfEffect]> as:INTERNAL_mine_<[npc].flag[kingdom]>_<[npc].id>
    - flag server kingdoms.<[npc].flag[kingdom]>.RNPCs.Miners.<[npc].id>.area:<cuboid[INTERNAL_mine_<[npc].flag[kingdom]>_<[npc].id>]>
    - flag server kingdoms.<[npc].flag[kingdom]>.RNPCs.Miners.<[npc].id>.NPC:<[npc]>
    - flag <[npc]> AOE:<[areaOfEffect]>

##ignorewarning raw_object_notation
##ignorewarning def_of_nothing

MineExperienceGain:
    type: data
    stone: 0.005
    granite: 0.015
    andesite: 0.013
    diorite: 0.01
    gold_ore: 0.20
    iron_ore: 0.03
    diamond_ore: 0.3
    coal_ore: 0.02
    redstone_ore: 0.07
    obsidian: 0.6
    emerald_ore: 0.7
    gravel: 0.004
    lapis_ore: 0.07
    clay_block: 0.01


TrueItemRef:
    type: data
    items:
        stone: cobblestone
        granite: granite
        andesite: andesite
        diorite: diorite
        gold_ore: gold_ingot
        iron_ore: iron_ingot
        diamond_ore: diamond
        coal_ore: coal
        redstone_ore: redstone
        obsidian: obsidian
        emerald_ore: emerald
        gravel: gravel
        lapis_ore: lapis_lazuli
        clay_block: clay


## NOTE: This is a stopgap. Rewrite all RNPCs code for A5!!
MinerItemGenerator:
    type: task
    script:
    - define kingdomList <proc[GetKingdomList]>
    - define allMiners <list[]>

    - foreach <[kingdomList]> as:kingdom:
        - if !<server.has_flag[kingdoms.<[kingdom]>.RNPCs.Miners]>:
            - foreach next

        - define minerData <server.flag[kingdoms.<[kingdom]>.RNPCs.Miners].parse_value_tag[<[parse_value].include[kingdom=<[kingdom]>]>]>
        - define allMiners <[allMiners].include[<[minerData].values>]>

    - foreach <[allMiners]>:
        - define npc <[value].get[NPC].as[npc]>
        - define kingdom <[value].get[kingdom]>
        - define npcChunk <[npc].location.chunk>

        - chunkload add <[npcChunk]>|<[npcChunk].add[1,0]>|<[npcChunk].add[0,1]>|<[npcChunk].sub[1,0]>|<[npcChunk].sub[0,1]> duration:10s
        - waituntil <[npcChunk].is_loaded>

        - if !<[kingdom].exists>:
            - foreach next

        - if <[npc].inventory.is_full>:
            - foreach next

        - if <proc[IsKingdomBankrupt].context[<[kingdom]>]>:
            - foreach next

        - define surroundingMiners <[npc].location.find_npcs_within[10].filter_tag[<[filter_value].flag[RNPC].equals[miners]>].if_null[<list[]>].exclude[<[npc]>]>
        - define overcrowdingPenalty <[surroundingMiners].size.sub[1].mul[25]>
        - define overcrowdingPenalty 0 if:<[overcrowdingPenalty].is[LESS].than[0]>
        - define overcrowdingPenalty 100 if:<[overcrowdingPenalty].is[MORE].than[100]>

        - if <[surroundingMiners].size.is[MORE].than[1]>:
            - adjust <[npc]> hologram_lines:<list[]>
            - adjust <[npc]> hologram_lines:<list[Overcrowding Penalty:<&sp><[overcrowdingPenalty]><&pc>]>
            - flag <[npc]> overcrowdingPen:<[overcrowdingPenalty]>

            - if <[overcrowdingPenalty]> == 100:
                - adjust <[npc]> hologram_lines:<list[Overcrowding Penalty:<red><[overcrowdingPenalty]><&pc>|This miner is disabled]>
                - foreach next

        # Note: future configurable
        # - flag <[npc]> nextGen:<util.time_now.add[35s]>
        - define minerBlocks <script[TrueItemRef].data_key[items].keys>
        - define volume <[mine].volume>
        - define generationProfile <[npc].flag[blockBuildup].exclude[totalBlocks].get_subset[<[minerBlocks]>]>
        - define npcLevel <[npc].flag[Level]>
        - define npcLevel 100 if:<[npcLevel].is[MORE].than[100]>

        - narrate format:debug GEN:<[generationProfile]>

        - foreach <[generationProfile]> key:block as:amount:
            - define spawnChance <util.random.int[<util.random.int[0].to[<[npcLevel].round>]>].to[100]>

            - if <[spawnChance].is[LESS].than[37]>:
                - foreach next

            - define trueItem <script[TrueItemRef].data_key[items.<[block]>]>
            - define outpostMod <[npc].flag[outpostMod].as[list].if_null[<list[0|0]>]>
            - define outputMod <[npc].flag[outputMod].if_null[0]>
            - define overcrowdingMultiplier <element[100].sub[<[overcrowdingPenalty]>]>
            - define itemAmount <element[1.01].sub[<script[MineExperienceGain].data_key[<[block]>]>].mul[<[spawnChance]>].div[8].mul[<[outpostMod].get[1].add[1]>].mul[<[outputMod].add[1]>].mul[<[overcrowdingMultiplier]>].round_down>

            - if !<[npc].inventory.can_fit[<[trueItem]>].quantity[<[itemAmount]>]>:
                - foreach next

            - give <[trueItem]> to:<[npc].inventory> quantity:<[itemAmount]>

            - flag <[npc]> Level:+:<script[MineExperienceGain].data_key[<[key]>].mul[<[itemAmount].div[350].round_to_precision[0.1]>]>

            # Find a random item not already in the generation
            # profile and weigh out the chance that it appears
            # in the Miner's inventory

            - define randomItemList <[minerBlocks].exclude[<[generationProfile].keys>]>
            - define randomItem <[randomItemList].get[<util.random.int[1].to[<[randomItemList].size>]>]>
            - define randomItemChance <script[MineExperienceGain].data_key[<[randomItem]>]>
            - define threshold <util.random.decimal[0].to[1]>
            - define randomItemList:!

            # If the lucky item appears than give the Miner only
            # one of it and add on the relevant experience

            - if <[threshold].is[LESS].than[<[randomItemChance]>]>:
                - foreach next

            - give <script[TrueItemRef].data_key[<[randomItem]>]> to:<[npc].inventory> quantity:<[outpostMod].get[2]>

            - define prevBaseLevel <[npc].flag[Level].round_down>

            - if <[npc].flag[Level].round_down> != <[prevBaseLevel]>:
                - define inventoryData <[npc].inventory.list_contents>
                - adjust <[npc]> name:<[npc].nickname.split[<&sp>].get[1].to[-2].space_separated><&sp><[npc].flag[Level].round_down>
                - adjust <[npc]> inventory_contents:<[inventoryData]>
                - flag <[npc]> outputMod:+:<util.random.decimal[0].to[0.005]>


MinerGeneration:
    type: task
    debug: false
    enabled: false
    script:
    # Loop through all the noted regions that start with 'mine'
    # and run the generation code relating to their NPCs.

    # Note: be sure to add some code which flags all miners RNPCs
    #       with the block build-up of their area as they're created

    - foreach <util.notes[cuboids].filter_tag[<[filter_value].starts_with[cu@INTERNAL_mine]>]>:

        # Don't forget to add netherrack and quartz for nether update #

        - define minerBlocks <list[stone|granite|andesite|diorite|gold_ore|iron_ore|diamond_ore|coal_ore|redstone_ore|obsidian|emerald_ore|gravel|lapis_ore|clay_block]>

        - define npcID <[value].split[_].get[4]>
        - define npc <npc[<[npcID]>]>


        # If the NPC's kingdom is not currently in a state of bankruptcy (4+
        # days in debt)

        - if !<proc[IsKingdomBankrupt].context[<[npc].flag[kingdom]>]>:
            - define npcLevel <[npc].flag[Level]>
            #- define npcIteration <element[100].sub[<[npcLevel]>].round_up_to_precision[10].div[10]>
            - define npcIteration 1
            - define kingdom <[value].split[_].get[3]>
            - define volume <[value].volume>
            - define generationProfile <[npc].flag[blockBuildup].get_subset[<[minerBlocks]>]>

            #- narrate format:debug <[kingdom]>
            #- narrate format:debug <[volume]>
            #- narrate format:debug <[generationProfile]>
            #- narrate target:<server.online_players> format:debug PROF:<[generationProfile]>
            #- narrate targets:<server.online_players> format:debug ITER:<[npcIteration]>,<server.flag[iterations]>

            - if <server.flag[iterations].mod[<[npcIteration]>]> == 0:
                - foreach <[generationProfile].to_pair_lists>:
                    - define key <[value].get[1]>
                    - define val <[value].get[2]>
                    - define trueItem <script[TrueItemRef].data_key[<[key]>]>
                    - define spawnChance <util.random.int[<util.random.int[0].to[<[npcLevel].round>]>].to[100]>

                    #- narrate format:debug targets:<server.online_players> CHNC:<[spawnChance]>

                    - if <[spawnChance].is[OR_MORE].than[37]>:
                        - define dropAmount <util.random.int[0].to[<util.random.int[<[val]>].to[99]>]>
                        - define outpostMod <[npc].flag[outpostMod]>
                        - define outputMod <[npc].flag[outputMod]>
                        - define itemModifier <element[1.01].sub[<script[MineExperienceGain].data_key[<[key]>]>].mul[<[spawnChance]>].div[8].mul[<[outpostMod].get[1]>].mul[<[outputMod].add[1]>].round_down>

                        - if <[npc].inventory.can_fit[<[trueItem]>].quantity[<[itemModifier]>]>:
                            - give <[trueItem]> to:<[npc].inventory> quantity:<[itemModifier]>

                            - flag <[npc]> Level:+:<script[MineExperienceGain].data_key[<[key]>].mul[<[itemModifier].div[350].round_to_precision[0.1]>]>

                            # Find a random item not already in the generation
                            # profile and weigh out the chance that it appears
                            # in the Miner's inventory

                            - define randomItemList <[minerBlocks].exclude[<[generationProfile].keys>]>
                            - define randomItem <[randomItemList].get[<util.random.int[1].to[<[randomItemList].size>]>]>
                            - define randomItemChance <script[MineExperienceGain].data_key[<[randomItem]>]>
                            - define threshold <util.random.decimal[0].to[1]>

                            # If the lucky item appears than give the Miner only
                            # one of it and add on the relevant experience

                            - if <[threshold].is[OR_MORE].than[<[randomItemChance]>]>:

                                # Modify the possibility of getting extra items
                                # by the second value in the outpostMod list
                                # stored in flag system

                                - give <script[TrueItemRef].data_key[<[randomItem]>]> to:<[npc].inventory> quantity:<[outpostMod].get[2]>

                                - define prevBaseLevel <[npc].flag[Level].round_down>
                                - flag <[npc]> Level:+:<util.random.decimal[0.01].to[0.02]>

                                - if <[npc].flag[Level].round_down> != <[prevBaseLevel]>:
                                    - define inventoryData <[npc].inventory.list_contents>
                                    - adjust <[npc]> name:<[npc].nickname.split[<&sp>].get[1].to[-2].space_separated><&sp><[npc].flag[Level].round_down>
                                    - adjust <[npc]> inventory_contents:<[inventoryData]>

                                    - flag <[npc]> outputMod:+:<util.random.decimal[0].to[0.005]>

                        #- narrate format:debug MOD:<[itemModifier]>

    - flag server iterations:++

    - if <server.flag[iterations]> == 10:
        - flag server iterations:0


MinerGenerationNoticeUpdater:
    type: task
    debug: false
    script:
    - repeat 35:
        - define timeStart <util.current_time_millis>

        - foreach <util.notes[cuboids].filter_tag[<[filter_value].starts_with[cu@INTERNAL_mine]>]>:
            - define npc <npc[<[value].split[_].get[4]>]>
            - define nextGen <[npc].flag[nextGen]>

            - adjust <[npc]> hologram_lines:<[npc].hologram_lines.include[<element[Generating in: <[nextGen].from_now>]>]>

        - wait <element[1000].sub[<util.current_time_millis.sub[<[timeStart]>]>].div[1000].mul[20].round>t


MinerGeneration_Handler:
    type: world
    debug: false
    enabled: false
    events:
        on system time secondly every:150:
        - run MinerItemGenerator

        #on player places block in:mine*:
        #- determine cancelled