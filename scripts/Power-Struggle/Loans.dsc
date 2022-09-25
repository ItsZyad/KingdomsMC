##
## * All scripts relating to the mechanic that allows
## * to take or give loans out from/to fyndalin
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Mar 2022
## @Script Ver: INDEV
##
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

UnavailableLoan_Item:
    type: item
    material: player_head
    display name: "<gray><bold>Unavailable Loan"
    lore:
        - "<gray><italic>Your kingdom needs more influence in the city"
        - "<gray><italic>to take this loan."
    mechanisms:
        skull_skin: 0770dfd8-52be-443d-ac2a-63389d0ac9dd|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNDgzNjUzOGY1NTU1Y2M2MTAzODhiOTdjNmJkMzY4ZTE2YWExZmZiNWQ3YjRiZDNjODZmZTA5MmU4ZTBkNGNjNyJ9fX0=

AvailableLoan_Item:
    type: item
    material: player_head
    display name: "<green><bold>Available Loan"
    mechanisms:
        skull_skin: d789eebe-d604-47a8-9c5b-8ef4f9f29c96|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOGVlYjE4ZTY2OTVjMzliNDQxZDA0ZjdjYTUzZWRhMTM0NmE1YTk0N2Q0ZmU4YmEzN2IzM2I5MjMyODhiNGUzMCJ9fX0=

Loan5k_Item:
    type: item
    material: iron_nugget
    display name: "<bold>$5,000 Loan"
    lore:
        - "<&r>Influence Hit:<red><bold> -1.5<&pc>"
        - "<&r>Influence Bonus:<green><bold> Between +1 and +2<&pc>"
    flags:
        amount: 5000

Loan10k_Item:
    type: item
    material: iron_ingot
    display name: "<bold>$10,000 Loan"
    lore:
        - "<&r>Influence Hit:<red><bold> -4<&pc>"
        - "<&r>Influence Bonus:<green><bold> Between +2 and +3.5<&pc>"
    flags:
        amount: 10000

Loan20k_Item:
    type: item
    material: gold_nugget
    display name: "<bold>$20,000 Loan"
    lore:
        - "<&r>Influence Hit:<red><bold> -9<&pc>"
        - "<&r>Influence Bonus:<green><bold> Between +4 and +5.5<&pc>"
    flags:
        amount: 20000

Loan40k_Item:
    type: item
    material: gold_ingot
    display name: "<bold>$40,000 Loan"
    lore:
        - "<&r>Influence Hit:<red><bold> -13<&pc>"
        - "<&r>Influence Bonus:<green><bold> Between +6 and +8.5<&pc>"
    flags:
        amount: 40000

Loan_GUI:
    type: inventory
    inventory: chest
    gui: true
    title: "Fyndalin Loans"
    procedural items:
    - define loanAmounts <player.flag[loanData]>
    - define kingdom <player.flag[kingdom]>
    - define existingLoans <server.flag[<[kingdom]>.loans].if_null[<list>]>
    - define outList <list[]>
    - define count 0

    - repeat 11:
        - define outList:->:<item[air]>

    #- narrate format:debug EXL:<[existingLoans]>

    - foreach <[existingLoans]>:
        - if <[count].mod[6]> == 0 && <[count]> != 0:
            - repeat 4:
                - define outList:->:<item[air]>

        - define amount <[value].get[amount]>
        - define dueDate <[value].get[dueDate]>
        ## NOTE 1: Interest will remain 0 - See Note 3 for more info.
        - define interest <[value].get[interest]>
        ## NOTE 2: Later, kingdoms will be able to issue loans to each other
        - define issuer <[value].get[issuer]>

        - define lore "<list[Amount: <red><[amount]>|<&r>Pay back by: <aqua><[dueDate].from_now.formatted>|<&r>Interest: <aqua><[interest]><&pc>|<&r>Issuer: <green><[issuer]>]>"
        - define item <item[Loan_From_Fyndalin_Influence]>
        - adjust def:item flag:LoanData:<[value]>
        - adjust def:item display_name:<bold><white>Loan
        - adjust def:item lore:<[lore]>

        - define outList:->:<[item]>
        - define count:++

    - if <[count].is[OR_LESS].than[<[loanAmounts]>]>:
        #- narrate format:debug REP:<element[10].sub[<[loanAmounts]>]>

        - repeat <element[10].sub[<[loanAmounts]>]>:
            - if <[count].mod[5]> == 0 && <[count]> != 0:
                - repeat 4:
                    - define outList:->:<item[air]>

            - if <[count].is[LESS].than[<[loanAmounts]>]>:
                - define outList:->:<item[AvailableLoan_Item]>

            - else:
                - define outList:->:<item[UnavailableLoan_Item]>

            - define count:++

    - determine <[outList]>

    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [Back_Influence] [] [] [] []

