##
## [KAPI]
## All scripts relating to the reading and modification of data specific to the squad manager only.
##
## @Author: Zyad (ITSZYAD#9280)
## @Original Scripts: Jun 2023
## @Date: Oct 2023
## @Script Ver: v1.1
##
## ----------------END HEADER-----------------

GenerateSMID:
    type: procedure
    debug: false
    definitions: location[LocationTag]
    description:
    - Generates the ID used to refer to SMs in the kingdom flag using the location of the SM.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Generates the ID used to refer to SMs in the kingdom flag using the location of the SM.
    ##
    ## location : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - if <[location].object_type> != Location:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot generate a SMID. Provided parameter: <[location].color[red]> is not of type: LocationTag.]>
        - determine null

    - determine <[location].simple.split[,].remove[last].unseparated>


GetSMLocation:
    type: procedure
    debug: false
    definitions: SMID[ElementTag(Integer)]|kingdom[ElementTag(String)]
    description:
    - Gets the location of a specific squad manager, provided the SM's kingdom and ID.
    - ---
    - → ?[LocationTag]

    script:
    ## Gets the location of a specific squad manager, provided the SM's kingdom and ID.
    ##
    ## SMID    : [ElementTag<Integer>]
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> ?[LocationTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get SM Location. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.location].if_null[null]>


GetSMName:
    type: procedure
    debug: false
    definitions: SMLocation[LocationTag]
    description:
    - Gets the internal name of the squad manager.
    - ---
    - → ?[ElementTag(String)]

    script:
    ## Gets the internal name of the squad manager.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> ?[ElementTag<String>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>

    - determine <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.name].if_null[null]>


SetSMName:
    type: task
    debug: false
    definitions: SMLocation[LocationTag]|newName[ElementTag(String)]
    description:
    - Sets the internal name of the squad manager with the provided location.
    - Returns null if the action fails.
    - ---
    - → [Void]

    script:
    ## Sets the internal name of the squad manager with the provided location.
    ## Returns null if the action fails.
    ##
    ## SMLocation : [LocationTag]
    ## newName    : [ElementTag(String)]
    ##
    ## >>> [Void]

    - if !<[SMLocation].has_flag[squadManager]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set squad manager name. Provided parameter: <[SMLocation]> has no flag: <element[squadManager].color[red]>.]>
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>

    - if <server.flag[kingdoms.<[kingdom]>.armies.barracks].parse_value_tag[<[parse_value].get[name]>].values.contains[<[newName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set squad manager name. Name provided: <[newName].color[red]> is already used by another SM.]>
        - determine null

    - define SMID <[SMLocation].proc[GenerateSMID]>

    - flag server kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.name:<[newName]>


GetSMUpkeep:
    type: procedure
    debug: false
    definitions: SMLocation[LocationTag]
    description:
    - Gets the upkeep of the given squad manager.
    - ---
    - → ?[ElementTag(String)]

    script:
    ## Gets the upkeep of the given squad manager.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> ?[ElementTag<String>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad manager upkeep. Provided parameter: <[SMLocation].color[aqua]> has no flag: <element[squadManager].color[red]>.]>
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>

    - determine <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.upkeep].if_null[1]>


SetSMUpkeep:
    type: task
    debug: false
    definitions: SMLocation[LocationTag]|amount[ElementTag(Float)]
    description:
    - Sets the upkeep of the given squad manager to the provided value.
    - Note: this task does not actually calculate the upkeep that the given SM *should* have. It just uses the value passed in.
    - Will return null if the action fails.
    - ---
    - → [Void]

    script:
    ## Sets the upkeep of the given squad manager to the provided value.
    ## Note: this task does not actually calculate the upkeep that the given SM *should* have. It just uses the value passed in.
    ##
    ## Will return null if the action fails.
    ##
    ## SMLocation : [LocationTag]
    ## amount     : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if !<[SMLocation].has_flag[squadManager]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set squad manager upkeep. Provided parameter: <[SMLocation].color[aqua]> has no flag: <element[squadManager].color[red]>.]>
        - determine null

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set squad manager upkeep. Provided value: <[amount].color[red]> is not an actual decimal]>
        - determine null

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set squad manager upkeep to a value below 0]>
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>

    - flag server kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.upkeep:<[amount]>


GetSMKingdom:
    type: procedure
    debug: false
    definitions: SMLocation[LocationTag]
    description:
    - Gets the squad manager's kingdom affiliation.
    - ---
    - → ?[ElementTag(String)]

    script:
    ## Gets the squad manager's kingdom affiliation.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> ?[ElementTag<String>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - determine <[SMLocation].flag[squadManager.kingdom].if_null[null]>


GetMaxSMAOESize:
    type: procedure
    debug: false
    definitions: SMLocation[LocationTag]
    description:
    - Gets the maximum size that a squad manager's AOE can be at its current level.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Gets the maximum size that a squad manager's AOE can be at its current level.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>
    - define AOELevel <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.levels.AOELevel]>

    - determine <script[SquadManagerUpgrade_Data].data_key[levels.AOE.<[AOELevel]>.value]>


