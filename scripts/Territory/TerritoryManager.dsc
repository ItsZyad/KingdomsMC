Claim_Command:
    type: command
    usage: /claim
    name: claim
    description: Claims kingdoms territory
    script:
    - define kingdom <player.flag[kingdom]>
    - define coreMax <server.flag[kingdoms.<[kingdom]>.claims.coreMax].if_null[0]>
    - define castleMax <server.flag[kingdoms.<[kingdom]>.claims.castleMax].if_null[0]>
    - define castleAmount <server.flag[kingdoms.<[kingdom]>.claims.castle].size.if_null[0]>
    - define coreAmount <server.flag[kingdoms.<[kingdom]>.claims.core].size.if_null[0]>
    - define coreChunks <server.flag[kingdoms.<[kingdom]>.claims.core].if_null[<list[]>]>
    - define castleChunks <server.flag[kingdoms.<[kingdom]>.claims.castle].if_null[<list[]>]>
    - define combinedChunks <[castleChunks].include[<[coreChunks]>]>
    - define balance <server.flag[kingdoms.<[kingdom]>.balance].if_null[0]>
    - define playerChunk <player.location.chunk>
    - define chunkConnected false

    # Calculation of chunk proximity #
    - if <[combinedChunks].size> != 0:
        - foreach <[combinedChunks]>:
            - define chunkX <[value].x>
            - define chunkZ <[value].z>
            - define chunkDiff <player.location.chunk.sub[<[chunkX]>,<[chunkZ]>]>

            - if <[chunkDiff].x.add[<[chunkDiff].z>].abs> == 1:
                - define chunkConnected true
                - foreach stop

    - foreach <util.notes.filter_tag[<[filter_value].starts_with[INTERNAL_STORY]>]> as:area:
        - if <[area].bounding_box.intersects[<player.location.chunk.cuboid>]>:
            - narrate format:callout "You are not allowed to claim a chunk here. This area is a point of interest!"
            - determine cancelled

    - choose <player.flag[ClaimingMode]>:
        - case CoreClaiming:
            - if <[coreChunks].contains[<[playerChunk]>]>:
                - narrate format:callout "You have already claimed this chunk."
                - determine cancelled

            - else if <[chunkConnected]>:
                - narrate format:callout "Chunks must be contigious."
                - determine cancelled

            - else if <[castleAmount]> == 0:
                - narrate format:callout "You must have castle chunks claimed before making core claims."
                - determine cancelled

            - run FindKingdomOverlaps def.currentClaim:<[playerChunk]> save:overlap

            - else if <entry[overlap].created_queue.determination.get[1]>:
                - narrate format:callout "This chunk is already occupied. Double claiming could be considered an act of agression!"
                - determine cancelled

            - else if <[coreMax]> <= <[coreAmount]>:
                - narrate format:callout "You have reached the maximum core chunks for your kingdom!"
                - determine cancelled

            - else:
                # Core Plot Price Equation #
                - define realPrestige <element[100].sub[<server.flag[kingdoms.<[kingdom]>.prestige]>]>
                - define prestigeMultiplier <util.e.power[<element[0.02186].mul[<[realPrestige]>]>].sub[0.9]>
                - define corePrice <[prestigeMultiplier].mul[100].round_to_precision[100]>

                - choose <[kingdom]>:
                    - case raptoran:
                        - define corePrice <[corePrice].mul[1.1]>

                    - case centran:
                        - define corePrice <[corePrice].mul[0.85]>

                    - case cambrian:
                        - define corePrice <[corePrice].mul[0.9]>

                - if <[balance].is[LESS].than[<[corePrice]>]>:
                    - narrate format:callout "You do not have enough money to buy this plot of land! You need a total of: <bold>$<[corePrice]>"
                    - determine cancelled

                - else:
                    - flag server kingdoms.<[kingdom]>.claims.core:->:<player.location.chunk>
                    - flag server kingdoms.claimInfo.allClaims:->:<player.location.chunk>

                    - if <server.has_flag[PreGameStart]>:
                        - flag server kingdoms.<[kingdom]>.balance:-:<[corePrice].div[2]>

                        - if <server.flag[kingdoms.<[kingdom]>.claims.core].size> < 20:
                            - flag server kingdoms.<[kingdom]>.upkeep:+:5

                    - else:
                        - flag server kingdoms.<[kingdom]>.balance:-:<[corePrice]>
                        - flag server kingdoms.<[kingdom]>.upkeep:+:30

        - case CastleClaiming:
            - if <[castleChunks].contains[<[playerChunk]>]>:
                - narrate format:callout "You have already claimed this chunk."
                - determine cancelled

            - else if <[castleAmount]> >= <[castleMax]>:
                - narrate format:callout "You have reached the maximum number of claims on your castle!"
                - determine cancelled

            - else:
                - flag server kingdoms.<[kingdom]>.claims.castle:->:<player.location.chunk>
                - flag server kingdoms.claimInfo.allClaims:->:<player.location.chunk>
                - narrate format:callout Claimed!

    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>

FindKingdomOverlaps:
    type: task
    definitions: currentClaim
    script:
    - foreach <server.flag[kingdoms.claimInfo.allClaims]>:
        - if <[value]> == <[currentClaim]>:
            - determine true

    - determine false

ResetClaimFlags:
    type: world
    events:
        on player quits:
        - flag <player> ClaimingMode:!