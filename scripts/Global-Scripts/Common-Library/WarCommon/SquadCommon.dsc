##
## [KAPI]
## All scripts that read and modify data at the squad-level of the army mechanic.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Original Scripts: Jun 2023
## @Date: Oct 2023
## @Script Ver: v0.1
##
## ------------------------------------------END HEADER-------------------------------------------

# TODO -- New KAPI Scripts to Add:
# TODO/ CreateSquad/SpawnSquad @ location
# TODO/

############################################# GETTERS #############################################

HasSquadSpawned:
    type: procedure
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Returns true if the squad has been spawned at least once before.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns true if the squad has been spawned at least once before.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - determine <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.hasSpawned].if_null[false]>


GetSquadNPCs:
    type: procedure
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Gets a list of the NPCs constituting this squad.
    - ---
    - → [ListTag(NPCTag)]

    script:
    ## Gets a list of the NPCs constituting this squad.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [ListTag<NPCTag>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad list. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad by name: <[squadName]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.npcList].if_null[<list[]>]>


GetSquadComposition:
    type: procedure
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Gets the composition map of the squad provided.
    - ---
    - → [MapTag(ElementTag(String); ElementTag(Integer))]

    script:
    ## Gets the composition map of the squad provided.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [MapTag<ElementTag<String>;<ElementTag<Integer>>>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad comp. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad by name: <[squadName]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.squadComp].if_null[<map[]>]>


GetSquadManpower:
    type: procedure
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Gets the total manpower of the squad provided.
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Gets the total manpower of the squad provided.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad manpower. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad by name: <[squadName]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.totalManpower].if_null[0]>


GetSquadLeader:
    type: procedure
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Gets the npc currently acting as the leader of the squad provided.
    - ---
    - → ?[NPCTag]

    script:
    ## Gets the npc currently acting as the leader of the squad provided.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> ?[NPCTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad leader. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad by name: <[squadName]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.squadLeader].if_null[null]>


GetSquadID:
    type: procedure
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Gets the given squad's numerical ID.
    - ---
    - ?[ElementTag(Integer)]

    script:
    ## Gets the given squad's numerical ID.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> ?[ElementTag<Integer>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad leader. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad by name: <[squadName]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.ID].if_null[null]>


GetSquadName:
    type: procedure
    definitions: kingdom[ElementTag(String)]|ID[ElementTag(Integer)]
    description:
    - Gets the given squad's internal name.
    - ---
    - → ?[ElementTag(String)]

    script:
    ## Gets the given squad's internal name.
    ##
    ## kingdom   : [ElementTag<String>]
    ## ID        : [ElementTag<Integer>]
    ##
    ## >>> ?[ElementTag<String>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad leader. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList].filter_tag[<[filter_value].get[ID].equals[<[ID]>]>].get[1].get[name].if_null[null]>


GetSquadDisplayName:
    type: procedure
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Gets the given squad's display name.
    - ---
    - → ?[ElementTag(String)]

    script:
    ## Gets the given squad's display name.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> ?[ElementTag<String>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad leader. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad by name: <[squadName]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.displayName].if_null[null]>


GetSquadEquipment:
    type: procedure
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Returns a map of the given squad's standard equipment in the following format
    - helmet:     (ItemTag)
    - chestplate: (ItemTag)
    - leggings:   (ItemTag)
    - boots:      (ItemTag)
    - hotbar:     (ListTag(ItemTag))
    - ---
    -     → [MapTag(
    -            (ItemTag);
    -            (ItemTag);
    -            (ItemTag);
    -            (ItemTag);
    -            (ListTag(
    -                (ItemTag)
    -            ))
    -        )]

    script:
    ## Returns a map of the given squad's standard equipment in the following format:
    ## helmet:     <ItemTag>
    ## chestplate: <ItemTag>
    ## leggings:   <ItemTag>
    ## boots:      <ItemTag>
    ## hotbar:     <ListTag<ItemTag>>
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [MapTag<
    ##         <ItemTag>;
    ##         <ItemTag>;
    ##         <ItemTag>;
    ##         <ItemTag>;
    ##         <ListTag<
    ##             <ItemTag>
    ##         >>
    ##     >]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad equipment. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad by name: <[squadName]>]>
        - determine null

    - define equipment <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.standardEquipment].if_null[<map[]>]>
    - define equipment.hotbar <list[]> if:<[equipment].get[hotbar].exists.not>

    - determine <[equipment]>


