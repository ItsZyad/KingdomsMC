##
## [KAPI]
## All scripts that read and modify data at the squad-level of the army mechanic.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Original Scripts: Jun 2023
## @Date: Oct 2023
## @Script Ver: v1.0
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


GetAllSquadNPCs:
    type: procedure
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Returns a list containing all of the provided squad's NPCs including the leader.
    - ---
    - → [ListTag(NPCTag)]

    script:
    ## Returns a list containing all of the provided squad's NPCs including the leader.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [ListTag<NPCTag>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get full squad list. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get full squad list. No squad exists by name: <[squadName]> in kingdom: <[kingdom]>]>
        - determine null

    - determine <proc[GetSquadNPCs].context[<[kingdom]>|<[squadName]>].include[<proc[GetSquadLeader].context[<[kingdom]>|<[squadName]>]>]>


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

    - if !<server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.squadLeader].exists>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad leader.]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad leader. No squad by name: <[squadName].color[red]> exists.]>
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


GetSquadSentinelName:
    type: procedure
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Returns the name of the internal sentinel-side name used by the provided Kingdoms squad.
    - Will return null if the action fails.
    - ---
    - → ?[ElementTag(String)]

    script:
    ## Returns the name of the internal sentinel-side name used by the provided Kingdoms squad.
    ##
    ## Will return null if the action fails.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> ?[ElementTag<String>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad sentinel name. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad sentinel name. No squad exists with name: <[squadName]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.sentinelSquad]>


GetSquadUpkeep:
    type: procedure
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Gets the upkeep for the squad with the given name and kingdom.
    - Will return null if the action fails.
    - ---
    - → ?[ElementTag(Float)]

    script:
    ## Gets the upkeep for the squad with the given name and kingdom.
    ##
    ## Will return null if the action fails.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> ?[ElementTag<Float>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad upkeep. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad upkeep. No squad with the name: <[squadName].color[red]> exists in <[kingdom].color[aqua]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.upkeep].if_null[1]>


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
    - define equipment.hotbar <[equipment].get[hotbar].parse_tag[<[parse_value].as[item]>]>

    - determine <[equipment]>


GetSquadStation:
    type: procedure
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Returns the location of the squad manager that the given squad is stationed in. If the squad does not exist, the procedure will return null.
    - Will return null if the action fails.
    - ---
    - → ?[LocationTag]

    script:
    ## Returns the location of the squad manager that the given squad is stationed in.
    ## If the squad does not exist, the procedure will return null.
    ##
    ## Will return null if the action fails.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> ?[LocationTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad station location. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad station location. Provided kingdom: <[kingdom].color[aqua]> does not have a squad with the name: <[squadName]>]>
        - determine null

    - foreach <server.flag[kingdoms.<[kingdom]>.armies.barracks]> as:barrackInfo key:barrack:
        - if <[barrackInfo].get[stationedSquads].contains[<[squadName]>]>:
            - determine <[barrackInfo].get[location]>

    - determine null


############################################# SETTERS #############################################

SetSquadLeader:
    type: task
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]|npc[NPCTag]
    description:
    - Sets the provided NPC as the squad leader of the provided squad.
    - Will return null if the action fails.
    - ---
    - → [Void]

    script:
    ## Sets the provided NPC as the squad leader of the provided squad.
    ##
    ## Will return null if the action fails.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ## npc       : [NPCTag]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set squad leader. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set squad leader. Provided kingdom: <[kingdom].color[aqua]> does not have a squad with the name: <[squadName]>]>
        - determine null

    - if !<server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.npcList].contains[<[npc]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set squad leader. Provided NPC: <[npc].color[red]> is not actually a member of the provided squad: <[squadName].color[aqua]>]>
        - determine null

    - if <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.squadLeader]> == <[npc]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set squad leader. Provided NPC: <[npc].color[red]> is already the squad leader.]>
        - determine null

    - define existingSquadLeader <proc[GetSquadLeader].context[<[kingdom]>|<[squadName]>]>

    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.npcList:->:<[existingSquadLeader]> if:<[existingSquadLeader].equals[null].not>
    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.squadLeader:<[npc]>
    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.npcList:<-:<[npc]> if:<server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.npcList].contains[<[npc]>]>
    - flag <[npc]> soldier.isSquadLeader:true


AddSoldierToSquad:
    type: task
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]|npc[NPCTag]
    description:
    - Adds the provided NPC as a soldier to the provided squad.
    - Returns null if the action fails.
    - ---
    - → [Void]

    script:
    ## Adds the provided NPC as a soldier to the provided squad.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ## npc       : [NPCTag]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot add soldier. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot add soldier. Provided kingdom: <[kingdom].color[aqua]> does not have a squad with the name: <[squadName]>]>
        - determine null

    - if <proc[GetSquadNPCs].context[<[kingdom]>|<[squadName]>].contains[<[npc]>]> || <proc[GetSquadLeader].context[<[kingdom]>|<[squadName]>].if_null[null]> == <[npc]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot add soldier. Provided NPC: <[npc].color[red]> is already a member of this squad.]>
        - determine null

    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.npcList:->:<[npc]>


