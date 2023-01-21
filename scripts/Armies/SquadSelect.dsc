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

    - choose <[args].get[1]>:
        - case create:
            - choose <[args].size>:
                - case 1:
                    - determine <list[[name]]>
                - case 2:
                    - determine <list[?[display_name]]>

    script:
    - define args <context.raw_args.split_args>

    - if <[args].get[1]> == list:
        - flag player pageNumber:1
        - run SquadSelectionGUI

    - if <[args].get[1]> == create:
        # Checks if player is not already in squad mode #
        - if !<player.has_flag[inventory_hold]>:

            # Checks if the player specifies a squad name #
            - if <[args].size.is[OR_MORE].than[2]>:
                - define kingdom <player.flag[kingdom]>
                - define internalSquadName <[args].get[2]>
                - define displaySquadName <[args].get[3]>

                # Checks for identical squad name #
                - if !<server.has_flag[armies.<[kingdom]>.squads.<[internalSquadName]>]>:

                    # Creates a temporary flag for player inventory holding and assigns squad name
                    # to a flag of its own.
                    - flag player inventory_hold:<list>
                    - flag player squadName:<[args].get[2]>

                    # Copies the player's current inventory into a temporary holding flag
                    # while also clearing it.
                    - repeat 36:
                        - flag player inventory_hold:->:<player.inventory.slot[<[value]>]>
                        - inventory set slot:<[value]> origin:<item[air]>

                    - inventory set slot:1 origin:<item[NPCSelectWand]>
                    - inventory set slot:9 origin:<item[NPCSelectExit]>

                    - flag server armies.<[kingdom]>.squads.<[internalSquadName]>.displayName:<[displaySquadName]> if:<[displaySquadName].exists>

                - else:
                    - narrate format:callout "There already exists a squad by this name."

            - else:
                - narrate format:callout "You must specify a squad name."

        - else:
            - narrate format:callout "You are already in squad creation mode!"

    # DEV COMMAND - Restores player inventory as kept in 'inventory_hold' flag - bypasses conditions #
    - if <context.args.get[1]> == DEBUG_inv_restore:
        - if <player.has_permission[kingdoms.admin.squads.debug]> || <player.has_permission[kingdoms.admin.debug]>:
            - repeat 36:
                - inventory set slot:<[value]> origin:<player.flag[inventory_hold].get[<[value]>]>

        - flag player inventory_hold:!

        - else:
            - narrate format:callout "Debug commands are not made available to players"

    # DEV COMMAND - Makes a particular squad walk in formation #
    # Use this code when writing the actual interface that will control squads #
    - else if <context.args.get[1]> == DEBUG_walk_formation:
        - if <player.has_permission[kingdoms.admin.squads.debug]> || <player.has_permission[kingdoms.admin.debug]>:
            - define param <context.args.get[2].to[<context.args.length>].separated_by[/sp/]>
            - yaml load:squads.yml id:squads

            - define squadName <yaml[squads].read[<player.flag[kingdom]>.<[param]>]>

            - run FormationWalk def:<[squadName]>

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

    - run PaginatedInterface def.itemList:<[itemList]> def.page:1 def.player:<player> def.title:Squads