############################################# SETTERS #############################################


# TODO: It needs to be standard across KAPI for setters to return whether they were successful.
RenameSquad:
    type: task
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]|newName[ElementTag(String)]|SMLocation[?LocationTag]
    description:
    - Renames the squad with the provided name to a new name. Will return true if the action was successful.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Renames the squad with the provided name to a new name. Will return true if the action was successful.
    ##
    ## kingdom    :  [ElementTag<String>]
    ## squadName  :  [ElementTag<String>]
    ## newName    :  [ElementTag<String>]
    ## SMLocation : ?[LocationTag]
    ##
    ## >>> [ElementTag<Boolean>]

    - define newInternalName <[newName].replace_text[ ].with[-]>

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot rename squad. Invalid kingdom code provided: <[kingdom]>]>
        - determine false

    - if !<[SMLocation].exists>:
        - define SMLocation <server.flag[kingdoms.<[kingdom]>.armies.barracks].filter_tag[<[filter_value].get[stationedSquads].contains[<[squadName]>]>].get[1]>

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad by name: <[squadName]>]>
        - determine false

    - if <server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[newInternalName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot rename squad: <[squadName]> to: <[newInternalName]>. Squad with that name already exists]>
        - determine false

    - define squadInfo <[SMLocation].flag[squadManager.squads.squadList.<[squadName]>]>
    - define squadInfo <[squadInfo].with[name].as[<[newInternalName]>].with[displayName].as[<[newName]>]>

    - flag <[SMLocation]> squadManager.squads.squadList.<[newInternalName]>:<[squadInfo]>
    - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>:!

    - foreach <[squadInfo].get[npcList].include[<[squadInfo].get[squadLeader]>]> as:soldier:
        - flag <[soldier]> soldier.squad:<[newInternalName]>

    - run WriteArmyDataToKingdom def.kingdom:<[kingdom]> def.SMLocation:<[SMLocation]>
    - determine true


DeleteSquad:
    type: task
    definitions: SMLocation[LocationTag]|kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Removes the provided squad from all flag structures that contain it as well as the actual NPCs that comprise it.
    - ---
    - → [Void]

    script:
    ## Removes the provided squad from all flag structures that contain it as well as the actual
    ## NPCs that comprise it.
    ##
    ## SMLocation   : [LocationTag]
    ## kingdom      : [ElementTag<String>]
    ## squadName    : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot delete squad. Invalid kingdom code provided: <[kingdom]>]>
        - stop

    - if <proc[GetSMLocation].context[<[SMLocation]>|<[kingdom]>]> == null:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot delete squad. Provided parameter: <[SMLocation].color[red]> is not a valid squad manager location!]>
        - stop

    - define npcList <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>

    - if <[npcList].size> > 0:
        - foreach <[npcList]> as:soldier:
            - remove <[soldier]>

    - run DeleteSquadReference def.SMLocation:<[SMLocation]> def.kingdom:<[kingdom]> def.squadName:<[squadName]>


DeleteSquadReference:
    type: task
    definitions: SMLocation[Location]|kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Removes the provided squad from all flag structures that contain it.
    - ---
    - → [Void]

    script:
    ## Removes the provided squad from all flag structures that contain it.
    ##
    ## SMLocation   : [LocationTag]
    ## kingdom      : [ElementTag<String>]
    ## squadName    : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot delete squad. Invalid kingdom code provided: <[kingdom]>]>
        - stop

    - if <proc[GetSMLocation].context[<[SMLocation]>|<[kingdom]>]> == null:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot delete squad. Provided parameter: <[SMLocation].color[red]> is not a valid squad manager location!]>
        - stop

    - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>:!
    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>:!

    - foreach <server.flag[kingdoms.<[kingdom]>.armies.barracks]> as:barrack:
        - if <[barrack].get[stationedSquads].contains[<[squadName]>]>:
            - flag server kingdoms.<[kingdom]>.armies.barracks.<[key]>.stationedSquads:<-:<[squadName]>


