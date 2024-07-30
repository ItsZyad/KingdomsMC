##
## Scripts related to the squad list window in the SM are here.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Sep 2022
## @Updated: Jul 2023
## @Script Ver: v2.0
##
##ignorewarning invalid_data_line_quotes
## ------------------------------------------END HEADER-------------------------------------------

SquadCommand:
    type: command
    name: squad
    usage: /squad list
    description: "Brings up the squad selection window"
    permission: kingdoms.squads
    script:
    - define args <context.raw_args.split_args>

    - if <[args].get[1]> == list:
        - run SquadSelectionGUI


ExitSquadSelector_Item:
    type: item
    material: barrier
    display name: <red><bold>Back


SquadInterfaceFooter_Inventory:
    type: inventory
    inventory: chest
    slots:
    - [] [] [] [] [ExitSquadSelector_Item] [] [] [] []


SquadInterface_Item:
    type: item
    material: player_head
    display name: "<gold><bold>Squad"
    mechanisms:
        skull_skin: 67f11d3f-bd61-4dcf-9675-d0b8919bcad2|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDZjYzZiODM3NjNhNjdmY2FkYTFlYTE4NGMyZDE3NTJhZDI0MDc0NmM2YmUyNThhNzM5ODNkOGI2NTdmNGJiNSJ9fX0=


SquadSelectionGUI:
    type: task
    debug: false
    definitions: player[PlayerTag]
    description:
    - Opens the squad selection interface, accessible through the squad manager for the provided player.
    - ---
    - → [Void]

    script:
    ## Opens the squad selection interface, accessible through the squad manager for the provided
    ## player.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [Void]

    - define __player <[player]>
    - define kingdom <player.flag[kingdom]>
    - define squadList <proc[GetKingdomSquads].context[<[kingdom]>].keys.if_null[<list[]>]>
    - define itemList <list[]>

    - if <[squadList].size.if_null[0]> == 0:
        - run PaginatedInterface def.itemList:<list[]> def.page:1 def.player:<player> def.title:Squads def.footer:<inventory[SquadInterfaceFooter_Inventory]> def.flag:viewingSquads
        - determine cancelled

    - foreach <[squadList]> as:squadName:
        - define squadItem <item[SquadInterface_Item]>
        - define squad <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>
        - define displayName <proc[GetSquadDisplayName].context[<[kingdom]>|<[squadName]>]>

        - adjust def:squadItem display:<gold><bold><[displayName]>

        - if <proc[HasSquadSpawned].context[<[kingdom]>|<[squadName]>]>:
            - define npcList <proc[GetSquadNPCs].context[<[kingdom]>|<[squadName]>]>
            - define npcListShort <[npcList].get[1].to[4].if_null[<list[]>]>
            - define npcListShort <[npcListShort].include[<proc[GetSquadLeader].context[<[kingdom]>|<[squadName]>]>]>

            - if <[npcListShort].size> < <[npcList].size>:
                - define remainingNpcNumber <[npcList].size.sub[<[npcListShort].size>]>
                - define npcListShort:->:<element[And <[remainingNpcNumber]> Others...].color[gray]>

            - adjust def:squadItem lore:<[npcListShort].separated_by[<n>]>

        - else:
            - adjust def:squadItem "lore:<gray>Squad Not Spawned Yet."

        - definemap squadInfo:
            internalName: <[squadName]>
            displayName: <[displayName]>
            npcList: <[npcList].if_null[<list[]>]>

        - flag <[squadItem]> squadInfo:<[squadInfo]>
        - define itemList:->:<[squadItem]>

    - run PaginatedInterface def.itemList:<[itemList]> def.page:1 def.player:<player> def.footer:<inventory[SquadInterfaceFooter_Inventory]> def.title:Squads def.flag:viewingSquads


SquadFirstSpawnInfo_Item:
    type: item
    material: player_head
    display name: <white><bold>Spawn Squad For First Time?
    mechanisms:
        skull_skin: da4d885d-2505-4f25-bfee-a0de07950191|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDAxYWZlOTczYzU0ODJmZGM3MWU2YWExMDY5ODgzM2M3OWM0MzdmMjEzMDhlYTlhMWEwOTU3NDZlYzI3NGEwZiJ9fX0=
    lore:
    - This squad has been created but not
    - spawned yet. Do you want to spawn it?


SquadConfirm_Item:
    type: item
    material: green_wool
    display name: <dark_green><bold>Confirm


