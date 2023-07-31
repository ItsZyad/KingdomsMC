##
## * The main command handler for all the
## * main kingdoms commands
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2020
## @Update 1: Mar 2021
## @Update 2: Apr-Jun 2022
## @Script Ver: v2.0
##
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

Kingdoms_Command:
    type: command
    usage: /kingdoms
    name: kingdoms
    description: Umbrella command for kingdoms
    aliases:
        - ks
    tab completions:
        1: about|credits|chunkmap|travel|ping|map|rules|version
    tab complete:
    - if <context.args.size> > 1 && <context.args.get[2]> == help:
        - if <script[Help_Strings].list_keys[].contains[<context.args.get[1]>]>:
            - narrate format:callout <script[Help_Strings].data_key[<context.args.get[1]>].parsed>

        - determine cancelled

    - if <context.args.get[1]> == travel && <context.args.size.is[LESS].than[2]>:
        - define allStory <list[]>

        # Note: Not a general case
        - define areaList <player.flag[foundAreas].include[<polygon[INTERNAL_STORY_Fyndalin_Castle]>]>

        - if <player.is_op> || <player.has_permission[kingdoms.admin]>:
            - define areaList <util.notes>

        - foreach <[areaList].filter_tag[<[filter_value].to_uppercase.split[@].get[2].starts_with[INTERNAL_STORY]>]>:
            - if <[value].has_flag[name]>:
                - define allStory:->:<[value].flag[name].replace[_].with[<&sp>]>

        - determine <[allStory]>

    script:
    - if <context.args.get[1]> == version:
        - yaml load:kingdoms.yml id:kingdoms
        - define hoverTest "<&7>Code Compostion: 99.4<&pc> Denizen // 0<&pc> Java // 0.6<&pc> Python"
        - narrate format:callout <yaml[kingdoms].read[version].on_hover[<[hoverTest]>]>
        - yaml load:kingdoms.yml id:kingdoms

    - else if <context.args.get[1]> == about:
        - narrate format:information "Kingdoms is an expansive Minecraft project which aims to blend the worlds of strategy and roleplay gaming into a medival/fantasy world rich with story and possibilities. The game, upon completion, should allow you to do just about anything you want from commanding an army, conducting diplomacy with other kingdoms, improving the lives of your subjects and much more. Kingdoms aims to be one of the most ambitious projects in Minecraft but is currently still in early development."
        - narrate format:information "Made with ❤ using Denizen©"

    - else if <context.args.get[1]> == rules:
        - narrate format:information "Rules and Guidelines Doc: https://docs.google.com/document/d/1U3_uZp75n77k9t58M0aKWwaUE7wIHL4PyioKMFv3vaQ/edit?usp=sharing"

    - else if <context.args.get[1]> == credits:
        - narrate format:information "<&b>Lead Developer: <aqua>Zyad Osman <&9>(ZyadTheBoss)"
        - wait 1s

        - narrate <&sp>
        - narrate format:information "<&b>Builders: <aqua>Ben Tcazuck <&9>(EchosBattalion),"
        - wait 1s

        - narrate format:information "            <aqua>Claude <&9>(Spaggyboidotcom),"
        - wait 1s

        - narrate format:information "            <aqua>Cydnee Howard <&9>(Shadow31911)"
        - wait 1s

        - narrate format:information "            <aqua>Alex Raymont <&9>(lyx3)"
        - wait 1s

        - narrate format:information "            <aqua>Max Chapman <&9>(Mxchapz)"
        - wait 1s

        - narrate <&sp>
        - narrate format:information "<&b>Writing Contributions: <aqua>Claude <&9>(Spaggyboidotcom),"
        - wait 1s

        - narrate format:information "                           <aqua>Philip Harker <&9>(Philidips),"
        - wait 1s

        - narrate <&sp>
        - narrate format:information "<&b>Special Thanks: <&9>Denizen Team/Alex Goodwin"

    - else if <context.args.get[1]> == map:
        - narrate "<blue><bold>Kingdoms Live Map:"
        - narrate format:information <underline>http://5.62.127.51:27204/#close

    - else if <context.args.get[1]> == ping:
        - define ping <player.ping>
        - define color blue

        - if <[ping].is[OR_MORE].than[900]>:
            - define color gray
        - else if <[ping].is[OR_MORE].than[650]>:
            - define color red
        - else if <[ping].is[OR_MORE].than[270]>:
            - define color yellow
        - else if <[ping].is[OR_MORE].than[50]>:
            - define color green

        - narrate "<element[Ping: ].color[gold].bold><element[<[ping]>ms].color[<[color]>]>"

    - else if <context.args.get[1]> == travel:
        - if <context.args.size.is[OR_MORE].than[2]>:
            - inject FastTravel

        - else:
            - narrate format:callout "You must specify a location to fast travel to!"

    - else if <context.args.get[1]> == chunkmap:
        - inject ChunkMap


