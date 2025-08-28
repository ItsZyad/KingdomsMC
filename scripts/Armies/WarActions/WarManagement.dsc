##
## All items, menus, tasks, and helpers related to the management of war in Kingdoms
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Apr 2025
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

TideOfWar_Item:
    type: item
    material: flower_banner_pattern
    display name: Tide of War
    mechanisms:
        hides: ITEM_DATA


SurrenderWar_Item:
    type: item
    material: white_banner
    display name: <red><bold>Surrender
    data:
        lore:
        - Allows you to negotiate the partial or total surrender of your kingdom to one or more of your enemies.

    lore:
    - <script.proc[FormatLore]>


OfferSurrenderWar_Item:
    type: item
    material: poppy
    display name: <aqua><bold>Offer Peace
    data:
        lore:
        - Allows you to offer conditional peace terms with one or more of your enemies.

    lore:
    - <script.proc[FormatLore]>


VictoryPoint_Interface:
    type: inventory
    inventory: chest
    gui: true
    title: War Panel
    slots:
    - [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [TideOfWar_Item] [InterfaceFiller_Item] [Info_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item]
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [SurrenderWar_Item] [] [OfferSurrenderWar_Item] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []


VictoryPointInterface_Handler:
    type: world
    debug: false
    events:
        on player clicks iron_sword in PaginatedInterface_Window flagged:warProgress:
        - determine passively cancelled

        - flag <player> datahold.armies.warProgress.kingdom:<player.flag[kingdom]>
        - flag <player> datahold.armies.warProgress.warID:<context.item.flag[warID]>

        - inventory open d:VictoryPoint_Interface

        on player opens VictoryPoint_Interface:
        - define kingdom <player.flag[kingdom]>
        - define warID <player.flag[datahold.armies.warProgress.warID]>
        - define slot <context.inventory.find_item[TideOfWar_Item]>

        - define infoLore <proc[GenerateWarOverviewInfoLore].context[<[kingdom]>|<[warID]>|false]>

        - inventory adjust d:<context.inventory> slot:<[slot]> lore:<[infoLore].values>
        - inventory adjust d:<context.inventory> origin:Info_Item lore:<proc[FormatLore].context[null|<list[<element[Click me for a more detailed breakdown of the war.]>]>]>

        on player clicks Info_Item in VictoryPoint_Interface:
        - determine passively cancelled

        on player closes VictoryPoint_Interface:
        - wait 10t
        - if <player.open_inventory> == <player.inventory>:
            - flag <player> datahold.armies.warProgress:!


GenerateWarOverviewInfoLore:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]|warID[ElementTag(String)]|formatForConsole[ElementTag(Boolean) = false]
    description:
    - Generates a list which represents the lines of the lore which would be attached to the item which displays all the information about the progress of a war
    - Will return null if the action fails.
    - ---
    - → ?[ListTag(ElementTag(String))]

    script:
    - define formatForConsole <[formatForConsole].if_null[false]>

    # Determine which side of the war is the "friendly" side, and which side is the enemy side
    # by looking at whether the player's kingdom is counted as one of the belligerents or
    # retaliators.
    - define enemyKingdoms <[warID].proc[GetWarBelligerents]>
    - define friendlyKingdoms <[warID].proc[GetWarRetaliators]>

    - if <[warID].proc[GetWarBelligerents].contains[<[kingdom]>]>:
        - define enemyKingdoms <[warID].proc[GetWarRetaliators]>
        - define friendlyKingdoms <[warID].proc[GetWarBelligerents]>

    - define friendlyColor <[friendlyKingdoms].get[1].proc[GetKingdomColor]>
    - define enemyColor <[enemyKingdoms].get[1].proc[GetKingdomColor]>

    - define VPVisual <list[<&r><&lb.color[white]>]>
    - define enemyVPVisual <list[<&r><&lb.color[white]>]>
    - define VPs <[friendlyKingdoms].parse_tag[<[parse_value].proc[GenerateVictoryPointOverview].context[<[warID]>].get[totalVPs]>].sum>
    - define enemyVPs <[enemyKingdoms].parse_tag[<[parse_value].proc[GenerateVictoryPointOverview].context[<[warID]>].get[totalVPs]>].sum>

    # Each square in the VP visualizer represents a +/-20 range of victory points. The
    # visualizer will print 20 of these squares with a shaded region representing the +/-20
    # range that the player's kingdom current lies in.
    - repeat 20:
        - if <[VPs].round_to_precision[20]> == <element[<[value].mul[10]>].sub[100]>:
            - define VPVisual:->:<element[▒].color[<[friendlyColor].mix[white]>]>

        - else if <[VPs].round_to_precision[20]> >= <element[<[value].mul[10]>].sub[100]>:
            - define VPVisual:->:<element[▌].color[<[friendlyColor]>]>

        - else:
            - define VPVisual:->:<element[▌].color[white]>

    - define VPVisual:->:]

    # The visualizer will also show the same for the player's enemies.
    - repeat 20:
        - if <[enemyVPs].round_to_precision[20]> == <element[<[value].mul[10]>].sub[100]>:
            - define enemyVPVisual:->:<element[▒].color[<[enemyColor].mix[white]>]>

        - else if <[enemyVPs].round_to_precision[20]> >= <element[<[value].mul[10]>].sub[100]>:
            - define enemyVPVisual:->:<element[▌].color[<[enemyColor]>]>

        - else:
            - define enemyVPVisual:->:<element[▌].color[white]>

    - define enemyVPVisual:->:]

    # This section calculates the amount that each side in the war has captured from the
    # others' outposts in terms of the area captured vs. area not captured.
    #
    # As mentioned in other parts of the war code, it's no good calculating outpost VP
    # contribution using the *number* of outposts captured if a given kingdom has 10 outposts
    # of size 1,000 each, and one massive outpost of size 10,000.
    - define capturedOutpostArea 0
    - define totalEnemyOutpostArea 0

    - foreach <[enemyKingdoms]>:
        - define totalEnemyOutpostArea:+:<[value].proc[GetOutposts].parse_value_tag[<[value].proc[GetOutpostSize].context[<[parse_key]>]>].values.sum>
        - define capturedOutpostArea:+:<[value].proc[GetAllKingdomLostOutposts].context[<[warID]>].parse_tag[<[value].proc[GetOutpostSize].context[<[parse_value]>]>].sum>

    - define lostOutpostArea 0
    - define totalFriendlyOutpostArea 0

    - foreach <[friendlyKingdoms]>:
        - define totalFriendlyOutpostArea:+:<[value].proc[GetOutposts].parse_value_tag[<[value].proc[GetOutpostSize].context[<[parse_key]>]>].values.sum>
        - define lostOutpostArea:+:<[value].proc[GetAllKingdomLostOutposts].context[<[warID]>].parse_tag[<[value].proc[GetOutpostSize].context[<[parse_value]>]>].sum>

    # Big ol' info dump.
    - if <[formatForConsole]>:
        - definemap infoLore:
            0l: <element[Friendly VPs:].color[<[friendlyColor].mix[white]>]>
            02: <[VPVisual].unseparated> <element[~ <[VPs].round_to_precision[0.01]> / 100].color[<[friendlyColor]>]>
            03: <element[Friendly Chunks Lost: ].color[gray]><[friendlyKingdoms].parse_tag[<[parse_value].proc[GetAllKingdomLostChunks].context[<[warID]>].size>].sum.color[aqua]>
            04: <element[Friendly Outpost Area Lost: ].color[gray]><element[<[lostOutpostArea].format_number> / <[totalFriendlyOutpostArea].format_number>].color[aqua]>
            05: <element[Friendly Casualties: ].color[gray]><element[<[friendlyKingdoms].parse_tag[<[parse_value].proc[GetWarDead].context[<[warID]>]>].sum.format_number>].color[red]>
            06: <element[]>
            07: <element[Enemy VPs:].color[<[enemyColor].mix[white]>]>
            08: <[enemyVPVisual].unseparated> <element[~ <[enemyVPs].round_to_precision[0.01]> / 100].color[<[enemyColor]>]>
            09: <element[Enemy Chunks Lost: ].color[gray]><[enemyKingdoms].parse_tag[<[parse_value].proc[GetAllKingdomLostChunks].context[<[warID]>].size>].sum.color[red]>
            10: <element[Enemy Outpost Area Lost: ].color[gray]><element[<[capturedOutpostArea].format_number> / <[totalEnemyOutpostArea].format_number>].color[aqua]>
            11: <element[Enemy Casualties: ].color[gray]><element[<[enemyKingdoms].parse_tag[<[parse_value].proc[GetWarDead].context[<[warID]>]>].sum.format_number>].color[aqua]>
            12: <element[]>
            13: <element[A <element[-100].color[red].underline> score results in an automatic surrender, while a <element[+100].color[aqua].underline> results in an automatic win.].italicize.color[gray]>

    - else:
        - definemap infoLore:
            0l: <element[Friendly VPs:].color[<[friendlyColor].mix[white]>]>
            02: <[VPVisual].unseparated> <element[〰 <[VPs].round_to_precision[0.01]> / 100].color[<[friendlyColor]>]>
            03: <element[Friendly Chunks Lost: ].proc[ConvertToSkinnyLetters].color[gray]><[friendlyKingdoms].parse_tag[<[parse_value].proc[GetAllKingdomLostChunks].context[<[warID]>].size>].sum.proc[ConvertToSkinnyLetters].color[aqua]>
            04: <element[Friendly Outpost Area Lost: ].proc[ConvertToSkinnyLetters].color[gray]><element[<[lostOutpostArea].format_number> / <[totalFriendlyOutpostArea].format_number>].proc[ConvertToSkinnyLetters].color[aqua]>
            05: <element[Friendly Casualties: ].proc[ConvertToSkinnyLetters].color[gray]><element[<[friendlyKingdoms].parse_tag[<[parse_value].proc[GetWarDead].context[<[warID]>]>].sum.format_number>].proc[ConvertToSkinnyLetters].color[red]>
            06: <element[]>
            07: <element[Enemy VPs:].color[<[enemyColor].mix[white]>]>
            08: <[enemyVPVisual].unseparated> <element[〰 <[enemyVPs].round_to_precision[0.01]> / 100].color[<[enemyColor]>]>
            09: <element[Enemy Chunks Lost: ].proc[ConvertToSkinnyLetters].color[gray]><[enemyKingdoms].parse_tag[<[parse_value].proc[GetAllKingdomLostChunks].context[<[warID]>].size>].sum.proc[ConvertToSkinnyLetters].color[red]>
            10: <element[Enemy Outpost Area Lost: ].proc[ConvertToSkinnyLetters].color[gray]><element[<[capturedOutpostArea].format_number> / <[totalEnemyOutpostArea].format_number>].proc[ConvertToSkinnyLetters].color[aqua]>
            11: <element[Enemy Casualties: ].proc[ConvertToSkinnyLetters].color[gray]><element[<[enemyKingdoms].parse_tag[<[parse_value].proc[GetWarDead].context[<[warID]>]>].sum.format_number>].proc[ConvertToSkinnyLetters].color[aqua]>
            12: <element[]>
            13: <element[A <element[-100].color[red].underline> score results in an automatic surrender,].italicize.color[gray]>
            14: <element[while a <element[+100].color[aqua].underline> results in an automatic win.].italicize.color[gray]>

    - determine <[infoLore]>


