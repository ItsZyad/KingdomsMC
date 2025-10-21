##
## * This file contains the command script which handles this /kingdom or /k command. This command
## * allows players to interact with the kingdom they are currently in. For the /kingdoms or /ks
## * command look for the KingdomsCommand.dsc file.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Aug 2020
## <------------------<-->---------------------->
## @Update 1: Mar 2021
## @Update 2: Apr-Jun 2022
## @Update 3: Dec 2023
## **** Note: This update entailed the splitting of the former CommandHandler.dsc file into smaller
## ****       sub-files containing each of the separate sub-commands (or sub-command groups) of the
## ****       /k and /ks command handlers. All of the subcommand should be found in their respecti-
## ****       -ve files under this folder.
## <------------------<-->---------------------->
##
## @Script Ver: v3.2
##
#- Note #1: The coreclaim/castleclaim system is just odd. Perhaps now is time to modernize it and
#-          implement something like a wand that lets you claim chunks, or some sort of a visual
#-          system involving a GUI...
##
## |------------------------------------------END HEADER------------------------------------------|


Kingdom_Command:
    type: command
    debug: false
    usage: /kingdom
    name: kingdom
    description: Umbrella command for managing your own kingdom. Use '/k help' or '/k [command] help' for more info.
    data:
        CommandHelpStrings:
            balance: Shows the joint kingdom bank account.
            claim: Can be used to claim the two types of contigious territory in Kingdoms: core and castle.<n> Use: <element[/k claim <element[core].color[red].on_hover[Territory classed as 'core' is always protected from other players except during times of war.]>].color[gray]> or <element[/k claim <element[castle].color[red].on_hover[Your castle will always be protected from other players unless another kingdom has successfully escalated a war after sieging your core territory.]>].color[gray]>
            color: Changes the kingdom's color.
            create: Creates a new kingdom with the attached player as king. Can only be used by kingdomless players.
            credits: Shows the Kingdoms development credits.
            chunkmap: Displays an in-chat map of the surrounding chunks and their claim status.
            delete: Deletes the player's kingdom. Requires confirmation. Can only be used by the king.
            deposit: Displays an interface which lets you add resources to your kingdom vault. Beware, however, some resources can only be deposited a certain number of times per day.
            description: Displays or sets your kingdom's description line. Use: <element[/k description [description]].color[gray]> to set.
            guards: Will open your kingdom's guard window which will show all your guard NPCs, their location, status, and other information.
            help: That's so meta...
            info: Displays your server's Kingdoms information document (external link).
            invite: Allows a member to invite a player to their kingdom. Use: <element[/k invite [player name]].color[gray]>.
            join: Allows a player to accept an invite request made to them by a kingdom. Use: <element[/k join [kingdom name]].color[gray]> to specify which kingdom to join.
            leave: Allows a member to leave the kingdom they are currently a part of.
            # map: Displays the Kingdoms live map.
            members: Displays a list of the players who are currently members of your kingdom.
            npc: Use /k npc spawn to open the spawn menu for kingdom NPCs.
            outline: You can specify either 'castle' or 'core' to show you the bounds of both of those territorial units in your kingdom.
            promote: Promotes a player to replace the current king. Only the king of a kingdom can do this action by using <element[/k promote [player]].color[gray]>.
            rename: Renames your kingdom to the provided name. Only the king can use this command.
            unclaim: Unclaims the chunk you are standing in if it is a part of your claims. You are refunded for its full upkeep value but not its upfront value.
            war: Subcommand which handles all aspects related to waging war against other kingdoms.
            warp: Takes you to your kingdom's private warp location. <red>Note that there is a 30 sec cooldown for this command.

    aliases:
        - k

    tab complete:
    - define args <context.raw_args.split_args>

    - if !<player.exists>:
        - define kingdom <[args].filter_tag[<[filter_value].starts_with[kingdom:]>].get[1].split[:].get[2].if_null[null]>
        - define args <[args].exclude[kingdom:<[kingdom]>]>

    - if <player.proc[IsPlayerKingdomless]>:
        - determine <list[create|help|info|list]>

    - else:
        - define kingdom <player.flag[kingdom]>

    - if <[args].size> == 0:
        - determine <script.data_key[data.CommandHelpStrings].keys>

    - if <[args].get[1]> == warp && <context.raw_args.ends_with[ ]>:
        - if <[args].get[2].is_in[allow|deny].if_null[false]>:
            - determine <proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomShortName]>]>

        - else if <[args].get[2].starts_with[kingdom<&co>].if_null[false]> && <server.flag[kingdoms.<[args].get[2].split[<&co>].get[2]>.openWarp].contains[<[kingdom]>]>:
            - define warpList <server.flag[kingdoms.<[kingdom]>.warps].keys>
            - determine <[warpList]>

        - define kingdomRealNames <proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomShortName]>]>
        - determine <list[set|remove|list|allow|deny].include[<server.flag[kingdoms.<[kingdom]>.warps].keys>].include[<[kingdomRealNames].parse_tag[<list[kingdom:|<[parse_value]>].unseparated>]>]>

    - else if <[args].get[1].to_lowercase> == claim:
        - determine <list[core|castle]>

    - else if <[args].get[1].to_lowercase> == invite:
        - determine <server.online_players.exclude[<[kingdom].proc[GetMembers]>].parse_tag[<[parse_value].name>]>

    - else if <[args].get[1].to_lowercase> == delete:
        - determine <list[cancel]>

    - else if <[args].get[1].to_lowercase> == join:
        - determine <player.flag[kingdomInvite].if_null[<list[]>].parse_tag[<[parse_value].proc[GetKingdomName]>]>

    - else if <[args].get[1].to_lowercase> == color:
        - determine <util.color_names.include[[#Hex Code]].exclude[transparent]>

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
                - if <[args].get[3].if_null[null]> == cancel:
                    - determine <proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomShortName]>]>

                - determine <list[cancel]>

            # TODO:
            # For console-side access to this command, the admin can input /k war progress [warID]
            # with another, admin-only command existing to show all the different war IDs and which
            # wars they correspond to.

        - determine <list[justify|progress]>

    - if <[args].size> == 1 && <context.raw_args.ends_with[ ]>:
        - determine <list[help]>

    script:
    - if <context.source_type> != PLAYER:
        - define kingdom <[args].filter_tag[<[filter_value].starts_with[kingdom:]>].get[1].split[:].get[2]>
        - define args <[args].exclude[kingdom:<[kingdom]>]>

    - else if <player.proc[IsPlayerKingdomless]>:
        - define args <context.raw_args.split_args>
        - define kingdom <player.flag[kingdom]>

        - if !<[args].get[1].to_lowercase.is_in[create|info|help]>:
            - narrate format:callout "You cannot use this command, you are not a member of a kingdom!"
            - stop

    - if <[args].get[2].if_null[null]> == help:
        - if <script.data_key[data.HelpStrings].keys.contains[<context.args.get[1]>]>:
            - narrate format:callout <script.data_key[data.HelpStrings.<context.args.get[1]>].parsed>

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
            - if <[args].get[1].to_lowercase> != leave && <player.has_flag[datahold.kingdomLeaveConfirm]>:
                - flag <player> datahold.kingdomLeaveConfirm:!

            - if <[args].get[1].to_lowercase.is_in[<script.data_key[SubCommands].keys.parse_tag[<[parse_value]>]>]>:
                - inject <script.name> path:SubCommands.<[args].get[1].to_titlecase>

            - else:
                - narrate format:callout "<[args].get[1].color[red]> is not a recognized sub-command."

    SubCommands:
        Create:
        - define shortName <[args].get[2]>
        - define longName <[args].get[3].if_null[<[shortName]>]>
        - define codeName <[args].get[4].if_null[null]>

        - if <player.has_permission[kingdoms.canspecifycodenames]> && <[codeName].is_truthy>:
            - narrate format:debug "Creating kingdom: <[shortName].color[aqua]> with provided code name: <[codeName].color[gold]>..."

            - run CreateKingdom def.kingdomShortName:<[shortName]> def.kingdomLongName:<[longName]> def.codeName:<[codeName]>
            - narrate format:debug <element[Done!]>

        - if <proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomShortName]>].contains[<[kingdomShortName]>]>:
            - narrate format:callout <element[Cannot create new kingdom. Kingdom with provided name: <[kingdomShortName].color[red]> already exists.]>
            - stop

        - if <proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomName]>].contains[<[kingdomLongName]>]>:
            - narrate format:callout <element[Cannot create new kingdom. Kingdom with provided name: <[kingdomLongName].color[red]> already exists.]>
            - stop

        - if <[codeName].exists> && <proc[GetKingdomList].contains[<[codeName]>]>:
            - narrate format:callout <element[Cannot create new kingdom. Provided with custom code name that already exists: <[codeName].color[red]>.]>
            - stop

        - run CreateKingdom def.kingdomShortName:<[shortName]> def.kingdomLongName:<[longName]> save:codeName
        - define kingdom <entry[codeName].created_queue.determination.get[1]>

        - run AddMember def.kingdom:<[kingdom]> def.player:<player>
        - run SetMaxClaims def.kingdom:<[kingdom]> def.amount:<proc[GetConfigNode].context[Territory.default-max-core-chunks]> def.type:core
        - run SetMaxClaims def.kingdom:<[kingdom]> def.amount:<proc[GetConfigNode].context[Territory.default-max-castle-chunks]> def.type:castle

        - run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>

        #------------------------------------------------------------------------------------------

        Delete:
        - if <[kingdom].proc[GetKing]> != <player>:
            - narrate format:callout <element[Access denied! Only the leader of the kingdom can use this command.]>
            - stop

        - if <[args].get[2].to_lowercase> == cancel:
            - narrate format:callout <element[Kingdom deletion cancelled!]>
            - stop

        - if <[kingdom].proc[GetBalance]> < 0:
            - narrate format:callout <element[You cannot use this action when your kingdom is in the red.]>
            - stop

        - if <player.has_flag[kingdomDeletionConfirm]>:
            - foreach <[kingdom].proc[GetMembers]>:
                - run RemoveMember def.kingdom:<[kingdom]> def.player:<[value]>

            - flag server kingdoms.<[kingdom]>:!
            - flag <player> kingdomDeletionConfirm:!

            - run SidebarLoader def.target:<server.online_players>

        - else:
            - narrate <&sp>
            - narrate <element[WARNING!].bold.color[red]>
            - narrate format:callout <element[Are you ABSOLUTELY sure that you want to delete your kingdom? This will kick all members of <[kingdom].proc[GetKingdomName].color[red]> and delete any money currently in the kingdom<&sq> vault!]>
            - narrate format:uttgccallout <element[If you are doing this because you are no longer able to play on the server, consider nominating a new king from the kingdom<&sq>s ranks instead.]>
            - narrate format:callout <element[If you are still sure about deleting your kingdom, you may type this command again to confirm. If you have changed your mind type <element[/k delete cancel].color[aqua]>.]>
            - narrate <&sp>

            - flag <player> kingdomDeletionConfirm

        #------------------------------------------------------------------------------------------

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
            - run ParticleDisplayDurationTrigger def.players:<player> def.duration:<[persistTime].as[duration]> def.locationList:<[claimsCuboid].outline_2d[<player.location.y.sub[10]>]> def.particle:CLOUD

        - else:
            - run ParticleDisplayDurationTrigger def.players:<player> def.duration:<[persistTime].as[duration]> def.locationList:<[claimsCuboid].outline_2d[<player.location.y.add[20]>]> def.particle:CLOUD

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

            - case setduke:
                - if !<player.proc[IsPlayerKing]>:
                    - stop

                - define player <[args].get[4]>

                - if !<[player].as[player].exists>:
                    - narrate format:callout "Please provide the name of a valid player to make duke of this duchy."
                    - stop

                - if <server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>.dukeAssignmentCooldown]>:
                    - narrate format:callout "Your kingdom has adjusted the ownership of this duchy <server.flag_expiration[kingdoms.<[kingdom]>.duchies.<[duchy]>.dukeAssignmentCooldown].from_now.formatted.color[red]> ago. You may not readjust this duchy's ownership until this duration ha elapsed."
                    - stop

                - run SetDuke def.kingdom:<[kingdom]> def.duchy:<[duchy]> def.player:<[player].as[player]> save:res

                - if <entry[res].created_queue.determination.get[1].if_null[success]> == null:
                    - stop

                - narrate format:callout "Successfully set player: <[player].color[aqua]> as the duke of <[duchy].color[aqua]>."
                - flag server kingdoms.<[kingdom]>.duchies.<[duchy]>.dukeAssignmentCooldown expire:24h

            - case removeduke:
                - if !<player.proc[IsPlayerKing]>:
                    - stop

                - define player <proc[GetDuke].context[<[kingdom]>|<[duchy]>]>

                - if !<[player].is_truthy>:
                    - narrate format:callout "The provided duchy already does not have a duke!"
                    - stop

                - if <server.has_flag[kingdoms.<[kingdom]>.duchies.<[duchy]>.dukeAssignmentCooldown]>:
                    - narrate format:callout "Your kingdom has adjusted the ownership of this duchy <server.flag_expiration[kingdoms.<[kingdom]>.duchies.<[duchy]>.dukeAssignmentCooldown].from_now.formatted.color[red]> ago. You may not readjust this duchy's ownership until this duration ha elapsed."
                    - stop

                - run RemoveDuke def.kingdom:<[kingdom]> def.duchy:<[duchy]> save:res

                - if <entry[res].created_queue.determination.get[1].if_null[success]> == null:
                    - stop

                - narrate format:callout "Successfully removed player: <[player].color[aqua]> from their role as the duke of <[duchy].color[aqua]>."
                - flag server kingdoms.<[kingdom]>.duchies.<[duchy]>.dukeAssignmentCooldown expire:24h

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

        - if !<[amount].exists>:
            - narrate format:callout "You must specify and amount to deposit!"
            - stop

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

        - if !<[amount].exists>:
            - narrate format:callout "You must specify and amount to deposit!"
            - stop

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

                    - if !<[args].get[4].exists>:
                        - narrate format:callout "You must specify a kingdom against whom an active justification should be cancelled."
                        - stop

                    - if <[targetKingdomCode]> == null:
                        - narrate format:callout "Unrecognized kingdom name: <[target].color[red]>. Please try again."
                        - stop

                    - if !<[kingdom].proc[IsJustifyingOnKingdom].context[<[targetKingdomCode]>]>:
                        - narrate format:callout "Your kingdom is not currently justifying a claim against: <[target].color[red]>."
                        - stop

                    - run CancelJustification def.kingdom:<[kingdom]> def.targetKingdom:<[targetKingdomCode]> save:result
                    - define result <entry[result].created_queue.determination.get[1]>

                    - if !<[result].exists> || <[result]> != null:
                        - narrate format:callout "Cancelled justification against: <[target].color[aqua]>. The peace shall remain for now."
                        - narrate <n>
                        - wait 1s
                        - narrate format:callout "<gray><italic>Peace is not absence of conflict, it is the ability to handle conflict by peaceful means.. ~ Ronald Reagan"

                    - stop

                - inventory open d:JustificationKingdom_Window

            - case progress:
                - if <[args].get[3].exists>:
                    - define warID <[args].get[3]>

                    - if <context.source_type> != PLAYER:
                        - narrate <proc[GenerateWarOverviewInfoLore].context[<[kingdom]>|<[warID]>|true].values.separated_by[<n>]>
                        - stop

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
        - if <context.args.size> == 1 || <context.args.get[2]> == list:
            - define kingdomGuardList <list[]>

            - foreach <server.flag[kingdoms.<[kingdom]>.castleGuards].if_null[<list[]>]> as:guard:
                - if <[guard].flag[kingdom]> == <[kingdom]>:
                    - define guardItem <item[GuardList_Item]>
                    - define kingdomColor <proc[GetKingdomColor].context[<[kingdom]>]>

                    - adjust def:guardItem skull_skin:<[guard].skull_skin>
                    - adjust def:guardItem display:<element[<[guard].name>].bold.color[<[kingdomColor]>]>
                    - adjust def:guardItem lore:|<element[Location: ].bold.color[white]><element[<[guard].location.round.xyz>].color[aqua]>
                    - flag <[guardItem]> referencedGuard:<[guard]>

                    - define kingdomGuardList:->:<[guardItem]>

            - if !<[kingdomGuardList].is_empty>:
                - run New_Paginate_Task def.itemList:<[kingdomGuardList]> def.itemsPerPage:36 def.page:1 save:paginate
                - define paginatedGuardList <entry[paginate].created_queue.determination.get[1]>

                - flag <player> guardListPage:1
                - flag <player> kingdomGuardItems:<[paginatedGuardList]>

            - inventory open d:KingdomGuardList_Window

        #------------------------------------------------------------------------------------------

        Color:
        - define color <[args].get[2]>

        - if <[color].is_in[<util.color_names>]>:
            - if <[color]> == transparent:
                - narrate format:callout <element[Cannot set kingdom color. <[color].color[red]> is not a valid color. Please try again.]>
                - stop

            - run SetKingdomColor def.kingdom:<[kingdom]> def.color:<[color].as[color]>

        - else if <[color].as[color].exists>:
            - run SetKingdomColor def.kingdom:<[kingdom]> def.color:<[color].as[color]>

        - else:
            - narrate format:callout <element[Cannot set kingdom color. <[color].color[red]> is not a valid color. Please try again.]>

        - run SidebarLoader def.target:<proc[GetMembers].context[<[kingdom]>].include[<server.online_ops>]>

        #------------------------------------------------------------------------------------------

        Join:
        - define targetKingdomName <[args].get[2]>

        - if <proc[GetKingdomCode].context[<[targetKingdomName]>]> == null:
            - narrate format:callout <element[The kingdom name you have provided: <[targetKingdomName].color[red]> is either invalid or does not exist.]>
            - stop

        - define targetKingdom <[targetKingdomName].proc[GetKingdomCode]>

        - if !<proc[IsKingdomCodeValid]>:
            - run GenerateInternalError def.GenericError def.message:<element[Provided kingdom name: <[targetKingdomName].color[red]> is valid but generated kingdom code: <[targetKingdom].color[red]> is not. Something has gone very wrong! Please report this error to an administrator or developer.]>
            - stop

        - if <player.has_flag[kingdomInvite.<[targetKingdom]>]>:
            - run AddMember def.kingdom:<[targetKingdom]> def.player:<player>
            - flag <player> kingdom:<[targetKingdom]>

            - narrate format:callout <element[Joined kingdom!]>

        - else:
            - narrate format:callout <element[The provided kingdom: <[kingdomName].color[red]> has not sent you an invite :/]>
            - wait 1s
            - narrate format:callout <element[...Maybe if you ask nicely?]>

        #------------------------------------------------------------------------------------------

        Invite:
        - define playerName <[args].get[2]>
        - define validPlayerList <server.players.parse_tag[<[parse_value].name>]>

        - if !<[playerName].is_in[<[validPlayerList]>]>:
            - narrate format:callout <element[Cannot create invite. Provided parameter: <[playerName].color[red]> is not a valid player name. Please try again.]>
            - stop

        - define player <[playerName].as[player]>

        - if !<[player].is_online>:
            - narrate format:callout <element[Cannot create invite. Provided player: <[player].name.color[red]> is not online. Please wait until they have joined the game before sending an invite.]>
            - stop

        - if !<[player].proc[IsPlayerKingdomless]>:
            - narrate format:callout <element[Cannot create invite. Provided player: <[player].name.color[red]> is already a member of another kingdom.]>
            - stop

        - if <[player].has_flag[kingdomInvite.<[kingdom]>]>:
            - narrate format:callout <element[You have already sent an invite to this player! Please wait <[player].flag_expiration[kingdomInvite.<[kingdom]>].from_now.formatted.color[red]> longer before sending another invite!]>
            - stop

        # Stuff that happens to the sender player
        - narrate format:callout <element[Sent invite to <[player].name>!]>

        # Stuff that happens to the target player
        - narrate format:callout <element[<player.name.color[aqua]> has invited you to join their kingdom: <player.flag[kingdom].proc[GetKingdomName].color[aqua]>!]> targets:<[player]>
        - narrate format:callout <element[You may type <element[/k join <player.flag[kingdom].proc[GetKingdomName]>].color[gray]> to accept this invite.]> targets:<[player]>
        - narrate format:callout <element[This invite will expire in 10 minutes.]> targets:<[player]>

        - flag <[player]> kingdomInvite.<[kingdom]> expire:10m

        #------------------------------------------------------------------------------------------

        Leave:
        - if <player.proc[IsPlayerKing]>:
            - narrate format:callout <element[You are the king, you cannot leave your own kingdom!]>
            - stop

        - if <player.has_flag[datahold.kingdomLeaveConfirm]>:
            - if <[args].get[2].to_lowercase> == cancel:
                - narrate format:callout <element[Operation cancelled!]>
                - stop

            - run RemoveMember def.kingdom:<[kingdom]> def.player:<player>
            - narrate format:callout <element[Left kingdom! You<&sq>re on your own now...]>

            - flag <player> datahold.kingdomLeaveConfirm:!

        - else:
            - narrate format:callout <element[Are you sure that you want to leave your kingdom? If you are sure, type this command again. If you change your mind, type <element[/k leave cancel].color[aqua]>]>
            - flag <player> datahold.kingdomLeaveConfirm

        #------------------------------------------------------------------------------------------

        Promote:
        - if <[kingdom].proc[GetKing]> != <player>:
            - narrate format:callout <element[Access denied! Only the leader of the kingdom can use this command.]>
            - stop

        - define newKing <[args].get[2]>

        - if !<[newKing].is_in[<[validPlayerList]>]>:
            - narrate format:callout <element[Cannot promote member. Provided parameter: <[newKing].color[red]> is not a valid player name. Please try again.]>
            - stop

        - define player <[newKing].as[player]>

        - if !<[player].is_in[<[kingdom].proc[GetMembers]>]>:
            - narrate format:callout <element[Cannot promote member. The provided player: <[player].name.color[red]> is not a part of your kingdom!]>
            - stop

        - if <[args].get[2].to_lowercase> == cancel:
            - narrate format:callout <element[Player promotion cancelled!]>
            - stop

        - if <player.has_flag[kingdomPromotionConfirm]>:
            - define player <player.flag[kingdomPromotionConfirm]>
            - narrate format:callout <element[Promoted <[player].name.color[aqua]> to be the new king!]>

            - run SetKing def.kingdom:<[kingdom]> def.player:<[player]>
            - run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>

            - flag <player> kingdomPromotionConfirm:!

        - else:
            - narrate <&sp>
            - narrate <element[WARNING!].bold.color[red]>
            - narrate format:callout <element[Are you sure you would like to promote <[newKing].color[red]> to replace you as king? To confirm type <element[/k promote].color[aqua]> again. To cancel type <element[/k promote cancel].color[aqua]>.]>
            - narrate <&sp>

            - flag <player> kingdomPromotionConfirm:<[player]>

        #------------------------------------------------------------------------------------------

        Members:
        - define memberList <[kingdom].proc[GetMembers].alphabetical>
        - define formattedMemberList <list[]>

        - foreach <[memberList]> as:member:
            - if <[kingdom].proc[GetKing]> == <[member]>:
                - define formattedMemberList:->:<element[<[member].name.bold> (king)].color[<[kingdom].proc[GetKingdomColor].mix[<white>]>]>

            - else:
                - define formattedMemberList:->:<element[<[member].name.italicize>]>

        - narrate <element[Member list for: <[kingdom].proc[GetKingdomShortName].bold.color[<[kingdom].proc[GetKingdomColor].mix[<white>]>]>]>
        - narrate <element[    - <[formattedMemberList].separated_by[<n>    - ]>]>
        - narrate <&sp>



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

            # Make sure that the new warp is within valid kingdom territory.
            - if <[warpName]> != main:
                - if <[castleCore].contains[<player.location.chunk>]> || <[inWhichOutpostAreas].size> > 0:
                    - flag server kingdoms.<[kingdom]>.warps.<[warpName]>:<player.location.center>

                - else:
                    - narrate format:callout "Regular kingdom warps must be within castle, core, or outpost territory"

                - stop

            # If the warp being specified is the 'main' kingdom warp, then it can only be placed in
            # castle territory...
            - if !<[castle].contains[<player.location.chunk>]>:
                - narrate format:callout "You must place your kingdom's main warp location inside your castle territory!"
                - stop

            # ...Also, it's worth making sure that the player actually means to change the most
            # importance warp in the kingdom.
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

        # If the player specifies another kingdom's warp, first make sure that they've actually
        # been allowed to warp to them (and that it exists), before sending them there.
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

        # Clause for if the player wants to deny another kingdom access to their warps. By default
        # kingdoms don't have access to one another's warps.
        - else if <[param]> == deny:
            - define kingdomCodeName <script[KingdomRealNames].data_key[ShortNames].invert.get[<context.args.get[3]>]>

            - if !<server.flag[kingdoms.<[kingdom]>.openWarp].contains[<[kingdomCodeName]>]>:
                - narrate format:callout "That kingdom was already not on your kingdom's warp whitelist."
                - stop

            - flag server kingdoms.<[kingdom]>.openWarp:<-:<[kingdomCodeName]>
            - narrate format:callout "Removed kingdom: <context.args.get[3].color[red].bold> from your warp whitelist!"

        - else if <[param]> == allow:
            # Players must specify a kingdom's *short* name when allowing/denying it access to
            # warps. Dems de rules (It gets way to laborious if I also allow people to specify a
            # kingdom's full name).
            - define kingdomRealNames <proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomShortName]>]>
            - define kingdomCodeNames <proc[GetKingdomList]>

            # If the player doesn't specify a kingdom, then the command should simply just return
            # if their kingdom has warps open at all.
            - if !<context.args.get[3].exists>:
                - define openWarp <server.flag[kingdoms.<[kingdom]>.openWarp]>

                - if <[openWarp].size.if_null[0]> == 0:
                    - narrate format:callout "Your kingdom has its warps closed to all kingdoms"

                - else:
                    - narrate format:callout "Kingdoms that can access your warps:<n><server.flag[kingdoms.<[kingdom]>.openWarp].parse_tag[<proc[GetKingdomList].parse_tag[<[parse_value].proc[GetKingdomShortName]>]>].separated_by[<n>]>"

            # But otherwise, verify the kingdom name exists and add them to list of warp users.
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

            # By default, if a player just types /k warp, then they should be taken back to their
            # kingdom's main warp.
            - else if <server.has_flag[kingdoms.<[kingdom]>.warps]>:
                - narrate format:callout "Warping in 3 seconds..."
                - chunkload add <server.flag[kingdoms.<[kingdom]>.warps.main].chunk> duration:1m

                - wait 3s

                - teleport <player> <server.flag[kingdoms.<[kingdom]>.warps.main]>

            # ...You should really have a main warp set -_-
            - else:
                - narrate format:callout "Your kingdom does not currently have a warp location. You may want to speak to your king about this."