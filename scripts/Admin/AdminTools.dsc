##
## * Conatins the umbrella command for all things related to
## * the kingdoms admin command
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2020
## @Updated: Jul 2022 - In Progress
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
        1: id|influence|loans|purgeflag|seeflag|buildplayerlists

    tab complete:
    - define mostFlags <list[]>

    - choose <context.args.get[1]>:
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
                - determine <list[server|player|[flaggable object]]>

            - else if <context.args.size> <= 2:
                - if <[object].regex_matches[^<&lt>.*\<&lb>.*\<&rb><&gt>$]>:
                    - define flagList <[object].parsed.list_flags>
                    - define flagList <server.list_flags[]> if:<[object].equals[server]>
                    - determine <[flagList].if_null[<list[]>]>

                - else if <[object]> == server:
                    - determine <server.list_flags[]>

                - else if <[object]> == player:
                    - determine <player.list_flags>

                - else:
                    - determine <list[server|player|[flaggable object]]>

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

                        - define keys <[object].parsed.flag[<[adjustedKeyList]>].keys.filter_tag[<[filter_value].advanced_matches[<[currentKey]>].or[<[filter_value].starts_with[<[currentKey]>]>]>]>
                        - define keys <server.flag[<[adjustedKeyList]>].keys.filter_tag[<[filter_value].advanced_matches[<[currentKey]>].or[<[filter_value].starts_with[<[currentKey]>]>]>]> if:<[object].equals[server]>

                        - if <[keys].exists>:
                            - determine <[keys].parse_tag[<[adjustedKeyList]>.<[parse_value]>]>

                        - else:
                            - determine <list[]>

                    # Example textbox:
                    # /kadmin seeflag server economy.
                    # /kadmin seeflag server fyndalin
                    - else:
                        - define keys <[object].parsed.flag[<[currentKey]>].keys>
                        - define keys <server.flag[<[currentKey]>].keys> if:<[object].equals[server]>

                        - if <[keys].exists>:
                            - determine <[keys].parse_tag[<[keyList].separated_by[.]>.<[parse_value]>]>

                        - else:
                            - determine <list[]>

                - else:
                    - if <[object].regex_matches[^<&lt>.*\<&lb>.*\<&rb><&gt>$]>:
                        - define flagList <[object].parsed.list_flags>
                        - define flagList <server.list_flags[]> if:<[object].equals[server]>
                        - determine <[flagList].if_null[<list[]>]>

                    - else if <[object]> == server:
                        - determine <server.list_flags[]>

                    - else if <[object]> == player:
                        - determine <player.list_flags>

    script:
    - define args <context.raw_args.split_args.get[1]>

    # ---------------------- START SHORT SUBCOMMANDS ----------------------#

    - choose <[args]>:
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

        # - case swapworld:
        #     - define loc <player.location>

        #     - if <player.location.world.name> == KingdomsCurrent:
        #         - teleport <player> <location[<[loc].x>,<[loc].y>,<[loc].z>,<[loc].pitch>,<[loc].yaw>,Kingdoms]>

        #     - else if <player.location.world.name> == Kingdoms:
        #         - teleport <player> <location[<[loc].x>,<[loc].y>,<[loc].z>,<[loc].pitch>,<[loc].yaw>,KingdomsCurrent]>

        - case buildplayerlists:
            - foreach <server.players>:
                - if <[value].has_flag[kingdom]>:
                    - define kingdom <[value].flag[kingdom]>

                    - flag server <[kingdom]>.members:->:<[value]>
                    - narrate format:admincallout "Added player: <[value].name> to kingdom flag: <[kingdom]>"

                - else:
                    - narrate format:admincallout "No kingdom found for: <[value].name>"

    # ---------------------- START INJECTED SUBCOMMANDS ----------------------#

        - case purgeflag:
            - define purgeTarget <[args].get[2]>
            - define flagTargets <[args].get[3].split[,]>

            - clickable save:confirm_purge until:30s usages:1:
                - narrate format:admincallout "Starting flag purge..."
                - run PurgeFlags_Subcommand def.player:<[purgeTarget]> def.flag:<[flagTargets]>

            - clickable save:cancel_purge until:30s usages:1:
                - narrate format:admincallout "Action cancelled!"
                - determine cancelled

            - narrate format:admincallout "Please confirm that you wish to clear the following flags:"
            - narrate <[flagTargets].comma_separated>
            - narrate format:admincallout "From the following players:"
            - narrate <[purgeTarget].comma_separated>

        - case seeflag:
            - if <player.is_op> || <player.has_permission[kingdoms.developer]>:
                - define args <context.raw_args.split_args>
                - define objectParam <[args].get[2]>

                - definemap objectRef:
                    player: <player>
                    world: <player.location.world>

                - define object <[objectRef].get[<[objectParam]>].if_null[<[args].get[2].parsed>]>
                - define flagName <[args].get[3]>
                - define flag <[object].flag[<[flagName]>]>

                # Can't put server: <server> in objectRef since the server
                # is a pseudo-tag that cannot be used on its own :/
                - if <[objectParam]> == server:
                    - define flag <server.flag[<[flagName]>]>

                - if <[flag].exists>:
                    - narrate "<element[                                                     ].strikethrough>"
                    - inject FlagVisualizer

                    - if <script.queues.get[1].determination.get[1].exists>:
                        - narrate "<element[<[flagName]>: ].color[green].italicize><script.queues.get[1].determination.get[1]>"

                    - narrate "<element[                                                     ].strikethrough>"

                - else:
                    - narrate format:admincallout "Object: <[object]> does not have flag with name: <[flagName]>"

            - else:
                - narrate format:admincallout "This subcommand can only be used by server developers!"