CreateSquadReference:
    type: task
    definitions: SMLocation[LocationTag]|kingdom[ElementTag(String)]|displayName[ElementTag(String)]|squadComp[MapTag]|totalManpower[ElementTag(Integer)]
    description:
    - Creates a new squad reference in the kingdoms.___.armies flag and the squadManager flag attached to the provided SMLocation. But does not create NPCs
    - ---
    - → [Void]

    script:
    ## Creates a new squad reference in the kingdoms.___.armies flag and the squadManager flag
    ## attached to the provided SMLocation. But does not create NPCs
    ##
    ## SMLocation    : [LocationTag]
    ## kingdom       : [ElementTag<String>]
    ## displayName   : [ElementTag<String>]
    ## squadComp     : [MapTag<ElementTag<String>;ElementTag<Integer>>]
    ## totalManpower : [ElementTag<Integer>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot create squad. Invalid kingdom code provided: <[kingdom]>]>
        - stop

    - if <proc[GetSMLocation].context[<[SMLocation]>|<[kingdom]>]> == null:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot create squad. Provided parameter: <[SMLocation].color[red]> is not a valid squad manager location!]>
        - stop

    - if !<[squadComp].object_type> != Map:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot create squad. Provided parameter: <[squadComp]> is not of type: MapTag]>

    - define barrackID <[SMLocation].xyz.replace_text[,]>
    - define squadLimitLevel <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.levels.squadLimitLevel]>
    - define squadLimit <script[SquadManagerUpgrade_Data].data_key[levels.SquadAmount.<[squadLimitLevel]>.value]>

    - if <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.stationedSquads].size.if_null[0]> >= <[squadLimit]>:
        - narrate format:callout "These barracks have already reached their stationing capacity!<n>You must upgrade your squad manager to increase its stationing capacity."
        - determine cancelled

    - define internalName <[displayName].replace_text[ ].with[-]>
    - define squadID <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList].last.get[ID].add[1].if_null[1]>
    - define kingdomColor <proc[GetKingdomColor].context[<[kingdom]>]>
    - define hotbar <script.data_key[data.UnitTypeHotbars.<[squadComp].keys.get[1]>]>

    - definemap squadMap:
        npcList: <list[]>
        squadComp: <[squadComp]>
        totalManpower: <[totalManpower]>
        hasSpawned: false
        displayName: <[displayName]>
        ID: <[squadID]>
        name: <[internalName]>
        upkeep: <proc[CalculateSquadUpkeep].context[<[kingdom]>|<[squadComp]>]>
        # Note: could be an upgrade to allow for better default equipment(?)
        standardEquipment:
            helmet: <item[leather_helmet[color=<[kingdomColor]>]].with_flag[defaultArmor]>
            chestplate: <item[leather_chestplate].with_flag[defaultArmor]>
            leggings: <item[leather_leggings].with_flag[defaultArmor]>
            boots: <item[leather_boots].with_flag[defaultArmor]>
            hotbar: <[hotbar]>

    - flag <[SMLocation]> squadManager.squads.squadList.<[internalName]>:<[squadMap]>
    - run WriteArmyDataToKingdom def.SMLocation:<[SMLocation]> def.kingdom:<[kingdom]>

    - if <player.exists>:
        - narrate format:callout "Created squad with name: <[displayName]>"

    # Note: future configurable
    data:
        UnitTypeHotbars:
            swordsmen: <list[wooden_sword]>
            archers: <list[bow]>


