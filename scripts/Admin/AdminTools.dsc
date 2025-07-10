##
## Conatins the umbrella command for all things admin-related.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2020
## @Updated: Jul 2022
## @Script Ver: v1.0
##
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

AdminTools_Command:
    type: command
    debug: false
    usage: /kadmin
    name: kadmin
    description: Umbrella command for all things kingdoms admin.
    permission: kingdoms.admin
    tab completions:
        1: id|influence|loans|purgeflag|seeflag|buildplayerlists|dynmap

    tab complete:
    - define mostFlags <list[]>

    - choose <context.args.get[1].if_null[null]>:
        - case purgeflag:
            - if <context.args.size> >= 2:
                - define target <context.args.get[2]>

                - if <[target]> == *:
                    - foreach <server.players> as:player:
                        - define flagList <[player].list_flags>

                        - if <[flagList].size.is[MORE].than[<[mostFlags].size>]>:
                            - define mostFlags <[flagList]>

                    - determine <[mostFlags].include[*]>

                - else:
                    - if <context.args.get[3].ends_with[,]>:
                        - define concatFlags <list[]>

                        - foreach <[target].as[player].list_flags.exclude[<context.args.get[3].replace_text[,].with[|].as[list]>]>:
                            - define concatFlags:->:<list[<context.args.get[3]>|<[value]>].unseparated>

                        - determine <[concatFlags]>

                    - else:
                        - determine <context.args.get[2].as[player].list_flags.include[*]>

            - determine <server.players.parse_tag[<[parse_value].name>].include[*]>

        - case seeflag:
            - define object <context.args.get[2]> if:<context.args.size.is[OR_MORE].than[2]>

            - if <context.args.size> == 1:
                - determine <list[server|world|player|[flaggable object]]>

            - else if <context.args.size> <= 2:
                - if <[object].starts_with[<&lt>]> && <[object].ends_with[<&gt>]> && <context.raw_args.ends_with[ ]>:
                    - define flagList <[object].parsed.list_flags>
                    - define flagList <server.list_flags[]> if:<[object].equals[server]>
                    - determine <[flagList].if_null[<list[]>]>

                - else if <[object]> == server:
                    - determine <server.list_flags[]>

                - else if <[object]> == player:
                    - determine <player.list_flags>

                - else if <[object]> == world:
                    - determine <player.location.world.list_flags>

                - else:
                    - determine <list[server|world|player|[flaggable object]]>

            - else if <context.args.size> == 3:
                - if <context.args.get[3].contains[.]>:
                    - define keyList <context.args.get[3].split[.]>
                    - define currentKey <[keyList].last>
                    - define firstKey <[keyList].first>

                    # Example textbox:
                    # /kadmin seeflag server economy.markets.
                    # /kadmin seeflag server fyndalin.loanOffers
                    - if <[currentKey]> != <[firstKey]>:
                        - define adjustedKeyList <[keyList].remove[last].separated_by[.]>
                        - define adjustedKeyList <[keyList].separated_by[.]> if:<context.args.get[3].ends_with[.]>
                        - define currentKey * if:<context.args.get[3].ends_with[.]>

                        - define keys <[object].parsed.flag[<[adjustedKeyList]>].keys.filter_tag[<[filter_value].advanced_matches[<[currentKey]>].or[<[filter_value].starts_with[<[currentKey]>]>]>].if_null[null]>
                        - define keys <server.flag[<[adjustedKeyList]>].keys.filter_tag[<[filter_value].advanced_matches[<[currentKey]>].or[<[filter_value].starts_with[<[currentKey]>]>]>].if_null[<list[]>]> if:<[object].equals[server]>

                        - if <[keys]> != null:
                            - determine <[keys].parse_tag[<[adjustedKeyList]>.<[parse_value]>]>

                        - else:
                            - determine <list[]>

                    # Example textbox:
                    # /kadmin seeflag server economy.
                    # /kadmin seeflag server fyndalin
                    - else:
                        - if <[object]> == server:
                            - define keys <server.flag[<[currentKey]>].keys>

                        - else if <[object]> == world:
                            - define keys <player.location.world.flag[<[currentKey]>].keys.if_null[<list[]>]>

                        - else:
                            - define keys <element[<&lt><[object]><&gt>].parsed.flag[<[currentKey]>].keys.if_null[<list[]>]>

                        - if <[keys].is_truthy> && <[keys].exists>:
                            - determine <[keys].parse_tag[<[keyList].separated_by[.]>.<[parse_value]>]>

                        - else:
                            - determine <list[]>

                - else:
                    - if <[object].starts_with[<&lt>]> && <[object].ends_with[<&gt>]> && <context.raw_args.ends_with[ ]>:
                        - define flagList <[object].parsed.list_flags>
                        - define flagList <server.list_flags[]> if:<[object].equals[server]>
                        - determine <[flagList].if_null[<list[]>]>

                    - else if <[object]> == server:
                        - determine <server.list_flags[]>

                    - else if <[object]> == player:
                        - determine <player.list_flags>

                    - else if <[object]> == world:
                        - determine <player.location.world.list_flags>

                    - else:
                        - determine <list[server|world|player|[flaggable object]]>

        - case dynmap:
            - define args <context.raw_args.to_lowercase.split_args>

            - choose <[args].get[2].if_null[null]>:
                - case generate:
                    - if <[args].size> >= 3:
                        - if <[args].get[4].if_null[null]> == duchy:
                            - determine <[args].get[3].proc[GetKingdomDuchies].include[all]>

                        - else if <[args].size> >= 4:
                            - determine <list[]>

                        - else:
                            - determine <list[main|duchy|all]>

                    - if <[args].size> >= 2:
                        - determine <proc[GetKingdomList].include[all]>

            - determine <list[generate|refresh]>

    script:
    - define args <context.raw_args.split_args>
    - define subcommand <[args].get[1]>

    # ---------------------- START SHORT SUBCOMMANDS ----------------------#

    - choose <[subcommand]>:
        - case id:
            - if <player.has_flag[AdminTools.id]>:
                - flag player AdminTools.id:!
                - narrate format:admincallout "Exited ID Checker"

            - else:
                - flag player AdminTools.id
                - narrate format:admincallout "Entered ID Checker"

        - case influence:
            - inventory open d:AdminOverallInfluence

        - case loans:
            - inventory open d:LoanAdmin_Window

        - case buildplayerlists:
            - foreach <server.players>:
                - if <[value].has_flag[kingdom]>:
                    - define kingdom <[value].flag[kingdom]>

                    - flag server <[kingdom]>.members:->:<[value]>
                    - narrate format:admincallout "Added player: <[value].name> to kingdom flag: <[kingdom]>"

                - else:
                    - narrate format:admincallout "No kingdom found for: <[value].name>"

        # TODO: Consider packaging this as a task script and putting in DynmapHandler.dsc
        ## I feel like this makes more logical sense as to where things should go.
        - case dynmap:
            - define action <[args].get[2].to_lowercase>

            - if !<[action].is_truthy>:
                - narrate format:admincallout "You must provide an argument to this subcommand."
                - stop

            - if <[action]> == generate:
                - define kingdom <[args].get[3].to_lowercase>
                - define territoryType <[args].get[4].to_lowercase>

                - if !<[territoryType].is_truthy>:
                    - narrate format:admincallout "You must specify a territory type to generate."
                    - stop

                - if <[kingdom]> == all:
                    - foreach <proc[GetKingdomList]>:
                        - run GenerateDynmapCorners def.chunks:<[value].proc[GetClaims]> save:corners
                        - define corners <entry[corners].created_queue.determination.get[1]>

                        - flag <player.location.world> dynmap.cache.<[value]>.main.cornerList:<[corners]>

                        - foreach <[value].proc[GetKingdomDuchies]> as:duchy:
                            - run GenerateDynmapCorners def.chunks:<[value].proc[GetDuchyTerritory].context[<[duchy]>]> save:corners
                            - define corners <entry[corners].created_queue.determination.get[1]>

                            - flag <player.location.world> dynmap.cache.<[value]>.duchies.<[duchy]>.cornerList:<[corners]>

                    - narrate format:admincallout "Territory generation complete. Use <element[/kadmin dynmap refresh].color[gray]> to see any changes reflected onto the dynmap."
                    - stop

                - else if !<[kingdom].proc[ValidateKingdomCode]>:
                    - narrate format:admincallout "You must specify a valid kingdom for which to generate dynmap data."
                    - stop

                - if <[territoryType]> == main:
                    - narrate format:admincallout "Generating dynmap data for territory type: <[territoryType].color[aqua]> for kingdom: <[kingdom].color[aqua]>..."
                    - run GenerateDynmapCorners def.chunks:<[kingdom].proc[GetClaims]> save:corners
                    - define corners <entry[corners].created_queue.determination.get[1]>

                    - flag <player.location.world> dynmap.cache.<[kingdom]>.main.cornerList:<[corners]>

                - else if <[territoryType]> == duchy:
                    - define duchy <[args].get[5].to_lowercase>

                    - if <[duchy]> == all:
                        - foreach <[kingdom].proc[GetKingdomDuchies]>:
                            - run GenerateDynmapCorners def.chunks:<[kingdom].proc[GetDuchyTerritory].context[<[value]>]> save:corners
                            - define corners <entry[corners].created_queue.determination.get[1]>

                            - flag <player.location.world> dynmap.cache.<[kingdom]>.duchies.<[value]>.cornerList:<[corners]>

                    - if !<[duchy].is_truthy>:
                        - narrate format:admincallout "You must specify the name of the duchy that you want to generate dynmap data for."
                        - stop

                    - narrate format:admincallout "Generating dynmap data for territory type: <[territoryType].color[aqua]> for duchy: <[duchy].color[aqua]> in kingdom: <[kingdom].color[aqua]>..."
                    - run GenerateDynmapCorners def.chunks:<[kingdom].proc[GetDuchyTerritory].context[<[duchy]>]> save:corners
                    - define corners <entry[corners].created_queue.determination.get[1]>

                    - flag <player.location.world> dynmap.cache.<[kingdom]>.duchies.<[duchy]>.cornerList:<[corners]>

                - else if <[territoryType]> == all:
                    - run GenerateDynmapCorners def.chunks:<[kingdom].proc[GetClaims]> save:corners
                    - define corners <entry[corners].created_queue.determination.get[1]>

                    - flag <player.location.world> dynmap.cache.<[kingdom]>.main.cornerList:<[corners]>

                    - foreach <[kingdom].proc[GetKingdomDuchies]>:
                        - run GenerateDynmapCorners def.chunks:<[kingdom].proc[GetDuchyTerritory].context[<[value]>]> save:corners
                        - define corners <entry[corners].created_queue.determination.get[1]>

                        - flag <player.location.world> dynmap.cache.<[kingdom]>.duchies.<[value]>.cornerList:<[corners]>

                - narrate format:admincallout "Territory generation complete. Use <element[/kadmin dynmap refresh].color[gray]> to see any changes reflected onto the dynmap."

            - else if <[action]> == refresh:
                - narrate format:admincallout "Refreshing dynmap to latest data..."
                - run DynmapTask

                - narrate format:admincallout "Refresh complete."

            - else:
                - narrate <element[<[action].if_null[null].color[red]> is an unrecognized action. Please enter a valid action.]>

        - case seeflag:
            - if <player.is_op> || <player.has_permission[kingdoms.developer]>:
                - define args <context.raw_args.split_args>
                - define objectParam <[args].get[2]>

                - definemap objectRef:
                    player: <player>
                    world: <player.location.world>

                - define object <[objectRef].get[<[objectParam]>].if_null[<[args].get[2].parsed>]>
                - define flagName <[args].get[3]>
                - define flag null

                # Can't put server: <server> in objectRef since the server
                # is a pseudo-tag that cannot be used on its own :/
                - if <[objectParam]> == server:
                    - define flag <server.flag[<[flagName]>]> if:<server.has_flag[<[flagName]>]>

                - else:
                    - define flag <[object].flag[<[flagName]>]> if:<[object].has_flag[<[flagName]>]>

                - if <[flag]> != null:
                    - run FlagVisualizer def.flag:<[flag]> def.flagName:<[flagName]>

                    - if <script.queues.get[1].determination.get[1].exists>:
                        - narrate <element[<[flagName]>: ].color[green].italicize><script.queues.get[1].determination.get[1]>

                - else:
                    - narrate <element[                                                     ].strikethrough>
                    - narrate "<italic><[flagName].color[green]> does not exist :/"
                    - narrate <element[                                                     ].strikethrough>

            - else:
                - narrate format:admincallout "This subcommand can only be used by server developers!"


