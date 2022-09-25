##
## * Scripts in charge of handling material transfers
## * to the Fyndalin Masons guild
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2021
## @Updated: Jul 2022
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

MaterialTransferOption_Handler:
    type: world
    events:
        on player clicks MaterialTransfer_MasonInfluence in MasonsInfluence_Window:
        - inventory open d:MaterialTransferSelection_Window
        - determine cancelled

        on player opens MaterialTransferSelection_Window:
        - yaml load:powerstruggle.yml id:ps

        - foreach <context.inventory.list_contents> as:item:
            - define amountAvailable <yaml[ps].read[transferItemsToday.<[item].material.name>]>

            - if <[amountAvailable].is_integer.if_null[false]> && <[amountAvailable].is[MORE].than[0]>:
                - inventory adjust d:<context.inventory> slot:<[loop_index]> "lore:|Present Orders: <[amountAvailable].color[aqua]>"

            - else:
                - inventory adjust d:<context.inventory> slot:<[loop_index]> "lore:|<red>No Present Orders!"

        - yaml id:ps unload

        on player clicks in MaterialTransferSelection_Window:
        - if <context.item.material.name> == air || <context.clicked_inventory.id_holder> == <player>:
            - determine cancelled

        - yaml load:powerstruggle.yml id:ps
        - define kingdom <player.flag[kingdom]>

        - if <yaml[ps].read[<[kingdom]>.dailyinfluences]> <= 0:
            - narrate format:callout "Your kingdom has exhasuted its influence points today"
            - determine cancelled

        - if <context.item.script.name.if_null[true]> != Back_Influence:
            - if !<player.has_flag[transferData.amount]>:
                - if <yaml[ps].read[transferItemsToday.<context.item.material.name>]> != 0:

                    - definemap tData:
                        transferType: masons
                        material: <context.item.material.name>

                    - flag player transferData:<[tData]>

                    - inventory close
                    - narrate format:callout "Type out (<bold>using just numbers) <&r><&6> how many orders you want to fullfill."
                    - narrate format:callout "Type <&sq>cancel<&sq> to cancel the transfer."

                - else:
                    - narrate format:callout "There are no present orders for this type of item!"
            - else:
                - narrate format:callout "You are already making an item transfer transaction"

        - yaml id:ps unload

        on player places *_sign:
        - if <player.has_flag[transferData]>:
            - if <player.flag[transferData].get[transferType]> == masons:

                - define playerLoc <player.location>
                - define chestLoc <context.location.with_x[<context.location.z.sub[1]>]>
                - define signDirection <context.location.material.direction>

                - choose <[signDirection]>:
                    - case NORTH:
                        - define chestLoc <context.location.with_z[<context.location.z.add[1]>]>

                    - case EAST:
                        - define chestLoc <context.location.with_x[<context.location.x.add[1]>]>

                    - case WEST:
                        - define chestLoc <context.location.with_x[<context.location.x.sub[1]>]>

                - if <[chestLoc].has_inventory>:
                    - flag player transferVaultLoc:<[chestLoc]>
                    - waituntil !<player.location> != <[playerLoc]> || <context.location.sign_contents> != "Material transfer|chest|DO NOT USE"
                    - sign "<red>Material transfer|chest|<bold>DO NOT USE" <context.location>

##############################################################################

IngestMaterialTransfer:
    type: command
    name: deliver
    usage: /deliver
    description: Used to initiate the collection of blocks the player wishes to transfer to the Mason's guild
    script:
    - if <player.has_flag[transferData]>:
        - if <player.flag[transferData].get[transferType]> == masons:
            - if <player.has_flag[transferVaultLoc]>:
                - define transferItem <player.flag[transferData].get[material]>
                - define transferAmount <player.flag[transferData].get[amount]>
                - define itemsInChest <player.flag[transferVaultLoc].inventory.quantity_item[<[transferItem]>]>

                #- narrate <player.flag[transferData]>
                #- narrate format:debug <[itemsInChest]>

                - if <[transferAmount].is[OR_LESS].than[<[itemsInChest]>]>:
                    #- narrate format:debug <[itemsInChest]>

                    # The influence equation for weapon transfers is:
                    # infl = ln(75grad / (amount - 75grad))

                    - define influenceGradient <script[ItemGradientData].data_key[<[transferItem]>]>
                    #- narrate format:debug INFG:<[influenceGradient]>

                    - define grad <[influenceGradient].mul[75]>
                    #- narrate format:debug GRAD:<[grad]>

                    - define influenceEquation <[grad].div[<[grad].sub[<[transferAmount]>]>].log[<util.e>].mul[3]>
                    #- narrate format:debug <[influenceEquation]>

                    - define kingdom <player.flag[kingdom]>

                    - yaml load:powerstruggle.yml id:ps
                    - yaml id:ps set <[kingdom]>.masonsguild:+:<[influenceEquation]>
                    - yaml id:ps set transferItemsToday.<[transferItem]>:-:<[transferAmount]>
                    - yaml id:ps savefile:powerstruggle.yml
                    - yaml id:ps unload

                    - run CalcTotalInfluence def:<[kingdom]>

                    - foreach <player.flag[transferVaultLoc].inventory.list_contents>:

                        # If the amount of items in the stack at this point is
                        # less than the total amount of items that need to be
                        # transfered clear that slot

                        - if <[value].quantity.is[OR_LESS].than[<[transferAmount]>]>:
                            - inventory d:<player.flag[transferVaultLoc].inventory> set slot:<[loop_index]> o:air

                            - define transferAmount:-:<[value].quantity>

                        # Else, subtract only the amount of items remaining and
                        # end the loop

                        - else:
                            - inventory d:<player.flag[transferVaultLoc].inventory> adjust slot:<[loop_index]> quantity:<[value].quantity.sub[<[transferAmount]>]>

                            - define transferAmount:-:<[value].quantity>

                            - foreach stop

                    - flag player transferVaultLoc:!
                    - flag player transferData:!

                    - run SidebarLoader def.target:<server.flag[<[kingdom]>.members].include[<server.online_ops>]>
                    - narrate format:callout "Materials sent! Any remaining blocks will be found in the chest"

                - else:
                    - narrate format:callout "You have not met the order's quantity requirement yet! You need <blue><[transferAmount].sub[<[itemsInChest]>]> <&6>more blocks"

            - else:
                - narrate format:callout "You have not set a transfer vault location!"

        - else:
            - narrate format:callout "You are not currently transferring to the Masons guild!"

    - else:
        - narrate format:callout "You have not initiated an active transfer deal yet."

