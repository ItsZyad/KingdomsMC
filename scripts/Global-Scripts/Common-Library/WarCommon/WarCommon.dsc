##
## [KAPI]
## This module contains all KAPI scripts relating to the political aspect of war in Kingdoms such
## as declarations, justifications, and active war tracking.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jul 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

IsAtWarWithKingdom:
    type: procedure
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]
    description:
    - Returns true if the provided kingdom is at war with the other provided kingdom.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns true if the provided kingdom is at war with the other provided kingdom.
    ##
    ## kingdom       : [ElementTag<String>]
    ## targetKingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot check if kingdom is at war. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot check if kingdom is at war. Invalid kingdom code provided: <[targetKingdom]>]>
        - determine null

    - foreach <[kingdom].proc[GetKingdomWars]> as:warID:
        - if <[warID].proc[GetWarParticipants].contains[<[targetKingdom]>]>:
            - determine true

    - determine false


IsJustifyingOnKingdom:
    type: procedure
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]
    description:
    - Returns true if the provided kingdom is justifying on the provided target kingdom.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns true if the provided kingdom is justifying on the provided target kingdom.
    ##
    ## kingdom       : [ElementTag<String>]
    ## targetKingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom justification status. Either one of the kingdom codes provided: <[kingdom]> & <[targetKingdom]> are invalid.]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.war.justifications].contains[<[targetKingdom]>]>


GetJustificationCompletion:
    type: procedure
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]
    description:
    - Will return the time at which the justification made by the provided kingdom against the provided target kingdom will be complete.
    - ---
    - → [TimeTag]

    script:
    ## Will return the time at which the justification made by the provided kingdom against the
    ## provided target kingdom will be complete.
    ##
    ## kingdom       : [ElementTag<String>]
    ## targetKingdom : [ElementTag<String>]
    ##
    ## >>> [TimeTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom justification completion. Either one of the kingdom codes provided: <[kingdom]> & <[targetKingdom]> are invalid.]>
        - determine null

    - if !<server.has_flag[kingdoms.<[kingdom]>.war.justifications.<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom justification completion. The provided kingdom: <[kingdom]> is not currently justifying on the provided target: <[targetKingdom]>.]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.war.justifications.<[targetKingdom]>.completion]>


GetKingdomWarStatus:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Returns true if the provided kingdom is currently at war.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns true if the provided kingdom is currently at war.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom war status. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.war.warStatus].if_null[false]>


## @Alias
IsKingdomAtWar:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - [Alias of `GetKingdomWarStatus`]

    script:
    ## [Alias of GetKingdomWarStatus]
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - determine <proc[GetKingdomWarStatus].context[<[kingdom]>]>


GetKingdomWars:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    description:
    - Returns a list of the ids of all the active wars that the kingdom with the provided name is currently involved in.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Returns a list of the names of all the active wars that the kingdom with the provided name
    ## is currently involved in.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom war list. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    # This will only contain IDs, but actual war data will be contained within kingdoms.wars
    - determine <server.flag[kingdoms.<[kingdom]>.war.wars].if_null[<list[]>]>


GetWarBelligerents:
    type: procedure
    definitions: warID[ElementTag(String)]
    description:
    - Returns the names of all the kingdoms that initiated the war with the provided ID.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Returns the names of all the kingdoms that initiated the war with the provided ID.
    ##
    ## warID : [ElementTag<String>]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine <list[]>

    - determine <server.flag[kingdoms.wars.<[warID]>.belligerents]>


GetWarRetaliators:
    type: procedure
    definitions: warID[ElementTag(String)]
    description:
    - Returns the names of all the kingdoms that were declared on in the war with the provided ID.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Returns the names of all the kingdoms that were declared on in the war with the provided ID.
    ##
    ## warID : [ElementTag<String>]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine <list[]>

    - determine <server.flag[kingdoms.wars.<[warID]>.retaliators]>


GetWarParticipants:
    type: procedure
    definitions: warID[ElementTag(String)]
    description:
    - Returns the names of all the kingdoms involved in the war with the provided ID.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Returns the names of all the kingdoms involved in the war with the provided ID.
    ##
    ## warID : [ElementTag<String>]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine <list[]>

    - determine <[warID].proc[GetWarBelligerents].include[<[warID].proc[GetWarRetaliators]>]>


GetWarStartDate:
    type: procedure
    definitions: warID[ElementTag(String)]
    description:
    - Returns the names of all the kingdoms involved in the war with the provided ID.
    - ---
    - → ?[TimeTag]

    script:
    ## Returns the names of all the kingdoms involved in the war with the provided ID.
    ##
    ## warID : [ElementTag<String>]
    ##
    ## >>> ?[TimeTag]

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine null

    - determine <server.flag[kingdoms.wars.<[warID]>.start]>


GetWarClaimType:
    type: procedure
    definitions: warID[ElementTag(String)]
    description:
    - Returns the type of territory that this war was started over.
    - ---
    - → [ElementTag(String)]

    script:
    ## Returns the type of territory that this war was started over.
    ##
    ## warID : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine null

    - determine <server.flag[kingdoms.wars.<[warID]>.claimType]>


GetWarName:
    type: procedure
    definitions: warID[ElementTag(String)]
    description:
    - Returns the display name of the war with the given ID.
    - Will return null if the action fails.
    - ---
    - → [ElementTag(String)]

    script:
    ## Returns the display name of the war with the given ID.
    ## Will return null if the action fails.
    ##
    ## warID : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine null

    - determine <server.flag[kingdoms.wars.<[warID]>.warName].if_null[null]>


