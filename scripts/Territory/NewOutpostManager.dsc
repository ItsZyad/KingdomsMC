##
## * Rewrote the entire outpost manager code in about
## * 4 and a half hours (refactor + conventions)
## * Manages initial outpost claiming and redef.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jul 2021
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

#TODO: Comment this!

# This file exists courtesy of Max Chapman #

TempSaveInventory:
    type: task
    definitions: player
    script:
    - if !<[player].has_flag[inventory_hold_outposts]>:
        - repeat 36:
            - flag <[player]> inventory_hold_outposts:->:<[player].inventory.slot[<[value]>]>
            - inventory set slot:<[value]> origin:<item[air]>

    - else:
        - narrate format:callout "You are already in outpost mode!"

LoadTempInventory:
    type: task
    definitions: player
    script:
    - if <player.has_flag[inventory_hold_outposts]>:
        - repeat 36:
            - inventory set slot:<[value]> origin:<[player].flag[inventory_hold_outposts].get[<[value]>]>

        - flag <[player]> inventory_hold_outposts:!

    - else:
        - narrate format:callout "There is no saved inventory!"

##############################################################################

Outpost_Command:
    type: command
    usage: /outpost
    name: outpost
    permission: kingdoms.outpost
    tab completions:
        1: claim|redefine|delete|cancel|showborder|list
    tab complete:
        - if <context.args.get[1]> == showborder:
            - if <context.args.size.is[MORE].than[1]>:
                - determine Duration<&sp>(seconds)<&sp>[Optional]

            - else:
                - determine Outpost<&sp>Name

        - else if <context.args.get[1]> == redefine:
            - if <context.args.size.is[OR_MORE].than[1]>:
                - determine Outpost<&sp>Name<&sp>[Spaces<&sp>Allowed]

    description: "Allows you to define and manage your claimed outposts"
    script:
    - if <server.has_flag[PreGameStart]> && !<player.is_op>:
        - determine cancelled

    #------------------------------------------------------------------------------------------------------------------------

    - if <context.args.get[1]> == list:
        - inject OutpostList_Command.subpaths.ResetOutpostPageFlag
        - inject OutpostList_Command.subpaths.OutpostGUI_Init
        - inject OutpostList_Command.subpaths.OutpostGUI_Show

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == showborder:
        - if <context.args.size.is[OR_MORE].than[2]>:
            - define param <context.args.get[2]>
            - define initialLoc <player.location>
            - define displayLength 30

            - if <context.args.size.is[MORE].than[2]>:
                - define displayLength <context.args.get[3]>

            - if <cuboid[<[param]>].exists>:
                # The base of the imaginary border blocks will be red wool
                # starting at the player y-position

                - showfake red_wool <cuboid[<[param]>].outline_2d[<[initialLoc].y>]> duration:<[displayLength]>s
                - wait 1s

                # The 5 blocks above those will be glass

                - repeat 5:
                    - showfake glass <cuboid[<[param]>].outline_2d[<[initialLoc].up[<[value]>].y>]> duration:<[displayLength]>s
                    - wait 1s

                # Topmost block on the imaginary block border will be red wool again

                - showfake red_wool <cuboid[<[param]>].outline_2d[<[initialLoc].up[<[value]>].y>]> duration:<[displayLength]>s
                - wait 1s

            - else:
                - narrate format:callout "There is no outpost with such a name."

        - else:
            - narrate format:callout "You must specify an outpost!"

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == cancel:
        - flag player outpostCost:!
        - flag player cornerOneDefined:!
        - flag player cornerTwoDefined:!
        - flag player canNameOutpost:!
        - flag player size:!
        - flag player redefiningOutpost:!

        # Give the player their blocks back

        - run LoadTempInventory def:<player>

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == delete:
        - if <player.has_permission[kingdoms.outpost.delete]>:

            - if <player.has_flag[confirmOutpostDeletion]> && <context.args.get[2]> == confirm:
                - define name <proc[OutpostNameEscaper].context[<context.args.get[3].to[last].space_separated>]>
                - define kingdom <player.flag[kingdom]>

                - yaml load:outposts.yml id:outpost
                - yaml load:kingdoms.yml id:kingdoms

                # Clear outpost name if it exists under the player's kingdom
                - if <yaml[outpost].contains[<[kingdom]>.<[name]>]>:
                    - yaml id:kingdoms set <[kingdom]>.balance:+:<yaml[outposts].read[<[kingdom]>.<[name]>.upkeep].mul[0.45]>

                    - yaml id:outpost set <[kingdom]>.<[name]>:!
                    - yaml id:outpost set outposts.<[name]>:!

                    #TODO: Make it clear the relevant amount of upkeep from the kingdom total

                    - note remove as:<[name]>
                    - narrate format:callout "Successfully deleted outpost by the name <[name]>"
                    - narrate format:callout "45<&pc> of your outpost's usual weekly upkeep has been returned to your kingdom."

                - else:
                    - narrate format:callout "There is no outpost by the name: <red><[name]>"

                - yaml id:outpost savefile:outposts.yml
                - yaml id:outpost unload

                - yaml id:kingdoms savefile:kingdoms.yml
                - yaml id:kingdoms unload

                - run SidebarLoader def.target:<server.flag[<[kingdom]>].get[members].include[<server.online_ops>]>

            - else:
                - narrate format:callout "Are you sure you would like to delete this outpost?"
                - narrate format:callout "Please type <element[outpost delete confirm <&lt>name<&gt>].color[red]> to confirm."
                - flag <player> confirmOutpostDeletion expire:10m

        - else:
            - narrate format:callout "You do not have sufficient permissions to delete an outpost! This must be performed by a higher-ranking member of your kingdom."


    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == claim:
        - run TempSaveInventory def:<player>
        - give to:<player.inventory> slot:<player.held_item_slot> OutpostWand_Item

        - narrate format:callout "Use the outpost wand in your hotbar to define this outpost by clicking the intended corner blocks with it."

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == redefine:
        - if <player.has_permission[kingdoms.outpost.redefine]>:
            - if <context.args.size.is[MORE].than[1]>:

                - define kingdom <player.flag[kingdom]>

                - define name <context.args.get[2].to[last]>
                #- narrate format:debug NAME:<[name]>
                - yaml load:outposts.yml id:outpost

                - if <yaml[outpost].contains[<[kingdom]>.<[name]>]>:
                    - run TempSaveInventory def:<player>
                    - give to:<player.inventory> slot:<player.held_item_slot> OutpostWand_Item

                    - flag player redefiningOutpost:<[name]>

                    - narrate format:callout "Use the outpost wand in your hotbar to redefine this outpost by clicking the intended corner blocks with it."

                - else:
                    - narrate format:callout "There exists no outpost by the name: <red><[name]>"

            - else:
                - narrate format:callout "You must specify a name for the outpost being redefined"

        - else:
            - narrate format:callout "You do not have sufficient permissions to redefine outpost claims"

