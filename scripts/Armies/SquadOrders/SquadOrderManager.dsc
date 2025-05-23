##
## All of the smaller squad order scripts can be found here + some move/attack related helper tasks.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: May 2023
## @Script Ver: v1.1
##
## ------------------------------------------END HEADER-------------------------------------------


SoldierManager_Assignment:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true

        on click:
        - if !<npc.has_flag[soldier]>:
            - determine cancelled

        - define kingdom <npc.flag[soldier.kingdom]>
        - define squadName <npc.flag[soldier.squad]>

        - flag <player> datahold.squadInfo:<server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>

        - if <player.flag[kingdom]> != <[kingdom]>:
            - determine cancelled

        - inventory close
        - wait 3t
        - run GiveSquadTools def.player:<player>
        - run ActionBarToggler def.player:<player> def.message:<element[Now Commanding: <player.flag[datahold.squadInfo.displayName].color[red].bold>]> def.toggleType:true


SquadRecall_Item:
    type: item
    material: player_head
    display name: <white><bold>Recall to Base
    mechanisms:
        skull_skin: bd2c2584-f53e-4829-81a3-5cff044e4979|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOGFhMTg3ZmVkZTg4ZGUwMDJjYmQ5MzA1NzVlYjdiYTQ4ZDNiMWEwNmQ5NjFiZGM1MzU4MDA3NTBhZjc2NDkyNiJ9fX0=


MiscOrders_Item:
    type: item
    material: player_head
    display name: <blue><bold>Show Misc Orders
    mechanisms:
        skull_skin: 49821769-c171-4288-9b95-ba04b799186f|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvY2EzYjlkNzFiYjU5NDI2NTdkNjZhNjMwMzMyZGIyYjk2MTg5ZjI1MTI3MTBlYzhjMzE0OTIxOGM4NTNmZGRiNiJ9fX0=


ExitSquadControls_Item:
    type: item
    material: barrier
    display name: <red><bold>Exit Squad Controls


SquadMoveTool_Item:
    type: item
    material: tipped_arrow
    display name: <white><bold>Move Order
    mechanisms:
        potion_effects:
        - [type=INVISIBILITY]
        hides: ALL


SquadAttackAllTool_Item:
    type: item
    material: tipped_arrow
    display name: <red><bold>Attack All Order
    mechanisms:
        potion_effects:
        - [type=INSTANT_HEAL]
        hides: ALL


SquadAttackTool_Item:
    type: item
    material: tipped_arrow
    display name: <element[Attack Squad Order].color[fuchsia].bold>
    mechanisms:
        potion_effects:
        - [type=REGEN]
        hides: ALL


