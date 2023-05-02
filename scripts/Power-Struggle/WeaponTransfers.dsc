##
## * All scripts relating to weapon transfer menus
## * and their updating/management/player-interactions
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2021
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

## IMPORTANT NOTE:: A lot of the code in this file also doubles for the
##                  Material transfer side of things. While I'm not re-
##                  any of the code anytime soon, I may reclassify this
##                  at some point in the future.

##############################################################################

DidTransferFail:
    type: task
    definitions: target|flagName
    script:
    - if <[target].has_flag[<[flagName]>]>:
        - define kingdom <[target].flag[kingdom]>

        # Debuff amount is defined as:
        # (totalinfluence / mercinfluence) / 10

        - define debuffAmount <server.flag[kingdoms.<[kingdom]>.powerstruggle.totalInfluence].div[<server.flag[<[kingdom]>.powerstruggle.mercenaryGuild]>].div[10]>

        - flag server kingdoms.<[kingdom]>.powerstruggle.mercenaryGuild:-:<[debuffAmount]>

        # Recalculates total influence so it is representative of
        # the new average

        - run CalcTotalInfluence def:<[target].flag[kingdom]>

##############################################################################

WeaponTransferOption_Handler:
    type: world
    debug: false
    events:
        on player clicks TransferSwords in WeaponTransferSelection_Window:
        - inventory open d:TransferSwords_Window

        on player clicks TransferArmour in WeaponTransferSelection_Window:
        - inventory open d:TransferArmour_Window

        on player clicks TransferRanged in WeaponTransferSelection_Window:
        - inventory open d:TransferRanged_Window

        on player clicks Back_Influence in inventory:
        - if <list[TransferSwords_Window|TransferRanged_Window|TransferArmour_Window].parse_tag[<[parse_value].to_lowercase>].contains[<context.inventory.script.name>]>:
            - inventory open d:WeaponTransferSelection_Window

        # If the player clicks in one of the valid inventories for
        # weapon transfer then flag them with the item they want to
        # transfer and what type of item that is (melee, ranged etc.)

        on player clicks in inventory:
        - define validInventories <list[TransferSwords_Window|TransferRanged_Window|TransferArmour_Window]>

        - if <context.inventory.script.exists> && <[validInventories].parse_tag[<[parse_value].to_lowercase>].contains[<context.inventory.script.name>]>:
            - if <context.item.material.name> == air || <context.clicked_inventory.id_holder> == <player>:
                - determine cancelled

            - define kingdom <player.flag[kingdom]>

            - if <server.flag[kingdoms.<[kingdom]>.powerstruggle.influencePoints]> <= 0:
                - narrate format:callout "Your kingdom has exhasuted its influence points today"
                - determine cancelled

            - if <server.flag[kingdoms.<[kingdom]>.powerstruggle.activeTransfers].size> > 44:
                - narrate format:callout "Your kingdom has made the maximum number of transfer requests (44). Please fulfill some of them before making a new one!"
                - determine cancelled

            - if !<player.has_flag[transferData.amount]>:
                - if <server.flag[kingdoms.powerstruggleInfo.transferItems.<context.item.material.name>]> != 0:

                    - narrate format:callout "Type out (<element[using just numbers].bold>) how many orders you want to fullfill."
                    - narrate format:callout "Type cancel to end the transfer."

                    # This flag is passed onto the player chats queue
                    # below and it extracts the item.

                    - definemap tData:
                        transferType: <context.item.flag[transferType]>
                        material: <context.item.material.name>

                    - flag <player> transferData:<[tData]>
                    - inventory close

                - else:
                    - narrate format:callout "There are no present orders for this type of item!"

            - else:
                - narrate format:callout "You are already making a weapon transfer transaction"

        on player chats flagged:transferData.transferType:
        - if <context.message.to_lowercase> == cancel:
            - flag <player> transferData:!
            - narrate format:callout "Transfer cancelled!"

        - else:
            - if !<context.message.is_integer>:
                - narrate format:callout "Please enter a valid order amount. (numbers only!)"
                - determine cancelled

            - define kingdom <player.flag[kingdom]>

            # If player does not cancel the transaction then extract
            # the item transfer type and material name and add to a
            # new flag which also has the amount of items to be tran-
            # sfered

            - define transferType <player.flag[transferData.transferType]>
            - define transferItem <player.flag[transferData.material]>

            - if <server.flag[kingdoms.powerstruggleInfo.transferItems.<[transferItem]>].is[OR_MORE].than[<context.message>]>:

                - flag <player> transferData.amount:<context.message>
                #- flag <player> influenceType:<list[weapons|mercenary]>

                - define kingdom <player.flag[kingdom]>
                - define sameMaterialTransfers <server.flag[kingdoms.<[kingdom]>.powerstruggle.activeTransfers].values.parse_tag[<[parse_value].values.contains[<player.flag[transferData].get[material]>]>].exclude[false].size>
                - define transferID <player.name>-<player.flag[transferData].get[material]><[sameMaterialTransfers]>
                - flag server <[kingdom]>.powerstruggle.activeTransfers.<[transferID]>.influenceType:<player.flag[transferData].get[transferType]>
                - flag server <[kingdom]>.powerstruggle.activeTransfers.<[transferID]>.material:<player.flag[transferData].get[material]>
                - flag server <[kingdom]>.powerstruggle.activeTransfers.<[transferID]>.amount:<context.message>
                - flag server <[kingdom]>.powerstruggle.activeTransfers.<[transferID]>.due:<util.time_now.add[1d]>
                - flag server <[kingdom]>.powerstruggle.activeTransfers.<[transferID]>.madeBy:<player>

                - runlater RemoveTransferAfterDue def:<[transferID]>|<[kingdom]> id:<[transferID]>

                # Just checks if the player still has the
                # amount/transferData subflag (which is deleted
                # if they go through) with the transaction and completed

                - runlater DidTransferFail delay:24h def:<player>|transferData.amount

                - if <[transferType]> != masons:
                    - narrate format:callout "To fullfill this order, go to the Fyndalin City Militia office and hand the item(s) over to General Thorvald within 24 hours"

                - else:
                    - narrate format:callout "You have 24 hours to place a sign on the chest you would like to use as a transfer vault."

                - flag server kingdoms.<[kingdom]>.powerstruggle.influencePoints:-:1

                - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>

            - else:
                - narrate format:callout "There is not enough demand for you to fullfill that many orders!"

        - flag <player> enteringTransferData:!
        - determine cancelled

        on player clicks WeaponTransfer_MercInfluence in MercenaryInfluence_Window:
        - ratelimit <player> 3t

        - define kingdom <player.flag[kingdom]>

        - if <server.flag[kingdoms.<[kingdom]>.powerstruggle.influencePoints].is[MORE].than[0]>:
            - define influenceTypeRaw <context.inventory.script.name.split[Influence].get[1]>

            - if !<player.has_flag[influenceCooldown.<[influenceTypeRaw]>]>:
                - inventory open d:WeaponTransferSelection_Window

        - else:
            - inventory close
            - narrate format:callout "Your kingdom has exhausted its influence actions for today <&co><&bs>"

