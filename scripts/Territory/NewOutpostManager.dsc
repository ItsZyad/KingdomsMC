##
## * Rewrote the entire outpost manager code in about
## * 4 and a half hours (refactor + conventions)
## * Manages initial outpost claiming and redef.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jul 2021
## @Script Ver: v1.0
##
##ignorewarning invalid_data_line_quotes
## This file exists courtesy of Max Chapman ##
## ----------------END HEADER-----------------

#TODO: Comment this!

TempSaveInventory:
    type: task
    debug: false
    definitions: player
    script:
    - if !<[player].has_flag[inventory_hold_outposts]>:
        - repeat 36:
            - flag <[player]> inventory_hold_outposts:->:<[player].inventory.slot[<[value]>]>
            - inventory set slot:<[value]> origin:<item[air]>


LoadTempInventory:
    type: task
    debug: false
    definitions: player
    script:
    - if <player.has_flag[inventory_hold_outposts]>:
        - repeat 36:
            - inventory set slot:<[value]> origin:<[player].flag[inventory_hold_outposts].get[<[value]>]>

        - flag <[player]> inventory_hold_outposts:!

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

                # Clear outpost name if it exists under the player's kingdom
                - if <server.has_flag[kingdoms.<[kingdom]>.outposts.outpostList.<[name]>]>:
                    - flag server kingdoms.<[kingdom]>.balance:+:<server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[name]>.upkeep].mul[0.45]>

                    - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[name]>:!
                    - flag server kingdoms.outpostInfo.allOutposts.<[name]>:!

                    #TODO: Make it clear the relevant amount of upkeep from the kingdom total

                    - note remove as:<[name]>
                    - narrate format:callout "Successfully deleted outpost by the name <[name]>"
                    - narrate format:callout "45<&pc> of your outpost's usual daily upkeep has been returned to your kingdom."

                - else:
                    - narrate format:callout "There is no outpost by the name: <red><[name]>"

                - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>

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

                - if <server.has_flag[kingdoms.<[kingdom]>.outposts.outpostList.<[name]>]>:
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

            ## CLOSE TO CASTLE CHECK ##
            # Check outpost's distance to other kingdom claims

            - foreach <server.flag[kingdoms.allClaims]>:
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

            # Cuboid object of the player's unfinalized outpost selection

            - define currOutpostSelection <cuboid[<player.location.world>,<[cornerOne]>,<[cornerTwo]>]>
            - define outpostList <server.flag[kingdoms.outpostInfo.allOutposts].to_pair_lists>

            - if <player.has_flag[redefiningOutpost]>:
                - define outpostList <server.flag[kingdoms.outpostInfo.allOutposts].to_pair_lists.exclude[<list[<player.flag[redefiningOutpost]>|<[kingdom]>]>]>

            - foreach <[outpostList]>:

                # Definitions for the loop outpost's kingdom,corners,
                # name,world

                - define outpostKingdom <[value].get[2]>
                - define outpostName <[value].get[1]>
                - define outpostCornerOne <server.flag[kingdoms.<[outpostKingdom]>.outposts.outpostList.<[outpostName]>.cornerone]>

                #- narrate format:debug "outpost corner one: <[outpostCornerOne].x>"
                #- narrate format:debug "outpost kingdom: <[outpostKingdom]>"

                - define outpostCornerTwo <server.flag[kingdoms.<[outpostKingdom]>.outposts.outpostList.<[outpostName]>.cornertwo]>
                - define outpostWorld <server.flag[kingdoms.<[outpostKingdom]>.outposts.outpostList.<[outpostName]>.cornerone].world>

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

                # If the size of the current claim is less than the maximum size of an outpost then commit the claim to relevant server flags #

                #- narrate format:debug "size: <[size]>"

                - if <[size].is[OR_LESS].than[<server.flag[kingdoms.<[kingdom]>.outposts.maxSize]>]>:

                    - define outpostCost <[size].mul[<server.flag[kingdoms.<[kingdom]>.outposts.outpostCost]>].round>

                    # Add buffs and debuffs to viridian and cambrian respectively, as outlined in their kingdom ideas

                    - if <[kingdom]> == viridian:
                        - define outpostCost <[outpostCost].mul[2]>

                    - else if <[kingdom]> == cambrian:
                        - define outpostCost <[outpostCost].mul[0.9]>

                    - if <server.flag[kingdoms.<[kingdom]>.balance].is[OR_MORE].than[<[outpostCost]>]>:

                        - if !<player.has_flag[redefiningOutpost]>:
                            - flag player noChat.outposts.definingOutpost
                            - flag player canNameOutpost

                            - narrate format:callout "Please type in chat the name you would like to give this outpost:"

                        - else:
                            - flag player noChat.outposts.definingOutpost
                            - flag player outpostAlreadyNamed

                            - narrate format:callout "Are you sure you would like to redefine this outpost to these specifications? (yes/no)"

                        - flag player outpostCost:<[outpostCost]>
                        - flag player size:<[size]>

                    - else:
                        - narrate format:callout "You do not have sufficient funds to claim this territory."

                        - flag player cornerOneDefined:!
                        - flag player cornerTwoDefined:!

                - else:
                    - narrate format:callout "Outpost exceeds maximum size of: <red><server.flag[kingdoms.<[kingdom]>.outposts.maxSize]><&6>! Attempted claim size of: <red><[size]>"

                    - flag player cornerOneDefined:!
                    - flag player cornerTwoDefined:!

        on player chats flagged:noChat.outposts.definingOutpost:
        - define posOne <player.flag[cornerOneDefined]>
        - define posTwo <player.flag[cornerTwoDefined]>
        - define outpostCost <player.flag[outpostCost]>
        - define kingdom <player.flag[kingdom]>

        - if <player.has_flag[canNameOutpost]>:
            - if !<server.has_flag[kingdoms.<[kingdom]>.outposts.outpostList.<context.message>]>:
                - note <cuboid[<player.world.name>,<[PosOne].as[location].x>,0,<[PosOne].as[location].z>,<[PosTwo].as[location].x>,255,<[PosTwo].as[location].z>]> as:<context.message>
                - define escapedName <proc[OutpostNameEscaper].context[<context.message>]>

                #- narrate format:debug "ESCAPED: <[escapedName]>"

                # Set data in outposts.yml

                - flag server kingdoms.outpostInfo.allOutposts.<[escapedName]>:<[kingdom]>
                - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.cornerone:<[PosOne].as[location]>
                - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.cornertwo:<[PosTwo].as[location]>
                - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.size:<player.flag[size].round>
                - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.upkeep:<server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.size].mul[<server.flag[kingdoms.<[kingdom]>.outposts.upkeepMultiplier]>].round>
                - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.name:<context.message>

                # Set data in kingdoms.yml

                - flag server kingdoms.<[kingdom]>.outposts.totalupkeep:+:<server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.upkeep]>
                - flag server kingdoms.<[kingdom]>.balance:-:<[outpostCost]>
                - flag server kingdoms.<[kingdom]>.upkeep:+:<server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.upkeep]>

            - else:
                - narrate format:callout "There is already an outpost by this name! Use <red>/outpost redefine <&6>or <red>/outpost rename to change an existing outpost"

            - determine cancelled

        - else if <player.has_flag[outpostAlreadyNamed]>:
            - if <context.message.to_lowercase> == yes:
                - define outpostName <player.flag[redefiningOutpost]>
                - note <cuboid[<player.world.name>,<[PosOne].as[location].x>,0,<[PosOne].as[location].z>,<[PosTwo].as[location].x>,255,<[PosTwo].as[location].z>]> as:<context.message>

                - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.cornerone:<[PosOne].as[location]>
                - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.cornertwo:<[PosTwo].as[location]>
                - flag server kingdoms.<[kingdom]>.outposts.outpostList.<[escapedName]>.size:<player.flag[size].round>

                - define newUpkeep <server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpostName]>.size].mul[<server.flag[kingdoms.<[kingdom]>.outposts.upkeepMultiplier]>].round>
                - define oldUpkeep <server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpostName]>.upkeep]>

                - flag server <[kingdom]>.outposts.outpostList.<[outpostName]>.upkeep:<[newUpkeep]>

                - define upkeepDiff <[newUpkeep].sub[<[newUpkeep]>].abs>

                - flag server kingdoms.<[kingdom]>.outposts.totalupkeep:+:<[upkeepDiff]>
                - flag server kingdoms.<[kingdom]>.upkeep:+:<[upkeepDiff]>
                - flag player outpostAlreadyNames:!

            - else:
                - narrate format:callout "Changes reverted."

            - determine cancelled

        - run LoadTempInventory def:<player>
        - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>

        - flag player outpostCost:!
        - flag player cornerOneDefined:!
        - flag player cornerTwoDefined:!
        - flag player canNameOutpost:!
        - flag player size:!
        - flag player redefiningOutpost:!
        - flag player outpostAlreadyNamed:!


