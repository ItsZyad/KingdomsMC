##
## Rewrote the entire outpost manager code in about 4 and a half hours (refactor + conventions)
## Manages initial outpost claiming and redef.
##
## This file exists courtesy of Max Chapman :)
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jul 2021
## @Update 1: Jul 2024
## @Update 2: Oct 2024
## @Script Ver: v1.3
##
## ------------------------------------------END HEADER-------------------------------------------

Outpost_Command:
    type: command
    usage: /outpost
    name: outpost
    description: Allows you to define and manage your claimed outposts.
    tab completions:
        1: claim|redefine|delete|cancel|showborder|list

    tab complete:
    - define args <context.raw_args.split_args>

    - choose <[args].get[1].to_lowercase.if_null[null]>:
        - case showborder:
            - if <[args].size.is[MORE].than[1]>:
                - determine Duration<&sp>(seconds)<&sp>[Optional]

            - else:
                - determine Outpost<&sp>Name

        - case redefine:
            - if <[args].size.is[OR_MORE].than[1]>:
                - determine Outpost<&sp>Name<&sp>[Spaces<&sp>Allowed]

    script:
    - if <player.proc[IsPlayerKingdomless]>:
        - narrate format:callout "You cannot use this command, you are not a member of a kingdom!"
        - stop

    - if <server.has_flag[PreGameStart]> && !<player.is_op>:
        - determine cancelled

    #------------------------------------------------------------------------------------------------------------------------

    - if <context.args.get[1]> == list:
        - run OutpostList def.player:<player>

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == showborder:
        - if <context.args.size.is[OR_MORE].than[2]>:
            - define param <context.args.get[2]>
            - define initialLoc <player.location>
            - define displayLength 30

            - if <context.args.size.is[MORE].than[2]>:
                - define displayLength <context.args.get[3]>

            - if <cuboid[<[param]>].exists>:
                # The base of the imaginary border blocks will be red wool starting at the player
                # y-position
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
        - flag <player> datahold.outpost:!

        # Give the player their blocks back
        - run LoadTempInventory def:<player>

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == delete:
        - if !<player.has_permission[kingdoms.outpost.delete]>:
            - narrate format:callout "You do not have sufficient permissions to delete an outpost! This must be performed by a higher-ranking member of your kingdom."
            - determine cancelled

        - if <player.has_flag[confirmOutpostDeletion]> && <context.args.get[2]> == confirm:
            - define name <proc[OutpostNameEscaper].context[<context.args.get[3].to[last].space_separated>]>
            - define kingdom <player.flag[kingdom]>

            # Clear outpost name if it exists under the player's kingdom
            - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[name]>]>:
                - narrate format:callout "There is no outpost by the name: <red><[name]>"
                - determine cancelled

            - run RemoveOutpost def.kingdom:<[kingdom]> def.outpost:<[name]>

            - narrate format:callout "Successfully deleted outpost by the name <[name]>"
            - narrate format:callout "45<&pc> of your outpost's usual daily upkeep has been returned to your kingdom."

            - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>

        - else:
            - narrate format:callout "Are you sure you would like to delete this outpost?"
            - narrate format:callout "Please type <element[outpost delete confirm <&lt>name<&gt>].color[red]> to confirm."
            - flag <player> confirmOutpostDeletion expire:10m

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == claim:
        - run TempSaveInventory def:<player>
        - give to:<player.inventory> slot:<player.held_item_slot> OutpostWand_Item

        - narrate format:callout "Use the outpost wand in your hotbar to define this outpost by clicking the intended corner blocks with it."
        - narrate format:callout "Alternatively, you can drop the wand to cancel the process."

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == redefine:
        - if <context.args.size.is[OR_LESS].than[1]>:
            - narrate format:callout "You must specify a name for the outpost being redefined"

        - define kingdom <player.flag[kingdom]>
        - define name <context.args.get[2].to[last].space_separated.trim>

        - if <proc[DoesOutpostExist].context[<[kingdom]>|<[name]>]>:
            - run TempSaveInventory def:<player>
            - give to:<player.inventory> slot:<player.held_item_slot> OutpostWand_Item

            - flag <player> datahold.outpost.redefiningOutpost:<[name]>

            - narrate format:callout "Use the outpost wand in your hotbar to redefine this outpost by clicking the intended corner blocks with it."
            - narrate format:callout "Alternatively, you can drop the wand to cancel the process."

        - else:
            - narrate format:callout "There exists no outpost by the name: <red><[name]>"


OutpostWand_Item:
    type: item
    material: spectral_arrow
    display name: <gold><bold>Outpost Wand


