##
## * Everything related to INFLUENCING the black market
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2021
## @Script Ver: v0.4
##
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

## NOTE: This may need to be split across a few files later...

BlackMarketInfluenceOptions_Window:
    type: inventory
    title: "Influence Black Market Faction"
    inventory: chest
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [PromiseTrade] [] [FriendshipLetter] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [Back_Influence] [] [] [] []

PromiseTrade:
    type: item
    material: barrel
    display name: "Promise Trade Volume"
    lore:
    - "Promising a faction that you would meet a certain"
    - "trade quota with them is a surefire way of ensuring"
    - "their loyalty and preference towards your kingdom."

FriendshipLetter:
    type: item
    material: paper
    display name: "Write a letter of support"
    lore:
    - "Sometimes the power of words can be more potent"
    - "than that of money or the sword."
    - "A well-worded letter to the faction boss may do"
    - "much more than one would expect..."
    - "<red><bold>Note: This action doesn't cost any influence"
    - "<red><bold>points but has a hefty cooldown."

BMInfluenceRecalculate:
    type: task
    definitions: amount|excess|faction
    script:
    - narrate WIP!

BlackMarketInfluence_Handler:
    type: world
    events:
        on player clicks item in BlackMarketInfluence_Window:
        - if <context.item.material.name> != air || <context.item.script.name> != Bribe_Influence:
            - flag <player> factionInfo:<context.item.flag[factionInfo]>

            - inventory open d:BlackMarketInfluenceOptions_Window

        on player clicks PromiseTrade in BlackMarketInfluenceOptions_Window:
        - define kingdom <player.flag[kingdom]>

        - if <server.flag[kingdoms.<[kingdom]>.powerstruggle.influencePoints].is[OR_MORE].than[0]>:
            - inventory close
            - flag <player> noChat.BMInf expire:1m

            - narrate format:callout "Please type (<bold>Using numbers only!) <&6>the amount of money you wish to promise, in trade, to this black market faction."

        - else:
            - narrate format:callout "You have exhausted your influence points today."

        on player chats:

        ## NOTE: Anything related to the faction numbers specified in the
        ##       factionInfo flag must be done in this queue or the one
        ##       where the flag is defined.

        # If the player has noChat and factionInfo flags;

        - if <player.has_flag[noChat.BMInf]> && <player.has_flag[factionInfo]>:

            - define kingdom <player.flag[kingdom]>
            #- narrate format:debug FAC:<player.flag[factionInfo]>

            - if !<server.has_flag[promisedTrade<[kingdom]>]>:
                - flag server promisedTrade<[kingdom]>:<list>

            #- narrate format:debug "promisedTrade Flag: <server.flag[promisedTrade<[kingdom]>]>"

            # and if the kingdom doesn't already have a trade commitment with
            # this exact faction;

            - define hasCommitment true

            - foreach <server.flag[promisedTrade<[kingdom]>]>:
                - if <[value].get[2]> != <player.flag[factionInfo].get[1]>:
                    - define hasCommitment false

            - if <[hasCommitment]>:

                # and the amount specified is actually a number;

                #- narrate format:debug <context.message.is_integer>

                - if <context.message.is_integer>:
                    - define amount <context.message>

                    # If the promised amount is less than half of the kingdom's
                    # balance then allow the transaction

                    - if <[amount].is[OR_MORE].than[<server.flag[kingdoms.<[kingdom]>.balance].div[2]>]>:

                        # promisedTrade example:
                        # FLAG :: promisedTradeCentran <-- [6000,syndicates]
                        #
                        # Meaning the first list item is the promised trade
                        # volume and the second list item is to whom

                        # TODO: come back later and fold the promisedTrade flag in the kingdoms flag because this is just disgusting.

                        - flag server promisedTrade<[kingdom]>:<server.flag[promisedTrade<[kingdom]>].include_single[<list[<[amount]>|<player.flag[factionInfo].get[1]>|<[amount]>]>]>
                        - flag server kingdoms.<[kingdom]>.powerstruggle.influencePoints:--
                        - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>

                        - narrate format:callout "You are now required to fullfill <blue>$<server.flag[promisedTrade<[kingdom]>].last.get[1]><&6> of trade with <red><bold><server.flag[kingdoms.factionInfo.<server.flag[promisedTrade<[kingdom]>].last.get[2]>.name]><&6> before you can use this action again."

                    - else:
                        - narrate format:callout "You must have at least <blue>$<[amount]> <&6>in your kingdom bank!"

                - else if <context.message.to_lowercase> == cancel:
                    - flag player noChat:!
                    - narrate format:callout "Cancelled influence action."

                - else:
                    - narrate format:callout "That is not a valid number! Try again or type 'cancel'."

            - else:
                - narrate format:callout "You already have an ongoing trade commitment with this black market faction!"

            - flag player factionInfo:!
            - flag player noChat:!
            - determine cancelled

        on player clicks FriendshipLetter in BlackMarketInfluenceOptions_Window:
        - define kingdom <player.flag[kingdom]>

        - if <server.flag[kingdoms.<[kingdom]>.powerstruggle.influencePoints]> <= 0:
            - narrate format:callout "Your kingdom has exhasuted its influence points today"
            - determine cancelled

        - if <server.flag[FriendshipLetterCooldown<[kingdom]>]>:
            - inventory adjust d:<context.inventory> slot:<context.slot> "lore:<context.item.lore>|<red>Your kingdom has already used this influence method recently|<white>Use again in: <red><server.flag_expiration[FriendshipLetterCooldown<[kingdom]>].from_now.formatted>"

        # TODO: later make factionInfo a dataHold flag

        - else:
            - flag server FriendshipLetterCooldown<[kingdom]> expire:72h
            - define influenceAmount <util.random.decimal[0.005].to[<util.random.decimal[0.007].to[0.1]>]>
            - define faction <player.flag[factionInfo].get[1]>

            - flag server kingdoms.<[kingdom]>.powerstruggle.BMFactionInfluence.<[faction]>:+:<[influenceAmount]>

            - narrate format:callout "A letter of support has been sent to the boss of: <server.flag[kingdoms.factionInfo.<[faction]>.name]>"

        - flag player factionInfo:!
        - determine cancelled