SetWarName:
    type: task
    definitions: warID[ElementTag(String)]|newName[ElementTag(String)]
    description:
    - Will change the name of the war with the given ID to the new name provided.
    - ---
    - → [Void]

    script:
    ## Will change the name of the war with the given ID to the new name provided.
    ##
    ## warID   : [ElementTag<String>]
    ## newName : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine null

    - flag server kingdoms.wars.<[warID]>.warName:<[newName]>


GetAllKingdomLostChunks:
    type: procedure
    definitions: kingdom[ElementTag(String)]|warID[ElementTag(String)]
    description:
    - Returns a list containing all the chunks lost by this kingdom in the current war.
    - ---
    - → [ListTag(ChunkTag)]

    script:
    ## Returns a list containing all the chunks lost by this kingdom in the current war.
    ##
    ## kingdom : [ElementTag<String>]
    ## warID   : [ElementTag<String>]
    ##
    ## >>> [ListTag<ChunkTag>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom<&sq>s lost chunks. Kingdom code provided: <[kingdom].color[red]> is invalid.]>
        - determine <list[]>

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine <list[]>

    - determine <server.flag[kingdoms.wars.<[warID]>.lostChunks.<[kingdom]>].parse_value_tag[<[parse_value]>].values.get[1]>


GetKingdomLostChunksByEnemy:
    type: procedure
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]|warID[ElementTag(String)]
    description:
    - Returns a list containing all the chunnks lost by the provided kingdom in the war with the provided ID at the hands of the provided target kingdom.
    - ---
    - → [ListTag(ChunkTag)]

    script:
    ## Returns a list containing all the chunnks lost by the provided kingdom in the war with the
    ## provided ID at the hands of the provided target kingdom.
    ##
    ## kingdom       : [ElementTag<String>]
    ## targetKingdom : [ElementTag<String>]
    ## warID         : [ElementTag<String>]
    ##
    ## >>> [ListTag<ChunkTag>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom<&sq>s lost chunks. Either one of the kingdom codes provided: <[kingdom]> & <[targetKingdom]> are invalid.]>
        - determine <list[]>

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine <list[]>

    - determine <server.flag[kingdoms.wars.<[warID]>.lostChunks.<[kingdom]>.<[targetKingdom]>].if_null[<list[]>]>


GetAllKingdomLostOutposts:
    type: procedure
    definitions: kingdom[ElementTag(String)]|warID[ElementTag(String)]
    description:
    - Returns a list containing all the names of the outposts lost by this kingdom in the current war.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Returns a list containing all the names of the outposts lost by this kingdom in the current
    ## war.
    ##
    ## kingdom  : [ElementTag<String>]
    ## warID    : [ElementTag<String>]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom<&sq>s lost chunks. Kingdom code provided: <[kingdom].color[red]> is invalid.]>
        - determine <list[]>

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine <list[]>

    - determine <server.flag[kingdoms.wars.<[warID]>.lostOutposts.<[kingdom]>].parse_value_tag[<[parse_value]>].values.get[1]>


GetChunkOccupier:
    type: procedure
    definitions: kingdom[ElementTag(String)]|warID[ElementTag(String)]|chunk[ChunkTag]
    description:
    - Returns the current occupier of the provided chunk in the given war that the provided kingdom is fighting.
    - ---
    - → ?[ElementTag(String)]

    script:
    ## Returns the current occupier of the provided chunk in the given war that the provided
    ## kingdom is fighting.
    ##
    ## kingdom : [ElementTag<String>]
    ## warID   : [ElementTag<String>]
    ## chunk   : [ChunkTag]
    ##
    ## >>> ?[ElementTag(String)]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get chunk occupier. Kingdom code provided: <[kingdom].color[red]> is invalid.]>
        - determine null

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine null

    - if <[chunk].object_type> != Chunk:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot get chunk occupier. Provided definition: <[chunk].color[red]> is not of type: ChunkTag.]>
        - determine null

    - foreach <server.flag[kingdoms.wars.<[warID]>.lostChunks]> key:occupier as:chunks:
        - if <[chunks].contains[<[chunk]>]>:
            - determine <[occupier]>

    - determine null


GetOutpostOccupiers:
    type: procedure
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]
    description:
    - Returns the squads that are currently occupying the provided outpost that belongs to the provided kingdom.
    - ---
    - → [ListTag(MapTag(
    -               ElementTag(String)
    -           ))]

    script:
    ## Returns the squads that are currently occupying the provided outpost that belongs to the
    ## provided kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ## outpost : [ElementTag<String>]
    ##
    ## >>> [ListTag<MapTag<
    ##                  ElementTag<String>
    ##              >>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost occupiers. Invalid kingdom code provided: <[kingdom].color[red]>.]>
        - determine null

    - if !<proc[GetAllOutpostsByKingdom].filter_tag[<[filter_value].contains[<[outpost]>]>].size> == 0:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost occupiers. There is no outpost by the name: <[outpost].color[red]>.]>
        - determine null

    - define targetKingdom <proc[GetAllOutpostsByKingdom].filter_tag[<[filter_value].contains[<[outpost]>]>].keys.get[1]>
    - define warID <[kingdom].proc[GetKingdomWars].filter_tag[<[filter_value].proc[GetWarRetaliators].contains[<[targetKingdom]>]>].get[1]>

    - if !<[warID].is_truthy>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get outpost occupiers. Kingdom (<[kingdom].color[red]>) war status with provided target: <[targetKingdom].color[red]> returned null...]>
        - determine null

    - determine <server.flag[kingdoms.wars.<[warID]>.occupiedOutposts.squads]>


