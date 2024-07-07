##
## Scripts in this file relate to the area designtor- a common tool which allows scripters to
## expedite and standardize the process of creating an area using an in-world 'designation wand'
##
## Kingdoms involves a lot of area designation, and I have often changed entire script designs to
## avoid having to reinvent the area designation process all over again. This tool should help make
## this process easier.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jul 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

PolygonWand_Item:
    type: item
    material: spectral_arrow
    display name: <gold><bold>Polygon Wand


CuboidWand_Item:
    type: item
    material: spectral_arrow
    display name: <gold><bold>Cuboid Wand


StartPolygonDesignation:
    type: task
    definitions: player[`PlayerTag`]
    description:
    - Clears the provided player's inventory and gives them the polygon wand.
    - ---
    - `→ [Void]`

    script:
    ## Clears the provided player's inventory and gives them the polygon wand.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [Void]

    - if !<[player].is_player>:
        - stop

    - run TempSaveInventory def.player:<[player]>

    - inventory set slot:1 origin:PolygonWand_Item
    - adjust <[player]> item_slot:1

    - flag <[player]> datahold.designatingPolygon:<list[]>


FinishPolygonDesignation:
    type: task
    definitions: player[`PlayerTag`]|minY[`?ElementTag(Integer)`]|maxY[`?ElementTag(Integer)`]
    description:
    - Returns the provided player's inventory and takes the polygon wand. Will then return the list of corners that the player designated.
    - Alternatively, if the `minY` & `maxY` arguments are provided, the task will create the PolygonTag corresponding to the player's selection.
    - ---
    - `→ ?[Union[PolygonTag / ListTag(LocationTag)]]`

    script:
    ## Returns the provided player's inventory and takes the polygon wand.
    ##
    ## player :  [PlayerTag]
    ## minY   : ?[ElementTag<Integer>]
    ## maxY   : ?[ElementTag<Integer>]
    ##
    ## >>> ?[Union[PolygonTag / ListTag<LocationTag>]]

    - if !<[player].is_player>:
        - determine null

    - run LoadTempInventory def.player:<[player]>

    - define determination <[player].flag[datahold.designatingPolygon]>

    - if <[minY].exists> || <[maxY].exists>:
        - define minY <[minY].if_null[<[player].location.world.min_height>]>
        - define maxY <[maxY].if_null[<[player].location.world.max_height>]>
        - define cornersFormatted <list[]>

        - foreach <[player].flag[datahold.designatingPolygon]> as:corner:
            - if !<[corner].x.exists>:
                - foreach next

            - define cornersFormatted:->:<[corner].x>
            - define cornersFormatted:->:<[corner].z>

        - define determination <polygon[<[player].location.world.name>,<[minY]>,<[maxY]>,<[cornersFormatted].comma_separated.replace[ ].with[]>]>

    - run CancelAllShowfakes def.__player:<[player]>

    - flag <[player]> datahold.designatingPolygon:!
    - determine <[determination]>


RefreshPolygonPoints:
    type: task
    definitions: player[PlayerTag]
    script:
    - foreach <[player].flag[datahold.designatingPolygon].if_null[<list[]>]> as:point:
        - showfake red_stained_glass <[point]> d:100s players:<[player]>


PolygonDesignation_Handler:
    type: world
    events:
        on player clicks block with:PolygonWand_Item flagged:datahold.designatingPolygon:
        - if <context.location.exists>:
            - flag <player> datahold.designatingPolygon:->:<context.location>

            - ~run RefreshPolygonPoints def.player:<player>

        on player drops PolygonWand_Item flagged:datahold.designatingPolygon:
        - narrate format:callout "Cancelled polygon designation process!"

        - run FinishPolygonDesignation def.player:<player>
        - determine passively cancelled