OutpostWand_Handler:
    type: world
    events:
        on player drops OutpostWand_Item:
        - flag <player> datahold.outpost.cornerOneDefined:!
        - flag <player> datahold.outpost.cornerTwoDefined:!

        - run LoadTempInventory def:<player>

        on player clicks OutpostWand_Item in inventory:
        - determine cancelled

        on player drags OutpostWand_Item in inventory:
        - determine cancelled

        on player clicks block with:OutpostWand_Item:
        - if !<player.has_flag[datahold.outpost.cornerOneDefined]>:
            - ratelimit <player> 1s

            # First corner selection and flagging player with its location
            - flag <player> datahold.outpost.cornerOneDefined:<context.location>
            - narrate format:callout "Please select the second corner of the outpost"

            - stop

        - define kingdom <player.flag[kingdom]>
        - define cornerOne <player.flag[datahold.outpost.cornerOneDefined]>
        - define cornerTwo <context.location>
        - define minCastleDistance <proc[GetConfigNode].context[Territory.minimum-outpost-distance]>

        - flag <player> datahold.outpost.cornerTwoDefined:<[cornerTwo]>

        # Cuboid object of the player's unfinalized outpost selection
        - define currOutpostSelection <cuboid[<player.location.world.name>,<[cornerOne].with_y[0].xyz>,<[cornerTwo].with_y[255].xyz>]>

        ## CLOSE TO CASTLE CHECK ##
        # Check outpost's distance to other kingdom claims
        - foreach <proc[GetAllClaims].exclude[<[kingdom].proc[GetClaims]>]>:
            - define chunkCenter <[value].cuboid.center>
            - define outpostDistance <[currOutpostSelection].center.distance[<[chunkCenter]>]>

            - if <[outpostDistance].is[OR_LESS].than[<[minCastleDistance]>]>:
                - flag <player> datahold.outpost.cornerOneDefined:!

                # Give error message and return the player's inventory
                - narrate format:callout "Your outpost is too close to another kingdom's territory!"
                - narrate format:callout "Your outpost must be - at minimum - <[minCastleDistance].color[red]> blocks away from another kingdom's territory."
                - run LoadTempInventory def:<player>

                - stop

        - foreach <proc[GetAllOutposts]> key:outpostName as:outpost:
            - if <[outpostName]> == <player.flag[datahold.outpost.redefiningOutpost].replace[ ].with[-]>:
                - foreach next

            - define outpostKingdom <[outpost].get[kingdom]>
            - define outpostWorld <proc[GetOutpostArea].context[<[kingdom]>|<[outpostName]>].world>

            # Put together the loop outpost as a cuboid object and check if it overlaps with the
            # player's current selection
            - define otherOutpostArea <proc[GetOutpostArea].context[<[outpostKingdom]>|<[outpostName]>]>

            # If the outpost overlaps with another outpost from any kingdom then cancel the
            # player's selection and return their inventory
            - if <[otherOutpostArea].intersects[<[currOutpostSelection]>]>:
                - flag <player> datahold.outpost.cornerOneDefined:!
                - flag <player> datahold.outpost.cornerTwoDefined:!

                - narrate format:callout "This selection overlaps with another outpost. Please select another location"

                - run LoadTempInventory def:<player>
                - stop

        - if <player.has_flag[datahold.outpost.cornerOneDefined]> && <player.has_flag[datahold.outpost.cornerTwoDefined]>:
            - define diffX <player.flag[datahold.outpost.cornerOneDefined].x.sub[<player.flag[datahold.outpost.cornerTwoDefined].x>].abs>
            - define diffZ <player.flag[datahold.outpost.cornerOneDefined].z.sub[<player.flag[datahold.outpost.cornerTwoDefined].z>].abs>
            - define size <[diffX].mul[<[diffZ]>]>

            - if <[size].is[MORE].than[<[kingdom].proc[GetKingdomOutpostMaxSize]>]>:
                - narrate format:callout "Outpost exceeds maximum size of: <red><[kingdom].proc[GetKingdomOutpostMaxSize]><&6>! Attempted claim size of: <red><[size]>"

                - flag <player> datahold.outpost.cornerOneDefined:!
                - flag <player> datahold.outpost.cornerTwoDefined:!

                - determine cancelled

            - define outpostCost <[size].mul[<server.flag[kingdoms.<[kingdom]>.outposts.costMultiplier].if_null[1]>].round>

            - if <[kingdom].proc[GetBalance].is[LESS].than[<[outpostCost]>]>:
                - narrate format:callout "This selection costs <element[$<[outpostCost].as_money>].color[red]> to claim. You do not have sufficient funds to claim it."

                - flag <player> datahold.outpost.cornerOneDefined:!
                - flag <player> datahold.outpost.cornerTwoDefined:!

                - determine cancelled

            - if <player.has_flag[datahold.outpost.redefiningOutpost]>:
                - flag <player> noChat.outposts.definingOutpost
                - flag <player> datahold.outpost.outpostAlreadyNamed

                - narrate format:callout "Are you sure you would like to redefine this outpost to these specifications? (yes/no)"

                - determine cancelled

            - flag <player> noChat.outposts.definingOutpost
            - flag <player> datahold.outpost.canNameOutpost

            - narrate format:callout "Please type in chat the name you would like to give this outpost or type 'cancel' (You can use spaces in the name):"

            - flag <player> datahold.outpost.outpostCost:<[outpostCost]>
            - flag <player> datahold.outpost.size:<[size]>

        on player chats flagged:noChat.outposts.definingOutpost:
        - define posOne <player.flag[datahold.outpost.cornerOneDefined]>
        - define posTwo <player.flag[datahold.outpost.cornerTwoDefined]>
        - define outpostCost <player.flag[datahold.outpost.outpostCost]>
        - define kingdom <player.flag[kingdom]>

        - if <context.message.to_lowercase> == cancel:
            - narrate format:callout "Cancelled outpost creation."

            - run LoadTempInventory def:<player>
            - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>

            - flag <player> datahold.outpost:!

            - determine cancelled

        - if <player.has_flag[datahold.outpost.canNameOutpost]>:
            - if !<server.has_flag[kingdoms.<[kingdom]>.outposts.outpostList.<context.message>]>:
                - define escapedName <proc[OutpostNameEscaper].context[<context.message>]>

                - run CreateOutpost def.kingdom:<[kingdom]> def.cornerList:<list[<[posOne]>|<[posTwo]>]> def.outpostName:<context.message>
                - narrate format:callout "Claimed outpst by the name: <context.message.color[red]>! Use <element[/outpost list].color[aqua]> to see outpost info."

            - else:
                - narrate format:callout "There is already an outpost by this name! Use <red>/outpost redefine <&6>or <red>/outpost rename to change an existing outpost"

        - else if <player.has_flag[datahold.outpost.outpostAlreadyNamed]>:
            - if <context.message.to_lowercase> == yes:
                - define outpostName <player.flag[datahold.outpost.redefiningOutpost]>
                - define newArea <cuboid[<player.world.name>,<[PosOne].as[location].x>,0,<[PosOne].as[location].z>,<[PosTwo].as[location].x>,255,<[PosTwo].as[location].z>]>
                - define escapedName <proc[OutpostNameEscaper].context[<[outpostName]>]>

                - run SetOutpostArea def.kingdom:<[kingdom]> def.outpost:<[escapedName]> def.newArea:<[newArea]>

                - flag <player> outpostAlreadyNames:!
                - narrate format:callout "Successfully made changes to outpost: <proc[GetOutpostDisplayName].context[<[kingdom]>|<[outpostName]>].color[red]>!"

            - else:
                - narrate format:callout "Changes reverted."

        - run LoadTempInventory def:<player>
        - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>

        - flag <player> datahold.outpost:!
        - flag <player> noChat.outposts.definingOutpost:!

        - determine cancelled


