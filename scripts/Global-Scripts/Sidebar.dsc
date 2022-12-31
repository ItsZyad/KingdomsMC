##
## * Sidebar function capable of refreshing/setting/
## * removing the sidebar for targetted players
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Dec 2021
## @Script Ver: v1.0
##
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

# So far this is the closest thing I will have to a dedicated script that sets people's kingdom flag

SetInitialSidebar:
    type: world
    debug: false
    events:
        on player joins:
        - run SidebarLoader def:<player>

        - if !<player.has_flag[kingdom]>:
            - narrate format:debug "<yellow><bold>WARNING: <&r>Player kingdom flag not set! Using kingdom functions may have unexpected/untested side-effects"

InfluenceBonusReference:
    type: data
    merchantDiscount:
        type: replaceText
        template: "-{text}<&pc> Discount off Regular Merchants"

    bonusTax:
        type: replaceText
        template: "+${text} of Fyndalin's Tax Money"

    controlStatus:
        type: textRef
        ref:
            null: "Negligble"
            DeJure: "De-Jure/Loose"
            DeFacto: "De-Facto/Significant"
            Direct: "Strong"
            Absolute: "Absolute"

##ignorewarning def_of_nothing

SidebarLoader:
    type: task
    #debug: false
    definitions: target|changeSBState
    script:
    - define war-true <red><bold>
    - define war-false <green>
    - define changeSBState <[changeSBState].if_null[true]>
    - yaml load:kingdoms.yml id:k
    - yaml load:powerstruggle.yml id:ps
    - yaml load:outposts.yml id:outp

    - if <[target].object_type> != List:
        - define target <list[<[target]>]>

    - foreach <[target]>:
        - define kingdomData <yaml[k].read[<[value].flag[kingdom]>]>
        - define totalOutpostUpkeep <yaml[outp].read[<[value].flag[kingdom]>.totalupkeep]>

        - if !<[value].sidebar_lines.exists> && !<[changeSBState]>:
            - foreach next

        - if <[value].has_flag[kingdom]>:

            # Initialize and set Balance line
            - define kingdom <[value].flag[kingdom]>
            - define kingdomName <script[KingdomRealNames].data_key[<[kingdom]>]>
            - sidebar set title:<bold><[kingdomName].color[<script[KingdomTextColors].data_key[<[value].flag[kingdom]>]>]> "values:<&r>|<&sp>Balance: <yellow>$<[kingdomData].get[balance].round_down.format_number>" players:<[value]>

            # Set Upkeep Line
            - if !<server.has_flag[PauseUpkeep]>:
                - sidebar add "values:<&sp>Upkeep: <yellow>$<[kingdomData].get[upkeep].add[<[totalOutpostUpkeep].if_null[0]>].round_down.format_number>" players:<[value]>

            - else:
                - sidebar add "values:<&sp>Upkeep: <aqua>Frozen!" players:<[value]>

            - if <server.flag[<[kingdom]>].deep_get[influenceBonuses.bonusTax].exists>:
                - sidebar add "values:<&sp>Fyndalin Tax Bonus: <green>$<server.flag[<[kingdom]>].deep_get[influenceBonuses.bonusTax].format_number>" players:<[value]>

            # Set Core Claim amount line
            - sidebar add "values:<&sp>Core Claims: <[kingdomData].get[core_claims].size.if_null[0]> / <[kingdomData].get[core_max]>" players:<[value]>

            # Set Castle Territory line
            - sidebar add "values:<&sp>Castle Claims: <[kingdomData].get[castle_territory].size.if_null[0]> / <[kingdomData].get[castle_max]>" players:<[value]>

            # Set War Status Line
            - sidebar add "values:<&sp>War Status: <[war-<[kingdomData].get[war_status]>]><[kingdomData].get[war_status]>" players:<[value]>

            # Set Outpost Count Line
            - sidebar add "values:<&sp>Outpost Count: <[kingdomData].get[outpost_count]>" players:<[value]>

            # Set Prestige Line
            - sidebar add "values:<&sp>Prestige: <[kingdomData].get[prestige]> / 100" players:<[value]>

            # Set Influences Line
            - sidebar add "values:<&sp>Influence Points: <yaml[ps].read[<[value].flag[kingdom]>.dailyinfluences]>" players:<[value]>

            # Separator Line
            - sidebar add values:<underline><element[<&sp>].repeat[40]> players:<[value]>
            - sidebar add values:<&sp> players:<[value]>

            # Set Quests Title
            - sidebar add "values:<&sp><bold><element[ACTIVE QUESTS:].color[<script[KingdomTextColors].data_key[<[value].flag[kingdom]>]>]>" players:<[value]>

        - else:
            - sidebar set title:<bold><gray>KINGDOMLESS

            - sidebar add "values:Upkeep: <gray>$####"
            - sidebar add "values:Core Claims: ##/##"
            - sidebar add "values:Castle Claims: ##/##"
            - sidebar add "values:War Status: N/A"
            - sidebar add "values:Outpost Count: ##"
            - sidebar add "values:Prestige: ##"
            - sidebar add values:<&sp>
            - sidebar add "values:<&sp><bold><gray>ACTIVE QUESTS:"

        - define activeQuestCount 0

        - if <[value].has_flag[quests]>:
            - foreach <[value].flag[quests]> as:quest:
                - if <[activeQuestCount]> == 7:
                    - sidebar add "values:<italic><gray>And more - check <aqua>/quests <gray>menu" players:<[value]>
                    - foreach stop

                - if <[quest].get[status]> == active:
                    - sidebar add values:-<&sp><[quest].get[name]> players:<[value]>
                    - define activeQuestCount:++

        # - if <[value].in_group[BDagger]> || <[value].is_op>:
        #     - sidebar add values:<underline><element[<&sp>].repeat[40]> players:<[value]>
        #     - sidebar add values:<&sp> players:<[value]>

        #     - sidebar add "values:<&sp><bold><blue>THE BLUE DAGGER" players:<[value]>

        #     - sidebar add "values:<&sp>Balance<&co> <yellow>$<server.flag[bd.balance].if_null[0].format_number>" players:<[value]>

    - yaml id:k unload
    - yaml id:ps unload
    - yaml id:outp unload

    - if <server.has_flag[RestrictedCreative]>:
        - bossbar remove resCre
        - bossbar create resCre title:Restricted<&sp>Creative color:purple

SidebarSeparator:
    type: procedure
    definitions: target
    script:
    - define sidebar <[target].sidebar_lines>
    - define longestLine 0

    - foreach <[sidebar]>:
        - if <[value].length.is[OR_MORE].than[<[longestLine]>]>:
            - define longestLine <[value].length>

    - define outLine <list[<&sp>|<&n>]>

    - narrate <[longestLine]>

    - repeat <[longestLine].add[4]>:
        - define outLine:->:<&sp>

    - define outLine:->:<&n.end_format>
    - determine <[outLine].unseparated>

ToggleSidebar_Command:
    type: command
    description: "command for managing the Kingdoms sidebar"
    usage: /sidebar
    name: sidebar
    tab completions:
        1: hide|show
    script:
    - if <context.raw_args> == hide:
        - sidebar remove

    - else if <context.raw_args> == show:
        - sidebar remove
        - run SidebarLoader def:<player>|true
