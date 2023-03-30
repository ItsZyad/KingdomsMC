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
    debug: false
    definitions: target|changeSBState
    script:
    - define war-true <red><bold>
    - define war-false <green>
    - define changeSBState <[changeSBState].if_null[true]>

    - if <[target].object_type> != List:
        - define target <list[<[target]>]>

    - foreach <[target]>:
        - if !<[value].sidebar_lines.exists> && !<[changeSBState]>:
            - foreach next

        - if <[value].has_flag[kingdom]>:

            # Initialize and set Balance line
            - define kingdom <[value].flag[kingdom]>
            - define kingdomName <script[KingdomRealNames].data_key[<[kingdom]>]>
            - define kingdomData <server.flag[kingdoms.<[kingdom]>]>
            - define totalOutpostUpkeep <server.flag[<[kingdom]>.outposts.totalUpkeep].if_null[0]>
            - sidebar set "title:<bold>  <[kingdomName].color[<script[KingdomTextColors].data_key[<[value].flag[kingdom]>]>]>  " "values:<&r>|<&sp>Balance: <yellow>$<[kingdomData].get[balance].round_down.format_number>" players:<[value]>

            # Set Upkeep Line
            - if !<server.has_flag[PauseUpkeep]>:
                - sidebar add "values:<&sp>Upkeep: <yellow>$<[kingdomData].get[upkeep].add[<[totalOutpostUpkeep].if_null[0]>].round_down.format_number>" players:<[value]>

            - else:
                - sidebar add "values:<&sp>Upkeep: <aqua>Frozen!" players:<[value]>

            - if <server.flag[kingdoms.<[kingdom]>.powerstruggle.influenceBonuses.bonusTax].exists>:
                - sidebar add "values:<&sp>Fyndalin Tax Bonus: <green>$<server.flag[kingdoms.<[kingdom]>.powerstruggle.influenceBonuses.bonusTax].format_number>" players:<[value]>

            # Set Core Claim amount line
            - sidebar add "values:<&sp>Core Claims: <[kingdomData].deep_get[claims.core].size.if_null[0]> / <[kingdomData].deep_get[claims.coreMax]>" players:<[value]>

            # Set Castle Territory line
            - sidebar add "values:<&sp>Castle Claims: <[kingdomData].deep_get[claims.castle].size.if_null[0]> / <[kingdomData].deep_get[claims.castleMax]>" players:<[value]>

            # Set War Status Line
            - sidebar add "values:<&sp>War Status: <[war-<[kingdomData].deep_get[warStatus]>]><[kingdomData].deep_get[warStatus].if_true[At War].if_false[At Peace]>" players:<[value]>

            # Set Outpost Count Line
            - sidebar add "values:<&sp>Outpost Count: <[kingdomData].deep_get[outposts.outpostList].size.if_null[0]>" players:<[value]>

            # Set Prestige Line
            - sidebar add "values:<&sp>Prestige: <[kingdomData].deep_get[prestige]> / 100" players:<[value]>

            # Set Influences Line
            - sidebar add "values:<&sp>Influence Points: <[kingdomData].deep_get[powerstruggle.influencePoints]>" players:<[value]>

            # Separator Line
            - sidebar add values:<element[<&sp>].repeat[30]> players:<[value]>

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

        # - if <[value].in_group[BDagger]> || <[value].is_op>:
        #     - sidebar add values:<underline><element[<&sp>].repeat[40]> players:<[value]>
        #     - sidebar add values:<&sp> players:<[value]>

        #     - sidebar add "values:<&sp><bold><blue>THE BLUE DAGGER" players:<[value]>

        #     - sidebar add "values:<&sp>Balance<&co> <yellow>$<server.flag[bd.balance].if_null[0].format_number>" players:<[value]>

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
