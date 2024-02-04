##
## This file contains scripts which handle player interaction permissions within kingdom territory.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jun 2021
## @Updated: Oct 2023
## @Script Ver: v2.0
##
## ------------------------------------------END HEADER-------------------------------------------


DoorInteractCode:
    type: task
    debug: false
    script:
    - if <player.has_permission[kingdoms.admin.bypassclickcheck]>:
        - stop

    - if !<server.flag[kingdoms.claimInfo.allClaims].contains[<context.location.chunk>]>:
        - stop

    - define kingdom <player.flag[kingdom]>

    - if !<server.flag[kingdoms.<[kingdom]>.warStatus]>:
        - define castleCore <proc[GetClaims].context[<[kingdom]>]>

        - if <[castleCore].filter_tag[<[filter_value].equals[<player.location.chunk>]>].size> != 0:
            - stop

        - foreach <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys.if_null[<list[]>]>:
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

        # on player opens inventory:
        # - define kingdom <player.flag[kingdom]>
        # - define core <server.flag[kingdoms.<[kingdom]>.claims.core].if_null[<list[]>]>
        # - define castle <server.flag[kingdoms.<[kingdom]>.claims.castle].if_null[<list[]>]>
        # - define castleCore <[core].include[<[castle]>].parse_tag[<[parse_value].cuboid>]>

        # - if <context.inventory.script.exists>:
        #     - stop

        # - if <player.cursor_on>

        on player damaged by entity:
        # If player has taken damage within their own core/castle
        # territory or within their own outpost then cancel the
        # damage event.

        - if <context.entity.is_player>:
            - define belligerent <context.entity>
            - define belligerentKingdom <context.entity.flag[kingdom]>
            - define castle <server.flag[kingdoms.<[belligerentKingdom]>.claims.castle].as[list]>
            - define core <server.flag[kingdoms.<[belligerentKingdom]>.claims.core].as[list]>
            - define castleCore <[core].include[<[castle]>].exclude[0]>

            - foreach <[castleCore]>:
                - if <[value].cuboid.contains[<context.entity.location>]>:
                    - determine cancelled

        - if <player.has_flag[kingdom]>:
            - define kingdom <player.flag[kingdom]>

            - if <server.flag[kingdoms.<[kingdom]>.warStatus]> != true:
                - define castle <server.flag[kingdoms.<[belligerentKingdom]>.claims.castle].as[list]>
                - define core <server.flag[kingdoms.<[belligerentKingdom]>.claims.core].as[list]>
                - define castleCore <[core].include[<[castle]>].exclude[0]>

                - foreach <[castleCore]>:
                    - if <[value].cuboid.contains[<context.entity.location>]>:
                        - determine cancelled

                - if <server.has_flag[kingdoms.<[kingdom]>.outposts.outpostList]>:
                    - foreach <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys>:
                        - if <cuboid[<[value]>].players.contains[<player>]>:
                            - determine cancelled

        on player empties bucket:
        - if <player.has_flag[kingdom]>:
            - define kingdom <player.flag[kingdom]>

            - if <server.has_flag[RestrictedCreative]>:
                - if !<player.has_permission[kingdoms.admin.bypassrc]>:
                    - define castleCore <server.flag[kingdoms.<[kingdom]>.claims.castle].include[<server.flag[kingdoms.<[kingdom]>.claims.core]>]>
                    - define inOwnTerritory false

                    # Note to self: this may not be very efficient. Try consolidating
                    # all the chunks of core/castle territory into a cuboid object to
                    # access and reference easier

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

        - else:
            - determine cancelled

        on player places block:
        - if !<player.has_flag[kingdom]>:
            - determine cancelled

        - define kingdom <player.flag[kingdom]>
        - define isInAnyClaim false

        - if <context.location.chunk.is_in[<server.flag[kingdoms.claimInfo.allClaims].parse_tag[<[parse_value].as[chunk]>]>]>:
            - define isInAnyClaim true

        # If the player places a block not within their own core/castle/
        # outpost territory then undo the block place

        - if <[isInAnyClaim]>:
            - if <server.flag[kingdoms.<[kingdom]>.warStatus].as_boolean.not>:
                - if !<player.has_permission[kingdoms.admin.bypassrc]> || !<player.is_op>:
                    - stop

                - define castleCore <server.flag[kingdoms.<[kingdom]>.claims.castle].if_null[<list[]>].include[<server.flag[kingdoms.<[kingdom]>.claims.core].if_null[<list[]>]>]>

                # Note to self: this may not be very efficient. Try consolidating
                # all the chunks of core/castle territory into a cuboid object to
                # access and reference easier

                - if <context.location.chunk.is_in[<[castleCore]>]>:
                    - stop

                - else if <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys.size.if_null[0]> != 0:
                    - foreach <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys>:
                        - if <cuboid[<[value]>].players.contains[<player>]>:
                            - stop

                - determine cancelled

        - else:
            # Block players from placing stuff in the wilderness only if restricted creative is
            # engaged.
            - if <server.has_flag[RestrictedCreative]>:
                - if !<player.has_permission[kingdoms.admin.bypassrc]>:
                    - determine cancelled

        on player breaks block:
        - if !<player.has_flag[kingdom]>:
            - determine cancelled

        - define kingdom <player.flag[kingdom]>
        - define isInAnyClaim false

        - if <context.location.chunk.is_in[<server.flag[kingdoms.claimInfo.allClaims].parse_tag[<[parse_value].as[chunk]>]>]>:
            - define isInAnyClaim true

        # If the player places a block not within their own core/castle/
        # outpost territory then undo the block place

        - if <[isInAnyClaim]>:
            - if <server.flag[kingdoms.<[kingdom]>.warStatus].as_boolean.not>:
                - if !<player.has_permission[kingdoms.admin.bypassrc]> || !<player.is_op>:
                    - stop

                - define castleCore <server.flag[kingdoms.<[kingdom]>.claims.castle].if_null[<list[]>].include[<server.flag[kingdoms.<[kingdom]>.claims.core].if_null[<list[]>]>]>

                # Note to self: this may not be very efficient. Try consolidating
                # all the chunks of core/castle territory into a cuboid object to
                # access and reference easier

                - if <context.location.chunk.is_in[<[castleCore]>]>:
                    - stop

                - else if <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys.size.if_null[0]> != 0:
                    - foreach <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys>:
                        - if <cuboid[<[value]>].players.contains[<player>]>:
                            - stop

                - determine cancelled

        - else:
            # Block players from placing stuff in the wilderness only if restricted creative is
            # engaged.
            - if <server.has_flag[RestrictedCreative]>:
                - if !<player.has_permission[kingdoms.admin.bypassrc]>:
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
            - define allClaims <server.flag[kingdoms.claimInfo.allClaims].as[list].parse_tag[<[parse_value].cuboid>]>

            - if <context.location.chunk.is_in[<[allClaims]>]>:
                - determine cancelled

        # on entity spawns:
        # - define blockedSpawnTypes <list[NATURAL|LIGHTNING|SPAWNER|JOCKEY]>

        # - if <[blockedSpawnTypes].contains[<context.reason>]>:
        #     - define kingdomList <proc[GetKingdomList].context[true]>

        #     - foreach <[kingdomList]> as:kingdom:
        #         - define castle <server.flag[kingdoms.<[kingdom]>.claims.castle].as[list]>
        #         - define core <server.flag[kingdoms.<[kingdom]>.claims.core].as[list]>
        #         - define kingdomAllTerritory <[core].include[<[castle]>].exclude[0]>

        #         - foreach <[kingdomAllTerritory]>:
        #             - if <[value].cuboid.contains[<context.location>]>:
        #                 - determine cancelled

        on entity explodes:
        - define kingdomList <proc[GetKingdomList].context[true]>

        - foreach <[kingdomList]> as:kingdom:
            - define castle <server.flag[kingdoms.<[kingdom]>.claims.castle].as[list]>
            - define core <server.flag[kingdoms.<[kingdom]>.claims.core].as[list]>

            - define kingdomAllTerritory <[core].include[<[castle]>]>

            - foreach <[kingdomAllTerritory]>:
                - if <[value].cuboid.contains[<context.location>]>:
                    - if <server.flag[kingdoms.<[kingdom]>.warStatus]> != true:
                        - determine cancelled
                        - foreach stop
