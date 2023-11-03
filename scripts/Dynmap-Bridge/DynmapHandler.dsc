##
## * A (heavily modified) Denizen-Dynmap hook for Kingdoms
##
## @Author: (@icecapade/Icecapade#8825)
## @Supplementary Scripts: Maxime (@mrm/Maxime#9999)
## @Editor: Zyad (@itszyad/ITSZYAD#9280)
## @Date: Jan 2022
## @Updated: May-Jun 2023
## @Script Ver: v2.0
##
## ----------------END HEADER-----------------

DynmapFlagBuilderV2:
  type: task
  definitions: kingdom|worldName
  script:
    ## Original script by: @mrm/Maxime#9999
    ## *also no, I'm not going to change the varibale scheme to match...*
    ## *ok I might...*
    ##
    ## Generates the corners for the provided territoryType and the provided kingdom and caches the
    ## output in the world-specific dynmap flag
    ##
    ## kingdom       : [ElementTag<String>]
    ## worldName     : [ElementTag<String>]
    ##
    ## >>> [ListTag<LocationTag>]

    - define territoryType <[territoryType].to_lowercase.if_null[core]>
    - define kingdomData <server.flag[kingdoms.<[kingdom]>]>
    - define world <server.worlds.filter_tag[<[filter_value].name.to_lowercase.equals[<[worldName].to_lowercase>]>]>
    - define chunks <[kingdomData].deep_get[claims.castle].if_null[<list[]>].include[<[kingdomData].deep_get[claims.core].if_null[<list[]>]>]>

    - if !<[world].exists>:
        - narrate format:admincallout "<red>[Internal Error INTD01] <&gt><&gt><&r>Could not determine world name. Please contact a dev or server owner."
        - determine cancelled

    - determine <list> if:<[chunks].is_empty.or[<[chunks].is_truthy.not>]>

    - define min_x <[chunks].sort_by_value[x].get[1].x>
    - define min_z <[chunks].filter[x.equals[<[min_x]>]].sort_by_value[z].get[1].z>
    - define start_chunk <chunk[<[min_x]>,<[min_z]>,<[worldName]>]>
    - define init_x <[min_x]>
    - define init_z <[min_z]>
    - define tar_x <[min_x]>
    - define tar_z <[min_z]>
    - define dir x_plus
    - define corners <list>
    - define corners <[corners].include[<chunk[<[tar_x]>,<[tar_z]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>

    - while !<[tar_x].equals[<[min_x]>]> || !<[tar_z].equals[<[min_z]>]> || !<[dir].equals[z_minus]>:
        - while stop if:<[loop_index].equals[1000]>

        - choose <[dir]>:
            - case x_plus:
                - if !<[chunks].contains[<chunk[<[tar_x].add[1]>,<[tar_z]>,<[worldName]>]>]>:
                    - define corners <[corners].include[<chunk[<[tar_x].add[1]>,<[tar_z]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir z_plus

                - else if !<[chunks].contains[<chunk[<[tar_x].add[1]>,<[tar_z].sub[1]>,<[worldName]>]>]>:
                    - define tar_x:++

                - else:
                    - define corners <[corners].include[<chunk[<[tar_x].add[1]>,<[tar_z]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir z_minus
                    - define tar_x:++
                    - define tar_z:--

            - case z_plus:
                - if !<[chunks].contains[<chunk[<[tar_x]>,<[tar_z].add[1]>,<[worldName]>]>]>:
                    - define corners <[corners].include[<chunk[<[tar_x].add[1]>,<[tar_z].add[1]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir x_minus

                - else if !<[chunks].contains[<chunk[<[tar_x].add[1]>,<[tar_z].add[1]>,<[worldName]>]>]>:
                    - define tar_z:++

                - else:
                    - define corners <[corners].include[<chunk[<[tar_x].add[1]>,<[tar_z].add[1]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir x_plus
                    - define tar_x:++
                    - define tar_z:++

            - case x_minus:
                - if !<[chunks].contains[<chunk[<[tar_x].sub[1]>,<[tar_z]>,<[worldName]>]>]>:
                    - define corners <[corners].include[<chunk[<[tar_x]>,<[tar_z].add[1]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir z_minus

                - else if !<[chunks].contains[<chunk[<[tar_x].sub[1]>,<[tar_z].add[1]>,<[worldName]>]>]>:
                    - define tar_x:--

                - else:
                    - define corners <[corners].include[<chunk[<[tar_x]>,<[tar_z].add[1]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir z_plus
                    - define tar_x:--
                    - define tar_z:++

            - case z_minus:
                - if !<[chunks].contains[<chunk[<[tar_x]>,<[tar_z].sub[1]>,<[worldName]>]>]>:
                    - define corners <[corners].include[<chunk[<[tar_x]>,<[tar_z]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir x_plus

                - else if !<[chunks].contains[<chunk[<[tar_x].sub[1]>,<[tar_z].sub[1]>,<[worldName]>]>]>:
                    - define tar_z:--

                - else:
                    - define corners <[corners].include[<chunk[<[tar_x]>,<[tar_z]>,<[worldName]>].cuboid.corners.parse[with_y[64]].deduplicate.get[1]>]>
                    - define dir x_minus
                    - define tar_x:--
                    - define tar_z:--

    - flag <[world]> dynmap.cache.<[kingdom]>.main.cornerList:<[corners]>
    - determine <[corners]>


DynmapTask:
    type: command
    name: refreshdynmap
    usage: /refreshdynmap
    permission: kingdoms.admin
    description: Admin Command - Updates all Kingdoms markers on Dynmap
    script:
    - define world <player.location.world>
    - define kingdomList <proc[GetKingdomList]>
    - definemap KingdomTextColors:
        raptoran: f14|812
        centran: 34c|16a
        viridian: 181|571
        cambrian: c27100|faaa39

    # Main territory loop #
    - foreach <[kingdomList]> as:kingdom:
        - if <[world].has_flag[dynmap.cache.<[kingdom]>.main.cornerList]>:
            - foreach <[world].flag[dynmap.cache.<[kingdom]>.main.cornerList]> as:corner:
                - define formattedCorner <[corner].simple.split[,].remove[last].space_separated>
                - execute as_op "dmarker addcorner <[formattedCorner]> <[world].name>"

            - execute as_op "dmarker deletearea id:<[kingdom]>_main_territory set:regions"
            - execute as_op "dmarker addarea id:<[kingdom]>_main_territory set:regions label:<&dq>[Kingdom] <proc[GetKingdomName].context[<[kingdom]>]><&dq>"
            - execute as_op "dmarker updatearea id:<[kingdom]>_main_territory set:outposts color:<[KingdomTextColors].get[<[kingdom]>].as[list].get[1]> fillcolor:<[KingdomTextColors].get[<[kingdom]>].as[list].get[2]> opacity:0.7 fillopacity:0.5 weight:2"
            - execute as_op "dmarker clearcorners" silent

        - foreach next

        # Main outpost loop #
        - foreach <[world].flag[dynmap.cache.<[kingdom]>.outposts]> as:entry:

            # TODO: REWRITE + INTEGRATE

            - define areaName <[entry].as[list].get[1]>
            - define area <[entry].as[list].get[2]>
            - define ID <[areaName].replace[<&sp>].with[-]>

            - narrate format:debug ID:<[ID]>
            - narrate format:debug AR:<[area]>
            - narrate format:debug --------------------

            - execute as_op "dmarker addcorner <[area].min.simple.replace_text[,].with[<&sp>]>" silent
            - execute as_op "dmarker addcorner <[area].max.simple.replace_text[,].with[<&sp>]>" silent
            - execute as_op "dmarker deletearea id:<[ID]> set:outposts" silent
            - execute as_op "dmarker addarea id:<[ID]> set:outposts label:"[Outpost] <proc[GetKingdomName].context[<[kingdom]>]>"" silent
            - execute as_op "dmarker updatearea id:<[ID]> set:outposts color:<[KingdomTextColors].get[<[kingdom]>].as[list].get[1]> fillcolor:<[KingdomTextColors].get[<[kingdom]>].as[list].get[2]> opacity:0.7 fillopacity:0.5 weight:2" silent
            - execute as_op "dmarker clearcorners" silent

    - narrate format:admincallout "Successfully refreshed Dynmap for world: <[world]>"
