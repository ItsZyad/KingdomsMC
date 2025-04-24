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
    events:
        on player clicks iron_sword in PaginatedInterface_Window flagged:warProgress:
        - flag <player> datahold.armies.warProgress.kingdom:<player.flag[kingdom]>
        - flag <player> datahold.armies.warProgress.warID:<context.item.flag[warID]>

        - inventory open d:VictoryPoint_Interface

        on player clicks item in VictoryPoint_Interface:
        - narrate format:debug WIP
        - run flagvisualizer def.flag:<player.flag[datahold.armies]>

        on player closes VictoryPoint_Interface:
        - wait 10t
        - if <player.open_inventory> == <player.inventory>:
            - flag <player> datahold.armies.warProgress:!


CalculateVictoryPoints:
    type: task
    definitions: kingdom[ElementTag(String)]|warID[ElementTag(String)]
    description:
    - Returns a value between -100 and 100 representing how close the given kingdom is to auto-winning or auto-losing the war with the given warID.
    - Will return null if the action fails.
    - ---
    - → ?[ElementTag(Float)]

    script:
    ## Returns a value between -100 and 100 representing how close the given kingdom is to auto-
    ## winning or auto-losing the war with the given warID.
    ##
    ## kingdom : [ElementTag(String)]
    ## warID   : [ElementTag(String)]
    ##
    ## >>> ?[ElementTag(Float)]

    # Calculate VP deficit; These are all of the things that the given kingdom has lost throughout
    # the war. This will be the amount deducted from the kingdom's total victory points.
    - define lostChunks <[kingdom].proc[GetAllKingdomLostChunks].context[<[warID]>]>
    - define lostOutposts <[kingdom].proc[GetAllKingdomLostOutposts].context[<[warID]>]>
    - define warDead 400
    - define playerDeaths 3

    - define lostChunksProportion <[lostChunks].size.div[<[kingdom].proc[GetClaims].size>]>
    - define lostChunksProportion 0 if:<[lostChunksProportion].is_decimal.not>
    - define lostOutpostsProportion <[lostOutposts].size.div[<[kingdom].proc[GetOutposts].size>]>
    - define lostOutpostsProportion 0 if:<[lostOutpostsProportion].is_decimal.not>

    # TODO: When pops are implemented, this should a ratio of the total number of kingdom subjects
    - define warDeadProportion <[warDead].mul[0.01]>
    - define playerDeathsProportion <[playerDeaths].div[<[kingdom].proc[GetMembers].size>]>
    - define playerDeathsProportion 0 if:<[playerDeathsProportion].is_decimal.not>

    - define VPDeficit <[lostChunksProportion].mul[0.25].add[<[lostOutpostsProportion].mul[0.5]>].add[<[warDeadProportion]>].add[<[playerDeathsProportion]>]>

    # Calculate VP surplus; These are all of the things that contribute to a kingdom's VP total.
    # The capturedChunks Map's keys are the kingdom the given kingdom captured the chunk from,
    # while the chunk itself is the value.
    - define capturedChunks <map[]>

    - foreach <proc[GetAllLostChunks].context[<[warID]>]> key:occupiedKingdom as:occupiers:
        - if <[occupiers].contains[<[kingdom]>]>:
            - foreach <[occupiers].get[<[kingdom]>]>:
                - define capturedChunks.<[occupiedKingdom]>:->:<[value]>

    # TODO:
    # It should calculate contribution to the capture of each outpost by the ratio of total units
    # involved in its captured belonging to the given kingdom.
    #
    # For example if 100 units took part in its capture and <[kingdom]> contributed 50% of them,
    # then it gets 50% of the VPs offered by the outpost.
    - define capturedOutposts <[warID].proc[GetAllLostOutposts]>

    - run flagvisualizer def.flag:<queue.definition_map> def.flagName:defMap
