##ignorewarning invalid_data_line_quotes

########################
## THIS FILE IS INDEV ##
########################

## VERSION NUMBERS / GENERAL METADATA DO NOT EXIST FOR INDEV MODULES!

SquadCommand:
    type: command
    name: squad
    usage: /squad list|create ...|name ...|?display name
    description: "Brings up the squad selection window"
    permission: kingdoms.squads
    tab completions:
        1: list|create

    tab complete:
    - define args <context.raw_args.split_args>

    - choose <[args].get[1].if_null[null]>:
        - case create:
            - choose <[args].size>:
                - case 1:
                    - determine <list[[name]]>
                - case 2:
                    - determine <list[?[display_name]]>

    script:
    - define args <context.raw_args.split_args>

    - if <[args].get[1]> == list:
        - run SquadSelectionGUI

    - if <[args].get[1]> == create:
        # Checks if player is not already in squad mode #
        - if <player.has_flag[inventoryHold]>:
            - narrate format:callout "You are already in squad creation mode!"
            - determine cancelled

        # Checks if the player specifies a squad name #
        - if <[args].size.is[LESS].than[2]>:
            - narrate format:callout "You must specify a squad name."
            - determine cancelled

        - define kingdom <player.flag[kingdom]>
        - define internalSquadName <[args].get[2]>
        - define displaySquadName <[args].get[3]>

        # Checks for identical squad name #
        - if <server.has_flag[armies.<[kingdom]>.squads.<[internalSquadName]>]>:
            - narrate format:callout "There already exists a squad by this name."
            - determine cancelled

        # Creates a temporary flag for player inventory holding and assigns squad name
        # to a flag of its own.
        - flag <player> inventoryHold:<list>
        - flag <player> squadName:<[args].get[2]>

        # Copies the player's current inventory into a temporary holding flag
        # while also clearing it.
        - repeat 36:
            - flag <player> inventoryHold:->:<player.inventory.slot[<[value]>]>
            - inventory set slot:<[value]> origin:<item[air]>

        - inventory set slot:1 origin:<item[NPCSelectWand]>
        - inventory set slot:9 origin:<item[NPCSelectExit]>

        - flag server armies.<[kingdom]>.squads.<[internalSquadName]>.displayName:<[displaySquadName]> if:<[displaySquadName].exists>

    # DEV COMMAND - Restores player inventory as kept in 'inventoryHold' flag - bypasses conditions #
    - if <context.args.get[1]> == DEBUG_inv_restore:
        - if <player.has_permission[kingdoms.admin.squads.debug]> || <player.has_permission[kingdoms.admin.debug]>:
            - repeat 36:
                - inventory set slot:<[value]> origin:<player.flag[inventoryHold].get[<[value]>]>

        - flag <player> inventoryHold:!

        - else:
            - narrate format:callout "Debug commands are not made available to players"


SquadInterface_Item:
    type: item
    material: player_head
    display name: "<gold><bold>Squad"
    mechanisms:
        skull_skin: 67f11d3f-bd61-4dcf-9675-d0b8919bcad2|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDZjYzZiODM3NjNhNjdmY2FkYTFlYTE4NGMyZDE3NTJhZDI0MDc0NmM2YmUyNThhNzM5ODNkOGI2NTdmNGJiNSJ9fX0=


SquadSelectionGUI:
    type: task
    script:
    - define kingdom <player.flag[kingdom]>
    - define squadList <server.flag[armies.<[kingdom]>.squads].keys>
    - define itemList <list[]>

    - if <server.flag[armies.<[kingdom]>.squads].keys.size.if_null[0]> == 0:
        - run PaginatedInterface def.itemList:<list[]> def.page:1 def.player:<player> def.title:Squads
        - determine cancelled

    - foreach <[squadList]> as:squadName:
        - define squadItem <item[SquadInterface_Item]>
        - define squad <server.flag[armies.<[kingdom]>.squads.<[squadName]>]>
        - define name <[squadName]>

        - if <[squad].contains[displayName]>:
            - define name <[squad].get[displayName]>

        - adjust def:squadItem display:<gold><bold><[name]>

        - define npcListShort <[squad].get[npcList].get[1].to[4]>

        - if <[npcListShort].size> < <[squad].get[npcList]>:
            - define remainingNpcNumber <[squad].get[npcList].size.sub[<[npcListShort].size>]>
            - define npcListShort:->:<element[And <[remainingNpcNumber]> Others...].color[gray]>

        - adjust def:squadItem lore:<[npcListShort].separated_by[<n>]>

        - definemap squadInfo:
            internalName: <[squadName]>
            displayName: <[name]>
            npcList: <[squad].get[npcList]>

        - flag <[squadItem]> squadInfo:<[squadInfo]>
        - define itemList:->:<[squadItem]>

    - run PaginatedInterface def.itemList:<[itemList]> def.page:1 def.player:<player> def.title:Squads def.flag:viewingSquads