GetLostChunksProportion:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]|warID[ElementTag(String)]
    description:
    - Generates a decimal value between 0 and 1 indicating the percentage of a given kingdom's chunks it has lost during a war.
    - This value is then adjusted by 25%. The reason for this is because when a kingdom has +100VPs in a war, the war is auto-won. Since I don't want wars to be entirely determined by chunk capture, this should entice players to focus on other ways to defeat their enemies.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Generates a decimal value between 0 and 1 indicating the percentage of a given kingdom's
    ## chunks it has lost during a war.
    ##
    ## This value is then adjusted by 25%. The reason for this is because when a kingdom has
    ## +100VPs in a war, the war is auto-won. Since I don't want wars to be entirely determined by
    ## chunk capture, this should entice players to focus on other ways to defeat their enemies.
    ##
    ## kingdom : [ElementTag(String)]
    ## warID   : [ElementTag(String)]
    ##
    ## >>> [ElementTag(Float)]

    # The percentage of the kingdom's total chunks that have been lost in the current war.
    - define lostChunks <[kingdom].proc[GetAllKingdomLostChunks].context[<[warID]>]>
    - define lostChunkProportion <[lostChunks].size.div[<[kingdom].proc[GetClaims].size>].if_null[0].round_to_precision[0.001]>

    # Basically, a kingdom shouldn't have to lose all of its chunks to be forced into unconditional
    # surrender.
    #
    # Note: future configurable.
    - define adjustedChunkProportion <[lostChunkProportion].mul[1.25].round_to_precision[0.001]>
    - define adjustedChunkProportion 1 if:<[adjustedChunkProportion].is[MORE].than[1]>

    - determine <[adjustedChunkProportion]>


