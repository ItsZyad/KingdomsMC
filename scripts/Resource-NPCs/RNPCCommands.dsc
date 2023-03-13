##
## * All the entry point commands and functions for
## * the rource NPCs pertaining to each specific kingdom
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2021
## @Script Ver: v0.6
## @Clean Code Classification: 4
##
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

RNPCSkins:
    type: data
    farmer: ewogICJ0aW1lc3RhbXAiIDogMTYwOTcwMzAyNzg2OSwKICAicHJvZmlsZUlkIiA6ICIyYzEwNjRmY2Q5MTc0MjgyODRlM2JmN2ZhYTdlM2UxYSIsCiAgInByb2ZpbGVOYW1lIiA6ICJOYWVtZSIsCiAgInNpZ25hdHVyZVJlcXVpcmVkIiA6IHRydWUsCiAgInRleHR1cmVzIiA6IHsKICAgICJTS0lOIiA6IHsKICAgICAgInVybCIgOiAiaHR0cDovL3RleHR1cmVzLm1pbmVjcmFmdC5uZXQvdGV4dHVyZS83YThhYjIyNjdhZTQ0M2U4M2IwNWUzYThkNjdiOGI3NjBhZGZhYWQzMzVjOTA0NzMzOGMwZTE3NzRhNjVjMzcyIgogICAgfQogIH0KfQ==;W1SJyWT8h8cP0u/fREJNdemGC2PokpNeozSdhk/9SvR6Y0Yo2aVz/8kA1xnvqdil4KS9AH6f5lY9+tC/IWzb7dkiOEIfr2QV5Cc6vgKVxr+R+vRjxvR2MZNME2NH/wpQ0/AooDuS2OW2VgmwSwpwwy3V3OTfR9Gy8RAC7KI5uDKBdfX31cyYAWpFGwux6bPi6drHixpY3MVG2M+XYLQUijEhkUuOQ8rH5zfJhCt3AmE8onIu1/LsdsO3u1NCsC/bfs5A6fYEoRX/xV8lfRx6pDMWf4xessuze7ubFCVDxKcUPmWQbodbrIQAjBYorykYr0GHkt6atZs8RcRwh8ulwSA7Pkz41BQnv9UQRfMQmUUWR7HS08CnIyJFakQhdVhB+DI7evT1eJTbtphCbxUGG/QCp7EzW/5HGoxVmaZTWHACF0GKfSR5mIX7L3Wj4KdEQUuFFOogEUCgWYzRkbnPN0S+sbJMyukIlZ8CUnUUzrhqmoUneHOHZtjGSLBtaQ3eth5WeuXllQSAz0ncq7FnPhdLSDHGya8zSbn8ti+kZ72dBg7TeCxSCTPLUN1itfTfDh/hpSsBbnOO1dLA97FLtcE76mYHN1RKyU2lLZaX11tomdP6QGEFRlLfMAYNIxrj1cOBaAX2XuKZLe27u0GGlqeOvfqPNLfsQ4NNEh4zoDs=

RNPCSpawn_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Spawn a Resource NPC
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [SpawnMiner_Item] [] [SpawnFarmer_Item] [] [SpawnLogger_Item] [] [SpawnFisher_Item] []
    - [] [] [] [] [SpawnGuard_Item] [] [] [] []
    - [] [] [] [] [barrier] [] [] [] []

SpawnMiner_Item:
    type: item
    material: iron_pickaxe
    display name: Spawn a Miner
    lore:
    - RNPC Price: <red>$<proc[ShowRNPCPrices].context[miners]>
    flags:
        spawnType: miners
    mechanisms:
        hides: ALL

SpawnLogger_Item:
    type: item
    material: iron_axe
    display name: Spawn a Logger
    lore:
    - RNPC Price: <red>$<proc[ShowRNPCPrices].context[loggers]>
    flags:
        spawnType: loggers
    mechanisms:
        hides: ALL

SpawnFarmer_Item:
    type: item
    material: iron_hoe
    display name: Spawn a Farmer
    lore:
    - RNPC Price: <red>$<proc[ShowRNPCPrices].context[farmers]>
    flags:
        spawnType: farmers
    mechanisms:
        hides: ALL

SpawnFisher_Item:
    type: item
    material: fishing_rod
    display name: <gray>ITEM UNVAILABLE
    lore:
    - This RNPC is still in development.
    flags:
        spawnType: fishermen
    mechanisms:
        hides: ALL

