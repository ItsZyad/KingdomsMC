##
## A (heavily modified) Denizen-Dynmap hook for Kingdoms.
##
## @Author: Maxime (@mrm/Maxime#9999)
## @Editor: Zyad (@itszyad/ITSZYAD#9280)
##
## @Date: Jan 2022
## @Update 1: May-Jun 2023
## @Update 2: Jul 2024
## @Script Ver: v2.1
##
## ------------------------------------------END HEADER-------------------------------------------

GenerateDynmapCorners:
    type: task
    definitions: chunks[ListTag(ChunkTag)]
    description:
    - Original script by: @mrm/Maxime#9999 at this link: https://paste.denizenscript.com/View/111717.
    - Generates the corners for the provided territoryType and the provided kingdom and caches the output in the world-specific dynmap flag.
    - ---
    - → [ListTag(LocationTag)]

    script:
    ## Original script by: @mrm/Maxime#9999 at this link:
    ## https://paste.denizenscript.com/View/111717.
    ##
    ## Generates the corners for the provided territoryType and the provided kingdom and caches the
    ## output in the world-specific dynmap flag.
    ##
    ## chunks : [ListTag<LocationTag>]
    ##
    ## >>> [ListTag<LocationTag>]

    - define world <[chunks].get[1].world>
    - define worldName <[world].name>

    - define minX <[chunks].sort_by_value[x].get[1].x>
    - define minZ <[chunks].filter[x.equals[<[minX]>]].sort_by_value[z].get[1].z>
    - define init_x <[minX]>
    - define init_z <[minZ]>
    - define tarX <[minX]>
    - define tarZ <[minZ]>
    - define dir xPlus
    - define corners <list>
    - define corners <[corners].include[<chunk[<[tarX]>,<[tarZ]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>

    - while !<[tarX].equals[<[minX]>]> || !<[tarZ].equals[<[minZ]>]> || !<[dir].equals[zMinus]>:
        - while stop if:<[loop_index].equals[1000]>

        - choose <[dir]>:
            - case xPlus:
                - if !<[chunks].contains[<chunk[<[tarX].add[1]>,<[tarZ]>,<[worldName]>]>]>:
                    - define corners <[corners].include[<chunk[<[tarX].add[1]>,<[tarZ]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir zPlus

                - else if !<[chunks].contains[<chunk[<[tarX].add[1]>,<[tarZ].sub[1]>,<[worldName]>]>]>:
                    - define tarX:++

                - else:
                    - define corners <[corners].include[<chunk[<[tarX].add[1]>,<[tarZ]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir zMinus
                    - define tarX:++
                    - define tarZ:--

            - case zPlus:
                - if !<[chunks].contains[<chunk[<[tarX]>,<[tarZ].add[1]>,<[worldName]>]>]>:
                    - define corners <[corners].include[<chunk[<[tarX].add[1]>,<[tarZ].add[1]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir xMinus

                - else if !<[chunks].contains[<chunk[<[tarX].add[1]>,<[tarZ].add[1]>,<[worldName]>]>]>:
                    - define tarZ:++

                - else:
                    - define corners <[corners].include[<chunk[<[tarX].add[1]>,<[tarZ].add[1]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir xPlus
                    - define tarX:++
                    - define tarZ:++

            - case xMinus:
                - if !<[chunks].contains[<chunk[<[tarX].sub[1]>,<[tarZ]>,<[worldName]>]>]>:
                    - define corners <[corners].include[<chunk[<[tarX]>,<[tarZ].add[1]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir zMinus

                - else if !<[chunks].contains[<chunk[<[tarX].sub[1]>,<[tarZ].add[1]>,<[worldName]>]>]>:
                    - define tarX:--

                - else:
                    - define corners <[corners].include[<chunk[<[tarX]>,<[tarZ].add[1]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir zPlus
                    - define tarX:--
                    - define tarZ:++

            - case zMinus:
                - if !<[chunks].contains[<chunk[<[tarX]>,<[tarZ].sub[1]>,<[worldName]>]>]>:
                    - define corners <[corners].include[<chunk[<[tarX]>,<[tarZ]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir xPlus

                - else if !<[chunks].contains[<chunk[<[tarX].sub[1]>,<[tarZ].sub[1]>,<[worldName]>]>]>:
                    - define tarZ:--

                - else:
                    - define corners <[corners].include[<chunk[<[tarX]>,<[tarZ]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir xMinus
                    - define tarX:--
                    - define tarZ:--

    - determine <[corners]>


DynmapTask:
    type: task
    script:
    - define world <[world].if_null[<player.location.world>]>
    - define kingdomList <proc[GetKingdomList]>

    # Check that main territory layer exists
    - execute as_server "dmarker list set:Regions" save:regionList
    - define regionList <entry[regionList].output>

    - if <[regionList].get[1].starts_with[Error]>:
        - execute as_server "dmarker addset id:regions Regions hide:false prio:1"

    # Check that duchy layer exists
    - execute as_server "dmarker list set:Duchies" save:duchyList
    - define duchyList <entry[duchyList].output>

    - if <[duchyList].get[1].starts_with[Error]>:
        - execute as_server "dmarker addset id:duchies Duchies hide:false prio:2"

    # Check that outpost layer exists
    - execute as_server "dmarker list set:Outposts" save:outpostList
    - define outpostList <entry[outpostList].output>

    - if <[outpostList].get[1].starts_with[Error]>:
        - execute as_server "dmarker addset id:outposts Outposts hide:false prio:3"

    # Main territory loop #
    - foreach <[kingdomList]> as:kingdom:
        - if !<[world].has_flag[dynmap.cache.<[kingdom]>.main.cornerList]>:
            - foreach next

        - define kingdomColor <proc[GetKingdomColor].context[<[kingdom]>]>
        - define fillColor <[kingdomColor].mix[<color[#000000]>]>

        - foreach <[world].flag[dynmap.cache.<[kingdom]>.main.cornerList]> as:corner:
            - define formattedCorner <[corner].simple.split[,].remove[last].space_separated>
            - execute as_op "dmarker addcorner <[formattedCorner]> <[world].name>"

        - execute as_op "dmarker deletearea id:<[kingdom]>_main_territory set:regions"
        - execute as_op "dmarker addarea id:<[kingdom]>_main_territory set:regions label:<&dq>[Kingdom] <proc[GetKingdomName].context[<[kingdom]>]><&dq>"
        - execute as_op "dmarker updatearea id:<[kingdom]>_main_territory set:regions color:<[kingdomColor].hex.replace[#]> fillcolor:<[fillColor].hex.replace[#]> opacity:0.7 fillopacity:0.5 weight:2"
        - execute as_op "dmarker clearcorners" silent

        # Main duchy loop #
        - foreach <[kingdom].proc[GetKingdomDuchies]> as:duchy:
            - foreach <[world].flag[dynmap.cache.<[kingdom]>.duchies.<[duchy]>.cornerList]> as:corner:
                - define formattedCorner <[corner].simple.split[,].remove[last].space_separated>
                - execute as_op "dmarker addcorner <[formattedCorner]> <[world].name>"

            - execute as_op "dmarker deletearea id:<[kingdom]>_<[duchy]>_duchy_territory set:duchies"
            - execute as_op "dmarker addarea id:<[kingdom]>_<[duchy]>_duchy_territory set:duchies label:<&dq>[Duchy] <[kingdom].proc[GetDuchyDisplayName].context[<[duchy]>]> in <proc[GetKingdomShortName].context[<[kingdom]>]><&dq>"
            - execute as_op "dmarker updatearea id:<[kingdom]>_<[duchy]>_duchy_territory set:duchies color:<[kingdomColor].hex.replace[#]> fillcolor:000000 opacity:0.9 fillopacity:0.35 weight:2"
            - execute as_op "dmarker clearcorners" silent

        # Main outpost loop #
        - foreach <[kingdom].proc[GetOutposts]> as:outpostData key:outpostName:
            - define area <[outpostData].get[area]>
            - define ID <[outpostName].replace[<&sp>].with[-]>

            - execute as_op "dmarker addcorner <[area].min.simple.replace_text[,].with[<&sp>]>" silent
            - execute as_op "dmarker addcorner <[area].max.simple.replace_text[,].with[<&sp>]>" silent
            - execute as_op "dmarker deletearea id:<[ID]> set:outposts" silent
            - execute as_op "dmarker addarea id:<[ID]> set:outposts label:"[Outpost] <proc[GetKingdomName].context[<[kingdom]>]>"" silent
            - execute as_op "dmarker updatearea id:<[ID]> set:outposts color:<[kingdomColor].hex.replace[#]> fillcolor:<[fillColor].hex.replace[#]> opacity:0.7 fillopacity:0.5 weight:2" silent
            - execute as_op "dmarker clearcorners" silent

    - narrate format:admincallout "Successfully refreshed Dynmap for world: <[world].name.color[gold]>"