SquadSelection_Handler:
    type: world
    events:
        on player clicks SquadInterface_Item in PaginatedInterface_Window flagged:viewingSquads:
        - flag <player> datahold.squadInfo:<context.item.flag[squadInfo]>
        - inventory open d:SquadEditConfirm_Window

        on player clicks SquadEditConfirm_Item in SquadEditConfirm_Window:
        - inventory close
        - run TempSaveInventory def.player:<player>
        - give SquadMoveTool_Item
        - inventory set slot:9 origin:ExitSquadControls_Item
        - adjust <player> item_slot:1

        on player clicks SquadEditReject_Item in SquadEditConfirm_Window:
        - run SquadSelectionGUI

        on player clicks block with:ExitSquadControls_Item:
        - flag <player> datahold.squadInfo:!
        - run LoadTempInventory def.player:<player>


SquadEditConfirm_Item:
    type: item
    material: green_wool
    display name: <green>Edit Squad


SquadEditReject_Item:
    type: item
    material: red_wool
    display name: <red>Cancel


SquadEditConfirm_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Confirm Editing Squad
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [SquadEditConfirm_Item] [] [SquadEditReject_Item] [] [] []
    - [] [] [] [] [] [] [] [] []


SquadOrders_Handler:
    type: world
    events:
        on player right clicks block with:SquadMoveTool_Item:
        - ratelimit <player> 1s
        - define kingdom <player.flag[kingdom]>
        - define location <player.cursor_on_solid[50]>
        - define squadInfo <player.flag[datahold.squadInfo]>
        - define squadName <[squadInfo].get[internalName]>
        - define npcList <[squadInfo].get[npcList]>
        - define displayName <[squadInfo].get[displayName]>

        - narrate format:debug LOC:<[location]>
        - narrate format:debug SQD:<[squadInfo]>

        #- showfake red_stained_glass <[location]> d:10s
        #- run FormationWalkThree def.npcList:<[npcList]> def.squadLeader:<npc[385]> def.npcsPerRow:3 def.finalLocation:<[location]>
        - run FormationWalkFour_ALT def.npcList:<[npcList]> def.squadLeader:<npc[385]> def.npcsPerRow:3 def.finalLocation:<[location].with_yaw[<player.location.yaw.round_to_precision[5]>]> def.lineLength:6 def.player:<player>


SquadMoveTool_Item:
    type: item
    material: blaze_rod
    display name: <gold><bold>Move Order
    enchantments:
    - sharpness:1
    mechanisms:
        hides: enchants


ExitSquadControls_Item:
    type: item
    material: barrier
    display name: <red>Exit Squad Controls


NPCSelectWand:
    type: item
    material: feather
    display name: "NPC Selector"


NPCSelectExit:
    type: item
    material: barrier
    display name: "Exit"


NPCSelectHandler:
    type: world
    debug: false
    events:
        on player clicks block with:NPCSelectExit:
        - repeat 36:
            - inventory set slot:<[value]> origin:<player.flag[inventoryHold].get[<[value]>]>

        - flag <player> inventoryHold:!
        - flag <player> squadName:!

        - determine cancelled

        on player right clicks npc with:NPCSelectWand flagged:inventoryHold:
        - ratelimit <player> 2t

        - define kingdom <player.flag[kingdom]>
        - define squadName <player.flag[squadName]>

        - if <context.entity.entity_type> == PLAYER && <context.entity.id.exists>:
            - if !<server.flag[armies.<[kingdom]>.squads.<[squadName]>.npcList].contains[<context.entity>].if_null[false]>:
                - flag server armies.<[kingdom]>.squads.<[squadName]>.npcList:->:<context.entity>
                - actionbar "Added to squad"

            - else:
                - actionbar "NPC already in squad"

        on player drops item flagged:inventoryHold:
        - determine cancelled