GetLostOutpostsProportion:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]|warID[ElementTag(String)]
    description:
    - Generates a decimal value between 0 and 1 indicating the percentage of outpost territory that a given kingdom has lost in a war.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Generates a decimal value between 0 and 1 indicating the percentage of outpost territory
    ## that a given kingdom has lost in a war.
    ##
    ## kingdom : [ElementTag(String)]
    ## warID   : [ElementTag(String)]
    ##
    ## >>> [ElementTag(Float)]

    - define lostOutposts <[kingdom].proc[GetAllKingdomLostOutposts].context[<[warID]>]>
    - define kingdomOutposts <[kingdom].proc[GetOutposts]>
    - define lostOutpostSizes <map[]>

    - foreach <[lostOutposts]>:
        - define lostOutpostSizes.<[value]>:<[kingdom].proc[GetOutpostSize].context[<[value]>]>

    - define allOutpostSizes <[kingdomOutposts].parse_value_tag[<[kingdom].proc[GetOutpostSize].context[<[parse_key]>]>]>

    - define lostOutpostProportion 0
    - define lostOutpostProportion <[allOutpostSizes].values.sum.div[<[lostOutpostSizes].values.sum>]> if:<[lostOutpostSizes].is_empty.not>

    - determine <[lostOutpostProportion]>


