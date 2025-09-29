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

    - repeat 10 from:-5 as:zChunk:
        - repeat 19 from:-9 as:xChunk:
            - define currentChunk <[playerChunk].add[<[xChunk]>,<[zChunk]>]>
            - define allOutposts <proc[GetAllOutposts].parse_value_tag[<[parse_value].get[area]>].values.parse_tag[<[parse_value].partial_chunks>].combine>

            - if <proc[GetAllClaims].contains[<[currentChunk]>]>:
                - foreach <proc[GetKingdomList]> as:kingdom:
                    - define kingdomCastle <[kingdom].proc[GetClaims].context[castle]>
                    - define kingdomCore <[kingdom].proc[GetClaims].context[core]>
                    - define kingdomColor <[kingdom].proc[GetKingdomColor]>

                    - if <[currentChunk]> == <[playerChunk]> && <[kingdomCore].include[<[kingdomCastle]>].contains[<[currentChunk]>]>:
                        - define chunkList:->:<element[P].color[<[kingdomColor]>]>
                        - foreach stop

                    - else if <[kingdomCore].contains[<[currentChunk]>]>:
                        - define chunkList:->:<element[X].color[<[kingdomColor]>]>
                        - foreach stop

                    - else if <[kingdomCastle].contains[<[currentChunk]>]>:
                        - define chunkList:->:<element[Y].color[<[kingdomColor]>]>
                        - foreach stop

            - else if <[allOutposts].contains[<[currentChunk]>]>:
                - foreach <proc[GetKingdomList]> as:kingdom:
                    - define kingdomOutposts <proc[GetOutposts].context[<[kingdom]>].parse_value_tag[<[parse_value].get[area]>].values.parse_tag[<[parse_value].partial_chunks>].combine>
                    - define kingdomColor <[kingdom].proc[GetKingdomColor]>

                    - if <[currentChunk]> == <[playerChunk]>:
                        - define chunkList:->:<element[P].color[<[kingdomColor]>]>
                        - foreach stop

                    - else:
                        - define chunkList:->:<element[O].color[<[kingdomColor]>]>
                        - foreach stop

            - else if <[currentChunk]> != <[playerChunk]>:
                - define chunkList:->:<element[-].color[gray]>

            - else:
                - define chunkList:->:<element[P].color[white].on_hover[<[currentChunk]>]>

    - define chunkList <[chunkList].sub_lists[19]>
    - define chunkList[1]:<[chunkList].get[1].include[<element[⮙ - North]>]>

    - narrate <gold>|<element[                        ].strikethrough><element[ Chunk Map ].color[#f7c64b]><element[                         ].strikethrough>|
    - narrate <[chunkList].parse_tag[<[parse_value].space_separated>].separated_by[<n>]>
    - narrate "<white>- : <gray>Wilderness      | <white>P : <gray>Player"
    - narrate "<white>X : <gray>Kingdom Castle | <white>O : <gray>Kingdom Outpost (Approx.)"
    - narrate "<white>Y : <gray>Kingdom Core   | <white>Chunks coded to respective kingdom color."
    - narrate <gold>|<element[                                                                ].strikethrough>|
