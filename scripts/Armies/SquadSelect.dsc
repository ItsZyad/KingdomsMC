########################
## THIS FILE IS INDEV ##
########################

## VERSION NUMBERS / GENERAL METADATA DO NOT EXIST FOR INDEV MODULES!

SquadCommand:
    type: command
    name: squad
    usage: /squad
    description: "Brings up the squad selection window"
    permission: kingdoms.squads
    tab completions:
        1: list|create
    script:
    - if <context.args.get[1]> == list:
        - flag player pageNumber:1
        - run SquadSelectionGUI

    - if <context.args.get[1]> == create:
        # Checks if player is not already in squad mode #
        - if !<player.has_flag[inventory_hold]>:
            - yaml load:squads.yml id:squads

            # Checks if the player specifies a squad name #
            - if <context.args.size.is[OR_MORE].than[2]>:

                - define kingdom <player.flag[kingdom]>

                # Checks for identical squad name #
                - if !<yaml[squads].contains[<[kingdom]>.<context.args.get[2]>]>:

                    # Creates a temporary flag for player inventory holding and assigns squad name
                    # to a flag of its own.
                    - flag player inventory_hold:<list>
                    - flag player squadName:<proc[YamlSpaceAdder].context[<context.args.get[2]>]>

                    # Copies the player's current inventory into a temporary holding flag
                    # while also clearing it.
                    - repeat 36:
                        - flag player inventory_hold:->:<player.inventory.slot[<[value]>]>
                        - inventory set slot:<[value]> origin:<item[air]>

                    - inventory set slot:1 origin:<item[NPCSelectWand]>
                    - inventory set slot:9 origin:<item[NPCSelectExit]>

                    - yaml id:squads set <[kingdom]>.<player.flag[squadName]>.name:<player.flag[squadName]>
                    - yaml id:squads set <[kingdom]>.<player.flag[squadName]>.squadSize:0

                    - yaml id:squads savefile:squads.yml
                    - yaml id:squads unload

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


SquadSelectionGUI:
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

SquadSelectionHandler:
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

        on player right clicks npc with:NPCSelectWand:
        - ratelimit <player> 2t

        - yaml load:squads.yml id:squads

        - if <player.has_flag[inventory_hold]>:
            - if <context.entity.entity_type> == PLAYER && <context.entity.split[@].get[1]> == n:
                - if !<yaml[squads].read[<player.flag[kingdom]>.<player.flag[squadName]>.npclist].contains[<context.entity>]>:
                    - yaml id:squads set <player.flag[kingdom]>.<player.flag[squadName]>.npclist:->:<context.entity>
                    - yaml id:squads set <player.flag[kingdom]>.<player.flag[squadName]>.squadSize:<yaml[squads].read[<player.flag[kingdom]>.<player.flag[squadName]>.npclist].size>
                    - actionbar "Added to squad"

                - else:
                    - actionbar "NPC already in squad"

        - yaml id:squads savefile:squads.yml
        - yaml id:squads unload

        on player drops item:
        - if <player.has_flag[inventory_hold]>:
            - determine cancelled