RemoveTransferAfterDue:
    type: task
    definitions: transferID|kingdom
    script:
    - flag server <[kingdom]>.powerstruggle.activeTransfers.<[transferID]>:!

InitiateWeaponTransferWindow:
    type: world
    debug: false
    events:
        on player opens inventory:
        # If the player opens one of the weapon transfer windows
        # loop through every item in the GUI and apply a
        # description to them showing if there are any
        # available orders and how many. If there are none then
        # just show 'No available orders'

        - define validInventories <list[TransferSwords_Window|TransferRanged_Window|TransferArmour_Window]>

        - if <context.inventory.script.exists> && <[validInventories].contains[<context.inventory.script.name>]>:
            - foreach <context.inventory.list_contents.exclude[<item[Back_influence]>]>:
                - define amountAvailable <server.flag[kingdoms.powerstruggleInfo.transferItems.<[value].material.name>]>

                - if <[amountAvailable].is_integer> && <[amountAvailable]> != 0:
                    - inventory adjust d:<context.inventory> slot:<[loop_index]> "lore:<aqua>Available Orders<&co> <white><server.flag[kingdoms.powerstruggleInfo.transferItems.<[value].material.name>]>"

                - else:
                    - inventory adjust d:<context.inventory> slot:<[loop_index]> "lore:<red>No orders available"
