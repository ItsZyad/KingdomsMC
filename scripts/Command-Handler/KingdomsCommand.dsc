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
        - narrate format:callout "Kingdoms is an expansive Minecraft project which aims to blend the worlds of strategy and roleplay gaming into a medival/fantasy world rich with story and possibilities. The game, upon completion, should allow you to do just about anything you want from commanding an army, conducting diplomacy with other kingdoms, improving the lives of your subjects and much more. Kingdoms aims to be one of the most ambitious projects in Minecraft but is currently still in early development."
        - narrate format:callout "Made with ❤ using Denizen©"

    # Note: future configurable
    #       or maybe just nix this completely when it goes into prod.
    - else if <context.args.get[1]> == rules:
        - narrate format:callout "Rules and Guidelines Doc: https://docs.google.com/document/d/1U3_uZp75n77k9t58M0aKWwaUE7wIHL4PyioKMFv3vaQ/edit?usp=sharing"

    - else if <context.args.get[1]> == credits:
        - narrate "<&b>Lead Developer: <aqua>Zyad Osman <&9>(ZyadTheBoss)"
        - wait 1s

        - narrate <&sp>
        - narrate "<&b>Builders: <aqua>Ben Tcazuck <&9>(EchosBattalion),"
        - wait 1s

        - narrate "            <aqua>Claude <&9>(Spaggyboidotcom),"
        - wait 1s

        - narrate "            <aqua>Cydnee Howard <&9>(Shadow31911)"
        - wait 1s

        - narrate "            <aqua>Alex Raymont <&9>(lyx3)"
        - wait 1s

        - narrate "            <aqua>Max Chapman <&9>(Mxchapz)"
        - wait 1s

        - narrate <&sp>
        - narrate "<&b>Writing Contributions: <aqua>Claude <&9>(Spaggyboidotcom),"
        - wait 1s

        - narrate "                           <aqua>Philip Harker <&9>(Philidips),"
        - wait 1s

        - narrate <&sp>
        - narrate "<&b>Additional Code<n>Courtesy Of: <aqua>@icecapade <&9>(Icecapade#8825),"
        - narrate "<gray>For: <blue><element[SimpleSit].click_url[https://github.com/Hydroxycobalamin/Denizen-Script-Collection/blob/main/external/SitScript/SitScript.dsc].underline>"
        - wait 1s

        - narrate "             <aqua>@0tickpulse <&9>(0TickPulse#0296),"
        - narrate "<gray>For: <blue><element[Command Manager].click_url[https://github.com/0tickpulse/TickMC/blob/master/plugins/Denizen/scripts/tickutil/tickutil_commands.dsc].underline>"
        - wait 1s

        - narrate "             <aqua>@mrm <&9>(MrM#9999),"
        - narrate "<gray>For: <blue><element[Dynmap Polygon Tracer].click_url[https://paste.denizenscript.com/View/111717].underline>"
        - wait 1s

        - narrate <&sp>
        - narrate "<&b>Special Thanks: <&9>Denizen Team/Alex Goodwin"
        - narrate "<gray>Learn more at: https://denizenscript.com/"

    # Note: future configurable
    - else if <context.args.get[1]> == map:
        - narrate "<blue><bold>Kingdoms Live Map:"
        - narrate format:callout <underline>http://5.62.127.51:27204/#close

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

        - narrate <element[Ping: ].color[gold].bold><element[<[ping]>ms].color[<[color]>]>

    - else if <context.args.get[1]> == travel:
        - if <context.args.size.is[OR_MORE].than[2]>:
            - inject FastTravel

        - else:
            - narrate format:callout "You must specify a location to fast travel to!"

    - else if <context.args.get[1]> == chunkmap:
        - inject ChunkMap
