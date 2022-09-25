##
## * A set of scripts relating to the first significant player-
## * NPC interaction in Kingdoms which is in charge of handling
## * kingdom transfers of weapons to the Fyndalin rump army
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2021
## @Update 1: Jul 2022
## @Script Ver: v0.9
##
## ----------------END HEADER-----------------

generalt:
    type: format
    format: <green>General Thorvald:: <yellow><[text]>

GeneralThorvald:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:proximity state:true radius:2
    interact scripts:
    - GeneralThorvald_I

# NOTE: THERE IS A GOOD CHANCE THIS WILL NEED TO BE REWRITTEN
#       DOWN THE LINE BECAUSE I FEEL LIKE THIS MAY BECOME UN-
#       MAINTAINABLE AFTER A WHILE.

# TODO: Add if case which handles if the player clicks yes but doesn't have the agreed-upon items

GeneralThorvald_I:
    type: interact
    steps:
        1:
            click trigger:
                script:
                - engage

                - define transferAmount <player.flag[transferData].get[amount]>
                - define transferItem <player.flag[transferData].get[material]>
                - define kingdom <player.flag[kingdom]>
                - define kingdomRealName <script[KingdomRealShortNames].data_key[<[kingdom]>]>

                - if <player.has_flag[transferData.amount]>:
                    - chat range:4 "Ah! I gather you are the representative from <[kingdomRealName]>."
                    - chat range:4 "Do you have the agreed-upon goods?"

                    - define clickableList <list[]>

                    - clickable save:yes_delivery until:1m usages:1:
                        - foreach <[clickableList]>:
                            - clickable cancel:<[value]>

                        - if <player.inventory.contains_item[<[transferItem]>]>:

                            - define itemQuantity <player.inventory.quantity_item[<[transferItem]>]>

                            - if <[itemQuantity].is[OR_MORE].than[<[transferAmount]>]>:
                                - random:
                                    - chat range:4 "Wonderful! We owe a debt of gratitude to <[kingdomRealName]>, thank you."
                                    - chat range:4 "Thank you for your help! We'll definitely be keeping your generosity in mind for the future."

                                - take from:<player.inventory> item:<[transferItem]> quantity:<[transferAmount]>
                                - run ChestTransferInfluenceCalc def:<player>

                            - else if <[itemQuantity]> < <[transferAmount]>:

                                - define remainingQuantity <[transferAmount].sub[<[itemQuantity]>]>

                                - random:
                                    - chat range:4 "This isn't the amount we agreed on! I'll take these for now but come back with the rest later!"
                                    - chat range:4 "Very well, I'll take these for now but remember, you still have <[remainingQuantity].as_element.color[red]> of these left to deliver!"

                                - narrate format:callout "Note! You will not gain any influence until the <element[entire].underline> shipment is fullfilled!"

                                - take from:<player.inventory> item:<[transferItem]> quantity:<[itemQuantity]>

                                # Reduce the amount of orders the kingdom must fullfill accordingly
                                - flag <player> transferData.amount:<[remainingQuantity]>

                    - clickable save:no_delivery until:1m usages:1:
                        - chat range:4 "Very well then... what shall we speak of?"

                        - foreach <[clickableList]>:
                            - clickable cancel:<[value]>

                        - clickable save:cancel_delivery until:1m usages:1:
                            - random:
                                - chat range:4 "Hrm... Very well then, but I won't be forgetting this..."
                                - chat range:4 "Fine then, I suppose we'll have to find another supplier..."

                            # Todo for later: Add a limit to the amount of times you can do this
                            # Todo as well: Add a negative influence hit to this action

                            - flag <player> transferData:!

                        - clickable save:reneg_delivery until:1m usages:1:
                            - narrate WIP

                        - narrate <&sp>
                        - narrate <bold>OPTIONS<&co>
                        - narrate format:dialogueoption "<element[<&dq>We need to renegotiate the terms of this delivery.<&dq>].on_click[<entry[reneg_delivery].command>]>"
                        - narrate format:dialogueoption "<element[<&dq>I think we may need to cancel this deal...<&dq>].on_click[<entry[cancel_delivery].command>]>"

                    - define clickableList:->:<entry[yes_delivery].id>
                    - define clickableList:->:<entry[no_delivery].id>

                    - narrate <&sp>
                    - narrate <bold>OPTIONS<&co>
                    - narrate format:dialogueoption "<element[<&dq>Yes, sir. Here you go;<&dq>].on_click[<entry[yes_delivery].command>]>"
                    - narrate format:dialogueoption "<element[<&dq>No actually, I am here for other business.].on_click[<entry[no_delivery].command>]>"
                    - narrate <&sp>

                - disengage

# NOTE: IN FUTURE I MAY NEED TO ADD A COOLDOWN TO WEAPONS TRANSFERS
#       WHICH I SUGGEST SHOULD BE DONE BY ADDING A FLAG TO THE ACTUAL
#       POWERSTRUGGLE.YML FILE ITSELF AND THEN HAVING A TIMEOUT WITH
#       THE 'RUNLATER' COMMAND WHICH REMOVES IT WHEN THE COOLDOWN EXPIRES

ChestTransferInfluenceCalc:
    type: task
    definitions: player
    script:
    - define orderAmount <[player].flag[transferData].get[amount]>
    - define orderItem <[player].flag[transferData].get[material]>
    - define kingdom <[player].flag[kingdom]>

    # The influence equation for weapon transfers is:
    # infl = ln(5grad / (amount - 5grad))

    - define influenceGradient <script[ItemGradientData].data_key[<[orderItem]>]>
    - define fiveGrad <element[5].mul[<[influenceGradient]>]>

    #- narrate format:debug <[fiveGrad]>
    #- narrate <[orderAmount].add[<[fiveGrad]>]>

    - define influenceEquation <[fiveGrad].div[<[fiveGrad].sub[<[orderAmount]>]>].log[<util.e>]>
    #- define influenceEquation <element[1].sub[<[fiveGrad].div[<util.e.power[]>]>]>

    - narrate format:debug "Influence<&co> <[influenceEquation]>"

    # Reduce order amounts, daily influences + add
    # required influence to militia guild

    - ~yaml load:powerstruggle.yml id:ps

    - yaml id:ps set <[kingdom]>.mercenaryguild:+:<[influenceEquation]>
    - yaml id:ps set transferItemsToday.<[orderItem]>:-:<[orderAmount]>

    - if <yaml[ps].read[<[kingdom]>.mercenaryguild].is[MORE].than[1]>:
        - yaml id:ps set <[kingdom]>.mercenaryguild:1

    - ~yaml savefile:powerstruggle.yml id:ps
    - yaml unload id:ps

    - ~run CalcTotalInfluence def:<[kingdom]>
    - run SidebarLoader def.target:<server.flag[<[kingdom]>].get[members].include[<server.online_ops>]>

    - flag player transferData:!
    - flag player influenceType:!

