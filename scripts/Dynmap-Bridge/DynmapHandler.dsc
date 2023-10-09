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


NEW_DynmapFlagBuilder:
    type: task
    permission: kingdoms.admin
    definitions: world|player|useCache|kingdomList
    ShortLookaround:
    - define shortLookaround <list[left=<[currCoord].add[1,0,0]>|right=<[currCoord].add[0,0,1]>|forward=<[currCoord].add[-1,0,0]>|backward=<[currCoord].add[0,0,-1]>].parse_tag[<[parse_value].as[map]>]>

    - foreach <[shortLookaround]>:
        - define dir <[value].values.get[1]>
        - define key <[value].keys.get[1]>

        - if <[dir]> == <[startCoord]> && <[sortedCornerList].size> > 3:
            - while stop

        - if <[sortedCornerList].contains[<[dir]>]>:
            - foreach next

        - if <[exteriorCorners].contains[<[dir]>]>:
            - define sortedCornerList:->:<[dir]>
            - define currCoord <[dir]>
            - define previousPointDir <[key]>
            - define lastJump 1
            - define foundNextCoord true
            - while next

    NormalLookaround:
    - foreach <[catchmentList]>:
        - define dir <[value].values.get[1]>
        - define key <[value].keys.get[1]>

        - if <[dir]> == <[startCoord]> && <[sortedCornerList].size> > 3:
            - while stop

        - if <[sortedCornerList].contains[<[dir]>]>:
            - foreach next

        - if <[exteriorCorners].contains[<[dir]>]>:
            - define sortedCornerList:->:<[dir]>
            - define currCoord <[dir]>
            - define previousPointDir <[key]>
            - define lastJump 15
            - define foundNextCoord true
            - while next

    script:
    - define kingdomList <proc[GetKingdomList]> if:<[kingdomList].exists.not>
    - define useCache false if:<[useCache].exists.not>

    - foreach <[kingdomList]> as:kingdom:
        - if <[useCache]> && <[world].has_flag[dynmap.cache.<[kingdom]>.cornerList]>:
            - define sortedCornerList <[world].flag[dynmap.cache.<[kingdom]>.cornerList]>

        - else:
            - define kingdomName <proc[GetKingdomName].context[<[kingdom]>]>
            - define core <server.flag[kingdoms.<[kingdom]>.claims.core].if_null[<list[]>]>
            - define castle <server.flag[kingdoms.<[kingdom]>.claims.castle].if_null[<list[]>]>
            - define allCuboids <[core].include[<[castle]>].parse_tag[<[parse_value].cuboid>]>

            - if <[allCuboids].size> == 0:
                - narrate format:admincallout SKIPPED <[kingdomName].color[gray].to_uppercase>!
                - foreach next

            - define allCorners <[allCuboids].parse_tag[<[parse_value].corners.parse_tag[<[parse_value].with_y[255]>]>].combine.deduplicate>
            - define excludedCorners <list[]>

            - foreach <[allCorners]> as:corner:
                - define surroundingCuboid <cuboid[<[world].name>,<[corner].forward[8].left[8].up[1].xyz>,<[corner].backward[8].right[8].down[1].xyz>]>
                - define amountofCorners 0

                - foreach <[allCorners]> as:comp:
                    - if <[amountOfCorners]> == 4:
                        - define excludedCorners:->:<[corner]>
                        - foreach stop

                    - if <[comp].is_within[<[surroundingCuboid]>]>:
                        - define amountOfCorners:++

            - define exteriorCorners <[allCorners].exclude[<[excludedCorners]>]>
            - define startCoord <[exteriorCorners].get[1]>
            - define currCoord <[startCoord]>
            - define sortedCornerList <list[<[currCoord]>]>
            - define previousPointDir null
            - define hasStarted false
            - define lastJump 15

            - while <[startCoord]> != <[currCoord]> || !<[hasStarted]>:
                - define hasStarted true
                - define foundNextCoord false

                ## Note: Still keeping this here until I am absolutely sure that the algo. is solid
                ##       although I've upped the limit to 200.
                - if <[loop_index]> >= 200:
                    - narrate format:debug "Loop exceeded <[loop_index]> iterations! Stopping Queue..."
                    - while stop

                - define catchmentList <list[left=<[currCoord].left[15]>|right=<[currCoord].right[15]>|forward=<[currCoord].forward_flat[15]>|backward=<[currCoord].backward_flat[15]>].parse_tag[<[parse_value].as[map]>]>

                - if <[previousPointDir].is_in[left|right|backward|forward]>:
                    - define catchmentList <[catchmentList].filter_tag[<[filter_value].keys.get[1].equals[<[previousPointDir]>].not>].include[<[catchmentList].filter_tag[<[filter_value].keys.get[1].equals[<[previousPointDir]>]>]>]>

                - if <[lastJump]> != 15:
                    - inject <script.name> path:ShortLookaround
                    - inject <script.name> path:NormalLookaround

                - else:
                    - inject <script.name> path:NormalLookaround
                    - inject <script.name> path:ShortLookaround

            - flag <[world]> dynmap.cache.<[kingdom]>.cornerList:<[sortedCornerList]>

    - foreach <[sortedCornerList].parse_tag[<[parse_value].with_y[<[player].location.y.sub[25]>]>]>:
        - showfake red_wool <[value]> d:30s
        - wait 10t


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

