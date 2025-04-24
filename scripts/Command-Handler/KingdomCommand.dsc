##
## * This file contains the command script which handles this /kingdom or /k command. This command
## * allows players to interact with the kingdom they are currently in. For the /kingdoms or /ks
## * command look for the KingdomsCommand.dsc file.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Aug 2020
## @Update 1: Mar 2021
## @Update 2: Apr-Jun 2022
## @Update 3: Dec 2023
## **** Note: This update entailed the splitting of the former CommandHandler.dsc file into smaller
## ****       sub-files containing each of the separate sub-commands (or sub-command groups) of the
## ****       /k and /ks command handlers. All of the subcommand should be found in their respecti-
## ****       -ve files under this folder.
##
## @Script Ver: v3.2
##
#- Note #1: The coreclaim/castleclaim system is just odd. Perhaps now is time to modernize it and
#-          implement something like a wand that lets you claim chunks, or some sort of a visual
#-          system involving a GUI...
##
## ------------------------------------------END HEADER-------------------------------------------


Help_Strings:
    type: data
    CommandHelpStrings:
        # coreclaim: Claims <element[core territory].color[red].on_hover[Territory classed as 'core' is always protected from other players except during times of war.]> for your kingdom. You need to the King or Vizier to do this action!
        # castleclaim: Claims <element[castle territory].color[red].on_hover[Your castle will always be protected from other players unless another kingdom has successfully escalated a war after sieging your core territory.]> for your kingdom. You need to the King to do this action!
        claim: Can be used to claim the two types of contigious territory in Kingdoms: core and castle.<n> Use: <element[/k claim <element[core].color[red].on_hover[Territory classed as 'core' is always protected from other players except during times of war.]>].color[gray]> or <element[/k claim <element[castle].color[red].on_hover[Your castle will always be protected from other players unless another kingdom has successfully escalated a war after sieging your core territory.]>].color[gray]>
        unclaim: Unclaims the chunk you are standing in if it is a part of your claims. You are refunded for its full upkeep value but not its upfront value.
        balance: Shows the joint kingdom bank account.
        deposit: Adds the specified amount of money to your kingdom's balance.
        duchy: Subcommand which handles all matters relating to the mangement of your kingdom's duchies- adding and removing them, setting dukes and managing their permissions.
        withdraw: Transfers the specified amount of money from the kingdom's balance to your personal account.
        trade: Initiates a trade with the specified player.
        rename: Renames the kingdom. <element[This command is restricted!].color[red].on_hover[Only the king can use this command with the the Game Czar's approval.]>
        npc: Use /k npc spawn to open the spawn menu for kingdom NPCs.
        warp: Takes you to your kingdom's private warp location. <red>Note that there is a 30 sec cooldown for this command.
        war: Subcommand which handles all aspects related to waging war against other kingdoms.
        ideas: Shows your kingdom's ideas. These are a number of buffs and debuffs that apply to kingdom depending on its character and history.
        outline: You can specify either 'castle' or 'core' to show you the bounds of both of those territorial units in your kingdom.
        guards: Will open your kingdom's guard window which will show all your guard NPCs, their location, status, and other information.
        help: That's so meta...

        travel: Upon selecting one of the options from the tab menu you will be teleported to that fast-travel location's designated waypoint. However you must discover an area first, before you travel to it.
        map: Displays the Kingdoms live map.
        rules: Displays the Kingdoms rules document.
        chunkmap: Displays an in-chat map of the surrounding chunks and their claim status.


Kingdom_Command:
    type: command
    debug: false
    usage: /kingdom
    name: kingdom
    description: Umbrella command for managing your own kingdom
    aliases:
        - k
    tab completions:
        1: help|claim|unclaim|balance|guards|deposit|withdraw|trade|rename|npc|warp|ideas|outline|influence|duchy|war
        2: help

    tab complete:
    - define kingdom <player.flag[kingdom]>
    - define args <context.raw_args.split_args.if_null[<list[null]>]>

    - if <[args].size> >= 1 && <[args].get[1]> == warp:
        - if <[args].get[2].is_in[allow|deny].if_null[false]>:
            - determine <proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomShortName]>]>

        - else if <[args].get[2].starts_with[kingdom<&co>].if_null[false]> && <server.flag[kingdoms.<[args].get[2].split[<&co>].get[2]>.openWarp].contains[<[kingdom]>]>:
            - define warpList <server.flag[kingdoms.<[kingdom]>.warps].keys>
            - determine <[warpList]>

        - define kingdomRealNames <proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomShortName]>]>
        - determine <list[set|remove|list|allow|deny].include[<server.flag[kingdoms.<[kingdom]>.warps].keys>].include[<[kingdomRealNames].parse_tag[<list[kingdom:|<[parse_value]>].unseparated>]>]>

    - else if <[args].get[1].to_lowercase> == claim:
        - determine <list[core|castle]>

    - else if <[args].get[1].to_lowercase> == duchy:
        - if <[args].size> == 1:
            - define tabCompletes <list[balance|deposit|withdraw|unclaim|tax|outline|list]>
            - define kingTabCompletes <list[create|remove|claim|setduke|removeduke]>

            - if <player.proc[IsPlayerKing]> || <player.is_op>:
                - define tabCompletes <[tabCompletes].include[<[kingTabCompletes]>]>

            - determine <[tabCompletes].alphabetical>

        - else if <[args].size> == 2:
            - if <[args].get[2].to_lowercase> == setduke:
                - determine <[kingdom].proc[GetKingdomDuchies]>

            - determine <[kingdom].proc[GetKingdomDuchies]>

        - else if <[args].size> == 3:
            - determine <[kingdom].proc[GetMembers].parse_tag[<[parse_value].name>]>

    - else if <[args].get[1].to_lowercase> == war:
        - if <[args].size> > 1:
            - if <[args].get[2].to_lowercase> == justify:
                - determine <proc[GetKingdomList].context[false]>

            - else if <[args].get[2].to_lowercase> == progress:
                - determine <[kingdom].proc[GetKingdomWars]>

        - determine <list[justify|progress]>

    script:
    - define kingdom <player.flag[kingdom]>
    - define args <context.raw_args.split_args>

    - if <[args].get[2]> == help:
        - if <script[Help_Strings].data_key[CommandHelpStrings].list_keys[].contains[<context.args.get[1]>]>:
            - narrate format:callout <script[Help_Strings].data_key[CommandHelpStrings.<context.args.get[1]>].parsed>

        - determine cancelled

    ## Note: Adding a case statement for a sub-command which already has its own sub-path will over-
    ##       ride its behavior.

    - choose <[args].get[1]>:
        - case help:
            - narrate format:callout "The /k command allows you to interact with most aspects of your kingdom such as finances, resources, trade and more."
            - narrate "<&n>                                       <&n.end_format>"
            - narrate <&sp>
            - narrate format:callout "<&r><italic>You can also type 'help' after each of the kingdom commands to learn more about them individually."

        - case trade:
            - narrate format:debug "Sub-command is being re-implemented."

        - case influence:
            - execute as_player influence

        - default:
            - if <[args].get[1].to_lowercase.is_in[<script.data_key[SubCommands].keys.parse_tag[<[parse_value]>]>]>:
                - inject <script.name> path:SubCommands.<[args].get[1].to_titlecase>

            - else:
                - narrate format:callout "<[args].get[1].color[red]> is not a recognized sub-command."

    SubCommands:
        Outline:
        - define param <[args].get[2]>
        - define hasTerritoryType false
        - define persistTime 10
        - define territoryType castle

        - if <[args].size.is[LESS].than[2]>:
            - narrate format:callout "Insufficient or too many parameters. Please specify either castle or core territory to outline"
            - determine cancelled

        - else if <[param].is_in[castle|core]>:
            - define territoryType <[param]>
            - define hasTerritoryType <proc[GetClaims].context[<[kingdom]>|<[param]>].get[1].cuboid.if_null[false]>

        - else:
            - narrate format:callout "<[param].to_titlecase> is not a valid territory type!"
            - determine cancelled

        - if !<[hasTerritoryType]>:
            - narrate format:callout "Your kingdom doesn't seem to have any <[param]> territory yet :/"
            - determine cancelled

        # If the player specificies a duration tag then check if the duration is more
        # than 0 and set persistTime as it

        - if <[args].size> >= 3 && <[args].get[3].starts_with[duration:]>:
            - define duration <[args].get[3].split[duration:].get[2]>

            # Ensure that if a duration is specified, it is less than 2min and more than 1s.
            # If player specifies invalid amount the whole command request is discarded

            - if <[duration].is[OR_MORE].than[1]> && <[duration].is[OR_LESS].than[120]>:
                - define persistTime <[duration]>

            - else:
                - narrate format:callout "Invalid duration! Please ensure that outline durations are between 1s and 120s."
                - determine cancelled

        - define claimsCuboid <proc[GetClaimsCuboid].context[<[kingdom]>|<[territoryType]>]>

        # Show the borders at different altitudes depending on if the player is flying or
        # on the ground

        - if <player.is_flying>:
            - showfake green_stained_glass <[claimsCuboid].outline_2d[<player.location.y.sub[10]>]> duration:<[persistTime]>

        - else:
            - showfake red_stained_glass <[claimsCuboid].outline_2d[<player.location.y.add[20]>]> duration:<[persistTime]>

        #------------------------------------------------------------------------------------------

        Duchy:
        - define action <[args].get[2]>
        - define duchy null if:<[args].size.is[LESS].than[2]>
        - define duchy <[args].get[3]>
        - define duchy null if:<[args].size.is[LESS].than[3]>
        - define chunk <player.location.chunk>

        - if <[action].to_lowercase> == list:
            - run DuchyListSubcommand def.kingdom:<[kingdom]> def.player:<player>
            - stop

        - if !<[duchy].is_truthy>:
            - narrate format:callout "You must provide a name for the duchy affecting."
            - stop

        - if <[duchy]> == null:
            - narrate format:callout "You cannot use that name in this sub-command."
            - stop

        - choose <[action].to_lowercase>:
            - case claim:
                - if !<player.proc[IsPlayerKing]>:
                    - stop

                - if !<proc[GetClaims].context[<[kingdom]>|core].contains[<[chunk]>]>:
                    - narrate format:callout "You cannot designate a non-core chunk as a duchy claim."
                    - stop

                - if !<[kingdom].proc[GetKingdomDuchies].contains[<[duchy]>]>:
                    - narrate format:callout "Provided name: <[duchy].color[red]> does not belong to a valid duchy in your kingdom!"
                    - stop

                - run AddDuchyClaim def.kingdom:<[kingdom]> def.chunk:<[chunk]> def.duchy:<[duchy]> save:res

                - if <entry[res].created_queue.determination.get[1].if_null[success]> == null:
                    - stop

                - narrate format:callout "Claimed your current chunk for <[duchy].color[aqua]>"

            - case unclaim:
                - if !<[kingdom].proc[GetKingdomDuchies].contains[<[duchy]>]>:
                    - narrate format:callout "Provided name: <[duchy].color[red]> does not belong to a valid duchy in your kingdom!"
                    - stop

                - run RemoveDuchyClaim def.kingdom:<[kingdom]> def.duchy:<[duchy]> def.chunk:<[chunk]> save:res

                - if <entry[res].created_queue.determination.get[1].if_null[success]> == null:
                    - stop

                - narrate format:callout "Unclaimed your current chunk from <[duchy].color[aqua]>. It will go back to being a normal core chunk."

            - case create:
                - if !<player.proc[IsPlayerKing]>:
                    - stop

                - run AddDuchy def.kingdom:<[kingdom]> def.duchy:<[duchy]> save:res

                - if <entry[res].created_queue.determination.get[1].if_null[success]> == null:
                    - stop

                - narrate format:callout "Successfully created a duchy with the name: <[duchy].color[aqua]>"
                - narrate format:callout "<element[But keep in mind!].color[red].bold> You will still need to use <element[/k duchy claim <&dq><[duchy]><&dq>].color[gray]> to claim the chunk you are standing in for this duchy."

            - case remove:
                - if !<player.proc[IsPlayerKing]>:
                    - stop

                - if !<player.flag[datahold.duchies.confirmDuchyDeletion].equals[<[duchy]>].if_null[false]>:
                    - narrate format:callout "To confirm that you would like to remove all the claims of the duchy with the name: <[duchy].color[light_purple]>, please type this command again."
                    - flag <player> datahold.duchies.confirmDuchyDeletion:<[duchy]>

                - run RemoveDuchy def.kingdom:<[kingdom]> def.duchy:<[duchy]> save:res

                - if <entry[res].created_queue.determination.get[1].if_null[success]> == null:
                    - stop

                - narrate format:callout "Successfully removed duchy with the name: <[duchy].color[aqua]> and all data associated with it."

                - flag <player> datahold.duchies.confirmDuchyDeletion:!

            # TODO: (Later) I may need to set a cooldown for both of these subcommands. I can see
            # TODO/ them being abused quite easily.
            - case setduke:
                - if !<player.proc[IsPlayerKing]>:
                    - stop

                - define player <[args].get[4]>

                - if !<[player].as[player].exists>:
                    - narrate format:callout "Please provide the name of a valid player to make duke of this duchy."
                    - stop

                - run SetDuke def.kingdom:<[kingdom]> def.duchy:<[duchy]> def.player:<[player].as[player]> save:res

                - if <entry[res].created_queue.determination.get[1].if_null[success]> == null:
                    - stop

                - narrate format:callout "Successfully set player: <[player].color[aqua]> as the duke of <[duchy].color[aqua]>."

            - case removeduke:
                - if !<player.proc[IsPlayerKing]>:
                    - stop

                - define player <proc[GetDuke].context[<[kingdom]>|<[duchy]>]>

                - if !<[player].is_truthy>:
                    - narrate format:callout "The provided duchy already does not have a duke!"
                    - stop

                - run RemoveDuke def.kingdom:<[kingdom]> def.duchy:<[duchy]> save:res

                - if <entry[res].created_queue.determination.get[1].if_null[success]> == null:
                    - stop

                - narrate format:callout "Successfully removed player: <[player].color[aqua]> from their role as the duke of <[duchy].color[aqua]>."

            - case tax:
                - if <[args].size> < 4:
                    - narrate format:callout "Your duchy's current tax obligation to <[kingdom].proc[GetKingdomName]> is: <aqua><[kingdom].proc[GetDuchyTaxRate].context[<[duchy]>]>%"

                - if !<player.proc[IsPlayerKing]>:
                    - stop

                - define taxRate <[args].get[4]>

                - if !<[taxRate].is_decimal>:
                    - narrate format:callout "You cannot set the duchy's tax rate to a non-numerical amount."
                    - stop

                - if <[taxRate]> > 100 || <[taxRate]> < 0:
                    - narrate format:callout "The duchy tax rate is formatted as a percentage. Please input an amount between 0 and 100."
                    - stop

                - run SetDuchyTaxRate def.kingdom:<[kingdom]> def.duchy:<[duchy]> def.amount:<[taxRate].div[100]>
                - narrate format:callout "Set the tax rate for this duchy to: <aqua><[taxRate]>%."
                - narrate format:callout "The default taxation rate for duchies in your kingdom is: <green><[kingdom].proc[GetKingdomDuchies].parse_tag[<[kingdom].proc[GetDuchyTaxRate].context[<[duchy]>].if_null[0].mul[100]>].average>%"

                - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>

            - case balance:
                - narrate format:callout "Balance for: <[duchy].color[aqua]> is: <aqua>$<[kingdom].proc[GetDuchyBalance].context[<[duchy]>].format_number>"

            - case deposit:
                - define amount <[args].get[4]>

                - if !<[amount].is_decimal>:
                    - narrate format:callout "You cannot deposit a non-numerical amount."
                    - stop

                - if <[amount]> <= 0:
                    - narrate format:callout "You must deposit an amount greater than 0."
                    - narrate format:callout "To take money out of your duchy's bank, use: <element[/k duchy withdraw (duchy) (amount)].color[gray]>"
                    - stop

                - if <player.money> < <[amount]>:
                    - narrate format:callout "You do not have sufficient funds in your personal account to deposit this in your duchy's bank."
                    - stop

                - run SetDuchyBalance def.kingdom:<[kingdom]> def.duchy:<[duchy]> def.amount:<[kingdom].proc[GetDuchyBalance].context[<[duchy]>].add[<[amount]>]>
                - money take players:<player> quantity:<[amount]>

                - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>

                - narrate format:callout "Successfully added: <element[$<[amount].format_number>].color[aqua]> to the duchy bank."

            - case withdraw:
                - define amount <[args].get[4]>

                - if !<[amount].is_decimal>:
                    - narrate format:callout "You cannot deposit a non-numerical amount."
                    - stop

                - if <[amount]> <= 0:
                    - narrate format:callout "You must withdraw an amount greater than 0."
                    - narrate format:callout "To put money into your duchy's bank, use: <element[/k duchy deposit (duchy) (amount)].color[gray]>"
                    - stop

                - define balance <[kingdom].proc[GetDuchyBalance].context[<[duchy]>]>

                - if <[balance]> < <[amount]>:
                    - narrate format:callout "Your duchy does not have enough funds to withdraw this amount from its bank."
                    - stop

                - run SetDuchyBalance def.kingdom:<[kingdom]> def.duchy:<[duchy]> def.amount:<[balance].sub[<[amount]>]>
                - money give players:<player> quantity:<[amount]>

                - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>

                - narrate format:callout "Successfully removed: <element[$<[amount].format_number>].color[aqua]> from the duchy bank."

            - case outline:
                - define duration <[args].get[4].replace[duration:].if_null[20s]>

                - if <[duration].is[OR_MORE].than[1]> && <[duration].is[OR_LESS].than[120]>:
                    - define persistTime <[duration]>

                - else:
                    - narrate format:callout "Invalid duration! Please ensure that outline durations are between 1s and 120s."
                    - determine cancelled

                - define duration <[duration].as[duration]>
                - define claims <[kingdom].proc[GetDuchyTerritory].context[<[duchy]>]>
                - define claimCuboid <[claims].get[1].cuboid>

                - foreach <[claims].remove[1]> as:claim:
                    - define claimCuboid <[claimCuboid].add_member[<[claim].cuboid>]>

                - if <player.is_flying>:
                    - showfake green_stained_glass <[claimCuboid].outline_2d[<player.location.y.sub[20]>]> duration:<[duration]>

                - else:
                    - showfake red_stained_glass <[claimCuboid].outline_2d[<player.location.y.add[20]>]> duration:<[duration]>

            - default:
                - narrate format:callout "Unrecognized argument: <[action].color[red]>"

        #------------------------------------------------------------------------------------------

        Claim:
        - define territoryType <[args].get[2]>

        - if !<[territoryType].to_lowercase.is_in[core|castle]>:
            - narrate format:callout "Invalid claiming type. Valid claiming types are either: <element[castle].color[red]> or <element[core].color[red]>"
            - determine cancelled

        - run TerritoryClaim def.claimingMode:<[territoryType]> def.kingdom:<[kingdom]> def.chunk:<player.location.chunk>

        #------------------------------------------------------------------------------------------

        Unclaim:
        - define coreCastle <[kingdom].proc[GetClaims].if_null[<list[]>]>

        - if !<player.location.chunk.is_in[<[coreCastle]>]>:
            - narrate format:callout "This chunk is not in your claims."
            - determine cancelled

        - run RemoveClaim def.kingdom:<[kingdom]> def.chunk:<player.location.chunk>

        - if <proc[GetClaims].context[<[kingdom]>|core].size> <= 20:
            - run SubUpkeep def.kingdom:<[kingdom]> def.amount:5

        - else:
            - run SubUpkeep def.kingdom:<[kingdom]> def.amount:30

        - narrate format:callout "Unclaimed chunk: <element[<player.location.chunk.x>, <player.location.chunk.z>].color[red]>"

        - ~run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>

        #------------------------------------------------------------------------------------------

        Layclaim:
        - narrate "Making unofficial claim to: <player.location.chunk>"
        - flag server kingdoms.<player.flag[kingdom]>.unofficial_claim:->:<player.location.chunk>

        #------------------------------------------------------------------------------------------

        Balance:
        - narrate format:callout "Balance for <[kingdom].proc[GetKingdomName]> is <red>$<[kingdom].proc[GetBalance].format_number>"

        #------------------------------------------------------------------------------------------

        Deposit:
        - define amount <context.args.get[2]>

        - if <player.money.is[OR_MORE].than[<[amount]>]>:
            - run AddBalance def.kingdom:<[kingdom]> def.amount:<[amount]>
            - money take from:<player> quantity:<[amount]>

            - narrate format:callout "Successfully deposited: <red>$<[amount].as_money>"

        - else:
            - narrate format:callout "You do not have sufficient funds to perform this action."

        # if the kingdom was previously indebted but has now pushed back
        # into the positives then clear its debt status from the appropriate
        # flag on the server

        - if <server.flag[indebtedKingdoms].get[<player.flag[kingdom]>].exists>:
            - if <[kingdom].proc[GetBalance].is[OR_MORE].than[0]>:
                - flag server indebtedKingdoms.<player.flag[kingdom]>:0

        - ~run SidebarLoader def.target:<proc[GetMembers].context[<[kingdom]>].include[<server.online_ops>]>

        #------------------------------------------------------------------------------------------

        Withdraw:
        - define amount <context.args.get[2]>

        - if <[kingdom].proc[GetBalance].is[OR_MORE].than[<[amount]>]>:
            - money give to:<player> quantity:<[amount]>
            - run SubBalance def.kingdom:<[kingdom]> def.amount:<[amount]>

            - narrate format:callout "Successfully withdrawn: <red>$<[amount].as_money>"

        - else:
            - narrate format:callout "You do not have sufficient funds in your kingdom to withdraw"

        - ~run SidebarLoader def.target:<proc[GetMembers].context[<[kingdom]>].include[<server.online_ops>]>

        #------------------------------------------------------------------------------------------

        Rename:
        - if <player.has_permission[kingdom.canrename]>:
            - define newName <context.raw_args.split[rename].get[2]>
            - flag server kingdoms.<player.flag[kingdom]>.name:<[newName]>

            - narrate format:debug <context.raw_args.split[rename].get[2]>

        - ~run SidebarLoader def.target:<proc[GetMembers].context[<[kingdom]>].include[<server.online_ops>]>

        - else:
            - narrate format:callout "This command requires permission from the server owner to perform!"

        #------------------------------------------------------------------------------------------

        Npc:
        - if <server.has_flag[PreGameStart]> && !<player.is_op>:
            - narrate format:callout "Sorry! You cannot use this while the server is still in build mode!"
            - determine cancelled

        - define coreLoc <proc[GetClaims].context[<[kingdom]>|core].as[list]>
        - define castleLoc <proc[GetClaims].context[<[kingdom]>|castle].as[list]>
        - define isInClaimedLoc <[coreLoc].include[<[castleLoc]>].contains[<player.location.chunk>].if_null[false]>

        # Only allow players to spawn in NPCs if they are in their own
        # kingdom's territory

        - if !<[isInClaimedLoc]>:
            - foreach <[kingdom].proc[GetOutposts]>:
                - if <[value].get[area].contains[<player.location>]>:
                    - define isInClaimedLoc true

        # Gives the player an info message if they've never opened
        # the npc window before

        - if <[isInClaimedLoc]>:
            - if !<player.has_flag[OpenedSpawnWindow]>:
                - narrate format:callout "Note: using the 'spawn' command will cause a kingdom NPC to be spawned directly at your position."
                - narrate format:callout "If you are not standing at the desired location of the NPC. Please close the window and move."
                - wait 6s

            # Found in: RNPCCommands.dsc
            - inventory open d:RNPCSpawn_Window
            - flag player OpenedSpawnWindow

        - else:
            - narrate format:callout "You must spawn resource NPCs within core territory of your kingdom or in outposts!"

        #------------------------------------------------------------------------------------------

        Warp:
        - inject KingdomWarp_Subcommand

        #------------------------------------------------------------------------------------------

        War:
        - define action <[args].get[2].if_null[null]>

        - choose <[action].to_lowercase>:
            - case justify:
                - if <[args].get[3].exists> && <[args].get[3].to_lowercase> == cancel:
                    - define target <[args].get[4]>
                    - define targetKingdomCode <[target].proc[GetKingdomCode]>

                    - if <[targetKingdomCode]> == null:
                        - narrate format:callout "Unrecognized kingdom name: <[target].color[red]>. Please try again."
                        - stop

                    - if <player.has_flag[datahold.war.cancelJustification]>:
                        - run CancelJustification def.kingdom:<[kingdom]> def.targetKingdom:<[targetKingdomCode]> save:result

                        - if <entry[result].created_queue.determination.get[1].is_truthy>:
                            - narrate format:callout "Cancelled justification against: <[target].color[aqua]>. The peace shall remain for now."
                            - narrate <n>
                            - wait 1s
                            - narrate format:callout "<gray><italic>All war represents a failure of diplomacy. ~ Tony Benn"

                - inventory open d:JustificationKingdom_Window

            - case progress:
                - if <[args].get[3].exists>:
                    - define warID <[args].get[3]>
                    - narrate format:debug WIP

                - define allWars <[kingdom].proc[GetKingdomWars]>
                - define warList <list[]>

                - foreach <[allWars]> as:warID:
                    - define warItem <item[iron_sword]>

                    - run SetWarName def.warID:<[warID]> def.newName:<element[The <[warID].proc[GetWarBelligerents].get[1].proc[GetKingdomShortName]>-<[warID].proc[GetWarRetaliators].proc[GetKingdomShortName]> War]> if:<[warID].proc[GetWarName].equals[null]>
                    - define warName <[warID].proc[GetWarName]>

                    - definemap lore:
                        1: <element[Belligerents: ]><n><element[    - ].color[aqua]><[warID].proc[GetWarBelligerents].parse_tag[<[parse_value].proc[GetKingdomName]>].separated_by[<n>    - ].color[aqua].italicize>
                        2: <element[Retaliators: ]><n><element[    - ].color[aqua]><[warID].proc[GetWarRetaliators].parse_tag[<[parse_value].proc[GetKingdomName]>].separated_by[<n>    - ].color[aqua].italicize>

                    - adjust def:warItem display:<[warName].proc[ConvertToSkinnyLetters].color[white].bold>
                    - adjust def:warItem lore:<[lore].values>
                    - adjust def:warItem lore:<[warItem].lore.include[|<element[warID: <[warID]>].color[gray]>]>
                    - adjust def:warItem hides:ALL
                    - adjust def:warItem flag:warID:<[warID]>

                    - define warList:->:<[warItem]>

                - run PaginatedInterface def.itemList:<[warList]> def.page:1 def.player:<player> def.flag:warProgress def.title:<element[All Wars - <[kingdom].proc[GetKingdomShortName]>]>

            - case surrender:
                - narrate WIP

                # TODO: see if there are any checks that need to be made before the player can
                # TODO/ justify willy-nilly

        #------------------------------------------------------------------------------------------

        Ideas:
        - if <script[Kingdom_Ideas].list_keys[].contains[<player.flag[kingdom]>]>:

            # A whole lotta formatting crap here;
            # This command will write out the kingdom's buffs and debuffs like this:
            # Kingdom Ideas for: <bold>[KINGDOM]
            # <green/bold>[BUFF NAME]
            # <gray>[BUFF DESCRIPTION]
            # <red/bold>[DEBUFF NAME]
            # <gray>[DEBUFF DESCRIPTION]

            - narrate "<&n>                                       <&n.end_format>"
            - narrate <&sp>
            - narrate "<bold>Kingdom Ideas for: <proc[GetKingdomName].context[<[kingdom]>]>"
            - narrate "<&n>                                       <&n.end_format>"
            - narrate <&sp>
            - narrate <&n><green><bold><script[Kingdom_Ideas].data_key[<[kingdom]>.buff.name]><&n.end_format>
            - narrate <gray><script[Kingdom_Ideas].data_key[<[kingdom]>.buff.desc]>
            - narrate <&sp>
            - narrate <&n><red><bold><script[Kingdom_Ideas].data_key[<[kingdom]>.debuff.name]><&n.end_format>
            - narrate <gray><script[Kingdom_Ideas].data_key[<[kingdom]>.debuff.desc]>
            - narrate "<&n>                                       <&n.end_format>"
            - narrate <&sp>

        - else:
            - narrate format:callout "<red>Your kingdom doesn't seem to have any national ideas..."

        #------------------------------------------------------------------------------------------

        Guards:
        - if <context.args.get[2]> == list || <context.args.size> == 1:
            - define kingdomGuardList <list[]>

            - foreach <server.flag[kingdoms.<[kingdom]>.castleGuards]> as:guard:
                - if <[guard].flag[kingdom]> == <[kingdom]>:
                    - define guardItem <item[GuardList_Item]>
                    - define kingdomColor <proc[GetKingdomColor].context[<[kingdom]>]>

                    - adjust def:guardItem skull_skin:<[guard].skull_skin>
                    - adjust def:guardItem display:<element[<[guard].name>].bold.color[<[kingdomColor]>]>
                    - adjust def:guardItem lore:|<element[Location: ].bold.color[white]><element[<[guard].location.round.xyz>].color[aqua]>
                    - flag <[guardItem]> referencedGuard:<[guard]>

                    - define kingdomGuardList:->:<[guardItem]>

            - run New_Paginate_Task def.itemList:<[kingdomGuardList]> def.itemsPerPage:36 def.page:1 save:paginate
            - define paginatedGuardList <entry[paginate].created_queue.determination.get[1]>

            - flag <player> guardListPage:1
            - flag <player> kingdomGuardItems:<[paginatedGuardList]>
            - inventory open d:KingdomGuardList_Window