##############################################################################

OutpostWand_Item:
    type: item
    material: blaze_rod
    display name: "Outpost Wand"

OutpostWand_Handler:
    type: world
    events:
        on player clicks block with:OutpostWand_Item:

        - define kingdom <player.flag[kingdom]>
        - define cornerOne 0
        - define cornerTwo 0

        # First corner selection and flagging player with its
        # location

        - if !<player.has_flag[cornerOneDefined]>:
            - define cornerOne <context.location>
            - flag player cornerOneDefined:<[cornerOne]>

            - narrate format:callout "Please select the second corner of the outpost"

        # Second corner selection and flagging player with its
        # location

        - else:
            - define cornerTwo <context.location>
            - flag player cornerTwoDefined:<[cornerTwo]>

            - yaml id:kingdoms load:kingdoms.yml

            ## CLOSE TO CASTLE CHECK ##
            # Check outpost's distance to other kingdom claims

            - foreach <yaml[kingdoms].read[all_claims]>:
                - define chunkCenter <[value].cuboid.center>
                - define outpostDistance <[cornerTwo].distance[<[chunkCenter]>]>

                - if <[outpostDistance].is[OR_LESS].than[700]>:
                    - flag player cornerOneDefined:!
                    - flag player cornerTwoDefined:!

                    # Give error message and return the player's
                    # inventory

                    - narrate format:callout "Your outpost is too close to another kingdom's territory!"

                    - run LoadTempInventory def:<player>
                    - foreach stop

            - yaml id:outpost load:outposts.yml

            # Cuboid object of the player's unfinalized outpost selection

            - define currOutpostSelection <cuboid[<player.location.world>,<[cornerOne]>,<[cornerTwo]>]>

            - define outpostList <yaml[outpost].read[outposts].to_pair_lists>

            - if <player.has_flag[redefiningOutpost]>:
                - define outpostList <yaml[outpost].read[outposts].to_pair_lists.exclude[<list[<player.flag[redefiningOutpost]>|<player.flag[kingdom]>]>]>

            - foreach <[outpostList]>:

                # Definitions for the loop outpost's kingdom,corners,
                # name,world

                - define outpostKingdom <[value].get[2]>
                - define outpostName <[value].get[1]>
                - define outpostCornerOne <yaml[outpost].read[<[outpostKingdom]>.<[outpostName]>.cornerone]>

                #- narrate format:debug "outpost corner one: <[outpostCornerOne].x>"
                #- narrate format:debug "outpost kingdom: <[outpostKingdom]>"

                - define outpostCornerTwo <yaml[outpost].read[<[outpostKingdom]>.<[outpostName]>.cornertwo]>

                - define outpostWorld <yaml[outpost].read[<[outpostKingdom]>.<[outpostName]>.cornerone].world>

                #- narrate format:debug "outpost world: <[outpostWorld]>"

                # Put together the loop outpost as a cuboid object
                # and check if it overlaps with the player's current
                # selection

                - define otherOutpost <cuboid[<[outpostWorld].name>,<[outpostCornerOne].x>,0,<[outpostCornerOne].z>,<[outpostCornerTwo].x>,255,<[outpostCornerTwo].z>]>

                #- narrate format:debug "other outpost: <[otherOutpost]>"

                # If the outpost overlaps with another outpost from
                # any kingdom then cancel the player's selection and
                # return their inventory

                - if <[otherOutpost].intersects[<[currOutpostSelection]>]>:
                    - flag player cornerOneDefined:!
                    - flag player cornerTwoDefined:!

                    - narrate format:callout "This selection overlaps with another outpost. Please select another location"

                    - run LoadTempInventory def:<player>

                    - foreach stop

            - if <player.has_flag[cornerOneDefined]> && <player.has_flag[cornerTwoDefined]>:
                - define diffX <player.flag[cornerOneDefined].x.sub[<player.flag[cornerTwoDefined].x>].abs>
                - define diffZ <player.flag[cornerOneDefined].z.sub[<player.flag[cornerTwoDefined].z>].abs>

                - define size <[diffX].mul[<[diffZ]>]>

                # If the size of the current claim is less than the maximum size of an outpost then commit the claim to relevant yaml files #

                #- narrate format:debug "size: <[size]>"

                - if <[size].is[OR_LESS].than[<yaml[kingdoms].read[<[kingdom]>.outposts.max_size]>]>:

                    - define outpostCost <[size].mul[<yaml[kingdoms].read[<[kingdom]>.outposts.outpost_cost]>].round>

                    # Add buffs and debuffs to viridian and cambrian respectively, as outlined in their kingdom ideas

                    - if <[kingdom]> == viridian:
                        - define outpostCost <[outpostCost].mul[2]>

                    - else if <[kingdom]> == cambrian:
                        - define outpostCost <[outpostCost].mul[0.9]>

                    - if <yaml[kingdoms].read[<[kingdom]>.balance].is[OR_MORE].than[<[outpostCost]>]>:

                        - if !<player.has_flag[redefiningOutpost]>:
                            - flag player canNameOutpost

                            - narrate format:callout "Please type in chat the name you would like to give this outpost:"

                        - else:
                            - flag player outpostAlreadyNamed

                            - narrate format:callout "Are you sure you would like to redefine this outpost to these specifications? (yes/no)"

                        - flag player outpostCost:<[outpostCost]>
                        - flag player size:<[size]>

                    - else:
                        - narrate format:callout "You do not have sufficient funds to claim this territory."

                        - flag player cornerOneDefined:!
                        - flag player cornerTwoDefined:!

                - else:
                    - narrate format:callout "Outpost exceeds maximum size of: <red><yaml[kingdoms].read[<[kingdom]>.outposts.max_size]><&6>! Attempted claim size of: <red><[size]>"

                    - flag player cornerOneDefined:!
                    - flag player cornerTwoDefined:!

            - yaml id:kingdoms unload

        on player chats:
        - define posOne <player.flag[cornerOneDefined]>
        - define posTwo <player.flag[cornerTwoDefined]>

        - define outpostCost <player.flag[outpostCost]>

        - yaml load:kingdoms.yml id:kingdoms
        - yaml load:outposts.yml id:outpost

        - define kingdom <player.flag[kingdom]>

        - if <player.has_flag[canNameOutpost]> || <player.has_flag[outpostAlreadyNamed]>:
            - if <player.has_flag[canNameOutpost]>:
                - if !<yaml[outpost].contains[<[kingdom]>.<context.message>]>:

                    - note <cuboid[<player.world.name>,<[PosOne].as_location.x>,0,<[PosOne].as_location.z>,<[PosTwo].as_location.x>,255,<[PosTwo].as_location.z>]> as:<context.message>

                    - define escapedName <proc[OutpostNameEscaper].context[<context.message>]>
                    #- narrate format:debug "ESCAPED: <[escapedName]>"

                    # Set data in outposts.yml

                    - yaml id:outpost set outposts.<[escapedName]>:<[kingdom]>
                    - yaml id:outpost set <[kingdom]>.<[escapedName]>.cornerone:<[PosOne].as_location>
                    - yaml id:outpost set <[kingdom]>.<[escapedName]>.cornertwo:<[PosTwo].as_location>
                    - yaml id:outpost set <[kingdom]>.<[escapedName]>.size:<player.flag[size].round>
                    - yaml id:outpost set <[kingdom]>.<[escapedName]>.upkeep:<yaml[outpost].read[<[kingdom]>.<[escapedName]>.size].mul[<yaml[kingdoms].read[<[kingdom]>.outposts.outpost_upkeep]>].round>
                    - yaml id:outpost set <[kingdom]>.<[escapedName]>.name:<context.message>

                    # Set data in kingdoms.yml

                    - yaml id:outpost set <[kingdom]>.totalupkeep:+:<[kingdom]>.<[escapedName]>.upkeep
                    - yaml id:kingdoms set <[kingdom]>.balance:-:<[outpostCost]>
                    - yaml id:kingdoms set <[kingdom]>.upkeep:+:<yaml[outpost].read[<[kingdom]>.<[escapedName]>]>
                    - yaml id:kingdoms set <[kingdom]>.outpost_count:+:1

                - else:
                    - narrate format:callout "There is already an outpost by this name! Use <red>/outpost redefine <&6>or <red>/outpost rename to change an existing outpost"

            - else if <player.has_flag[outpostAlreadyNamed]>:
                - if <context.message.to_lowercase> == yes:

                    - define outpostName <player.flag[redefiningOutpost]>

                    - note <cuboid[<player.world.name>,<[PosOne].as_location.x>,0,<[PosOne].as_location.z>,<[PosTwo].as_location.x>,255,<[PosTwo].as_location.z>]> as:<context.message>

                    - yaml id:outpost set <[kingdom]>.<[outpostName]>.cornerone:<[PosOne].as_location>
                    - yaml id:outpost set <[kingdom]>.<[outpostName]>.cornertwo:<[PosTwo].as_location>
                    - yaml id:outpost set <[kingdom]>.<[outpostName]>.size:<player.flag[size].round>

                    - define newUpkeep <yaml[outpost].read[<[kingdom]>.<[outpostName]>.size].mul[<yaml[kingdoms].read[<[kingdom]>.outposts.outpost_upkeep]>].round>
                    - define oldUpkeep <yaml[outpost].read[<[kingdom]>.<[outpostName]>.upkeep]>

                    - yaml id:outpost set <[kingdom]>.<[outpostName]>.upkeep:<[newUpkeep]>

                    - define upkeepDiff <[newUpkeep].sub[<[newUpkeep]>].abs>

                    #- narrate format:debug <[upkeepDiff]>

                    - yaml id:outpost set <[kingdom]>.totalupkeep:+:<[upkeepDiff]>
                    - yaml id:kingdoms set <[kingdom]>.upkeep:+:<[upkeepDiff]>

                    - flag player outpostAlreadyNames:!

                - else:
                    - narrate format:callout "Reverting changes..."

            - run LoadTempInventory def:<player>

            - yaml id:kingdoms savefile:kingdoms.yml
            - yaml id:outpost savefile:outposts.yml

            - run SidebarLoader def.target:<server.flag[<[kingdom]>.members].include[<server.online_ops>]>

            - flag player outpostCost:!
            - flag player cornerOneDefined:!
            - flag player cornerTwoDefined:!
            - flag player canNameOutpost:!
            - flag player size:!
            - flag player redefiningOutpost:!
            - flag player outpostAlreadyNamed:!

            - yaml id:kingdom unload
            - yaml id:outpost unload
            - determine cancelled

