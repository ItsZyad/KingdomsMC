##----------------START HEADER----------------
##
## * All the main scripts relating to the initial influence
## * GUIs and player interactions
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2021
## @Script Ver: v1.0
## @Clean Code Classification: 3.5
##
##ignorewarning ancient_defs
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

FyndalinTakeoverWindow:
    type: inventory
    inventory: chest
    gui: true
    title: "Takeover Fyndalin"
    procedural items:
    - determine <player.flag[FyndalinTakeoverList]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [FyndalinTakeoverHelp_Item] [] [Back_Influence] [] [] []

InfluenceWindow:
    type: inventory
    title: "Influence in Fyndalin"
    inventory: chest
    gui: true
    slots:
    - [] [] [] [] [TotalInfluence] [] [] [] []
    - [] [MasonsInfluence] [] [MercenaryInfluence] [] [GovernmentInfluence] [] [PopulationInfluence] []
    - [] [] [] [] [BlackMarketInfluence] [] [] [] []
    - [] [] [] [FyndalinAnger_Item] [InfluenceHelp] [FyndalinTreaties_Item] [] [] []

InfluenceWindow_Help:
    type: inventory
    title: "Influence in Fyndalin"
    inventory: chest
    gui: true
    slots:
    - [] [] [] [] [TotalInfluence_Help] [] [] [] []
    - [] [MasonsInfluence_Help] [] [MercenaryInfluence_Help] [] [GovernmentInfluence_Help] [] [PopulationInfluence_Help] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [FyndalinAngerHelp_Item] [InfluenceHelp] [FyndalinTreatiesHelp_Item] [] [] []

##############################################################################

FyndalinAnger:
    type: procedure
    script:
    - define slot <context.inventory.find_item[FyndalinAnger_Item]>
    - define anger <server.flag[powerstruggleFile].get[fyndalinanger].mul[100]>
    - define influenceGraphic <list>

    - repeat <[anger].div[5]>:
        - define influenceGraphic:->:█

    - repeat <element[20].sub[<[anger].div[5]>]>:
        - define influenceGraphic:->:░

    - define influenceGraphic:->:<&sp>-<&sp>
    - define influenceGraphic:->:<[anger].round_to_precision[0.01]><element[%].escaped>

    - determine <[influenceGraphic].unseparated>

##############################################################################

InfluenceGetter:
    type: procedure
    definitions: type
    script:
    #- narrate <server.flag[powerstruggleFile].get[centran]>

    - define influencePercentage <server.flag[powerstruggleFile].deep_get[<player.flag[kingdom]>.<[type]>].mul[100]>
    - define influenceGraphic <list>

    - repeat <[influencePercentage].div[5]>:
        - define influenceGraphic:->:█

    - repeat <element[20].sub[<[influencePercentage].div[5]>]>:
        - define influenceGraphic:->:░

    - define influenceGraphic:->:<&sp>-<&sp>
    - define influenceGraphic:->:<[influencePercentage].round_to_precision[0.01]><element[%].escaped>
    - determine <[influenceGraphic].unseparated>

##############################################################################

