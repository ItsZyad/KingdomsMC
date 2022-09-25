SoldierTypeSelector:
    type: inventory
    title: "Soldier Selector"
    size: 54
    slots:
    - "[Militia] [Conscript] [Archer] [] [] [] [] [] []"
    - "[] [] [] [] [] [] [] [] []"
    - "[] [] [] [] [] [] [] [] []"
    - "[] [] [] [] [] [] [] [] []"
    - "[Equip] [] [] [] [] [] [] [] [SwitchWindow]"
    - "[AutoSwitch] [SafeShot] [ChaseClose] [ToggleRunaway] [ToggleFightback] [] [] [] [Exit]"

Militia:
    type: item
    material: zombie_head
    display name: Militia
    lore:
    - "A cheap, reliable, but untrained unit."

Conscript:
    type: item
    material: zombie_head
    display name: Conscript
    lore:
    - "A moderate, well-rounded unit with decent training"

Archer:
    type: item
    material: bow
    display name: Archer
    lore:
    - "The baseline specialized ranged unit; No Buffs; No Debuffs"

ToggleFightback:
    type: item
    material: diamond
    display name: "Fight Back"
    lore:
    - "Whether the NPC should fightback if provoked (True by default)"
    - "Current Status: <npc.flag[fightback]>"

ToggleRunaway:
    type: item
    material: brick
    display name: "Run away"
    lore:
    - "Whether the NPC should run away if it is engaged (False by default)"
    - "Current Status: <npc.flag[runaway]>"

ChaseClose:
    type: item
    material: bone_meal
    display name: "Chase in close-quarters"
    lore:
    - "Whether the NPC should initiate a chase when in close-quarters combat (True by default)"
    - "Current Status: <npc.flag[chaseclose]>"

SafeShot:
    type: item
    material: iron_chestplate
    display name: "Safeshot"
    lore:
    - "Whether the NPC should avoid collateral or not (I'm sure you care about the Geneva convention plenty)"
    - "Current Status: <npc.flag[safeshot]>"

AutoSwitch:
    type: item
    material: tripwire_hook
    display name: "Autoswitch"
    lore:
    - "Whether the NPC should automatically \n switch between items in their hotbar (True by default)"
    - "Current Status: <npc.flag[autoswitch]>"

Equip:
    type: item
    material: iron_sword
    display name: "Equip NPC"

SwitchWindow:
    type: item
    material: spectral_arrow
    display name: "Switch windows"
    lore:
    - "Switches to the commands window"

