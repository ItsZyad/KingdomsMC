##
## [SCENARIO I]
## Just some random data files that were too big or didn't fit anywhere else.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jul 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

TradableItems_Data:
    type: data
    ConfigData:
        # This figure is in Minecraft days.
        tradeRefresh: 5

        priceMultipliers:
            # The min and max here refer to the range in which the price multiplier will generate.
            # The prices won't actually be contained in this file, but instead will be drawn from
            # the economy_data/worth.yml file.
            Fyndalin:
                min: 1
                max: 1.35

    TradableItems:
        # The keys are items and the values are a ballpark for how many of it will be available on
        # each trade refresh.
        Fyndalin:
            BuildingBlocks:
                categoryName: Building Blocks
                icon: stone_bricks
                items:
                    stone: 700
                    granite: 650
                    diorite: 750
                    andesite: 650
                    deepslate: 650
                    cobbled_deepslate: 325
                    calcite: 50
                    tuff: 250
                    dripstone_block: 100
                    cobblestone: 1000
                    oak_planks: 1000
                    spruce_planks: 1000
                    birch_planks: 1000
                    jungle_planks: 100
                    acacia_planks: 150
                    dark_oak_planks: 250
                    mangrove_planks: 100
                    glass: 700
                    sand: 500
                    red_sand: 50
                    gravel: 500
                    oak_log: 400
                    spruce_log: 400
                    birch_log: 400
                    jungle_log: 100
                    acacia_log: 125
                    dark_oak_log: 400
                    mangrove_log: 75
                    mangrove_roots: 75
                    muddy_mangrove_roots: 50
                    bricks: 650
                    basalt: 100

            Organics:
                categoryName: Organics
                icon: oak_sapling
                items:
                    oak_sapling: 100
                    spruce_sapling: 100
                    birch_sapling: 100
                    jungle_sapling: 100
                    acacia_sapling: 100
                    dark_oak_sapling: 100
                    mangrove_propagule: 25
                    honeycomb: 50
                    feather: 300
                    string: 500
                    bone: 100
                    ink_sac: 200
                    spider_eye: 50

            Resources:
                categoryName: Natural Resources & Ores
                icon: coal
                items:
                    coal: 500
                    raw_iron: 300
                    raw_gold: 200
                    raw_copper: 500
                    lapis_lazuli: 75
                    redstone: 250
                    diamond: 50
                    emerald: 25
                    clay: 500
                    flint: 75
                    amethyst_shard: 25

            Food:
                categoryName: Foodstuffs
                icon: bread
                items:
                    sugar_cane: 500
                    sugar: 200
                    bamboo: 50
                    pumpkin: 50
                    carved_pumpkin: 25
                    melon: 50
                    melon_slice: 300
                    egg: 500
                    kelp: 1000
                    wheat: 400
                    bread: 200
                    carrot: 150
                    potato: 150
                    beetroot: 200
                    sweet_berries: 50
                    beef: 100
                    chicken: 100
                    rabbit: 100
                    cod: 150
                    salmon: 150
                    brown_mushroom: 300
                    red_mushroom: 200