InfluenceBonusDisplay_Handler:
    type: world
    events:
        on player opens InfluenceWindow:
        - define kingdom <player.flag[kingdom]>
        - define powerStruggle <server.flag[powerstruggleFile]>

        - foreach <context.inventory.list_contents>:
            - define newLore <list>
            - define bonusTitle BONUSES

            - if <[value].has_flag[type]>:
                - define type <[value].flag[type]>
                - define influenceAmount <[powerStruggle].deep_get[<[kingdom]>.<[type]>]>

                - choose <[type]>:
                    - case fyndalingovt:
                        - define bonusTax 0

                        - if <[influenceAmount].is[OR_MORE].than[0.15]>:
                            - define newLine "<element[<aqua>- 25% Reduction in Regular Merchant Prices]>"
                            - define newLore:->:<[newLine]>

                        - if <[influenceAmount].is[OR_MORE].than[0.25]>:
                            - define bonusTax:+:4000

                        - if <[influenceAmount].is[OR_MORE].than[0.35]>:
                            - define bonusTax:+:1500

                        - if <[influenceAmount].is[OR_MORE].than[0.5]>:
                            - define newLine "<element[<aqua>- ]>"

                        - define newLine "<element[<aqua>- Additional $<[bonusTax].format_number> of Fyndalin's tax money]>"
                        - define newLore:->:<[newLine]>

                    - case totalinfluence:
                        - define bonusTitle DESCRIPTION

                        - if <[influenceAmount].is[OR_MORE].than[0.95]>:
                            - define newLines "<list[<aqua>- Absolute Control|<gray>  Your kingdom's forces rule over Fyndalin with an iron|<gray>  fist, and have reduced the mandate government to a|<gray>  puppet administration.]>"

                        - else if <[influenceAmount].is[OR_MORE].than[0.85]>:
                            - define newLines "<list[<aqua>- Strong Control|<gray>  This means your rule over Fyndalin is largely undisputed]>"

                        - else if <[influenceAmount].is[OR_MORE].than[0.7]>:
                            - define newLines "<list[<aqua>- De-Facto/Significant Control|<gray>  This means you are largely in control of Fyndalin...|<gray>  But some parts of the population and administration |<gray>  are still unconvinced.]>"

                        - else if <[influenceAmount].is[OR_MORE].than[0.5]>:
                            - define newLines "<list[<element[<aqua>- De-Jure/Nominal Control]>|<element[<gray>  This means you are technically in control of Fyndalin...]>|<element[<gray>  But... like... not really.]>]>"

                        - else if <[influenceAmount].is[OR_MORE].than[0.35]>:
                            - define newLines "<list[<aqua>- Negligble Control|<gray>  Your influence in Fyndalin exists only on paper|<gray>  (specifically, <bold>your <&r><gray>papers).]>"

                        - else:
                            - define newLines "<list[<aqua>- No Control|<gray>  Your kingdom holds no practical influence over Fyndalin]>"

                        - define newLore <[newLore].include[<[newLines]>]>

                    - case mercenaryguild:
                        - define bonusTitle DESCRIPTION

                        - if <[influenceAmount].is[OR_MORE].than[0.9]>:
                            - define newLines "<list[<aqua><bold>- Allegiant Militia|<gray>  The Fyndalin militia is in your kingdom's pockets. They|<gray>  They will back any attempts to annex the city.]>"

                        - else if <[influenceAmount].is[OR_MORE].than[0.75]>:
                            - define newLines "<list[<green><bold>- Loyal Militia|<gray>  The Fyndalin militia will likely back your attempts to|<gray>  take over the city.]>"

                        - else if <[influenceAmount].is[OR_MORE].than[0.5]>:
                            - define newLines "<list[<gold><bold>- Indifferent Militia|<gray>  The Fyndalin city militia is invested enough in|<gray>  your kingdom's success to stand aside from annexation|<gray>  attempts. But will not aid you in any such endevours.]>"

                        - else if <[influenceAmount].is[OR_MORE].than[0.35]>:
                            - define newLines "<list[<yellow><bold>- Weary Militia|<gray>  The Fyndalin militia is suspicious of your actions in|<gray>  the city and will likely intervene should your kingdom|<gray>  try to annex it.]>"

                        - else:
                            - define newLines "<list[<red><bold>- Defiant Militia|<gray>  The Fyndalin city militia is fully under the control of city|<gray>  officials and will respond decisively should your kingdom|<gray>  attempt to annex the city.]>"

                        - define newLore <[newLore].include[<[newLines]>]>

            - if <[newLore].size> != 0:
                - inventory d:<context.inventory> adjust slot:<[loop_index]> lore:<[value].lore.include[<&sp>|<light_purple><bold><[bonusTitle]><&co>].include[<[newLore]>]>

##############################################################################

