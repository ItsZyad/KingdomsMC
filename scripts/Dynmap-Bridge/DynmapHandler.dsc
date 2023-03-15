##
## * A (lightly modified) Denizen-Dynmap hook for Kingdoms
##
## @Author: (Icecapade#8825)
## @Editor: Zyad (ITSZYAD#9280)
## @Date: Jan 2022
## @Script Ver: v1.5
##
## Modified for Kingdoms: Apr 2022
##
## ----------------END HEADER-----------------

NEW_DynmapFlagBuilder:
    type: task
    permission: kingdoms.admin
    definitions: world
    script:
    - define kingdomList <list[centran|cambrian|viridian|raptoran]>

    - foreach <[kingdomList]> as:kingdom:
        - define core <server.flag[kingdoms.<[kingdom]>.claims.core].as[list]>
        - define castle <server.flag[kigndoms.<[kingdom]>.claims.castle].as[list]>
        - define kingdomName <script[KingdomRealNames].data_key[<[kingdom]>]>
        - define all <[core].include[<[castle]>]>
        - define as_cuboid <[all].get[1].cuboid>
        - define as_cuboid <[as_cuboid].add_member[<[all].get[2].to[last].parse_tag[<[parse_value].cuboid>]>]>
        - define corners <[as_cuboid].corners>
        - define uselessCorners <list[]>

        - foreach <[as_cuboid].outline_2d[100]> as:loc:
            - foreach <list[16|-16]> as:xDiff:
                - foreach <list[16|-16]> as:zDiff:
                    - if <[as_cuboid].contains[<[loc].add[<[xDiff]>,0,<[zDiff]>]>]>:
                        - define corners <[corners].exclude[<[loc].add[<[xDiff]>,0,<[zDiff]>]>]>

        # - narrate format:debug castle:<[castle]>
        # - narrate format:debug core:<[core]>

        # - define as_polygon <polygon[<[world].name>,0,256,<[as_cuboid].corners.get[1].x>,<[as_cuboid].corners.get[1].z>]>

        # - narrate format:debug COR:<[as_cuboid].corners>

        # - foreach <[as_cuboid].corners.get[2].to[last]> as:corner:
        #    - define as_polygon <[as_polygon].with_corner[<[corner]>]>

        # - narrate format:debug POLY:<[as_polygon]>
        # - narrate format:debug KING:<[kingdom]>
        # - narrate format:debug CUBD:<[as_cuboid]>

        # - showfake red_stained_glass <[as_polygon].outline_2d[<player.location.y>]> d:10s
        - showfake green_stained_glass <[corners].parse_tag[<[parse_value].with_y[<player.location.y>]>]> d:20s

        - narrate format:debug "Cancelled script!"
        - determine cancelled

        - flag <[world]> dynmap.kingdoms.<[kingdom]>.region:<list[<[kingdomName]>|<[as_cuboid]>]>
        - define outposts <server.flag[kingdoms.<[kingdom]>.outpostList].to_pair_lists>
        - flag <[world]> dynmap.kingdoms.<[kingdom]>.outposts:<list[]>

        - foreach <[outposts]> as:outpost:
            - define cornerone <[outpost].get[2].get[cornerone].xyz>
            - define cornertwo <[outpost].get[2].get[cornertwo].xyz>
            - define name <[outpost].get[2].get[name]>

            - define region <cuboid[<player.location.world.name>,<[cornerone]>,<[cornertwo]>]>

            - flag <[world]> dynmap.kingdoms.<[kingdom]>.outposts:<[world].flag[dynmap].deep_get[kingdoms.<[kingdom]>.outposts].include_single[<[name]>|<[region]>]>

        - narrate format:debug -------------------------