SquadReject_Item:
    type: item
    material: red_wool
    display name: <red><bold>Cancel


SquadDelete_Item:
    type: item
    material: barrier
    display name: <red><bold><underline>Delete Squad


SquadFirstTimeSpawnConfirmation_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Squad First Time Spawn
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [SquadFirstSpawnInfo_Item] [] [] [] []
    - [] [] [SquadConfirm_Item] [] [] [] [SquadReject_Item] [] []
    - [] [] [] [] [SquadDelete_Item] [] [] [] []
    - [] [] [] [] [] [] [] [] []


SquadEquipmentSet_Item:
    type: item
    material: player_head
    display name: <yellow><bold>Set Squad Equipment
    mechanisms:
        skull_skin: c11efdef-80c0-4909-8d8c-a6951fc28c47|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvN2I5MjRiMzdmZTMyOTQyNzNhNzQzODZjODc4Y2EyMTBmYzg5ZjQ3ODcwMjk0M2EwMjcyZTcxMzk1NjMwYmVkYSJ9fX0=


SquadOrders_Item:
    type: item
    material: player_head
    display name: <light_purple><bold>Give Squad Orders
    mechanisms:
        skull_skin: 99d1db69-a107-4227-b575-cb40c9f37092|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYTVkNzZkOTBiMzc4MDgzZDE0Nzc1NjgwNTA1ZGRiMWU2YzJjNmRjZjRkZGU3ZjliMWY1ODgwOWJlYzZjNjVjOCJ9fX0=


SquadRename_Item:
    type: item
    material: name_tag
    display name: <white><bold>Rename Squad


SquadOptions_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Squad Options
    slots:
    - [InterfaceFiller_Item] [InterfaceFiller_Item] [] [] [] [] [] [InterfaceFiller_Item] [InterfaceFiller_Item]
    - [InterfaceFiller_Item] [InterfaceFiller_Item] [SquadOrders_Item] [] [SquadRename_Item] [] [SquadEquipmentSet_Item] [InterfaceFiller_Item] [InterfaceFiller_Item]
    - [InterfaceFiller_Item] [InterfaceFiller_Item] [] [] [SquadDelete_Item] [] [] [InterfaceFiller_Item] [InterfaceFiller_Item]
    - [InterfaceFiller_Item] [InterfaceFiller_Item] [] [] [Back_Item] [] [] [InterfaceFiller_Item] [InterfaceFiller_Item]


SquadEquipment_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Squad Equipment
    slots:
    - [InterfaceFiller_Item] [leather_helmet] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item]
    - [InterfaceFiller_Item] [leather_chestplate] [InterfaceFiller_Item] [] [] [] [] [] [InterfaceFiller_Item]
    - [InterfaceFiller_Item] [leather_leggings] [InterfaceFiller_Item] [] [] [] [] [InterfaceFiller_Item] [InterfaceFiller_Item]
    - [InterfaceFiller_Item] [leather_boots] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item]