LoanSelection_GUI:
    type: inventory
    inventory: chest
    gui: true
    title: "Select Loan Type"
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [Loan5k_Item] [] [Loan10k_Item] [] [Loan20k_Item] [] [Loan40k_Item] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [Back_Influence] [] [] [] []

Loan_Handler:
    type: world
    events:
        on player clicks Loan_From_Fyndalin_Influence in GovernmentInfluence_Window:
        - yaml load:powerstruggle.yml id:ps

        - define kingdom <player.flag[kingdom]>
        - define totInfluence <yaml[ps].read[<[kingdom]>.fyndalingovt]>
        - define loanAmounts <[totInfluence].round_to_precision[0.1].mul[10]>

        - flag player loanData:<[loanAmounts]>
        - inventory open d:Loan_GUI
        - flag player loanData:!

        - yaml unload id:ps

        on player clicks AvailableLoan_Item in Loan_GUI:
        - define LoanGUI <inventory[LoanSelection_GUI]>
        - define kingdom <player.flag[kingdom]>

        - yaml load:powerstruggle.yml id:ps

        - if <yaml[ps].read[<[kingdom]>.dailyinfluences]> <= 0:
            - narrate format:callout "Your kingdom has exhasuted its influence points today"
            - determine cancelled

        - yaml is:ps unload

        # When the player opens the 'TAKE LOAN' window instead of give loan
        # replace all the influence bonuses with influence hits instead to
        # better communicate
        - foreach <[loanGUI].list_contents>:
            - if <[value].has_lore>:
                - inventory adjust d:<[loanGUI]> slot:<[loop_index]> lore:<[value].lore.remove[2]>

        - inventory open d:<[LoanGUI]>

        on player clicks Loan_From_Fyndalin_Influence in Loan_GUI:
        - define loanData <context.item.flag[loanData]>
        - define kingdom <player.flag[kingdom]>
        - define kingdomName <script[KingdomRealNames].data_key[<[kingdom]>]>
        - yaml load:kingdoms.yml id:kingdoms

        - if <yaml[kingdoms].read[<[kingdom]>.balance].is[MORE].than[<[loanData].get[amount]>]>:
            # Subtract from kingdom, add to issuer
            - yaml id:kingdoms set <[kingdom]>.balance:-:<[loanData].get[amount]>
            - yaml id:kingdoms set <[loanData].get[issuer]>.balance:+:<[loanData].get[amount]>

            - run SidebarLoader def.target:<server.flag[<[kingdom]>].get[members]>|<player>

            # Remove that loan from the kingdom's outstanding debt
            - flag server <[kingdom]>.loans:<server.flag[<[kingdom]>].get[loans].exclude[<[loanData]>]>

            - yaml id:kingdoms savefile:kingdoms.yml

            - narrate format:callout "Successfully paid back loan debt to the <[kingdomName].color[aqua].bold> worth: $<[loanData].get[amount].color[red].bold>"

        - else:
            - narrate format:callout "You do not have enough money in your kingdom's balance to pay back this debt!"

        - yaml id:kingdoms unload
        - inventory close

        on player clicks item in LoanSelection_GUI:
        - if <context.item> == <item[Loan_From_Fyndalin_Influence]>:
            - determine cancelled

        - else if <context.item.has_flag[amount]>:
            - define amount <context.item.flag[amount]>
            - define kingdom <player.flag[kingdom]>
            - yaml load:kingdoms.yml id:kingdoms
            - yaml load:powerstruggle.yml id:ps

            - if <yaml[ps].read[<[kingdom]>.dailyinfluences]> <= 0:
                - narrate format:callout "Your kingdom has exhasuted its influence points today"
                - determine cancelled

            - define fyndalinTotal <yaml[kingdoms].read[fyndalin.balance]>

            - if <[amount].is[LESS].than[<[fyndalinTotal].add[1000]>]>:
                - yaml id:kingdoms set fyndalin.balance:-:<[amount]>
                - yaml id:kingdoms set <[kingdom]>.balance:+:<[amount]>
                - yaml id:kingdoms savefile:kingdoms.yml
                - yaml id:kingdoms unload

                - yaml id:ps set <[kingdom]>.dailyinfluences:--
                - yaml id:ps savefile:powerstruggle.yml

                - define daysToDue <[amount].div[1000].add[<[amount].div[2000].round>]>
                - define due <util.time_now.add[<[daysToDue]>d]>

                ## NOTE 3: For now interest will remain at 0 for all Fyndalin's loans to ease
                ## up my workload. Smartly calculating loans on their own is pointless
                ## until I start work on the global economy system;;
                - define loanMap <map[amount=<[amount]>;dueDate=<[due]>;interest=0;issuer=fyndalin]>

                - flag server <[kingdom]>.loans:->:<[loanMap]>

                - define kingdomName <script[KingdomRealNames].data_key[<[kingdom]>]>
                - inventory close
                - narrate format:callout "<[kingdomName]> has taken out a loan of $<[amount]> from Fyndalin. Your kingdom will have <[due].from_now.formatted.color[red].bold> to pay back this loan or else you will default!"
                - narrate "<&sp><gray>To pay back your loans access the loans section of the <element[/influence options].color[red].bold> command again!"

                - run SidebarLoader def.target:<server.flag[<[kingdom]>].get[members].include[<server.online_ops>]>

            - yaml id:ps unload

            - else:
                - inventory close
                - narrate format:callout "Unfortunately, Fyndalin does not have sufficient reserves to lend your kingdom this amount!"

                - if <[amount].is[MORE].than[5000]>:
                    - narrate format:callout "If possible, try selecting a smaller amount."

