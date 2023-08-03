##
## * All files related to the creation of regular market
## * and regular merchants in Kingdoms
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Nov 2022
## @Script Ver: INDEV
##
## ----------------END HEADER-----------------


MarketCreation_Command:
    type: command
    name: market
    usage: /market create|remove|init [name] [Attractiveness]|...|[Spawn Chance] [Max Size]|...
    permission: kingdoms.admin.markets
    description: Designates a market with a given name and area
    tab completions:
        1: create|remove|init
        2: (Name)
        3: (Attractiveness)|...|(Spawn Chance)
        4: (?MaxSize)|...|...
    script:
    - define args <context.raw_args.split_args>
    - define action <[args].get[1]>
    - define name <[args].get[2]>
    - define maxSize <[args].get[4].if_null[n/a]>

    - if <[action]> == name:
        - if <[args].size> < 3:
            - narrate format:admincallout "You must provide all the details for market creation as shown in the command's tab-complete"
            - determine cancelled

        - if <server.has_flag[economy.markets.<[name]>]>:
            - narrate format:admincallout "There already exists a market with that name. Please choose a different name."
            - determine cancelled

    - if !<[name].char_at[1].to_lowercase.matches_character_set[abcdefghijklmnopqrstuvwxyz1234567890]>:
        - narrate format:admincallout "Market name must start with an alphanumeric character"
        - determine cancelled

    - if <[action].exists> && <[name].exists>:
        - choose <[action].to_lowercase>:
            - case init:
                - define spawnChance <util.random.decimal[0].to[1]>

                - if <[args].get[3].is_decimal>:
                    - define spawnChance <[args].get[3]>

                - define merchantAmount <server.flag[economy.markets.<[name]>.merchants].size>

                - run SupplyAmountCalculator def.marketSize:<[merchantAmount]> def.spawnChance:<[spawnChance]> save:supplyAmount

                - define supply <entry[supplyAmount].created_queue.determination.get[1]>
                - flag server economy.markets.<[name]>.supplyMap.original:<[supply]>
                - flag server economy.markets.<[name]>.supplyMap.current:<[supply]>

            - case create:
                - define attractiveness <[args].get[3]>

                - flag server economy.markets.<[name]>.ID:<server.flag[economy.markets].size.if_null[0].add[1]>
                - flag server economy.markets.<[name]>.merchants:<list[]>
                - flag server economy.markets.<[name]>.attractiveness:<[attractiveness]>
                - flag server economy.markets.<[name]>.maxSize:<[maxSize]> if:<[maxSize].equals[n/a].not>
                - flag server economy.markets.<[name]>.supplierPriceMod:0.6

                - clickable save:make_area until:10m usages:1 for:<player>:
                    - give to:<player.inventory> MarketCreation_Item
                    - narrate format:admincallout "Click the blocks you would like to constitute the borders of the market area. Drop the market wand to cancel the process.<n>Type <element[/market complete].color[green]> to finish the process."
                    - narrate format:admincallout "<gray><italic>Note: This does not need to be an exact area. You will still be able to determine where individual merchants can go."

                - clickable save:no_make_area until:10m usages:1 for:<player>:
                    - narrate "<green>Created market area: '<[name].bold.underline>'"

                - narrate format:admincallout "You may optionally define an area that a market operates in. This will restrict the places where merchants can spawn."
                - narrate "<blue>Would you like to do that?"
                - narrate "<n><element[Yes].color[green].on_click[<entry[make_area].command>]> / <element[No].color[red].on_click[<entry[no_make_area].command>]>"

            - case complete:
                - define minY 999
                - define maxY -999
                - define world <player.location.world>
                - define coordList <list[]>

                - foreach <player.flag[marketPoints]> as:point:
                    - define coordList:->:<[point].x>
                    - define coordList:->:<[point].z>

                    - if <[point].y> > <[maxY]>:
                        - define maxY <[point].y>

                    - if <[point].y> < <[minY]>:
                        - define minY <[point].y>

                - define marketArea <polygon[<[world].name>,<[minY]>,<[maxY]>,<[coordList].comma_separated.replace_text[<&sp>].with[]>]>

                - take from:<player.inventory> item:MarketCreation_Item

                - foreach <player.flag[marketPoints]> as:point:
                    - showfake cancel <[point]>

                - flag <player> marketPoints:!
                - flag server economy.markets.<[name]>.marketArea:<[marketArea]>
                - note <[marketArea]> as:<[name]>
                - showfake red_stained_glass <[marketArea].outline_2d[<player.location.y.add[10]>]>
                - narrate format:admincallout "Created market area: '<[name]>'!"

            - case remove:
                - if <server.has_flag[economy.markets.<[name]>]>:
                    - narrate format:admincallout "Removed market with name: <[name]>"
                    - flag server economy.markets.<[name]>:!

                - else:
                    - narrate format:admincallout "There exists no market with the name"

            - default:
                - narrate format:admincallout "<[action].color[red]> is not a valid argument."

    - else:
        - narrate format:admincallout "You must provide a create/remove action and an ID to create a market."


