##
## [SCENARIO I]
## This file holds all scripts relating to the weapon trade sub-mechanic of the Scenario-1
## influence system.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Aug 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

SC1_GenerateAllianceWeaponTradeLists:
    type: task
    script:
    - yaml load:economy_data/worth.yml id:worth

    - define averageItemAmounts <script[SC1_WeaponData].data_key[Amounts]>
    - define allianceTowns <script[SC1_AllianceTownNames].data_key[Names].keys>

    - foreach <[allianceTowns]> as:town:
        - define itemMap <map[]>

        - foreach <[averageItemAmounts]> as:amount key:item:
            - define actualSpawnAmount <util.random.int[<[amount]>].to[<[amount].mul[1.5].round_up>]>
            - define itemMap.<[item]>:<[amount]>

        - flag server kingdoms.scenario-1.influence.weaponLists.<[town]>:<[itemMap]>


SC1_WeaponTradeList_Handler:
    type: world
    events:
        on system time hourly every:48:
        - ~run SC1_GenerateAllianceWeaponTradeLists


SC1_TransferVaultDesignator_Item:
    type: item
    material: arrow
    display name: <gray><bold>Transfer Vault Designator


SC1_WeaponTrade_Handler:
    type: world
    events:
        on player clicks SC1_AssistDefense_Item in SC1_AllianceTownInfluenceActions_Interface:
        - define kingdom <player.flag[kingdom]>
        - define marketName <script[SC1_AllianceTownNames].data_key[Names.<player.flag[datahold.scenario-1.influence.marketName]>]>

        - if <server.has_flag[influenceCooldown.weaponTrade.<[kingdom]>.<[marketName]>]>:
            - narrate format:callout <element[You cannot use this influence type on this market for another: <server.flag_expiration[influenceCooldown.weaponTrade.<[kingdom]>.<[marketName]>].from_now.formatted.color[red]>. Please try again then.]>
            - determine cancelled

        - define itemList <list[]>

        - foreach <server.flag[kingdoms.scenario-1.influence.weaponLists.<player.flag[datahold.scenario-1.influence.marketName]>]> as:amount key:item:
            - define weaponItem <[item].as[item]>
            - definemap lore:
                1: <element[Amount Required: ].color[white]><[amount].color[red]>

            - adjust def:weaponItem lore:<[lore].values>
            - adjust def:weaponItem flag:amount:<[amount]>

            - define itemList:->:<[weaponItem]>

        - wait 1t

        - run PaginatedInterface def.itemList:<[itemList]> def.player:<player> def.page:1 def.flag:viewingWeaponTrades def.title:<element[<[marketName]><&sq>s Requests]>

        on player clicks in inventory flagged:viewingWeaponTrades:
        - ratelimit <player> 1t

        - if <context.slot> == -998:
            - determine cancelled

        - if <context.item.material.name> == air:
            - determine cancelled

        - define maximumAmount <context.item.flag[amount]>
        - define marketName <script[SC1_AllianceTownNames].data_key[Names.<player.flag[datahold.scenario-1.influence.marketName]>]>

        - flag <player> datahold.scenario-1.influence.weaponMaxAmount:<[maximumAmount]>
        - flag <player> datahold.scenario-1.influence.selectedWeapon:<context.item.material.name>
        - flag <player> noChat.scenario-1.influence.weaponTrade

        - narrate format:callout <element[Please type the amount of orders of this item that you would like to fullfill for <[marketName].color[aqua]>.]>
        - narrate format:callout <element[Keep in mind that the maximum number of orders that they will accept is: <[maximumAmount].color[aqua]>.]>

        - inventory close

        on custom event id:PaginatedInvClose flagged:viewingWeaponTrades:
        - if !<player.has_flag[noChat.scenario-1.influence.weaponTrade]>:
            - determine passively cancelled

        - else:
            - stop

        - narrate format:callout <element[Transaction cancelled.]>

        - flag <player> datahold.scenario-1.influence:!
        - flag <player> noChat.scenario-1.influence.weaponTrade:!

        on player chats flagged:noChat.scenario-1.influence.weaponTrade:
        - define kingdom <player.flag[kingdom]>
        - define maximumAmount <player.flag[datahold.scenario-1.influence.weaponMaxAmount]>
        - define marketName <script[SC1_AllianceTownNames].data_key[Names.<player.flag[datahold.scenario-1.influence.marketName]>]>

        - if <context.message.to_lowercase> == cancel:
            - narrate format:callout <element[Transaction cancelled!]>

            - flag <player> datahold.scenario-1.influence:!
            - flag <player> noChat.scenario-1.influence.weaponTrade:!
            - determine cancelled

        - if !<context.message.is_integer>:
            - narrate format:callout <element[You must use only round numbers to input the amount you wish to trade. Type <&sq>cancel<&sq> to cancel this transaction.]>
            - determine cancelled

        - define tradeAmount <context.message>

        - if <[tradeAmount]> > <[maximumAmount]>:
            - narrate format:callout <element[This alliance town does not need more than: <[maximumAmount].color[red]> to fullfill its current defense needs. Type <&sq>cancel<&sq> to cancel this transaction.]>
            - determine cancelled

        - flag <player> datahold.scenario-1.influence.tradeAmount:<[tradeAmount]>

        - run TempSaveInventory def.player:<player>
        - give to:<player.inventory> SC1_TransferVaultDesignator_Item
        - adjust <player> item_slot:1

        - narrate format:callout <element[Fill an empty chest with the desired items, then click on it with the transfer vault designator to complete the weapons trade.]>
        - narrate format:callout <element[To cancel this transaction, drop the transfer vault designator.]>

        - determine cancelled

        on player drops SC1_TransferVaultDesignator_Item:
        - determine passively cancelled

        - run LoadTempInventory def.player:<player>
        - narrate format:callout <element[Transaction cancelled.]>

        - flag <player> datahold.scenario-1.influence:!
        - flag <player> noChat.scenario-1.influence.weaponTrade:!

        on player clicks block with:SC1_TransferVaultDesignator_Item:
        - determine passively cancelled

        - define kingdom <player.flag[kingdom]>
        - define marketName <script[SC1_AllianceTownNames].data_key[Names.<player.flag[datahold.scenario-1.influence.marketName]>]>

        - if !<player.has_flag[datahold.scenario-1.influence.tradeAmount]>:
            - run GenerateInternalError def.message:<element[Cannot find reference to <element[datahold.scenario-1.influence.tradeAmount].color[gray]>! Has the player<&sq>s datahold flag been tampered with?]>
            - determine cancelled

        - define tradeAmount <player.flag[datahold.scenario-1.influence.tradeAmount]>

        - if !<context.location.has_inventory>:
            - narrate format:callout <element[This item does not have an inventory. Please select a chest, barrel, shulker, or any other block capable of holding items.]>
            - determine cancelled

        - define selectedWeapon <player.flag[datahold.scenario-1.influence.selectedWeapon]>

        - if <context.location.inventory.find_all_items[<[selectedWeapon]>].size> < <[tradeAmount]>:
            - narrate format:callout <element[This block does not contain enough of the selected weapon to trade. Please take this moment to fill the container accordingly.]>
            - narrate format:callout <element[Alternatively, you can cancel this transaction by dropping the transfer vault designator.]>
            - determine cancelled

        - define tradeReward <script[SC1_WeaponData].data_key[Rewards.<[selectedWeapon]>].mul[<[tradeAmount]>].div[3]>
        - define itemsRemoved 0

        - foreach <context.location.inventory.list_contents> as:item:
            - if <[item].material.name> == <[selectedWeapon]>:
                - inventory set slot:<[loop_index]> origin:air destination:<context.location.inventory>
                - define itemsRemoved:++

            - if <[itemsRemoved]> >= <[tradeAmount]>:
                - foreach stop

        - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.markets.<[marketName]>:+:<[tradeReward]>
        - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.markets.<[marketName]>:1 if:<server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.markets.<[marketName]>].is[MORE].than[1]>
        - flag server kingdoms.scenario-1.influence.weaponLists.<[marketName]>.<[selectedWeapon]>:-:<[tradeAmount]>

        - narrate format:callout <element[<[marketName].color[aqua]> has successfully recieved the shipment. Your kingdom may send this alliance town shipments again in another 6 hours.]>

        - run LoadTempInventory def.player:<player>

        - flag <player> datahold.scenario-1.influence:!
        - flag <player> noChat.scenario-1.influence.weaponTrade:!
        - flag server influenceCooldown.weaponTrade.<[kingdom]>.<[marketName]> expire:6h

        - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>