#########################################################################################################
## IMPORTANT NOTE: There is a script in AdminTools.dsc that allows the GC in charge of Fyndalin         #
##                 to view the currently queued loans Kingdoms want to give the city. When the          #
##                 Loan feature is expanded such that any kingdom can give loans to any other kingdom   #
##                 don't forget to adapt that script to make it accessible to all kingdoms.             #
#########################################################################################################

PendingLoan_Item:
    type: item
    material: player_head
    display name: "<gold><bold>Pending Loan"
    mechanisms:
        skull_skin: 7193fa7b-4dbe-4e92-a840-3d95d2839240|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDllOTA2OGQxNWI0ZDhhNGI2NGZiYjA2NzQ0MTBkYjM0OWE2YzZhYWQ3OWZlOGE1YWI3MWU5NGRhMjQwZmZmNiJ9fX0=

LoanGive_GUI:
    type: inventory
    inventory: chest
    gui: true
    title: "Select Loan Type"
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [Loan5k_Item] [] [Loan10k_Item] [] [Loan20k_Item] [] [Loan40k_Item] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [Back_Influence] [] [] [] []

LoanCancelConfirm_Item:
    type: item
    material: green_wool
    display name: "Confirm Offer Cancellation"

LoanCancelUndo_Item:
    type: item
    material: red_wool
    display name: "Undo Offer Cancellation"

LoanCancelConfirmation_Window:
    type: inventory
    inventory: chest
    gui: true
    title: "Confirm Offer Cancellation"
    slots:
    - [] [] [] [LoanCancelConfirm_Item] [] [LoanCancelUndo_Item] [] [] []

LoanExpiryChecker:
    type: task
    definitions: offer
    script:
    - foreach <server.flag[fyndalin].get[loanOffers]>:
        - if <[value]> == <[offer]>:
            - flag server fyndalin.loanOffers:<-:<[value]>

