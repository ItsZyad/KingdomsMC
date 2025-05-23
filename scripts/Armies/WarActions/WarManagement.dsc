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
    display name: <aqua><bold>Offer Surrender
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
    - [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [TideOfWar_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item]
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
        - flag <player> datahold.armies.warProgress.kingdom:<player.flag[kingdom]>
        - flag <player> datahold.armies.warProgress.warID:<context.item.flag[warID]>

        - inventory open d:VictoryPoint_Interface

        on player opens VictoryPoint_Interface:
        - define slot <context.inventory.find_item[TideOfWar_Item]>
        - define kingdom <player.flag[kingdom]>

        ## These will continue to be placeholder values until I finalize this code.
        - define index 1
        - define VPs 14
        - define enemyVPs 18
        - define blockVPs <list[]>

        - repeat <[VPs]>:
            - define blockVPs:->:<element[▌].color[<proc[GetKingdomColor].context[<[kingdom]>]>]>

            - if <[index].mod[25]> == 0 && <[index]> != 0:
                - define blockVPs:->:<n>

            - define index:++

        - repeat <element[200].sub[<[VPs]>].sub[<[enemyVPs]>]>:
            - define blockVPs:->:<element[▌].color[white]>

            - if <[index].mod[25]> == 0:
                - define blockVPs:->:<n>

            - define index:++

        - repeat <[enemyVPs]>:
            - define blockVPs:->:<element[▌].color[gray]>

            - if <[index].mod[25]> == 0:
                - define blockVPs:->:<n>

            - define index:++

        - inventory adjust d:<context.inventory> slot:<[slot]> lore:<&r><[blockVPs].unseparated>

        on player clicks item in VictoryPoint_Interface:
        - narrate format:debug WIP
        - run flagvisualizer def.flag:<player.flag[datahold.armies]>

        on player closes VictoryPoint_Interface:
        - wait 10t
        - if <player.open_inventory> == <player.inventory>:
            - flag <player> datahold.armies.warProgress:!


GetLostChunksProportion:
    type: procedure
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
    type: task
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

    - determine <[determination]>


PlayerWarDeath_Handler:
    type: world
    debug: false
    events:
        on player dies:
        - if !<player.has_flag[kingdom]>:
            - stop

        - define kingdom <player.flag[kingdom]>

        - if <context.damager.has_flag[kingdom]>:
            - run AddWarDead def.affectedKingdom:<[kingdom]> def.inflictingKingdom:<context.damager.flag[kingdom]> def.amount:10