SpawnGuard_Item:
    type: item
    material: chainmail_helmet
    display name: Spawn a Castle Guard
    lore:
    - RNPC Price: <red>$<proc[ShowRNPCPrices].context[guard]>
    flags:
        spawnType: guard
    mechanisms:
        hides: ALL

RNPCBasePrices:
    type: data
    loggers: 6000
    miners: 8000
    farmers: 5500
    fishermen: 4500
    guard: 10000

ShowRNPCPrices:
    type: procedure
    definitions: spawnType
    script:
    - define basePrice <script[RNPCBasePrices].data_key[<[spawnType]>]>

    - yaml load:kingdoms.yml id:kingdoms

    - define k 6.31
    - define invPrestige <yaml[kingdoms].read[<player.flag[kingdom]>.prestige].sub[100].abs>
    - define gradient 0.1543221

    # Prestige modifier for RNPC Spawning:
    # y = 4log(invPrestige + k)^-1 - gradient * k

    - define prestigeModifier <element[4].mul[<[invPrestige].add[<[k]>].log[10].power[-1]>].sub[<[gradient].mul[<[k]>]>].round_to_precision[0.01]>
    - determine <[prestigeModifier].mul[<[basePrice]>]>

    - yaml id:kingdoms unload

WriteRNPCData:
    type: task
    definitions: createdNPC|spawnType
    script:
    - define kingdom <player.flag[kingdom]>
    - yaml load:npclist.yml id:npcs
    - yaml load:kingdoms.yml id:kingdoms

    # Write to the kingdom's NPC lists and increment the total
    # npcs counter in the npclist.yml

    - yaml id:npcs set <[kingdom]>.NPCAmount:+:1
    - yaml id:npcs set <[kingdom]>.AllNPCs:->:<[createdNPC]>
    - yaml id:npcs set <[kingdom]>.<[spawnType]>:->:<[createdNPC]>
    - yaml id:kingdoms set <[kingdom]>.npc_total:++

    # Flag the npc with its RNPC type

    - flag <[createdNPC]> RNPC:<context.item.flag[spawnType]>
    - flag <[createdNPC]> Level:1
    - flag <[createdNPC]> outputMod:0
    - flag <[createdNPC]> kingdom:<player.flag[kingdom]>

    # Add the npc's id and it's type to the universal server list
    # of RNPCs

    - flag server RNPCS:->:<list[<[createdNPC].id>|<[spawnType]>]>

    - assignment set script:RNPCHandler to:<[createdNPC]>

    - yaml id:kingdoms savefile:kingdoms.yml
    - yaml id:npcs savefile:npclist.yml
    - yaml id:kingdoms unload
    - yaml id:npcs unload

CalculateRNPCPrice:
    type: task
    definitions: truePrice|player
    script:
    - yaml load:kingdoms.yml id:kingdoms
    - yaml id:kingdoms set <[player].flag[kingdom]>.balance:-:<[truePrice]>
    - yaml id:kingdoms set <[player].flag[kingdom]>.npcs.npc_total:++
    - yaml id:kingdoms savefile:kingdoms.yml
    - yaml id:kingdoms unload

    - run SidebarLoader def.target:<server.flag[<[player].flag[kingdom]>.members].include[<server.online_ops>]>

