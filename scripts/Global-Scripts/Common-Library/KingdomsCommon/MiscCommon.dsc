##
## [KAPI]
## Any other kingdom-related common information is retrived and/or edited through the scripts in
## this file.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2023
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

OpenWarpsToKingdom:
    type: task
    definitions: kingdom|targetKingdom
    script:
    ## Opens a kingdoms' warps to another target kingdom if not already
    ##
    ## kingdom       : [ElementTag<String>]
    ## targetKingdom : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot modify kingdom warps. Invalid kingdom code(s) provided: <[kingdom]>/<[targetKingdom]>]>
        - determine cancelled

    - if <server.flag[kingdoms.<[kingdom]>.openWarps].contains[<[targetKingdom]>]>:
        - flag server kingdoms.<[kingdom]>.openWarps:->:<[targetKingdom]>


AddWarp:
    type: task
    definitions: kingdom|location|warpName
    description:
    - WARNING: Will overwrite any existing warps should the warpName provided already be in use!

    script:
    ## Adds a warp to the provided kingdom's warp map with the given name.
    ## WARNING: Will overwrite any existing warps should the warpName provided already be in use!
    ##
    ## kingdom  : [ElementTag<String>]
    ## location : [LocationTag]
    ## warpName : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot modify kingdom warps. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if <[location].object_type.to_lowercase> != location:
        - run GenerateInternalError def.category:TypeError message:<element[Cannot modify kingdom warps. Expected type location for <&sq>Location<&sq> definition. Instead recieved type: <[location].object_type>]>
        - determine cancelled

    - if <[warpName].object_type.to_lowercase> != element:
        - run GenerateInternalError def.category:TypeError message:<element[Cannot modify kingdom warps. Expected type element for <&sq>warpName<&sq> definition. Instead recieved type: <[warpName].object_type>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.warps.<[warpName]>:<[location]>


RemoveWarp:
    type: task
    definitions: kingdom|warpName
    script:
    ## Removes a kingdom's warp by the given name if it exists
    ##
    ## kingdom  : [ElementTag<String>]
    ## warpName : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot modify kingdom warps. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if <server.has_flag[kingdoms.<[kingdom]>.warps.<[warpName]>]>:
        - flag server kingdoms.<[kingdom]>.warps.<[warpName]>:!