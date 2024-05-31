##
## This file does not have a formal header since it is testing a future feature (or a component of
## one). Once this feature begins development in earnest, this code will be cleaned and the file
## will be given a header.
##

HeatMapColorCodes:
    type: data
    ColorCodes:
        0: black_wool
        1: obsidian
        2: dark_oak_planks
        3: black_terracotta
        4: gray_terracotta
        5: brown_terracotta
        6: red_terracotta
        7: orange_terracotta
        8: smooth_red_sandstone
        9: yellow_terracotta
        10: lime_terracotta
        11: green_wool
        12: moss_block
        13: weathered_copper
        14: cyan_terracotta
        15: blue_terracotta
        16: purple_terracotta
        17: magenta_terracotta
        18: light_gray_terracotta
        19: white_terracotta
        20: white_wool

    MonoColorCodes:
        0: black_concrete
        1: bedrock
        2: obsidian
        3: dark_oak_wood
        4: polished_blackstone
        5: mud
        6: gray_concrete
        7: deepslate_bricks
        8: basalt
        9: deepslate
        10: tuff
        11: dead_horn_coral_block
        12: light_gray_concrete
        13: light_gray_wool
        14: andesite
        15: chiseled_stone_bricks
        16: stone
        17: smooth_stone
        18: white_concrete
        19: quartz_block
        20: white_wool


CopyNoiseTest:
    type: task
    debug: false
    definitions: location|spacing|size
    script:
    - define spacing 3 if:<[spacing].exists.not>
    - define size 10 if:<[size].exists.not>

    - define replacements <script[HeatMapColorCodes].data_key[MonoColorCodes]>
    - define replacementLen <[replacements].size>

    - repeat <[size]> from:0 as:row:
        - repeat <[size]> from:0 as:col:
            - define currLocation <[location].add[<[row].mul[<[spacing]>]>,0,<[col].mul[<[spacing]>]>]>
            - define index <[currLocation].with_y[62].div[16].simplex_3d.add[1].div[2].mul[<[replacementLen]>].add[1].round_down>
            - define index 20 if:<[index].is[MORE].than[20]>
            - define material <material[<[replacements].get[<[index]>]>]>

            - showfake <[currLocation].add[0,<[index]>,0]> <[material]>
            # |<[currLocation].add[1,<[index]>,0]>|<[currLocation].add[0,<[index]>,1]>|<[currLocation].add[1,<[index]>,1]>


CancelAllShowfakes:
    type: task
    script:
    - showfake <player.fake_block_locations> cancel


OctaveNoiseTest:
    type: task
    definitions: location|spacing|size|seed
    debug: false
    script:
    - define noiseMap <map[]>
    - define coordList <list[]>

    - if !<[size].exists> || <[size].split[x].size> != 2 || !<[size].split[x].unseparated.is_integer>:
        - define sizeX 15
        - define sizeZ 15

    - else:
        - define sizeX <[size].split[x].get[1]>
        - define sizeZ <[size].split[x].get[2]>

    - define spacing 5 if:<[spacing].exists.not>
    - define seed 60 if:<[seed].exists.not>

    - repeat <[sizeX]> as:row:
        - repeat <[sizeZ]> as:col:
            - define xComp <[location].x.add[<[row].mul[<[spacing]>]>]>
            - define zComp <[location].z.add[<[col].mul[<[spacing]>]>]>

            - define oct1 <[location].with_y[<[seed]>].with_x[<[xComp].mul[1]>].with_z[<[zComp].mul[1]>].div[5].div[16].simplex_3d.add[1].div[2].mul[20].add[1]>
            - define oct2 <[location].with_y[<[seed]>].with_x[<[xComp].mul[2]>].with_z[<[zComp].mul[2]>].div[5].div[16].simplex_3d.add[1].div[2].mul[20].add[1].mul[0.5]>
            - define oct3 <[location].with_y[<[seed]>].with_x[<[xComp].mul[4]>].with_z[<[zComp].mul[4]>].div[5].div[16].simplex_3d.add[1].div[2].mul[20].add[1].mul[0.25]>

            - define octSum <[oct1].add[<[oct2]>].add[<[oct3]>]>
            - define ampedOcts <[octSum].div[1.8].sub[5]>
            - define scaledOcts <[ampedOcts].power[1.23]>

            - if !<[scaledOcts].is_truthy> || <[scaledOcts]> == NaN || <[scaledOcts]> < 0:
                - define scaledOcts 0

            - else if <[scaledOcts]> > 20:
                - define scaledOcts 20

            - define noiseMap.<[row]>:->:<[scaledOcts].round_to_precision[0.0001]>

            - define loc <[location].add[<[row].mul[<[spacing]>]>,0,<[col].mul[<[spacing]>]>]>
            - define coordList:->:<[loc]>

            - showfake <script[HeatMapColorCodes].data_key[MonoColorCodes.<[scaledOcts].round>]> <[loc].add[0,<[scaledOcts].round>,0]> d:30s

    - narrate format:debug OVERALL_AVG:<[noiseMap].parse_value_tag[<[parse_value].average>].values.average>
    - narrate format:debug OVERALL_MAX:<[noiseMap].parse_value_tag[<[parse_value].highest>].values.highest>
    - narrate format:debug OVERALL_MIN:<[noiseMap].parse_value_tag[<[parse_value].lowest>].values.lowest>