SquadSelection_Handler:
    type: world
    debug: false
    events:
        ## CLICK SQUAD LIST ICON
        on player clicks SquadInterface_Item in PaginatedInterface_Window flagged:viewingSquads:
        - inventory open d:SquadOptions_Window
        - flag <player> datahold.armies.squadInfo:<context.item.flag[squadInfo]>

        ## CLICK SQUAD ORDERS
        on player clicks SquadOrders_Item in SquadOptions_Window:
        - define kingdom <player.flag[kingdom]>
        - define squadName <player.flag[datahold.armies.squadInfo.internalName]>
        - define hasSpawned <proc[HasSquadSpawned].context[<[kingdom]>|<[squadName]>]>

        - if <[hasSpawned]>:
            - define npcList <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.npcList]>
            - define squadLeader <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>.squadLeader]>
            - define currentlySpawned <[squadLeader].as[npc].is_spawned>

            - if <[currentlySpawned]>:
                - flag <player> datahold.squadInfo:<server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>
                - run GiveSquadTools def.player:<player>
                - inventory close

            - else:
                - define spawnLocation 0
                - define SMLocation <player.flag[datahold.armies.SquadManagerLocation]>
                - inject SpawnSquadNPCs path:FindSpacesAroundSM

                - if <[spawnLocation]> != 0:
                    - flag <player> datahold.squadInfo:<server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadName]>]>

                    # TODO: Unfuck this.
                    - run GiveSquadTools def.player:<player>

                    - spawn <[npcList].include[<[squadLeader]>]> <[spawnLocation]>

                - else:
                    - narrate format:debug "<red>[Internal Error SQA112] <&gt><&gt> <gold>Cannot generate SMLocation from squad reference."

                - inventory close

        - else:
            - inventory open d:SquadFirstTimeSpawnConfirmation_Window
            # - flag <player> datahold.armies.squadInfo:<context.item.flag[squadInfo]>

        ## CLICK SQUAD DELETE
        on player clicks SquadDelete_Item in SquadOptions_Window:
        - inventory open d:SquadDeleteConfirmation_Window

        ## CLICK SQUAD RENAME
        on player clicks SquadRename_Item in SquadOptions_Window:
        - flag <player> noChat.armies.renamingSquad
        - narrate format:callout "Type the squad's new name here, or type 'cancel' (you can use spaces):"
        - inventory close

        ## PLAYER TYPES NEW SQUAD NAME
        on player chats flagged:noChat.armies.renamingSquad:
        - if <context.message.to_lowercase> == cancel:
            - narrate format:callout "Cancelled squad renaming."

        - else:
            - define kingdom <player.flag[kingdom]>
            - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
            - define squadName <player.flag[datahold.armies.squadInfo.internalName]>

            - run RenameSquad def.kingdom:<[kingdom]> def.squadName:<[squadName]> def.newName:<context.message> def.SMLocation:<[SMLocation]> save:rename
            - define renameSuccessful <entry[rename].created_queue.determination.get[1]>
            # - define squadInfo <[SMLocation].flag[squadManager.squads.squadList.<[squadName]>]>
            # - define squadInfo <[squadInfo].with[name].as[<[newInternalName]>].with[displayName].as[<context.message>]>

            # - flag <[SMLocation]> squadManager.squads.squadList.<[newInternalName]>:<[squadInfo]>
            # - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>:!

            # - run WriteArmyDataToKingdom def.kingdom:<[kingdom]> def.SMLocation:<[SMLocation]>

            - if <[renameSuccessful]>:
                - narrate format:callout "Renamed <[squadName].replace[-].with[ ].color[gray]> to: <context.message.color[red]>."

            - else:
                - narrate format:callout "An error occurred. Cannot rename squad."

        - flag <player> noChat.armies.renamingSquad:!
        - determine cancelled

        ## EQUIPMENT WINDOW SETUP
        on player opens SquadEquipment_Window:
        - define leatherItems <context.inventory.find_all_items[leather_*]>

        - if !<[leatherItems].is_empty>:
            - define kingdom <player.flag[kingdom]>
            - define kingdomColor <proc[GetKingdomColor].context[<[kingdom]>]>
            - define squadManagerData <player.flag[datahold.armies.squadManagerData]>

            #- IMPORTANT: If you do follow through on making default equipment customizable then
            #-            you will need to add a line under the inventory adjust that changes that
            #-            in the interface.

            - foreach <[leatherItems]> as:slot:
                - inventory adjust slot:<[slot]> color:<[kingdomColor]> d:<context.inventory>

        - define squadName <player.flag[datahold.armies.squadInfo.internalName]>
        - define hotbarSlots <context.inventory.list_contents.parse_tag[<[parse_value].material.name>].find_all[air]>
        - define armorSlots <context.inventory.list_contents.parse_tag[<[parse_value].material.name>].find_all_matches[*_boots|*_leggings|*_chestplate|*_helmet]>
        # - define hotbarItems <[squadManagerData].deep_get[squads.squadList.<[squadName]>.standardEquipment.hotbar].if_null[<list[]>]>
        - define hotbarItems <proc[GetSquadEquipment].context[<[kingdom]>|<[squadName]>].get[hotbar]>
        - flag <player> datahold.hotbarSlots:<[hotbarSlots]>
        - flag <player> datahold.armorSlots:<[armorSlots]>

        - foreach <[hotbarItems]> as:item:
            - inventory set slot:<[hotbarSlots].get[<[loop_index]>]> origin:<[item]> d:<context.inventory>

        ## ADD ITEM IN EQUIPMENT WINDOW
        on player left clicks item in SquadEquipment_Window:
        - ratelimit <player> 1t
        - define hotbarSlots <player.flag[datahold.hotbarSlots]>
        - define armorSlots <player.flag[datahold.armorSlots]>

        - if <[hotbarSlots].contains[<context.slot>]>:
            - define cursorItem <context.cursor_item>
            - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
            - define kingdom <player.flag[kingdom]>
            - define squadName <player.flag[datahold.armies.squadInfo.internalName]>

            - inventory set d:<context.inventory> origin:<context.cursor_item> slot:<context.slot>
            # - define hotbarItems <[SMLocation].flag[squadManager.standardEquipment.hotbar].if_null[<list[]>]>
            - define hotbarItems <proc[GetSquadEquipment].context[<[kingdom]>|<[squadName]>].get[hotbar]>
            - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.standardEquipment.hotbar:<[hotbarItems].remove[<[hotbarSlots].find[<context.slot>]>].include[<context.cursor_item>]>
            - run WriteArmyDataToKingdom def.SMLocation:<[SMLocation]> def.kingdom:<[kingdom]>

        - else if <[armorSlots].contains[<context.slot>]>:
            - define cursorItem <context.cursor_item>
            - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
            - define squadName <player.flag[datahold.armies.squadInfo.internalName]>
            - define armorType <context.item.material.name.split[_].get[2]>
            - define cursorItemType <context.item.material.name.split[_].get[2]>

            - if <[cursorItemType]> == <[armorType]>:
                - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.standardEquipment.<[armorType]>:<[cursorItem]>
                - inventory set d:<context.inventory> origin:<[cursorItem]> slot:<context.slot>

        ## REMOVE ITEM IN EQUIPMENT WINDOW
        on player right clicks item in SquadEquipment_Window:
        - ratelimit <player> 1t
        - define hotbarSlots <player.flag[datahold.hotbarSlots]>
        - define armorSlots <player.flag[datahold.armorSlots]>

        - if <[hotbarSlots].contains[<context.slot>]>:
            - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
            - define squadName <player.flag[datahold.armies.squadInfo.internalName]>
            - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.standardEquipment.hotbar:<-:<context.item>

            - inventory set d:<context.inventory> origin:air slot:<context.slot>

        - else if <[armorSlots].contains[<context.slot>]>:
            - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
            - define squadName <player.flag[datahold.armies.squadInfo.internalName]>
            - define armorType <context.item.material.name.split[_].get[2]>
            - inventory set d:<context.inventory> origin:air slot:<context.slot>

            - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.standardEquipment.<[armorType]>:<item[air]>

        ## CLOSES EQUIPMENT WINDOW
        on player closes SquadEquipment_Window:
        - flag <player> datahold.hotbarSlots:!

        ## CLICKS SQUAD EQUIPMENT
        on player clicks SquadEquipmentSet_Item in SquadOptions_Window:
        - inventory open d:SquadEquipment_Window

        ## EXITS SQUAD OPTIONS
        on player clicks Back_Item in SquadOptions_Window:
        - run SquadSelectionGUI def.player:<player>

        ## EXITS SQUAD LIST
        on player clicks ExitSquadSelector_Item in PaginatedInterface_Window flagged:viewingSquads:
        - if <player.has_flag[datahold.armies]>:
            - inventory open d:SquadManager_Interface

        - else:
            - inventory close

        ## SPAWN FIRST TIME
        on player clicks SquadConfirm_Item in SquadFirstTimeSpawnConfirmation_Window:
        - define squadInfo <player.flag[datahold.armies.squadInfo]>
        - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>

        - run SpawnSquadNPCs def.atManager:true def.SMLocation:<[SMLocation]> def.squadName:<[squadInfo].get[internalName]> def.player:<player>

        - inventory close

        ## DELETE FIRST TIME
        on player clicks SquadDelete_Item in SquadFirstTimeSpawnConfirmation_Window:
        - inventory open d:SquadDeleteConfirmation_Window


