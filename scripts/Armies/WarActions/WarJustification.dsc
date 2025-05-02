##
## This module contains all scripts relating to the justification of war against other kingdoms.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jul 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

IronicAntiWarQuotes:
    type: data
    Quotes:
    - Only the dead have seen the end of war. ~ Plato
    - Most people seek what they do not possess, and are enslaved by the very things they wish to acquire. ~ Anwar El-Sadat
    - Cry havoc and let slip the dogs of war! ~ William Shakespeare
    - If you want to make peace, you don't talk to your friends. You talk to your enemies. ~ Moshe Dayan
    - No enterprise is more likely to succeed than one concealed from the enemy until it is ripe for execution. ~ Niccolò Machiavelli
    - As long as there are sovereign nations possessing great power, war is inevitable. ~ Albert Einstein
    - The more you sweat in peace, the less you bleed in war. ~ Norman Schwarzkopf
    - All war represents a failure of diplomacy. ~ Tony Benn
    - Politics is the skilled use of blunt objects. ~ Lester B. Pearson


GetIronicWarQuote:
    type: procedure
    script:
    - define quotes <script[IronicAntiWarQuotes].data_key[Quotes].as[list]>
    - determine <[quotes].random>


CalculateClaimableTerritory:
    type: procedure
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]
    description:
    - Returns the maximum number of chunks that the provided kingdom can claim off the provided target kingdom in the case of a war.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Returns the maximum number of chunks that the provided kingdom can claim off the provided
    ## target kingdom in the case of a war.
    ##
    ## kingdom       : [ElementTag<String>]
    ## targetKingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Integer>]

    - define kingdomPrestige <[kingdom].proc[GetPrestige]>
    - define targetKingdomPrestige <[targetKingdom].proc[GetPrestige]>

    # Maximum possible value: 200, Minimum: 0.
    - define prestigeDiff <[kingdomPrestige].sub[<[targetKingdomPrestige]>].add[100]>

    - define kingdomCoreAmount <[kingdom].proc[GetClaims].context[core].size>
    - define targetKingdomCoreAmount <[targetKingdom].proc[GetClaims].context[core].size>

    # This is the proportion of the kingdom's territory to the target kingdom's territory. So if
    # it's lower than 1 that means the target kingdom has more territory.
    - define territoryDiffProp <[kingdomCoreAmount].div[<[targetKingdomCoreAmount]>]>

    # Having more territory than your adversaries should give a partial advantage but not play a
    # stupidly outsized role.
    - if <[territoryDiffProp]> > 1.5:
        - define territoryDiffProp <[territoryDiffProp].div[2]>

    # You can only ever claim half a kingdom's territory in one go.
    - define maxPossibleClaims <[targetKingdomCoreAmount].div[2]>

    # Prestige diff applied.
    - define maxPossibleClaims <[maxPossibleClaims].mul[<[prestigeDiff].div[110].if_null[0.1]>]>
    - define maxPossibleClaims <[maxPossibleClaims].mul[<[territoryDiffProp]>].round_up>

    - determine <[maxPossibleClaims]>


CalculateJustificationTime:
    type: procedure
    definitions: claimSize[ElementTag(Integer)]
    description:
    - Returns the time needed to generate a justification of the provided size.
    - The size of a claim is measured in the number of chunks claimed.
    - ---
    - → [DurationTag]

    script:
    ## Returns the time needed to generate a justification of the provided size.
    ## The size of a claim is measured in the number of chunks claimed.
    ##
    ## claimSize : [ElementTag<Integer>]
    ##
    ## >>> [DurationTag]

    - define logParam <element[<[claimSize].add[19]>].div[19]>
    - define timeInDays <[logParam].log[10].mul[9.5]>
    - determine <duration[<[timeInDays]>d]>


JustificationKingdom_Item:
    type: item
    material: barrier
    display name: <red>TEMP KINGDOM ITEM