MarketCreation_Item:
    type: item
    material: blaze_rod
    display name: <gold><bold>Market Designation Wand


MarketCreation_Handler:
    type: world
    events:
        on player clicks block with:MarketCreation_Item:
        - flag <player> marketPoints:->:<player.cursor_on>

        - foreach <player.flag[marketPoints]> as:point:
            - showfake red_stained_glass <[point]> d:100s

        on player drops MarketCreation_Item:
        - determine passively cancelled
        - narrate "Cancelled market creation process!"
        - take from:<player.inventory> item:MarketCreation_Item

        - foreach <player.flag[marketPoints]> as:point:
            - showfake cancel <[point]>

        - flag <player> marketPoints:!


MerchantCreation_Command:
    type: command
    name: merchant
    usage: /merchant create|remove|resetstat ...|[ID]|... [Spec]|...|...
    permission: kingdoms.admin.merchants
    description: Creates, removes, or edits regular Kingdoms merchants
    tab completions:
        1: create|remove|resetstats
    tab complete:
    - define args <context.raw_args.split_args>

    - if <[args].size> >= 1 && <[args].get[1]> == create:
        - yaml load:economy_data/price-info.yml id:prices
        - define groups <yaml[prices].read[price_info.items].keys>
        - yaml id:prices unload

        - determine <[groups]>

    script:
    - define args <context.raw_args.split_args>
    - define action <[args].get[1]>

    - choose <[action]>:
        - case create:
            - run TempSaveInventory def.player:<player>
            - give to:<player.inventory> MerchantPlacement_Item
            - flag <player> PlacingMerchant
            - flag <player> dataHold.merchantSpec:<[args].get[2].if_null[null]>

        - case remove:
            - define mercID <[args].get[2]>
            - define npc <npc[<[mercID]>]>

            - if <[npc].exists> && <[npc].has_flag[merchantData]>:
                - remove <[npc]>

            - else:
                - narrate format:admincallout "This is not a valid merchant npc! The npc selected either does not exist or is not a valid merchant."

        - case resetstat:
            - narrate format:debug WIP
            #TODO: Add a subcommand which allows you to enter the name of a merchantData sub-flag
            #TODO: that will get reset to a default value.


MerchantPlacement_Item:
    type: item
    material: armor_stand
    display name: <blue><bold>Merchant Placement Stand
    mechanisms:
        hides: ALL
    enchantments:
    - sharpness: 1
    lore:
    - Drop item to quit merchant spawning