InfluenceGetter_Admin:
    type: procedure
    definitions: kingdom
    script:
    #- narrate <server.flag[powerstruggleFile].get[centran]>

    - define influencePercentage <server.flag[powerstruggleFile].deep_get[<[kingdom]>.totalinfluence].mul[100]>
    - define influenceGraphic <list>

    - repeat <[influencePercentage].div[5]>:
        - define influenceGraphic:->:█

    - repeat <element[20].sub[<[influencePercentage].div[5]>]>:
        - define influenceGraphic:->:░

    - define influenceGraphic:->:<&sp>-<&sp>
    - define influenceGraphic:->:<[influencePercentage].round_to_precision[0.01]><element[%].escaped>
    - determine <[influenceGraphic].unseparated>

##############################################################################

InfluenceTextRef:
    type: data
    controlStatus:
        type: textRef
        ref:
            90: "Absolute"
            70: "Strong"
            50: "De-Facto/Significant"
            35: "De-Jure/Loose"
            5: "Negligble"
            0: "None"

InfluenceStatus_Command:
    type: command
    name: influence
    usage: /influence
    description: Shows the extent of your kingdom<&sq>s influence in Fyndalin.
    tab completions:
        1: info|help
    script:
    - if <server.has_flag[PreGameStart]> && !<player.is_op>:
        - narrate format:callout "Sorry! You cannot use this while the server is still in build mode!"
        - determine cancelled

    - yaml load:kingdoms.yml id:kingdoms

    - if !<proc[IsKingdomBankrupt].context[<yaml[kingdoms].parsed_key[].deep_get[<player.flag[kingdom]>.balance]>|<player.flag[kingdom]>]>:
        - if <context.args.size> == 0 || <context.args.get[1]> == info:
            - yaml load:powerstruggle.yml id:ps
            - flag server powerstruggleFile:<util.parse_yaml[<yaml[ps].to_text>]>

            - yaml unload id:ps

            - inventory open d:InfluenceWindow

        - else if <context.args.get[1]> == help:
            - inventory open d:InfluenceWindow_Help

    - else:
        - narrate format:callout "Your kingdom is bankrupt! Clear your outstanding debts to start using influence actions again."

    - yaml id:kingdoms unload

##############################################################################

InfluenceWindow_Handler:
    type: world
    events:
        # Changes the function of the influence help button depending
        # on which GUI it is present in so that it correctly leads to
        # the other.

        on player clicks InfluenceHelp in inventory:
        - narrate format:debug <context.inventory.script.name>

        - if <context.inventory.script.name> == InfluenceWindow_Help:
            - yaml load:powerstruggle.yml id:ps
            - flag server powerstruggleFile:<util.parse_yaml[<yaml[ps].to_text>]>

            - yaml unload id:ps

            - inventory open d:InfluenceWindow

        - else if <context.inventory.script.name> == InfluenceWindow:
            - inventory open d:InfluenceWindow_Help

        on player closes InfluenceWindow:
        - flag server powerstruggleFile:!

##############################################################################