KingdomSwitcher_Command:
    type: command
    usage: /kswitch
    name: kswitch
    description: Allows admins to switch their kingdom tag for debug purposes
    permission: kingdoms.admin.kingdomswitch
    tab completions:
        1: <proc[GetKingdomList]>
    script:
    - define kingdomList <proc[GetKingdomList]>

    - if <[kingdomList].contains[<context.args.get[1]>]>:
        - if <context.args.length> == 2:
            - flag <context.args.get[2]> kingdom:<context.args.get[1]>
            - narrate format:admincallout "<context.args.get[2]> are now flagged as: <player.flag[kingdom]>"
        - else:
            - flag player kingdom:<context.args.get[1]>
            - narrate format:admincallout "you are now flagged as: <player.flag[kingdom]>"

        - ~run SidebarLoader def:<player>

    - else:
        - narrate format:admincallout "That is not a valid kingdom"


idCheck_Handler:
    type: world
    events:
        on player right clicks npc flagged:AdminTools.id:
        - ratelimit <player> 1t
        - narrate format:admincallout "NPC Has ID: <npc.id>"

        on player quits flagged:AdminTools.id:
        - flag <player> AdminTools.id:!


KillForbiddenFunction:
    type: world
    debug: false
    events:
        on command:
        - define forbiddenCommands <list[kill|killall|nuke]>

        - if <[forbiddenCommands].contains[<context.command>]>:
            - determine cancelled


