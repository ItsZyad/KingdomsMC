##
## This file contains all of the scripts related to the assignment of squad orders and the handling
## of squad behavior while these orders are active.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jul 2023
## @Script Ver: v1.1
##
## ------------------------------------------END HEADER-------------------------------------------

## Target Assigners
#################################################

SquadAttackAllOrder:
    type: task
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Causes the given squad to attack all other soliders regardless of kingdom.
    - ---
    - → [Void]

    script:
    ## Causes the given squad to attack all other soliders regardless of kingdom.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [Void]

    # Note: make a configurable (in-game) which allows players to adjust (on the fly) whether the
    #       squad leader should join battle with their squad?

    - foreach <proc[GetSquadNPCs].context[<[kingdom]>|<[squadName]>].include[<proc[GetSquadLeader].context[<[kingdom]>|<[squadName]>]>]> as:soldier:
        - execute as_server "sentinel addtarget denizen_proc:SquadAttackAll_Procedure:<[soldier]> --id <[soldier].id>" silent


SquadAttackSquadOrder:
    type: task
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]|enemyKingdom[ElementTag(String)]|enemySquadName[ElementTag(String)]
    description:
    - Causes the given squad to attack an enemy squad only. Will cancel if the 'enemy' squad provided is of the same kingdom.
    - ---
    - → [Void]

    script:
    ## Causes the given squad to attack an enemy squad only. Will cancel if the 'enemy' squad
    ## provided is of the same kingdom.
    ##
    ## kingdom        : [ElementTag<String>]
    ## squadName      : [ElementTag<String>]
    ## enemyKingdom   : [ElementTag<String>]
    ## enemySquadName : [ElementTag<String>]
    ##
    ## >>> [Void]

    - if !<[kingdom].proc[IsAtWarWithKingdom].context[<[enemyKingdom]>]>:
        - narrate format:callout "You are not at war with this kingdom!"
        - stop

    - define fullNPCList <proc[GetSquadNPCs].context[<[kingdom]>|<[squadName]>].include[<proc[GetSquadLeader].context[<[kingdom]>|<[squadName]>]>]>
    - define enemySquadSentinelName <proc[GetSquadSentinelName].context[<[kingdom]>|<[squadName]>]>

    - foreach <[fullNPCList]> as:soldier:
        - execute as_server "sentinel addtarget squad:<[enemySquadSentinelName]> --id <[soldier].id>" silent


SquadAttackMonstersOrder:
    type: task
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Orders the given squad to attack monsters and hostile mobs whenever they can.
    - ---
    - → [Void]

    script:
    ## Orders the given squad to attack monsters and hostile mobs whenever they can.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [Void]

    - define soldierList <proc[GetSquadNPCs].context[<[kingdom]>|<[squadName]>].include[<proc[GetSquadLeader].context[<[kingdom]>|<[squadName]>]>]>

    - foreach <[soldierList]> as:soldier:
        - execute as_server "sentinel addtarget denizen_proc:SquadAttackMonsters_Procedure:<[soldier]> --id <[soldier].id>" silent


SquadRemoveAllOrders:
    type: task
    definitions: kingdom[ElementTag(String)]|squadName[ElementTag(String)]
    description:
    - Cancels a given squads active orders and causes all of its soldiers to forgive their targets.
    - ---
    - → [Void]

    script:
    ## Cancels a given squads active orders and causes all of its soldiers to forgive their targets.
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [Void]

    - foreach <proc[GetAllSquadNPCs].context[<[kingdom]>|<[squadName]>]> as:soldier:
        - define proceduralTargets <[soldier].sentinel.targets.filter_tag[<[filter_value].starts_with[denizen_proc]>]>
        - define squadTargets <[soldier].sentinel.targets.filter_tag[<[filter_value].starts_with[squad]>]>

        - foreach <[proceduralTargets]> as:proc:
            - execute as_server "sentinel removetarget <[proc]> --id <[soldier].id>" silent

        - foreach <[squadTargets]> as:squad:
            - execute as_server "sentinel removetarget <[squad]> --id <[soldier].id> " silent

        - execute as_server "sentinel forgive --id <[soldier].id>" silent

## Target Procs
#################################################