GetTerritoryJustificationLevel:
    type: procedure
    definitions: territoryType[ElementTag(String)]
    description:
    - Each type of territory in kingdoms is required to have a numerical id which indicates its precedence in the heirarchy of territory required by the justification system.
    - This procedure returns the numerical value of the provided territory type.
    - Will return null if the type provided is invalid.
    - ---
    - → ?[ElementTag(Integer)]

    script:
    ## Each type of territory in kingdoms is required to have a numerical id which indicates its
    ## precedence in the heirarchy of territory required by the justification system.
    ##
    ## This procedure returns the numerical value of the provided territory type.
    ## Will return null if the type provided is invalid.
    ##
    ## territoryType : [ElementTag<String>]
    ##
    ## >>> ?[ElementTag<Integer>]

    - definemap territoryMap:
        outpost: 1
        core: 2
        castle: 3

    - determine <[territoryMap].get[<[territoryType]>].if_null[null]>


GetKingdomHighestJustificationLevel:
    type: procedure
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]
    description:
    - Kingdoms are not allowed to justify on another's territory if they have not already fought a war over a lesser type of territory.
    - For example if a kingdom wishes to declare war on another's core territory they must have already fought a war over an outpost.
    - This procedure will return the numeric equivalent of the highest-order territory type the provided kingdom has fought over with the provided target kingdom.
    - NONE = 0, OUTPOST = 1, CORE = 2, CASTLE = 3
    - ---
    - → [ElementTag(Integer)]

    script:
    ## Kingdoms are not allowed to justify on another's territory if they have not already fought a
    ## war over a lesser type of territory. For example if a kingdom wishes to declare war on
    ## another's core territory they must have already fought a war over an outpost.
    ##
    ## This procedure will return the numeric equivalent of the highest-order territory type the
    ## provided kingdom has fought over with the provided target kingdom.
    ##
    ## NONE = 0, OUTPOST = 1, CORE = 2, CASTLE = 3
    ##
    ## kingdom       : [ElementTag<String>]
    ## targetKingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Integer>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom justification status. Either one of the kingdom codes provided: <[kingdom]> & <[targetKingdom]> are invalid.]>
        - determine null

    - define previousJustifications <server.flag[kingdoms.<[kingdom]>.war.previousJustifications.<[targetKingdom]>].if_null[<list[]>]>

    - if <[previousJustifications].is_empty>:
        - determine 0

    - determine <[previousJustifications].parse_tag[<[parse_value].proc[GetTerritoryJustificationLevel]>].replace[null].highest>


StartJustification:
    type: task
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]|claimSize[ElementTag(Integer)]|claimType[ElementTag(String)]|claimTime[DurationTag]|claimName[?ElementTag(String)]
    description:
    - Will start justifications for a war between the two provided kingdoms with the targetKingdom as a retaliator, eventually leading to an automatically triggered war declaration after the provided claim time has elapsed.
    - If the provided claimType is 'outpost' then the 'claimName' definition will become required to record the name of the outpost being justified on.
    - Will return null if the action fails.
    - ---
    - → ?[Void]

    script:
    ## Will start justifications for a war between the two provided kingdoms with the targetKingdom
    ## as a retaliator, eventually leading to an automatically triggered war declaration after the
    ## provided claim time has elapsed.
    ##
    ## If the provided claimType is 'outpost' then the 'claimName' definition will become required
    ## to record the name of the outpost being justified on.
    ##
    ## Will return null if the action fails.
    ##
    ## kingdom       :  [ElementTag<String>]
    ## targetKingdom :  [ElementTag<String>]
    ## claimSize     :  [ElementTag<Integer>]
    ## claimType     :  [ElementTag<String>]
    ## claimTime     :  [DurationTag]
    ## claimName     : ?[ElementTag<String>]
    ##
    ## >>> ?[Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot intitate war justification. Either one of the kingdom codes provided: <[kingdom]> & <[targetKingdom]> are invalid.]>
        - determine null

    - if <server.flag[kingdoms.<[kingdom]>.war.justifications].contains[<[targetKingdom]>].if_null[false]>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot intitate war justification. Kingdom is already justifying againt provided target: <[targetKingdom]>.]>
        - determine null

    - if !<[claimSize].is_integer>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot intitate war justification. The provided claim size is invalid.]>
        - determine null

    - if <[claimTime].object_type> != Duration:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot intitate war justification. The provided claim time is invalid.]>
        - determine null

    - if <[claimType].to_lowercase> == outpost:
        - if !<[claimName].exists>:
            - run GenerateInternalError def.category:TypeError def.message:<element[Cannot intitate war justification. Outpost claims need to use the `claimName` parameter.]>
            - stop

        - runlater DeclareWar id:justification_<[kingdom]>_<[targetKingdom]> def.kingdom:<player.flag[kingdom]> def.targetKingdom:<[targetKingdom]> def.claimSize:<[claimSize]> def.claimType:<[claimType]> def.claimName:<[claimName]> delay:<[claimTime]>

    - runlater DeclareWar id:justification_<[kingdom]>_<[targetKingdom]> def.kingdom:<player.flag[kingdom]> def.targetKingdom:<[targetKingdom]> def.claimSize:<[claimSize]> def.claimType:<[claimType]> delay:<[claimTime]>

    - flag server kingdoms.<[kingdom]>.war.justifications.<[targetKingdom]>.completion:<util.time_now.add[<[claimTime]>]>
    - flag server kingdoms.<[kingdom]>.war.justifications.<[targetKingdom]>.type:<[claimType]>
    - flag server kingdoms.<[kingdom]>.war.justifications.<[targetKingdom]>.size:<[claimSize]>
    - flag server kingdoms.<[kingdom]>.war.justifications.<[targetKingdom]>.name:<[claimName]> if:<[claimName].exists>
    - flag server kingdoms.<[kingdom]>.war.justifications.<[targetKingdom]>.id:justification_<[kingdom]>_<[targetKingdom]>