##############################################################################

OutpostHandler:
    type: world
    debug: false
    events:
        on player enters *:
        - yaml load:outposts.yml id:outp

        - if <script.queues.size.is[MORE].than[1]>:
            - queue clear <script.queues.get[1]>

        - if <yaml[outp].contains[outposts.<context.area.split[@].get[2]>]>:
            - define whichKingdom <yaml[outp].read[outposts.<context.area.split[@].get[2]>]>

            - if <[whichKingdom]> == <player.flag[kingdom]>:
                - repeat 3:
                    - actionbar "You are now entering the outpost: <context.area.split[@].get[2].color[<script[KingdomColors].data_key[<[whichKingdom]>]>]>"
                    - wait 1s

            - else:
                - repeat 3:
                    - actionbar "You are now entering a <yaml[outp].read[outposts.<context.area.split[@].get[2]>].color[<script[KingdomColors].data_key[<[whichKingdom]>]>]> outpost"
                    - wait 1s

        - yaml unload id:outp

        on player exits *:
        - yaml load:outposts.yml id:outp

        - if <script.queues.size.is[MORE].than[1]>:
            - queue clear <script.queues.get[1]>

        - if <yaml[outp].contains[outposts.<context.area.split[@].get[2]>]>:
            - repeat 3:
                - actionbar "<red>Leaving outpost"
                - wait 1s

        - yaml unload id:outp