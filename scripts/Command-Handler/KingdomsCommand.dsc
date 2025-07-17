##
## * This file contains the command script which handles this /kingdoms or /ks command, which
## * allows players to retrieve non-kingdom specific information about the world or the game.
## * For the /k or /kingdom command look for the KingdomCommand.dsc file.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2020
## @Update 1: Mar 2021
## @Update 2: Apr-Jun 2022
## @Update 3: Dec 2023
## **** Note: This update entailed the splitting of the former CommandHandler.dsc file into smaller
## ****       sub-files containing each of the separate sub-commands (or sub-command groups) of the
## ****       /k and /ks command handlers. All of the subcommand should be found in their respecti-
## ****       -ve files under this folder.
##
## @Script Ver: v3.0
##
## ------------------------------------------END HEADER-------------------------------------------

# Note: future configurable
#       Just a quick adendum to this note- if there is a larger file for kingdom-specific configs
#       in the future then this stuff should go underneath each of the kingdoms with a scriptable
#       CISK-like set of buffs and debuffs that the players can go in and add themselves.
#
#       Or perhaps there is a static list of ready-made buffs and debuffs that can be selected by
#       name.
#
#       Bottom line is- this data script *NEEDS* to go, since it's probably the last vestige of 4-
#       kingdom hard-coding

Kingdom_Ideas:
    type: data
    # altea
    raptoran:
        debuff:
            name: ANTI-IMPERIALIST
            desc: Claiming core chunks costs 10% more upfront
        buff:
            name: PROVING OUR WORTH
            desc: Gets a 10% boost to point gain during wars
    # muspelheim
    centran:
        debuff:
            name: AILING POWER
            desc: Gets a -15% debuff to point gain during wars
        buff:
            name: HISTORICAL ROOTS
            desc: Claiming core chunks costs 15% less upfront
    viridian:
        debuff:
            name: UNINTERESTED IN COLONIALISM
            desc: Outposts cost twice as much upfront
        buff:
            name: MERCHANT CULTURE
            desc: Recieves twice the amount of black market loot for the same price
    # grovelia
    cambrian:
        debuff:
            name: INDECISIVE COMMANDER
            desc: Declaring and Escalating wars takes $8,500 out of the Kingdom bank
        buff:
            name: RESTORING PRECIPIUM
            desc: Outpost and core claiming cost 10% less each upfront
    fyndalin:
        debuff:
            name: DECLAWED WOLF
            desc: Any military or territorial expansion is locked unless the mandate council provides and exception

        # OK THIS IS BIG IDEA!!
        # Fyndalin becomes player control but is entirely subordinated at the start
        # and much like how the kingdoms have the ability to influence fyndalin,
        # the city state has a mirror mechanic that allows it to counter these tactics
        # by increasing its own autonomy.

        buff:
            name: FESTERING NATIONALISM
            desc: Fyndalin's autonomy will increase exponentially as the game progresses


