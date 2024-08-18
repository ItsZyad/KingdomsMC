##
## [SCENARIO I]
## This file holds all scripts relating to the trade promise sub-mechanic of the Scenario-1
## influence system.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Aug 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

SC1_TradePromise_Handler:
    type: world
    events:
        on player clicks SC1_PromiseTrade_Item in SC1_AllianceTownInfluenceActions_Interface:
        - define kingdom <player.flag[kingdom]>
        - define marketName <script[SC1_AllianceTownNames].data_key[Names.<player.flag[datahold.scenario-1.influence.marketName]>]>

        - if <server.has_flag[influenceCooldown.promiseTrade.<[kingdom]>.<[marketName]>]>:
            - narrate format:callout <element[You cannot use this influence type on this market for another: <server.flag_expiration[influenceCooldown.promiseTrade.<[kingdom]>.<[marketName]>].from_now.formatted.color[red]>. Please try again then.]>
            - determine cancelled

        - if <server.has_flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.promises.<[marketName]>]>:
            - narrate format:callout <element[Your kingdom already has an active trade promise with trade alliance. Please complete the existing trade promise before starting a new one.]>
            - determine cancelled

        - flag <player> noChat.scenario-1.influence.promiseTrade expire:1m
        - inventory close

        - narrate format:callout <element[Please type <element[(using only numbers)].color[red].bold> the amount of money you wish to promise, in trade, to this black market faction. <n> <italic>(You will have the opportunity to specify the time period over which this amount can be fullfilled.)]>

        on player chats flagged:noChat.scenario-1.influence.promiseTrade:
        - if <context.message.to_lowercase> == cancel:
            - narrate format:callout <element[Transaction cancelled!]>

            - flag <player> datahold.scenario-1.influence:!
            - flag <player> noChat.scenario-1.influence.promiseTrade:!
            - determine cancelled

        - if !<player.has_flag[datahold.scenario-1.influence.promiseAmount]>:
            - if !<context.message.is_decimal>:
                - narrate format:callout <element[You must use only numbers to input the amount you wish to promise. Type <&sq>cancel<&sq> to cancel this transaction.]>
                - determine cancelled

            - if <context.message> < 1000:
                - narrate format:callout <element[The minimum amount you can promise this alliance town is $1,000. Type <&sq>cancel<&sq> to cancel this transaction.]>
                - determine cancelled

            - if <context.message> > 100000:
                - narrate format:callout <element[The maximum amount you can promise this alliance town is $100,000. Type <&sq>cancel<&sq> to cancel this transaction.]>
                - determine cancelled

            - define promiseAmount <context.message>
            - narrate format:callout <element[Please type a period of time <element[(in hours)].color[red]> that you will need to fullfill the promised amount of: $<[promiseAmount].format_number.color[red]>]>

            - flag <player> datahold.scenario-1.influence.promiseAmount:<context.message>

        - else:
            - define kingdom <player.flag[kingdom]>
            - define promiseAmount <player.flag[datahold.scenario-1.influence.promiseAmount]>

            - if !<context.message.is_decimal>:
                - narrate format:callout <element[You must use only numbers to input the amount of time needed to carry out the trade promise. Type <&sq>cancel<&sq> to cancel this transaction.]>
                - determine cancelled

            - if <context.message> < 0.25:
                - narrate format:callout <element[The minimum amount of time that a trade promise can be carried out over is 15 mintes (0.25 hours). Type <&sq>cancel<&sq> to cancel this transaction.]>
                - determine cancelled

            - if <context.message> > 336:
                - narrate format:callout <element[The maximum amount of time that a trade promise can be carried out over is 2 weeks (336 hours). Type <&sq>cancel<&sq> to cancel this transaction.]>
                - determine cancelled

            - define promiseTime <duration[<context.message>h]>
            - define marketName <script[SC1_AllianceTownNames].data_key[Names.<player.flag[datahold.scenario-1.influence.marketName]>]>

            - narrate format:callout <element[You have <[promiseTime].formatted.color[aqua]> to fullfill a trade promise of $<[promiseAmount].format_number.color[aqua]> to <[marketName].color[aqua]>.]>
            - narrate format:callout <element[You can use the <element[/promises].color[aqua]> command to track or cancel your kingdom<&sq>s active promises.]>

            - definemap promiseMap:
                amount: <[promiseAmount]>
                expiry: <util.time_now.add[<[promiseTime]>]>
                kingdom: <[kingdom]>

            - runlater SC1_FinishTradePromise def.kingdom:<[kingdom]> def.marketName:<[marketName]> delay:<[promiseTime]> id:<[kingdom]>_<[marketName]>

            - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.promises.<script[SC1_AllianceTownNames].data_key[Names.<player.flag[datahold.scenario-1.influence.marketName]>]>:<[promiseMap]>
            - flag server influenceCooldown.promiseTrade.<[kingdom]>.<[marketName]> expire:24h
            - flag <player> datahold.scenario-1.influence:!
            - flag <player> noChat.scenario-1.influence.promiseTrade:!

        - determine cancelled


