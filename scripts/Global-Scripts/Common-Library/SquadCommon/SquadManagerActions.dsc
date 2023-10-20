##
## [KAPI]
## All scripts relating to the reading and modification of data specific to the squad manager only.
##
## @Author: Zyad (ITSZYAD#9280)
## @Original Scripts: Jun 2023
## @Date: Oct 2023
## @Script Ver: v0.1
##
## ----------------END HEADER-----------------

GenerateSMID:
    type: task
    definitions: location
    script:
    ## Generates the ID used to refer to SMs in the kingdom flag using the location of the SM
    ##
    ## location : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - determine <[location].simple.split[,].remove[last].unseparated>


GetSMName:
    type: procedure
    definitions: SMLocation
    script:
    ## Gets the internal name of the squad manager.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ElementTag<String>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - determine <[SMLocation].flag[squadManager.name]>


GetSMKingdom:
    type: procedure
    definitions: SMLocation
    script:
    ## Gets the squad manager's kingdom affiliation.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ElementTag<String>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - determine <[SMLocation].flag[squadManager.kingdom]>


GetMaxSMAOESize:
    type: procedure
    definitions: SMLocation
    script:
    ## Gets the maximum size that a squad manager's AOE can be at its current level.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - define AOELevel <[SMLocation].flag[squadManager.levels.AOELevel]>

    - determine <script[SquadManagerUpgrade_Data].data_key[levels.AOE.<[AOELevel]>.value]>


GetSquadLimit:
    type: procedure
    definitions: SMLocation
    script:
    ## Gets the maximum amount of squads that can be stationed under this squad manager
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - define squadLevel <[SMLocation].flag[squadManager.levels.squadLimitLevel].if_null[0]>
    - define squadLimit <script[SquadManagerUpgrade_Data].data_key[levels.SquadAmount.<[squadLevel]>.value]>

    - determine <[squadLimit]>


GetMaxSquadSize:
    type: procedure
    definitions: SMLocation
    script:
    ## Gets the maximum size squad that can be created using this squad manager's composer.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - define squadSizeLevel <[SMLocation].flag[squadManager.levels.squadSizeLevel].if_null[0]>
    - define maxSquadSize <script[SquadManagerUpgrade_Data].data_key[levels.SquadSize.<[squadSizeLevel]>.value]>

    - determine <[maxSquadSize]>


GetStationingCapacity:
    type: procedure
    definitions: SMLocation
    script:
    ## Gets the maximum size of squads that can be stationed under this squad manager.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - define stationCapacity <[SMLocation].flag[squadManager.levels.stationCapacity]>

    - determine <[stationCapacity]>


GetSMAOESize:
    type: procedure
    definitions: SMLocation
    script:
    ## Gets the current size of a squad manager's AOE.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - determine <[SMLocation].flag[squadManager.AOESize]>


GetSMArea:
    type: procedure
    definitions: SMLocation
    script:
    ## Gets the CuboidTag representing a squad manager's AOE.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [CuboidTag]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - determine <[SMLocation].flag[squadManager.area]>


GetSMArmoryLocations:
    type: procedure
    definitions: SMLocation
    script:
    ## Gets a list of all the locations assigned as armories in this squad manager.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ListTag<LocationTag>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - determine <[SMLocation].flag[squadManager.armories]>


GetSquadSMLocation:
    type: task
    definitions: kingdom|squadName
    script:
    ## Gets the SM associated with the squad provided
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [LocationTag]

    - define barracks <server.flag[kingdoms.<[kingdom]>.armies.barracks]>
    - define stationingInfo <[barracks].parse_value_tag[<[parse_value].get[stationedSquads]>]>

    - foreach <[stationingInfo]>:
        - if <[value].contains[<[squadName]>]>:
            - define SMID <[key]>
            - define location <[barracks].get[<[SMID]>].get[location]>
            - determine <[location]>


WriteArmyDataToKingdom:
    type: task
    definitions: SMLocation|kingdom
    script:
    ## Ensures that the kingdom.armies flag contains the same information as the squad manager
    ## flag of the provided SMLocation
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