SquadAttackMonstersTool_Item:
    type: item
    material: tipped_arrow
    display name: <element[Attack Monsters Order].color[#8f6464].bold>
    mechanisms:
        potion_effects:
        - [type=INSTANT_DAMAGE]
        hides: ALL


SquadClearAllAttacksTool_Item:
    type: item
    material: spectral_arrow
    display name: <element[Clear All Attack Orders].color[gold].bold>
    mechanisms:
        hides: ALL


SquadOccupyTool_Item:
    type: item
    material: stick
    display name: <element[Occupy Chunk/Outpost].color[<proc[GetColor].context[Default.Brown]>]>
    enchantments:
    - sharpness:1
    mechanisms:
        hides: ALL


SquadOptions_Handler:
    type: world
    events:
        ## PREVENT TAKING ITEMS
        on player clicks in inventory flagged:datahold.armies.squadTools:
        - narrate format:callout "Please exit squad orders mode first to be able to do that!"
        - determine cancelled

        ## MISC ORDERS
        on player right clicks block with:MiscOrders_Item flagged:datahold.armies.squadTools:
        - if <player.flag[datahold.armies.squadTools]> != 1:
            - repeat 9:
                - inventory slot:<[value]> set origin:air

            - run GiveSquadTools def.player:<player> def.saveInv:false

        - else:
            - repeat 7:
                - inventory slot:<[value]> set origin:air

            - give to:<player.inventory> SquadRecall_Item
            - flag <player> datahold.armies.squadTools:2

            - adjust <player> item_slot:1

        - determine cancelled

        ## RECALL SQUAD
        on player right clicks block with:SquadRecall_Item:
        - define kingdom <player.flag[kingdom]>
        - define squadName <player.flag[datahold.squadInfo.name]>
        - define npcList <proc[GetSquadNPCs].context[<[kingdom]>|<[squadName]>].include[<proc[GetSquadLeader].context[<[kingdom]>|<[squadName]>]>]>
        - define stationInfo <server.flag[kingdoms.<[kingdom]>.armies.barracks].parse_value_tag[<[parse_value].get[stationedSquads]>]>
        - define barrackID 0

        - foreach <[stationInfo]>:
            - if <[value].contains[<[squadName]>]>:
                - define barrackID <[key]>
                - foreach stop

        - if <[barrackID]> == 0:
            - narrate format:debug "<red>[Internal Error SQA111] <&gt><&gt> <gold>Cannot associate squad with barrack."
            - determine cancelled

        - run ResetSquadTools def.player:<player>

        - define SMLocation <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.location]>
        - inject SpawnSquadNPCs path:FindSpacesAroundSM

        - foreach <[npcList]> as:npc:
            - run WalkSoldierToSM_Helper def.npc:<[npc]> def.location:<[spawnLocation]>

        - run SquadEquipmentChecker def.squadName:<[squadName]> def.kingdom:<[kingdom]>
        - run ActionBarToggler def.player:<player> def.toggleType:false

        - narrate format:callout "Stashing squad at barracks: <server.flag[kingdoms.<[kingdom]>.armies.barracks.<[barrackID]>.name].color[red]>..."
        - narrate format:callout "To respawn the squad click on their icon in the squad list option in your SM."
        - determine cancelled

        ## ATTACK ORDER: ALL
        on player right clicks block with:SquadAttackAllTool_Item:
        - ratelimit <player> 10t

        - define kingdom <player.flag[kingdom]>
        - define squadInfo <player.flag[datahold.squadInfo]>
        - define squadName <[squadInfo].get[name]>
        - define squadLeader <[squadInfo].get[squadLeader]>
        - define npcList <[squadInfo].get[npcList]>

        # If the squad already has the attackAll order
        - if <[squadLeader].has_flag[soldier.order]> && <[squadLeader].flag[soldier.order]> == attackAll:
            - flag <[squadLeader]> datahold.armies.particles:!
            - flag <[squadLeader]> soldier.order:!

            - run SquadRemoveAllOrders def.kingdom:<[kingdom]> def.squadName:<[squadName]>

        - else:
            - flag <[squadLeader]> datahold.armies.particles
            - flag <[squadLeader]> soldier.order:attackAll

            - run SquadRemoveAllOrders def.kingdom:<[kingdom]> def.squadName:<[squadName]>
            - run SquadAttackAllOrder def.kingdom:<[kingdom]> def.squadName:<[squadName]>
            - run SoldierParticleGenerator def.npcList:<[npcList]> def.squadLeader:<[squadLeader]> def.orderType:attackAll

        ## ATTACK ORDER: SQUAD
        on player clicks block with:SquadAttackTool_Item:
        - ratelimit <player> 10t

        - if !<player.cursor_on[<proc[GetConfigNode].context[Armies.max-order-distance]>].exists>:
            - determine cancelled

        - define kingdom <player.flag[kingdom]>

        # TODO(High): Replace all of these player.flag[datahold.squadInfo] with actual KAPI calls.
        # TODO/ You shouldn't need to juggle a flag around just to access basic squad information.
        - define squadInfo <player.flag[datahold.squadInfo]>
        - define squadName <[squadInfo].get[name]>
        - define squadLeader <[squadInfo].get[squadLeader]>
        - define npcList <[squadInfo].get[npcList]>

        - if <[squadLeader].has_flag[soldier.order]> && <[squadLeader].flag[soldier.order]> == attackSquad:
            - flag <[squadLeader]> datahold.armies.particles:!
            - flag <[squadLeader]> soldier.order:!

            - run SquadRemoveAllOrders def.kingdom:<[kingdom]> def.squadName:<[squadName]>

        - else:
            - flag <[squadLeader]> datahold.armies.particles
            - flag <[squadLeader]> soldier.order:attackSquad

            - run FindClickedSquad def.location:<player.cursor_on[100]> def.kingdom:<[kingdom]> def.range:10 save:enemySquadInfo
            - define enemySquadInfo <entry[enemySquadInfo].created_queue.determination.get[1]>

            - narrate format:callout "Attacking Squad: <[enemySquadInfo].get[squadName].color[red]> from: <[enemySquadInfo].get[kingdom].color[red]>"

            - run SquadRemoveAllOrders def.kingdom:<[kingdom]> def.squadName:<[squadName]>
            - run SquadAttackSquadOrder def.kingdom:<[kingdom]> def.squadName:<[squadName]> def.enemyKingdom:<proc[GetSquadLeader].context[<[enemySquadInfo].get[kingdom]>|<[enemySquadInfo].get[squadName]>].flag[soldier.kingdom]> def.enemySquadName:<[enemySquadInfo].get[squadName]>
            - run SoldierParticleGenerator def.npcList:<[npcList]> def.squadLeader:<[squadLeader]> def.orderType:attackSquad

        ## ATTACK ORDER: MONSTERS
        on player right clicks block with:SquadAttackMonstersTool_Item:
        - ratelimit <player> 1s

        - define kingdom <player.flag[kingdom]>
        - define squadInfo <player.flag[datahold.squadInfo]>
        - define squadName <[squadInfo].get[name]>
        - define squadLeader <[squadInfo].get[squadLeader]>
        - define npcList <[squadInfo].get[npcList]>

        - if <[squadLeader].has_flag[soldier.order]> && <[squadLeader].flag[soldier.order]> == attackMonsters:
            - flag <[squadLeader]> datahold.armies.particles:!
            - flag <[squadLeader]> soldier.order:!

            - run SquadRemoveAllOrders def.kingdom:<[kingdom]> def.squadName:<[squadName]>

        - else:
            - flag <[squadLeader]> datahold.armies.particles
            - flag <[squadLeader]> soldier.order:attackMonsters

            - run SquadRemoveAllOrders def.kingdom:<[kingdom]> def.squadName:<[squadName]>
            - run SquadAttackMonstersOrder def.kingdom:<[kingdom]> def.squadName:<[squadName]>
            - run SoldierParticleGenerator def.npcList:<[npcList]> def.squadLeader:<[squadLeader]> def.orderType:attackMonsters

        ## CLEAR ATTACK ORDERS
        on player right clicks block with:SquadClearAllAttacksTool_Item:
        - ratelimit <player> 1s

        - define kingdom <player.flag[kingdom]>
        - define squadInfo <player.flag[datahold.squadInfo]>
        - define squadName <[squadInfo].get[name]>
        - define squadLeader <[squadInfo].get[squadLeader]>

        - flag <[squadLeader]> datahold.armies.particles:!
        - flag <[squadLeader]> soldier.order:!

        - run SquadRemoveAllOrders def.kingdom:<[kingdom]> def.squadName:<[squadName]>

        # - foreach <proc[GetSquadNPCs].context[<[kingdom]>|<[squadName]>].include[<proc[GetSquadLeader].context[<[kingdom]>|<[squadName]>]>]> as:soldier:
        #     - execute as_server "sentinel removetarget monsters --id <[soldier].id>" silent

        ## REG. MOVE SQUAD
        on player right clicks block with:SquadMoveTool_Item:
        - ratelimit <player> 1s

        - define kingdom <player.flag[kingdom]>
        - define location <player.cursor_on_solid[50]>
        - define squadInfo <player.flag[datahold.squadInfo]>
        - define squadName <[squadInfo].get[name]>
        - define npcList <[squadInfo].get[npcList]>
        - define squadLeader <[squadInfo].get[squadLeader]>
        - define displayName <[squadInfo].get[displayName]>

        # If the squad was occupying to a chunk and then moved to a different chunk.
        - if <[squadLeader].has_flag[datahold.war.occupying]> && <[squadLeader].flag[datahold.war.occupying.chunk].contains[<[location]>]>:
            - run ChunkOccupationVisualizer path:CancelVisualization def.squadLeader:<[squadLeader]>
            - run CancelChunkOccupation def.kingdom:<[kingdom]> def.targetKingdom:<[squadLeader].flag[datahold.war.occupying.target]> def.squadLeader:<[squadLeader]> def.chunk:<[squadLeader].flag[datahold.war.occupying.chunk]>
            - run CancelOutpostOccupation def.kingdom:<[kingdom]> def.squadName:<[squadName]> def.outpost:<[squadLeader].flag[datahold.war.occupying.outpost]> if:<[squadLeader].has_flag[datahold.war.occupying.outpost]>
            - run CancelOutpostReclamation def.kingdom:<[kingdom]> def.targetKingdom:<[squadLeader].flag[datahold.war.occupying.target]> def.squadName:<[squadName]> def.outpost:<[squadLeader].flag[datahold.war.occupying.outpost]> if:<[squadLeader].has_flag[datahold.war.occupying.outpost]>
            - run CancelChunkReclamation def.kingdom:<[kingdom]> def.targetKingdom:<[squadLeader].flag[datahold.war.occupying.target]> def.squadName:<[squadName]> def.chunk:<[squadLeader].flag[datahold.war.occupying.chunk]> if:<[squadLeader].has_flag[datahold.war.occupying.chunk]>

        - define npcsPerRow <player.flag[datahold.armies.npcsPerRow].if_null[3]>
        - define lineLength <player.flag[datahold.armies.lineLength].div[2].if_null[6]>

        - run FormationWalk def.npcList:<[npcList]> def.squadLeader:<[squadLeader]> def.npcsPerRow:<[npcsPerRow]> def.finalLocation:<[location].with_yaw[<player.location.yaw.round_to_precision[5]>]> def.lineLength:<[lineLength]> def.player:<player>

        ## LINE MOVE SQUAD
        on player left clicks block with:FormationLineTool_Item flagged:datahold.armies.drawingFormation.pointTwo:
        - determine passively cancelled

        - define kingdom <player.flag[kingdom]>
        - define squadInfo <player.flag[datahold.squadInfo]>
        - define squadName <[squadInfo].get[name]>
        - define npcList <[squadInfo].get[npcList]>
        - define squadLeader <[squadInfo].get[squadLeader]>
        - define pointTwo <player.flag[datahold.armies.drawingFormation.pointTwo]>
        - define pointOne <player.flag[datahold.armies.drawingFormation.pointOne]>

        # If the squad was occupying to a chunk and then moved to a different chunk.
        - if <[squadLeader].has_flag[datahold.war.occupying.chunk]> && (<[squadLeader].flag[datahold.war.occupying.chunk].contains[<[pointOne]>]> || <[squadLeader].flag[datahold.war.occupying.chunk].contains[<[pointTwo]>]>):
            - run ChunkOccupationVisualizer path:CancelVisualization def.squadLeader:<[squadLeader]>
            - run CancelChunkOccupation def.kingdom:<[kingdom]> def.targetKingdom:<[squadLeader].flag[datahold.war.occupying.target]> def.squadLeader:<[squadLeader]> def.chunk:<[squadLeader].flag[datahold.war.occupying.chunk]>
            - run CancelOutpostOccupation def.kingdom:<[kingdom]> def.squadName:<[squadName]> def.outpost:<[squadLeader].flag[datahold.war.occupying.outpost]> if:<[squadLeader].has_flag[datahold.war.occupying.outpost]>
            - run CancelOutpostReclamation def.kingdom:<[kingdom]> def.targetKingdom:<[squadLeader].flag[datahold.war.occupying.target]> def.squadName:<[squadName]> def.outpost:<[squadLeader].flag[datahold.war.occupying.outpost]> if:<[squadLeader].has_flag[datahold.war.occupying.outpost]>
            - run CancelChunkReclamation def.kingdom:<[kingdom]> def.targetKingdom:<[squadLeader].flag[datahold.war.occupying.target]> def.squadName:<[squadName]> def.chunk:<[squadLeader].flag[datahold.war.occupying.chunk]> if:<[squadLeader].has_flag[datahold.war.occupying.chunk]>

        - run DrawLineFormationWalk def.npcList:<[npcList]> def.soldierSpacing:3 def.squadLeader:<[squadLeader]> def.player:<player> def.pointOne:<[pointOne]> def.pointTwo:<[pointTwo]>

        - wait 1s

        - run CreateParticleLine path:ClearParticleLineFlag def.flagName:formationLine
        - flag <player> datahold.armies.drawingFormation:!

        ## OCCUPY CHUNK/OUTPOST
        on player right clicks block with:SquadOccupyTool_Item:
        - ratelimit <player> 2t

        - determine passively cancelled

        - define squadInfo <player.flag[datahold.squadInfo]>
        - define squadLeader <[squadInfo].get[squadLeader]>
        - define kingdom <[squadLeader].flag[soldier.kingdom]>

        - if !<[kingdom].proc[GetKingdomWarStatus]>:
            - narrate format:callout "You cannot occupy this chunk or outpost! Your kingdom is not at war."
            - stop

        - define chunk <[squadLeader].location.chunk>

        # If the chunk that the squad leader is standing in has been claimed by another kingdom
        # then initiate the chunk reclaim process.
        - if <[chunk].is_in[<[kingdom].proc[GetClaims]>]>:
            - foreach <[kingdom].proc[GetKingdomWars]> as:war:
                - if <[kingdom].proc[GetAllKingdomLostChunks].context[<[war]>].contains[<[chunk]>]>:
                    #- Debug Value -#
                    - define claimDuration <duration[5m]>
                    - narrate format:callout "Your troops have started reclaiming this chunk. It will take them: <[claimDuration].formatted.color[aqua]> to finish occupying it. They must not be engaged in combat for this time."

                    - adjust <[squadLeader]> hologram_line_height:0.25

                    - run ReclaimChunk def.kingdom:<[kingdom]> def.targetKingdom:<proc[GetChunkOccupier].context[<[kingdom]>|<[war]>|<[chunk]>]> def.squadLeader:<[squadLeader]> def.chunk:<[chunk]> def.delay:<[claimDuration]>
                    - run ChunkOccupationVisualizer def.squadLeader:<[squadLeader]> def.occupationDuration:<[claimDuration]>
                    - stop

        # If the chunk that the squad leader is standing in is part of an outpost which has been
        # claimed by another kingdom, then initiate the outpost reclaim process.
        - else if <[kingdom].proc[GetOutposts].filter_tag[<[filter_value].get[area].contains[<[squadLeader].location>]>].size> > 0:
            #- Debug Value -#
            - run ReclaimOutpost def.kingdom:<[kingdom]> def.outpost:<[kingdom].proc[GetOutposts].filter_tag[<[filter_value].get[area].contains[<[squadLeader].location>]>].keys.get[1]> def.squadName:<[squadInfo].get[name]> def.delay:<duration[1m]> save:delay
            - define claimDuration <entry[delay].created_queue.determination.get[1]>

            - run ChunkOccupationVisualizer def.squadLeader:<[squadLeader]> def.occupationDuration:<[claimDuration]>

            - narrate format:callout "Your troops have started reclaiming this outpost. It will take them: <[claimDuration].formatted.color[aqua]> to finish occupying it. They must not be engaged in combat for this time."
            - stop

        # All the kingdoms that the squad leader's kingdom is at war with
        - define kingdomsAtWar <proc[GetKingdomList].exclude[<[kingdom]>].filter_tag[<proc[IsAtWarWithKingdom].context[<[kingdom]>|<[filter_value]>]>]>

        - foreach <[kingdomsAtWar]>:
            - define outpostData <[value].proc[GetOutposts].parse_value_tag[<[parse_value].include[name=<[parse_key]>]>].filter_tag[<[filter_value].get[area].contains[<[squadLeader].location>]>].values.get[1].if_null[null]>

            # If the squad leader is standing in another kingdom's as-of-yet unclaimed chunk, then
            # claim it for the squad leader's kingdom.
            - if <[value].proc[GetClaims].contains[<[chunk]>]>:
                - define claimDuration <duration[5m]>
                - run OccupyChunk def.kingdom:<[kingdom]> def.targetKingdom:<[value]> def.chunk:<[chunk]> def.squadLeader:<[squadLeader]> def.delay:<[claimDuration]> save:result

                - if <entry[result].created_queue.determination.get[1]> == null:
                    - stop

                - narrate format:callout "Your troops have started occupying this chunk. It will take them: <[claimDuration].formatted.color[aqua]> to finish occupying it. They must not be engaged in combat for this time."
                - adjust <[squadLeader]> hologram_line_height:0.25
                - flag <[squadLeader]> datahold.war.occupying.chunk:<[chunk]>
                - flag <[squadLeader]> datahold.war.occupying.target:<[value]>

                - run ChunkOccupationVisualizer def.squadLeader:<[squadLeader]> def.occupationDuration:<[claimDuration]>
                - stop

            # Same as above but for outposts.
            - else if <[outpostData].is_truthy> && !<[outpostData].is_empty>:
                - define squadLeaders <[kingdom].proc[GetKingdomSquads].parse_value_tag[<[parse_value].get[squadLeader]>].values>
                - define otherOccupyingSquads <list[]>

                - flag <[squadLeader]> datahold.war.occupying.outpost:<[outpostData].get[name]>

                - foreach <[squadLeaders]> as:leader:
                    - if <[leader].has_flag[datahold.war.occupying.outpost]> && <[leader].flag[datahold.war.occupying.outpost]> == <[outpostData].get[name]>:
                        - define otherOccupyingSquads:->:<[leader].flag[soldier.squad]>

                # - define baseClaimDuration <duration[<[outpostData].get[size].div[256].round_up.mul[5]>m]>
                # - define claimDuration <duration[<[baseClaimDuration].in_minutes.mul[<[otherOccupyingSquads].size.if_null[1]>]>m]>

                - run OccupyOutpost def.kingdom:<[kingdom]> def.targetKingdom:<[value]> def.outpost:<[outpostData].get[name]> def.squadName:<[squadLeader].flag[soldier.squad]> save:claimDuration
                - define claimDuration <entry[claimDuration].created_queue.determination.get[1]>

                - if !<[claimDuration].is_truthy> || <[claimDuration]> == null:
                    - stop

                - narrate format:callout "Your troops have started occupying this outpost. It will take them: <[claimDuration].formatted.color[aqua]> to finish occupying it. They must not be engaged in combat for this time."
                - narrate format:callout "<italic>Note: You may move in additional squads to occupy outposts faster."

            # Wilderness check. You can't claim wilderness chunks through the war interactions.
            - else:
                - narrate format:callout <element[Failed to claim chunk!].color[red]><element[ This area is a part of the wilderness, and cannot be occupied during a war.]>

        ## PREVENT WARPING WITH SQUAD TOOLS
        on warp command:
        - if <player.has_flag[datahold.armies.squadTools]>:
            - determine passively cancelled
            - narrate format:callout "You cannot warp while using army/squad tools. Please exit the squad interface before warping."

        ## EXITS ORDERS
        on player clicks block with:ExitSquadControls_Item:
        - flag <player> datahold.squadInfo:!
        - flag <player> datahold.armies.squadTools:!
        - run ResetSquadTools def.player:<player>
        - run ActionBarToggler def.player:<player> def.toggleType:false

        - determine cancelled

        on player quits flagged:datahold.armies.squadTools:
        - run ActionBarToggler def.player:<player> def.toggleType:false
        - run ResetSquadTools def.player:<player>

        on player places ExitSquadControl_Item:
        - determine cancelled

        on player drops SquadMoveTool_Item:
        - determine cancelled

        on player drops ExitSquadControls_Item:
        - determine cancelled