SC1_FinishTradePromise:
    type: task
    definitions: kingdom[ElementTag(String)]|marketName[ElementTag(String)]
    script:
    - define promiseAmount <server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.promises.<[marketName]>.amount]>

    - if <server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.tradeVolume.<[marketName]>]> < <[promiseAmount]>:
        - run AffectOfflinePlayers def.playerList:<[kingdom].proc[GetMembers]> def.scriptName:SC1_InformPlayerOfFailedPromise def.otherDefs:<map[marketName=<[marketName]>;amount=<[promiseAmount]>]>
        - run SC1_CancelTradePromise def.kingdom:<[kingdom]> def.marketName:<[marketName]>

        - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.tradeVolume.<[marketName]>:!
        - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>
        - stop

    - define promiseInfluence <element[10000].div[<element[<[promiseAmount].add[26000]>]>].proc[Invert].add[<element[10000].div[26000]>]>
    - run AffectOfflinePlayers def.playerList:<[kingdom].proc[GetMembers]> def.scriptName:SC1_InformPlayersOfSuccessfulPromise def.otherDefs:<map[marketName=<[marketName]>;amount=<[promiseAmount]>]>

    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.promises.<[marketName]>:!
    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.markets.<[marketName]>:+:<[promiseInfluence]>
    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.tradeVolume.<[marketName]>:!

    - foreach <proc[GetKingdomList].exclude[<[kingdom]>]>:
        - flag server kingdoms.<[value]>.scenario-1.influence.markets.<[marketName]>:-:<[promiseInfluence].div[4]>
        - flag server kingdoms.<[value]>.scenario-1.influence.markets.<[marketName]>:0 if:<server.flag[kingdoms.<[value]>.scenario-1.influence.markets.<[marketName]>].is[LESS].than[0]>

    - adjust system cancel_runlater:<[kingdom]>_<script[SC1_AllianceTownNames].data_key[Names.<[marketName]>]>
    - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>


SC1_InformPlayerOfFailedPromise:
    type: task
    definitions: _playerList[ListTag(PlayerTag)]|marketName[ElementTag(String)]|amount[ElementTag(Float)]
    script:
    - define marketName <script[SC1_AllianceTownNames].data_key[Names.<[marketName]>]>

    - narrate format:callout <element[Your kingdom failed to honor its promise to conduct trade with a value of: $<[amount].color[red]> with: <[marketName].color[red]>, and has thus lost influence with that trade alliance.]> targets:<[_playerList]>


SC1_InformPlayersOfSuccessfulPromise:
    type: task
    definitions: _playerList[ListTag(PlayerTag)]|marketName[ElementTag(String)]|amount[ElementTag(Float)]
    script:
    - define marketName <script[SC1_AllianceTownNames].data_key[Names.<[marketName]>]>

    - narrate format:callout <element[Your kingdom honored its promise to conduct trade with a value of: $<[amount].color[red]> with: <[marketName].color[red]>, and has thus gained influence with that trade alliance.]> targets:<[_playerList]>