KingdomSwitcher_Command:
    type: command
    usage: /kswitch
    name: kswitch
    description: Allows admins to switch their kingdom tag for debug purposes
    permission: kingdoms.admin.kingdomswitch
    tab completions:
        1: centran|viridian|raptoran|cambrian|fyndalin
    script:
    - define kingdomList <script[KingdomRealNames].data_key[].keys>

    - if <[kingdomList].contains[<context.args.get[1]>]>:
        - if <context.args.length> == 2:
            - flag <context.args.get[2]> kingdom:<context.args.get[1]>
            - narrate format:admincallout "<context.args.get[2]> are now flagged as: <player.flag[kingdom]>"
        - else:
            - flag player kingdom:<context.args.get[1]>
            - narrate format:admincallout "you are now flagged as: <player.flag[kingdom]>"

        - run SidebarLoader def:<player>

    - else:
        - narrate format:admincallout "That is not a valid kingdom"

idCheck_Handler:
    type: world
    events:
        on player right clicks npc:
        - if <player.has_flag[AdminTools.id]>:
            - ratelimit <player> 1t
            - narrate format:admincallout "NPC Has ID: <npc.id>"

        on player quits:
        - flag <player> AdminTools.id:!

AdminOverallInfluence:
    type: inventory
    inventory: chest
    title: "Overall Influence"
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [AdminInfluence_K1] [] [AdminInfluence_K2] [] [AdminInfluence_K3] [] [AdminInfluence_K4] []
    - [] [] [] [] [] [] [] [] []

AdminInfluence_K1:
    type: item
    material: green_banner
    display name: "Imperium Viriditas:: Overall"
    lore:
    - <proc[InfluenceGetter_Admin].context[viridian]>

AdminInfluence_K2:
    type: item
    material: red_banner
    display name: "Dynastus Raptores:: Overall"
    lore:
    - <proc[InfluenceGetter_Admin].context[raptoran]>

AdminInfluence_K3:
    type: item
    material: blue_banner
    display name: "Centra Australis:: Overall"
    lore:
    - <proc[InfluenceGetter_Admin].context[centran]>

AdminInfluence_K4:
    type: item
    material: orange_banner
    display name: "Cambrian Empire:: Overall"
    lore:
    - <proc[InfluenceGetter_Admin].context[cambrian]>

# arrowRain:
#     type: world
#     debug: false
#     events:
#         on player clicks block:
#         - if <context.item> == <item[spectral_arrow]>:
#             - if <player.has_permission[kingdoms.admin]>:
#                 - define arrowList <list[]>
#                 - define variance <util.random.int[100].to[250]>

#                 - repeat <[variance]>:
#                     - shoot arrow speed:2 shooter:<player> no_rotate origin:<player.location.simple.up[30]> destination:<player.cursor_on.random_offset[5]> spread:3 script:ArrowRainScript save:arrow
#                     - define arrowList:->:<entry[arrow].shot_entity>

#                 - playsound <player> sound:ENTITY_ARROW_SHOOT
#                 - wait 10s

#                 - foreach <[arrowList]>:
#                     - remove <[value]>

