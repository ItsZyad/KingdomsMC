##
## This file contains scripts which handle player interaction permissions within kingdom territory.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jun 2021
## @Update 1: Oct 2023
## @Update 2: Jun 2024
## @Script Ver: v3.0
##
## ------------------------------------------END HEADER-------------------------------------------

IsInOwnDuchy:
    type: procedure
    definitions: player[PlayerTag]
    description:
    - Returns true if the provided player is currently inside their own duchy's territory.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns true if the provided player is currently inside their own duchy's territory.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [ElementTag<Boolean>]

    - define kingdom <[player].flag[kingdom]>

    - foreach <[kingdom].proc[GetKingdomDuchies]> as:duchy:
        - if <proc[GetDuke].context[<[kingdom]>|<[duchy]>]> == <[player]>:
            - define duchyTerritory <proc[GetDuchyTerritory].context[<[kingdom]>|<[duchy]>]>

            - determine <[player].location.chunk.is_in[<[duchyTerritory]>]>

    - determine false


IsInAnyDuchy:
    type: procedure
    definitions: player[PlayerTag]
    script:
    - define kingdom <[player].flag[kingdom]>

    - foreach <[kingdom].proc[GetKingdomDuchies]> as:duchy:
        - if <player.location.chunk.is_in[<proc[GetDuchyTerritory].context[<[kingdom]>|<[duchy]>]>]>:
            - determine true

    - determine false


DoorInteractCode:
    type: task
    #debug: false
    script:
    - if <player.has_permission[kingdoms.admin.bypassclickcheck]>:
        - stop

    - if !<proc[GetAllClaims].contains[<context.location.chunk>]>:
        - stop

    - define kingdom <player.flag[kingdom]>

    - if <player.proc[IsInOwnDuchy]>:
        - stop

    - if <player.proc[IsInAnyDuchy]>:
        # TODO: Insert logic for checking if the player has been allowed by the duke to use
        # TODO/ their land.
        - determine cancelled

    - if <proc[GetClaims].context[<[kingdom]>].contains[<player.location.chunk>]>:
        - stop

    - foreach <proc[GetKingdomList].exclude[<[kingdom]>]>:
        - if !<proc[GetClaims].context[<[kingdom]>|core].is_in[<player.location.chunk>]>:
            - foreach next

        - if !<[value].proc[GetKingdomWarStatus]>:
            - determine cancelled

        - else:
            - foreach <[value].proc[GetKingdomWars]> as:warID:
                - if <[warID].proc[GetWarParticipants].contains[<[value]>]>:
                    - stop

            - determine cancelled

    - foreach <[kingdom].proc[GetOutposts].keys.if_null[<list[]>]>:
        - if <cuboid[<[value]>].players.contains[<player>]>:
            - stop

    - determine cancelled


