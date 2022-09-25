Farmer:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true
    interact scripts:
    - Farmer_I

Farmer_I:
    type: interact
    steps:
        1:
            click trigger:
                script:
                    - if <player.has_flag[NPCUpgrade]>:
                        - if <npc.has_flag[Farmer]>:
                            - if <npc.flag[Farmer].is[LESS].than[3]>:
                                - if <player.money.is[OR_MORE].than[<el@3500.mul[<npc.flag[Farmer]>]>]>:
                                    - flag npc Farmer:++
                                    - take money quantity:<el@3500.mul[<npc.flag[Farmer]>]>
                                    - flag player NPCUpgrade:!
                                    - narrate format:callout "Farmer Upgraded to level: <npc.flag[Farmer]>"
                                    - execute as_server "npc rename Farmer:: Lvl <npc.flag[Farmer]>"
                                - else:
                                    - narrate format:callout "Upgraded to maximum level"

                            - else:
                                - narrate format:callout "You do not have sufficient funds for this upgrade. $<el@3500.mul[<npc.flag[Farmer]>]> Needed"
                                - flag player MPCUpgrade:!

                        - else:
                            - narrate format:callout "This is not a valid kingdom NPC"

                    - else if <player.has_flag[NPCMove]>:
                        - flag player NPCMove:<npc>
                        - narrate format:callout "Move to the desired location and type the command again"

                    - else:
                        - inventory open d:<npc.inventory>

FarmerGenerationHandler:
    type: world
    debug: false
    events:
        on system time secondly every:120:
        - foreach <server.flag[FarmerList]>:
            - if <[value].inventory.empty_slots.is[MORE].than[0]>:
                - give wheat to:<[value].inventory> quantity:<[value].flag[Farmer]>
                - give carrot to:<[value].inventory> quantity:<[value].flag[Farmer]>
                - give potato to:<[value].inventory> quantity:<[value].flag[Farmer]>
                - give beetroot to:<[value].inventory> quantity:<[value].flag[Farmer]>

                - if <[value].flag[Farmer].is[OR_MORE].than[2]>:
                    - give sugar_cane to:<[value].inventory> quantity:<[value].flag[Farmer]>
                    - give melon to:<[value].inventory> quantity:2
                    - give pumpkin to:<[value].inventory> quantity:<[value].flag[Farmer]>

MinerLevelViewer:
    type: task
    script:
        - foreach <server.flag[FarmerList]>:
            - execute as_server "npc select <[value].id>"
            - execute as_server "npc rename Farmer:: Lvl <[value].flag[Farmer]>"
        - foreach <server.flag[MinerList]>:
            - execute as_server "npc select <[value].id>"
            - execute as_server "npc rename Miner:: Lvl <[value].flag[Miner]>"
