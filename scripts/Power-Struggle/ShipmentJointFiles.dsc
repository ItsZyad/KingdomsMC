ItemOrderWeightings:
    type: data
    stone_sword: 0.85
    stone_axe: 0.8
    iron_sword: 0.6
    iron_axe: 0.55
    diamond_sword: 0.3
    diamond_axe: 0.25
    netherite_sword: 0.05
    netherite_axe: 0.035
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
    netherite_sword: 60
    netherite_axe: 90
    bow: 400
    crossbow: 375
    arrow: 7000
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
    netherite_helmet: 100
    netherite_chestplate: 80
    netherite_leggings: 105
    netherite_boots: 120
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
# 1 or 0 in flag to signify whether or not they're
# available during this refresh.

DailyOrderRefresh:
    type: task
    debug: false
    script:
    - foreach <server.flag[kingdoms.powerstruggleInfo.transferItems]> key:item as:amount:
        - define itemWeight <script[ItemOrderWeightings].data_key[<[item]>]>
        - define dataKey <script[ItemGradientData].data_key[<[item]>]>
        - define itemAmountWeight <util.random.int[32].to[<[dataKey].div[2]>].div[2].round_up.if_null[1]>
        - define itemAmount <util.random.int[<[itemAmountWeight].div[2].round_up>].to[<[itemAmountWeight]>]>

        - if <player.exists> && <player.has_permission[kingdoms.admin]>:
            - narrate format:debug ITEM:<[item]>
            - narrate format:debug IAW:<[itemAmountWeight]>
            - narrate format:debug AMOUNT:<[itemAmount]>
            - narrate format:debug ----------------------------

        - flag server kingdoms.powerstruggleInfo.transferItems.<[item]>:<[itemAmount]>


OLD_DailyOrderRefresh:
    type: task
    script:
    - define refreshDecider <util.random.decimal[0.1].to[1]>

    - foreach <server.flag[kingdoms.powerstruggleInfo.transferItems].to_pair_lists>:
        - define item <[value].get[1]>
        - define value <[value].get[2]>

        # if the weighting for each item is above the refresh
        # threshold then assign the item key in flag a value
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

            - flag server kingdoms.powerstruggleInfo.transferItems.<[item]>:<[itemAmount]>

        - else:
            - flag server kingdoms.powerstruggleInfo.transferItems.<[item]>:0

        - narrate format:debug -----------------------------

    - narrate format:debug REF:<[refreshDecider]>


DailyOrderRefresh_Handler:
    type: world
    events:
        on system time hourly every:24:
        - run DailyOrderRefresh


TransferTakeoverChecker:
    type: task
    definitions: originalPlayer|newPlayer|transferInfo
    script:
    - define transferID <[transferInfo].get[transferID]>

    - if !<[originalPlayer].has_flag[maintainedTransferRights.<[transferID]>]>:
        - flag <[newPlayer]> transferData:<[originalPlayer].flag[transferData]>
        - flag <[originalPlayer]> transferData:!

        - define kingdom <player.flag[kingdom]>
        - define sameMaterialTransfers <server.flag[kingdoms.<[kingdom]>.powerstruggle.activeTransfers].values.parse_tag[<[parse_value].values.contains[<[newPlayer].flag[transferData].get[material]>]>].exclude[false].size>
        - define newTransferID <[newPlayer].name>-<[newPlayer].flag[transferData].get[material]><[sameMaterialTransfers]>

        - flag server <[kingdom]>.powerstruggle.activeTransfers.<[newTransferID]>:<[transferInfo]>

    - else:
        - flag <[originalPlayer]> maintainedTransferRights.<[transferID]>:!

        - if <[originalPlayer].is_online>:
            - narrate format:callout targets:<[originalPlayer]> "Player: <[newPlayer].name.color[red].bold> made a request to takeover a material/weapon transfer request you made with ID: <[transferID].color[red]>. Due to your inactivity they have taken over this request."


TransferClaimConfirm_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Confirm Claim?
    slots:
    - [] [] [TransferClaimYes_Item] [] [] [] [TransferClaimNo_Item] [] []


TransferClaimYes_Item:
    type: item
    material: green_wool
    display name: <green><bold>Confirm
    lore:
    - Doing this will allow you take over this player's transfer
    - request, allowing you to do it for them if they don't
    - contest your claim in 24 hours.


TransferClaimNo_Item:
    type: item
    material: red_wool
    display name: <red><bold>Cancel