GetSquadLimit:
    type: procedure
    debug: false
    definitions: SMLocation[LocationTag]
    description:
    - Gets the maximum amount of squads that can be stationed under this squad manager.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Gets the maximum amount of squads that can be stationed under this squad manager.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>
    - define squadLevel <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.levels.squadLimitLevel].if_null[0]>

    - determine <script[SquadManagerUpgrade_Data].data_key[levels.SquadAmount.<[squadLevel]>.value]>


GetMaxSquadSize:
    type: procedure
    debug: false
    definitions: SMLocation[LocationTag]
    description:
    - Gets the maximum size squad that can be created using this squad manager's composer.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Gets the maximum size squad that can be created using this squad manager's composer.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>
    - define squadSizeLevel <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.levels.squadSizeLevel].if_null[0]>

    - determine <script[SquadManagerUpgrade_Data].data_key[levels.SquadSize.<[squadSizeLevel]>.value]>


GetStationingCapacity:
    type: procedure
    debug: false
    definitions: SMLocation[LocationTag]
    description:
    - Gets the maximum size of squads that can be stationed under this squad manager.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Gets the maximum size of squads that can be stationed under this squad manager.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>

    - determine <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.levels.stationCapacity].if_null[1]>


CalculateSMStationingCapacity:
    type: procedure
    debug: false
    definitions: bedCount[ElementTag(Integer)]
    script:
    # Station count equation:
    # s = round(sqrt(b) * b ^ 0.7)

    - determine <[bedCount].sqrt.mul[<[bedCount].power[0.7]>].round>


SetStationingCapacity:
    type: task
    debug: false
    definitions: SMLocation[LocationTag]|newCapacity[ElementTag(Integer)]
    description:
    - Changes the maximum size of squads that can be stationed in the SM at the given location.
    - Returns null if the action fails.
    - ---
    - → [Void]

    script:
    ## Changes the maximum size of squads that can be stationed in the SM at the given location.
    ##
    ## Returns null if the action fails.
    ##
    ## SMLocation  : [LocationTag]
    ## newCapacity : [ElementTag<Integer>]
    ##
    ## >>> [Void]

    - if !<[SMLocation].has_flag[squadManager]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set SM station capacity. Provided location: <[SMLocation].color[red]> is not a valid squad manager.]>
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>

    - flag server kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.levels.stationCapacity:<[newCapacity]>


GetSMAOESize:
    type: procedure
    debug: false
    definitions: SMLocation[LocationTag]
    description:
    - Gets the current size of a squad manager's AOE.
    - ---
    - → ?[ElementTag(Integer)]

    script:
    ## Gets the current size of a squad manager's AOE.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> ?[ElementTag<Integer>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>

    - determine <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.AOESize].if_null[null]>


GetSMArea:
    type: procedure
    debug: false
    definitions: SMLocation[LocationTag]
    description:
    - Gets the CuboidTag representing a squad manager's AOE.
    - ---
    - → ?[CuboidTag]

    script:
    ## Gets the CuboidTag representing a squad manager's AOE.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> ?[CuboidTag]

    - if !<[SMLocation].has_flag[squadManager]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get SM area. Provided location: <[SMLocation].color[red]> is not a valid squad manager.]>
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>

    - determine <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.area].if_null[null]>


GenerateSMArea:
    type: procedure
    debug: false
    definitions: SMLocation[LocationTag]|AOE[ElementTag(Integer)]
    description:
    - Returns the cuboid representing the area of effect of a squad manager.
    - Will return null if the action fails.
    - ---
    - → ?[CuboidTag]

    script:
    ## Returns the cuboid representing the area of effect of a squad manager.
    ## Will return null if the action fails.
    ##
    ## SMLocation : [LocationTag]
    ## AOE        : [ElementTag<Integer>]
    ##
    ## >>> ?[CuboidTag]

    - define SMID <[SMLocation].proc[GenerateSMID]>
    - define AOEHalf <[AOE].div[2].round_up>
    - define topCorner <[SMLocation].add[<[AOEHalf]>,<[AOEHalf]>,<[AOEHalf]>]>
    - define bottomCorner <[SMLocation].sub[<[AOEHalf]>,<[AOEHalf]>,<[AOEHalf]>]>

    - determine <cuboid[<[topCorner].world.name>,<[topCorner].xyz>,<[bottomCorner].xyz>]>


