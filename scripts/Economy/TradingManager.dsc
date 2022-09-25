##ignorewarning invalid_data_line_quotes

TradeInitiate_Command:
    type: command
    name: trade
    usage: /trade
    permission: kingdoms.trade
    description: Used to initiate manual trade between players and kingdoms
    script:
    - define target <context.args.get[1].as[player]>

    - if <[target].as[player].if_null[false]> || <[target].as[player].is_online>:
        - if <[target].as[player]> != <player>:

            # Note: TradeInitiator is the flag which indicates that this player has initiated the trade
            #       while TradeInitiate is the flag attached to the target player so I can have a reference
            #       on their side of who initiated the trade.

            - flag player TradeInitiator:<player>
            - flag player TradeTarget:<[target]>
            - flag <[target]> TradeTarget:<[target]>
            - flag <[target]> TradeInitiator:<player>

            - flag player TradeRequest expire:60s
            - runlater TimedClearTradeFlags delay:60s def:<player>

            - narrate targets:<player> format:callout "You have requested trade from player: <[target].name.color[red].bold>. They have 60 seconds to respond."
            - narrate targets:<[target]> format:callout "<player.name.color[red].bold> has requested a trade. Type <&l>/tradeaccept <&6>if you wish to trade. Type <&l>/tradedecline <&6>if not."

        - else:
            - narrate format:callout "You seem lonely... Do you need a friend to trade with?"

    - else:
        - narrate format:callout "You have not specified a player to trade with."

TradeAccept_Command:
    type: command
    name: tradeaccept
    usage: /tradeaccept
    #permission: kingdoms.trade.accept
    description: Accepts a manual trade deal
    script:
    - if <context.args.size.is[OR_MORE].than[1]>:
        - define initiator <context.args.get[1].as[player]>

        - if !<[initiator].has_flag[TradeRequest].if_null[true]>:
            - narrate format:callout "This is not a valid trade partner. Are you sure the trade request has not expired?"
            - determine cancelled

        - narrate format:debug <[initiator]>

        - if <[initiator].has_flag[TradeInitiator]>:
            - if <player.has_flag[TradeTarget]>:
                - define tradeWindow <proc[TradeWindowClone].context[TradeDeal]>

                - inventory open d:<[tradeWindow]>
                - inventory open d:<[tradeWindow]> player:<[initiator]>

                - narrate format:debug FLG:<player.flag[TradeDeal]>

                - flag <[initiator]> TradeRequest:!
                - flag player currentlyTradingWith:<[initiator]>
                - flag <[initiator]> currentlyTradingWith:<player>

            - else:
                - narrate format:callout "No one has initiated a trade deal with you yet!"

TradeDecline_Command:
    type: command
    name: tradedecline
    usage: /tradedecline
    #permission: kingdoms.trade.decline
    description: Refuses a manual trade deal
    script:
    - if <context.args.size.is[OR_MORE].than[1]>:
        - define initiator <context.args.get[1].as[player]>

        - if !<[initiator].has_flag[TradeRequest].if_null[true]>:
            - narrate format:callout "This is not a valid trade partner. Are you sure the trade request has not expired?"
            - determine cancelled

        - if <[initiator].has_flag[TradeInitiator]>:
            - if <player.has_flag[TradeTarget]>:
                - narrate target:<[initiator]> format:callout "<player.name> has refused to trade with you!"

            - else:
                - narrate format:callout "No one has initiated a trade deal with you yet!"

KingdomStockpile:
    type: inventory
    title: "Kingdom Stockpile"
    inventory: chest
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []

TradeDeal:
    type: inventory
    title: "Initiate Trade Deal"
    inventory: chest
    slots:
    - [<item[AcceptDeal]>] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [DealSeparator] [DealSeparator] [DealSeparator] [DealSeparator] [DealSeparator] [DealSeparator] [DealSeparator] [DealSeparator] [DealSeparator]
    - [] [] [] [] [] [] [] [] []
    - [<item[RejectDeal]>] [] [] [] [] [] [] [] []

