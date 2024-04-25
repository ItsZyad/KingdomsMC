##
## This is a single script file which is reponsible for chunk claiming.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Mar 2023
## @Update 1: Jul 2023
## @Update 2: Apr 2024
## **** Note: This update converted the previous Claim_Command into a task script that can be
## ****       called from the KingdomCommand.dsc file with all the relevant parameters needed 
## ****       for chunk claiming.
##
## @Script Ver: v3.0
##
## ------------------------------------------END HEADER-------------------------------------------

TerritoryClaim:
    type: task
    debug: false
    definitions: claimingMode[ElementTag(String)]|chunk[ChunkTag]|kingdom[ElementTag(String)]
    description:
    - Will claim the provided chunk for the provided kingdom as either core or castle territory.
    - ---
    - → [Void]

    script:
    ## Will claim the provided chunk for the provided kingdom as either core or castle territory.
    ##
    ## claimingMode : [ElementTag(String)]
    ## chunk        : [ChunkTag]
    ## kingdom      : [ElementTag(String)]

    - if !<[claimingMode].exists>:
        - narrate format:callout "You have not selected a claiming mode! Please use <element[/k claim core].color[red]> or <element[/k claim castle].color[red]> to use this command."
        - determine cancelled

    - define coreMax <server.flag[kingdoms.<[kingdom]>.claims.coreMax].if_null[0]>
    - define castleMax <server.flag[kingdoms.<[kingdom]>.claims.castleMax].if_null[0]>
    - define castleAmount <server.flag[kingdoms.<[kingdom]>.claims.castle].size.if_null[0]>
    - define coreAmount <server.flag[kingdoms.<[kingdom]>.claims.core].size.if_null[0]>
    - define coreChunks <server.flag[kingdoms.<[kingdom]>.claims.core].if_null[<list[]>]>
    - define castleChunks <server.flag[kingdoms.<[kingdom]>.claims.castle].if_null[<list[]>]>
    - define combinedChunks <[castleChunks].include[<[coreChunks]>]>
    - define balance <server.flag[kingdoms.<[kingdom]>.balance].if_null[0]>
    - define chunkConnected false

    # Calculation of chunk proximity #
    - if <[combinedChunks].size> != 0:
        - foreach <[combinedChunks]>:

            ## IMPORTANT! THIS IS FOR DEBUGGING PURPOSES
            ## DO NOT KEEP IN PRODUCTION!
            - if <[value].world> != <[chunk].world>:
                - foreach next

            - define chunkX <[value].x>
            - define chunkZ <[value].z>
            - define chunkDiff <[chunk].sub[<[chunkX]>,<[chunkZ]>]>

            - if <[chunkDiff].x.add[<[chunkDiff].z>].abs> == 1:
                - define chunkConnected true
                - foreach stop

    - foreach <util.notes.filter_tag[<[filter_value].starts_with[INTERNAL_STORY]>]> as:area:
        - if <[area].bounding_box.intersects[<[chunk].cuboid>]>:
            - narrate format:callout "You are not allowed to claim a chunk here. This area is a point of interest!"
            - determine cancelled

    - choose <[claimingMode]>:
        - case core:
            - if <[coreChunks].contains[<[chunk]>]>:
                - narrate format:callout "You have already claimed this chunk."
                - determine cancelled

            - else if !<[chunkConnected]> && <[combinedChunks].size> != 0:
                - narrate format:callout "Chunks must be contigious."
                - determine cancelled

            - else if <[castleAmount]> == 0:
                - narrate format:callout "You must have castle chunks claimed before making core claims."
                - determine cancelled

            - else if <server.flag[kingdoms.claimInfo.allClaims].contains[<[chunk]>]>:
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
                    - run AddClaim def.kingdom:<[kingdom]> def.type:core def.chunk:<[chunk]>

                    - if <server.has_flag[PreGameStart]>:
                        - run SubBalance def.kingdom:<[kingdom]> def.amount:<[corePrice].div[2]>

                        - if <server.flag[kingdoms.<[kingdom]>.claims.core].size> < 20:
                            - run AddUpkeep def.kingdom:<[kingdom]> def.amount:5

                    - else:
                        - run SubBalance def.kingdom:<[kingdom]> def.amount:<[corePrice]>
                        - run AddUpkeep def.kingdom:<[kingdom]> def.amount:30

            - ~run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].if_null[<list[]>].include[<server.online_ops>]>

        - case castle:
            - if <[castleChunks].contains[<[chunk]>]>:
                - narrate format:callout "You have already claimed this chunk."
                - determine cancelled

            - else if <[castleAmount]> >= <[castleMax]>:
                - narrate format:callout "You have reached the maximum number of claims on your castle!"
                - determine cancelled

            - else:
                - run AddClaim def.kingdom:<[kingdom]> def.type:castle def.chunk:<[chunk]>
                - narrate format:callout Claimed!

            - ~run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].if_null[<list[]>].include[<server.online_ops>]>

        - default:
            - narrate format:callout "Invalid claiming type. Valid claiming types are either: <element[castle].color[red]> or <element[core].color[red]>"