SimpleNoiseTest:
    type: task
    enabled: false
    definitions: location|spacing|size|seed
    debug: false
    script:

    ## WORKS WELL IN ISOlATION.
    ## MAIN ISSUE: DOES NOT GENERATE FLOWING PATTERNS OVER MULTIPLE CALLS.
    ##             WHEN THIS GOES INTO PRODUCTION, HEAT MAP GENERATION WILL BE DONE IN PASSES. IT
    ##             MUST BE ABLE TO GENERATE LOGICALLY CONTIGIOUS "TERRAIN" REAGRDLESS OF HOW MANY
    ##             FUNCTION CALLS ARE MADE.

    - define noiseMap <map[]>
    - define coordList <list[]>

    - define spacing 5 if:<[spacing].exists.not>
    - define size 15 if:<[size].exists.not>
    - define seed 60 if:<[seed].exists.not>

    - define replacements <script[HeatMapColorCodes].data_key[MonoColorCodes]>
    - define replacementLen <[replacements].size>

    - repeat <[size]> from:0 as:row:
        - repeat <[size]> from:0 as:col:
            - define xComp <[row].mul[<[spacing]>]>
            - define zComp <[col].mul[<[spacing]>]>
            - define oct1 <[location].add[<[xComp]>,0,<[zComp]>].with_y[<[seed]>].div[3].div[16].simplex_3d.add[1].div[2].mul[<[replacementLen]>].add[1]>

            # - if <[row]> == 1 && <[col]> == 1:
            #     - narrate format:debug XCM:<[xComp].round_to_precision[0.01]>
            #     - narrate format:debug ZCM:<[zComp].round_to_precision[0.01]>
            #     - narrate format:debug <red>----

            - define ampedOcts <[oct1].div[1.65].sub[4.5]>
            # - define scaledOcts <[ampedOcts].power[1.1]>
            - define scaledOcts <[oct1]>

            - if !<[scaledOcts].is_truthy> || <[scaledOcts]> == NaN || <[scaledOcts]> < 0:
                - define scaledOcts 0

            - else if <[scaledOcts]> > 20:
                - define scaledOcts 20

            - define noiseMap.<[row]>:->:<[scaledOcts].round_to_precision[0.0001]>

            - define loc <[location].add[<[row].mul[<[spacing]>]>,0,<[col].mul[<[spacing]>]>]>
            - define coordList:->:<[loc]>

            - showfake <script[HeatMapColorCodes].data_key[MonoColorCodes.<[scaledOcts].round>]> <[loc].add[0,<[scaledOcts].round>,0]> d:30s

    # - narrate format:debug XCM:<[xComp].round_to_precision[0.01]>
    # - narrate format:debug ZCM:<[zComp].round_to_precision[0.01]>
    # - narrate format:debug <black>----

    - narrate format:debug OVERALL_AVG:<[noiseMap].parse_value_tag[<[parse_value].average>].values.average>
    - narrate format:debug OVERALL_MAX:<[noiseMap].parse_value_tag[<[parse_value].highest>].values.highest>
    - narrate format:debug OVERALL_MIN:<[noiseMap].parse_value_tag[<[parse_value].lowest>].values.lowest>
