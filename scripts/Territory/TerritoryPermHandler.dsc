DoorInteractCode:
    type: task
    debug: false
    script:
    - if !<player.has_permission[kingdoms.admin.bypassclickcheck]>:
        - define kingdom <player.flag[kingdom]>

        - if <server.flag[kingdoms.claimInfo.allClaims].contains[<context.location.chunk>]>:
            - if <server.flag[kingdoms.<[kingdom]>.warStatus]> != true:
                - define castle <server.flag[kingdoms.<[kingdom]>.claims.castle].as[list]>
                - define core <server.flag[kingdoms.<[kingdom]>.claims.core].as[list]>
                - define castleCore <[core].include[<[castle]>].exclude[0]>
                - define isInOwnTerritory false

                - foreach <[castleCore]>:
                    - if <[value].cuboid.contains[<context.location>]>:
                        - define isInOwnTerritory true

                - foreach <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys>:
                    - if <cuboid[<[value]>].players.contains[<player>]>:
                        - define isInOwnTerritory true

                - if !<[isInOwnTerritory]>:
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
        - define kingdom <player.flag[kingdom]>

        - if !<player.has_flag[kingdom]>:
            - determine cancelled

        - define isInAnyClaim false

        - foreach <server.flag[kingdoms.claimInfo.allClaims]>:
            - if <[value]> == <context.location.chunk>:
                - define isInAnyClaim true
                - foreach stop

        # If the player places a block not within their own core/castle/
        # outpost territory then undo the block place

        - if <[isInAnyClaim]>:
            - if !<server.flag[kingdoms.<[kingdom]>.warStatus]>:
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
                        - if <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys.size> != 0:
                            - foreach <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys>:
                                - if <cuboid[<[value]>].players.contains[<player>]>:
                                    - determine cancelled

        - else:
            - if <server.has_flag[RestrictedCreative]>:
                - if !<player.has_permission[kingdoms.admin.bypassrc]>:
                    - determine cancelled

        on player breaks block:
        - define kingdom <player.flag[kingdom]>

        - if !<player.has_flag[kingdom]>:
            - determine cancelled

        - define isInAnyClaim false

        - foreach <server.flag[kingdoms.claimInfo.allClaims]>:
            - if <[value]> == <context.location.chunk>:
                - define isInAnyClaim true
                - foreach stop

        # If the player places a block not within their own core/castle/
        # outpost territory then undo the block place

        - if <[isInAnyClaim]>:
            - if !<server.flag[kingdoms.<[kingdom]>.warStatus]>:
                - if !<player.has_permission[kingdoms.admin.bypassrc]>:
                    - define castleCore <server.flag[kingdoms.<[kingdom]>.claims.castle].include[<server.flag[kingdoms.<[kingdom]>.claims.core]>]>
                    - define inOwnTerritory false

                    # Note to self: this may not be very efficient. Try consolidating
                    # all the chunks of core/castle territory into a cuboid object to
                    # access and reference easier

                    - foreach <[castleCore]>:
                        - if <[value].cuboid.contains[<context.location>]>:
                            - define inOwnTerritory true

                    - if !<[inOwnTerritory]>:
                        - determine cancelled

                    - else:
                        - if <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys.size> != 0:
                            - foreach <server.flag[kingdoms.<[kingdom]>.outposts.outpostList].keys>:
                                - if <cuboid[<[value]>].players.contains[<player>]>:
                                    - determine cancelled

        - else:
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

        - define weightedRandom <util.random.decimal[0].to[<util.random.decimal[0.5].to[1]>]>

        - if <[weightedRandom]> < 0.3:
            - determine cancelled

        on entity spawns:
        - define blockedSpawnTypes <list[NATURAL|LIGHTNING|SPAWNER|JOCKEY]>

        - if <[blockedSpawnTypes].contains[<context.reason>]>:
            - define kingdomList <proc[GetKingdomList].context[true]>

            - foreach <[kingdomList]> as:kingdom:
                - define castle <server.flag[kingdoms.<[kingdom]>.claims.castle].as[list]>
                - define core <server.flag[kingdoms.<[kingdom]>.claims.core].as[list]>
                - define kingdomAllTerritory <[core].include[<[castle]>].exclude[0]>

                - foreach <[kingdomAllTerritory]>:
                    - if <[value].cuboid.contains[<context.location>]>:
                        - determine cancelled

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