ChunkOccupationVisualizer:
    type: task
    debug: false
    definitions: squadLeader[NPCTag]|occupationDuration[DurationTag]|occupationMessages[?MapTag(ElementTag(String))]
    description:
    - Will display a small progress bar as a hologram above the head of the provided squad leader indicating how long until the chunk is fully occupied.
    - ---
    - → [Void]

    script:
    ## Will display a small progress bar as a hologram above the head of the provided squad leader
    ## indicating how long until the chunk is fully occupied.
    ##
    ## squadLeader          :  [NPCTag]
    ## occupationDuration   :  [DurationTag]
    ## occupationMessages   : ?[MapTag(ElementTag(String))]
    ##
    ## >>> [Void]

    - if <[squadLeader].object_type> != Npc:
        - run GenerateInternalError def.type:TypeError def.message:<element[Unable to set squad leader hologram. Provided definition: <[squadLeader].color[red]> is not of type: NPCTag]>
        - stop

    - if !<[squadLeader].has_flag[soldier]>:
        - run GenerateInternalError def.type:GenericError def.message:<element[Unable to set squad leader hologram. Npc with provided ID: <[squadLeader].id.color[red]> is not member of any squad.]>
        - stop

    - if <[occupationDuration].object_type> != Duration:
        - run GenerateInternalError def.type:GenericError def.message:<element[Unable to set squad leader hologram. Provided definition: <[occupationDuration].color[red]> is not of type: DurationTag.]>
        - stop

    - define startTime <util.time_now>
    - inject ChunkOccupationVisualizer path:Visualizer_Helper

    Visualizer_Helper:
    - if <[completeMessage].exists> && <[interruptMessage].exists>:
        - goto SkipMessageSetters

    - define completeMessage <element[&2Chunk Occupation Complete!]>
    - define interruptMessage <element[&4Chunk Occupation Interrupted!]>

    - if <[occupationMessages].exists> && <[occupationMessages].contains[complete|interrupt]>:
        - define completeMessage <[occupationMessages].get[complete]>
        - define interruptMessage <[occupationMessages].get[interrupt]>

    - mark SkipMessageSetters

    - define maxPercentage <[occupationDuration].in_seconds>
    - define timeRemaining <[occupationDuration].sub[<util.time_now.duration_since[<[startTime]>]>]>
    - define currentPercentage <util.time_now.duration_since[<[startTime]>].in_seconds.div[<[maxPercentage]>].mul[100].if_null[0]>
    - define progressGraphic <list[]>

    - if <[currentPercentage]> >= 100:
        - adjust <[squadLeader]> hologram_lines:<map[text=<element[<[completeMessage]>]>;duration=<duration[15s]>]>
        - stop

    - repeat <[currentPercentage].div[5].round>:
        - define progressGraphic:->:█

    - repeat <element[20].sub[<[currentPercentage].div[5]>].round>:
        - define progressGraphic:->:░

    - adjust <[squadLeader]> hologram_lines:<list[<[progressGraphic].unseparated>|<[currentPercentage].round_to_precision[0.1]>% Occupied|<element[Time Remaining: ]>&4<[timeRemaining].formatted>]>

    - runlater ChunkOccupationVisualizer path:Visualizer_Helper id:<[squadLeader]>_occupation_visualizer def.squadLeader:<[squadLeader]> def.occupationDuration:<[occupationDuration]> def.startTime:<[startTime]> delay:5s

    CancelVisualization:
    - define interruptMessage <[interruptMessage].if_null[&4<element[Chunk Occupation Interrupted!]>]>

    - adjust system cancel_runlater:<[squadLeader]>_occupation_visualizer
    - adjust <[squadLeader]> hologram_lines:<map[text=<element[<[interruptMessage]>]>;duration=<duration[15s]>]>
    - stop


