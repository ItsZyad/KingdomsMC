SoldierCommands:
    type: inventory
    title: "Soldier Commands"
    inventory: chest
    slots:
    - "[WhoAttack] [] [] [] [] [] [] [] []"
    - "[LocationOrders] [FollowPlayer] [IgnoreWhenWalk] [] [] [] [] [] []"
    - "[AnchorPoint] [] [] [] [] [] [] [] []"
    - "[AddToSquad] [SquadFollow] [SquadAttack] [] [] [] [] [] []"
    - "[] [] [] [] [] [] [] [] [SwitchWindow]"
    - "[] [] [] [] [] [] [] [] [Exit]"

WhoAttack:
    type: item
    material: iron_sword
    display name: "Attack Orders"

PlayerOrNPC:
    type: item
    material: creeper_head
    display name: "Attack Players or NPCs?"

LocationOrders:
    type: item
    material: map
    display name: "Location Orders"

IgnoreWhenWalk:
    type: item
    material: iron_leggings
    display name: "Ignore Enemies While Walking"
    lore:
    - "When this is set to true the Soldier will ignore enemies whilst making their way to a location order"
    - "Current Status: true"

AnchorPoint:
    type: item
    material: slime_ball
    display name: "Anchor Point"
    lore:
    - "The point an NPC should return to when idle (preferably only use with archers)"

AddToSquad:
    type: item
    material: bone
    display name: "Add To Squad"
    lore:
    - "A squad is a group of NPCs who all have the same target and follow the same commands"

SquadFollow:
    type: item
    material: arrow
    display name: "Squad Follow Player"

FollowPlayer:
    type: item
    material: bone_meal
    display name: "NPC Follow Player"

Exit:
    type: item
    material: barrier
    display name: "Exit"

WhoAttack_Window:
    type: inventory
    title: "Attack Orders"
    inventory: chest
    slots:
    - "[] [] [] [] [] [] [] [] []"
    - "[] [Centra] [] [Cambrian] [] [Viriditas] [] [Raptores] []"
    - "[] [] [Player] [] [NPC] [] [Both] [] []"

##### START WhoAttack ITEMS ######

Centra:
    type: item
    material: cyan_wool
    display name: "Centra Australis"

Cambrian:
    type: item
    material: orange_wool
    display name: "Cambrian Empire"

Viriditas:
    type: item
    material: green_wool
    display name: "Kingdom Of Viriditas"

Raptores:
    type: item
    material: red_wool
    display name: "Dynastus Raptores"

Player:
    type: item
    material: player_head
    display: "Attack Only Players"

NPC:
    type: item
    material: zombie_head
    display name: "Attack Only NPCs"

Both:
    type: item
    material: skeleton_head
    display name: "Attack Both"

##### END WhoAttack ITEMS #####

WhoAttackHandler:
    type: world
    events:
        on player clicks item in WhoAttack_Window:
        - determine passively cancelled
        - inventory close d:WhoAttack_Window
        - inventory open d:SoldierCommands

        on player clicks Centra in WhoAttack_Window:
        - execute as_op ""

SoldierCommandHandler:
    type: world
    events:
        on player right clicks npc:
        - if <player.has_flag[SoldierCommands]>:
            - inventory open d:SoldierCommands

        on sentinel npc attacks:
        - if <npc.has_flag[follow]>:
            - follow followers:<npc[<server.flag[NPCid]>]> target:<player> lead:4

        on player drags in SoldierCommands:
        - determine cancelled

        on player clicks Exit in inventory:
        - inventory close

        - flag player ActiveWindow:!

        on player clicks LocationOrders in SoldierCommands:
        - flag player ActiveCommand:LocationOrder
        - if <player.has_flag[Callouts]>:
            - narrate format:callout "Enter a location in the format: '(xpos),(ypos),(zpos)'"
        - inventory close d:SoldierCommands
        - determine cancelled

        on player clicks FollowPlayer in SoldierCommands:
        - if <npc[<server.flag[NPCid]>].has_flag[follow]>:
            - follow followers:<npc[<server.flag[NPCid]>]> target:<player> stop
            - flag <npc[<server.flag[NPCid]>]> follow:!
        - else:
            - follow followers:<npc[<server.flag[NPCid]>]> target:<player> lead:4
            - flag <npc[<server.flag[NPCid]>]> follow

        - determine cancelled

        on player clicks WhoAttack in SoldierCommands:
        - determine passively cancelled
        - inventory close d:SoldierCommands
        - inventory open d:WhoAttack_Window

        on player clicks AddToSquad in SoldierCommands:
        - flag player ActiveCommand:AddSquad
        - if <player.has_flag[Callouts]>:
            - narrate format:callout "Enter the squad name you would like to add the NPC to (If the squad already exists it will add the NPC to it)"
        - inventory close d:SoldierCommands
        - determine cancelled

        on player clicks SquadFollow in SoldierCommands:
        - if <npc[<server.flag[NPCid]>].has_flag[SquadFollow]>:
            - follow followers:<yaml[squads].read[<npc[<server.flag[NPCid]>].flag[kingdom]>.<npc[<server.flag[NPCid]>].flag[squad]>]>
            - flag <npc[<server.flag[NPCid]>]> SquadFollow:!
        - else:
            - follow stop
            - flag <npc[<server.flag[NPCid]>]> SquadFollow

        - determine cancelled

        on player chats:
        - if <player.flag[ActiveCommand]> == LocationOrder:
            - define LocationOrder <context.message.split[,]>
            - if <context.message> != mypos:
                - if <definition[LocationOrder].size> != 3:
                    - narrate format:callout "Please follow the format"
                    - stop
                - else:
                    - walk <npc[<server.flag[NPCid]>]> <context.message>,0,<npc[<server.flag[NPCid]>].body_yaw>,kingdomsutd auto_range
                    - flag player ActiveCommand:!
            - else:
                - walk <npc[<server.flag[NPCid]>]> <player.location> auto_range

            - determine cancelled

        - else if <player.flag[ActiveCommand]> == AddSquad:
            - yaml load:squads.yml id:squads
            - define soldier <server.flag[NPCid]>

            - if <npc[<server.flag[NPCid]>].has_flag[squad]>:
                - yaml id:squads set <yaml[squads].read[<definition[soldier].flag[kingdom]>.<definition[soldier].flag[squad]>]>:!

            - flag <npc[<server.flag[NPCid]>]> squad:<context.message>
            - flag player ActiveCommand:!

            - define found false

            - foreach <yaml[squads].read[<player.flag[kingdom]>.<context.message>]>:
                - if <[value]> == <npc[<server.flag[NPCid]>]>:
                    - define found:true

            - narrate <definition[found]>

            - if !<definition[found]>:
                - yaml id:squads set <player.flag[kingdom]>.<context.message>:->:<npc[<server.flag[NPCid]>]>
                - flag <npc[<server.flag[NPCid]>]> squad:<context.message>

            - ~yaml savefile:squads.yml id:squads
            - yaml unload id:squads

            - execute as_server "npc rename <npc[<server.flag[NPCid]>].flag[squad]>:: <npc[<server.flag[NPCid]>].flag[kingdom]>:: <npc[<server.flag[NPCid]>].flag[type]>"

            - determine passively cancelled