AcceptDeal:
    type: item
    material: green_wool
    display name: "<dark_green><bold>Accept Deal"

RejectDeal:
    type: item
    material: red_wool
    display name: "<red><bold>Reject Deal"

DealSeparator:
    type: item
    material: red_stained_glass_pane
    display name: <&sp>

TradeWindowClone:
    type: procedure
    definitions: inventoryName
    script:
    - define tempTradeInv <inventory[TradeDeal]>

    - determine <[tempTradeInv]>

TradeDealHandler:
    type: world
    events:
        on player clicks in KingdomStockpile:
        - narrate <inventory[KingdomStockpile]>

        on player closes TradeDeal:
        - define initiator <player.flag[TradeInitiator]>
        - define target <player.flag[TradeTarget]>

        - repeat from:2 17:
            - if <context.inventory.slot[<[value]>].material.name> != air:
                - give to:<[target].inventory> <context.inventory.slot[<[value]>]>
                - take from:<context.inventory> slot:<[value]>

        - repeat from:28 45:
            - if <context.inventory.slot[<[value]>].material.name> != air:
                # excludes the reject deal item so the player doesn't get it too
                - if <context.inventory.slot[<[value]>].item.script.name> != rejectdeal:
                    - give to:<[initiator].inventory> <context.inventory.slot[<[value]>]>
                    - take from:<context.inventory> slot:<[value]>

        - if <player.flag[TradeInitiator]> == <player>:
            - flag player TradeInitiator:!
            - flag <player.flag[currentlyTradingWith]> TradeTarget:!

        - else:
            - flag <player.flag[currentlyTradingWith]> TradeInitiator:!
            - flag <player> TradeTarget:!

        - inventory close player:<player.flag[CurrentlyTradingWith]>

        - flag <player.flag[currentlyTradingWith]> currentlyTradingWith:!
        - flag player currentlyTradingWith:!

        on player clicks AcceptDeal in TradeDeal:
        - ratelimit <player> 10t

        - flag player TradeDeal:Accept
        - define otherPlayer <player.flag[CurrentlyTradingWith]>
        - define initiator <player.flag[TradeInitiator]>
        - define target <player.flag[TradeTarget]>

        - narrate format:debug INT:<[initiator].name>
        - narrate format:debug TAR:<[target].name>
        - narrate format:debug OTH:<[otherPlayer].name>

        - if <[otherPlayer].has_flag[TradeDeal]> && <[otherPlayer].flag[TradeDeal]> == Accept:
            - narrate format:debug <[otherPlayer].flag[TradeDeal]>

            - repeat from:2 17:
                - if <context.inventory.slot[<[value]>].material.name> != air:
                    - give to:<[target].inventory> <context.inventory.slot[<[value]>]>
                    - take from:<context.inventory> slot:<[value]>

            - repeat from:28 45:
                - if <context.inventory.slot[<[value]>].material.name> != air:
                    # excludes the reject deal item so the player doesn't get it too
                    - if <context.inventory.slot[<[value]>].item.script.name> != rejectdeal:
                        - give to:<[initiator].inventory> <context.inventory.slot[<[value]>]>
                        - take from:<context.inventory> slot:<[value]>

            - inventory close player:<[otherPlayer]>
            - inventory close
            - flag <player> TradeDeal:!
            - flag <[otherPlayer]> TradeDeal:!
            - inject ClearTradeFlags

        - narrate format:callout targets:<player>|<[otherPlayer]> "<bold>Player: <element[<player.name>].color[green]> has accepted the deal!"
        - narrate format:callout targets:<[otherPlayer]> "<bold>If you accept the deal too, it will got through."

        - determine cancelled

        on player clicks RejectDeal in TradeDeal:
        - ratelimit <player> 10t

        - flag player TradeDeal:Reject
        - define otherPlayer <player.flag[CurrentlyTradingWith]>
        - define initiator <player.flag[TradeInitiator]>
        - define target <player.flag[TradeTarget]>

        - repeat from:2 17:
            - if <context.inventory.slot[<[value]>].material.name> != air:
                - give to:<[target].inventory> <context.inventory.slot[<[value]>]>
                - take from:<context.inventory> slot:<[value]>

        - repeat from:28 45:
            - if <context.inventory.slot[<[value]>].material.name> != air:
                # excludes the reject deal item so the player doesn't get it too
                - if <context.inventory.slot[<[value]>].item.script.name> != rejectdeal:
                    - give to:<[initiator].inventory> <context.inventory.slot[<[value]>]>
                    - take from:<context.inventory> slot:<[value]>

        - if <[otherPlayer].has_flag[TradeDeal]> && <[otherPlayer].flag[TradeDeal]> == Reject:
            - narrate format:debug <[otherPlayer].flag[TradeDeal]>

            - inventory close player:<player.flag[CurrentlyTradingWith]>
            - inventory close
            - flag <player> TradeDeal:!
            - flag <[otherPlayer]> TradeDeal:!
            - inject ClearTradeFlags

        - narrate format:callout targets:<player>|<player.flag[CurrentlyTradingWith]> "<bold>Player: <element[<player.name>].color[red]> has not accepted the deal!"
        - narrate format:callout targets:<[otherPlayer]> "<bold>If you reject the deal too, it will be cancelled."

        - determine cancelled

        on player clicks in TradeDeal with:*:
        - if <context.is_shift_click>:
            - define initiator <player.flag[TradeInitiator]>
            - define target <player.flag[TradeTarget]>
            - define canStack false

            - if <context.slot.is[OR_MORE].than[46]>:
                - if <[initiator]> == <player>:
                    - repeat from:2 17:
                        - if <context.inventory.slot[<[value]>].stacks[<context.item>]>:
                            - define canStack true
                            - repeat stop

                - else:
                    - repeat from:28 45:
                        - else if <context.inventory.slot[<[value]>].stacks[<context.item>]>:
                            - if <context.inventory.slot[<[value]>].item.script.name.if_null[true]> != rejectdeal:
                                - define canStack true
                                - repeat stop

            - if !<[canStack]>:
                - determine cancelled

        - else:
            - inject TradeDealClickEvent

        on player drags in TradeDeal:
        - inject TradeDealClickEvent

        on player clicks DealSeparator in TradeDeal:
        - determine passively cancelled