MerchantPlacement_Handler:
    type: world
    debug: false
    subpaths:
        SpawnMerchantPrompt:
        - define marketsFlag <server.flag[economy.markets]>

        - if <[marketsFlag].size> == 0:
            - narrate format:admincallout "Cannot create a Kingdoms merchant without defining any markets. Use <element[/market create].color[aqua]> to do so."
            - determine cancelled

        - define merchantPos <player.flag[PlacingMerchant].get[2]>

        - narrate format:admincallout "Enter the name of the market this merchant should belong to. Type: <element[*auto].color[aqua]> to automatically assign it based on the market area it is currently in."
        - narrate format:admincallout "Type <element['cancel'].color[red]> to stop creating a merchant at this location."
        - flag <player> noChat.economy.spawningMerchant

        CreateMerchant:
        - if <player.has_flag[datahold.merchantSpec]>:
            - define spec <player.flag[datahold.merchantSpec].replace[_].with[<&sp>].to_titlecase>
            - create player "<&6><[spec]> Merchant" <[merchantPos]> save:newMerchant

        - else:
            - create player "&7Unspecialized Merchant" <[merchantPos]> save:newMerchant

        - define newMerc <entry[newMerchant].created_npc>
        - adjust <[newMerc]> lookclose:true
        - adjust def:newMerc lookclose:true

        - flag <[newMerc]> merchantData.linkedMarket:<[marketName]>
        - flag <[newMerc]> merchantData.spec:<player.flag[dataHold.merchantSpec]>
        - flag <[newMerc]> merchantData.spendBias:<util.random.decimal[0].to[1]>
        - flag <player> noChat.economy.spawningMerchant:!
        - flag <player> PlacingMerchant:!
        - flag <player> dataHold.merchantSpec:!
        - flag <player> merchantRef:<[newMerc]>
        - flag server economy.markets.<[marketName]>.merchants:->:<[newMerc]>

        - assignment set script:KMerchant_Assignment to:<[newMerc]>

        - inventory open d:MerchantWealthSelector_Window

    events:
        # When player selects merchant tool for the first time
        on player holds item item:MerchantPlacement_Item:
        - if !<player.has_flag[PlacingMerchant]>:
            - flag <player> PlacingMerchant

        # When player deselects merchant tool
        on player holds item flagged:PlacingMerchant:
        - if <player.inventory.slot[<context.new_slot>].script.name.to_lowercase.if_null[null]> != merchantplacement_item:
            - fakespawn cancel <player.flag[PlacingMerchant].get[1]>
            - flag <player> PlacingMerchant:!

        on player drops MerchantPlacement_Item:
        - determine passively cancelled
        - wait 1t
        - take item:MerchantPlacement_Item
        - fakespawn cancel <player.flag[PlacingMerchant].get[1]>
        - flag <player> PlacingMerchant:!
        - flag <player> noChat.economy.spawningMerchant:!
        - run LoadTempInventory def.player:<player>

        on player walks flagged:PlacingMerchant:
        - ratelimit <player> 1t
        - if <player.flag[PlacingMerchant].get[2].if_null[<player.cursor_on>]> != <player.cursor_on.up[1].add[0.5,0,0.5]> && !<player.has_flag[noChat.economy.spawningMerchant]>:
            - fakespawn armor_stand <player.cursor_on.up[1].add[0.5,0,0.5]> save:fake_stand
            - fakespawn cancel <player.flag[PlacingMerchant].get[1]> if:<player.flag[PlacingMerchant].get[1].exists>
            - flag <player> PlacingMerchant:<list[<entry[fake_stand].faked_entity>|<player.cursor_on.up[1].add[0.5,0,0.5]>]>

        - else if !<player.flag[PlacingMerchant].get[1].is_in[<player.fake_entities>]>:
            - fakespawn armor_stand <player.cursor_on.up[1].add[0.5,0,0.5]> save:fake_stand
            - flag <player> PlacingMerchant:<list[<entry[fake_stand].faked_entity>|<player.cursor_on.up[1].add[0.5,0,0.5]>]>

        on player clicks block with:MerchantPlacement_Item:
        - inject MerchantPlacement_Handler.subpaths.SpawnMerchantPrompt
        - determine cancelled

        on player clicks fake entity flagged:PlacingMerchant:
        - if <context.entity.name> == armor_stand:
            - inject MerchantPlacement_Handler.subpaths.SpawnMerchantPrompt
            - determine cancelled

        on player chats flagged:noChat.economy.spawningMerchant:
        - define markets <server.flag[economy.markets]>
        - define merchantPos <player.flag[PlacingMerchant].get[2]>

        - if <context.message> == *auto:
            - foreach <[markets]> as:market:
                - define marketName <[key]>
                - define marketArea <[market].get[marketArea]>

                - if <[marketArea].contains[<[merchantPos]>]>:
                    - inject MerchantPlacement_Handler.subpaths.CreateMerchant
                    - determine cancelled

            - narrate format:admincallout "The merchant is not currently inside any defined market area. Please manually specify the name of the market or type <element['cancel'].color[red]>."

        - else if <context.message.to_lowercase> == cancel:
            - flag <player> noChat.economy.spawningMerchant:!
            - narrate format:admincallout "Cancelled merchant creation."
            - determine cancelled

        - else:
            - define marketName <context.message>
            - define markets <server.flag[economy.markets]>
            - define merchantPos <player.flag[PlacingMerchant].get[2]>

            - if <[marketName].is_in[<[markets].keys>]>:
                - inject MerchantPlacement_Handler.subpaths.CreateMerchant
                - determine cancelled

            - else:
                - narrate format:admincallout "There is no market with this name. Please try again or type: <element['cancel'].color[red]>."