JustificationKingdom_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Select Kingdom
    procedural items:
    - define outList <list[<item[air]>]>
    - define playerKingdom <player.flag[kingdom]>

    - foreach <proc[GetKingdomList].exclude[<[playerKingdom]>]> as:kingdom:
        - define item <item[JustificationKingdom_Item]>
        - adjust def:item display:<[kingdom].proc[GetKingdomName].color[<[kingdom].proc[GetKingdomColor]>]>
        - adjust def:item flag:kingdom:<[kingdom]>

        - define outList:->:<[item]>
        - define outList:->:<item[air]>

    - determine <[outList]>

    slots:
    - [] [] [] [] [] [] [] [] []


JustificationClaimCore_Item:
    type: item
    material: player_head
    display name: <gray><bold>Claim Core Territory
    mechanisms:
        skull_skin: da906070-6c24-448b-b9c9-0a35ceee534b|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNTk0Yzc5ZjAzZTE5MWI5MzQ3N2Y3YzE5NTU3NDA4ZjdhZjRmOTY2MGU1ZGZiMDY4N2UzYjhlYjkyZmJkM2FlMSJ9fX0=


JustificationClaimOutpost_Item:
    type: item
    material: player_head
    display name: <white><bold>Claim Outpost
    mechanisms:
        skull_skin: bcccae77-0ac7-4cd0-8126-c900727c2223|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNDljMTgzMmU0ZWY1YzRhZDljNTE5ZDE5NGIxOTg1MDMwZDI1NzkxNDMzNGFhZjI3NDVjOWRmZDYxMWQ2ZDYxZCJ9fX0=


JustificationClaimCastle_Item:
    type: item
    material: player_head
    display name: <gold><bold>Claim Castle
    mechanisms:
        skull_skin: 3b7b5d6f-aafa-4f1c-ac6d-ba77953d9b3e|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNmVlZjdlNTZjZGU3NDA3NzJkZmI3NmRkZDJmNTg0YmU4OTA3Yjg1OTc2NjhlNDAyNjM0OTg2NDY5MjMwYWE0OSJ9fX0=


JustificationClaimType_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Select Claim Type
    slots:
    - [] [] [JustificationClaimOutpost_Item] [] [JustificationClaimCore_Item] [] [JustificationClaimCastle_Item] [] []


OutpostJustification_Item:
    type: item
    material: player_head
    display name: <dark_aqua><bold>Outpost
    mechanisms:
        skull_skin: bcccae77-0ac7-4cd0-8126-c900727c2223|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNDljMTgzMmU0ZWY1YzRhZDljNTE5ZDE5NGIxOTg1MDMwZDI1NzkxNDMzNGFhZjI3NDVjOWRmZDYxMWQ2ZDYxZCJ9fX0=


OutpostJustificationSelection_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Select Outpost to Claim
    procedural items:
    - define target <player.flag[datahold.war.justification.target]>
    - define outposts <[target].proc[GetOutposts]>
    - define outpostList <list[]>

    - foreach <[outposts]> key:outpostName as:outpostData:
        - define outpostItem <item[OutpostJustification_Item]>
        - adjust def:outpostItem display:<[outpostName].color[dark_aqua].bold>
        - adjust def:outpostItem lore:<element[Size: ]><[outpostData].get[size].color[light_purple]><element[ blocks]>
        - adjust def:outpostItem flag:outpostName:<[outpostName]>

        - define outpostList:->:<[outpostItem]>

    - determine <[outpostList]>

    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []


OutpostJustificationConfirmation_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Confirm Outpost Claim
    slots:
    - [] [] [Check_Item] [] [] [] [Cross_Item] [] []


