##
## This file contains scripts which handle player interaction permissions within kingdom territory.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jun 2021
## @Update 1: Oct 2023
## @Update 2: Jun 2024
## @Script Ver: v3.2
##
## ------------------------------------------END HEADER-------------------------------------------

IsInOwnDuchy:
    type: procedure
    debug: false
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

    - if <player.proc[IsPlayerKingdomless]>:
        - determine false

    - define kingdom <[player].flag[kingdom]>

    - foreach <[kingdom].proc[GetKingdomDuchies]> as:duchy:
        - if <proc[GetDuke].context[<[kingdom]>|<[duchy]>]> == <[player]>:
            - define duchyTerritory <proc[GetDuchyTerritory].context[<[kingdom]>|<[duchy]>]>

            - determine <[player].location.chunk.is_in[<[duchyTerritory]>]>

    - determine false


IsInAnyDuchy:
    type: procedure
    debug: false
    definitions: player[PlayerTag]
    description:
    - Returns true if the provided player is currently inside any of their kingdom's duchies.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns true if the provided player is currently inside any of their kingdom's duchies.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [ElementTag<Boolean>]

    - if <player.proc[IsPlayerKingdomless]>:
        - determine false

    - define kingdom <[player].flag[kingdom]>

    - foreach <[kingdom].proc[GetKingdomDuchies]> as:duchy:
        - if <player.location.chunk.is_in[<proc[GetDuchyTerritory].context[<[kingdom]>|<[duchy]>]>]>:
            - determine true

    - determine false


DoorInteractCode:
    type: task
    debug: false
    script:
    - if <player.has_permission[kingdoms.admin.bypassclickcheck]>:
        - stop

    - if !<proc[GetAllClaims].contains[<context.location.chunk>]>:
        - stop

    - if <player.proc[IsInOwnDuchy]>:
        - stop

    - if <player.proc[IsInAnyDuchy]>:
        # TODO: Insert logic for checking if the player has been allowed by the duke to use
        # TODO/ their land.
        - determine cancelled

    # If the player is kingdomless and has done an action within *any* kingdom's claims or outposts
    # then immediately cancel the behaviour.
    - if <player.proc[IsPlayerKingdomless]>:
        - if <proc[GetAllClaims].contains[<player.location.chunk>]>:
            - determine cancelled

        - foreach <proc[GetAllOutposts].parse_value_tag[<[parse_value].get[area]>].values>:
            - if <[value].contains[<player.location>]>:
                - determine cancelled

    - define kingdom <player.flag[kingdom]>

    # If the player is within their own kingdom's claims then ignore.
    - if <proc[GetClaims].context[<[kingdom]>].contains[<player.location.chunk>]>:
        - stop

    # If the player is within the claims or outposts of any kingdom other than their own then
    # cancel the action.
    - foreach <proc[GetKingdomList].exclude[<[kingdom]>]>:

        # Skip if the player is not in the chunk.
        - if !<proc[GetClaims].context[<[kingdom]>|core].is_in[<player.location.chunk>]>:
            - foreach next

        - if !<[value].proc[GetKingdomWarStatus]>:
            - determine cancelled

        # If the player's kingdom is at war with the kingdom that owns the current chunk then
        # ignore and allow them to tamper with their doors.
        - else:
            - foreach <[value].proc[GetKingdomWars]> as:warID:
                - if <[warID].proc[GetWarParticipants].contains[<[value]>]>:
                    - stop

            - determine cancelled

    # If the player is in their own outpost territory then ignore.
    - foreach <[kingdom].proc[GetOutposts].keys.if_null[<list[]>]>:
        - if <cuboid[<[value]>].players.contains[<player>]>:
            - stop

    - determine cancelled