SetSMArea:
    type: task
    debug: false
    definitions: SMLocation[LocationTag]|AOE[ElementTag(Integer)]|bypassMaxAOE[ElementTag(Boolean) = false]
    description:
    - Sets the area of effect for squad manager at the provided location to the provided AOE value.
    - If the player sets bypassMaxAOE to true, the task will not check if the provided AOE value is larger than the maximum allowable value for the given SM
    - Will return null if the action fails.
    - ---
    - → [Void]

    script:
    ## Sets the area of effect for squad manager at the provided location to the provided AOE value.
    ## If the player sets bypassMaxAOE to true, the task will not check if the provided AOE value
    ## is larger than the maximum allowable value for the given SM.
    ##
    ## Will return null if the action fails.
    ##
    ## SMLocation   :  [LocationTag]
    ## AOE          :  [ElementTag<Integer>]
    ## bypassMaxAOE : ?[ElementTag<Boolean>]
    ##
    ## >>> [Void]

    - if !<[SMLocation].has_flag[squadManager]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set SM area. Provided location: <[SMLocation].color[red]> is not a valid squad manager.]>
        - determine null

    - define maxAOESize <proc[GetMaxSMAOESize].context[<[SMLocation]>]>
    - define maxAOESize <element[99999]> if:<[bypassMaxAOE]>
    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>

    - if <[AOE]> > <[maxAOESize]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set SM area. Provided AOE: <[AOE].color[red]> is larger than the maximum valid size define for this squad manager.]>
        - determine null

    - define barracksArea <proc[GenerateSMArea].context[<[SMLocation]>|<[AOE]>]>

    - flag server kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.AOESize:<[AOE]>
    - flag server kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.area:<[barracksArea]>


GetSMArmoryLocations:
    type: procedure
    debug: false
    definitions: SMLocation[LocationTag]
    description:
    - Gets a list of all the locations assigned as armories in this squad manager.
    - ---
    - → [ListTag(LocationTag)]

    script:
    ## Gets a list of all the locations assigned as armories in this squad manager.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ListTag<LocationTag>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>

    - determine <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.armories].if_null[<list[]>]>


AddSMArmoryLocation:
    type: task
    debug: false
    definitions: SMLocation[LocationTag]|newArmory[LocationTag]
    description:
    - Adds a new location to the list of armories associated with the SM at the provided location.
    - Will return null if the action fails. Specifically, the task will return null if the location provided does not have an inventory.
    - ---
    - → [Void]

    script:
    ## Adds a new location to the list of armories associated with the SM at the provided location.
    ## Will return null if the action fails. Specifically, the task will return null if the location provided does not have an inventory.
    ##
    ## SMLocation   :  [LocationTag]
    ## newArmory    :  [LocationTag]
    ##
    ## >>> [Void]

    - if !<[SMLocation].has_flag[squadManager]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot add an armory to SM. Provided location: <[SMLocation].color[red]> is not a valid squad manager.]>
        - determine null

    - if !<[newArmory].has_inventory>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot add an armory to SM. Provided location: <[newArmory].color[red]> does not have an inventory, thus cannot be used as an armory.]>
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>

    - if <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.armories].contains[<[newArmory]>]>:
        - stop

    - flag server kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.armories:->:<[newArmory]>


RemoveSMArmoryLocation:
    type: task
    debug: false
    definitions: SMLocation[LocationTag]|armory[LocationTag]
    description:
    - Removes a location from the list of armories associated with the SM at the provided location.
    - Will return null if the action fails.
    - ---
    - → [Void]

    script:
    ## Removes a location from the list of armories associated with the SM at the provided location.
    ##
    ## Will return null if the action fails.
    ##
    ## SMLocation   :  [LocationTag]
    ## armory       :  [LocationTag]
    ##
    ## >>> [Void]

    - if !<[SMLocation].has_flag[squadManager]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot remove an armory from SM. Provided location: <[SMLocation].color[red]> is not a valid squad manager.]>
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>
    - define armories <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.armories].if_null[<list[]>]>

    - if !<[armories].contains[<[armory]>]>:
        - determine null

    - flag server kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.armories:<-:<[armory]>


GetSMSquads:
    type: procedure
    debug: false
    definitions: SMLocation[LocationTag]
    description:
    - Gets a list of all the squads stationed at a certain SM.
    - ---
    - → [ListTag(MapTag)]

    script:
    ## Gets a list of all the squads stationed at a certain SM.
    ##
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ListTag<MapTag>]

    - if !<[SMLocation].has_flag[squadManager]>:
        - determine null

    - define kingdom <[SMLocation].flag[squadManager.kingdom]>
    - define SMID <[SMLocation].proc[GenerateSMID]>
    - define stationedSquads <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.stationedSquads].if_null[<list[]>]>
    - define squadMap <map[]>

    - foreach <server.flag[kingdoms.<[kingdom]>.armies.squads].if_null[<list[]>]> key:squadName:
        - define squadMap.<[squadName]>:<[value]> if:<[squadName].is_in[<[stationedSquads]>]>

    - determine <[squadMap]>


GetSquadSMLocation:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Gets the SM associated with the squad provided.
    - ---
    - → ?[LocationTag]

    script:
    ## Gets the SM associated with the squad provided.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> ?[LocationTag]

    - define barracks <server.flag[kingdoms.<[kingdom]>.armies.barracks]>
    - define stationingInfo <[barracks].parse_value_tag[<[parse_value].get[stationedSquads]>]>

    - foreach <[stationingInfo]>:
        - if <[value].contains[<[squadName]>]>:
            - define SMID <[key]>
            - define location <[barracks].get[<[SMID]>].get[location]>

            - determine <[location]>

    - determine null