TransferClaimConfirm_Handler:
    type: world
    events:
        on player clicks TransferClaimNo_Item in TransferClaimConfirm_Window:
        - inventory close
        - narrate format:callout Cancelled!
        - flag <player> transferInfo:!

        on player clicks TransferClaimYes_Item in TransferClaimConfirm_Window:
        - define transferInfo <player.flag[transferInfo]>
        - define transferID <[transferInfo].get[transferID]>
        - define originalPlayer <[transferInfo].get[madeBy]>

        - clickable usages:1 until:10m save:AllowTransferTO:
            - run TransferTakeoverChecker def.originalPlayer:<[originalPlayer]> def.newPlayer:<player> def.transferInfo:<[transferInfo]>
            - narrate format:callout targets:<[originalPlayer]> "Transfer request: <[transferID].bold> is now the responsibility of player: <player.name.color[red].bold>"
            - narrate format:callout "You have taken over the transfer request: <[transferID].bold>. See the <element[/transfer].color[aqua]> menu for information."
            - clickable cancel:DenyTransferTO

        - clickable usages:1 until:10m save:DenyTransferTO:
            - narrate format:callout targets:<[originalPlayer]> "Denied transfer request takeover!"
            - narrate format:callout "Player: <[originalPlayer].name.color[red].bold> has denied your transfer takeover request!"
            - clickable cancel:AllowTransferTO

        - if <[originalPlayer].is_online>:
            - narrate format:callout targets:<[originalPlayer]> "Another player from your kingdom (<player.name.color[gray].italicize>) is requesting to take over your material/weapon transfer with ID: <[transferID].color[red].bold><n>Do you wish to allow them?"
            - narrate "<element[YES].color[green].bold.on_click[<entry[AllowTransferTO].command>]> / <element[NO].color[red].bold.on_click[<entry[DenyTransferTO].command>]>"
            - narrate <n>
            - narrate format:callout "<gray><italic>You may also use the command: <element[/transfer takeover [<green>allow<aqua>/<red>deny]].color[aqua].italicize>"
            - narrate format:callout "Sent material transfer takeover request to: <[originalPlayer].name.color[red].bold>. They have 24 hours to accept."

        - else:
            - narrate format:callout "This player is not online. If they do not join the server within 24 hours and deny your request, this transfer request will be automatically made your responsibility."
            - flag <[originalPlayer]> maintainedTransferRights.<[transferID]> expire:24h
            - runlater TransferTakeoverChecker def.originalPlayer:<[originalPlayer]> def.newPlayer:<player> def.transferInfo:<[transferInfo]> delay:24h

        on player joins flagged:maintainedTransferRights:
        - define transferID <player.flag[maintainedTransferRights]>
        - define kingdom <player.flag[kingdom]>
        - define transferInfo <server.flag[kingdoms.<[kingdom]>.powerstruggle.activeTransfers.<[transferID]>]>
        - define originalPlayer <[transferInfo].get[madeBy]>

        - clickable usages:1 until:10m save:AllowTransferTO:
            - run TransferTakeoverChecker def.originalPlayer:<[originalPlayer]> def.newPlayer:<player> def.transferInfo:<[transferInfo]>
            - narrate format:callout targets:<[originalPlayer]> "Transfer request: <[transferID].bold> is now the responsibility of player: <player.name.color[red].bold>"
            - narrate format:callout "You have taken over the transfer request: <[transferID].bold>. See the <element[/transfer].color[aqua]> menu for information."
            - clickable cancel:DenyTransferTO

        - clickable usages:1 until:10m save:DenyTransferTO:
            - narrate format:callout targets:<[originalPlayer]> "Denied transfer request takeover!"
            - narrate format:callout "Player: <[originalPlayer].name.color[red].bold> has denied your transfer takeover request!"
            - clickable cancel:AllowTransferTO

        - narrate format:callout targets:<[originalPlayer]> "Another player from your kingdom (<player.name.color[gray].italicize>) is requesting to take over your material/weapon transfer with ID: <[transferID].color[red].bold><n>Do you wish to allow them?"
        - narrate "<element[YES].color[green].bold.on_click[<entry[AllowTransferTO].command>]> / <element[NO].color[red].bold.on_click[<entry[DenyTransferTO].command>]>"
        - narrate "<gray><italic>You have <player.flag_expiration[maintainedTransferRights].format.color[red]> left to take this decision."
        - narrate <n>
        - narrate "<gray><italic>You may also use the command: <element[/transfer takeover [<green>allow<aqua>/<red>deny]].color[aqua].italicize>"


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
    type: world
    events:
        on player clicks item in TransferTracker_Window:
        - if <context.item.flag[transferInfo.madeBy].as[player]> == <player>:
            - narrate format:callout "You cannot claim a transfer request that you made!"
            - determine cancelled

        - if <context.item.has_flag[claimable]>:
            - flag <player> transferInfo:<context.item.flag[transferInfo]>
            - inventory open d:TransferClaimConfirm_Window


TransferTracker_Command:
    type: command
    name: transfers
    usage: /transfers
    description: Shows all of your kingdom's active transfer orders
    script:
    - define kingdom <player.flag[kingdom]>
    - define transferFlag <server.flag[kingdoms.<[kingdom]>.powerstruggle.activeTransfers]>
    - define transferItemList <list[]>

    - if !<[transferFlag].exists> || <[transferFlag].is_empty>:
        - define noTransfersItem <item[barrier]>
        - adjust def:noTransfersItem display:<element[No Transfer Requests].color[red].bold>

        - define transferWindow <inventory[TransferTracker_Window]>
        - inventory open d:<[transferWindow]>
        - inventory set slot:23 o:<[noTransfersItem]> d:<[transferWindow]>
        - determine cancelled

    - foreach <[transferFlag]> as:request:
        - narrate format:debug <[request].get[madeBy]>

        - define transferItem <[request].get[material].as[item]>
        - adjust def:transferItem lore:<element[Transfer ID: ].color[aqua]><[key].color[gray]>|<element[Request Originally Made By: ].color[aqua]><[request].get[madeBy].name.color[gray].italicize>|<element[Amount: ].color[aqua]><element[$<[request].get[amount].format_number>].color[red]>|<element[Due by: ].color[aqua]><element[<[request].get[due].to_local.format>]>
        - flag <[transferItem]> transferInfo:<[request].include[transferID=<[key]>]>

        #- if <[request].get[madeBy]> != <player>:
        - adjust def:transferItem lore:<[transferItem].lore.include[|<element[CLICK TO CLAIM].color[green].bold>]>
        - flag <[transferItem]> claimable:true

        - define transferItemList:->:<[transferItem]>

        - flag <player> transferItemList:<[transferItemList]>
        - inventory adjust title:something d:TransferTracker_Window
        - inventory open d:TransferTracker_Window
        - flag <player> transferItemList:!