CancelJustification:
    type: task
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]
    description:
    - Will cancel the justification made by the provided kingdom against the provided target kingdom.
    - Will return null if the action fails.
    - ---
    - → ?[Void]

    script:
    ## Will cancel the justification made by the provided kingdom against the provided target
    ## kingdom.
    ##
    ## Will return null if the action fails.
    ##
    ## kingdom       : [ElementTag<String>]
    ## targetKingdom : [ElementTag<String>]
    ##
    ## >>> ?[Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot intitate war justification. Either one of the kingdom codes provided: <[kingdom]> & <[targetKingdom]> are invalid.]>
        - determine null

    - if <server.flag[kingdoms.<[kingdom]>.war.justifications].contains[<[targetKingdom]>]>:
        - flag server kingdoms.<[kingdom]>.war.justifications.<[targetKingdom]>:!
        - adjust system cancel_runlater:justification_<[kingdom]>_<[targetKingdom]>


DeclareWar:
    type: task
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]|claimSize[ElementTag(Integer)]|claimType[ElementTag(String)]|claimName[?ElementTag(String)]
    description:
    - Will officially start a war between the two kingdoms provided, with the initial kingdom being the belligerent and the target kingdom being the retaliator.
    - Will return null if the action fails.
    - ---
    - → ?[Void]

    script:
    ## Will officially start a war between the two kingdoms provided, with the initial kingdom
    ## being the belligerent and the target kingdom being the retaliator.
    ##
    ## Will return null if the action fails.
    ##
    ## kingdom       :  [ElementTag<String>]
    ## targetKingdom :  [ElementTag<String>]
    ## claimSize     :  [ElementTag<Integer>]
    ## claimType     :  [ElementTag<String>]
    ## claimName     : ?[ElementTag<String>]
    ##
    ## >>> ?[Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot intitate war declaration. Either one of the kingdom codes provided: <[kingdom]> & <[targetKingdom]> are invalid.]>
        - determine null

    - if !<[claimSize].is_integer>:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot intitate war declaration. The provided claim size is invalid.]>
        - determine null

    - if <[claimType].to_lowercase> == outpost:
        - if !<[claimName].exists>:
            - run GenerateInternalError def.category:TypeError def.message:<element[Cannot intitate war declaration. Outpost claims need to use the `claimName` parameter.]>
            - stop

    - define warID <util.random_uuid.split[-].get[1]>

    - flag server kingdoms.<[targetKingdom]>.war.wars:->:<[warID]>
    - flag server kingdoms.<[kingdom]>.war.wars:->:<[warID]>
    - flag server kingdoms.<[kingdom]>.war.justifications.<[targetKingdom]>:!
    - flag server kingdoms.<[kingdom]>.warStatus:true
    - flag server kingdoms.<[targetKingdom]>.warStatus:true

    - definemap warMap:
        belligerents: <list[<[kingdom]>]>
        retaliators: <list[<[targetKingdom]>]>
        start: <util.time_now>
        # War progress is a -100 -> 100 scale where 100 means that the war is won in favor of the
        # belligerent and -100 in favor of the retaliator.
        progress: 0
        claimType: <[claimType]>
        claimSize: <[claimSize]>
        warName: <element[The <[kingdom].proc[GetKingdomShortName]>-<[targetKingdom].proc[GetKingdomShortName]> War]>

    - if <[claimName].exists>:
        - define warMap.claimName:<[claimName]>

    - flag server kingdoms.wars.<[warID]>:<[warMap]>

    - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<[targetKingdom].proc[GetMembers]>].include[<server.online_ops>]>


OccupyChunk:
    type: task
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]|chunk[ChunkTag]|squadLeader[NPCTag]|delay[DurationTag]
    description:
    - Will occupy the provided chunk for the provided kingdom off of the target kingdom after the provided delay has elapsed.
    - Chunk occupations may be cancelled after they are start by using the `CancelChunkOccupation` task.
    - Will return null if the action fails.
    - ---
    - → ?[Void]

    script:
    ## Will occupy the provided chunk for the provided kingdom off of the target kingdom after the
    ## provided delay has elapsed.
    ##
    ## Chunk occupations may be cancelled after they are start by using the `CancelChunkOccupation`
    ## task and providing the same parameters.
    ##
    ## Will return null if the action fails.
    ##
    ## kingdom        : [ElementTag<String>]
    ## targetKingdom  : [ElementTag<String>]
    ## chunk          : [ChunkTag]
    ## squadLeader    : [NPCTag]
    ## delay          : [DurationTag]
    ##
    ## >>> ?[Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot occupy chunk. Either one of the kingdom codes provided: <[kingdom]> & <[targetKingdom]> are invalid.]>
        - determine null

    - if <[chunk].object_type> != Chunk:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot occupy chunk. Provided definition: <[chunk].color[red]> is not of type: ChunkTag.]>
        - determine null

    - if <[delay].object_type> != Duration:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot occupy chunk. Provided definition: <[delay].color[red]> is not of type: DurationTag.]>
        - determine null

    - if <[squadLeader].object_type> != Npc:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot occupy chunk. Provided definition: <[squadLeader].color[red]> is not of type: NPCTag.]>
        - determine null

    - define warID <[kingdom].proc[GetKingdomWars].filter_tag[<[filter_value].proc[GetWarRetaliators].contains[<[targetKingdom]>]>].get[1]>

    - if !<[warID].is_truthy>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot occupy chunk. Kingdom (<[kingdom].color[red]>) war status with provided target: <[targetKingdom].color[red]> returned null...]>
        - determine null

    - define kingdomLostChunks <[targetKingdom].proc[GetAllKingdomLostChunks].context[<[warID]>]>

    - if <[chunk].is_in[<[kingdomLostChunks]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot occupy chunk. Provided chunk: <[chunk].color[red]> has already been occupied by another participant in this war.]>
        - determine null

    - runlater <script.name> path:OccupyChunk_Helper id:<[kingdom]>_<[targetKingdom]>_<[chunk]>_chunk_occupy def.kingdom:<[kingdom]> def.targetKingdom:<[targetKingdom]> def.chunk:<[chunk]> def.squadLeader:<[squadLeader]> def.warID:<[warID]> delay:<[delay]>

    OccupyChunk_Helper:
    - flag server kingdoms.wars.<[warID]>.lostChunks.<[targetKingdom]>.<[kingdom]>:->:<[chunk]>
    - flag <[squadLeader]> datahold.war.occupying:!