SoldierParticleGenerator:
    type: task
    debug: false
    definitions: npcList[ListTag(NPCTag)]|squadLeader[NPCTag]|orderType[?ElementTag(String)]
    description:
    - Applies a particle effect to a list of soldiers which changes depending on the type of order they are given.
    - ---
    - [Void]

    script:
    ## Applies a particle effect to a list of soldiers which changes depending on the type of order
    ## they are given.
    ##
    ## npcList     : [ListTag<NPCTag>]
    ## squadLeader : [NPCTag]
    ## orderType   : ?[ElementTag<String>]
    ##               Accepted Values: attackAll, attackSquad
    ##
    ## >>> [Void]

    - define waitTime 7t
    - definemap orderFormats:
        attackAll: 2|red
        attackSquad: 1.5|fuchsia
        attackMonsters: 1.5|#8f6464

    - define orderType attackAll if:<[orderType].exists.not.or[<[orderType].is_in[<[orderFormats].keys>]>]>

    - while <[squadLeader].exists> && <[squadLeader].has_flag[datahold.armies.particles]>:
        - foreach <[npcList].include[<[squadLeader]>]> as:soldier:
            - playeffect at:<[soldier].location.up[3]> effect:REDSTONE special_data:<[orderFormats].get[<[orderType]>]> quantity:3 offset:0,0,0

        - wait <[waitTime]>