InfluenceOption_Handler:
    type: world
    events:
        on player clicks MercenaryInfluence in InfluenceWindow:
        - inventory open d:MercenaryInfluence_Window

        on player clicks MasonsInfluence in InfluenceWindow:
        - inventory open d:MasonsInfluence_Window

        on player clicks GovernmentInfluence in InfluenceWindow:
        - inventory open d:GovernmentInfluence_Window

        on player clicks PopulationInfluence in InfluenceWindow:
        - inventory open d:PopulationInfluence_Window

        on player clicks BlackMarketInfluence in InfluenceWindow:
        - define BMWindow <inventory[BlackMarketInfluence_Window]>
        - yaml load:blackmarket-formatted.yml id:bmf

        - define kingdom <player.flag[kingdom]>
        - define factionOpinions <yaml[bmf].read[factiondata.opinions.<[kingdom]>]>

        - foreach <[BMWindow].list_contents>:
            - if <[value].has_flag[factionInfo]>:
                - define factionName <[value].flag[factionInfo].get[1]>
                - define factionOpinion <[factionOpinions].get[<[factionName]>]>
                - define factionOpMeter <list[<&lb>]>

                - repeat 20:
                    - if <[value]> == <[factionOpinion].round_to_precision[0.1].mul[10]>:
                        - define factionOpMeter:->:█

                    - else:
                        - define factionOpMeter:->:░

                - define factionOpMeter:->:<&rb>

                - define sentence <element[]>

                - if <[factionOpinion].is[OR_MORE].than[1.8]>:
                    - define sentence "This faction is highly friendly to your kingdom!"

                - else if <[factionOpinion].is[OR_MORE].than[1.5]>:
                    - define sentence "This faction is friendly to your kingdom."

                - else if <[factionOpinion].is[OR_MORE].than[1.2]>:
                    - define sentence "This faction is mildly friendly to your kingdom."

                - else if <[factionOpinion].is[OR_MORE].than[0.95]>:
                    - define sentence "This faction is indifferent to your kingdom"

                - else if <[factionOpinion].is[OR_MORE].than[0.7]>:
                    - define sentence "This faction is weary of your kingdom"

                - else if <[factionOpinion].is[OR_MORE].than[0.35]>:
                    - define sentence "This faction is unfriendly to your kingdom!"

                - else:
                    - define sentence "This faction hates your kingdom, and will not trade with you!"

                - inventory adjust d:<[BMWindow]> slot:<[loop_index]> "lore:<[factionOpMeter].unseparated>|Exact Opinion: ~<[factionOpinion].sub[1].round_to_precision[0.01]>| |<[sentence].italicize>"

        - yaml id:bmf unload
        - inventory open d:<[BMWindow]>

        on player clicks Back_Influence in inventory:
        - yaml load:powerstruggle.yml id:ps
        - flag server powerstruggleFile:<util.parse_yaml[<yaml[ps].to_text>]>

        - yaml unload id:ps

        - inventory open d:InfluenceWindow
        - determine cancelled

##############################################################################

DailyInfluenceRefresh:
    type: task
    script:
    - yaml load:powerstruggle.yml id:ps

    - define kingdomList <proc[GetKingdomList].context[true]>

    - foreach <[kingdomList]>:
        - if <yaml[ps].read[<[value]>.dailyinfluences]> < 3:
            - yaml id:ps set <[value]>.dailyinfluences:3

    - yaml id:ps savefile:powerstruggle.yml
    - yaml id:ps unload

    - run DailyOrderRefresh
    - run SidebarLoader def.target:<server.online_players>

DailyInfluenceRefresh_Handler:
    type: world
    events:
        on system time hourly every:24:
        - run DailyInfluenceRefresh

##############################################################################

CalcTotalInfluence:
    type: task
    definitions: kingdom
    script:
    - yaml load:powerstruggle.yml id:ps

    - define population <yaml[ps].read[<[kingdom]>.citypopulation]>
    - define government <yaml[ps].read[<[kingdom]>.fyndalingovt]>
    - define mercenary <yaml[ps].read[<[kingdom]>.mercenaryguild]>
    - define masons <yaml[ps].read[<[kingdom]>.masonsguild]>

    - define average <[population].add[<[government]>].add[<[mercenary]>].add[<[masons]>].div[4]>

    - yaml id:ps set <[kingdom]>.totalinfluence:<[average]>
    - yaml savefile:powerstruggle.yml id:ps

    - yaml id:ps unload

##############################################################################