DynmapWorldTick_Handler:
   type: world
   debug: false
   enabled: false
   events:
       on system time minutely every:15:
       - execute refreshdynmap as_server

dynmap_task:
    type: task
    debug: false
    script:
    - foreach <script[dynmap_config].data_key[configs]> key:name as:options:
        - define world <world[<[options.world]>].if_null[null]>

        - if <[world]> == null:
            - announce to_console "<red>WARNING: <white>World '<[options.world].color[dark_red]>' does not exist or isn't loaded!"
            - foreach next

        - foreach <[options.path]> as:path:
            - if !<[world].has_flag[<[path]>]>:
                - narrate format:debug "World '<[world].name.color[gold]>' does not contain the flag <[path].color[aqua]>"
                - foreach next

            - foreach <[world].flag[<[path]>]>:
                - define note <[value].as[list].get[2]>
                - define note_name <[value].as[list].get[1]>

                - if <[note].as[cuboid].exists>:
                    - define area <cuboid[<[note]>]>
                    - execute as_server "dmarker addcorner <[note].min.simple.replace_text[,].with[ ]>" silent
                    - execute as_server "dmarker addcorner <[note].max.simple.replace_text[,].with[ ]>" silent
                    - inject dynmap_add_area

                - else if <[note_name].as[polygon].exists>:
                    - define area <polygon[<[note_name]>]>
                    - foreach "<[area].corners.parse[simple.replace_text[,].with[ ]]>" as:corner:
                        - execute as_server "dmarker addcorner <[corner]>" silent

                    - inject dynmap_add_area

                - else if !<[note_name].as[ellipsoid].exists>:
                    - narrate format:debug "<red>WARNING: <white>Path: <[path].color[aqua]> in world: <[world].name.color[gold]> does not contain a AreaObject '<[note_name].color[dark_red]>'"
                    - foreach next

                - inject dynmap_markers

    - run dynmap_remove_area

dynmap_add_area:
    type: task
    debug: false
    script:
    - define set <[options.marker-set].exists.if_true[set:<[options.marker-set]>].if_false[<empty>]>
    - define ID <[note_name].replace[<&sp>].with[-]>

    - narrate format:debug "dmarker deletearea id:<[ID]> <[set]>"
    - narrate format:debug "dmarker addarea id:<[ID]> <[set]> label:"<script[dynmap_config].parsed_key[configs.<[name]>.label].space_separated.if_null[<empty>]>""
    - narrate format:debug "dmarker updatearea id:<[ID]> <[set]> color:<[options.color].if_null[c7ba75]> fillcolor:<[options.fillcolor].if_null[feee97]> opacity:<[options.opacity].if_null[1]> fillopacity:<[options.fillopacity].if_null[0.5]> weight:<[options.weight].if_null[2]>" silent
    - narrate format:debug "dmarker clearcorners"

    - execute as_server "dmarker deletearea id:<[ID]>" silent
    - execute as_server "dmarker addarea id:<[ID]> label:"<script[dynmap_config].parsed_key[configs.<[name]>.label].space_separated.if_null[<empty>]>"" silent
    - execute as_server "dmarker updatearea id:<[ID]> color:<[options.color].if_null[c7ba75]> fillcolor:<[options.fillcolor].if_null[feee97]> opacity:<[options.opacity].if_null[1]> fillopacity:<[options.fillopacity].if_null[0.5]> weight:<[options.weight].if_null[2]>" silent
    - execute as_server "dmarker clearcorners" silent


dynmap_markers:
    type: task
    debug: false
    script:
    - define marker-set <[options.marker-set].exists.if_true[<[options.marker-set]>].if_false[Markers]>
    - if !<server.flag[dynmap.areamarkers.<[marker-set]>].if_null[<list>].contains[<[note_name]>]>:
        - flag server dynmap.areamarkers.<[marker-set]>:->:<[note_name]>

    - flag server dynmap.check.<[marker-set]>:->:<[note_name]>


dynmap_remove_area:
    type: task
    debug: false
    script:
    - foreach <server.flag[dynmap.areamarkers].if_null[<list>]> key:set as:areas:
        - foreach <[areas]> as:area:
            - if <server.flag[dynmap.check.<[set]>].contains[<[area]>].if_null[false]>:
                - foreach next

            - flag server dynmap.areamarkers.<[set]>:<-:<[area]>
            - if <[set]> == Markers:
                - execute as_server "dmarker deletearea id:<[area]>" silent
                - foreach next

            - execute as_server "dmarker deletearea id:<[area]> set:<[set]>" silent

    - flag server dynmap.check:!