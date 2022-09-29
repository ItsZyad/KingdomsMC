DoorInteractCode:
    type: task
    debug: false
    script:
    - if !<player.has_permission[kingdoms.admin.bypassclickcheck]>:
        - yaml load:kingdoms.yml id:kingdoms

        - define kingdom <player.flag[kingdom]>

        - if <yaml[kingdoms].read[all_claims].contains[<context.location.chunk>]>:
            - if <yaml[kingdoms].read[<[kingdom]>.war_status]> != true:
                - yaml load:outposts.yml id:outp

                - define castle <yaml[kingdoms].read[<[kingdom]>.castle_territory]>
                - define core <yaml[kingdoms].read[<[kingdom]>.core_claims].as[list]>

                - define castleCore <[core].include[<[castle]>].exclude[0]>

                - define isInOwnTerritory false

                - foreach <[castleCore]>:
                    - if <[value].cuboid.contains[<context.location>]>:
                        - define isInOwnTerritory true

                - foreach <yaml[outp].read[<player.flag[kingdom]>].keys.exclude[totalupkeep]>:
                    - if <cuboid[<[value]>].players.contains[<player>]>:
                        - define isInOwnTerritory true

                - if !<[isInOwnTerritory]>:
                    - determine cancelled

                - yaml id:outp unload

        - yaml id:kingdoms unload

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
        - yaml load:kingdoms.yml id:kingdoms

        # If player has taken damage within their own core/castle
        # territory or within their own outpost then cancel the
        # damage event.

        - if <context.entity.is_player>:
            - define belligerent <context.entity>
            - define belligerentKingdom <context.entity.flag[kingdom]>

            - define castle <yaml[kingdoms].read[<[belligerentKingdom]>.castle_territory]>
            - define core <yaml[kingdoms].read[<[belligerentKingdom]>.core_claims].as[list]>

            - define castleCore <[core].include[<[castle]>].exclude[0]>

            - foreach <[castleCore]>:
                - if <[value].cuboid.contains[<context.entity.location>]>:
                    - determine cancelled

        - if <player.has_flag[kingdom]>:
            - define kingdom <player.flag[kingdom]>

            - if <yaml[kingdoms].read[<[kingdom]>.war_status]> != true:
                - yaml load:outposts.yml id:outp

                - define castle <yaml[kingdoms].read[<[kingdom]>.castle_territory]>
                - define core <yaml[kingdoms].read[<[kingdom]>.core_claims].as[list]>

                - define castleCore <[core].include[<[castle]>].exclude[0]>

                - foreach <[castleCore]>:
                    - if <[value].cuboid.contains[<context.entity.location>]>:
                        - determine cancelled

                - foreach <yaml[outp].read[<player.flag[kingdom]>].keys.exclude[totalupkeep]>:
                    - if <cuboid[<[value]>].players.contains[<player>]>:
                        - determine cancelled

                - yaml unload id:outp

            - yaml unload id:kingdoms

        on player empties bucket:
        - yaml load:kingdoms.yml id:kingdoms

        - if <player.has_flag[kingdom]>:
            - define kingdom <player.flag[kingdom]>

            - if <server.has_flag[RestrictedCreative]>:
                - if !<player.has_permission[kingdoms.admin.bypassrc]>:
                    - yaml load:outposts.yml id:outp

                    - define castleCore <yaml[kingdoms].read[<[kingdom]>.castle_territory].include[<yaml[kingdoms].read[<[kingdom]>.core_claim]>]>
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
                        - foreach <yaml[outp].read[<player.flag[kingdom]>].keys.exclude[totalupkeep]>:
                            - if <cuboid[<[value]>].players.contains[<player>]>:
                                - determine cancelled

                    - yaml id:outp unload

        - else:
            - determine cancelled

        - yaml id:kingdoms unload

        on player places block:
        - yaml load:kingdoms.yml id:kingdoms
        - define kingdom <player.flag[kingdom]>

        - if !<player.has_flag[kingdom]>:
            - determine cancelled

        - define isInAnyClaim false

        - foreach <yaml[kingdoms].read[all_claims]>:
            - if <[value]> == <context.location.chunk>:
                - define isInAnyClaim true
                - foreach stop

        # If the player places a block not within their own core/castle/
        # outpost territory then undo the block place

        - if <[isInAnyClaim]>:
            - if !<yaml[kingdoms].read[<[kingdom]>.war_status]>:
                - if !<player.has_permission[kingdoms.admin.bypassrc]>:
                    - yaml load:outposts.yml id:outp

                    - define castleCore <yaml[kingdoms].read[<[kingdom]>.castle_territory].include[<yaml[kingdoms].read[<[kingdom]>.core_claims]>]>
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
                        - if <yaml[outp].read[<player.flag[kingdom]>].keys.exclude[totalupkeep].size> != 0:
                                - foreach <yaml[outp].read[<player.flag[kingdom]>].keys.exclude[totalupkeep]>:
                                    - if <cuboid[<[value]>].players.contains[<player>]>:
                                        - determine cancelled

                    - yaml unload id:outp

            - yaml unload id:kingdoms

        - else:
            - if <server.has_flag[RestrictedCreative]>:
                - if !<player.has_permission[kingdoms.admin.bypassrc]>:
                    - determine cancelled

        on player breaks block:
        - yaml load:kingdoms.yml id:kingdoms
        - define kingdom <player.flag[kingdom]>

        - if !<player.has_flag[kingdom]>:
            - determine cancelled

        - define isInAnyClaim false

        - foreach <yaml[kingdoms].read[all_claims]>:
            - if <[value]> == <context.location.chunk>:
                - define isInAnyClaim true
                - foreach stop

        # If the player places a block not within their own core/castle/
        # outpost territory then undo the block place

        - if <[isInAnyClaim]>:
            - if !<yaml[kingdoms].read[<[kingdom]>.war_status]>:
                - if !<player.has_permission[kingdoms.admin.bypassrc]>:
                    - yaml load:outposts.yml id:outp

                    - define castleCore <yaml[kingdoms].read[<[kingdom]>.castle_territory].include[<yaml[kingdoms].read[<[kingdom]>.core_claims]>]>
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
                        - if <yaml[outp].read[<player.flag[kingdom]>].keys.exclude[totalupkeep].size> != 0:
                            - foreach <yaml[outp].read[<player.flag[kingdom]>].keys.exclude[totalupkeep]>:
                                - if <cuboid[<[value]>].players.contains[<player>]>:
                                    - determine cancelled

                    - yaml unload id:outp

            - yaml unload id:kingdoms

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
            - yaml load:kingdoms.yml id:kingdoms
            - define kingdomList <proc[GetKingdomList].context[true]>

            - foreach <[kingdomList]> as:kingdom:
                - define castle <yaml[kingdoms].read[<[kingdom]>.castle_territory]>
                - define core <yaml[kingdoms].read[<[kingdom]>.core_claims].as[list]>
                - define kingdomAllTerritory <[core].include[<[castle]>].exclude[0]>

                - foreach <[kingdomAllTerritory]>:
                    - if <[value].cuboid.contains[<context.location>]>:
                        - determine cancelled

            - yaml id:kingdoms unload

        on entity explodes:
        - yaml load:kingdoms.yml id:kingdoms
        - define kingdomList <proc[GetKingdomList].context[true]>

        - foreach <[kingdomList]> as:kingdom:
            - define castle <yaml[kingdoms].read[<[kingdom]>.castle_territory]>
            - define core <yaml[kingdoms].read[<[kingdom]>.core_claims].as[list]>

            - define kingdomAllTerritory <[core].include[<[castle]>]>

            - foreach <[kingdomAllTerritory]>:
                - if <[value].cuboid.contains[<context.location>]>:
                    - if <yaml[kingdoms].read[<[kingdom]>.war_status]> != true:
                        - determine cancelled
                        - foreach stop

        - yaml id:kingdoms unload