CancelChunkOccupation:
    type: task
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]|squadLeader[NPCTag]|chunk[ChunkTag]
    description:
    - Cancels the occupation of the provided chunk by the provided kingdom in a war against the provided targetKingdom.
    - ---
    - → ?[Void]

    script:
    ## Cancels the occupation of the provided chunk by the provided kingdom in a war against the
    ## provided targetKingdom.
    ##
    ## kingdom        : [ElementTag<String>]
    ## targetKingdom  : [ElementTag<String>]
    ## squadLeader    : [NPCTag]
    ## chunk          : [ChunkTag]
    ##
    ## >>> ?[Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot cancel chunk occupation. Either one of the kingdom codes provided: <[kingdom]> & <[targetKingdom]> are invalid.]>
        - determine null

    - if <[chunk].object_type> != Chunk:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot cancel chunk occupation. Provided definition: <[chunk].color[red]> is not of type: ChunkTag.]>
        - determine null

    - if <[squadLeader].object_type> != Npc:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot cancel chunk occupation. Provided definition: <[squadLeader].color[red]> is not of type: NPCTag.]>
        - determine null

    - adjust system cancel_runlater:<[kingdom]>_<[targetKingdom]>_<[chunk]>_chunk_occupy
    - flag <[squadLeader]> datahold.war.occupying:!


ReclaimChunk:
    type: task
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]|squadLeader[NPCTag]|chunk[ChunkTag]|delay[DurationTag]
    description:
    - Will reclaim the provided chunk for the provided kingdom off of the target kingdom after the provided delay has elapsed.
    - Chunk reclamations may be cancelled after they are start by using the `CancelChunkReclamation` task.
    - Will return null if the action fails.
    - ---
    - → ?[Void]

    script:
    ## Will reclaim the provided chunk for the provided kingdom off of the target kingdom after the
    ## provided delay has elapsed.
    ##
    ## Chunk reclamations may be cancelled after they are start by using the
    ## `CancelChunkReclamation` task.
    ##
    ## Will return null if the action fails.
    ##
    ## kingdom        : [ElementTag<String>]
    ## targetKingdom  : [ElementTag<String>]
    ## squadLeader    : [NPCTag]
    ## chunk          : [ChunkTag]
    ## delay          : [DurationTag]
    ##
    ## >>> ?[Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot reclaim chunk. Either one of the kingdom codes provided: <[kingdom]> & <[targetKingdom]> are invalid.]>
        - determine null

    - if <[chunk].object_type> != Chunk:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot reclaim chunk. Provided definition: <[chunk].color[red]> is not of type: ChunkTag.]>
        - determine null

    - if <[squadLeader].object_type> != Npc:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot reclaim chunk. Provided definition: <[squadLeader].color[red]> is not of type: NPCTag.]>
        - determine null

    - if <[delay].object_type> != Duration:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot reclaim chunk. Provided definition: <[delay].color[red]> is not of type: DurationTag.]>
        - determine null

    - runlater <script.name> path:ReclaimChunk_Helper id:<[kingdom]>_<[targetKingdom]>_<[chunk]>_chunk_reclaim def.kingdom:<[kingdom]> def.targetKingdom:<[targetKingdom]> def.chunk:<[chunk]> def.squadLeader:<[squadLeader]> delay:<[delay]>

    ReclaimChunk_Helper:
    - define warID <[kingdom].proc[GetKingdomWars].filter_tag[<[filter_value].proc[GetWarRetaliators].contains[<[targetKingdom]>]>].get[1]>

    - if !<[warID].is_truthy>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot reclaim chunk. Kingdom (<[kingdom].color[red]>) war status with provided target: <[targetKingdom].color[red]> returned null...]>
        - determine null

    - adjust system cancel_runlater:<[kingdom]>_<[targetKingdom]>_<[chunk]>_chunk_reclaim
    - flag <[squadLeader]> datahold.war.occupying:!