RNPCWindow_Handler:
    type: world
    events:

        on player clicks Spawn* in RNPCSpawn_Window:
        - define basePrice <script[RNPCBasePrices].data_key[<context.item.flag[spawnType]>]>

        - yaml load:kingdoms.yml id:kingdoms

        - define k 6.31
        - define invPrestige <yaml[kingdoms].read[<player.flag[kingdom]>.prestige].sub[100].abs>
        - define gradient 0.1543221

        # Prestige modifier for RNPC Spawning:
        # y = 4log(invPrestige + k)^-1 - gradient * k

        - define prestigeModifier <element[4].mul[<[invPrestige].add[<[k]>].log[10].power[-1]>].sub[<[gradient].mul[<[k]>]>].round_to_precision[0.01]>
        - define truePrice <[prestigeModifier].mul[<[basePrice]>]>

        #- narrate format:debug <[prestigeModifier]>

        - foreach <util.notes[cuboids]>:
            - if <[value].contains[<player.location>]>:
                - foreach stop
                - inventory close

                - narrate format:callout "You cannot spawn an RNPC in the AOE of another RNPC!"
                - determine cancelled

        - if <yaml[kingdoms].read[<player.flag[kingdom]>.npcs.npc_cap].is[OR_MORE].than[<yaml[kingdoms].read[<player.flag[kingdom]>.npcs.npc_total]>]>:

            # If the kingdom bank has enough money to buy an NPC with the
            # price modified by the prestige value

            - if <yaml[kingdoms].read[<player.flag[kingdom]>.balance].is[OR_MORE].than[<[truePrice]>]>:

                # Deduct amount from kingdom balance and add to NPC total

                - define nameType <context.item.display.split[Spawn<&sp>a<&sp>].get[2]>
                - define prestige <yaml[kingdoms].read[<player.flag[kingdom]>.prestige]>
                - define NPCOutpostMod 1|1
                - define specType null

                # Find if the player is currently standing in an outpost that
                # their kingdom owns, if so, define values for the outpost's
                # specialization type and how much of a modifier should be
                # applied

                - yaml load:outposts.yml id:outp

                - foreach <yaml[outp].read[<player.flag[kingdom]>].keys.exclude[totalupkeep]>:
                    - if <cuboid[<[value]>].contains[<player.location>]>:
                        - if <yaml[outp].contains[<player.flag[kingdom]>.<[value]>.specType]>:
                            - define specType <yaml[outp].read[<player.flag[kingdom]>.<[value]>.specType]>

                            - if <[specType]> == <context.item.flag[spawnType]>:
                                - define NPCOutpostMod <yaml[outp].read[<player.flag[kingdom]>.<[value]>.specMod]>

                - yaml id:outp unload

                ## >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                # If spawned NPC is a farmer type

                - if <context.item.flag[spawnType]> == farmers:
                    - create player <player.location> "<[nameType]> :: Lvl 1" save:latestNPC

                    # If the NPC is spawned into an outpost of its correspond-
                    # ing specialization type, assign it a modifier

                    - flag <entry[latestNPC].created_npc> outpostMod:<[NPCOutpostMod].as[list]>

                    # Change NPC's skin
                    - adjust def:<entry[latestNPC].created_npc> skin_blob:<script[RNPCSkins].data_key[farmer]>

                    # Make the AOE scale with half the kingdom's prestige with
                    # a minimum radius of 5

                    - if <[prestige].round.is[LESS].than[10]>:
                        - run FarmerRangeFinder def:<entry[latestNPC].created_npc>|5

                    - else:
                        - run FarmerRangeFinder def:<entry[latestNPC].created_npc>|<[prestige].div[2].round>

                    # Write relevant RNPC data

                    - run WriteRNPCData def:<entry[latestNPC].created_npc>|<context.item.flag[spawnType]>
                    - run CalculateRNPCPrice def.truePrice:<[truePrice]> def.player:<player>

                ## >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                # If spawned NPC is a miner type

                - else if <context.item.flag[spawnType]> == miners:
                    - define npcLoc <player.location>

                    # A sample of blocks above the npc by 10 blocks with a
                    # dimension of 4x4

                    - define tenBlocksAbove <cuboid[<[npcLoc].location.world.name>,<[npcLoc].x.sub[1]>,<[npcLoc].y.add[10]>,<[npcLoc].z.sub[1]>,<[npcLoc].x.add[1]>,<[npcLoc].y>,<[npcLoc].z.add[1]>]>
                    - define numOfAir 0

                    # - narrate format:debug TBA:<[tenBlocksAbove].blocks>

                    - foreach <[tenBlocksAbove].blocks>:
                        - if <[value].material.name> == air:
                            - define numOfAir:++

                    # If the ratio of air blocks in the sample is below
                    # 40% then initialize the miner NPC

                    # - narrate format:debug NOA:<[numOfAir]>
                    # - narrate format:debug NOA_DIV:<[numOfAir].div[<[tenBlocksAbove].volume>]>
                    #- determine cancelled

                    - if <[numOfAir].div[<[tenBlocksAbove].volume>].is[OR_LESS].than[0.6]> || <[numOfAir]> == 0:

                        - create player <player.location> "<[nameType]> :: Lvl 1" save:latestNPC

                        # If the NPC is spawned into an outpost of its correspond
                        # .ing specialization type, assign it a modifier

                        - flag <entry[latestNPC].created_npc> outpostMod:<[NPCOutpostMod]>

                        # Write relevant RNPC data

                        - run WriteRNPCData def:<entry[latestNPC].created_npc>|<context.item.flag[spawnType]>

                        - if <[prestige].is[LESS].than[20]>:
                            - run MinerRangeFinder def.npc:<entry[latestNPC].created_npc> def.radius:5

                        - else:
                            - run MinerRangeFinder def.npc:<entry[latestNPC].created_npc> def.radius:<[prestige].div[4].round_up>

                        - run CalculateRNPCPrice def.truePrice:<[truePrice]> def.player:<player>

                    # If not then remove the NPC just created and its ref
                    # in the server RNPC flag

                    - else:
                        - narrate format:callout "You can't create a miner NPC here! These need to be at least 10 blocks below solid ground."

                ## >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                # If spawned NPC is a logger type

                - else if <context.item.flag[spawnType]> == loggers:
                    - create player <player.location> "<[nameType]> :: Lvl 1" save:latestNPC

                    # If the NPC is spawned into an outpost of its correspond
                    # .ing specialization type, assign it a modifier

                    - flag <entry[latestNPC].created_npc> outpostMod:<[NPCOutpostMod]>

                    - run WriteRNPCData def:<entry[latestNPC].created_npc>|<context.item.flag[spawnType]>

                    - if <[prestige].round.is[LESS].than[10]>:
                        - run LoggerRangeFinder def:<entry[latestNPC].created_npc>|20

                    - run CalculateRNPCPrice def.truePrice:<[truePrice]> def.player:<player>

                ## >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                # If spawned NPC is a guard type

                - else if <context.item.flag[spawnType]> == guard:
                    - yaml load:kingdoms.yml id:kingdoms
                    - yaml load:outposts.yml id:outp

                    - define isInCastleLoc <yaml[kingdoms].read[<player.flag[kingdom]>.castle_territory].contains[<player.location.chunk>]>

                    - if <[isInCastleLoc]>:
                        # Found in: CastleGuard.dsc
                        - run GuardSetup def:<player>

                    - else:
                        - narrate format:callout "You need to be inside your castle territory to spawn this NPC type."

                    - run CalculateRNPCPrice def.truePrice:<[truePrice]> def.player:<player>

                    - yaml id:kingdoms unload
                    - yaml id:outp unload

                - inventory close
                - if <entry[latestNPC].created_npc.has_flag[outpostMod]>:
                    - flag <entry[latestNPC].created_npc> type:<context.item.flag[spawnType]>

                - flag <entry[latestNPC].created_npc> kingdom:<player.flag[kingdom]>

            - else:
                - narrate format:callout "There is not enough money in your kingdom's bank to get that resource NPC!"

        - else:
            - narrate format:callout "You have reached the maximum number of NPCs for your kingdom!"

        - yaml id:kingdoms savefile:kingdoms.yml
        - yaml id:kingdoms unload
        - run SidebarLoader def.target:<server.flag[<player.flag[kingdom]>.members].include[<server.online_ops>]>

        on player clicks in RNPCSpawn_Window:
        - determine passively cancelled

        on player clicks barrier in RNPCSpawn_Window:
        - inventory close