WarJustification_Handler:
    type: world
    events:
        ## KINGDOM SELECTOR ##
        on player clicks JustificationKingdom_Item in JustificationKingdom_Window:
        - define targetKingdom <context.item.flag[kingdom]>
        - flag <player> datahold.war.justification.target:<[targetKingdom]>

        - if <player.flag[kingdom].proc[IsAtWarWithKingdom].context[<[targetKingdom]>]>:
            - narrate format:callout "You cannot justify on a kingdom that you're already at war with!"
            - stop

        - inventory open d:JustificationClaimType_Window

        # TODO: There need to be other conditions that allow kingdoms to declare on others' castles
        # TODO/ Maybe something like a maximum number of core claims remaining.
        ## CLAIM TYPE: CASTLE ##
        on player clicks JustificationClaimCastle_Item in JustificationClaimType_Window:
        - define kingdom <player.flag[kingdom]>
        - define targetKingdom <player.flag[datahold.war.justification.target]>
        - define justificationLevel <proc[GetTerritoryJustificationLevel].context[castle]>

        - if <[kingdom].proc[GetKingdomHighestJustificationLevel].context[<[targetKingdom]>].add[1]> < <[justificationLevel]>:
            - narrate format:callout "You cannot justify on this kingdom's castle territory. You must first have previously fought a war with this kingdom over a lesser level of territory."
            - stop

        - define claimSize <[targetKingdom].proc[GetClaims].context[castle].size>
        - define claimTime <[claimSize].proc[CalculateJustificationTime]>
        - run StartJustification def.kingdom:<player.flag[kingdom]> def.targetKingdom:<[targetKingdom]> def.claimSize:<[claimSize]> def.claimType:core def.claimTime:<[claimTime]>

        - narrate format:callout "<bold>Began Justifying on: <[targetKingdom].proc[GetKingdomName]>..."
        - narrate format:callout "This justification will take exactly: <[claimTime].formatted.color[light_purple]> to complete. After that point your two kingdoms will be at war."
        - narrate <n>
        - wait 1s
        - narrate <gray><italic><proc[GetIronicWarQuote]>

        - flag <player> datahold.war.justification.type:castle
        - inventory close

        ## CLAIM TYPE: CORE ##
        on player clicks JustificationClaimCore_Item in JustificationClaimType_Window:
        - define kingdom <player.flag[kingdom]>
        - define targetKingdom <player.flag[datahold.war.justification.target]>
        - define justificationLevel <proc[GetTerritoryJustificationLevel].context[core]>

        - if <[kingdom].proc[GetKingdomHighestJustificationLevel].context[<[targetKingdom]>].add[1]> < <[justificationLevel]> && !<[kingdom].proc[GetOutposts].is_empty>:
            - narrate format:callout "You cannot justify on this kingdom's core territory. You must first have previously fought a war with this kingdom over a lesser level of territory."
            - stop

        - flag <player> datahold.war.justification.type:core
        - flag <player> noChat.war.justification
        - inventory close

        - define maxClaimableTerritory <player.flag[kingdom].proc[CalculateClaimableTerritory].context[<[targetKingdom]>]>

        - narrate format:callout "Please type the number of chunks you want to claim in the coming war (max: <[maxClaimableTerritory].color[aqua]>):"
        - narrate format:callout "<italic>Do note: This will be considered the minimum number claims for you to make to end the war in your favor. Limiting this number to an amount your kingdom can manage is recommended."

        ## CLAIM TYPE: OUTPOST ##
        on player clicks JustificationClaimOutpost_Item in JustificationClaimType_Window:
        - define kingdom <player.flag[kingdom]>
        - define targetKingdom <player.flag[datahold.war.justification.target]>
        - define justificationLevel <proc[GetTerritoryJustificationLevel].context[outpost]>

        - if <[kingdom].proc[GetOutposts].is_empty>:
            - narrate format:callout "You cannot justify on this kingdom's outpost territory because it does not have any outposts."
            - stop

        - if <[kingdom].proc[GetKingdomHighestJustificationLevel].context[<[targetKingdom]>].add[1]> < <[justificationLevel]>:
            - narrate format:callout "You cannot justify on this kingdom's outpost territory. You must first have previously fought a war with this kingdom over a lesser level of territory."
            - stop

        - narrate format:callout "Select the outpost that you would like to claim."

        - flag <player> datahold.war.justification.type:outpost
        - inventory open d:OutpostJustificationSelection_Window

        ## OUTPOST SELECTOR ##
        on player clicks item in OutpostJustificationSelection_Window:
        - if <context.item.has_flag[outpostName]>:
            - define kingdom <player.flag[kingdom]>

            - flag <player> datahold.war.justification.outpost:<context.item.flag[outpostName]>
            - inventory open d:OutpostJustificationConfirmation_Window

        ## OUTPOST CONFIRM CLAIM ##
        on player clicks Check_Item in OutpostJustificationConfirmation_Window:
        - define kingdom <player.flag[kingdom]>
        - define targetKingdom <player.flag[datahold.war.justification.target]>
        - define outpostName <player.flag[datahold.war.justification.outpost]>

        - define claimSize <[targetKingdom].proc[GetOutpostSize].context[<[outpostName]>]>
        - define claimTime <[claimSize].div[256].round_up.proc[CalculateJustificationTime]>
        - run StartJustification def.kingdom:<player.flag[kingdom]> def.targetKingdom:<[targetKingdom]> def.claimSize:<[claimSize]> def.claimType:outpost def.claimTime:<[claimTime]> def.claimName:<[outpostName]>

        - inventory close
        - narrate format:callout "<bold>Began Justifying on: <[targetKingdom].proc[GetKingdomName]>..."
        - narrate format:callout "This justification will take exactly: <[claimTime].formatted.color[light_purple]> to complete. After that point your two kingdoms will be at war."
        - narrate <n>
        - wait 1s
        - narrate <gray><italic><proc[GetIronicWarQuote]>

        ## OUTPOST REJECT CLAIM ##
        on player clicks Cross_Item in OutpostJustificationConfirmation_Window:
        - flag <player> datahold.war.justification:!
        - flag <player> noChat.war.justification:!
        - narrate format:callout "Cancelled war justification."

        - inventory close

        on player chats flagged:noChat.war.justification:
        - determine passively cancelled

        - if <context.message.to_lowercase> == cancel:
            - flag <player> datahold.war.justification:!
            - flag <player> noChat.war.justification:!
            - narrate format:callout "Cancelled war justification."
            - stop

        - define justificationType <player.flag[datahold.war.justification.type]>
        - define target <player.flag[datahold.war.justification.target]>

        - if <[justificationType]> == core:
            - define maxClaimableTerritory <player.flag[kingdom].proc[CalculateClaimableTerritory].context[<[target]>]>

            - if <player.has_flag[noChat.war.justification.confirm]>:
                - if <context.message.to_lowercase> == no:
                    - narrate format:callout "Please re-type your desired claim amount below:"
                    - narrate format:callout "<italic>(Maximum claim amount: <[maxClaimableTerritory].color[aqua]>)"
                    - stop

                - define claimSize <player.flag[datahold.war.justification.claimSize]>
                - define claimTime <[claimSize].proc[CalculateJustificationTime]>
                - run StartJustification def.kingdom:<player.flag[kingdom]> def.targetKingdom:<[target]> def.claimSize:<[claimSize]> def.claimType:core def.claimTime:<[claimTime]>

                - narrate <element[                       ].strikethrough>
                - narrate format:callout "<bold>Began Justifying on: <[target].proc[GetKingdomName]>..."
                - narrate format:callout "This justification will take exactly: <[claimTime].formatted.color[light_purple]> to complete. After that point your two kingdoms will be at war."
                - narrate <n>
                - wait 1s
                - narrate <gray><italic><proc[GetIronicWarQuote]>

                - stop

            - if !<context.message.is_integer>:
                - narrate format:callout "<context.message.color[red]> is not a valid amount of claims. Please try again or type 'cancel' to end the justification process."
                - stop

            - if <context.message> > <[maxClaimableTerritory]>:
                - narrate format:callout "This amount is greater than the maximum number of <[target].proc[GetKingdomShortName].color[red]><&sq>s core chunks that you can claim in any one go. Please try again or type 'cancel' to end the justification process."
                - stop

            - narrate <element[                       ].strikethrough>
            - narrate format:callout "Are you sure you wish to claim <context.message.color[aqua]> chunks in this justification?"
            - narrate format:callout "<italic>Note: This will be considered the minimum number claims for you to make to end the war in your favor. Limiting this number to an amount your kingdom can manage is recommended."
            - narrate <n>
            - narrate format:callout "To confirm type 'yes'. To type in another claim amount type 'no'. To cancel the justification process altogether type 'cancel'."

            - flag <player> noChat.war.justification.confirm
            - flag <player> datahold.war.justification.claimSize:<context.message>

        - else:
            - run GenerateInternalError def.message:<element[Unrecognized justification type. Cancelling justification...]> def.silent:false
            - flag <player> datahold.war.justification:!
            - flag <player> noChat.war.justification:!