OLD_SquadSelectionGUI:
    type: task
    debug: false
    script:
    - yaml load:squads.yml id:squads

    # Since the squads.yml file maps the individual squad information to a name that is not known to this file
    # This definition helps me access each of these maps (i.e. squad1, squad2 etc.) without calling them by name
    # Thus giving me access to the npclist and the squadsize etc.

    - define mappedVals <yaml[squads].read[<player.flag[kingdom]>].values>
    - define mappedVals <[mappedVals].insert[<[mappedVals].get[<[mappedVals].size>]>].at[1].remove[last]>
    - define amountOfSquads <definition[mappedVals].size>

    - define squadInv <list>

    - repeat <definition[amountOfSquads]>:
        - define squadNumber <[value]>

        # Some more information about each of the squads assigned to definitions for ease of access
        - define squadList <definition[mappedVals].get[<[squadNumber]>].get[npclist]>
        - define squadName <proc[YamlSpaceAdder].context[<definition[mappedVals].get[<[squadNumber]>].get[name]>]>

        # Creates an item on the fly that is just a player head with the npclist values attached to it
        - define head <item[player_head].with[lore="NPCs:";display=<definition[squadName]>]>

        - foreach <definition[squadList]>:
            - define newLore <list[<definition[head].lore>|<[value]>].combine>
            - define head <item[player_head].with[lore=<definition[newLore]>]>

            - if <[loop_index]> == 3:
                - foreach stop

        # If there are more than 3 NPCs in a squad - add message at the bottom of the GUI entry that says:
        # "And [Amount of remaining NPCs] more"
        - if <definition[squadList].size.is[MORE].than[3]>:
            - define moreNPCsMsg "And <definition[squadList].size.sub[3]> more"
            - define newLore <list[<definition[head].lore>|<definition[moreNPCsMsg]>].combine>
            - define head <item[player_head].with[lore=<definition[newLore]>]>

        - flag <definition[head]> <proc[YamlSpaceAdder].context[<definition[mappedVals].get[<[squadNumber]>].get[name]>]>
        - define squadInv:->:<definition[head]>

    - flag player squadsel:<list>

    - if <definition[squadInv].size.is[OR_LESS].than[36]>:
        - flag player squadsel:<definition[squadInv]>
    - else:
        - define loopStart <player.flag[pageNumber].sub[1].mul[36]>

        # If the amount of slots between the start of this page and the end of the list is less than the threshold amount
        - narrate format:debug <definition[squadInv].size.sub[<player.flag[pageNumber].sub[1].mul[36]>]>
        - if <definition[squadInv].size.sub[<player.flag[pageNumber].sub[1].mul[36]>].is[LESS].than[36]>:

            - repeat <definition[squadInv].size.sub[<player.flag[pageNumber].sub[1].mul[36]>]>:
                - flag player squadsel:->:<definition[squadInv].get[<[value].add[<definition[loopStart]>]>]>
        - else:
            - repeat 36:
                - flag player squadsel:->:<definition[squadInv].get[<[value].add[<definition[loopStart]>]>]>

    - yaml id:squads unload

    - define squadInv:!

    - inventory open destination:SquadSelectionWindow


SquadSelectionWindow:
    type: inventory
    inventory: chest
    title: "Squad Selector"
    procedural items:
    - determine <player.flag[squadsel]>

    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [PrevPage] [] [] [] [] [] [] [] [NextPage]

PrevPage:
    type: item
    material: arrow
    display name: "Previous Page"

NextPage:
    type: item
    material: arrow
    display name: "Next Page"

NPCSelectWand:
    type: item
    material: feather
    display name: "NPC Selector"

NPCSelectExit:
    type: item
    material: barrier
    display name: "Exit"

SquadSelection_Handler:
    type: world
    events:
        # These two events handle pagination #
        # ---------------------------------- #
        on player clicks PrevPage in SquadSelectionWindow:
        - if <player.flag[pageNumber].is[OR_MORE].than[1]>:
            - flag player pageNumber:-:1
            - run SquadSelectionGUI
            - inventory open destination:SquadSelectionWindow

        - narrate format:debug "PAGE NUMBER:<player.flag[pageNumber]>"
        - determine cancelled

        on player clicks NextPage in SquadSelectionWindow:
        # CHANGE THIS LINE IF YOU EVER CHANGE THE NUMBER OF SLOTS IN THE GUI!! #
        - define itemRange <player.flag[pageNumber].sub[1].mul[36]>

        - if <definition[itemRange].is[OR_LESS].than[<player.flag[squadsel].size>]>:
            - flag player pageNumber:+:1
            - run SquadSelectionGUI
            - inventory open destination:SquadSelectionWindow

        - narrate format:debug "PAGE NUMBER:<player.flag[pageNumber]>"
        - determine cancelled

        # Change this if you ever change the item that represents squads #
        on player clicks player_head in SquadSelectionWindow:
        - narrate <context.item.list_flags>
        - determine cancelled

NPCSelectHandler:
    type: world
    debug: false
    events:
        on player clicks block with:NPCSelectExit:
        - repeat 36:
            - inventory set slot:<[value]> origin:<player.flag[inventory_hold].get[<[value]>]>

        - flag player inventory_hold:!
        - flag player squadName:!

        - determine cancelled

        on player right clicks npc with:NPCSelectWand:
        - ratelimit <player> 2t

        - define kingdom <player.flag[kingdom]>
        - define squadName <player.flag[squadName]>

        - narrate format:debug <[squadName]>

        - if <player.has_flag[inventory_hold]>:
            - if <context.entity.entity_type> == PLAYER && <context.entity.id.exists>:
                - if !<server.flag[armies.<[kingdom]>.squads.<[squadName]>.npcList].contains[<context.entity>].if_null[false]>:
                    - flag server armies.<[kingdom]>.squads.<[squadName]>.npcList:->:<context.entity>
                    - actionbar "Added to squad"

                - else:
                    - actionbar "NPC already in squad"

        on player drops item:
        - if <player.has_flag[inventory_hold]>:
            - determine cancelled