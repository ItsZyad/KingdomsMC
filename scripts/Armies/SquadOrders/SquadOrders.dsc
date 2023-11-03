##
## This file contains all of the scripts related to the assignment of squad orders and the handling
## of squad behavior while these orders are active.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jul 2023
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

## Target Assigners
#################################################

SquadAttackAllOrder:
    type: task
    definitions: kingdom|squadName
    script:
    ## Causes the given squad to attack all other soliders regardless of kingdom
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [Void]

    - run GetSquadInfo def.kingdom:<[kingdom]> def.squadName:<[squadName]> save:squadInfo
    - define squadInfo <entry[squadInfo].created_queue.determination.get[1]>

    # Note: make a configurable (in-game) which allows players to adjust (on the fly) whether the
    #       squad leader should join battle with their squad?

    - foreach <[squadInfo].get[npcList].include[<[squadInfo].get[squadLeader]>]> as:soldier:
        - execute as_server "sentinel addtarget denizen_proc:SquadAttackAll_Procedure:<[soldier]> --id <[soldier].id>" silent


SquadAttackSquadOrder:
    type: task
    definitions: kingdom|squadName|enemyKingdom|enemySquadName
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

    - run GetSquadInfo def.kingdom:<[kingdom]> def.squadName:<[squadName]> save:squadInfo
    - define squadInfo <entry[squadInfo].created_queue.determination.get[1]>
    - define fullNPCList <[squadInfo].get[npcList].include[<[squadInfo].get[squadLeader]>]>

    - run GetSquadInfo def.kingdom:<[enemyKingdom]> def.squadName:<[enemySquadName]> save:enemySquadInfo
    - define enemySquadInfo <entry[enemySquadInfo].created_queue.determination.get[1]>
    - define enemySquadSentinelName <[enemySquadInfo].get[sentinelSquad]>

    - foreach <[fullNPCList]> as:soldier:
        - execute as_server "sentinel addtarget squad:<[enemySquadSentinelName]> --id <[soldier].id>" silent


SquadRemoveAllOrders:
    type: task
    definitions: kingdom|squadName
    script:
    ## Cancels a given squads active orders and causes all of its soldiers to forgive their targets
    ##
    ## kingdom   : [ElementTag<String>]
    ## squadName : [ElementTag<String>]
    ##
    ## >>> [Void]

    - run GetSquadInfo def.kingdom:<[kingdom]> def.squadName:<[squadName]> save:squadInfo
    - define squadInfo <entry[squadInfo].created_queue.determination.get[1]>

    - foreach <[squadInfo].get[npcList].include[<[squadInfo].get[squadLeader]>]> as:soldier:
        - define proceduralTargets <[soldier].sentinel.targets.filter_tag[<[filter_value].starts_with[denizen_proc]>]>

        - foreach <[proceduralTargets]> as:proc:
            - execute as_server "sentinel removetarget <[proc]> --id <[soldier].id>" silent

        - execute as_server "sentinel forgive --id <[soldier].id>" silent

## Target Procs
#################################################

SquadAttackAll_Procedure:
    type: procedure
    debug: false
    definitions: entity|context
    script:
    - ratelimit <queue> 25t

    - if <[context].as[npc].is_navigating>:
        - stop

    - define enemyKingdoms <proc[GetKingdomList].exclude[<[context].as[npc].flag[soldier.kingdom]>]>

    - if !<[entity].has_flag[soldier]>:
        - determine passively false
        - execute as_server "sentinel forgive --id <[context].as[npc].id>" silent

    - else if <[entity].flag[soldier.kingdom].is_in[<[enemyKingdoms]>]>:
        - determine true

    - else:
        - determine passively false
        - execute as_server "sentinel forgive --id <[context].as[npc].id>" silent

## Death Handlers
#################################################

SoldierCombat_Handler:
    type: world
    events:
        on npc dies:
        - if <context.entity.traits.contains[sentinel]> && <context.entity.has_flag[soldier]>:
            - define soldier <context.entity>
            - define kingdom <[soldier].flag[soldier.kingdom]>
            - define squadName <[soldier].flag[soldier.squad]>

            - run GetSquadSMLocation def.squadName:<[squadName]> def.kingdom:<[kingdom]> save:SMLocation
            - define SMLocation <entry[SMLocation].created_queue.determination.get[1]>

            - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.npcList:<-:<[soldier]>
            - define npcList <proc[GetSquadNPCs].context[<[kingdom]>|<[squadName]>]>

            - if <[soldier].flag[soldier.isSquadLeader].if_null[false]>:
                - flag <[soldier]> datahold.armies.particles:!

                # Last soldier is killed - delete squad
                - if <[npcList].size> == 0:
                    - run DeleteSquad def.SMLocation:<[SMLocation]> def.kingdom:<[kingdom]> def.squadName:<[squadName]>

                # Promote a soldier to become squad leader
                - else:
                    - define firstSoldier <[npcList].first>
                    - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.squadLeader:<[firstSoldier]>
                    - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.npcList:<-:<[firstSoldier]>
                    - flag <[firstSoldier]> soldier.isSquadLeader:true

                    - rename "&4Squad Leader" t:<[firstSoldier].as[npc]>
                    - assignment set to:<[firstSoldier]> script:SoldierManager_Assignment
                    - run SoldierParticleGenerator def.npcList:<[npcList]> def.squadLeader:<[firstSoldier]> def.orderType:attackAll

            - run WriteArmyDataToKingdom def.kingdom:<[kingdom]> def.SMLocation:<[SMLocation]>
