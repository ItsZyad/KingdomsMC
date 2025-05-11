##
## [KAPI]
## Any other kingdom-related common information is retrived and/or edited through the scripts in
## this file.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2023
## @Script Ver: v1.1
##
## ------------------------------------------END HEADER-------------------------------------------

OpenWarpsToKingdom:
    type: task
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]
    description:
    - Opens a kingdom's warps to another target kingdom if not already.
    - ---
    - → [Void]

    script:
    ## Opens a kingdom's warps to another target kingdom if not already.
    ##
    ## kingdom       : [ElementTag(String)]
    ## targetKingdom : [ElementTag(String)]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot modify kingdom warps. Invalid kingdom code(s) provided: <[kingdom]>/<[targetKingdom]>]>
        - determine cancelled

    - if <server.flag[kingdoms.<[kingdom]>.openWarps].contains[<[targetKingdom]>]>:
        - flag server kingdoms.<[kingdom]>.openWarps:->:<[targetKingdom]>


CloseWarpsToKingdom:
    type: task
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]
    description:
    - Closes a given kingdom's warps to another target kingdom if not already.
    - ---
    - → [Void]

    script:
    ## Closes a given kingdom's warps to another target kingdom if not already.
    ##
    ## kingdom       : [ElementTag(String)]
    ## targetKingdom : [ElementTag(String)]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot modify kingdom warps. Invalid kingdom code(s) provided: <[kingdom]>/<[targetKingdom]>]>
        - determine cancelled

    - if <server.flag[kingdoms.<[kingdom]>.openWarps].contains[<[targetKingdom]>]>:
        - flag server kingdoms.<[kingdom]>.openWarps:<-:<[targetKingdom]>


AddWarp:
    type: task
    definitions: kingdom[ElementTag(String)]|location[LocationTag]|warpName[ElementTag(String)]
    description:
    - Adds a warp to the provided kingdom's warp map with the given name.
    - WARNING: Will overwrite any existing warps should the warpName provided already be in use!
    - ---
    - → [Void]

    script:
    ## Adds a warp to the provided kingdom's warp map with the given name.
    ##
    ## WARNING: Will overwrite any existing warps should the warpName provided already be in use!
    ##
    ## kingdom  : [ElementTag(String)]
    ## location : [LocationTag]
    ## warpName : [ElementTag(String)]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot modify kingdom warps. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if <[location].object_type.to_lowercase> != location:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot modify kingdom warps. Expected type location for <&sq>Location<&sq> definition. Instead recieved type: <[location].object_type>]>
        - determine cancelled

    - if <[warpName].object_type.to_lowercase> != element:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot modify kingdom warps. Expected type element for <&sq>warpName<&sq> definition. Instead recieved type: <[warpName].object_type>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.warps.<[warpName]>:<[location]>


RemoveWarp:
    type: task
    definitions: kingdom[ElementTag(String)]|warpName[ElementTag(String)]
    description:
    - Removes a kingdom's warp by the given name if it exists.
    - ---
    - → [Void]

    script:
    ## Removes a kingdom's warp by the given name if it exists.
    ##
    ## kingdom  : [ElementTag(String)]
    ## warpName : [ElementTag(String)]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot modify kingdom warps. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if <server.has_flag[kingdoms.<[kingdom]>.warps.<[warpName]>]>:
        - flag server kingdoms.<[kingdom]>.warps.<[warpName]>:!


GetConfigNode:
    type: procedure
    definitions: node[ElementTag(String)]
    description:
    - Returns the value of the provided config node. The accepted format is [Category].[Setting] (for example: General.version).
    - Please note that this loads nodes from the version of the config that has been loaded into memory (usually at server start), not from config file, itself.
    - Will return null if the action fails.
    - ---
    - → [ObjectTag]

    data:
        # This is for if the user deletes a node that is still in use by the game.
        # Out of the box, this *should* be an identical copy of the config file in
        # ../Kingdoms/config.yml. If it's not then someone didn't do their due diligence before
        # pushing to prod and you should alert a dev or contributor.
        ConfigBackup:
            General:
                version: 0.4.4
                version-name: By Debt And Blood - INDEV BRANCH
                build: 0 /DEV/
            KPM:
                load-unsatisfied-dependencies: true
            Armies:
                squad-manager-upfront: 2000
                squad-manager-upkeep: 500
                squad-manager-min-spacing: 200
                max-allowed-squad-managers: 4
                max-order-distance: 50
                VP-multipliers:
                    outpost: 0.5
                    chunk: 1
            Territory:
                outpost-respec-multiplier: 1.15
                minimum-outpost-distance: 50
                maximum-outpost-size: 3000
                default-max-castle-chunks: 25
                default-max-core-chunks: 50
            Debug:
                show-internal-debug-messages: true
            External:
                Dynmap:
                    map-link: null
            Flavor:
                custom-player-messages: null

    script:
    ## Returns the value of the provided config node. The accepted format is [Category].[Setting]
    ## (for example: General.version).
    ##
    ## Please note that this loads nodes from the version of the config that has been loaded into
    ## memory (usually at server start), not from config file, itself.
    ##
    ## Will return null if the action fails.
    ##
    ## node : [ElementTag(String)]
    ##
    ## >>> [ObjectTag]

    - define configMap <server.flag[kingdoms.config.nodes]>

    - if !<[configMap].deep_get[<[node]>].exists> || <[configMap].deep_get[<[node]>]> == null:
        - if <script.data_key[data.ConfigBackup].deep_get[<[node]>].exists>:
            - determine <script.data_key[data.ConfigBackup].deep_get[<[node]>].if_null[null]>

        - run GenerateKingdomsDebug message:<element[Unable to find config node with the name: <[node].color[red]>. Perhaps there is a typo?]>
        - determine null

    - determine <[configMap].deep_get[<[node]>].if_null[null]>