CalculateSquadUpkeep:
    type: procedure
    definitions: kingdom[ElementTag(String)]|squadComp[MapTag(ElementTag(Integer))]
    description:
    - Generates a daily upkeep cost for the squad with the provided kingdom and composition.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Generates a daily upkeep cost for the squad with the provided kingdom and composition.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadComp : [MapTag<ElementTag<Integer>>]
    ##
    ## >>> [ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot calculate squad upkeep. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<[squadComp].object_type> != Map:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot calculate squad upkeep. Provided parameter: <[squadComp]> is not of type: MapTag]>
        - determine null

    - define totalCost 0

    # This is the value above which prestige actually starts reducing the cost of the squad unit.
    # (Must always be below 100).
    - define prestigeCutoff 45
    - define prestige <[kingdom].proc[GetPrestige]>
    - define prestigeMultiplier <[prestige].sub[<[prestigeCutoff]>].div[100]>
    - define prestigeMultiplier <[prestigeMultiplier].sub[<[prestigeMultiplier].mul[2]>].mul[2]>

    - foreach <[squadComp]> as:amount key:unitType:
        - define baseCost <script.data_key[data.UnitTypeBaseCosts.<[unitType]>].mul[<[amount]>]>
        - define totalCost:+:<[baseCost].mul[<[prestigeMultiplier]>]>

    - determine <[totalCost]>

    data:
        # All keys here will use the standard convention of plurality that Kingdoms uses for unit
        # names (such as 'swordsmen' or 'archers'). But the costs listed here are all on an indivi-
        # dual unit basis.
        UnitTypeBaseCosts:
            swordsmen: 35
            archers: 30


GiveSquadTools:
    type: task
    definitions: player[PlayerTag]|saveInv[ElementTag(Boolean)]
    description:
    - Replaces the provided player's hotbar with squad management tools.
    - ---
    - → [Void]

    script:
    ## Replaces the provided player's hotbar with squad management tools.
    ##
    ## player  : [PlayerTag]
    ## saveInv : [ElementTag(Boolean)]
    ##
    ## >>> [Void]

    - define __player <[player]>
    - define saveInv true if:<[saveInv].exists.not>
    - flag <player> datahold.armies.previousItemSlot:<player.held_item_slot>
    - flag <player> datahold.armies.squadTools:1

    - if <[saveInv]>:
        - run TempSaveInventory def.player:<player>

    - give SquadMoveTool_Item
    - give FormationLineTool_Item
    - give SquadAttackAllTool_Item
    - give SquadAttackTool_Item
    - give SquadAttackMonstersTool_Item
    - inventory set slot:9 origin:ExitSquadControls_Item
    - inventory set slot:8 origin:MiscOrders_Item
    - inventory set slot:7 origin:SquadClearAllAttacksTool_Item
    - adjust <player> item_slot:1


ResetSquadTools:
    type: task
    definitions: player[PlayerTag]
    description:
    - Gives the player back the inventory they had before selecting the squad tools.
    - ---
    - → [Void]

    script:
    ## Gives the player back the inventory they had before selecting the squad tools.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [Void]

    - define __player <[player]>

    - run LoadTempInventory def.player:<player>

    - flag <player> datahold.armies.squadTools:!

    - if <player.has_flag[datahold.armies.previousItemSlot]>:
        - adjust <player> item_slot:<player.flag[datahold.armies.previousItemSlot]>
        - flag <player> datahold.armies.previousItemSlot:!


# @Deprecated
GetSquadInfo:
    type: task
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - @Deprecated [Phase-out]
    - <&sp>
    - Gets the full squad information of a given squad under the given kingdom.
    - ---
    - → [MapTag]

    script:
    ## Gets the full squad information of a given squad under the given kingdom.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [MapTag]

    # GlobalRef refers to the version of army data stored on the kingdoms.___.armies flag while
    # LocalRef refers to the copy of data stored on each SM belonging to the kingdom
    - define globalRef <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>
    - define barrackList <server.flag[kingdoms.<[kingdom]>.armies.barracks]>
    - define barrackLocation null
    - define localRef null

    - foreach <[barrackList]> as:barrack:
        - if <[barrack].get[stationedSquads].contains[<[squadName]>]>:
            - define barrackLocation <[barrack].get[location]>
            - foreach stop

    - if <[barrackLocation].has_flag[squadManager]>:
        - define localRef <[barrackLocation].flag[squadManager].deep_get[squads.squadList.<[squadName]>]>

        # TODO: find a way to properly compare these maps
        - if !<[localRef].equals[<[globalRef]>]>:
            # - run flagvisualizer def.flag:<[localRef]> def.flagName:localRef
            - determine <[localRef]>

    # - run flagvisualizer def.flag:<[globalRef]> def.flagName:globalRef
    - determine <[globalRef]>
