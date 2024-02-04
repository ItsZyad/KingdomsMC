##
## Helps the admin add more items to the dynamic markets price info file by extrapolating the data
## from similar items in the file.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Oct 2022
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------


PriceExtrapolationHelper_Command:
    type: command
    name: pricehelp
    usage: /pricehelp [group] [item] [-r]
    permission: kingdoms.admin
    description: Helps extrapolate prices for new items in price-info.yml from existing items<&nl><&gt> -r flag restricts extrapolation search to the same group<&nl><&gt> -c flag ensures that only stats present in every item in the dataset are extrapolated
    tab completions:
        1: (group name)|help
        2: (item)
        3: -r|-c

    ## Generates the final stats from the allStats variable
    GenerateFinalStatsFromScratch:
    # This code does what it is written to do, however still has logical issues.
    # It accounts for crafting value in one direction only. EXAMPLE;

    # oak_log --> 4 oak_planks
    # If you want to set the price of oak_planks it looks at the price of one oak_log
    # but does not account for the fact that oak_planks should be a 1/4 the value of
    # oak_logs. So before this can be committed, the process must be checked in reverse
    # too, to every item in allRecipes.

    # There's also a design consideration on whether this code is even necessary. It assumes
    # that the prices of related goods are prefectly relational and balanced in real life.
    # which is simply untrue as the market is generally chaotic and in constant flux. Should
    # the supply/demand balance mechanic be implemented properly, any attempt to exploit any
    # potential mismatch between buy and sell prices should be met, by the market, with an
    # appropriate response of raising or reducing prices.

    # - define allRecipes <item[<[item]>].recipe_ids>

    # - yaml load:economy_data/price-info.yml id:prices

    # - define highestCraftingVal -1

    # - foreach <[allRecipes]>:
    #     - define craftingValueMin 0
    #     - define craftingMaterials <server.recipe_items[<[value]>].split[MATERIAL:].get[2]>

    #     - narrate format:debug CRF:<[craftingMaterials]>

    #     - foreach <[craftingMaterials]> as:material:
    #         #- narrate format:debug MAT:<[searchItems].contains[<[material].to_lowercase>]>
    #         - if <[searchItems].contains[<[material].to_lowercase>]>:
    #             - define materialData <yaml[prices].read[price_info.items].to_pair_lists.parse_tag[<[parse_value].get[2].get[<[material].to_lowercase>].if_null[-1]>].exclude[-1]>
    #             - define craftingValueMin <[craftingValueMin].add[<[materialData].get[1].get[base]>]>

    #     - if <[craftingValueMin]> > <[highestCraftingVal]>:
    #         - define highestCraftingVal <[craftingValueMin]>

    # - narrate format:debug CRAFTING_VAL:<[highestCraftingVal]>

    # - yaml id:prices unload

    - foreach <[allStats.sums]>:
        - if <[consistentDatapointsOnly]> && <[value].get[occurances]> != <[extrapolatedItems].size>:
            - foreach next

        - define finalStats.<[key]>:<[value].get[value].div[<[value].get[occurances]>].round_to_precision[0.01]>

    ## Generates the final stats from an existing finalStats variable;
    ## Used when the player wishes to change only one value from finalStats and leave the rest unchanged
    RegenerateFinalStats:
    - narrate <n>
    - narrate "<bold>FINAL OUTPUT -"
    - narrate "<strikethrough>              "
    - narrate <[item].color[aqua]><&co>

    - define clickableList <list[]>

    - foreach <[finalStats]> as:stat:
        - clickable save:refresh_all_stats until:1m for:<player> usages:1:
            - flag <player> noChat.admin.retypingStat
            - narrate format:admincallout "Type the new value in the chatbox:"

            - waituntil <player.has_flag[noChat.admin.retypingStat].not> rate:10t

            - if <player.has_flag[replacementStat]>:
                - define finalStats.<[key]>:<player.flag[replacementStat]>
                - flag <player> replacementFlag:!

            - foreach <[clickableList]>:
                - clickable cancel:<[value]>

            - inject PriceExtrapolationHelper_Command path:RegenerateFinalStats

        - narrate "    <[key].color[gray]>: <[stat]> <element[[Change Value]].on_click[<entry[refresh_all_stats].command>].color[red].underline>"

        - define clickableList:->:<entry[refresh_all_stats].id>

    - clickable save:accept_final usages:1 for:<player> until:5m:
        - clickable cancel:<entry[reject_final].id>
        - inject PriceExtrapolationHelper_Command path:AcceptFinalOutput

    - clickable save:reject_final usages:1 for:<player> until:5m:
        - define finalStats:!
        - define allStats:!
        - narrate <n>
        - narrate format:admincallout "Discarded all pending changes for item: <[item].color[aqua]>"
        - clickable cancel:<entry[accept_final].id>
        - determine cancelled

    - narrate <n>
    - narrate "<element[ACCEPT FINAL OUTPUT].color[green].bold.underline.on_click[<entry[accept_final].command>].on_hover[This will write the above data to price-info.yml]>"
    - narrate "<element[REJECT FINAL OUTPUT].color[red].bold.underline.on_click[<entry[reject_final].command>]>"

    AcceptFinalOutput:
    - yaml load:economy_data/price-info.yml id:prices
    - yaml id:prices set price_info.items.<[group]>.<[item]>:<[finalStats]>
    - yaml id:prices savefile:economy_data/price-info.yml
    - yaml id:prices unload

    - narrate format:admincallout "Saved data for item: <[item].color[aqua]>"

    ## Writes out all items that matched the player's query and allows them to adjust the items that will be extrapolated from
    WriteItemList:
    - define clickableList <[clickableList].if_null[<list[]>]>

    - clickable save:save_new_items until:1m for:<player> usages:1:
        - yaml load:economy_data/price-info.yml id:prices
        - define allStats <map[]>
        - define allItems <map[]>

        - foreach <yaml[prices].read[price_info.items].keys> as:group:
            - define allItems <[allItems].include[<yaml[prices].read[price_info.items.<[group]>]>]>

        - yaml id:prices unload

        - foreach <[extrapolatedItems]> as:entry:
            - foreach <[allItems.<[entry]>]>:
                - define allStats.<[entry]>.<[key]>:<[value]>

                - if <[value].div[2].exists>:
                    - define allStats.sums.<[key]>.value:+:<[value].mul[<[weights].get[<[entry]>].if_null[1]>]>
                    - define allStats.sums.<[key]>.occurances:++

        - define finalStats <map[]>
        - inject PriceExtrapolationHelper_Command path:GenerateFinalStatsFromScratch
        - inject PriceExtrapolationHelper_Command path:RegenerateFinalStats

    #- narrate format:debug EXT:<[extrapolatedItems]>

    - foreach <[extrapolatedItems]> as:entry:
        # Clickable attached to the end of every line allowing the player to remove an item from extrapolation
        - clickable save:item_clickable until:1m for:<player> usages:1:
            - define target <[entry]>
            - define extrapolatedItems:<-:<[target]>

            - foreach <[clickableList]> as:clickable:
                - clickable cancel:<[clickable]>

            - inject PriceExtrapolationHelper_Command path:WriteItemList

        - clickable save:weight_item until:1m for:<player> usages:1:
            - define target <[entry]>
            - flag <player> noChat.admin.weightingItem
            - narrate format:admincallout "Please type the weight you would like to assign this item:"

            - waituntil <player.has_flag[noChat.admin.weightingItem].not> rate:10t

            - if <player.has_flag[itemWeight]>:
                - define weights.<[target]>:<player.flag[itemWeight].if_null[<[weights].get[<[target]>].if_null[1]>]>

            - foreach <[clickableList]>:
                - clickable cancel:<[value]>

            - inject PriceExtrapolationHelper_Command path:WriteItemList

        - define clickableList:->:<entry[item_clickable].id>
        - define clickableList:->:<entry[weight_item].id>

        - yaml load:economy_data/price-info.yml id:prices

        - foreach <yaml[prices].read[price_info.items].keys> as:key:
            - if <yaml[prices].contains[price_info.items.<[key]>.<[entry]>]>:
                - define itemInfo "<yaml[prices].read[price_info.items.<[key]>.<[entry]>].to_list[ : ].separated_by[<n>]>"
                - foreach stop

        - yaml id:prices unload

        - narrate "<element[[Remove Item]].on_click[<entry[item_clickable].command>].color[red].underline> <element[[Weight]].on_click[<entry[weight_item].command>].color[aqua].underline>.....<[entry].color[gray].italicize.underline.on_hover[<[itemInfo]>]>.....<element[Weight: ].color[aqua]><[weights].get[<[entry]>].if_null[1]>"

    - narrate <n>
    - narrate "<element[Calculate New Item Averages].color[green].bold.underline.on_click[<entry[save_new_items].command>]>"
    - inject PriceExtrapolationHelper_Command path:AddItemToExtrapolation
    - define clickableList:<-:<entry[save_new_items].id>

    ## Inserts a clickable that allows the player to add a new item to extrapolatedItems using the chat (see the handler below)
    AddItemToExtrapolation:
    - clickable save:add_item for:<player> usages:1 until:1m:
        - flag <player> noChat.admin.addItem
        - narrate format:admincallout "Type the name of the item you would like to add to the extrapolation list as it appears in the advanced tooltips (F3+H):"

        - waituntil <player.has_flag[noChat.admin.addItem].not> rate:10t max:1m

        - if <player.has_flag[noChat.admin.addItem]>:
            - narrate format:admincallout "Input period expired. Please re-click the prompt to add an item."

        - else if <player.has_flag[newItem]>:
            - define extrapolatedItems:->:<player.flag[newItem]>
            - narrate format:admincallout "Added new item: <player.flag[newItem].color[aqua]>"
            - flag <player> newItem:!
            - inject PriceExtrapolationHelper_Command path:WriteItemList

    - narrate "<element[Add New Item].color[green].bold.underline.on_click[<entry[add_item].command>]>"

    script:
    - if <context.args.get[1]> == help:
        - narrate <script.parsed_key[description]>
        - determine cancelled

    - yaml load:economy_data/price-info.yml id:prices
    - define args <context.raw_args.split_args>
    - define group <[args].get[1]>
    - define item <[args].get[2]>
    - define flags <[args].get[3].to[last]>
    - define searchItems <list[]>
    - define clickableList <list[]>
    - define consistentDatapointsOnly false
    - define weights <map[]>

    # the -r flag restricts the search for like terms to extrapolate from to the current group
    - if <[flags].contains[-r]>:
        - define searchItems <yaml[prices].read[price_info.items.<[group]>].keys>

    - else:
        - foreach <yaml[prices].read[price_info.items]>:
            - define searchItems <[searchItems].include[<[value].keys>]>

    - if <[item].is_in[<[searchItems]>]>:
        - clickable save:Confirm_ExistingItem for:<player> usages:1 until:10m:
            - define searchItems <[searchItems].exclude[<[item]>]>
            - narrate format:admincallout "Proceeding... Adjusting extrapolation data to prevent contamination."
            - narrate <n>
            - clickable cancel:<entry[Cancel_ExistingItem].id>
            - flag <player> noChat.admin.existingItemSelection:confirm

        - clickable save:Cancel_ExistingItem for:<player> usages:1 until:10m:
            - narrate format:admincallout "Cancelled item price extrapolation."
            - clickable cancel:<entry[Confirm_ExistingItem].id>
            - flag <player> noChat.admin.existingItemSelection:cancel

        - define existingItemInfo <yaml[prices].read[price_info.items.<[group]>.<[item]>]>
        - narrate format:admincallout "This item already exists with the following data: "
        - narrate "    <[existingItemInfo].to_list[ : ].separated_by[<n>    ].italicize>"
        - narrate <n>
        - narrate format:admincallout "Do you want to proceed anyways and overwrite its price data?"
        - narrate "<element[YES].bold.underline.color[green].on_click[<entry[Confirm_ExistingItem].command>]> / <element[NO].bold.underline.color[red].on_click[<entry[Cancel_ExistingItem].command>]>"

        - waituntil <player.has_flag[noChat.admin.existingItemSelection]> rate:10t

        - define didCancel <player.flag[noChat.admin.existingItemSelection]>
        - flag <player> noChat.admin.existingItemSelection:!

        - if <[didCancel]> == cancel:
            - determine cancelled

    - if <[flags].contains[-c]>:
        - define consistentDatapointsOnly true

    # generates a list of other items similar to the item selected to extrapolate data from
    - if <[item].contains[_]>:
        - define itemSplit <[item].split[_]>

        - foreach <[itemSplit]>:
            - define extrapolatedItems <[extrapolatedItems].if_null[<list[]>].include[<[searchItems].find_all_partial[<[value]>].as[list].parse_tag[<[searchItems].get[<[parse_value]>]>].exclude[<[value]>]>]>

    - else:
        - define extrapolatedItems <[searchItems].find_all_partial[<[item]>].as[list].parse_tag[<[searchItems].get[<[parse_value]>]>].exclude[<[item]>]>

    - if <[extrapolatedItems].size> != 0:
        - inject PriceExtrapolationHelper_Command path:WriteItemList

    - else:
        - narrate format:admincallout "Cannot find any item similar to this in price-info.yml. You can add similar items to the file manually. Or add any item from the file using the button below:"
        - inject PriceExtrapolationHelper_Command path:AddItemToExtrapolation

    - yaml id:prices unload

    ##FLAVOR FEATURE FOR FUTURE REFERENCE: ALLOW WEIGHTING OF EACH ITEM BASED ON IMPORTANCE OF ITS DATA