#         - if <context.item.material.name> == tipped_arrow:
#              - if <player.has_permission[kingdoms.admin]>:
#                 - define circle <player.location.up[1].forward_flat[1].points_around_y[radius=3;points=30]>
#                 - define smallerCircle <player.location.up[1].forward_flat[1].points_around_y[radius=2;points=15]>
#                 - define startCursor <player.cursor_on>

#                 - foreach <[circle].include[<[smallerCircle]>]>:
#                     - if <[loop_index].mod[2]> == 0:
#                         - playsound <player> sound:ENTITY_ARROW_SHOOT pitch:2

#                     - shoot arrow speed:2 shooter:<player> no_rotate origin:<[value]> destination:<[startCursor]>
#                     - wait 1t

# EntityList:
#     type: data
#     targets:
#     - pig
#     - sheep
#     - cow
#     - zombie

# ArrowRainScript:
#     type: task
#     script:
#     - define closestEntities <[location].find_entities[<script[EntityList].data_key[targets]>].within[20]>
#     - define randomEntity <util.random.int[1].to[<[closestEntities].size>]>

#     ################################################################
#     ## I CAN MAKE THE SECOND INSTANCE ARROWS FUCKING HEATSEAKING!!!!
#     ################################################################

#     - if <[closestEntities].size> != 0:
#         - shoot arrow speed:2 origin:<[location]> destination:<[closestEntities].get[<[randomEntity]>].location.up[1]> shooter:<player> save:arrow

#     - else:
#         - shoot arrow speed:2 origin:<[location]> destination:<[location].up[30]> shooter:<player> save:arrow

#     - wait 10s
#     - remove <entry[arrow].shot_entity>

# TPArrow:
#     type: world
#     events:
#         on player clicks block:
#         - if <context.item> == <item[arrow]>:
#             - ratelimit <player> 1s

#             - if <player.has_permission[kingdoms.admin]>:
#                 - define prevLoc <player.location>

#                 - repeat 200:
#                     - shoot arrow speed:2 shooter:<player> no_rotate origin:<player.location.up[1].random_offset[3]> destination:<player.cursor_on.random_offset[5]> script:TPArrowScript save:arrow def:<[prevLoc]>

#                 - wait 10s
#                 - remove <entry[arrow].shot_entity>

# TPArrowScript:
#     type: task
#     definitions: loc
#     script:
#     - foreach <[shot_entities]>:
#         - adjust <[value]> damage:0
#         - narrate format:debug <[value].damage>

#     - teleport <[hit_entities]> <[loc]>

yamlHasAll:
    type: procedure
    definitions: file|values
    script:
    - yaml load:<definition[file]> id:data

    - foreach <definition[values]>:
        - if !<yaml[data].contains[<[value]>]>:
            - determine false

    - determine true

NPCYeet_Item:
    type: item
    material: blaze_rod
    display name: "NPC YEETER"

NPCYeet_Handler:
    type: world
    events:
        on player right clicks entity with:NPCYeet_Item:
        - if <context.entity.entity_type> == PLAYER:
            - if <context.entity.name.starts_with[Miner]> || <context.entity.name.starts_with[Farmer]>:
                - narrate "Removed entity: <context.entity.id>"
                - remove <context.entity>

SuperWheat_Item:
    type: item
    material: wheat
    display name: "<bold><light_purple>Super Wheat Tool"
    mechanisms:
        enchantments:
        - fortune:1

SuperWheat_Handler:
    type: world
    debug: false
    events:
        on player clicks block with:SuperWheat_Item:
        - ratelimit <player> 1t
        - define acceptableBlocks <list[grass_block|dirt|corse_dirt|podzol|farmland]>

        - if <[acceptableBlocks].contains_text[<player.cursor_on[10].block.material.name>]>:
            - modifyblock <player.cursor_on[10]> farmland
            - modifyblock <player.cursor_on[10].up[1]> wheat
            - adjustblock <player.cursor_on[10]> age:7

