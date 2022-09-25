MerchantAssignment:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true
    interact scripts:
    - npc_killquest_interact

MerchantInteract:
    type: interact
    steps:
        1:
            click trigger:
            - inventory open d:in@MerchantGUI

MerchantConfig:
    type: command
    usage: /merchant <&lt>config<&gt>
    name: merchant
    description: Enters you into config mode for Merchant NPCs
    script:
    - if <player.is_op>:
        - if <context.raw_args> == "config":
            - if <player.has_flag[Callouts]>:
                - narrate format:callout "Please select an NPC to configure into a merchant"
            - if <player.has_flag[MerchantCreate]>:
                - flag player MerchantCreate:!
                - narrate format:callout "Exited Merchant Creator"
            - else:
                - flag player MerchantCreate
    - else:
        - narrate "You are not permitted to use this command"

MerchantConfigGUI:
    type: inventory
    title: "Merchant Config"
    size: 27
    slots:
    - "[i@FoodMerchant] [i@ResourceMerchant] [i@ToolMerchant] [i@WeaponMerchant] [] [] [] [] []"
    - "[] [] [] [] [] [] [] [] []"
    - "[] [] [] [] [] [] [] [] [i@DeleteMerchant]"

FoodMerchant:
    type: item
    material: cooked_beef
    display name: "Food Merchant / Butcher"
    
ResourceMerchant:
    type: item
    material: diamond
    display name: "Resource Merchant / Miner"
    
ToolMerchant:
    type: item
    material: iron_pickaxe
    display name: "Tool Merchant / Blacksmith"
    
WeaponMerchant:
    type: item
    material: iron_sword
    display name: "Weapon Merchant / Weaponsmith"

DeleteMerchant:
    type: item
    material: barrier
    display name: "Delete Merchant"

GUITest:
    type: task
    script:
        - foreach <s@MerchantItemData.yaml_key[Butcher].keys> as:item:
            - narrate <[value]>
            #- narrate <[key]>

MerchantGUI:
    type: inventory
    title: "Merchant"
    size: 54
    procedural items:
        - foreach <s@MerchantItemData.yaml_key[Butcher].keys>:
            - define names:->:<[value]>
        - foreach <s@MerchantItemData.yaml_key[Butcher].values>:
            - define chances:->:<[value]>
        
        - foreach <definition[names]>:
            - define chance <definition[chances].get[<[loop_index]>]>

            - if <util.random.int[0].to[1]> <= <definition[chance]>:
                - define price <definition[chance].mul[100].div[2]>
                - define thing <item[<[value]>]>[lore=<definition[chance]>|<definition[price]>]
                - define list:->:<definition[thing]>
                - narrate "-- <definition[price]>"
            - else:
                - take material:<[value]> from:in@MerchantGUI
        
        - determine <[list]>
        
    slots:
    - "[] [] [] [] [] [] [] [] []"
    - "[] [] [] [] [] [] [] [] []"
    - "[] [] [] [] [] [] [] [] []"
    - "[] [] [] [] [] [] [] [] []"
    - "[] [] [] [] [] [] [] [] []"
    - "[] [i@Accept] [] [] [] [] [] [i@Reject] []"

MerchantGUIHandler:
    type: world
    events:
        on player right clicks npc:
        - if <player.has_flag[MerchantCreate]>:
            - assignment set script:MerchantInteract
            - inventory open d:in@MerchantConfigGUI
            - flag server NPCid:<npc.id>
            - execute as_server "npc select <server.flag[NPCid]>"

        on player clicks in MerchantGUI:
        - if <context.item> != "i@air":
            - if <context.slot> <= 45:
                - narrate <context.item.lore>
        
        on player clicks DeleteMerchant in MerchantConfigGUI:
        - execute as_server "npc remove"
        - determine cancelled
        
        on player closes MerchantConfigGUI:
        - flag server NPCid:!

Accept:
    type: item
    material: green_wool
    display name: "<&3>Confirm Selection"

Reject:
    type: item
    material: red_wool
    display name: "<&4>Cancel Selection"