SoldierCreator:
    type: world
    events:
    
        # Can you spot the point where I fucking gave up?
    
        on player clicks ToggleFightback in SoldierTypeSelector:
        - execute as_server "npc sel <server.flag[NPCid]>"
        
        - if <npc[<server.flag[NPCid]>].flag[fightback].is[==].to[true]>:
            - flag <npc[<server.flag[NPCid]>]> fightback:false
        - else:
            - flag <npc[<server.flag[NPCid]>]> fightback:true
        
        - execute as_server "sentinel fightback <npc.flag[fightback]>"
        - inventory adjust destination:<context.inventory> slot:54 "lore:Whether the NPC should fightback if provoked (True by default)|Current Status: <npc[<server.flag[NPCid]>].flag[fightback]>"
        - determine cancelled
        
        on player clicks ToggleRunaway in SoldierTypeSelector:
        - execute as_server "npc sel <server.flag[NPCid]>"
        
        - if <npc[<server.flag[NPCid]>].flag[runaway].is[==].to[true]>:
            - flag <npc[<server.flag[NPCid]>]> runaway:false
        - else:
            - flag <npc[<server.flag[NPCid]>]> runaway:true
        
        - execute as_server "sentinel runaway <npc.flag[runaway]>"
        - inventory adjust destination:<context.inventory> slot:53 "lore:Whether the NPC should run away if it is engaged (False by default)|Current Status: <npc[<server.flag[NPCid]>].flag[runaway]>"
        - determine cancelled

        on player clicks ChaseClose in SoldierTypeSelector:
        - execute as_server "npc sel <server.flag[NPCid]>"
        
        - if <npc[<server.flag[NPCid]>].flag[chaseclose].is[==].to[true]>:
            - flag <npc[<server.flag[NPCid]>]> chaseclose:false
        - else:
            - flag <npc[<server.flag[NPCid]>]> chaseclose:true
        
        - execute as_server "sentinel chaseclose <npc.flag[chaseclose]>"
        - inventory adjust destination:<context.inventory> slot:52 "lore:Whether the NPC should initiate a chase when in close-quarters combat (True by default)|Current Status: <npc[<server.flag[NPCid]>].flag[chaseclose]>"
        - determine cancelled

        on player clicks SafeShot in SoldierTypeSelector:
        - execute as_server "npc sel <server.flag[NPCid]>"
        
        - if <npc[<server.flag[NPCid]>].flag[safeshot].is[==].to[true]>:
            - flag <npc[<server.flag[NPCid]>]> safeshot:false
        - else:
            - flag <npc[<server.flag[NPCid]>]> safeshot:true
        
        - execute as_server "sentinel safeshot <npc.flag[safeshot]>"
        - inventory adjust destination:<context.inventory> slot:51 "lore:Whether the NPC should avoid collateral or not (I'm sure you care about the Geneva convention plenty)|Current Status: <npc[<server.flag[NPCid]>].flag[safeshot]>"
        - determine cancelled

        on player clicks AutoSwitch in SoldierTypeSelector:
        - execute as_server "npc sel <server.flag[NPCid]>"
        
        - if <npc[<server.flag[NPCid]>].flag[autoswitch].is[==].to[true]>:
            - flag <npc[<server.flag[NPCid]>]> autoswitch:false
        - else:
            - flag <npc[<server.flag[NPCid]>]> autoswitch:true
        
        - execute as_server "sentinel autoswitch <npc.flag[autoswitch]>"
        - inventory adjust destination:<context.inventory> slot:50 "lore:Whether the NPC should automatically switch between items in their hotbar (True by default)|Current Status: <npc[<server.flag[NPCid]>].flag[autoswitch]>"
        - determine cancelled


        on player clicks Militia in SoldierTypeSelector:
        - execute as_server "npc select <server.flag[NPCid]>"
        - flag <npc[<server.flag[NPCid]>]> type:Militia
        
        - if <npc[<server.flag[NPCid]>].has_flag[squad]>:
            - execute as_server "npc rename <npc[<server.flag[NPCid]>].flag[squad]>:: <npc[<server.flag[NPCid]>].flag[kingdom]>:: <npc[<server.flag[NPCid]>].flag[type]>"
        - else:
            - execute as_server "npc rename <npc[<server.flag[NPCid]>].flag[kingdom]>:: <npc[<server.flag[NPCid]>].flag[type]>"

        - execute as_op "trait add sentinel"
        - execute as_server "sentinel invincible false"
        - execute as_server "sentinel realistic true"
        - execute as_server "sentinel respawn -1"
        
        - execute as_server "sentinel autoswitch true"
        - execute as_server "sentinel runaway false"
        - execute as_server "sentinel safeshot true"
        - execute as_server "sentinel fightback true"
        - execute as_server "sentinel chaseclose true"
        
        - execute as_server "sentinel attackrate 0.8"
        - execute as_server "sentinel reach 2"
        - execute as_server "sentinel accuracy 1.5"
        - execute as_server "sentinel damage -1"
        - execute as_server "sentinel projectilerange 15"
        - execute as_server "sentinel guardrange 15"
        - execute as_server "sentinel weapondamage stone_sword 5.75"
        - execute as_server "sentinel range 45"
        
        - if <player.has_flag[Callouts]>:
            - narrate format:callout "Note: Militia types recieve -50% debuff for guarding and achery"
        
        - determine cancelled
        
        on player clicks Conscript in SoldierTypeSelector:
        - execute as_server "npc select <server.flag[NPCid]>"
        - flag <npc[<server.flag[NPCid]>]> type:Conscript

        - if <npc[<server.flag[NPCid]>].has_flag[squad]>:
            - execute as_server "npc rename <npc[<server.flag[NPCid]>].flag[squad]>:: <npc[<server.flag[NPCid]>].flag[kingdom]>:: <npc[<server.flag[NPCid]>].flag[type]>"
        - else:
            - execute as_server "npc rename <npc[<server.flag[NPCid]>].flag[kingdom]>:: <npc[<server.flag[NPCid]>].flag[type]>"

        - execute as_op "trait add sentinel"
        - execute as_server "sentinel invincible false"
        - execute as_server "sentinel realistic true"
        - execute as_server "sentinel respawn -1"

        - execute as_server "sentinel autoswitch true"
        - execute as_server "sentinel safeshot true"
        - execute as_server "sentinel fightback true"
        - execute as_server "sentinel chaseclose false"
        - execute as_server "sentinel runaway false"

        - execute as_server "sentinel attackrate 0.35"
        - execute as_server "sentinel reach 3"
        - execute as_server "sentinel attackrate 0.65 ranged"
        - execute as_server "sentinel accuracy 1.2"
        - execute as_server "sentinel damage -1"
        - execute as_server "sentinel projectilerange 17"
        - execute as_server "sentinel guardrange 22.5"
        - execute as_server "sentinel weapondamage iron_sword 6.75"
        - execute as_server "sentinel range 60"

        - if <player.has_flag[Callouts]>:
            - narrate format:callout "Note: Conscript types recieve 25% debuff for guarding and achery"
        
        - determine cancelled
        
        on player clicks Archer in SoldierTypeSelector:
        - execute as_server "npc select <server.flag[NPCid]>"
        - flag <npc[<server.flag[NPCid]>]> type:Archer

        - if <npc[<server.flag[NPCid]>].has_flag[squad]>:
            - execute as_server "npc rename <npc[<server.flag[NPCid]>].flag[squad]>:: <npc[<server.flag[NPCid]>].flag[kingdom]>:: <npc[<server.flag[NPCid]>].flag[type]>"
        - else:
            - execute as_server "npc rename <npc[<server.flag[NPCid]>].flag[kingdom]>:: <npc[<server.flag[NPCid]>].flag[type]>"
        
        - execute as_op "trait add sentinel"
        - execute as_server "sentinel invincible false"
        - execute as_server "sentinel realistic true"
        - execute as_server "sentinel respawn -1"

        - execute as_server "sentinel autoswitch true"
        - execute as_server "sentinel safeshot true"
        - execute as_server "sentinel fightback true"
        - execute as_server "sentinel chaseclose true"
        - execute as_server "sentinel runaway false"
        
        - execute as_server "sentinel attackrate 0.45 ranged"
        - execute as_server "sentinel accuracy 0.2"
        - execute as_server "sentinel damage -1"
        - execute as_server "sentinel projectilerange 100"
        - execute as_server "sentinel range 20"
        - execute as_server "sentinel attackrate 0.5"
        - execute as_server "sentinel weapondamage iron_sword 3.5"
        - execute as_server "sentinel weapondamage diamond_sword 4"
        - execute as_server "sentinel weapondamage netherite_sword 4.5"
        - execute as_server "sentinel guardrange 22.5"
        
        - if <player.has_flag[Callouts]>:
            - narrate format:callout "Note: Archer types will recieve ~70% debuff for sword combat and 25% debuff for guarding"
        
        - determine cancelled
        
        on player clicks Equip in SoldierTypeSelector:
        - determine passively cancelled
        - inventory close d:in@SoldierTypeSelector
        - execute as_op "npc equip"
        
        - if <player.has_flag[Callouts]>:
            - narrate format:callout "Be sure to click the equip button again to exit equip mode!"
        
        on player clicks SwitchWindow in SoldierTypeSelector:
        - determine passively cancelled
        - inventory close d:in@SoldierTypeSelector
        - inventory open d:in@SoldierCommands

        - flag player ActiveWindow:SoldierCommands
        
        on player clicks SwitchWindow in SoldierCommands:
        - determine passively cancelled
        - inventory close d:in@SoldierCommands
        - inventory open d:in@SoldierTypeSelector

        - flag player ActiveWindow:SoldierCreate
        
        on player right clicks npc:
        - if <player.has_flag[SoldierCreate]>:
            - inventory open d:in@SoldierTypeSelector
            
            - flag npc fightback:true
            - flag npc runaway:false
            - flag npc autoswitch:true
            - flag npc chasclose:false
            - flag npc safeshot:true
        
        - flag server NPCid:<npc.id>


        