OutpostEntry_Handler:
    type: world
    debug: false
    events:
        on player enters cuboid:
        - define outpostHandlerQueue <util.queues.parse_tag[<[parse_value].script.name.equals[<script.name>]>].get[1].if_null[null]>

        - if <[outpostHandlerQueue]> != null:
            - queue stop <[outpostHandlerQueue]>

        - if !<context.area.note_name.starts_with[outpost]>:
            - stop

        - if <player.proc[IsPlayerKingdomless]>:
            - stop

        - define kingdom <player.flag[kingdom]>
        - define outpost <context.area.note_name.split[_].get[2]>
        - define outpostExists false
        - define whichKingdom null

        - foreach <proc[GetKingdomList]>:
            - if <proc[DoesOutpostExist].context[<[value]>|<[outpost]>]>:
                - define outpostExists true
                - define whichKingdom <[value]>

        - if !<[outpostExists]>:
            - stop

        - if <[whichKingdom]> == <[kingdom]>:
            - repeat 3:
                - actionbar "You are now entering the outpost: <[outpost].color[<proc[GetKingdomColor].context[<[whichKingdom]>]>]>"
                - wait 1s

        on player exits cuboid:
        - define outpostHandlerQueue <util.queues.parse_tag[<[parse_value].script.name.equals[<script.name>]>].get[1].if_null[null]>

        - if <[outpostHandlerQueue]> != null:
            - queue stop <[outpostHandlerQueue]>

        - if !<context.area.note_name.starts_with[outpost]>:
            - stop

        - if <player.proc[IsPlayerKingdomless]>:
            - stop

        - define kingdom <player.flag[kingdom]>
        - define outpost <context.area.note_name.split[_].get[2]>

        - if <proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
            - repeat 3:
                - actionbar "<red>Leaving outpost"
                - wait 1s