ChunkMap:
    type: task
    debug: false
    script:
    - define playerChunk <player.location.chunk>
    - define chunkList <list[]>
    - define allClaims <server.flag[kingdoms.claimInfo.allClaims]>
    - define kingdomList <script[KingdomRealNames].data_key[].keys.exclude[type]>

    - repeat 10 from:-5 as:zChunk:
        - repeat 19 from:-9 as:xChunk:
            - define currentChunk <[playerChunk].add[<[xChunk]>,<[zChunk]>]>
            #- narrate format:debug CUR:<[currentChunk]>

            - if <[allClaims].contains[<[currentChunk]>]>:
                - foreach <[kingdomList]> as:kingdom:
                    - define kingdomTerritory <server.flag[kingdoms.<[kingdom]>.claims.castle].include[<server.flag[kingdoms.<[kingdom]>.claims.core]>]>
                    - define kingdomColor <script[KingdomTextColors].data_key[<[kingdom]>]>

                    - if <[currentChunk]> == <[playerChunk]> && <[kingdomTerritory].contains[<[currentChunk]>]>:
                        - define chunkList:->:<element[P].color[<[kingdomColor]>]>
                        - foreach stop

                    - else if <[kingdomTerritory].contains[<[currentChunk]>]>:
                        - define chunkList:->:<element[■].color[<[kingdomColor]>]>
                        - foreach stop

            - else if <[currentChunk]> != <[playerChunk]>:
                - define chunkList:->:<element[-].color[gray]>

            - else:
                - define chunkList:->:<element[P].color[white].on_hover[<[currentChunk]>]>

    - define chunkList <[chunkList].sub_lists[19]>
    - narrate "<gold>=-=-=-=-=-= <element[Chunk Map].color[#f7c64b]> =-=-=-=-=-=-="
    - narrate <[chunkList].parse_tag[<[parse_value].space_separated>].separated_by[<n>]>
    - narrate "- : <gray>Wilderness"
    - narrate "P : <blue>Player"
    - narrate "■ : <gold>Kingdom Claim"
    - narrate "▒ : <green>Kingdom Outpost"


##############################################################################

##ignorewarning ancient_defs

Kingdom_Ideas:
    type: data
    # altea
    raptoran:
        debuff:
            name: "ANTI-IMPERIALIST"
            desc: "Claiming core chunks costs 10% more upfront"
        buff:
            name: "PROVING OUR WORTH"
            desc: "Gets a 10% boost to point gain during wars"
    # muspelheim
    centran:
        debuff:
            name: "AILING POWER"
            desc: "Gets a -15% debuff to point gain during wars"
        buff:
            name: "HISTORICAL ROOTS"
            desc: "Claiming core chunks costs 15% less upfront"
    viridian:
        debuff:
            name: "UNINTERESTED IN COLONIALISM"
            desc: "Outposts cost twice as much upfront"
        buff:
            name: "MERCHANT CULTURE"
            desc: "Recieves twice the amount of black market loot for the same price"
    # grovelia
    cambrian:
        debuff:
            name: "INDECISIVE COMMANDER"
            desc: "Declaring and Escalating wars takes $8,500 out of the Kingdom bank"
        buff:
            name: "RESTORING PRECIPIUM"
            desc: "Outpost and core claiming cost 10% less each upfront"
    fyndalin:
        debuff:
            name: "DECLAWED WOLF"
            desc: "Any military or territorial expansion is locked unless the mandate council provides and exception"

        # OK THIS IS BIG IDEA!!
        # Fyndalin becomes player control but is entirely subordinated at the start
        # and much like how the kingdoms have the ability to influence fyndalin,
        # the city state has a mirror mechanic that allows it to counter these tactics
        # by increasing its own autonomy.

        buff:
            name: "FESTERING NATIONALISM"
            desc: "Fyndalin's autonomy will increase exponentially as the game progresses"

##############################################################################