TradeDealClickEvent:
    type: task
    script:
    - if !<context.item.material.name.advanced_matches[*_wool]>:
        - if <context.raw_slot.is[MORE].than[1]> && <context.raw_slot.is[OR_LESS].than[18]>:
            - if <player.flag[TradeTarget]> == <player>:
                - narrate format:callout "You must use the bottom section of the trade window."
                - determine passively cancelled

        - else if <context.raw_slot.is[MORE].than[27]> && <context.raw_slot.is[OR_LESS].than[45]>:
            - if <player.flag[TradeTarget]> != <player>:
                - narrate format:callout "You must use the top section of the trade window."
                - determine passively cancelled

TimedClearTradeFlags:
    type: task
    definitions: player
    script:
    - if <[player].has_flag[TradeRequest]>:
        - narrate format:callout targets:<[player]> "Trade request to: <player.flag[TradeTarget].name.color[red].bold> has expired!"
        - run ClearTradeFlags

ClearTradeFlags:
    type: task
    script:
    - flag <player> TradeInitiator:!
    - flag <player> TradeTarget:!
    - flag <player> TradeDeal:!
    - flag <player.flag[CurrentlyTradingWith]> TradeInitiator:!
    - flag <player.flag[CurrentlyTradingWith]> TradeTarget:!
    - flag <player.flag[CurrentlyTradingWith]> TradeDeal:!

    - flag <player.flag[CurrentlyTradingWith]> currentlyTradingWith:!
    - flag <player> CurrentlyTradingWith:!