SquadDeleteConfirmation_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Delete Squad?
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [SquadConfirm_Item] [] [] [] [SquadReject_Item] [] []
    - [] [] [] [] [] [] [] [] []


SquadDeletion_Handler:
    type: world
    debug: false
    events:
        on player clicks SquadConfirm_Item in SquadDeleteConfirmation_Window:
        - define squadInfo <player.flag[datahold.armies.squadInfo]>
        - define SMLocation <player.flag[datahold.armies.squadManagerLocation]>
        - define kingdom <player.flag[kingdom]>

        - narrate format:callout "Deleted squad with name: <server.flag[kingdoms.<[kingdom]>.armies.squads.squadList.<[squadInfo].get[internalName]>.displayName].color[red]>"

        - run DeleteSquad def.SMLocation:<[SMLocation]> def.kingdom:<[kingdom]> def.squadName:<[squadInfo].get[internalName]>
        - run SquadSelectionGUI def.player:<player>

        on player clicks SquadReject_Item in SquadDeleteConfirmation_Window:
        - run SquadSelectionGUI def.player:<player>


SpawnSquadNPCs:
    type: task
    debug: false
    definitions: atManager[ElementTag(Boolean)]|SMLocation[LocationTag]|squadName[ElementTag(String)]|player[PlayerTag]|spawnLocation[?LocationTag]
    description:
    - This script handles the spawning of new or existing squads at a given squad manager.
    - ---
    - → [Void]

    script:
    ## This script handles the spawning of new or existing squads at a given squad manager.
    ##
    ## atManager     :  [ElementTag<Boolean>]
    ## SMLocation    :  [LocationTag]
    ## squadName     :  [ElementTag<String>]
    ## player        :  [PlayerTag]
    ## spawnLocation : ?[LocationTag]
    ##
    ## >>> [Void]

    - define kingdom <[player].flag[kingdom]>

    - if <[atManager].if_null[false]>:
        - inject <script.name> path:FindSpacesAroundSM

        - if <[spawnLocation].exists>:
            - inject <script.name> path:SpawnSoldiers
            - flag <player> datahold.squadInfo.name:<[squadName]>

        - else:
            - narrate format:debug "Invalid Location."

    - else:
        - if <[spawnLocation].exists>:
            - inject <script.name> path:SpawnSoldiers

        - else:
            # TODO: Make it so that it gives the player the placement/soldier wand and allow them
            # TODO/ to determine the intial spawn location.
            - narrate WIP

    FindSpacesAroundSM:
    - define areasAroundSM <list[<[SMLocation].left[1]>|<[SMLocation].right[1]>|<[SMLocation].forward[1]>|<[SMLocation].backward[1]>]>

    - foreach <[areasAroundSM]> as:location:
        - if <[location].material.name> == air && <[location].up[1].material.name> == air:
            - define spawnLocation <[location]>
            - foreach stop

    SpawnSoldiers:
    - define hasSpawned <proc[HasSquadSpawned].context[<[kingdom]>|<[squadName]>]>
    - define soldierList <list[]>

    - if !<[hasSpawned]>:
        - foreach <proc[GetSquadComposition].context[<[kingdom]>|<[squadName]>]> key:type as:amount:
            - run SpawnNewSoldiers def.type:<[type]> def.location:<[spawnLocation]> def.amount:<[amount]> def.squadName:<[squadName]> def.SMLocation:<[SMLocation]> def.kingdom:<[kingdom]> save:soldiers
            - define soldierList <entry[soldiers].created_queue.determination.get[1]>

    - flag <player> datahold.squadInfo.npcList:<[soldierList].remove[1]>
    - flag <player> datahold.squadInfo.squadLeader:<[soldierList].get[1]>
    - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.hasSpawned:true
    - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.npcList:<[soldierList].remove[1]>
    - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.sentinelSquad:<[kingdom]>_<[squadName]>

    - ~run WriteArmyDataToKingdom def.SMLocation:<[SMLocation]> def.kingdom:<[player].flag[kingdom]>
    - run GiveSquadTools def.player:<player>