Help_Strings:
    type: data
    coreclaim: Claims <element[core territory].color[red].on_hover[Territory classed as 'core' is always protected from other players except during times of war.]> for your kingdom. You need to the King or Vizier to do this action!
    castleclaim: Claims <element[castle territory].color[red].on_hover[Your castle will always be protected from other players unless another kingdom has successfully escalated a war after sieging your core territory.]> for your kingdom. You need to the King to do this action!
    balance: Shows the joint kingdom bank account.
    deposit: Adds the specified amount of money to your kingdom's balance.
    withdraw: Transfers the specified amount of money from the kingdom's balance to your personal account.
    trade: Initiates a trade with the specified player.
    rename: Renames the kingdom. <element[This command is restricted!].color[red].on_hover[Only the king can use this command with the the Game Czar's approval.]>
    npc: Use /k npc spawn to open the spawn menu for kingdom NPCs.
    warp: Takes you to your kingdom's private warp location. <red>Note that there is a 30 sec cooldown for this command.
    ideas: Shows your kingdom's ideas. These are a number of buffs and debuffs that apply to kingdom depending on its character and history.
    outline: You can specify either 'castle' or 'core' to show you the bounds of both of those territorial units in your kingdom.
    influence: Opens a menu which shows all the influence actions you can take to bring Fyndalin further under your control, as well as the current status of your kingdom's influence. <red>Can also be accessed using /influence
    guards: Will open your kingdom's guard window which will show all your guard NPCs, their location, status, and other information.
    help: That's so meta...

    travel: Upon selecting one of the options from the tab menu you will be teleported to that fast-travel location's designated waypoint. However you must discover an area first, before you travel to it.
    map: Displays the Kingdoms live map.
    rules: Displays the Kingdoms rules document.
    chunkmap: Displays an in-chat map of the surrounding chunks and their claim status.

##############################################################################

Kingdom_Command:
    type: command
    usage: /kingdom
    name: kingdom
    description: Umbrella command for managing your own kingdom
    aliases:
        - k
    tab completions:
        1: help|coreclaim|castleclaim|balance|guards|deposit|withdraw|trade|rename|npc|warp|ideas|outline|influence
        2: help

    tab complete:
    - if <context.args.size> > 1 && <context.args.get[1]> == warp:
        - if <context.args.get[2].is_in[allow|deny]>:
            - determine <script[KingdomRealShortNames].data_key[].values.exclude[data]>

        - else if <context.args.get[2].starts_with[kingdom<&co>]>:
            - define kingdom <player.flag[kingdom]>
            - define warpList <server.flag[kingdoms.<[kingdom]>.warps].keys>
            - determine <[warpList]>

        - define kingdomRealNames <script[KingdomRealShortNames].data_key[].values.exclude[data]>
        - determine <list[set|list|allow|deny].include[<[kingdomRealNames].parse_tag[<list[kingdom:|<[parse_value]>].unseparated>]>]>

    script:
    - define kingdom <player.flag[kingdom]>

    - if <context.args.get[2]> == help:
        - if <script[Help_Strings].list_keys[].contains[<context.args.get[1]>]>:
            - narrate format:callout <script[Help_Strings].data_key[<context.args.get[1]>].parsed>

        - determine cancelled

    - else if <context.args.get[1]> == help:
        - narrate format:callout "The /k command allows you to interact with most aspects of your kingdom such as finances, resources, trade and more."
        - narrate "<&n>                                       <&n.end_format>"
        - narrate <&sp>
        - narrate format:callout "<&r><italic>You can also type 'help' after each of the kingdom commands to learn more about them individually."

    - else if <context.args.get[1]> == outline:
        # DEFINE PARAM GLOBALS #
        - define param <context.args.get[2]>
        - define jointCuboid 0
        - define persistTime 10
        - define territoryType castle_territory

        - if <context.args.size.is[LESS].than[2]>:
            - narrate format:callout "Insufficient or too many parameters. Please specify either castle or core territory to outline"

        - else if <[param].is_in[castle|core]>:
            - define territoryType <[param]>
            - define jointCuboid <server.flag[kingdoms.<[kingdom]>.claims.<[param]>].get[1].cuboid.if_null[0]>

        - else:
            - narrate format:callout "<[param].to_titlecase> is not a valid territory type!"
            - determine cancelled

        - if <[jointCuboid]> == 0:
            - narrate format:callout "Your kingdom doesn't seem to have any <[param]> territory yet :/"
            - determine cancelled

        # If the player specificies a duration tag then check if the duration is more
        # than 0 and set persistTime as it

        - if <context.args.get[3].starts_with[duration:]>:
            - define duration <context.args.get[3].split[duration:].get[2]>

            # Ensure that if a duration is specified, it is less than 2min and more than 1s.
            # If player specifies invalid amount the whole command request is discarded

            - if <[duration].is[OR_MORE].than[1]> && <[duration].is[OR_LESS].than[120]>:
                - define persistTime <[duration]>

            - else:
                - narrate format:callout "Invalid duration! Please ensure that outline durations are between 1s and 120s."
                - determine cancelled

        # Loop through the suitable type of territory (depending on what the player specified)
        # excluding the first territory since the joinCuboid is initialized with the first
        # already added

        - foreach <server.flag[kingdoms.<[kingdom]>.claims.<[territoryType]>].exclude[<server.flag[kingdoms.<[kingdom]>.claims.<[territoryType]>].get[1]>]>:
            - if <[value].cuboid.world> != <player.location.world>:
                - foreach next

            - define jointCuboid <[jointCuboid].add_member[<[value].cuboid>]>

        # Show the borders at different altitudes depending on if the player is flying or
        # on the ground

        - if <player.is_flying>:
            - showfake green_stained_glass <[jointCuboid].outline_2d[<player.location.y.sub[10]>]> duration:<[persistTime]>

        - else:
            - showfake red_stained_glass <[jointCuboid].outline_2d[<player.location.y.add[20]>]> duration:<[persistTime]>

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.raw_args> == coreclaim:
        #- if <player.has_permission[kingdom.cancoreclaim]>:
        - if <player.has_flag[ClaimingMode]> && <player.flag[ClaimingMode]> == CoreClaiming:
            - flag <player> ClaimingMode:!
            - narrate format:callout "You have exited core claiming mode"

        - else:
            - flag <player> ClaimingMode:CoreClaiming
            - narrate format:callout "You are now in core claiming mode"
            - narrate format:callout "Use /claim to claim a chunk for your kingdom!"

            - define realPrestige <element[100].sub[<server.flag[kingdoms.<[kingdom]>.prestige]>]>
            - define prestigeMultiplier <util.e.power[<element[0.02186].mul[<[realPrestige]>]>].sub[0.9]>
            - define corePrice <[prestigeMultiplier].mul[100].round_to_precision[100]>

            - narrate format:callout "Current core chunk price is: <red><bold>$<[corePrice]>"

        #- else:
        #    - narrate format:callout "You do not have sufficient power in the kingdom to carry out this command! Ask your king or their second-in-command to carry out this action."

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == castleclaim:
        - define param <context.args.get[2]>

        - if <[param]> == unclaim:
            #- if <player.has_permission[kingdoms.admin.unclaim]> || <player.is_op>:

            - if <server.flag[kingdoms.<player.flag[kingdom]>.claims.castle].contains[<player.location.chunk>]>:
                - flag server kingdoms.<player.flag[kingdom]>.claims.castle:<-:<player.location.chunk>
                - flag server kingdoms.allClaims:<-:<player.location.chunk>

            - else:
                - narrate format:admin "This area is not a castle claim"

            #- else:
            #    - narrate format:callout "You do not have sufficient power in the kingdom to carry out this command! Ask your king or their second-in-command to carry out this action."

        - else:
            #- if <player.has_permission[kingdom.cancastleclaim]>:
            - if <player.has_flag[ClaimingMode]> && <player.flag[ClaimingMode]> == CastleClaiming:
                - flag <player> ClaimingMode:!
                - narrate format:callout "You have exited castle claiming mode"

            - else:
                - flag <player> ClaimingMode:CastleClaiming
                - narrate format:callout "You are now in castle claiming mode"
                - narrate format:callout "Use /claim to claim a chunk for your castle!"

            #- else:
            #    - narrate format:callout "You do not have sufficient power in the kingdom to carry out this command! Ask your king or their second-in-command to carry out this action."

        - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>

    #------------------------------------------------------------------------------------------------------------------------

    # So far this doesn't really do much but when I figure how to integrate
    # Kingdoms into dynamap, it will help players visualize where the intended
    # extent of each kingdom is

    - else if <context.args.get[1]> == layclaim:
        - narrate "Making unofficial claim to: <player.location.chunk>"
        - flag server kingdoms.<player.flag[kingdom]>.unofficial_claim:->:<player.location.chunk>

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.raw_args> == balance:
        - narrate format:callout "Balance for <proc[KingdomNameReplacer].context[<player.flag[kingdom]>]>"
        - narrate $<server.flag[kingdoms.<player.flag[kingdom]>.balance].format_number.color[red]>

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == deposit:
        #- if <player.has_permission[kingdom.deposit]>:
        - define amount <context.args.get[2]>

        - if <player.money.is[OR_MORE].than[<[amount]>]>:
            - flag server kingdoms.<player.flag[kingdom]>.balance:+:<[amount]>
            - money take from:<player> quantity:<[amount]>

            - narrate format:callout "Successfully deposited: $<[amount].as_money>"

        - else:
            - narrate format:callout "You do not have sufficient funds to perform this action."

        # if the kingdom was previously indebted but has now pushed back
        # into the positives then clear its debt status from the appropriate
        # flag on the server

        - if <server.flag[indebtedKingdoms].get[<player.flag[kingdom]>].exists>:
            - if <server.flag[kingdoms.<player.flag[kingdom]>.balance].is[OR_MORE].than[0]>:
                - flag server indebtedKingdoms.<player.flag[kingdom]>:0

        - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>

        #- else:
        #    - narrate format:callout "You do not have sufficient power in the kingdom to carry out this command! Ask your king or their second-in-command to carry out this action."

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == withdraw:
        #- if <player.has_permission[kingdom.withdraw]>:
        - define offerWorth null

        - foreach <server.flag[fyndalin].get[loanOffers]>:
            - if <[value].get[kingdom]> == <[kingdom]>:
                - define offerWorth <[value].get[amount]>

        - define amount <context.args.get[2]>

        - if <server.flag[kingdoms.<[kingdom]>.balance].sub[<[amount]>].is[LESS].than[<[offerWorth].if_null[0]>]>:
            - narrate format:callout "Your kingdom has an active loan offer to Fyndalin worth: $<[offerWorth]>. You may not withdraw an amount that would place you below that amount until the offer is resolved."

        - else if <server.flag[kingdoms.<[kingdom]>.balance].is[OR_MORE].than[<[amount]>]>:
            - money give to:<player> quantity:<[amount]>
            - flag server kingdoms.<[kingdom]>.balance:-:<[amount]>

            - narrate format:callout "Successfully withdrawn: $<[amount].as_money>"

        - else:
            - narrate format:callout "You do not have sufficient funds in your kingdom to withdraw"

        - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>].get[members].include[<server.online_ops>]>

        #- else:
        #    - narrate format:callout "You do not have sufficient power in the kingdom to carry out this command! Ask your king or their second-in-command to carry out this action."

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == rename:
        - if <player.has_permission[kingdom.canrename]>:
            - define newName <context.raw_args.split[rename].get[2]>
            - flag server kingdoms.<player.flag[kingdom]>.name:<[newName]>

            - narrate format:debug <context.raw_args.split[rename].get[2]>

        - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>].get[members].include[<server.online_ops>]>

        - else:
            - narrate format:callout "This command requires permission from the server owner to perform!"

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == npc:
        - if <server.has_flag[PreGameStart]> && !<player.is_op>:
            - narrate format:callout "Sorry! You cannot use this while the server is still in build mode!"
            - determine cancelled

        #- if <player.has_permission[kingdom.npc.spawn]>:
        - define coreLoc <server.flag[kingdoms.<[kingdom]>.claims.core].as[list]>
        - define castleLoc <server.flag[kingdoms.<[kingdom]>.claims.castle].as[list]>

        - define isInClaimedLoc <[coreLoc].include[<[castleLoc]>].contains[<player.location.chunk>].if_null[false]>

        # Only allow players to spawn in NPCs if they are in their own
        # kingdom's territory

        - if !<[isInClaimedLoc]>:
            - foreach <server.flag[kingdoms.<[kingdom]>.outposts].keys.exclude[totalUpkeep]>:
                - define cornerOne <server.flag[kingdoms.<[kingdom]>.<[value]>.cornerOne].with_y[255]>
                - define cornerTwo <server.flag[kingdoms.<[kingdom]>.<[value]>.cornerTwo].with_y[0]>
                - define outpostCuboid <cuboid[<player.location.world.name>,<[cornerOne].xyz>,<[cornerTwo].xyz>]>

                - if <[outpostCuboid].contains[<player.location>]>:
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

        #- else:
        #    - narrate format:callout "You do not have sufficient power in the kingdom to carry out this command! Ask your king or their second-in-command to carry out this action."

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == warp:
        - define kingdom <player.flag[kingdom]>

        # If the player has recently engaged in combat with another player then
        # they will not be allowed to use or set warps
        - if !<player.has_flag[combatMode]>:

            # If the player specifies any parameter for the command
            - define param <context.args.get[2].if_null[main]>

            #- narrate format:debug <[param]>

            - if <[param]> == set:
                #- if <player.has_permission[kingdom.setwarp]> || <player.is_op>:

                # If the player does not specify a specific warp name the game will assume
                # they are trying to reset their main castle spawn.
                - define warpName <context.raw_args.split_args.get[3].if_null[main]>
                - define castle <server.flag[kingdoms.<[kingdom]>.claims.castle].as[list]>
                - define core <server.flag[kingdoms.<[kingdom]>.claims.core].as[list]>
                - define castleCore <[core].include[<[castle]>].exclude[0]>
                - define outpostAreas <proc[GetAllOutposts].context[<[kingdom]>].values.parse_tag[<[parse_value].get[area]>]>
                - define inWhichOutpostAreas <[outpostAreas].filter_tag[<[parse_value].contains[<player.location>]>]>

                - if <[warpName]> == main:
                    - if <[castle].contains[<player.location.chunk>]>:

                        - clickable save:confirm_warp until:1m usages:1:
                            - flag server kingdoms.<[kingdom]>.warps.main:<player.location.center>
                            - narrate format:callout "Warp location has been set to: <aqua><player.location.round.xyz>"

                        - clickable save:decline_warp until:1m usages:1:
                            - narrate format:callout "Cancelled warp creation."
                            - clickable cancel:<entry[confirm_warp].id>

                        - narrate format:callout "Not specifying a name for the warp will change your main kingdom warp. Are you sure you would like to do this?"
                        - narrate format:callout "<element[YES].bold.underline.on_click[<entry[confirm_warp].command>]> / <element[NO].bold.underline.on_click[<entry[decline_warp].command>]>"

                    - else:
                        - narrate format:callout "You must place your kingdom's main warp location inside your castle territory!"

                - else:
                    - if <[castleCore].contains[<player.location.chunk>]> || <[inWhichOutpostAreas].size> > 0:
                        - flag server kingdoms.<[kingdom]>.warps.<[warpName]>:<player.location.center>

                    - else:
                        - narrate format:callout "Regular kingdom warps must be within castle, core, or outpost territory"

                #- else:
                #    - narrate format:callout "You do not have sufficient power in the kingdom to carry out this command! Ask your king or their second-in-command to carry out this action."

            - else if <[param].starts_with[kingdom<&co>]>:
                - define chosenKingdomRN <[param].split[<&co>].get[2]>
                - define warpName <context.args.get[3].if_null[main]>
                - define kingdomRealNames <script[KingdomRealShortNames].data_key[].values.exclude[data]>
                - define chosenKingdomCN <script[KingdomRealShortNames].data_key[].invert.get[<[chosenKingdomRN]>]>

                - if <[chosenKingdomRN]> == <script[KingdomRealShortNames].data_key[<[kingdom]>]>:
                    - narrate format:callout "You do not need to specify the kingdom when teleporting to your own warps."
                    - determine cancelled

                - if <[chosenKingdomRN].is_in[<[kingdomRealNames]>]>:
                    - if <server.flag[kingdoms.<[chosenKingdomCN]>.openWarp].contains[<[kingdom]>]>:
                        - if <server.flag[kingdoms.<[chosenKingdomCN]>.warps.<[warpName]>].exists>:
                            - define warpLoc <server.flag[kingdoms.<[chosenKingdomCN]>.warps.<[warpName]>]>
                            - narrate format:callout "Warping in 3 seconds..."
                            - chunkload add <[warpLoc].chunk> duration:1m

                            - wait 3s

                            - teleport <player> <[warpLoc]>

                        - else:
                            - narrate format:callout "Unknown warp. Ensure that the chosen kingdom has a warp with this name."

                    - else:
                        - narrate format:callout "The kingdom specified has not opened its warps to you."

                - else:
                    - narrate format:callout "Invalid kingdom name."

            - else if <[param]> == list:
                - if !<server.flag[kingdoms.<[kingdom]>.warps].as[list].get[1].exists>:
                    - narrate format:callout "Your kingdom doesn't have any warps! Consider setting a private castle warp by standing in the desired warp location and typing <aqua>/k warp set"

                - else:
                    - foreach <server.flag[kingdoms.<[kingdom]>.warps].to_pair_lists> as:warp:
                        - narrate "<green>--<&gt> <[warp].get[1].color[aqua].bold><&co> <[warp].get[2].round.simple>"

            - else if <[param]> == deny:
                - define kingdomCodeName <script[KingdomRealShortNames].data_key[].invert.get[<context.args.get[3]>]>
                - if <server.flag[kingdoms.<[kingdom]>.openWarp].contains[<[kingdomCodeName]>]>:
                    - flag server kingdoms.<[kingdom]>.openWarp:<-:<[kingdomCodeName]>
                    - narrate format:callout "Removed kingdom: <context.args.get[3].color[red].bold> from your warp whitelist!"

                - else:
                    - narrate format:callout "That kingdom was already not on your kingdom's warp whitelist."

            - else if <[param]> == allow:
                - define kingdomRealNames <script[KingdomRealShortNames].data_key[].values.exclude[data]>
                - define kingdomCodeNames <script[KingdomRealShortNames].data_key[].keys.exclude[type]>

                - if !<context.args.get[3].exists>:
                    - define openWarp <server.flag[kingdoms.<[kingdom]>.openWarp]>

                    - if <[openWarp].size.if_null[0]> == 0:
                        - narrate format:callout "Your kingdom has its warps closed to all kingdoms"

                    - else:
                        - narrate format:callout "Kingdoms that can access your warps:<n><server.flag[kingdoms.<[kingdom]>.openWarp].parse_tag[<script[KingdomRealShortNames].data_key[<[parse_value]>]>].separated_by[<n>]>"

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
                - define warpArea <[param]>

                - if !<server.flag[kingdoms.<[kingdom]>.warps.<[param]>]>:
                    - clickable save:confirm_warp usages:1 until:1m:
                        - narrate format:callout "Warping in 3 seconds..."
                        - chunkload add <server.flag[kingdoms.<[kingdom]>.warps.<[warpArea]>].chunk> duration:1m

                        - wait 3s

                        - teleport <player> <server.flag[kingdoms.<[kingdom]>.warps.<[warpArea]>]>
                        - clickable cancel:<entry[decline_warp].id>

                    - clickable save:decline_warp usages:1 until:1m:
                        - narrate format:callout "Cancelled warp creation."
                        - clickable cancel:<entry[confirm_warp].id>

                    - define warpArea main
                    - narrate format:callout "Not specifying a name for the warp will take you to your kingdom's main warp. Do you want to do this?"
                    - narrate format:callout "<element[YES].bold.underline.on_click[<entry[confirm_warp].command>]> / <element[NO].bold.underline.on_click[<entry[decline_warp].command>]>"

                - else if <server.flag[kingdoms.<[kingdom]>.warps]> != null:
                    - narrate format:callout "Warping in 3 seconds..."
                    #- narrate format:debug <[kingdom]>
                    #- chunkload add <server.flag[kingdoms.<[kingdom]>.warps.main].chunk> duration:1m

                    - wait 3s

                    - teleport <player> <server.flag[kingdoms.<[kingdom]>.warps.main]>
                    #- narrate format:debug <server.flag[kingdoms.<[kingdom]>.warps]>

                - else:
                    - narrate format:callout "Your kingdom does not currently have a warp location. You may want to speak to your king about this."

        - else:
            - narrate format:callout "You may not use warps, you are in <red>combat mode!"

    #------------------------------------------------------------------------------------------------------------------------

    - else if <context.args.get[1]> == ideas:
        - if <script[Kingdom_Ideas].list_keys[].contains[<player.flag[kingdom]>]>:
            - define kingdom <player.flag[kingdom]>

            # A whole lotta formatting crap here;
            # This command will write out the kingdom's buffs and debuffs like this:
            # Kingdom Ideas for: <bold>[KINGDOM]
            # <green/bold>[BUFF NAME]
            # <gray>[BUFF DESCRIPTION]
            # <red/bold>[DEBUFF NAME]
            # <gray>[DEBUFF DESCRIPTION]

            - narrate "<&n>                                       <&n.end_format>"
            - narrate <&sp>
            - narrate "<bold>Kingdom Ideas for: <proc[KingdomNameReplacer].context[<[kingdom]>]>"
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

    - else if <context.args.get[1]> == guards:
        - define kingdom <player.flag[kingdom]>

        - if <context.args.get[2]> == list || <context.args.size> == 1:
            - define kingdomGuardList <list[]>

            - foreach <server.flag[kingdoms.<[kingdom]>.castleGuards]> as:guard:
                - if <[guard].flag[kingdom]> == <[kingdom]>:
                    - define guardItem <item[GuardList_Item]>
                    - define kingdomColor <script[KingdomTextColors].data_key[<[kingdom]>]>

                    - adjust def:guardItem skull_skin:<[guard].skull_skin>
                    - adjust def:guardItem display:<element[<[guard].name>].bold.color[<[kingdomColor]>]>
                    - adjust def:guardItem "lore:|<element[Location: ].bold.color[white]><element[<[guard].location.round.xyz>].color[aqua]>"
                    - flag <[guardItem]> referencedGuard:<[guard]>

                    - define kingdomGuardList:->:<[guardItem]>

            - run New_Paginate_Task def.itemList:<[kingdomGuardList]> def.itemsPerPage:36 def.page:1 save:paginate
            - define paginatedGuardList <entry[paginate].created_queue.determination.get[1]>

            - flag <player> guardListPage:1
            - flag <player> kingdomGuardItems:<[paginatedGuardList]>
            - inventory open d:KingdomGuardList_Window

    - else:
        - narrate format:callout "Unrecognized argument: <context.args.get[1].color[red]>"

    #------------------------------------------------------------------------------------------------------------------------
    #- START FOLDED COMMANDS
    #------------------------------------------------------------------------------------------------------------------------

    - if <context.args.get[1]> == influence:
        - execute as_player influence