SC1_CancelTradePromise:
    type: task
    definitions: kingdom[ElementTag(String)]|marketName[ElementTag(String)]
    script:
    - define promiseAmount <server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.promises.<[marketName]>.amount]>
    - define promiseInfluence <element[10000].div[<element[<[promiseAmount].add[26000]>]>].proc[Invert].add[<element[10000].div[26000]>]>

    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.promises.<[marketName]>:!
    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.markets.<[marketName]>:-:<[promiseInfluence].div[2]>
    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.markets.<[marketName]>:0 if:<server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.markets.<[marketName]>].is[LESS].than[0]>
    - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.tradeVolume.<[marketName]>:!

    - adjust system cancel_runlater:<[kingdom]>_<script[SC1_AllianceTownNames].data_key[Names.<[marketName]>]>
    - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>


SC1_PromiseTracker_Command:
    type: command
    name: promises
    usage: /promises
    description: Opens your kingdom's trade promise tracker.
    script:
    - if <player.has_flag[kingdom]>:
        - run SC1_PromiseTracker def.player:<player>


SC1_Promise_Item:
    type: item
    material: gold_nugget
    display name: <gold><bold>Trade Promise


SC1_PromiseTracker:
    type: task
    definitions: player[PlayerTag]
    script:
    - define kingdom <player.flag[kingdom]>
    - define promises <server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.promises].if_null[<map[]>]>
    - define promiseList <list[]>

    - foreach <[promises]> key:marketName as:promise:
        - define promiseItem <item[SC1_Promise_Item]>
        - definemap lore:
            1: <element[Promised Amount<&co> $<aqua><[promise].get[amount].format_number>]>
            2: <element[Time Remaining<&co> <[promise].get[expiry].from_now.formatted.color[red]>]>
            3: <element[Promised To<&co> <script[SC1_AllianceTownNames].data_key[Names.<[marketName]>].color[gold]>]>
            4: <element[Amount Fullfilled<&co> <green>$<server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.tradeVolume.<[marketName]>]>].format_number>

        - adjust def:promiseItem lore:<[lore].values>
        - adjust def:promiseItem flag:amount:<[promise].get[amount]>
        - adjust def:promiseItem flag:expiry:<[promise].get[expiry]>
        - adjust def:promiseItem flag:market:<[marketName]>

        - define promiseList:->:<[promiseItem]>

    - run PaginatedInterface def.itemList:<[promiseList]> def.page:1 def.player:<[player]> def.title:<element[Promise Tracker]> def.flag:viewingPromises


SC1_CancelPromise_Item:
    type: item
    material: barrier
    display name: <red><bold>Cancel Promise
    lore:
    - <red>Warning! Cancelling trade promises will result in a
    - <red>influence hit with this trade alliance.
    - <&sp>
    - <red>The larger the promised amount, the larger the influence
    - <red>hit.


SC1_PromiseOptions_Interface:
    type: inventory
    inventory: chest
    gui: true
    title: Promise Options
    slots:
    - [] [] [] [] [SC1_CancelPromise_Item] [] [] [] []


SC1_PromiseTracker_Handler:
    type: world
    events:
        on player clicks SC1_Promise_Item in PaginatedInterface_Window flagged:viewingPromises:
        - flag <player> datahold.scenario-1.influence.viewingPromise.market:<context.item.flag[market]>

        - inventory open d:SC1_PromiseOptions_Interface

        on player clicks SC1_CancelPromise_Item in SC1_PromiseOptions_Interface:
        - define marketName <player.flag[datahold.scenario-1.influence.viewingPromise.market]>
        - run SC1_CancelTradePromise def.kingdom:<player.flag[kingdom]> def.marketName:<[marketName]>