TerritoryHandler:
    type: world
    events:
        on player right clicks *button:
        - inject DoorInteractCode

        on player right clicks *gate:
        - inject DoorInteractCode

        on player right clicks *door:
        - inject DoorInteractCode

        on player right clicks *trapdoor:
        - inject DoorInteractCode

        on player damaged by entity:
        # If player has taken damage within their own core/castle
        # territory or within their own outpost then cancel the
        # damage event.

        - if !<context.entity.is_player>:
            - stop

        - define belligerent <context.entity>
        - define belligerentKingdom <context.entity.flag[kingdom]>
        - define castleCore <[belligerentKingdom].proc[GetClaims]>

        - if !<player.has_flag[kingdom]>:
            - stop

        - define kingdom <player.flag[kingdom]>

        - if <[kingdom].proc[GetKingdomWarStatus]>:
            - stop

        - define castleCore <[belligerentKingdom].proc[GetClaims]>

        - foreach <[castleCore]>:
            - if <[value].cuboid.contains[<context.entity.location>]>:
                - determine cancelled

        - foreach <[kingdom].proc[GetOutposts].keys>:
            - if <cuboid[<[value]>].players.contains[<player>]>:
                - determine cancelled

        on player empties bucket:
        - if !<proc[GetAllClaims].contains[<context.location.chunk>]>:
            - stop

        - if !<player.has_flag[kingdom]>:
            - determine cancelled

        - define kingdom <player.flag[kingdom]>

        - if <player.has_permission[kingdoms.admin.bypassrc]>:
            - stop

        - define castleCore <[kingdom].proc[GetClaims]>
        - define inOwnTerritory false

        - foreach <[castleCore]>:
            - if <[value].cuboid.contains[<context.location>]>:
                - define inOwnTerritory true
                - foreach stop

        - if !<[inOwnTerritory]>:
            - determine cancelled

        - else:
            - foreach <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys>:
                - if <cuboid[<[value]>].players.contains[<player>]>:
                    - determine cancelled

        on player places block:
        - if <player.has_permission[kingdoms.admin.bypassrc]>:
            - stop

        - if !<proc[GetAllClaims].contains[<context.location.chunk>]>:
            - stop

        - if !<player.has_flag[kingdom]>:
            - determine cancelled

        - define kingdom <player.flag[kingdom]>
        - define castleCore <[kingdom].proc[GetClaims]>

        - if <player.proc[IsInOwnDuchy]>:
            - stop

        - if <player.proc[IsInAnyDuchy]>:
            # TODO: Insert logic for checking if the player has been allowed by the duke to use
            # TODO/ their land.
            - determine cancelled

        - if <context.location.chunk.is_in[<[castleCore]>]>:
            - stop

        - foreach <proc[GetKingdomList].exclude[<[kingdom]>]>:
            - if !<[value].proc[GetKingdomWarStatus]>:
                - determine cancelled

            - else:
                - foreach <[value].proc[GetKingdomWars]> as:warID:
                    - if <[warID].proc[GetWarParticipants].contains[<[value]>]>:
                        - stop

                - determine cancelled

        - else if <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys.size.if_null[0]> != 0:
            - foreach <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys>:
                - if <cuboid[<[value]>].players.contains[<player>]>:
                    - stop

        - determine cancelled

        on player breaks block:
        - if <player.has_permission[kingdoms.admin.bypassrc]>:
            - stop

        - if !<proc[GetAllClaims].contains[<context.location.chunk>]>:
            - stop

        - if !<player.has_flag[kingdom]>:
            - determine cancelled

        - define kingdom <player.flag[kingdom]>
        - define castleCore <[kingdom].proc[GetClaims]>

        - if <player.proc[IsInOwnDuchy]>:
            - stop

        - if <player.proc[IsInAnyDuchy]>:
            # TODO: Insert logic for checking if the player has been allowed by the duke to use
            # TODO/ their land.
            - determine cancelled

        - if <context.location.chunk.is_in[<[castleCore]>]>:
            - stop

        - foreach <proc[GetKingdomList].exclude[<[kingdom]>]>:
            - if !<[value].proc[GetKingdomWarStatus]>:
                - determine cancelled

            - else:
                - foreach <[value].proc[GetKingdomWars]> as:warID:
                    - if <[warID].proc[GetWarParticipants].contains[<[value]>]>:
                        - stop

                - determine cancelled

        - else if <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys.size.if_null[0]> != 0:
            - foreach <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys>:
                - if <cuboid[<[value]>].players.contains[<player>]>:
                    - stop

        - determine cancelled


EntityTerritoryHandler:
    type: world
    debug: false
    events:
        on spawner spawns entity:
        - if <server.has_flag[PreGameStart]>:
            - determine cancelled

        on entity spawns:
        - define blockedSpawnTypes <list[NATURAL|LIGHTNING|SPAWNER|JOCKEY]>

        - if <[blockedSpawnTypes].contains[<context.reason>]>:
            - define allClaims <proc[GetAllClaims].parse_tag[<[parse_value].cuboid>]>

            - if <context.location.chunk.is_in[<[allClaims]>]>:
                - determine cancelled

        on entity explodes:
        - define kingdomList <proc[GetKingdomList].context[true]>

        - foreach <[kingdomList]> as:kingdom:
            - foreach <[kingdom].proc[GetClaims]>:
                - if <[value].cuboid.contains[<context.location>]>:
                    - if <[kingdom].proc[GetKingdomWarStatus]> != true:
                        - determine cancelled
                        - foreach stop
