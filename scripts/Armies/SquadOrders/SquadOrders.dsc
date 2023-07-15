## Target Assigners
#################################################

SquadAttackAllOrder:
    type: task
    definitions: kingdom|squadName
    script:
    - run GetSquadInfo def.kingdom:<[kingdom]> def.squadName:<[squadName]> save:squadInfo
    - define squadInfo <entry[squadInfo].created_queue.determination.get[1]>

    # Note: make a configurable (in-game) which allows players to adjust (on the fly) whether the
    #       squad leader should join battle with their squad?

    - foreach <[squadInfo].get[npcList].include[<[squadInfo].get[squadLeader]>]> as:soldier:
        - execute as_server "sentinel addtarget denizen_proc:SquadAttackAll_Procedure:<[soldier]> --id <[soldier].id>" silent


SquadRemoveAllOrders:
    type: task
    definitions: kingdom|squadName
    script:
    - run GetSquadInfo def.kingdom:<[kingdom]> def.squadName:<[squadName]> save:squadInfo
    - define squadInfo <entry[squadInfo].created_queue.determination.get[1]>

    - foreach <[squadInfo].get[npcList].include[<[squadInfo].get[squadLeader]>]> as:soldier:
        - define proceduralTargets <[soldier].sentinel.targets.filter_tag[<[filter_value].starts_with[denizen_proc]>]>

        - foreach <[proceduralTargets]> as:proc:
            - execute as_server "sentinel removetarget <[proc]> --id:<[soldier].id>"

        - execute as_server "sentinel forgive --id <[soldier].id>" silent

## Target Procs
#################################################

SquadAttackAll_Procedure:
    type: procedure
    debug: false
    definitions: entity|context
    script:
    - ratelimit <queue> 1s
    - define soldier <[context].as[npc]>

    - if !<[entity].has_flag[soldier]>:
        - execute as_server "sentinel forgive --id <[soldier].id>"
        - determine false

    - define friendlyKingdom <[soldier].flag[soldier.kingdom]>
    - define enemyKingdoms <proc[GetKingdomList].exclude[<[friendlyKingdom]>]>

    - if <[entity].flag[soldier.kingdom].is_in[<[enemyKingdoms]>]>:
        - determine true

    - execute as_server "sentinel forgive --id <[soldier].id>"
    - determine false