MerchantPoor_Item:
    type: item
    material: red_wool
    display name: <red><bold>Low Wealth
    flags:
        wealth: low


MerchantNormal_Item:
    type: item
    material: orange_wool
    display name: <gold><bold>Normal Wealth
    flags:
        wealth: normal


MerchantWealthy_Item:
    type: item
    material: green_wool
    display name: <green><bold>High Wealth
    flags:
        wealth: high


MerchantVeryWealthy_Item:
    type: item
    material: purple_wool
    display name: <light_purple><bold>Very High Wealth
    flags:
        wealth: very_high


MerchantWealthSelector_Window:
    type: inventory
    inventory: chest
    title: Select Merchant Wealth Level
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [MerchantPoor_Item] [] [MerchantNormal_Item] [] [MerchantWealthy_Item] [] [MerchantVeryWealthy_Item] []
    - [] [] [] [] [] [] [] [] []


MerchantWealthSelector_Handler:
    type: world
    events:
        on player clicks item in MerchantWealthSelector_Window:
        - define merchant <player.flag[merchantRef]>
        - flag <player> merchantRef:!
        - define wealth <context.item.flag[wealth].if_null[normal]>
        ## NOTE: To be used only until I have a dynamic way of generating average wealth values
        ## based on current market values and economic situation of the kingdoms.
        - definemap wealthMatrix:
            low: 3000
            normal: 5000
            high: 8000
            very_high: 13500
        - define wealthList <[wealthMatrix].to_pair_lists>
        - define wealthIndex <[wealthMatrix].keys.find[<[wealth]>]>
        # Selects a random value between the level lower than the merchant's selected wealth level
        # and the level higher. Example if the merchant's wealth level is 'normal' then the true
        # wealth level will be somewhere between 3000 and 8000.
        - define merchantWealth <util.random.int[<[wealthList].get[<[wealthIndex].sub[1].if_null[0]>].get[2]>].to[<[wealthList].get[<[wealthIndex].add[1]>].get[2].if_null[16000]>]>
        - flag <[merchant]> merchantData.wealth:<[merchantWealth]>
        - flag <[merchant]> merchantData.balance:<[merchantWealth]>

        # QBias Calculation:
        # q = ((wealth + 1000) ^ 2 / 10000 ^ 2) - 0.01
        - define qBias <element[<[merchantWealth].add[1000]>].power[2].div[<element[10000].power[2]>].sub[0.01]>
        - define qBias 0.99 if:<[qBias].is[OR_MORE].than[1]>
        - flag <[merchant]> merchantData.quantityBias:<[qBias]>

        - narrate format:admincallout "Merchant wealth is: $<[merchantWealth].color[aqua].bold>"
        - run LoadTempInventory def.player:<player>

        - inventory close
        - determine cancelled