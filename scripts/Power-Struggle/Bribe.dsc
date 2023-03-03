##
## * A handler for bribe-related influence actions
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: May/Jun 2021
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

Bribe_Config:
    type: data
    minBribe: 6000

Bribe_Handler:
    type: world
    events:
        on player clicks Bribe_Influence in inventory:
        - ratelimit <player> 1t

        - define influenceTypeRaw <context.inventory.script.name.split[Influence].get[1]>
        - yaml load:powerstruggle.yml id:ps

        # If the kingdom has daily influences left and the player
        # does not have a cooldown then close the window and
        # allow the player to type in an amount to bribe

        - if <yaml[ps].read[<player.flag[kingdom]>.dailyinfluences].is[MORE].than[0]>:
            - if !<player.has_flag[influenceCooldown.<[influenceTypeRaw]>]>:
                - flag <player> noChat.bribe.influenceType:<[influenceTypeRaw]> expire:1m
                - inventory close

                - narrate format:callout "Please type <element[(using only numbers)].color[red].bold> the amount you wish to give. Type 'cancel' to undo this transaction."

        # If the player is still subject to a cooldown then add
        # a line to the description of the bribe icon which tells
        # them how long they need to wait

            - else:
                - inventory adjust slot:<context.slot> d:<context.inventory> "lore:<context.item.lore>|<red>Use Again in: <red><player.flag_expiration[influenceCooldown.<[influenceTypeRaw].to_titlecase>].from_now.formatted>"

        - else:
            - inventory close
            - narrate format:callout "Your kingdom has exhausted its influence actions for today <&co><&bs>"

        on player chats flagged:noChat.bribe:
        - if <context.message.to_lowercase> == cancel:
            - narrate format:callout "Transaction cancelled!"
            - flag player bribeAmount:!
            - flag player noChat.bribe:!
            - determine cancelled

        - define kingdom <player.flag[kingdom]>
        - define influenceType <player.flag[noChat.bribe.influenceType]>
        - yaml load:kingdoms.yml id:kingdoms
        - yaml load:powerstruggle.yml id:ps

        - if <context.message.is_integer>:
            - flag player bribeAmount:<context.message>

        - else:
            - narrate format:callout "The value you have entered is not a number! Please check that you have not any any non-number values in your input and try again."
            - narrate format:callout "You may also type 'cancel' to undo this transaction."
            - determine cancelled

        - define minBribe <script[Bribe_Config].data_key[minBribe]>
        - define bribeAmount <player.flag[bribeAmount]>

        # If the bribe amount in less than the kingdom's balance and the minimum bribe amount
        - if <yaml[kingdoms].read[<[kingdom]>.balance].is[OR_MORE].than[<[bribeAmount]>]>:
            - if <[bribeAmount].is[OR_MORE].than[<[minBribe]>]>:

                - define influenceTarget citypopulation
                - choose <[influenceType]>:
                    - case mercenary:
                        - define influenceTarget mercenaryguild
                    - case government:
                        - define influenceTarget fyndalingovt
                    - case masons:
                        - define influenceTarget masonsguild

                # If player doesn't have a cooldown for influence
                # actions then add influence to the target faction
                # using the baseValue equation:
                # y = (0.35(log(1.09 / 1200))x)^2 / 19

                - if !<player.has_flag[influenceCooldown.<[influenceType]>]>:
                    - define baseValue <element[0.35].mul[<element[1.09].div[1200].mul[<[bribeAmount]>].log[10].power[2]>].div[19]>

                    - yaml id:ps set <[kingdom]>.<[influenceTarget]>:+:<[baseValue].round_to_precision[0.001]>
                    - yaml id:kingdoms set <[kingdom]>.balance:-:<[bribeAmount]>
                    - yaml id:ps set <[kingdom]>.dailyinfluences:-:1

                    - narrate format:callout "An envoy has been sent containing the funds. Please wait 10 hours before sending another."

                    - flag <player> influenceCooldown.<[influenceType].to_titlecase> expire:10h

                - else:
                    - narrate format:callout "Please wait another <white><player.flag_expiration[influenceCooldown<[influenceType].to_titlecase>].from_now.formatted> <&6>before sending another influence action in this category."

            - else:
                - narrate format:callout "The minimum amount you can give in a bribe is: <red>$<[minBribe]>"

        - else:
            - narrate format:callout "There is not enough money in your kingdom's bank to complete this transaction!"

        # Save and unload yaml

        - yaml savefile:kingdoms.yml id:kingdoms
        - yaml savefile:powerstruggle.yml id:ps
        - yaml id:kingdoms unload
        - yaml id:ps unload

        - run CalcTotalInfluence def:<[kingdom]>
        - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>

        - flag player bribeAmount:!
        - flag player noChat:!
        - determine cancelled