CancelChunkReclamation:
    type: task
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]|squadLeader[NPCTag]|chunk[ChunkTag]
    description:
    - Cancels the reclamation of the provided chunk by the provided kingdom in a war against the provided targetKingdom.
    - ---
    - → ?[Void]

    script:
    ## Cancels the reclamation of the provided chunk by the provided kingdom in a war against the
    ## provided targetKingdom.
    ##
    ## kingdom        : [ElementTag<String>]
    ## targetKingdom  : [ElementTag<String>]
    ## squadLeader    : [NPCTag]
    ## chunk          : [ChunkTag]
    ##
    ## >>> ?[Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot cancel chunk occupation. Either one of the kingdom codes provided: <[kingdom]> & <[targetKingdom]> are invalid.]>
        - determine null

    - if <[chunk].object_type> != Chunk:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot cancel chunk occupation. Provided definition: <[chunk].color[red]> is not of type: ChunkTag.]>
        - determine null

    - if <[squadLeader].object_type> != Npc:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot cancel chunk occupation. Provided definition: <[squadLeader].color[red]> is not of type: NPCTag.]>
        - determine null

    - adjust system cancel_runlater:<[kingdom]>_<[targetKingdom]>_<[chunk]>_chunk_reclaim
    - flag <[squadLeader]> datahold.war.occupying:!


OccupyOutpost:
    type: task
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]|outpost[ElementTag(String)]|squadName[ElementTag(String)]|delay[?DurationTag]
    description:
    - Will occupy the provided outpost for the provided kingdom after the an amount of time corresponding to the number of squads that are occupying it has elapsed.
    - If the action succeeds, this script should return the amount of time needed for the outpost to be fully occupied.
    - Will return null if the action fails.
    - ---
    - → ?[DurationTag]

    script:
    ## Will occupy the provided outpost for the provided kingdom after the an amount of time
    ## corresponding to the number of squads that are occupying it has elapsed.
    ##
    ## Will return null if the action fails.
    ##
    ## kingdom       :  [ElementTag<String>]
    ## targetKingdom :  [ElementTag<String>]
    ## outpost       :  [ElementTag<String>]
    ## squadName     :  [ElementTag<String>]
    ## delay         : ?[DurationTag]
    ##
    ## >>> ?[DurationTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot occupy outpost. Invalid kingdom code provided: <[kingdom].color[red]>.]>
        - determine null

    - if !<proc[GetAllOutpostsByKingdom].filter_tag[<[filter_value].contains[<[outpost]>]>].size> == 0:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot occupy outpost. There is no outpost by the name: <[outpost].color[red]>.]>
        - determine null

    - if <[delay].exists> && <[delay].object_type> != Duration:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot occupy outpost. Provided definition: <[delay].color[red]> is not of type: DurationTag.]>
        - determine null

    - define warID <[kingdom].proc[GetKingdomWars].filter_tag[<[filter_value].proc[GetWarRetaliators].contains[<[targetKingdom]>]>].get[1]>

    - if !<[warID].is_truthy>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot occupy outpost. Kingdom (<[kingdom].color[red]>) war status with provided target: <[targetKingdom].color[red]> returned null...]>
        - determine null

    - if <server.flag[kingdoms.wars.<[warID]>.occupiedOutposts.<[outpost]>.squads].if_null[<list[]>].contains[<[squadName]>]>:
        - run GenerateKingdomsDebug def.message:<element[Provided squad is already claiming this outpost. Skipping...]> def.silent:true
        - stop

    - flag server kingdoms.wars.<[warID]>.occupiedOutposts.<[outpost]>.squads.<[squadName]>:<[kingdom]>
    - define occupyingSquadAmount <server.flag[kingdoms.wars.<[warID]>.occupiedOutposts.<[outpost]>.squads].size.if_null[1]>
    - define occupationDelay <duration[<[targetKingdom].proc[GetOutpostSize].context[<[outpost]>].div[64].round_up.mul[5].div[<[occupyingSquadAmount]>]>m]>
    - define occupationDelay <[delay]> if:<[delay].exists>
    - define existingOccupationProgress <duration[0s]>

    - if <util.runlater_ids.contains_match[*_*_<[outpost]>_outpost_occupy]>:
        - define existingRunlater <util.runlater_ids.get[<util.runlater_ids.find_match[*_*_<[outpost]>_outpost_occupy]>]>
        - define existingEndTime <server.flag[kingdoms.wars.<[warID]>.occupiedOutposts.<[outpost]>.finish]>
        - define existingStartTime <server.flag[kingdoms.wars.<[warID]>.occupiedOutposts.<[outpost]>.start]>

        - define existingOccupationDuration <[existingEndTime].duration_since[<[existingStartTime]>]>
        - define existingOccupationProgress <util.time_now.duration_since[<[existingStartTime]>]>

        - adjust system cancel_runlater:<[existingRunlater]>

        - if <[existingOccupationProgress].sub[<[existingOccupationDuration]>].in_seconds> > 0:
            - define occupationDelay <[occupationDelay].sub[<[existingOccupationProgress]>]>

    - flag server kingdoms.wars.<[warID]>.occupiedOutposts.<[outpost]>.start:<util.time_now> if:<server.has_flag[kingdoms.wars.<[warID]>.occupiedOutposts.<[outpost]>.start].not>
    - flag server kingdoms.wars.<[warID]>.occupiedOutposts.<[outpost]>.finish:<util.time_now.add[<[occupationDelay]>]>
    - runlater <script.name> path:OccupyOutpost_Helper id:<[kingdom]>_<[targetKingdom]>_<[outpost]>_outpost_occupy def.warID:<[warID]> def.targetKingdom:<[targetKingdom]> def.kingdom:<[kingdom]> def.outpost:<[outpost]> delay:<[occupationDelay]>

    - run ChunkOccupationVisualizer def.squadLeader:<[kingdom].proc[GetSquadLeader].context[<[squadname]>]> def.occupationDuration:<[occupationDelay]>

    - determine <[occupationDelay]>

    OccupyOutpost_Helper:
    - flag server kingdoms.wars.<[warID]>.lostOutposts.<[targetKingdom]>.<[kingdom]>.<[outpost]>.finish:<server.flag[kingdoms.wars.<[warID]>.occupiedOutposts.<[outpost]>.finish]>
    - flag server kingdoms.wars.<[warID]>.lostOutposts.<[targetKingdom]>.<[kingdom]>.<[outpost]>.start:<server.flag[kingdoms.wars.<[warID]>.occupiedOutposts.<[outpost]>.start]>
    - flag server kingdoms.wars.<[warID]>.lostOutposts.<[targetKingdom]>.<[kingdom]>.<[outpost]>.squads:<server.flag[kingdoms.wars.<[warID]>.occupiedOutposts.<[outpost]>.squads]>
    - flag server kingdoms.wars.<[warID]>.occupiedOutposts.<[outpost]>:!
    - flag <[squadLeader]> datahold.war.occupying:!

    - foreach <util.runlater_ids.find_all_matches[*_*_<[outpost]>_outpost_occupy]> as:runLater:
        - adjust system cancel_runlater:<[runLater]>