##############################################################################

KingdomGuardList_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Kingdom Guards
    procedural items:
    - determine <player.flag[kingdomGuardItems]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [Page_Back] [] [Page_Forward] [] [] []

KingdomGuardRespawn_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Respawn Guard?
    slots:
    - [] [] [] [] [GuardRespawn_Item] [] [] [] []

GuardList_Item:
    type: item
    material: player_head
    display name: <gray><bold>Unknown Guard

GuardRespawn_Item:
    type: item
    material: respawn_anchor
    display name: Respawn Guard
    lore:
    - Cost: <element[$100].color[red].bold>
    flags:
        cost: 100

KingdomGuardList_Handler:
    type: world
    events:
        on player clicks Page_Back in KingdomGuardList_Window:
        - if <player.flag[guardListPage].is[MORE].than[1]>:
            - flag <player> guardListPage:--

        on player clicks Page_Forward in KingdomGuardList_Window:
        - flag <player> guardListPage:++

        on player closes KingdomGuardList_Window:
        - flag <player> guardListPage:!
        - flag <player> kingdomGuardItems:!

        on player clicks GuardList_Item in KingdomGuardList_Window:
        - define guard <context.item.flag[referencedGuard]>

        - if <[guard].exists> && <[guard].is_spawned>:
            - inventory open d:Guard_Window

        - else:
            - inventory open d:KingdomGuardRespawn_Window

        - flag <player> clickedNPC:<[guard]>

        on player clicks GuardRespawn_Item in KingdomGuardRespawn_Window:
        - define kingdom <player.flag[kingdom]>
        - define kingdomBalance <server.flag[kingdoms.<[kingdom]>.balance]>
        - define respawnCost <context.item.flag[cost]>

        - if <[kingdomBalance]> >= <[respawnCost]>:
            - flag server kingdoms.<[kingdom]>.balance:-:<[respawnCost]>
            - run SidebarLoader def:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>
            - narrate format:callout "Respawned castle guard at their previously defined anchor position!"

        - else:
            - narrate format:callout "Your kingdom does not have enough funds in its treasury to replace this guard!"

        - inventory close

##############################################################################

##ignorewarning enumerated_script_name

debug:
    type: format
    format: "<gray>[Kingdoms Debug] <&gt><&gt> <[text]>"

information:
    type: format
    format: "<&9><[text]>"

callout:
    type: format
    format: "<white>[Kingdoms] <&gt><&gt> <&6><[text]>"

npctalk:
    type: format
    format: "<light_purple><bold>[NPC] <&r><red>-<&gt> <light_purple><bold>[YOU]: <white><[text]>"