GetCapturedChunksProportion:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]|warID[ElementTag(String)]
    description:
    - Returns a MapTag where the keys are kingdoms that oppose the provided kingdom a given war, and the values are the percentage of chunk territory that each opposing kingdom has lost to the given kingdom represented as a decimal between 0 and 1.
    - 25% adjustments are applied to the values here, just as they are in `GetLostChunksProportion`.
    - ---
    - → [MapTag(ElementTag(Float))]

    script:
    ## Returns a MapTag where the keys are kingdoms that oppose the provided kingdom a given war,
    ## and the values are the percentage of chunk territory that each opposing kingdom has lost to
    ## the given kingdom represented as a decimal between 0 and 1.
    ##
    ## 25% adjustments are applied to the values here, just as they are in
    ## `GetLostChunksProportion`.
    ##
    ## kingdom : [ElementTag(String)]
    ## warID   : [ElementTag(String)]
    ##
    ## >>> [MapTag(ElementTag(Float))]

    # Calculate VP surplus; These are all of the things that contribute to a kingdom's VP total.
    # The capturedChunks Map's keys are the kingdom the given kingdom captured the chunk from,
    # while the chunk itself is the value.
    - define capturedChunks <map[]>

    - foreach <proc[GetAllLostChunks].context[<[warID]>]> key:occupiedKingdom as:occupiers:
        - if !<[occupiers].contains[<[kingdom]>]>:
            - foreach next

        # This is the percentage of chunks that the provided kingdom captured from each other
        # kingdom that it's in conflict with in this war.
        - define capturedChunks.<[occupiedKingdom]>:<[occupiers].get[<[kingdom]>].size.div[<[occupiedKingdom].proc[GetClaims].size>].round_to_precision[0.001]>

    - determine <[capturedChunks]>