TerritoryHandler:
    type: world
    debug: false
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
        #- If player has taken damage within their own core/castle territory or within their own
        #- outpost then cancel the damage event.

        - if !<context.entity.is_player>:
            - stop

        - else if <context.entity.proc[IsPlayerKingdomless]>:
            - if <proc[GetAllClaims].contains[<player.location.chunk>]>:
                - determine cancelled

            - foreach <proc[GetAllOutposts].parse_value_tag[<[parse_value].get[area]>].values>:
                - if <[value].contains[<player.location>]>:
                    - determine cancelled

            - stop

        - define belligerent <context.entity>
        - define belligerentKingdom <context.entity.flag[kingdom]>
        - define castleCore <[belligerentKingdom].proc[GetClaims]>

        - if <player.proc[IsPlayerKingdomless]>:
            - stop

        - define kingdom <player.flag[kingdom]>

        - if <[kingdom].proc[GetKingdomWarStatus]>:
            - stop

        - define castleCore <[belligerentKingdom].proc[GetClaims]>

        - foreach <[castleCore]>:
            - if <[value]> == <context.location.chunk>:
                - determine cancelled

        - foreach <[kingdom].proc[GetOutposts]>:
            - if <[value].get[area].contains[<player.location>]>:
                - determine cancelled

        on player empties bucket:
        - if <player.has_permission[kingdoms.admin.bypassrc]>:
            - stop

        - if <player.proc[IsInAnyDuchy]>:
            - if <player.proc[IsInOwnDuchy]>:
                - stop

            # TODO: Insert logic for checking if the player has been allowed by the duke to use
            # TODO/ their land.

            - determine cancelled

        # If the player is kingdomless and has done an action within *any* kingdom's claims or outposts
        # then immediately cancel the behaviour.
        - if <player.proc[IsPlayerKingdomless]>:
            - if <proc[GetAllClaims].contains[<player.location.chunk>]>:
                - determine cancelled

            - foreach <proc[GetAllOutposts].parse_value_tag[<[parse_value].get[area]>].values>:
                - if <[value].contains[<player.location>]>:
                    - determine cancelled

            - stop

        - define kingdom <player.flag[kingdom]>
        - define castleCore <[kingdom].proc[GetClaims]>
        - define inOwnTerritory false

        - foreach <[castleCore]>:
            - if <[value]> == <context.location.chunk>:
                - define inOwnTerritory true
                - foreach stop

        - if !<[inOwnTerritory]>:
            - foreach <[kingdom].proc[GetOutposts]> key:outpost:
                - if <[kingdom].proc[GetOutpostArea].context[<[outpost]>].players.contains[<player>]>:
                    - stop

            - determine cancelled

        - if !<proc[GetAllClaims].contains[<context.location.chunk>]>:
            - stop

        on player places block:
        - if <player.has_permission[kingdoms.admin.bypassrc]>:
            - stop

        # If the player is kingdomless and has done an action within *any* kingdom's claims or outposts
        # then immediately cancel the behaviour.
        - if <player.proc[IsPlayerKingdomless]>:
            - if <proc[GetAllClaims].contains[<player.location.chunk>]>:
                - determine cancelled

            - foreach <proc[GetAllOutposts].parse_value_tag[<[parse_value].get[area]>].values>:
                - if <[value].contains[<player.location>]>:
                    - determine cancelled

            - stop

        - define kingdom <player.flag[kingdom]>
        - define castleCore <[kingdom].proc[GetClaims]>

        - if <player.proc[IsInAnyDuchy]>:
            - if <player.proc[IsInOwnDuchy]>:
                - stop

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

        - if <[kingdom].proc[GetOutposts].size.if_null[0]> != 0:
            - foreach <[kingdom].proc[GetOutposts]>:
                - if <[value].get[area].contains[<player.location>]>:
                    - stop

        - if !<proc[GetAllClaims].contains[<context.location.chunk>]>:
            - stop

        - determine cancelled

        on player breaks block:
        - if <player.has_permission[kingdoms.admin.bypassrc]>:
            - stop

        # If the player is kingdomless and has done an action within *any* kingdom's claims or outposts
        # then immediately cancel the behaviour.
        - if <player.proc[IsPlayerKingdomless]>:
            - if <proc[GetAllClaims].contains[<player.location.chunk>]>:
                - determine cancelled

            - foreach <proc[GetAllOutposts].parse_value_tag[<[parse_value].get[area]>].values>:
                - if <[value].contains[<player.location>]>:
                    - determine cancelled

            - stop

        - define kingdom <player.flag[kingdom]>
        - define castleCore <[kingdom].proc[GetClaims]>

        - if <player.proc[IsInAnyDuchy]>:
            - if <player.proc[IsInOwnDuchy]>:
                - stop

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

        - if <[kingdom].proc[GetOutposts].size.if_null[0]> != 0:
            - foreach <[kingdom].proc[GetOutposts]>:
                - if <[value].get[area].contains[<player.location>]>:
                    - stop

        - if !<proc[GetAllClaims].contains[<context.location.chunk>]>:
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