KingdomWarp_Subcommand:
    type: task
    script:
        # If the player has recently engaged in combat with another player then
        # they will not be allowed to use or set warps
        - if <player.has_flag[combatMode]>:
            - narrate format:callout "You may not use warps, you are in <red>combat mode!"

        # If the player specifies any parameter for the command
        - define param <context.args.get[2].if_null[main]>
        - define validParams <list[set|remove|kingdom<&co>|list|allow|deny]>

        - if <[param]> == set:
            # If the player does not specify a specific warp name the game will assume
            # they are trying to reset their main castle spawn.
            - define warpName <context.raw_args.split_args.get[3].if_null[main]>

            - if <[warpName].is_in[<[validParams]>]>:
                - narrate format:callout "<[warpName].color[red]> is a reserved word and cannot be used to name a warp. Try another name."
                - stop

            - define castle <proc[GetClaims].context[<[kingdom]>|castle].as[list]>
            - define core <proc[GetClaims].context[<[kingdom]>|core].as[list]>
            - define castleCore <[core].include[<[castle]>].exclude[0]>
            - define outpostAreas <[kingdom].proc[GetOutposts].values.parse_tag[<[parse_value].get[area]>]>
            - define inWhichOutpostAreas <[outpostAreas].filter_tag[<[parse_value].contains[<player.location>]>]>

            - if <[warpName]> != main:
                - if <[castleCore].contains[<player.location.chunk>]> || <[inWhichOutpostAreas].size> > 0:
                    - flag server kingdoms.<[kingdom]>.warps.<[warpName]>:<player.location.center>

                - else:
                    - narrate format:callout "Regular kingdom warps must be within castle, core, or outpost territory"

                - stop

            - if !<[castle].contains[<player.location.chunk>]>:
                - narrate format:callout "You must place your kingdom's main warp location inside your castle territory!"
                - stop

            - clickable save:confirm_warp until:1m usages:1:
                - flag server kingdoms.<[kingdom]>.warps.main:<player.location.center>
                - narrate format:callout "Warp location has been set to: <aqua><player.location.round.xyz>"

            - clickable save:decline_warp until:1m usages:1:
                - narrate format:callout "Cancelled warp creation."
                - clickable cancel:<entry[confirm_warp].id>

            - narrate format:callout "Not specifying a name for the warp will change your main kingdom warp. Are you sure you would like to do this?"
            - narrate format:callout "<element[YES].bold.underline.on_click[<entry[confirm_warp].command>]> / <element[NO].bold.underline.on_click[<entry[decline_warp].command>]>"

        - else if <[param]> == remove:
            - if <context.raw_args.split_args.size> < 3:
                - narrate format:callout "You must provide a name for the warp you wish to remove."
                - stop

            - define warpName <context.raw_args.split_args.get[3]>

            - if !<server.has_flag[kingdoms.<[kingdom]>.warps.<[warpName]>]>:
                - narrate format:callout "Your kingdom does not seem to have a warp by that name."
                - stop

            - flag server kingdoms.<[kingdom]>.warps.<[warpName]>:!
            - narrate format:callout "Removed warp with the name: <[warpName].color[aqua]>"

        - else if <[param].starts_with[kingdom<&co>]>:
            - define chosenKingdomRN <[param].split[<&co>].get[2]>
            - define warpName <context.args.get[3].if_null[main]>
            - define kingdomRealNames <proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomShortName]>]>
            - define chosenKingdomCN <script[KingdomRealNames].data_key[ShortNames].invert.get[<[chosenKingdomRN]>]>

            - if <[chosenKingdomRN]> == <[kingdom].proc[GetKingdomShortName]>:
                - narrate format:callout "You do not need to specify the kingdom when teleporting to your own warps."
                - determine cancelled

            - if !<[chosenKingdomRN].is_in[<[kingdomRealNames]>]>:
                - narrate format:callout "Invalid kingdom name."
                - stop

            - if !<server.flag[kingdoms.<[chosenKingdomCN]>.openWarp].contains[<[kingdom]>]>:
                - narrate format:callout "The kingdom specified has not opened its warps to you."
                - stop

            - if !<server.flag[kingdoms.<[chosenKingdomCN]>.warps.<[warpName]>].exists>:
                - narrate format:callout "Unknown warp. Ensure that the chosen kingdom has a warp with this name."
                - stop

            - define warpLoc <server.flag[kingdoms.<[chosenKingdomCN]>.warps.<[warpName]>]>
            - narrate format:callout "Warping in 3 seconds..."
            - chunkload add <[warpLoc].chunk> duration:1m

            - wait 3s

            - teleport <player> <[warpLoc]>

        - else if <[param]> == list:
            - if !<server.flag[kingdoms.<[kingdom]>.warps].as[list].get[1].exists>:
                - narrate format:callout "Your kingdom doesn't have any warps! Consider setting a private castle warp by standing in the desired warp location and typing <aqua>/k warp set"
                - stop

            - foreach <server.flag[kingdoms.<[kingdom]>.warps].to_pair_lists> as:warp:
                - narrate "<green>--<&gt> <[warp].get[1].color[aqua].bold><&co> <[warp].get[2].round.simple>"

        - else if <[param]> == deny:
            - define kingdomCodeName <script[KingdomRealNames].data_key[ShortNames].invert.get[<context.args.get[3]>]>

            - if !<server.flag[kingdoms.<[kingdom]>.openWarp].contains[<[kingdomCodeName]>]>:
                - narrate format:callout "That kingdom was already not on your kingdom's warp whitelist."
                - stop

            - flag server kingdoms.<[kingdom]>.openWarp:<-:<[kingdomCodeName]>
            - narrate format:callout "Removed kingdom: <context.args.get[3].color[red].bold> from your warp whitelist!"

        - else if <[param]> == allow:
            - define kingdomRealNames <proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomShortName]>]>
            - define kingdomCodeNames <proc[GetKingdomList]>

            - if !<context.args.get[3].exists>:
                - define openWarp <server.flag[kingdoms.<[kingdom]>.openWarp]>

                - if <[openWarp].size.if_null[0]> == 0:
                    - narrate format:callout "Your kingdom has its warps closed to all kingdoms"

                - else:
                    - narrate format:callout "Kingdoms that can access your warps:<n><server.flag[kingdoms.<[kingdom]>.openWarp].parse_tag[<proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomShortName]>]>].separated_by[<n>]>"

            - else if <[kingdomRealNames].contains[<context.args.get[3]>]>:
                - define index <[kingdomRealNames].find[<context.args.get[3]>]>

                - if <[kingdomCodeNames].get[<[index]>]> != <[kingdom]>:
                    - define codeNameChosenKingdom <[kingdomCodeNames].get[<[index]>]>
                    - flag server kingdoms.<[kingdom]>.openWarp:->:<[codeNameChosenKingdom]>
                    - flag server kingdoms.<[kingdom]>.openWarp:<server.flag[kingdoms.<[kingdom]>.openWarp].deduplicate>
                    - narrate format:callout "Now allowing members of: <context.args.get[3].color[red].bold> to warp to your kingdom."

                - else:
                    - narrate format:callout "Please specify a kingdom other than your own"

        - else:
            - if <server.has_flag[kingdoms.<[kingdom]>.warps.<[param]>]>:
                - narrate format:callout "Warping in 3 seconds..."
                - chunkload add <server.flag[kingdoms.<[kingdom]>.warps.<[param]>].chunk> duration:1m

                - wait 3s

                - teleport <player> <server.flag[kingdoms.<[kingdom]>.warps.<[param]>]>

            - else if <server.has_flag[kingdoms.<[kingdom]>.warps]>:
                - narrate format:callout "Warping in 3 seconds..."
                - chunkload add <server.flag[kingdoms.<[kingdom]>.warps.main].chunk> duration:1m

                - wait 3s

                - teleport <player> <server.flag[kingdoms.<[kingdom]>.warps.main]>

            - else:
                - narrate format:callout "Your kingdom does not currently have a warp location. You may want to speak to your king about this."