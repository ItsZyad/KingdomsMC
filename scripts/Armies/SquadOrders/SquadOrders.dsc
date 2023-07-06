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
        - execute as_server "sentinel forgive --id <[soldier].id>" silent

## Target Procs
#################################################

SquadAttackAll_Procedure:
    type: procedure
    definitions: entity|context
    script:
    - ratelimit <queue> 1s

    - if !<[entity].has_flag[soldier]>:
        - determine false

    - define soldier <[context]>
    - define friendlyKingdom <[context].flag[soldier.kingdom]>
    - define enemyKingdoms <proc[GetKingdomList].exclude[<[friendlyKingdom]>]>

    - if <[entity].flag[soldier.kingdom].is_in[<[enemyKingdoms]>]>:
        - determine true