Kingdoms_Command:
    type: command
    debug: false
    usage: /kingdoms
    name: kingdoms
    description: Umbrella command for kingdoms
    data:
        Credits:
            Lead-Developer: <element[Zyad Osman].color[aqua]> <element[(ZyadTheBoss)].color[blue]>
            Builders:
            - <element[Claude Capellini].color[aqua]> <element[(Spaggyboidotcom)].color[blue]>
            - <element[Alex Raymont].color[aqua]> <element[(lyx3)].color[blue]>
            - <element[Max Chapman].color[aqua]> <element[(Mxchapz)].color[blue]>
            - <element[Ben Tcazuck].color[aqua]> <element[(EchosBattalion)].color[blue]>
            - <element[CJ Howard].color[aqua]> <element[(Shadow31911)].color[blue]>
            Additional-Code-Courtesy-Of:
            - <element[@icecapade / Icecapade#8825].color[gold]><element[ For: ]><element[SimpleSit].click_url[https://github.com/Hydroxycobalamin/Denizen-Script-Collection/blob/main/external/SitScript/SitScript.dsc].underline>
            - <element[@0tickpulse / (0TickPulse#0296)].color[gold]><element[ For: ]><element[Command Manager].click_url[https://github.com/0tickpulse/TickMC/blob/master/plugins/Denizen/scripts/tickutil/tickutil_commands.dsc].underline>
            - <element[@mrm / (MrM#9999)].color[gold]><element[ For: ]><element[Dynmap Polygon Tracer].click_url[https://paste.denizenscript.com/View/111717].underline>

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
        - narrate <element[KINGDOMS: ].color[gold]><element[A Minecraft Strategy Game].color[white]><n>
        - narrate <element[ Current Version: <proc[GetConfigNode].context[General.version].color[aqua]> <element[(Build <proc[GetConfigNode].context[General.build]>)].color[gray]>]>
        - narrate <element[ <&dq><proc[GetConfigNode].context[General.version-name]><&dq>].color[red]>

    - else if <context.args.get[1]> == about:
        - narrate format:callout "Kingdoms is an expansive Minecraft project which aims to blend the worlds of strategy and roleplay gaming into a medival/fantasy world rich with story and possibilities. The game, upon completion, should allow you to do just about anything you want from commanding an army, conducting diplomacy with other kingdoms, improving the lives of your subjects and much more. Kingdoms aims to be one of the most ambitious projects in Minecraft but is currently still in early development."
        - narrate format:callout "Made with ❤ using Denizen©"

    # Note: future configurable
    #       or maybe just nix this completely when it goes into prod.
    - else if <context.args.get[1]> == rules:
        - narrate format:callout "Rules and Guidelines Doc: https://docs.google.com/document/d/1U3_uZp75n77k9t58M0aKWwaUE7wIHL4PyioKMFv3vaQ/edit?usp=sharing"

    - else if <context.args.get[1]> == credits:
        - foreach <script.data_key[data.Credits]>:
            - narrate <&sp>
            - narrate <light_purple><[key].replace[-].with[ ]><&co>

            - foreach <[value]> as:creditLine:
                - define parsedCreditLine <[creditLine].parsed>

                - if <[creditLine].contains_text[.click_url<&lb>]> && <context.source_type> != PLAYER:
                    - define url <[creditLine].split[.click_url<&lb>].get[2].split[<&rb>].get[1]>
                    - define parsedCreditLine <[parsedCreditLine]><element[ (<[url]>)]>

                - narrate <element[- <[parsedCreditLine]>]>
                - wait 10t

        - narrate <&sp>
        - narrate "<&b>Special Thanks: <&9>Denizen Team/Alex Goodwin"
        - narrate "<gray>Learn more at: https://denizenscript.com/"

    - else if <context.args.get[1]> == map:
        - define mapLink <proc[GetConfigNode].context[External.Dynmap.map-link]>

        - if <[mapLink]> == null:
            - narrate <element[There is no live map for this server.].color[blue]>
            - stop

        - narrate "<blue><bold>Kingdoms Live Map:"
        - narrate format:callout <underline><[mapLink]>

    - else if <context.args.get[1]> == ping:
        - if <context.source_type> != PLAYER && <context.args.size> < 2:
            - narrate format:callout "You must specify the name of a player."
            - stop

        - define target <context.args.get[2].if_null[<player>].as[player]>

        - if !<[target].is_online>:
            - narrate format:callout "Cannot get offline players' ping. Please enter the name of an online player."
            - stop

        - if <context.source_type> == PLAYER && <[target]> != <player>:
            - if !<player.has_permission[kingdoms.ping.otherplayers]>:
                - narrate format:callout "You do not have permission to view the ping of other players."
                - stop

        - define ping <[target].ping>
        - define color blue

        - if <[ping].is[OR_MORE].than[900]>:
            - define color gray
        - else if <[ping].is[OR_MORE].than[650]>:
            - define color red
        - else if <[ping].is[OR_MORE].than[270]>:
            - define color yellow
        - else if <[ping].is[OR_MORE].than[50]>:
            - define color green

        - narrate <element[<[target].name.color[red]><&sq>s ping: ].color[gold].bold><element[<[ping]>ms].color[<[color]>]>

    - else if <context.args.get[1]> == travel:
        - if <context.args.size.is[OR_MORE].than[2]>:
            - inject FastTravel

        - else:
            - narrate format:callout "You must specify a location to fast travel to!"

    - else if <context.args.get[1]> == chunkmap:
        - inject ChunkMap
