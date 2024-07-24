# TODO: Make this an actual tool that admins can use to setup custom world borders + add header.

WorldBorderPoints:
    type: data
    points:
    - -3032,-896
    - -2864,-944
    - -2536,-1064
    - -2344,-1064
    - -2136,-1024
    - -1952,-1128
    - -1624,-1128
    - -1368,-1072
    - -1024,-896
    - -768,-872
    - -512,-1088
    - -224,-1088
    - -88,-1176
    - -8,-1408
    - 272,-1608
    - 576,-1800
    - 776,-1984
    - 952,-2264
    - 968,-2552
    - 928,-2824
    - 808,-3096
    - 656,-3384
    - 736,-3696
    - 520,-3888
    - 168,-4040
    - -24,-4368
    - -32,-4688
    - -368,-5128
    - -440,-5288
    - -968,-5544
    - -1256,-5528
    - -1536,-5656
    - -1808,-5664
    - -2256,-5840
    - -2608,-5920
    - -2960,-5824
    - -3184,-5856
    - -3368,-5640
    - -3320,-5368
    - -3224,-5096
    - -3280,-4872
    - -3208,-4552
    - -3016,-4216
    - -2888,-3968
    - -2992,-3896
    - -3352,-3864
    - -3480,-3624
    - -3496,-3336
    - -3424,-3024
    - -3296,-2744
    - -3176,-2464
    - -2960,-2344
    - -3136,-2240
    - -3464,-2240
    - -3520,-2016
    - -3448,-1696
    - -3288,-1456
    - -3144,-1272
    - -3064,-968


ReconfigureWorldBorder:
    type: task
    definitions: world
    script:
    - if !<[world].exists>:
        - narrate format:admincallout "Unable to create world border; world unknown."
        - determine cancelled

    - define formattedPointList <script[WorldBorderPoints].data_key[points].separated_by[,]>
    - define worldBorder <polygon[<[world]>,0,255,<[formattedPointList]>]>

    - note <[worldBorder]> as:worldborder

    - narrate format:debug <[worldBorder]>


WorldBorder_Handler:
    type: world
    debug: false
    events:
        on player exits polygon:
        - if !<player.is_op>:
            - if <context.area.note_name> == worldborder:
                - if <context.cause.is_in[WALK|TELEPORT|VEHICLE]>:
                    - determine cancelled