GetCapturedOutpostsProportion:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]|warID[ElementTag(String)]
    description:
    - Returns a list of MapTags where the values of each Map include the name of each outpost the given kingdom has captured in a war, their original owner, the proportion of that outpost's size against the opposing kingdom's total outpost size, and the proportion of manpower that the provided kingdom contributed to the capture of each outpost.
    - ---
    - → [ListTag(MapTag(ElementTag(String);ElementTag(Float)))]

    script:
    ## Returns a list of MapTags where the values of each Map include the name of each outpost the
    ## given kingdom has captured in a war, their original owner, the proportion of that outpost's
    ## size against the opposing kingdom's total outpost size, and the proportion of manpower that
    ## the provided kingdom contributed to the capture of each outpost.
    ##
    ## kingdom : [ElementTag(String)]
    ## warID   : [ElementTag(String)]
    ##
    ## >>> [ListTag(MapTag(ElementTag(String);ElementTag(Float)))]

    - define forceBreakdown <[warID].proc[GetAllLostOutposts].parse_tag[<map[name=<[parse_value].keys.get[1]>;owner=<[parse_value].values.get[1]>;breakdown=<[warID].proc[GetLostOutpostManpowerBreakdown].context[<[parse_value].keys.get[1]>]>]>]>
    - define outpostProportions <list[]>

    - foreach <[forceBreakdown]>:
        # If the provided kingdom was not involved in the capture of the current outpost then skip
        - if <[value].get[breakdown].filter_tag[<[filter_value].get[kingdom].equals[<[kingdom]>]>].is_empty>:
            - foreach next

        - define manpowerContribution 0

        - foreach <[value].get[breakdown]> key:squadName as:squadInfo:
            - if <[squadInfo].get[kingdom]> == <[kingdom]>:
                - define manpowerContribution:+:<[squadInfo].get[forceRatio]>

        - define outpostSizeSum <[value].get[owner].proc[GetOutposts].parse_value_tag[<[value].get[owner].proc[GetOutpostSize].context[<[parse_key]>]>].values.sum>

        # Note: sizeRatio is the percentage that this outpost makes of all the kingdom's outposts'
        # sizes. Eg. if there are 4 outposts with a total size of 4000, and this outpost's size is
        # 1000, then the sizeRatio should be 0.25
        - define outpostProportions:->:<map[name=<[value].get[name]>;owner=<[value].get[owner]>;sizeRatio=<[outpostSizeSum].div[<[value].get[owner].proc[GetOutpostSize].context[<[value].get[name]>]>]>;proportion=<[manpowerContribution]>]>

    - determine <[outpostProportions]>


GenerateVictoryPointOverview:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]|warID[ElementTag(String)]
    description:
    - Returns a MapTag containing various victory point breakdowns of each dimension of warfare progress that Kingdoms tracks such as chunks gained, chunks lost, outposts gained, outposts lost, kills, losses, etc.
    - ---
    - → [MapTag]

    script:
    ## Returns a MapTag containing various victory point breakdowns of each dimension of warfare
    ## progress that Kingdoms tracks such as chunks gained, chunks lost, outposts gained, outposts
    ## lost, kills, losses, etc.
    ##
    ## kingdom : [ElementTag(String)]
    ## warID   : [ElementTag(String)]
    ##
    ## >>> [MapTag]

    - define lostChunkVPRatio <[kingdom].proc[GetLostChunksProportion].context[<[warID]>].mul[0.65]>
    - define lostOutpostVPRatio <[kingdom].proc[GetLostOutpostsProportion].context[<[warID]>].mul[0.45]>
    - define capturedChunksRatioMap <[kingdom].proc[GetCapturedChunksProportion].context[<[warID]>]>
    - define capturedOutpostsRatioMap <[kingdom].proc[GetCapturedOutpostsProportion].context[<[warID]>]>

    # TODO: Once populations are implemented, work the kill count into the VP calculation by making
    # TODO/ a function of kills vs. total population & player count.
    - define kills 0

    - foreach <[warID].proc[GetWarParticipants].exclude[<[kingdom]>]> as:participant:
        - define kills:+:<[participant].proc[GetWarDead].context[<[warID]>].get[<[kingdom]>].if_null[0]>

    - define negativeVPs <[lostChunkVPRatio].mul[100].add[<[lostOutpostVPRatio]>]>
    - define positiveVPs 0

    - foreach <[capturedChunksRatioMap]>:
        - define positiveVPs:+:<[value].mul[0.65].div[<[capturedChunksRatioMap].size>].mul[100]>

    - foreach <[capturedOutpostsRatioMap]>:
        - define positiveVPs:+:<[value].get[sizeRatio].mul[<[value].get[proportion]>].mul[0.45].mul[100]>

    - definemap determination:
        lostChunkVPRatio : <[lostChunkVPRatio]>
        lostOutpostVPRatio : <[lostOutpostVPRatio]>
        capturedChunksRatioMap : <[capturedChunksRatioMap]>
        capturedOutpostsRatioMap : <[capturedOutpostsRatioMap]>
        kills: <[kills]>
        positiveVPs: <[positiveVPs]>
        negativeVPs: <[negativeVPs]>
        totalVPs: <[positiveVPs].sub[<[negativeVPs]>]>

    - determine <[determination]>


PlayerWarDeath_Handler:
    type: world
    debug: false
    events:
        on player dies:
        - if <player.proc[IsPlayerKingdomless]>:
            - stop

        - define kingdom <player.flag[kingdom]>

        - if <context.damager.has_flag[kingdom]>:
            - run AddWarDead def.affectedKingdom:<[kingdom]> def.inflictingKingdom:<context.damager.flag[kingdom]> def.amount:10