SquadEquipmentChecker:
    type: task
    definitions: squadName|kingdom
    script:
    ## Checks that a given squad has its standard equipment. If not this task will assign as many
    ## soldiers as possible their gear from the barracks' assigned armory.
    ##
    ## squadName : [ElementTag<String>]
    ## kingdom   : [ElementTag<String>]
    ##
    ## >>> [Void]

    - define standardEquipment <proc[GetSquadEquipment].context[<[kingdom]>|<[squadName]>]>

    # Get SMLocation and find armory locations
    - define SMLocation <proc[GetSquadSMLocation].context[<[kingdom]>|<[squadName]>]>
    - define filledArmories <proc[GetSMArmoryLocations].context[<[SMLocation]>].filter_tag[<[filter_value].inventory.is_empty.not>]>

    # Loop through all squad soldiers with squad leader coming first to give them priority for
    # equipment
    - foreach <proc[GetSquadNPCs].context[<[kingdom]>|<[squadName]>].insert[<proc[GetSquadLeader].context[<[kingdom]>|<[squadName]>]>].at[1]> as:soldier:
        - define missingEquipment <[soldier].proc[GetSoldierMissingStandardEquipment]>

        #...Skip soldier if their equipment needs are met
        - if <[missingEquipment].is_empty>:
            - foreach next

        - foreach <[missingEquipment]>:
            - run GiveSoldierItemFromArmory def.soldier:<[soldier]> def.squadName:<[squadName]> def.kingdom:<[kingdom]> def.item:<[value]> def.armories:<[filledArmories]>


