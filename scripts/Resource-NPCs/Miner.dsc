##
## All the scripts in the file relate to the operation of the Miner NPC that can be spawned by
## kingdoms to extract resources.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jun 2021
## @Updated: Jun 2024
## @Script Ver: v2.0
##
## ------------------------------------------END HEADER-------------------------------------------

MinerRangeFinder:
    type: task
    debug: false
    definitions: npc[NPCTag]
    script:
    - flag server kingdoms.<[npc].flag[kingdom]>.RNPCs.Miners.<[npc].id>.NPC:<[npc]>
    - flag server kingdoms.<[npc].flag[kingdom]>.RNPCs.Miners.<[npc].id>.refreshTime:<[npc].location.world.time>

##ignorewarning raw_object_notation

MineExperienceGain:
    type: data
    XP:
        clay_block: 0.02
        clay: 0.02
        gravel: 0.03
        granite: 0.03
        andesite: 0.04
        diorite: 0.04
        stone: 0.05
        cobblestone: 0.05
        coal_ore: 0.06
        coal: 0.06
        lapis_ore: 0.08
        lapis_lazuli: 0.08
        redstone_ore: 0.09
        redstone: 0.09
        iron_ore: 0.1
        iron_ingot: 0.1
        gold_ore: 0.25
        gold_ingot: 0.25
        diamond_ore: 0.35
        diamond: 0.35
        emerald_ore: 0.37
        emerald: 0.37
        obsidian: 0.5


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


ResourceSeed_Data:
    type: data
    BaseSeed: 0
    ResourceSeedShifts:
        cobblestone: 0
        clay: 3
        diorite: 5
        andesite: 6
        granite: 7
        gravel: 10
        coal: 25
        lapis_lazuli: 50
        redstone: 70
        iron_ingot: 80
        gold_ingot: 150
        diamond: 250
        emerald: 300
        obsidian: 700


GetResourceValueAtChunk:
    type: procedure
    definitions: chunk[`ChunkTag`]|resource[`ElementTag(String)`]|octaveScale[`?ElementTag(Float) = 1.23`]|octaveAmp[`?ElementTag(Float) = 1.8`]
    description:
    - Will get a value between 0 and 20 indicating the prevalance of the given resource at the provided chunk.
    - ---
    - → `[ElementTag(Float)]`

    script:
    ## Will get a value between 0 and 20 indicating the prevalance of the given resource at the
    ## provided chunk.
    ##
    ## chunk       :  [ChunkTag]
    ## resource    :  [ElementTag<String>]
    ## octaveScale : ?[ElementTag<Float>]
    ## octaveAmp   : ?[ElementTag<Float>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<script[ResourceSeed_Data].data_key[ResourceSeedShifts].contains[<[resource]>]>:
        - determine 0

    - define octaveScale <[octaveScale].if_null[1.23]>
    - define octaveAmp <[octaveAmp].if_null[1.8]>

    - define baseSeed <script[ResourceSeed_Data].data_key[BaseSeed]>
    - define resourceSeedShift <script[ResourceSeed_Data].data_key[ResourceSeedShifts.<[resource]>]>
    - define seed <[baseSeed].add[<[resourceSeedShift]>]>

    - define location <location[<[chunk].x>,0,<[chunk].z>,0,0,<[chunk].world.name>]>
    - define xComp <[location].x>
    - define zComp <[location].z>

    - define oct1 <[location].with_y[<[seed]>].with_x[<[xComp].mul[1]>].with_z[<[zComp].mul[1]>].div[5].div[16].simplex_3d.add[1].div[2].mul[20].add[1]>
    - define oct2 <[location].with_y[<[seed]>].with_x[<[xComp].mul[2]>].with_z[<[zComp].mul[2]>].div[5].div[16].simplex_3d.add[1].div[2].mul[20].add[1].mul[0.5]>
    - define oct3 <[location].with_y[<[seed]>].with_x[<[xComp].mul[4]>].with_z[<[zComp].mul[4]>].div[5].div[16].simplex_3d.add[1].div[2].mul[20].add[1].mul[0.25]>

    - define octSum <[oct1].add[<[oct2]>].add[<[oct3]>]>
    - define ampedOcts <[octSum].div[<[octaveAmp]>].sub[5]>
    - define scaledOcts <[ampedOcts].power[<[octaveScale]>]>

    - if !<[scaledOcts].is_truthy> || <[scaledOcts]> == NaN || <[scaledOcts]> < 0:
        - define scaledOcts 0

    - else if <[scaledOcts]> > 20:
        - define scaledOcts 20

    - determine <[scaledOcts].round_to_precision[0.0001]>


