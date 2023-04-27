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
    - define target <[target].as[list]>

    - foreach <[target]> as:player:
        - if !<[player].sidebar_lines.exists> && !<[changeSBState]>:
            - foreach next

        - if <[player].is_online> && <[player].has_flag[kingdom]>:

            # Initialize and set Balance line
            - define kingdom <[player].flag[kingdom]>
            - define kingdomName <script[KingdomRealNames].data_key[<[kingdom]>]>
            - define kingdomData <server.flag[kingdoms.<[kingdom]>]>
            - define totalOutpostUpkeep <server.flag[<[kingdom]>.outposts.totalUpkeep].if_null[0]>
            - sidebar set "title:<bold> <[kingdomName].color[<script[KingdomTextColors].data_key[<[player].flag[kingdom]>]>]>  " "values:<&r>|<&sp>Balance: <yellow>$<[kingdomData].get[balance].round_down.format_number>" players:<[player]>

            # Set Upkeep Line
            - if !<server.has_flag[PauseUpkeep]>:
                - sidebar add "values:<&sp>Upkeep: <yellow>$<[kingdomData].get[upkeep].add[<[totalOutpostUpkeep].if_null[0]>].round_down.format_number>" players:<[player]>

            - else:
                - sidebar add "values:<&sp>Upkeep: <aqua>Frozen!" players:<[player]>

            - if <server.flag[kingdoms.<[kingdom]>.powerstruggle.influenceBonuses.bonusTax].exists>:
                - sidebar add "values:<&sp>Fyndalin Tax Bonus: <green>$<server.flag[kingdoms.<[kingdom]>.powerstruggle.influenceBonuses.bonusTax].format_number>" players:<[player]>

            # Set Core Claim amount line
            - sidebar add "values:<&sp>Core Claims: <[kingdomData].deep_get[claims.core].size.if_null[0]> / <[kingdomData].deep_get[claims.coreMax]>" players:<[player]>

            # Set Castle Territory line
            - sidebar add "values:<&sp>Castle Claims: <[kingdomData].deep_get[claims.castle].size.if_null[0]> / <[kingdomData].deep_get[claims.castleMax]>" players:<[player]>

            # Set War Status Line
            - sidebar add "values:<&sp>War Status: <[war-<[kingdomData].deep_get[warStatus]>]><[kingdomData].deep_get[warStatus].if_true[At War].if_false[At Peace]>" players:<[player]>

            # Set Outpost Count Line
            - sidebar add "values:<&sp>Outpost Count: <[kingdomData].deep_get[outposts.outpostList].size.if_null[0]>" players:<[player]>

            # Set Prestige Line
            - sidebar add "values:<&sp>Prestige: <[kingdomData].deep_get[prestige]> / 100" players:<[player]>

            # Set Influences Line
            - sidebar add "values:<&sp>Influence Points: <[kingdomData].deep_get[powerstruggle.influencePoints]>" players:<[player]>

            # Separator Line
            - sidebar add values:<element[<&sp>].repeat[30]> players:<[player]>

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

        # - if <[player].in_group[BDagger]> || <[player].is_op>:
        #     - sidebar add values:<underline><element[<&sp>].repeat[40]> players:<[player]>
        #     - sidebar add values:<&sp> players:<[player]>

        #     - sidebar add "values:<&sp><bold><blue>THE BLUE DAGGER" players:<[player]>

        #     - sidebar add "values:<&sp>Balance<&co> <yellow>$<server.flag[bd.balance].if_null[0].format_number>" players:<[player]>

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
        - if <[player].length.is[OR_MORE].than[<[longestLine]>]>:
            - define longestLine <[player].length>

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
