ItemOrderWeightings:
    type: data
    stone_sword: 0.85
    stone_axe: 0.8
    iron_sword: 0.6
    iron_axe: 0.55
    diamond_sword: 0.3
    diamond_axe: 0.25
    netherite_sword: 0.05
    netherite_axe: 0.075
    bow: 0.8
    crossbow: 0.5
    arrow: 0.95
    iron_helmet: 0.57
    iron_chestplate: 0.5
    iron_leggings: 0.55
    iron_boots: 0.6
    golden_helmet: 0.47
    golden_chestplate: 0.4
    golden_leggings: 0.45
    golden_boots: 0.5
    diamond_helmet: 0.38
    diamond_chestplate: 0.29
    diamond_leggings: 0.33
    diamond_boots: 0.35
    netherite_helmet: 0.07
    netherite_chestplate: 0.02
    netherite_leggings: 0.04
    netherite_boots: 0.08
    bricks: 0.34
    oak_planks: 0.85
    spruce_planks: 0.8
    oak_log: 0.65
    spruce_log: 0.5
    glass: 0.56
    glass_pane: 0.44
    oak_stairs: 0.52
    spruce_stairs: 0.32
    oak_slab: 0.25
    spruce_slab: 0.29
    oak_fence: 0.24
    spruce_fence: 0.23
    cobblestone: 0.91
    stone_bricks: 0.73
    cobblestone_slab: 0.45
    stone_brick_slab: 0.25
    cobblestone_stairs: 0.26
    stone_brick_stairs: 0.13
    iron_bars: 0.1
    oak_sign: 0.34
    spruce_sign: 0.29
    lantern: 0.56
    torch: 0.62

# Lower number means higher reward #
# Minimum value is 20.2496 - which means 64 of the item  #
# gives full influence -- NEVER USE FOR CRAFTABLE ITEMS! #

# WIP!

ItemGradientData:
    type: data
    stone_sword: 2000
    stone_axe: 2000
    iron_sword: 500
    iron_axe: 600
    diamond_sword: 900
    diamond_axe: 1000
    netherite_sword: 100
    netherite_axe: 90
    bow: 400
    crossbow: 375
    arrow: 6000
    iron_helmet: 200
    iron_chestplate: 200
    iron_leggings: 200
    iron_boots: 200
    golden_helmet: 200
    golden_chestplate: 200
    golden_leggings: 200
    golden_boots: 200
    diamond_helmet: 200
    diamond_chestplate: 200
    diamond_leggings: 200
    diamond_boots: 200
    netherite_helmet: 120
    netherite_chestplate: 90
    netherite_leggings: 120
    netherite_boots: 130
    bricks: 1550
    oak_planks: 2005
    spruce_planks: 2000
    oak_log: 1800
    spruce_log: 1450
    glass: 1550
    glass_pane: 1400
    oak_stairs: 1950
    spruce_stairs: 1325
    oak_slab: 2200
    spruce_slab: 220
    oak_fence: 1850
    spruce_fence: 1850
    cobblestone: 1950
    stone_bricks: 1800
    cobblestone_slab: 2000
    stone_brick_slab: 1950
    cobblestone_stairs: 2050
    stone_brick_stairs: 2050
    iron_bars: 1560
    oak_sign: 1800
    spruce_sign: 1800
    lantern: 1450
    torch: 1750

######################################
# +----------------------------------+
# | Daily AI Weapons Orders
# |
# | Refreshed automagically everyday
# +----------------------------------+
######################################

# This script will loop through all the items that can
# be shipped to the militia and assign them a value of
# 1 or 0 in YAML to signify whether or not they're
# available during this refresh.

DailyOrderRefresh:
    type: task
    script:
    - define refreshDecider <util.random.decimal[0.1].to[1]>

    - yaml load:powerstruggle.yml id:ps

    - foreach <yaml[ps].read[transferItemsToday].to_pair_lists>:
        - define item <[value].get[1]>
        - define value <[value].get[2]>

        # if the weighting for each item is above the refresh
        # threshold then assign the item key in YAML a value
        # representing the amount of available orders.

        # if not then set the value to 0.

        - define itemWeight <script[ItemOrderWeightings].data_key[<[item]>]>

        - narrate format:debug ITEM:<[item]>
        - narrate format:debug WEIGHT:<[itemWeight]>

        - if <[itemWeight].is[MORE].than[<[refreshDecider]>]>:
            - define dataKey <script[ItemGradientData].data_key[<[item]>]>
            - define itemAmountWeight <util.random.int[32].to[<[dataKey].div[2]>].div[2].round_up.if_null[0]>

            - narrate format:debug IAW:<[itemAmountWeight]>

            - define itemAmount <util.random.int[<[itemAmountWeight].div[2].round_up>].to[<[itemAmountWeight]>]>
            - narrate format:debug AMOUNT:<[itemAmount]>

            - yaml id:ps set transferItemsToday.<[item]>:<[itemAmount]>

        - else:
            - yaml id:ps set transferItemsToday.<[item]>:0

        - narrate format:debug -----------------------------
    - yaml id:ps savefile:powerstruggle.yml
    - yaml id:ps unload

DailyOrderRefresh_Handler:
    type: world
    events:
        on system time hourly every:24:
        - run DailyOrderRefresh

TransferTracker_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Transfer Tracker
    procedural items:
    - determine <player.flag[transferItemList]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []

TransferWindow_Handler:
    type: command
    name: transfers
    usage: /transfers
    description: Shows all of your kingdom's active transfer orders
    script:
    - define kingdom <player.flag[kingdom]>
    - define transferFlag <server.flag[<[kingdom]>.powerstruggle.activeTransfers]>
    - define transferItemList <list[]>

    - foreach <[transferFlag]> as:request:
        - narrate format:debug <[request].get[material].as[item]>

        - define transferItem <[request].get[material].as[item]>
        - adjust def:transferItem "lore:<element[Transfer ID: ].color[aqua]><[key].color[gray]>|<element[Amount: ].color[aqua]><element[$<[request].get[amount].format_number>].color[red]>|<element[Due by: ].color[aqua]><element[<[request].get[due].to_local.format>]>"
        - define transferItemList:->:<[transferItem]>

        - flag <player> transferItemList:<[transferItemList]>
        - inventory open d:TransferTracker_Window
        - flag <player> transferItemList:!