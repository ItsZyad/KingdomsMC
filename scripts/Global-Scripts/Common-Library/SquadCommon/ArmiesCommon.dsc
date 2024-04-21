##
## [KAPI]
## All army-related standard scripts that interact with the armies/squads/SMs at the kingdom-level.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Oct 2023
## @Script Ver: v0.1
##
## ----------------END HEADER-----------------

GetKingdomSquadManagers:
    type: procedure
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

    - determine <server.flag[kingdoms.<[kingdom]>.armies.barracks]>


GetKingdomSquads:
    type: procedure
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

    - determine <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList]>


GetMaxAllowedSMs:
    type: procedure
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
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get SM Location. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    # Note: future configurable(?)
    - determine <server.flag[kingdoms.<[kingdom]>.armies.maximumAllowedSMs].if_null[4]>


WriteArmyDataToKingdom:
    type: task
    definitions: SMLocation[LocationTag]|kingdom[ElementTag(String)]
    description:
    - Ensures that the kingdom.armies flag contains the same information as the squad manager.
    - flag of the provided SMLocation.
    - ---
    - → [Void]

    script:
    ## Ensures that the kingdom.armies flag contains the same information as the squad manager.
    ## flag of the provided SMLocation.
    ##
    ## SMLocation : [LocationTag]
    ## kingdom    : [ElementTag<String>]
    ##
    ## >>> [Void]

    - define squadManagerID <[SMLocation].simple.split[,].remove[last].unseparated>
    - define SMData <[SMLocation].flag[squadManager]>
    - define stationedSquads <[SMData].deep_get[squads.squadList].keys> if:<[SMData].deep_get[squads.squadList].exists>
    - define SMData <[SMData].exclude[kingdom].exclude[id].deep_exclude[squads]>

    - flag server kingdoms.<[kingdom]>.armies.barracks.<[squadManagerID]>:<[SMData]>
    - flag server kingdoms.<[kingdom]>.armies.barracks.<[squadManagerID]>.location:<[SMLocation]>
    - flag server kingdoms.<[kingdom]>.armies.barracks.<[squadManagerID]>.stationedSquads:<[stationedSquads]> if:<[stationedSquads].exists>
    - flag server kingdoms.<[kingdom]>.armies.squads.squadList:!

    - foreach <[SMLocation].flag[squadManager.squads.squadList].if_null[<list[]>]>:
        - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[key]>:<[value]>
