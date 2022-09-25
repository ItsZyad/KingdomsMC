SoldierSpawner:
    type: command
    name: soldier
    usage: /soldier
    description: Spawns a NPC of type 'soldier'
    permission: kingdom.soldier.spawn
    script:
    - define testArr <map.with[arr].as[<list[a|b|c|d|e|f|g|h|i|j|k|l|m|n]>]>
    - foreach <proc[Paginate].context[<[testArr]>|6|2]>:
        - narrate <[value]>

SoldierAssign:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
    interact scripts:
    - SoldierScript

SoldierScript:
    type: interact
    steps:
        1:
            click trigger:
                script:
                - narrate format:callout thing