PriceExtrapolation_Handler:
    type: world
    events:
        on player chats flagged:noChat.admin.retypingStat:
        - if <context.message> == cancel:
            - flag <player> noChat.admin.retypingStat:!
            - narrate format:admincallout "Cancelled operation."

        - else if <context.message.div[2].exists>:
            - flag <player> replacementStat:<context.message>
            - flag <player> noChat.admin.retypingStat:!

        - else:
            - narrate format:admincallout "This is not a valid integer or decimal. Please enter a valid value or type 'cancel':"

        - determine cancelled

        on player chats flagged:noChat.admin.addItem:
        - yaml load:economy_data/price-info.yml id:prices

        - if <context.message> == cancel:
            - flag <player> noChat.admin.addItem:!
            - narrate format:admincallout "Cancelled operation"

        - else if <context.message.as[material].exists>:
            - if <util.parse_yaml[<yaml[prices].read[price_info.items]>].deep_keys.parse_tag[<[parse_value].ends_with[<context.message>.base]>].contains[true]>:
                - flag <player> newItem:<context.message>
                - flag <player> noChat.admin.addItem:!

            - else:
                - narrate format:admincallout "The value: <context.message> does not appear in price-info.yml. Please try again or type 'cancel'."

        - else:
            - narrate format:admincallout "This is not a valid item. Please enter the item as it appears in the advanced tooltips (F3+H) or type 'cancel':"

        - determine cancelled

        on player chats flagged:noChat.admin.weightingItem:
        - if <context.message> == cancel:
            - flag <player> noChat.admin.weightingItem:!
            - narrate format:admincallout "Cancelled Operation"

        - else if <context.message.div[2].exists>:
            - if <context.message> <= 1:
                - flag <player> itemWeight:<context.message>

            - else:
                - narrate format:admincallout "<element[Warning!].color[red].bold> Item weight values must be between 0 and 1!"
                - flag <player> itemWeight:!

            - flag <player> noChat.admin.weightingItem:!

        - else:
            - narrate format:admincallout "This is not a valid integer or decimal. Please enter a valid value or type 'cancel':"

        - determine cancelled