RNPCInfo_Window:
    type: inventory
    inventory: chest
    gui: true
    title: "Select NPC Specialization"
    slots:
    - [] [UpgardeProgress_Item] [] [] [RNPCInventory_Item] [] [] [CurrentLevel_Item] []
    - [] [] [] [] [ShowRNPCAOE_Item] [] [] [] []
    - [] [] [] [] [DeleteRNPC_Item] [] [] [] []

DeleteConfirm_Window:
    type: inventory
    inventory: chest
    gui: true
    title: "Are you sure?"
    slots:
    - [] [] [ConfirmDeleteRNPC_Item] [] [] [] [CancelDeleteRNPC_Item] [] []

ConfirmDeleteRNPC_Item:
    type: item
    material: green_wool
    display name: "<green><bold>YES"

CancelDeleteRNPC_Item:
    type: item
    material: red_wool
    display name: "<red><bold>NO"

UpgardeProgress_Item:
    type: item
    display name: "<blue><bold>Progress to Next Level"
    material: blue_wool
    lore:
    - <proc[NPCLevelProgress].context[<npc.flag[Level]>]>

CurrentLevel_Item:
    type: item
    display name: "<green><bold>Current Level"
    material: green_wool
    lore:
    - "<&r><dark_purple>Lvl :: <player.flag[currNPC].flag[Level].round_down>"
    - ""
    - "<white>Output Bonus: <blue><npc.flag[outputMod].mul[100].round><&pc>"

