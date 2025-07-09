##
## [KAPI]
## All army-related standard scripts that interact with the armies/squads/SMs at the kingdom-level.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Oct 2023
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

GetKingdomSquadManagers:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Gets all of a given kingdom's squad managers.
    - ---
    - → [MapTag]

    script:
    ## Gets all of a given kingdom's squad managers.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [MapTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom squad managers. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.armies.barracks].if_null[<map[]>]>


GetKingdomSquads:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Gets all squads belonging to a kingdom.
    - ---
    - → [ListTag(MapTag)]

    script:
    ## Gets all squads belonging to a kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ListTag<MapTag>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom squads. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList].if_null[<list[]>]>


GetMaxAllowedSMs:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Gets the maximum amount of squad managers that a kingdom is allowed to posses.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Gets the maximum amount of squad managers that a kingdom is allowed to posses.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get SM Location. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.armies.maximumAllowedSMs].if_null[<proc[GetConfigNode].context[Armies.max-allowed-squad-managers]>]>
