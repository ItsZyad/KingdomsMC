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

    - determine <[warID].proc[GetWarRetaliators].include[<[warID].proc[GetWarRetaliators]>]>


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

    - determine <server.flag[kingdom.wars.<[warID]>.start]>


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
    - flag server kingdoms.<[kingdom]>.war.justifications:<-:<[targetKingdom]>

    - definemap warMap:
        belligerents: <list[<[kingdom]>]>
        retaliators: <list[<[targetKingdom]>]>
        start: <util.time_now>
        # War progress is a -100 -> 100 scale where 100 means that the war is won in favor of the
        # belligerent and -100 in favor of the retaliator.
        progress: 0
        claimType: <[claimType]>
        claimSize: <[claimSize]>

    - if <[claimName].exists>:
        - define warMap.claimName:<[claimName]>

    - flag server kingdoms.wars.<[warID]>:<[warMap]>
