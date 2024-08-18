##
## [SCENARIO I]
## This file holds all of the scripts relating to the bribing sub-mechanic of the Scenario-1
## influence system.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Aug 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

SC1_Bribe_Handler:
    type: world
    events:
        on player clicks SC1_BribeInfluence_Item in SC1_AllianceTownInfluenceActions_Interface:
        - define kingdom <player.flag[kingdom]>

        - if <server.has_flag[influenceCooldown.bribe.<[kingdom]>]>:
            - narrate format:callout <element[You cannot use this influence type for another: <server.flag_expiration[influenceCooldown.bribe.<[kingdom]>].from_now.formatted.color[red]>. Please try again then.]>
            - determine cancelled

        - flag <player> noChat.scenario-1.influence.bribe expire:1m
        - inventory close

        - narrate format:callout <element[Please type <element[(using only numbers)].color[red].bold> the amount you wish to give. Type <&sq>cancel<&sq> to undo this transaction.]>

        on player chats flagged:noChat.scenario-1.influence.bribe:
        - if <context.message.to_lowercase> == cancel:
            - narrate format:callout <element[Transaction cancelled!]>

            - flag <player> datahold.scenario-1.influence:!
            - flag <player> noChat.scenario-1.influence.bribe:!
            - determine cancelled

        - if !<context.message.is_decimal>:
            - narrate format:callout <element[You must use only numbers to input the amount you wish to give. Type <&sq>cancel<&sq> to cancel this transaction.]>
            - determine cancelled

        - define bribeAmount <context.message>

        - if <[bribeAmount]> < 100:
            - narrate format:callout <element[The minimum amount you can give this alliance town is $100.]>
            - determine cancelled

        - define kingdom <player.flag[kingdom]>
        - define marketName <player.flag[datahold.scenario-1.influence.marketName]>

        - if <[kingdom].proc[GetBalance]> < <[bribeAmount]>:
            - narrate format:callout <element[Your kingdom does not have enough money to disburse a <&dq>gift<&dq> to this alliance town.]>
            - determine cancelled

        # Bribe-to-influence equation:
        # y = -(20,000 / x + 50,000) + 0.4
        - define bribeInfluence <element[<element[20000].div[<[bribeAmount].add[50000]>]>].proc[Invert].add[0.4]>

        - run SubBalance def.kingdom:<[kingdom]> def.amount:<[bribeAmount]>

        - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.markets.<[marketName]>:+:<[bribeInfluence]>
        - flag server influenceCooldown.bribe.<[kingdom]> expire:12h

        - narrate format:callout <element[An envoy has been sent containing the funds. Please wait <server.flag_expiration[influenceCooldown.bribe.<[kingdom]>].from_now.formatted.color[aqua]> before sending another to <element[any].bold> alliance.]>

        - foreach <proc[GetKingdomList].exclude[<[kingdom]>]>:
            - flag server kingdoms.<[value]>.scenario-1.influence.markets.<[marketName]>:-:<[bribeInfluence].div[4]>
            - flag server kingdoms.<[value]>.scenario-1.influence.markets.<[marketName]>:0 if:<server.flag[kingdoms.<[value]>.scenario-1.influence.markets.<[marketName]>].is[LESS].than[0]>

        - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>

        - flag <player> noChat.scenario-1.influence.bribe:!
        - flag <player> datahold.scenario-1.influence:!
        - determine cancelled