PerkChecker:
    type: task
    script:
    - yaml load:powerstruggle.yml id:ps

    - define kingdoms <proc[GetKingdomList].context[<yaml[kingdoms].parsed_key[]>]>

    - foreach <yaml[ps].list_keys[]> as:kingdom:
        - if <[kingdoms].contains[<[kingdom]>]>:

            - define govInfluence <yaml[ps].read[<[kingdom]>.fyndalingovt]>
            - define popInfluence <yaml[ps].read[<[kingdom]>.citypopulation]>
            - define merInfluence <yaml[ps].read[<[kingdom]>.mercenaryguild]>
            - define masInfluence <yaml[ps].read[<[kingdom]>.masonsguild]>
            - define totInfluence <yaml[ps].read[<[kingdom]>.totalinfluence]>

            # GOVERNMENT INF. CHECK #

            - if <[govInfluence].is[OR_MORE].than[0.15]>:
                - flag server <[kingdom]>.influenceBonuses.merchantDiscount:25

            - if <[govInfluence].is[OR_MORE].than[0.25]>:
                - flag server <[kingdom]>.influenceBonuses.bonusTax:+:4000

            - if <[govInfluence].is[OR_MORE].than[0.35]>:
                - flag server <[kingdom]>.influenceBonuses.bonusTax:+:1500

            # TOTAL INF. CHECK #

            - if <[totInfluence].is[OR_MORE].than[0.5]>:
                - flag server <[kingdom]>.influenceBonuses.controlStatus:DeJure

            # POPULATION INF. CHECK #



            # MASONS INF. CHECK #



            # MERCENARY INF. CHECK #



            - narrate format:debug <yaml[ps].read[<[kingdom]>]>

    - yaml id:ps unload

    # BLACK MARKET INF. CHECK #

    - yaml load:blackmarket-formatted.yml id:bm

    - define factionOpinions <yaml[bm].read[factiondata.opinions].to_pair_lists>
    - foreach <[factionOpinions]>:
        - define kingdom <[value].get[1]>

        - foreach <[value].get[2].to_pair_lists> as:faction:
            - flag server <[kingdom]>.influenceBonuses.BMOpinion.<[faction].get[1]>:<[faction].get[2]>

    - yaml id:bm unload

##############################################################################

FyndalinTakeover_Handler:
    type: world
    events:
        on player clicks TotalInfluence in InfluenceWindow:
        - define inventoryItem <item[FyndalinTakeoverImpossible_Item]>
        - define kingdom <player.flag[kingdom]>

        - yaml load:powerstruggle.yml id:ps

        - define totalInf <yaml[ps].read[<[kingdom]>.totalinfluence]>
        - define kingdomList <list[centran|raptoran|viridian|cambrian].exclude[<[kingdom]>]>
        - define takeoverCondition 0

        - foreach <[kingdomList]>:
            - define otherTotalInf <yaml[ps].read[<[value]>.totalinfluence]>

            - if <[otherTotalInf].add[0.3].is[LESS].than[<[totalInf]>]> && <[totalInf].is[MORE].than[0.5]>:
                - define takeoverCondition:++

        - if <[takeoverCondition].is[OR_MORE].than[<[kingdomList].size.sub[1]>]>:
            - define inventoryItem <item[FyndalinTakeoverPossible_Item]>

            - yaml load:kingdoms.yml id:king

            - define fyndalinBalance <yaml[king].read[fyndalin.balance]>
            - define fyndalinUpkeep <yaml[king].read[fyndalin.upkeep]>
            - define fyndalinPrestige <yaml[king].read[fyndalin.prestige]>
            - define taxDivisor <[fyndalinPrestige].div[<[fyndalinPrestige].ln>].round_to_precision[0.1]>
            - define fyndalinDailyTax <element[20000].div[<[taxDivisor]>]>

            - yaml id:king unload

            - adjust def:inventoryItem "lore:<white>If you were to annex Fyndalin now, your kingdom would:|<&sp>|<green><bold>[GAIN] <&r><red>$<[fyndalinBalance].format_number> <white>from Fyndalin's coffers instantly,|<green><bold>[GAIN] <&r><red>$<[fyndalinDailyTax].format_number> <white>from Fyndalin's tax money daily,|<&sp>|<red><bold>[LOSE] <&r><red>$<[fyndalinUpkeep].format_number> <white>As upkeep for your Kingdom's new territories."

        - flag <player> FyndalinTakeoverList:<list[air|air|air|air|<[inventoryItem]>|air|air|air|air]>
        - inventory open d:FyndalinTakeoverWindow
        - flag <player> FyndalinTakeoverList:!

        - yaml is:ps unload

        # on player clicks FyndalinTakeoverPossible_Item in FyndalinTakeoverWindow:
        # - narrate format:callout "I JUST MORBED"