NetherKey_Item:
    type: item
    material: carrot_on_a_stick
    display name: "<light_purple><bold>Nether Key"
    lore:
        - "A mysterious key, that"
        - "shimmers in the sunlight"
    mechanisms:
        custom_model_data: 123456

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
        - if <[item].worth.exists>:
            #- narrate format:debug ITM:<[item].worth>
            #- yaml id:prices set price_info.items.<[item].material.name>.price:<[item].worth>
            - yaml id:prices set price_info.items.<[item].material.name>.base:<yaml[prices].read[price_info.items.<[item].material.name>.price]>
            - yaml id:prices set price_info.items.<[item].material.name>.price:!
            #- yaml id:prices set price_info.items.<[item].material.name>.gov_cap:<[item].worth.mul[1.4]>

    - yaml id:prices savefile:economy_data/price-info.yml
    - yaml id:prices unload

DEBUG_GenerateKingdomFlags:
    type: task
    script:
    - define kingdomNames <list[centran|cambrian|viridian|raptoran|fyndalin]>

    - yaml load:kingdoms.yml id:kingdoms
    - yaml load:powerstruggle.yml id:ps
    - yaml load:blackmarket-formatted.yml id:bmf

    - foreach <[kingdomNames]> as:kingdom:
        - define oldKingdomFlag <server.flag[<[kingdom]>]>

        - flag server kingdoms.<[kingdom]>.members:<[oldKingdomFlag].get[members]>
        - flag server kingdoms.<[kingdom]>.openWarp:<[oldKingdomFlag].get[openWarp]> if:<[oldKingdomFlag].get[openWarp].exists>
        - flag server kingdoms.<[kingdom]>.loans:<[oldKingdomFlag].get[loans]> if:<[oldKingdomFlag].get[loans].exists>
        - flag server kingdoms.<[kingdom]>.powerstruggle:<[oldKingdomFlag].get[powerstruggle]> if:<[oldKingdomFlag].get[powerstruggle].exists>

        - define YKI <yaml[kingdoms].read[<[kingdom]>]>
        - define YPI <yaml[ps].read[<[kingdom]>]>
        - define YBI <yaml[bmf].read[factiondata.opinions.<[kingdom]>]>

        - flag server kingdoms.<[kingdom]>.balance:<[YKI].get[balance]>
        - flag server kingdoms.<[kingdom]>.warps:<[YKI].get[warp_location]>
        - flag server kingdoms.<[kingdom]>.description:<[YKI].get[description]>
        - flag server kingdoms.<[kingdom]>.prestige:<[YKI].get[prestige]>
        - flag server kingdoms.<[kingdom]>.upkeep:<[YKI].get[upkeep]>
        - flag server kingdoms.<[kingdom]>.warStatus:<[YKI].get[war_status]>
        - flag server kingdoms.<[kingdom]>.claims.core:<[YKI].get[core_claims]>
        - flag server kingdoms.<[kingdom]>.claims.castle:<[YKI].get[castle_territory]>
        - flag server kingdoms.<[kingdom]>.claims.coreMax:<[YKI].get[core_max]>
        - flag server kingdoms.<[kingdom]>.claims.castleMax:<[YKI].get[castle_max]>
        - flag server kingdoms.<[kingdom]>.npcTotal:<[YKI].deep_get[npcs.npc_total]>
        - flag server kingdoms.<[kingdom]>.outposts.costMultiplier:<[YKI].deep_get[outposts.outpost_cost]>
        - flag server kingdoms.<[kingdom]>.outposts.upkeepMultiplier:<[YKI].deep_get[outposts.outpost_upkeep]>
        - flag server kingdoms.<[kingdom]>.outposts.maxSize:<[YKI].deep_get[outposts.max_size]>
        - flag server kingdoms.<[kingdom]>.outposts.totalUpkeep:0

        - flag server kingdoms.<[kingdom]>.powerstruggle.cityPopulation:<[YPI].get[citypopulation]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.influencePoints:<[YPI].get[dailyinfluences]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.fyndalinGovt:<[YPI].get[fyndalingovt]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.maxPlotSize:<[YPI].get[maxplotsize]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.totalInfluence:<[YPI].get[totalinfluence]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.mercenaryGuild:<[YPI].get[mercenaryguild]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.masonsGuild:<[YPI].get[masonsguild]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.prestigeMultiplier:<[YPI].get[perstigemultiplier]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.electionInfluence:<[YPI].get[electioninfluence]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.BMFactionInfluence:<[YBI]> if:<[YBI].exists>

    - flag server kingdoms.claimInfo.allClaims:<yaml[kingdoms].read[all_claims]>

    - yaml id:kingdoms unload
    - yaml id:ps unload

admincallout:
    type: format
    format: "<light_purple>Kingdoms <light_purple>Admin:: <[text]>"