AddEssentialsWorthItems:
    type: task
    script:
    - define allItems <server.material_types.parse_tag[<[parse_value].name.as[item]>]>
    - yaml load:economy_data/price-info.yml id:prices

    #- narrate format:debug ALL:<[allItems]>

    - foreach <[allItems]> as:item:
        - if <[item].essentials_worth.exists>:
            #- narrate format:debug ITM:<[item].worth>
            #- yaml id:prices set price_info.items.<[item].material.name>.price:<[item].worth>
            - yaml id:prices set price_info.items.<[item].material.name>.base:<yaml[prices].read[price_info.items.<[item].material.name>.price]>
            - yaml id:prices set price_info.items.<[item].material.name>.price:!
            #- yaml id:prices set price_info.items.<[item].material.name>.gov_cap:<[item].worth.mul[1.4]>

    - yaml id:prices savefile:economy_data/price-info.yml
    - yaml id:prices unload


ReloadVerbosity_Handler:
    type: world
    debug: false
    events:
        on ex command:
        - if <context.source_type> == PLAYER && <context.args.get[1]> == reload && <context.args.size> == 1:
            - determine passively cancelled
            - narrate "<yellow>[Kingdoms Backend] <&gt><&gt> <white>Reloading Scripts..."
            - define timeBeforeReload <util.current_time_millis>
            - reload
            - flag server reloadoverride:<player>
            - waituntil <server.has_flag[reloadoverride].not> max:10m
            - define reloadTime <util.current_time_millis.sub[<[timeBeforeReload]>]>
            - narrate "<yellow>[Kingdoms Backend] <&gt><&gt> <white>Processed <util.scripts.size.color[red].bold> Scripts!"
            - narrate "<yellow>[Kingdoms Backend] <&gt><&gt> <white>See console for more information regarding STP & processed event paths."
            - narrate "<yellow>[Kingdoms Backend] <&gt><&gt> <white>Reloaded all scripts in: <aqua><[reloadTime]>ms<white>!"

        on reload scripts server_flagged:reloadoverride:
        - if <context.had_error>:
            - narrate targets:<server.flag[reloadoverride]> "<yellow>[Kingdoms Backend] <&gt><&gt> <red>WARNING! Error occured while reloading some or all scripts!"

        - flag server reloadoverride:!