MinerItemGenerator:
    type: task
    definitions: npc[NPCTag]
    script:
    - define kingdom <[npc].flag[kingdom]>
    - define chunk <[npc].location.chunk>

    - if !<[kingdom].exists>:
        - foreach next

    - if <[npc].inventory.is_full>:
        - foreach next

    - if <proc[IsKingdomBankrupt].context[<[kingdom]>]>:
        - foreach next

    - define surroundingMiners <[npc].location.find_npcs_within[9].filter_tag[<[filter_value].flag[RNPC].equals[miners]>].if_null[<list[]>].exclude[<[npc]>]>
    - define overcrowdingPenalty <[surroundingMiners].size.sub[1].mul[25]>
    - define overcrowdingPenalty 0 if:<[overcrowdingPenalty].is[LESS].than[0]>
    - define overcrowdingPenalty 100 if:<[overcrowdingPenalty].is[MORE].than[100]>

    - if <[surroundingMiners].size.is[MORE].than[1]>:
        - adjust <[npc]> hologram_lines:<list[]>
        - adjust <[npc]> hologram_lines:<list[Overcrowding Penalty:<&sp><[overcrowdingPenalty]><&pc>]>
        - flag <[npc]> overcrowdingPen:<[overcrowdingPenalty]>

        - if <[overcrowdingPenalty]> == 100:
            - adjust <[npc]> hologram_lines:<list[Overcrowding Penalty:<&sp><red><[overcrowdingPenalty]><&pc>|This miner is disabled]>
            - foreach next

    - else:
        - adjust <[npc]> hologram_lines:<list[]>
        - flag <[npc]> overcrowdingPen:0

    - if <[npc].has_flag[RNPC.cache.resourceMap]> && <[npc].flag[RNPC.cache.chunk]> == <[npc].location.chunk>:
        - define resourceMap <[npc].flag[RNPC.cache.resourceMap]>

    - else:
        - inject <script.name> path:Subpaths.CalculateAllResourceValues
        - flag <[npc]> RNPC.cache.resourceMap:<[resourceMap]>
        - flag <[npc]> RNPC.cache.chunk:<[npc].location.chunk>

    # This is the *total* number of resources that a miner can generate per tick. (which at the
    # moment is one in-game day).
    - define resourcesPerTick 32
    - define resourcesPerTick <[resourcesPerTick].sub[<[npc].flag[RNPC.cache.carryOver].size>]> if:<[npc].has_flag[RNPC.cache.carryOver]>
    - define totalResources <[resourceMap].values.sum.round_to_precision[0.001]>
    - define proportionMap <[resourceMap].parse_value_tag[<[parse_value].div[<[totalResources]>].mul[<[resourcesPerTick]>].round>]>
    - define carryOver <[npc].flag[RNPC.cache.carryOver].if_null[<map[]>]>

    - foreach <[proportionMap].include[<[carryOver]>]> key:item as:amount:
        - if !<[npc].inventory.can_fit[<[item]>].quantity[<[amount]>]>:
            - foreach next

        - if <[carryOver].size> < <[resourcesPerTick].div[10].round> && <util.random_chance[35]>:
            - flag <[npc]> RNPC.cache.carryOver.<[item]>:++
            - define amount:--

        - give <[item]> to:<[npc].inventory> quantity:<[amount]>

        - if <[npc].flag[Level].round> >= 100:
            - foreach next

        - define prevBaseLevel <[npc].flag[Level].round_down>

        - flag <[npc]> Level:+:<script[MineExperienceGain].data_key[XP.<[item]>].mul[<[amount].div[350].round_to_precision[0.01]>]>

        - if <[npc].flag[Level].round_down> == <[prevBaseLevel]>:
            - foreach next

        - define inventoryData <[npc].inventory.list_contents>
        - adjust <[npc]> name:<[npc].nickname.split[<&sp>].get[1].to[-2].space_separated><&sp><[npc].flag[Level].round_down>
        - adjust <[npc]> inventory_contents:<[inventoryData]>

        - if <[npc].flag[outputMod]> >= 2:
            - foreach next

        - flag <[npc]> outputMod:+:<util.random.decimal[0].to[0.005]>

    Subpaths:
        CalculateAllResourceValues:
        - define resourceMap <map[]>
        - definemap specialMaterialCharacteristics:
            diamond:
                octaveAmp: 1.7
                octaveScale: 1.11
            obsidian:
                octaveAmp: 2.3
                octaveScale: 1.09
            andesite:
                octaveAmp: 0.97
                octaveScale: 1.05
            diorite:
                octaveAmp: 0.97
                octaveScale: 1.05
            gravel:
                octaveAmp: 1.97
                octaveScale: 1.35
            stone:
                octaveAmp: 0.89
                octaveScale: 1

        - foreach <script[ResourceSeed_Data].data_key[ResourceSeedShifts].keys> as:material:
            - if <[specialMaterialCharacteristics].contains[<[material]>]>:
                - define octaveScale <[specialMaterialCharacteristics].deep_get[<[material]>.octaveScale]>
                - define octaveAmp <[specialMaterialCharacteristics].deep_get[<[material]>.octaveAmp]>
                - define resourceMap.<[material]>:<proc[GetResourceValueAtChunk].context[<[chunk]>|<[material]>|<[octaveScale]>|<[octaveAmp]>]>

            - else:
                - define resourceMap.<[material]>:<proc[GetResourceValueAtChunk].context[<[chunk]>|<[material]>]>


