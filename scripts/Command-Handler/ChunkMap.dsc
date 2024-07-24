##
## This file contains the script which generates the chat-based chunk map.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Dec 2023
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

ChunkMap:
    type: task
    debug: false
    script:
    - define playerChunk <player.location.chunk>
    - define chunkList <list[]>
    # - define allClaims <server.flag[kingdoms.claimInfo.allClaims]>

    - repeat 10 from:-5 as:zChunk:
        - repeat 19 from:-9 as:xChunk:
            - define currentChunk <[playerChunk].add[<[xChunk]>,<[zChunk]>]>

            - if <proc[GetAllClaims].contains[<[currentChunk]>]>:
                - foreach <proc[GetKingdomList]> as:kingdom:
                    # - define kingdomTerritory <server.flag[kingdoms.<[kingdom]>.claims.castle].include[<server.flag[kingdoms.<[kingdom]>.claims.core]>]>
                    - define kingdomTerritory <[kingdom].proc[GetClaims]>
                    - define kingdomColor <[kingdom].proc[GetKingdomColor]>

                    - if <[currentChunk]> == <[playerChunk]> && <[kingdomTerritory].contains[<[currentChunk]>]>:
                        - define chunkList:->:<element[P].color[<[kingdomColor]>]>
                        - foreach stop

                    - else if <[kingdomTerritory].contains[<[currentChunk]>]>:
                        - define chunkList:->:<element[■].color[<[kingdomColor]>]>
                        - foreach stop

            - else if <[currentChunk]> != <[playerChunk]>:
                - define chunkList:->:<element[-].color[gray]>

            - else:
                - define chunkList:->:<element[P].color[white].on_hover[<[currentChunk]>]>

    - define chunkList <[chunkList].sub_lists[19]>

    - narrate "<gold>=-=-=-=-=-= <element[Chunk Map].color[#f7c64b]> =-=-=-=-=-=-="
    - narrate <[chunkList].parse_tag[<[parse_value].space_separated>].separated_by[<n>]>
    - narrate "- : <gray>Wilderness"
    - narrate "P : <blue>Player"
    - narrate "■ : <gold>Kingdom Claim"
    - narrate "▒ : <green>Kingdom Outpost"