ShowRNPCAOE_Item:
    type: item
    display name: "<light_purple><bold>Show AOE"
    material: glass
    lore:
    - "<&r>Shows the area that the NPC's resource gathering operates in"
    - "<&r>for 10 seconds."

RNPCInventory_Item:
    type: item
    material: player_head
    display name: "<gold><bold>See Inventory"

DeleteRNPC_Item:
    type: item
    display name: "<red><bold>Delete NPC"
    material: barrier

RNPCLandTypeRef:
    type: data
    farmer: farm
    miner: mine
    logger: ranch
    fisherman: fishery

RNPCInfo_Handler:
    type: world
    events:
        on player clicks ShowRNPCAOE_Item in RNPCInfo_Window:
        - define npc <player.flag[currNPC]>
        - define npcLoc <[npc].location>
        - define kingdom <[npc].flag[kingdom]>

        - define areaOfEffect <util.notes.get[<util.notes.find_partial[_<[npc].id>]>]>
        - showfake blue_stained_glass <[areaOfEffect].outline_2d[<player.location.y.add[3]>]> duration:10s
        - inventory close

        on player clicks RNPCInventory_Item in RNPCInfo_Window:
        - inventory open d:<player.flag[currNPC].inventory>

        on player clicks DeleteRNPC_Item in RNPCInfo_Window:
        - inventory open d:DeleteConfirm_Window

        on player clicks ConfirmDeleteRNPC_Item in DeleteConfirm_Window:

        # When the player deletes the RNPC, also delete the noted
        # AOE cuboidTag as well as its entry in the universal list
        # of RNPCs attached to the server

        - define npc <player.flag[currNPC]>
        - define kingdom <[npc].flag[kingdom]>
        - yaml load:kingdoms.yml id:kingdoms

        # Refund code
        # Equation: mult = log(prestige + 18) - 1.25
        - define prestige <yaml[kingdoms].read[<[kingdom]>.prestige]>
        - define refundMultiplier <[prestige].add[18].log[10].sub[1.25]>
        - define npcType <[npc].flag[type].if_null[guard]>
        - define npcCost <script[RNPCBasePrices].data_key[<[npcType]>]>
        - define refund <[npcCost].mul[<[refundMultiplier]>]>

        - note as:INTERNAL_<script[RNPCLandTypeRef].data_key[<[npc].nickname.split[<&sp>::].get[1]>]>_<[kingdom]>_<[npc].id> remove

        # Remove all references of NPC from YAML files

        - yaml load:npclist.yml id:npcl
        - yaml id:kingdoms set <[kingdom]>.npcs.npc_total:--
        - yaml id:kingdoms set <[kingdom]>.balance:+:<[refund].round>
        - yaml id:npcl set <[kingdom]>.NPCAmount:--
        - yaml id:npcl set <[kingdom]>.AllNPCs:<-:<[npc]>
        - yaml id:npcl set <[kingdom]>.<[npc].flag[RNPC]>:<-:<[npc]>
        - yaml id:kingdoms savefile:kingdoms.yml
        - yaml id:npcl savefile:npclist.yml
        - yaml id:kingdoms unload
        - yaml id:npcl unload

        - foreach <server.flag[RNPCs]>:
            - if <[value].get[1]> == <[npc].id>:
                - flag server RNPCs:<server.flag[RNPCs].remove[<[loop_index]>]>
                - foreach stop

        - remove <[npc]>
        - inventory close
        - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>

        on player clicks CancelDeleteRNPC_Item in DeleteConfirm_Window:
        - inventory close

RNPCHandler:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
    interact scripts:
    - RNPCHandler_I

##ignorewarning raw_object_notation

RNPCHandler_I:
    type: interact
    steps:
        1:
            click trigger:
                script:
                - if <player.flag[kingdom]> == <npc.flag[kingdom]>:
                    - if <npc.has_flag[RNPC]>:
                        - flag player currNPC:<npc>

                        - inventory open d:RNPCInfo_Window

                    - else:
                        - narrate "<red>An Internal Error Has Occured!"
                        - narrate "<gray>NPC flag 'RNPC' not found on n@<npc.id>. Please report this error to the server administrator immediately."