FindClickedSquad:
    type: task
    definitions: location|kingdom|range
    script:
    ## Finds the nearest squad to the location provided within the range provided. If no range
    ## argument is provided, it will default to 10.
    ##
    ## location : [LocationTag]
    ## kingdom  : [ElementTag<String>]
    ## range    : ?[ElementTag<Float>]
    ##
    ## >>> [MapTag]

    - define range <[range].if_null[10]>
    - define range 10 if:<[range].sin.exists.not>
    - define nearbySoldiers <[location].find_npcs_within[<[range]>].filter_tag[<[filter_value].has_flag[soldier]>]>
    - define nearbyEnemySoldiers <[nearbySoldiers].filter_tag[<[filter_value].flag[soldier.kingdom].equals[<[kingdom]>].not>]>

    - if <[nearbyEnemySoldiers].size> == 0:
        - determine <map[]>

    - determine <map[squadName=<[nearbySoldiers].get[1].flag[soldier.squad]>;kingdom=<[nearbySoldiers].get[1].flag[soldier.kingdom]>]>


DEBUG_ClearSquadEquipment:
    type: task
    enabled: false
    definitions: squadName|kingdom
    script:
    - define npcList <proc[GetAllSquadNPCs].context[<[kingdom]>|<[squadName]>]>

    - foreach <[npcList]> as:soldier:
        - equip <[soldier]> boots:air
        - equip <[soldier]> chest:air
        - equip <[soldier]> legs:air
        - equip <[soldier]> head:air
        - inventory clear d:<[soldier].inventory>


