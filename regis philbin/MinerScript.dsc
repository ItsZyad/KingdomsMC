NPC_Command:
    type: command
    usage: /npccreate
    name: npccreate
    description: "Creates the mentioned kingdom NPC"
    permission: kingdoms.npc.create
    script:
    - ~yaml load:npclist.yml id:npclist

    - if <context.raw_args> == Miner:
        - if <player.money.is[OR_MORE].than[7000]>:
            - flag server NPCCreating

            - take money quantity:7000
            - create player "Miner:: Lvl 1" <player.location>

            - flag server NPCCreating:!

            - flag <server.flag[LatestKingdomNPC]> Miner:1
            - yaml id:npclist set MinerList:->:<server.flag[LatestKingdomNPC]>
            - yaml id:npclist set <player.flag[kingdom]>.Miners:->:<server.flag[LatestKingdomNPC]>
            - yaml id:npclist set <player.flag[kingdom]>.MinerAmount:++
            - yaml id:npclist set <player.flag[kingdom]>.NPCAmount:++

            - yaml savefile:npclist.yml id:npclist

            - flag server LatestKingdom:!

            - flag server MinerList:->:<server.flag[LatestKingdomNPC]>
            - assignment set script:Miner to:<server.flag[LatestKingdomNPC]>
        - else:
            - narrate format:callout "You do not have sufficient funds to hire a Miner. 7000$ Needed"

    - else if <context.raw_args> == Farmer:
        - if <player.money.is[OR_MORE].than[6000]>:
            - flag server NPCCreating

            - take money quantity:6000
            - create player "Farmer:: Lvl 1" <player.location>

            - flag server NPCCreating:!

            - flag <server.flag[LatestKingdomNPC]> Farmer:1
            - yaml id:npclist set FarmerList:->:<server.flag[LatestKingdomNPC]>
            - yaml id:npclist set <player.flag[kingdom]>.Farmers:->:<server.flag[LatestKingdomNPC]>
            - yaml id:npclist set <player.flag[kingdom]>.FarmerAmount:++
            - yaml id:npclist set <player.flag[kingdom]>.NPCAmount:++

            - yaml savefile:npclist.yml id:npclist

            - flag server FarmerList:->:<server.flag[LatestKingdomNPC]>
            - assignment set script:Farmer to:<server.flag[LatestKingdomNPC]>
        - else:
            - narrate format:callout "You do not have the sufficient funds to hire a Farmer. 6000$ Needed"

    - else:
        - narrate format:callout "Unrecognized Parameter: <context.raw_args>"

    - yaml unload id:npclist

NPCUpgrade_Command:
    type: command
    usage: /npcupgrade
    name: npcupgrade
    description: "Upgrades a kingdom NPC when it is clicked on"
    permission: kingdoms.npc.upgrade
    script:
    - flag player NPCUpgrade
    - narrate format:callout "Please click the kingdom NPC you would like to upgrade (do '/npcupgrade cancel' to exit)"

    - if <player.has_flag[NPCUpgrade]>:
        - if <context.raw_args> == cancel:
            - narrate format:callout "Exited NPC Upgrade Mode"
            - flag player NPCUpgrade:!

NPCMove_Command:
    type: command
    usage: /npcmove
    name: npcmove
    description: "Moves a kingdom NPC"
    permission: kingdoms.npc.move
    script:
    - if <player.has_flag[NPCMove]>:
        - teleport <player.flag[NPCMove]> <player.location>
        - flag player NPCMove:!
    - else:
        - flag player NPCMove
        - narrate format:callout "Please click the kingdom NPC you would like to move"

NPCDel_Command:
    type: command
    usage: /npcdel
    name: npcdel
    description: "Deletes a kingdom NPC"
    permission: kingdoms.npc.delete
    script:
    - flag player NPCDel
    - narrate format:callout "Please click the kingdom NPC you would like to delete"

Miner:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true
    interact scripts:
    - Miner_I

Miner_I:
    type: interact
    steps:
        1:
            click trigger:
                script:
                    - if <player.has_flag[NPCUpgrade]>:
                        - if <npc.has_flag[Miner]>:
                            - if <npc.flag[Miner].is[LESS].than[3]>:
                                - if <player.money.is[OR_MORE].than[<el@4000.mul[<npc.flag[Miner]>]>]>:
                                    - flag npc Miner:++
                                    - take money quantity:<el@4000.mul[<npc.flag[Miner]>]>
                                    - flag player NPCUpgrade:!
                                    - narrate format:callout "Miner Upgraded to level: <npc.flag[Miner]>"
                                    - execute as_server "npc rename Miner:: Lvl <npc.flag[Miner]>"
                                - else:
                                    - narrate format:callout "Upgraded to maximum level"

                            - else:
                                - narrate format:callout "You do not have sufficient funds for this upgrade"
                                - flag player MPCUpgrade:!

                        - else:
                            - narrate format:callout "This is not a valid kingdom NPC"

                    - else if <player.has_flag[NPCMove]>:
                        - if <npc.has_flag[Miner]> || <npc.has_flag[Farmer]>:
                            - flag player NPCMove:<npc>
                            - narrate format:callout "Move to the desired location and type the command again"

                    - else if <player.has_flag[NPCDel]>:
                        - if <npc.has_flag[Miner]> || <npc.has_flag[Farmer]>:
                            - remove <player.target>
                            - flag player NPCDel:!

                    - else if <player.flag[AdminTools]> == ID:
                        - narrate format:admincallout <npc.id>

                    - else:
                        - inventory open d:<npc.inventory>

MinerGenerationHandler:
    type: world
    debug: false
    events:
        on system time secondly every:120:
        - foreach <server.flag[MinerList]>:
            - if <[value].inventory.empty_slots.is[MORE].than[0]>:
                - give iron_ingot to:<[value].inventory> quantity:<[value].flag[Miner]>
                - give cobblestone to:<[value].inventory> quantity:<[value].flag[Miner].mul[2]>

                - if <[value].flag[Miner].is[OR_MORE].than[2]>:
                    - give redstone to:<[value].inventory> quantity:<[value].flag[Miner].sub[1]>
                    - give coal to:<[value].inventory> quantity:<[value].flag[Miner].sub[1]>

        on system time secondly every:160:
        - foreach <server.flag[MinerList]>:
            - if <[value].inventory.empty_slots.is[MORE].than[0]>:
                - if <[value].flag[Miner].is[OR_MORE].than[2]>:
                    - give lapis_lazuli to:<[value].inventory> quantity:<[value].flag[Miner].sub[1]>
                    - give gold_ingot to:<[value].inventory> quantity:<[value].flag[Miner].sub[1]>

                    - if <[value].flag[Miner].is[OR_MORE].than[3]>:
                        - give diamond to:<[value].inventory> quantity:1

        on npc spawns:
        - narrate <server.flag[NPCCreating]>

        - if <server.has_flag[NPCCreating]>:
            - flag server LatestKingdomNPC:<npc>