SpawnNewSoldiers:
    type: task
    debug: false
    definitions: type[ElementTag(String)]|location[LocationTag]|amount[ElementTag(Integer)]|squadName[ElementTag(String)]|kingdom[ElementTag(String)]|SMLocation[LocationTag]
    description:
    - Spawns in the specified amount of the given soldier type at the provided location.
    - ---
    - → [ListTag(NPCTag)]

    script:
    ## Spawns in the specified amount of the given soldier type at the provided location.
    ##
    ## type       : [ElementTag<String>]
    ## location   : [LocationTag]
    ## amount     : [ElementTag<Integer>]
    ## squadName  : [ElementTag<String>]
    ## kingdom    : [ElementTag<String>]
    ## SMLocation : [LocationTag]
    ##
    ## >>> [ListTag<NPCTag>]

    - define soldierList <list[]>

    # I won't have the script terminate altogether, but if you've reached this point and there's an
    # unrecognized unit-type then something's seriously wrong...
    # Make sure there isn't an addon that's fucking with this.
    - if !<script.data_key[UnitTypeConfigurations.<[type].to_titlecase>].exists>:
        - define type Swordsmen
        - run GenerateInternalError def.silent:false def.message:<element[Cannot recognize provided unit type: <[type].underline>. Could this be a bad param? Defaulting to unit type: <&sq>swordsmen<&sq>.]>

    - repeat <[amount].add[1]>:
        - define soldierName <element[Squad Member]>
        - define isSquadLeader false

        # Special case for squad leader;
        - if <[value]> == 1:
            - define soldierName <element[&4Squad Leader]>
            - define isSquadLeader true

        - create player <[soldierName]> <[location]> traits:sentinel save:new_soldier
        - define soldier <entry[new_soldier].created_npc>
        - define soldierList <[soldierList].include[<[soldier]>]>

        - flag <[soldier]> soldier.squad:<[squadName]>
        - flag <[soldier]> soldier.kingdom:<[kingdom]>
        - flag <[soldier]> soldier.type:<[type]>
        - flag <[soldier]> soldier.isSquadLeader:<[isSquadLeader]>

        - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.npcList:->:<[soldier]>

        # Special case for squad leader;
        - if <[value]> == 1:
            - flag <[SMLocation]> squadManager.squads.squadList.<[squadName]>.squadLeader:<[soldier]>
            - assignment set to:<[soldier]> script:SoldierManager_Assignment

        # General configurations;
        - execute as_server "sentinel squad <[kingdom]>_<[squadName]> --id <[soldier].id>" silent
        - execute as_server "sentinel respawntime -1 --id <[soldier].id>" silent
        - execute as_server "sentinel addignore squad:<[kingdom]>_<[squadName]> --id <[soldier].id>" silent
        - execute as_server "sentinel addignore denizen_proc:SoldierIgnoreKingdomPlayers:<[soldier]> --id <[soldier].id>" silent

        - inject <script> path:UnitTypeConfigurations.<[type].to_titlecase>

        - define equipment <proc[GetSquadEquipment].context[<[kingdom]>|<[squadName]>]>
        - equip <[soldier]> boots:<[equipment].get[boots]> head:<[equipment].get[helmet]> chest:<[equipment].get[chestplate]> legs:<[equipment].get[leggings]> hand:<[equipment].get[hotbar].get[1]>
        - inventory fill d:<[soldier].inventory> o:<[equipment].get[hotbar]>

        # Note: could have a system where the NPCs can specialize in a certain type of weapon
        #       thus utilizing something like:
        #       - execute as_server "sentinel weapondirect iron_axe diamond_axe"

    - determine <[soldierList]>

    # Note: Future configurables
    UnitTypeConfigurations:
        Swordsmen:
        - execute as_server "sentinel addtarget event:pvsentinel --id <[soldier].id>" silent
        - execute as_server "sentinel attackrate 0.5 --id <[soldier].id>" silent
        - execute as_server "sentinel attackrate 0.1 'ranged' --id <[soldier].id>" silent
        - execute as_server "sentinel speed 1.15 --id <[soldier].id>" silent
        - execute as_server "sentinel accuracy 2.7 --id <[soldier].id>" silent

        Archers:
        - execute as_server "sentinel speed 1.3 --id <[soldier].id>" silent
        - execute as_server "sentinel attackrate 0.5 'ranged' --id <[soldier].id>" silent
        - execute as_server "sentinel attackrate 0.1 --id <[soldier].id>" silent
        - execute as_server "sentinel projectilerange 50 --id <[soldier].id>" silent
        - execute as_server "sentinel accuracy 1.4 --id <[soldier].id>" silent
        - execute as_server "sentinel targettime 1.75 --id <[soldier].id>" silent


SoldierIgnoreKingdomPlayers:
    type: procedure
    debug: false
    definitions: entity[EntityTag]|context[MapTag]
    description:
    - Returns false if the provided entity is a player and is a member of the soldier's kingdom.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns false if the provided entity is a player and is a member of the soldier's kingdom.
    ##
    ## entity  : [EntityTag]
    ## context : [MapTag]
    ##
    ## >>> [ElementTag<Boolean>]

    - if <[entity].is_player> && <[entity].flag[kingdom]> == <[context].flag[kingdom]>:
        - determine true