MinerGeneration_Handler:
    type: world
    debug: false
    events:
        on time changes in world:
        - foreach <proc[GetKingdomList]> as:kingdom:
            - foreach <server.flag[kingdoms.<[kingdom]>.RNPCs.miners].if_null[<list[]>]> as:miner:
                - define miner <[miner].get[NPC].as[npc]>

                - if <[miner].location.world> != <context.world>:
                    - foreach next

                - if <[miner].get[refreshTime].div[1000].round.if_null[0]> != <context.world.time.full.in_minutes.mod[20].round>:
                    - foreach next

                - run MinerItemGenerator def.npc:<[miner]>


## EVERYTHING BELOW IS OLD CODE AND SHOULD NOT BE USED IN PROD. ANYMORE!! ##
OLD_MinerItemGenerator:
    type: task
    enabled: false
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
        - define mine <[value].get[area]>

        - chunkload add <[npcChunk]>|<[npcChunk].add[1,0]>|<[npcChunk].add[0,1]>|<[npcChunk].sub[1,0]>|<[npcChunk].sub[0,1]> duration:10s
        - waituntil <[npcChunk].is_loaded>

        - if !<[kingdom].exists>:
            - foreach next

        - if <[npc].inventory.is_full>:
            - foreach next

        - if <proc[IsKingdomBankrupt].context[<[kingdom]>]>:
            - foreach next

        - define surroundingMiners <[npc].location.find_npcs_within[9].filter_tag[<[filter_value].flag[RNPC].equals[miners]>].if_null[<list[]>].exclude[<[npc]>]>
        - define overcrowdingPenalty <[surroundingMiners].size.sub[1].mul[25]>
        - define overcrowdingPenalty 0 if:<[overcrowdingPenalty].is[LESS].than[0]>
        - define overcrowdingPenalty 100 if:<[overcrowdingPenalty].is[MORE].than[100]>

        - if <[surroundingMiners].size.is[MORE].than[1]>:
            - adjust <[npc]> hologram_lines:<list[]>
            - adjust <[npc]> hologram_lines:<list[Overcrowding Penalty:<&sp><[overcrowdingPenalty]><&pc>]>
            - flag <[npc]> overcrowdingPen:<[overcrowdingPenalty]>

            - if <[overcrowdingPenalty]> == 100:
                - adjust <[npc]> hologram_lines:<list[Overcrowding Penalty:<&sp><red><[overcrowdingPenalty]><&pc>|This miner is disabled]>
                - foreach next

        - else:
            - adjust <[npc]> hologram_lines:<list[]>
            - flag <[npc]> overcrowdingPen:0

        # Note: future configurable
        # - flag <[npc]> nextGen:<util.time_now.add[35s]>
        - define minerBlocks <script[TrueItemRef].data_key[items].keys>
        - define volume <[mine].volume>
        - define generationProfile <[npc].flag[blockBuildup].exclude[totalBlocks].get_subset[<[minerBlocks]>]>
        - define totalAmount <[generationProfile].values.sum>
        - define npcLevel <[npc].flag[Level]>
        - define npcLevel 100 if:<[npcLevel].is[MORE].than[100]>

        - run flagvisualizer def.flag:<[generationProfile].include[total=<[totalAmount]>]> def.flagName:genProf

        - foreach <[generationProfile]> key:block as:amount:
            - define spawnChance <util.random.int[<util.random.int[0].to[<[npcLevel].round>]>].to[100]>

            - if <[spawnChance].is[LESS].than[37]>:
                - foreach next

            - define trueItem <script[TrueItemRef].data_key[items.<[block]>]>
            - define outpostMod <[npc].flag[outpostMod].as[list].if_null[<list[0|0]>]>
            - define outputMod <[npc].flag[outputMod].if_null[0]>
            - define outputMod 2 if:<[npc].flag[outputMod].is[OR_MORE].than[2]>
            - define overcrowdingMultiplier <element[100].sub[<[overcrowdingPenalty]>].div[100]>
            - define baseEXP <element[1.01].sub[<script[MineExperienceGain].data_key[XP.<[block]>]>]>
            - define maximumGeneratableItems <[volume].div[20.8125].round.mul[<[outputMod]>].add[<util.random.int[-10].to[20]>].round>

            - if <[amount]> >= <[totalAmount].div[2]>:

                # Item proportion scalar equation:
                # s = (t / 10) * log2(a - (t / 2)) - (t / 2)
                # Where: t = totalAmount
                #        a = amount
                # https://www.desmos.com/calculator/qi3c4cfcsb
                - define amount <[totalAmount].div[10].mul[<element[<[amount].sub[<[totalAmount].div[2]>]>].log[2]>].sub[<[totalAmount].div[2]>]>

            - define itemProportion <[amount].div[<[totalAmount]>]>
            - define itemAmount <[maximumGeneratableItems].mul[<[itemProportion]>].round_up>

            # - narrate format:debug <red>ITM:<[trueItem]>
            # - narrate format:debug <gold>AMT:<[amount]>
            # - narrate format:debug MAX:<[maximumGeneratableItems].round_to_precision[0.001]>
            # - narrate format:debug PRP:<[itemProportion]>
            # - narrate format:debug APR:<[itemProportion].mul[<element[<[itemProportion].power[1.90279728]>].div[2]>]>
            # - narrate format:debug VOL:<[volume]>
            # - narrate format:debug <bold>ITA:<[itemAmount]>
            # - narrate format:debug -----------------------------

            - if !<[npc].inventory.can_fit[<[trueItem]>].quantity[<[itemAmount]>]>:
                - foreach next

            - give <[trueItem]> to:<[npc].inventory> quantity:<[itemAmount]>

            - flag <[npc]> Level:+:<script[MineExperienceGain].data_key[<[block]>].mul[<[itemAmount].div[500].round_to_precision[0.1]>]>

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

            - if <[npc].flag[Level].round> >= 100:
                - foreach next

            - define prevBaseLevel <[npc].flag[Level].round_down>
            - flag <[npc]> Level:+:<util.random.decimal[0.01].to[0.02]>

            - if <[npc].flag[Level].round_down> == <[prevBaseLevel]>:
                - foreach next

            - define inventoryData <[npc].inventory.list_contents>
            - adjust <[npc]> name:<[npc].nickname.split[<&sp>].get[1].to[-2].space_separated><&sp><[npc].flag[Level].round_down>
            - adjust <[npc]> inventory_contents:<[inventoryData]>

            - if <[npc].flag[outputMod]> >= 2:
                - foreach next

            - flag <[npc]> outputMod:+:<util.random.decimal[0].to[0.005]>


MinerGenerationNoticeUpdater:
    type: task
    debug: false
    enabled: false
    script:
    - repeat 35:
        - define timeStart <util.current_time_millis>

        - foreach <util.notes[cuboids].filter_tag[<[filter_value].starts_with[cu@INTERNAL_mine]>]>:
            - define npc <npc[<[value].split[_].get[4]>]>
            - define nextGen <[npc].flag[nextGen]>

            - adjust <[npc]> hologram_lines:<[npc].hologram_lines.include[<element[Generating in: <[nextGen].from_now>]>]>

        - wait <element[1000].sub[<util.current_time_millis.sub[<[timeStart]>]>].div[1000].mul[20].round>t


OLD_MinerGeneration_Handler:
    type: world
    debug: false
    enabled: false
    events:
        on system time secondly every:150:
        - run OLD_MinerItemGenerator

        on player places block in:mine*:
        - determine cancelled