##############################################################################

OutpostHandler:
    type: world
    debug: false
    events:
        on player enters area:
        - if <script.queues.size.is[MORE].than[1]>:
            - queue clear <script.queues.get[1]>

        - if <server.has_flag[kingdoms.outpostInfo.allOutposts.<context.area.split[@].get[2]>]>:
            - define whichKingdom <server.flag[kingdoms.outpostInfo.allOutposts.<context.area.split[@].get[2]>]>

            - if <[whichKingdom]> == <player.flag[kingdom]>:
                - repeat 3:
                    - actionbar "You are now entering the outpost: <context.area.split[@].get[2].color[<script[KingdomTextColors].data_key[<[whichKingdom]>]>]>"
                    - wait 1s

            - else:
                - repeat 3:
                    - actionbar "You are now entering a <server.flag[kingdoms.outpostInfo.allOutposts.<context.area.split[@].get[2]>].color[<script[KingdomTextColors].data_key[<[whichKingdom]>]>]> outpost"
                    - wait 1s

        on player exits area:
        - if <script.queues.size.is[MORE].than[1]>:
            - queue clear <script.queues.get[1]>

        - if <server.has_flag[kingdoms.outpostinfo.allOutposts.<context.area.split[@].get[2]>]>:
            - repeat 3:
                - actionbar "<red>Leaving outpost"
                - wait 1s