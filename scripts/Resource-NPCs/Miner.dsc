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

        on player clicks MinerSpec* in MinerSpecialization_Window:
        - define latestRNPC <npc[<server.flag[RNPCs].last.get[1]>]>

        - flag <[latestRNPC]> spec:<context.item.flag[specType]>

MinerRangeFinder:
    type: task
    definitions: npc|radius
    script:

    # Have it check that the NPC is at least 10 blocks below ground
    # then have it carry out the checks relating to what block types
    # are around it.

    # Occasionally it should sprinkle in some ores/stones that aren't
    # in it's direct vicinity but that will be rare and will heavily
    # depend on NPC level and exp.

    - define npcLoc <[npc].location>
    - define locOne <[npcLoc].right[<[radius]>].forward[<[radius]>]>
    - define locTwo <[npcLoc].left[<[radius]>].backward[<[radius]>]>
    - define areaOfEffect <cuboid[<[npc].location.world.name>,<[locOne].x>,<[npcLoc].y.add[<[radius].mul[2]>]>,<[locOne].z>,<[locTwo].x>,<[npcLoc].y.sub[<[radius]>]>,<[locTwo].z>]>

    - foreach <[areaOfEffect].blocks> as:block:
       - flag <[npc]> blockBuildup.<[block].material.name>:++
       - flag <[npc]> blockBuildup.totalBlocks:++

    - narrate format:debug <[areaOfEffect]>
    - narrate format:debug <[npc].flag[blockBuildup]>

    #                              1      2            3               4
    - note <[areaOfEffect]> as:INTERNAL_mine_<[npc].flag[kingdom]>_<[npc].id>

##ignorewarning raw_object_notation
##ignorewarning def_of_nothing

MineExperienceGain:
    type: data
    stone: 0.01
    granite: 0.03
    andesite: 0.03
    diorite: 0.03
    gold_ore: 0.25
    iron_ore: 0.05
    diamond_ore: 0.45
    coal_ore: 0.02
    redstone_ore: 0.1
    obsidian: 0.99
    emerald_ore: 0.9
    gravel: 0.01
    lapis_ore: 0.07
    clay_block: 0.02

TrueItemRef:
    type: data
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

MinerGeneration:
    type: task
    debug: false
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

        - if !<proc[IsKingdomBankrupt].context[<server.flag[kingdoms.<[npc].flag[kingdom]>.balance]>|<[npc].flag[kingdom]>]>:
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

MinerGeneration_Handler:
    type: world
    debug: false
    events:
        on system time secondly every:35:
        - inject MinerGeneration

        #on player places block in:mine*:
        #- determine cancelled