DynmapFlagBuilder:
    type: task
    permission: kingdoms.admin
    definitions: world
    script:
    - define kingdomList <list[centran|cambrian|viridian|raptoran]>

    - foreach <[kingdomList]> as:kingdom:
        - define core <server.flag[kingdoms.<[kingdom]>.claims.core].as[list]>
        - define castle <server.flag[kigndoms.<[kingdom]>.claims.castle].as[list]>
        - define kingdomName <script[KingdomRealNames].data_key[<[kingdom]>]>
        - define all <[core].include[<[castle]>]>
        - define as_cuboid <[all].get[1].cuboid>
        - narrate format:debug castle:<[castle]>
        - narrate format:debug core:<[core]>

        - foreach <[all]> as:chunk:
            - define as_cuboid <[as_cuboid].include[<[chunk].cuboid>]>

        - define x_size <[as_cuboid].max.x.sub[<[as_cuboid].min.x>]>
        - define z_size <[as_cuboid].max.z.sub[<[as_cuboid].min.z>]>

        - narrate format:debug XSIZ:<[x_size]>

        - flag <[world]> dynmap.kingdoms.<[kingdom]>.region:<list[<[kingdomName]>|<[as_cuboid]>]>

        - narrate format:debug KING:<[kingdom]>
        - narrate format:debug CUBD:<[as_cuboid]>
        - narrate format:debug SIZE:<[x_size].mul[<[z_size]>]>

        - define outposts <server.flag[kingdoms.<[kingdom]>.outpostList].to_pair_lists>

        - flag <[world]> dynmap.kingdoms.<[kingdom]>.outposts:<list[]>

        - foreach <[outposts]> as:outpost:
            - define cornerone <[outpost].get[2].get[cornerone].xyz>
            - define cornertwo <[outpost].get[2].get[cornertwo].xyz>
            - define name <[outpost].get[2].get[name]>

            - define region <cuboid[<player.location.world.name>,<[cornerone]>,<[cornertwo]>]>

            - flag <[world]> dynmap.kingdoms.<[kingdom]>.outposts:<[world].flag[dynmap].deep_get[kingdoms.<[kingdom]>.outposts].include_single[<[name]>|<[region]>]>

        - narrate format:debug -------------------------


DynmapTask:
    type: command
    name: refreshdynmap
    usage: /refreshdynmap
    permission: kingdoms.admin
    description: Admin Command - Updates all Kingdoms markers on Dynmap
    script:
    - define world <player.location.world>
    - define kingdomList <list[centran|cambrian|viridian|raptoran]>
    - definemap KingdomTextColors:
        raptoran: f14|812
        centran: 34c|16a
        viridian: 181|571
        cambrian: c27100|faaa39

    - foreach <[kingdomList]> as:kingdom:

        # Main outpost loop #
        - foreach <[world].flag[dynmap].deep_get[kingdoms.<[kingdom]>.outposts]> as:entry:
            - define areaName <[entry].as[list].get[1]>
            - define area <[entry].as[list].get[2]>
            - define ID <[areaName].replace[<&sp>].with[-]>

            - narrate format:debug ID:<[ID]>
            - narrate format:debug AR:<[area]>
            - narrate format:debug --------------------

            - execute as_op "dmarker addcorner <[area].min.simple.replace_text[,].with[<&sp>]>" silent
            - execute as_op "dmarker addcorner <[area].max.simple.replace_text[,].with[<&sp>]>" silent
            - execute as_op "dmarker deletearea id:<[ID]> set:outposts" silent
            - execute as_op "dmarker addarea id:<[ID]> set:outposts label:"[Outpost] <script[KingdomRealNames].data_key[<[kingdom]>]>"" silent
            - execute as_op "dmarker updatearea id:<[ID]> set:outposts color:<[KingdomTextColors].get[<[kingdom]>].as[list].get[1]> fillcolor:<[KingdomTextColors].get[<[kingdom]>].as[list].get[2]> opacity:0.7 fillopacity:0.5 weight:2" silent
            - execute as_op "dmarker clearcorners" silent

        - define ID main_region_<[kingdom]>
        - define regionEntry <[world].flag[dynmap].deep_get[kingdoms.<[kingdom]>.region]>
        - define region <[regionEntry].get[2].as[cuboid]>

        - narrate format:debug REG:<[region]>

        - execute as_op "dmarker addcorner <[region].min.simple.replace_text[,].with[ ]>" silent
        - execute as_op "dmarker addcorner <[region].max.simple.replace_text[,].with[ ]>" silent
        - execute as_op "dmarker deletearea id:<[ID]> set:regions"
        - execute as_op "dmarker addarea id:<[ID]> set:regions label:"[Kingdom] <script[KingdomRealNames].data_key[<[kingdom]>]>""
        - execute as_op "dmarker updatearea id:<[ID]> set:regions color:<[KingdomTextColors].get[<[kingdom]>].as[list].get[1]> fillcolor:<[KingdomTextColors].get[<[kingdom]>].as[list].get[2]> opacity:0.7 fillopacity:0.5 weight:2"
        - execute as_op "dmarker clearcorners"

    - narrate format:admincallout "Successfully refreshed Dynmap for world: <[world]>"

#DynmapWorldTick_Handler:
#    type: world
#    debug: false
#    events:
#        on system time minutely every:15:
#        - run dynmap_task

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