CancelOutpostOccupation:
    type: task
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]|outpost[ElementTag(String)]
    description:
    - Cancels the occupation of the provided outpost by the provided kingdom's given squad.
    - ---
    - → ?[Void]

    script:
    ## Cancels the occupation of the provided outpost by the provided kingdom given squad
    ##
    ## kingdom   : [ElementTag<String>]
    ## outpost   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> ?[Void]

    - if !<proc[GetAllOutpostsByKingdom].filter_tag[<[filter_value].contains[<[outpost]>]>].size> == 0:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot cancel outpost occupation. There is no outpost by the name: <[outpost].color[red]>.]>
        - determine null

    - define targetKingdom <proc[GetAllOutpostsByKingdom].filter_tag[<[filter_value].contains[<[outpost]>]>].keys.get[1]>

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot cancel outpost occupation. Either one of the kingdom codes provided: <[kingdom]> & <[targetKingdom]> are invalid.]>
        - determine null

    - adjust system cancel_runlater:<[kingdom]>_<[targetKingdom]>_<[outpost]>_outpost_occupy
    - flag <[kingdom].proc[GetSquadLeader].context[<[squadName]>]> datahold.war.occupying:!


ReclaimOutpost:
    type: task
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]|squadName[ElementTag(String)]|delay[?DurationTag]
    description:
    - Will reclaim the the provided outpost for the provided kingdom if it belonged to it originally and is currently being occupied by another kingdom.
    - Outpost reclamations may be cancelled after they are started by using the `CancelOutpostReclamation` script.
    - If successful, this script will return the amount of time it will take for the reclamation to finish.
    - Will return null if the action fails.
    - ---
    - → ?[DurationTag]

    script:
    ## Will reclaim the the provided outpost for the provided kingdom if it belonged to it
    ## originally and is currently being occupied by another kingdom.
    ##
    ## Outpost reclamations may be cancelled after they are started by using the
    ## `CancelOutpostReclamation` script.
    ##
    ## If successful, this script will return the amount of time it will take for the reclamation
    ## to finish.
    ##
    ## Will return null if the action fails.
    ##
    ## kingdom       :  [ElementTag<String>]
    ## outpost       :  [ElementTag<String>]
    ## squadName     :  [ElementTag<String>]
    ## delay         : ?[DurationTag]
    ##
    ## >>> ?[DurationTag]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot reclaim outpost. Invalid kingdom code provided: <[kingdom].color[red]>.]>
        - determine null

    - if !<proc[GetAllOutpostsByKingdom].filter_tag[<[filter_value].contains[<[outpost]>]>].size> == 0:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot reclaim outpost. There is no outpost by the name: <[outpost].color[red]>.]>
        - determine null

    - if <[delay].exists> && <[delay].object_type> != Duration:
        - run GenerateInternalError def.category:TypeError def.message:<element[Cannot reclaim outpost. Provided definition: <[delay].color[red]> is not of type: DurationTag.]>
        - determine null

    - foreach <[kingdom].proc[GetKingdomWars]> as:warID:
        - if <[delay].exists>:
            - run <script.name> path:ReclaimOutpostInSingleWar def.kingdom:<[kingdom]> def.outpost:<[outpost]> def.delay:<[delay]> def.squadName:<[squadName]> def.warID:<[warID]> save:result

        - run <script.name> path:ReclaimOutpostInSingleWar def.kingdom:<[kingdom]> def.outpost:<[outpost]> def.squadName:<[squadName]> def.warID:<[warID]> save:result
        - define result <entry[result].created_queue.determination.get[1]>

        - if <[result].is_truthy>:
            - determine <[result]>

    - determine null

    ReclaimOutpostInSingleWar:
    - if !<[warID].is_truthy>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot reclaim outpost. The provided warID: <[warID].color[red]> does not belong to any active war.]>
        - determine null

    - if !<[kingdom].proc[GetOutposts].keys.contains[<[outpost]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot reclaim outpost. The provided outpost: <[outpost].color[red]> does not initially belong to the provided kingdom: <[kingdom].color[red]> and therefore cannot reclaim it.<n>To occupy another kingdom<&sq>s outpost you must use the <element[OccupyOutpost].color[gray]> script.]>
        - determine null

    - if <proc[GetAllKingdomLostOutposts].context[<[kingdom]>|<[warID]>].is_empty>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot reclaim outpost. The provided outpost: <[outpost].color[red]> was not being occupied to begin with.]>
        - determine null

    - if <server.flag[kingdoms.wars.<[warID]>.reclaimingOutposts.<[outpost]>.squads].if_null[<list[]>].contains[<[squadName]>]>:
        - run GenerateKingdomsDebug def.message:<element[Provided squad is already reclaiming this outpost. Skipping...]> def.silent:true
        - stop

    - flag server kingdoms.wars.<[warID]>.reclaimingOutposts.<[outpost]>.squads.<[squadName]>:<[kingdom]>

    - define occupyingSquadAmount <server.flag[kingdoms.wars.<[warID]>.reclaimingOutposts.<[outpost]>.squads].size.if_null[1]>
    - define occupationDelay <duration[<[kingdom].proc[GetOutpostSize].context[<[outpost]>].div[64].round_up.mul[5].div[<[occupyingSquadAmount]>]>m]>
    - define occupationDelay <[delay]> if:<[delay].exists>
    - define existingOccupationProgress <duration[0s]>

    - if <util.runlater_ids.contains_match[*_*_<[outpost]>_outpost_reclaim]>:
        - define existingRunlater <util.runlater_ids.get[<util.runlater_ids.find_match[*_*_<[outpost]>_outpost_reclaim]>]>
        - define existingEndTime <server.flag[kingdoms.wars.<[warID]>.reclaimingOutposts.<[outpost]>.finish]>
        - define existingStartTime <server.flag[kingdoms.wars.<[warID]>.reclaimingOutposts.<[outpost]>.start]>

        - define existingOccupationDuration <[existingEndTime].duration_since[<[existingStartTime]>]>
        - define existingOccupationProgress <util.time_now.duration_since[<[existingStartTime]>]>

        - adjust system cancel_runlater:<[existingRunlater]>

        - if <[existingOccupationProgress].sub[<[existingOccupationDuration]>].in_seconds> > 0:
            - define occupationDelay <[occupationDelay].sub[<[existingOccupationProgress]>]>

    - flag server kingdoms.wars.<[warID]>.reclaimingOutposts.<[outpost]>.start:<util.time_now> if:<server.has_flag[kingdoms.wars.<[warID]>.reclaimingOutposts.<[outpost]>.start].not>
    - flag server kingdoms.wars.<[warID]>.reclaimingOutposts.<[outpost]>.finish:<util.time_now.add[<[occupationDelay]>]>
    - runlater <script.name> path:ReclaimOutpost_Helper id:<[kingdom]>_<[outpost]>_outpost_reclaim def.warID:<[warID]> def.kingdom:<[kingdom]> def.outpost:<[outpost]> delay:<[occupationDelay]>

    - run ChunkOccupationVisualizer def.squadLeader:<[kingdom].proc[GetSquadLeader].context[<[squadname]>]> def.occupationDuration:<[occupationDelay]>

    - determine <[occupationDelay]>

    ReclaimOutpost_Helper:
    - foreach <server.flag[kingdoms.wars.<[warID]>.lostOutposts.<[kingdom]>]> as:outposts key:occupier:
        - if <[outposts].contains[<[outpost]>]>:
            - flag server kingdoms.wars.<[warID]>.lostOutposts.<[kingdom]>.<[occupier]>:<-:<[outpost]>

    - flag server kingdoms.wars.<[warID]>.reclaimingOutposts.<[outpost]>:!
    - flag <[squadLeader]> datahold.war.occupying:!

    - foreach <util.runlater_ids.find_all_matches[*_*_<[outpost]>_outpost_reclaim]> as:runLater:
        - adjust system cancel_runlater:<[runLater]>