RemoveSoldierFromSquad:
    type: task
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]|npc[NPCTag]
    description:
    - Removes the provided NPC from the provided squad.
    - Returns null if the action fails.
    - ---
    - → [Void]

    script:
    ## Removes the provided NPC from the provided squad.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ## npc       : [NPCTag]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot remove soldier. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot remove soldier. Provided kingdom: <[kingdom].color[aqua]> does not have a squad with the name: <[squadName]>]>
        - determine null

    - if !<proc[GetSquadNPCs].context[<[kingdom]>|<[squadName]>].contains[<[npc]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot remove soldier. Provided NPC: <[npc].color[red]> is not a member of this squad.]>
        - determine null

    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.npcList:<-:<[npc]>


RenameSquad:
    type: task
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]|newName[ElementTag(String)]
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
    ##
    ## >>> [ElementTag<Boolean>]

    - define newInternalName <[newName].replace_text[ ].with[-]>

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot rename squad. Invalid kingdom code provided: <[kingdom]>]>
        - determine false

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get squad by name: <[squadName]>]>
        - determine false

    - if <server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[newInternalName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot rename squad: <[squadName]> to: <[newInternalName]>. Squad with that name already exists]>
        - determine false

    - define squadInfo <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>
    - define squadInfo <[squadInfo].with[name].as[<[newInternalName]>].with[displayName].as[<[newName]>]>

    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[newInternalName]>:<[squadInfo]>
    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>:!

    - foreach <[squadInfo].get[npcList].include[<[squadInfo].get[squadLeader]>]> as:soldier:
        - flag <[soldier]> soldier.squad:<[newInternalName]>

    - determine true


DeleteSquad:
    type: task
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Removes the provided squad from all flag structures that contain it as well as the actual NPCs that comprise it.
    - ---
    - → [Void]

    script:
    ## Removes the provided squad from all flag structures that contain it as well as the actual
    ## NPCs that comprise it.
    ##
    ## kingdom      : [ElementTag<String>]
    ## squadName    : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot delete squad. Invalid kingdom code provided: <[kingdom]>]>
        - stop

    - define squadSMLocation <proc[GetSquadStation].context[<[kingdom]>|<[squadName]>]>

    - if <[squadSMLocation]> == null:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot delete squad. Provided parameter: <[squadSMLocation].color[red]> is not a valid squad manager location!]>
        - stop

    - define npcList <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.npcList]>

    - if <[npcList].size> > 0:
        - foreach <[npcList]> as:soldier:
            - remove <[soldier]>

    - run DeleteSquadReference def.SMLocation:<[squadSMLocation]> def.kingdom:<[kingdom]> def.squadName:<[squadName]>


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

    - if !<[SMLocation].has_flag[squadManager]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot delete squad. Provided parameter: <[SMLocation].color[red]> is not a valid squad manager location!]>
        - stop

    - define SMID <[SMLocation].proc[GenerateSMID]>

    - flag server kingdoms.<[kingdom]>.armies.barracks.<[SMID]>.stationedSquads:<-:<[squadName]>
    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>:!


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

    - if !<[SMLocation].has_flag[squadManager]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot create squad. Provided parameter: <[SMLocation].color[red]> is not a valid squad manager location!]>
        - stop

    - if <[squadComp].object_type> != Map:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot create squad. Provided parameter: <[squadComp]> is not of type: MapTag]>
        - stop

    - define barrackID <[SMLocation].proc[GenerateSMID]>
    - define squadLimitLevel <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.levels.squadLimitLevel]>
    - define squadLimit <script[SquadManagerUpgrade_Data].data_key[levels.SquadAmount.<[squadLimitLevel]>.value]>

    - if <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.stationedSquads].size.if_null[0]> >= <[squadLimit]>:
        - narrate format:callout "These barracks have already reached their stationing capacity!<n>You must upgrade your squad manager to increase its stationing capacity."
        - determine cancelled

    - define internalName <[displayName].replace_text[ ].with[-]>
    - define squadID <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList].last.get[ID].add[1].if_null[1]>
    - define kingdomColor <proc[GetKingdomColor].context[<[kingdom]>]>
    - define hotbar <script.data_key[data.UnitTypeHotbars.<[squadComp].keys.get[1]>].parsed.as[list]>

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

    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[internalName]>:<[squadMap]>
    - flag server kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.stationedSquads:->:<[internalName]>

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

    - if <[squadComp].object_type> != Map:
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


SetSquadUpkeep:
    type: task
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]|amount[ElementTag(Float)]
    description:
    - Sets the upkeep of the provided squad to the provided amount.
    - Returns null if the action fails.
    - ---
    - → [Void]

    script:
    ## Sets the upkeep of the provided squad to the provided amount.
    ##
    ## Returns null if the action fails.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ## amount    : [ElementTag<Float>]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set squad upkeep. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set squad upkeep. Provided kingdom: <[kingdom].color[aqua]> does not have a squad with the name: <[squadName].color[red]>]>
        - determine null

    - if !<[amount].is_decimal>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set squad upkeep. Provided value: <[amount].color[red]> is not an actual decimal]>
        - determine null

    - if <[amount]> < 0:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set squad upkeep to a value below 0]>
        - determine null

    - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.upkeep:<[amount]>


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
    - give SquadOccupyTool_Item
    - give SquadClearAllAttacksTool_Item
    - give MiscOrders_Item
    - give ExitSquadControls_Item
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