WalkSoldierToSM_Helper:
    type: task
    definitions: npc|location
    script:
    - walk <[npc]> <[location]> auto_range
    - waituntil <[npc].is_navigating.not> rate:1s
    - despawn <[npc]>


OLD_SquadAttackAllOrder:
    type: task
    enabled: false
    definitions: kingdom|squadName
    DEBUG_OldApproach:
    - define squadInfo <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>
    - define npcList <[squadInfo].get[npcList]>
    - define squadLeader <[squadInfo].get[squadLeader]>
    - define unassignedFriendlies <[npcList]>
    - define nearbyNPCs <[squadLeader].location.find_npcs_within[40]>
    - define nearbySquads <map[]>

    - if <[nearbyNPCs].if_null[<list[]>].is_empty>:
        - determine cancelled

    - foreach <[nearbyNPCs]> as:npc:
        - if !<[npc].has_flag[soldier.squadName]>:
            - foreach next

        - if <[npc].flag[soldier.kingdom]> == <[squadLeader].flag[soldier.kingdom]>:
            - foreach next

        - if <[npc].flag[soldier.squadName]> == <[squadLeader].flag[soldier.squadName]>:
            - foreach next

        - define nearbySquads.npcs:->:<[npc]>

        - if <[unassignedFriendlies].size> != 0:
            - define nearbySquads.<[npc].id>:->:<[unassignedFriendlies].first>
            - define unassignedFriendlies:<-:<[unassignedFriendlies].first>

    - while (<[unassignedFriendlies].size> != 0 || <queue.flag[iterations]> > 5) && !<[nearbySquads].is_empty>:
        - flag <queue> iterations:<queue.flag[iterations].if_null[0].add[1]>

        - foreach <[nearbySquads]> as:assignments key:npc:
            - narrate format:debug "Assigning Excess Friendly To: <[npc]>"
            - define nearbySquads.<[npc].id>:->:<[unassignedFriendlies].get[<[loop_index]>]>
            - define unassignedFriendlies:<-:<[unassignedFriendlies].get[<[loop_index]>]>

    - if <queue.flag[iterations]> > 5:
        - narrate format:debug "While loop iteration cap exceeded. Killing Queue..."

    - run flagvisualizer def.flag:<[nearbySquads]> def.flagName:nearby

    script:
    - define squadInfo <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>
    - define npcList <[squadInfo].get[npcList]>
    - define squadLeader <[squadInfo].get[squadLeader]>
    - define unassignedFriendlies <[npcList]>
    - define nearbyNPCs <[squadLeader].location.find_npcs_within[40].filter_tag[<[filter_value].flag[soldier.squad].equals[<[squadName]>].not>]>
    #- define nearbySquads <[nearbyNPCs].parse_tag[<map[<[parse_value].flag[soldier.squad]>=<[parse_value].flag[soldier.kingdom]>]>].deduplicate>
    - define nearbySquads <map[]>

    - foreach <[nearbyNPCs]> as:npc:
        - if !<[npc].has_flag[soldier]>:
            - foreach next

        - else:
            - define enemySquadName <[npc].flag[soldier.squad]>
            - define enemySquadKingdom <[npc].flag[soldier.kingdom]>
            - define enemySquad <server.flag[kingdoms.<[enemySquadKingdom]>.armies.squads.squadList.<[enemySquadName]>]>
            - define nearbySquads.<[enemySquadName]>:<[enemySquad].get[npcList].include[<[enemySquad].get[squadLeader]>]>

    # - run flagvisualizer def.flag:<[nearbyNPCs]> def.flagName:nearbyNPCs
    - run flagvisualizer def.flag:<[nearbySquads]> def.flagName:nearbySquads

    - define assignedSoldiers <map[]>

    # yes, second for loop that could be combined into previous one, i know.
    # i have deadlines.
    - foreach <[nearbySquads]> as:squad:
        - if <[npcList].size> >= <[squad].size>:
            - narrate "More or equal friendlies!"

            # oh look, another for loop!
            - foreach <[npcList]>:
                - define assignmentIndex <[loop_index].mod[<[squad].size.add[1]>]>
                - define assignmentIndex <[assignmentIndex].add[1]> if:<[loop_index].is[MORE].than[<[squad].size>]>
                - narrate format:debug <[squad].get[<[assignmentIndex]>].id>
                - define assignedSoldiers.<[squad].get[<[assignmentIndex]>].as[npc].id>:->:<[value].id>

        - else:
            - narrate "More enemies!"

    - run flagvisualizer def.flag:<[assignedSoldiers]> def.flagName:assSoldiers