LoanGive_Handler:
    type: world
    events:
        on player clicks Loan_To_Fyndalin_Influence in GovernmentInfluence_Window:
        - define loanGUI <inventory[LoanSelection_GUI]>
        - define kingdom <player.flag[kingdom]>

        - yaml load:powerstruggle.yml id:ps

        - if <yaml[ps].read[<[kingdom]>.dailyinfluences]> <= 0:
            - narrate format:callout "Your kingdom has exhasuted its influence points today"
            - determine cancelled

        - yaml is:ps unload

        # When the player opens the 'GIVE LOAN' window instead of take loan
        # replace all the influence hits with influence bonuses instead to
        # better communicate
        - foreach <[loanGUI].list_contents>:
            - if <[value].has_lore>:
                - inventory adjust d:<[loanGUI]> slot:<[loop_index]> lore:<[value].lore.remove[1]>

        - inventory open d:<[loanGUI]>

        on player opens LoanGive_GUI:
        - define hasMadeOffer false
        - define offerDetails <map[]>
        - define kingdom <player.flag[kingdom]>

        # Loop through Fyndalin's active loan offers and check if one of
        # them has the player's kingdom name attached.
        - foreach <server.flag[fyndalin].get[loanOffers]>:
            - if <[value].get[kingdom]> == <[kingdom]>:
                - define hasMadeOffer true
                - define offerDetails <[value]>
                - foreach stop

        - if <[hasMadeOffer]>:
            - define amount <[offerDetails].get[amount]>
            - define expiry <[offerDetails].get[expiry]>

            # Create an object called pendingLoan and replace the contents
            # of the LoanGive_GUI with this object that allows the player
            # to cancel their kingdom's loan req. to Fyndalin.
            - define pendingLoan <item[PendingLoan_Item]>
            - adjust def:pendingLoan "lore:<white>Offer: <red><bold>$<[amount]>|<white>Expires in: <red><bold><[expiry].from_now.formatted>|<gray><italic>Click to cancel offer"
            #- narrate format:debug <[pendingLoan]>

            - inventory d:<context.inventory> keep o:Back_Influence
            - give to:<context.inventory> <[pendingLoan]> slot:14
            - adjust <context.inventory> "title:Pending Offer(s)"

        on player clicks PendingLoan_Item in LoanGive_GUI:
        - inventory open d:LoanCancelConfirmation_Window

        on player clicks LoanCancelUndo_Item in LoanCancelConfirmation_Window:
        - inventory open d:LoanGive_GUI

        on player clicks LoanCancelConfirm_Item in LoanCancelConfirmation_Window:
        - define kingdom  <player.flag[kingdom]>

        - foreach <server.flag[fyndalin].get[loanOffers]>:
            - if <[value].get[kingdom]> == <[kingdom]>:
                - flag server fyndalin.loanOffers:<-:<[value]>
                - foreach stop

        - inventory close
        - narrate format:callout "Successfully cancelled loan offer. Your kingdom may now make alternative offers."

        on player clicks item in LoanGive_GUI:
        #- narrate format:debug <context.slot>

        - if <context.item.has_flag[amount]>:
            - define kingdom <player.flag[kingdom]>
            - define amount <context.item.flag[amount]>
            - define expiry <util.time_now.add[7d]>

            - yaml load:kingdom.yaml id:kingdoms

            - if <yaml[kingdoms].read[<[kingdom]>.balance].sub[<[amount]>].is[LESS].than[0]>:
                - narrate format:debug "Your kingdom does not have the sufficient funds to make this loan offer!"

            - else:
                - definemap loanOffer:
                    amount: <[amount]>
                    kingdom: <[kingdom]>
                    expiry: <[expiry]>

                - flag server fyndalin.loanOffers:->:<[loanOffer]>
                - runlater delay:7d LoanExpiryChecker def:<[loanOffer]>
                - inventory close
                - narrate format:callout "Your loan offer has been made to Fyndalin. You must wait until this offer expires in a week or Fyndalin accepts it before making another."

            - yaml id:kingdoms unload