SquadAttackAll_Procedure:
    type: procedure
    debug: false
    definitions: entity[EntityTag]|context[NPCTag]
    description:
    - Will return true if the provided entity is a soldier in another kingdom's army.
    - ---
    - → [Void]

    script:
    ## Will return true if the provided entity is a soldier in another kingdom's army.
    ##
    ## entity  : [EntityTag]
    ## context : [NPCTag]
    ##
    ## >>> [Void]

    - ratelimit <queue> 25t

    - if <[context].as[npc].is_navigating>:
        - stop

    - define enemyKingdoms <proc[GetKingdomList].exclude[<[context].as[npc].flag[soldier.kingdom]>]>

    - if !<[entity].has_flag[soldier]>:
        - determine passively false
        - execute as_server "sentinel forgive --id <[context].as[npc].id>" silent
        - stop

    - if !<[context].flag[soldier.kingdom].proc[IsAtWarWithKingdom].context[<[entity].flag[soldier.kingdom]>]>:
        - determine passively false
        - execute as_server "sentinel forgive --id <[context].as[npc].id>" silent

    - else if <[entity].flag[soldier.kingdom].is_in[<[enemyKingdoms]>]>:
        - determine true

    - else:
        - determine passively false
        - execute as_server "sentinel forgive --id <[context].as[npc].id>" silent


SquadAttackMonsters_Procedure:
    type: procedure
    debug: false
    definitions: entity[EntityTag]|context[NPCTag]
    description:
    - Will return true if the provided entity is a monster.
    - ---
    - → [Void]

    script:
    ## Will return true if the provided entity is a monster.
    ##
    ## entity  : [EntityTag]
    ## context : [NPCTag]
    ##
    ## >>> [Void]

    - ratelimit <queue> 25t

    - if <[context].as[npc].is_navigating>:
        - stop

    - if <[entity].is_monster>:
        - determine true

    - determine passively false
    - execute as_server "sentinel forgive --id <[context].as[npc].id>" silent

## Death Handlers
#################################################

SoldierCombat_Handler:
    type: world
    debug: false
    events:
        on npc dies:
        - if !(<context.entity.traits.contains[sentinel]> && <context.entity.has_flag[soldier]>):
            - stop

        - define soldier <context.entity>
        - define kingdom <[soldier].flag[soldier.kingdom]>
        - define squadName <[soldier].flag[soldier.squad]>
        - define SMLocation <proc[GetSquadSMLocation].context[<[kingdom]>|<[squadName]>]>

        - flag server kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.npcList:<-:<[soldier]>
        - define npcList <proc[GetSquadNPCs].context[<[kingdom]>|<[squadName]>]>

        - if !<[soldier].flag[soldier.isSquadLeader].if_null[false]>:
            - stop

        - flag <[soldier]> datahold.armies.particles:!

        - run ChunkOccupationVisualizer path:CancelVisualization def.squadLeader:<[soldier]>
        - run CancelChunkOccupation def.kingdom:<[kingdom]> def.targetKingdom:<[soldier].flag[datahold.war.occupying.target]> def.squadLeader:<[soldier]> def.chunk:<[soldier].flag[datahold.war.occupying.chunk]> if:<[soldier].has_flag[datahold.war.occupying.chunk]>
        - run CancelOutpostOccupation def.kingdom:<[kingdom]> def.squadName:<[squadName]> def.outpost:<[soldier].flag[datahold.war.occupying.outpost]> if:<[soldier].has_flag[datahold.war.occupying.outpost]>
        - run CancelOutpostReclamation def.kingdom:<[kingdom]> def.targetKingdom:<[soldier].flag[datahold.war.occupying.target]> def.squadName:<[squadName]> def.outpost:<[soldier].flag[datahold.war.occupying.outpost]> if:<[soldier].has_flag[datahold.war.occupying.outpost]>
        - run CancelChunkReclamation def.kingdom:<[kingdom]> def.targetKingdom:<[soldier].flag[datahold.war.occupying.target]> def.squadName:<[squadName]> def.chunk:<[soldier].flag[datahold.war.occupying.chunk]> if:<[soldier].has_flag[datahold.war.occupying.chunk]>

        - if <context.damager.has_flag[kingdom]>:
            - run AddWarDead def.affectedKingdom:<[kingdom]> def.inflictingKingdom:<context.damager.flag[kingdom]> def.amount:1

        # Last soldier is killed - delete squad
        - if <[npcList].size> == 0:
            - run DeleteSquad def.kingdom:<[kingdom]> def.squadName:<[squadName]>

        # Promote a soldier to become squad leader
        - else:
            - define firstSoldier <[npcList].first>
            - run SetSquadLeader def.kingdom:<[kingdom]> def.npc:<[firstSoldier]> def.squadName:<[squadName]>

            - rename "&4Squad Leader" t:<[firstSoldier].as[npc]>
            - assignment set to:<[firstSoldier]> script:SoldierManager_Assignment
            - run SoldierParticleGenerator def.npcList:<[npcList]> def.squadLeader:<[firstSoldier]> def.orderType:attackAll