CancelOutpostReclamation:
    type: task
    definitions: kingdom[ElementTag(String)]|targetKingdom[ElementTag(String)]|squadName[ElementTag(String)]|outpost[ElementTag(String)]
    description:
    - Cancels the occupation of the provided outpost by the provided kingdom's given squad.
    - ---
    - → ?[Void]

    script:
    ## Cancels the occupation of the provided outpost by the provided kingdom given squad
    ##
    ## kingdom       : [ElementTag<String>]
    ## targetKingdom : [ElementTag<String>]
    ## outpost       : [ElementTag<String>]
    ## squadName     : [ElementTag<String>]
    ##
    ## >>> ?[Void]

    - if !<proc[GetAllOutpostsByKingdom].filter_tag[<[filter_value].contains[<[outpost]>]>].size> == 0:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot cancel outpost reclamation. There is no outpost by the name: <[outpost].color[red]>.]>
        - determine null

    - define warID <[kingdom].proc[GetKingdomWars].filter_tag[<[filter_value].proc[GetWarRetaliators].contains[<[targetKingdom]>]>].get[1]>

    - if !<[warID].is_truthy>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot reclaim outpost. The provided warID: <[warID].color[red]> does not belong to any active war.]>
        - determine null

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]> || !<proc[ValidateKingdomCode].context[<[targetKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot cancel outpost reclamation. Either one of the kingdom codes provided: <[kingdom]> & <[targetKingdom]> are invalid.]>
        - determine null

    - adjust system cancel_runlater:<[kingdom]>_<[targetKingdom]>_<[outpost]>_outpost_reclaim
    - flag server kingdoms.wars.<[warID]>.reclaimingOutposts.<[outpost]>:!
    - flag <[kingdom].proc[GetSquadLeader].context[<[squadName]>]> datahold.war.occupying:!


MakeTheSquigglesGoAway:
    type: task
    enabled: false
    debug: false
    script:
    - inject OccupyOutpost path:OccupyOutpost_Helper
    - inject ReclaimOutpost path:ReclaimOutpost_Helper
    - inject OccupyChunk path:OccupyChunk_Helper
