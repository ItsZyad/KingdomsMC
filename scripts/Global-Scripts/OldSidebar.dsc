##
## * Old Sidebar functions (before I knew about dot definitions)
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Apr 2021
## @Script Ver: v1.5
##
## ----------------END HEADER-----------------

##ignorewarning truly_true
##ignorewarning def_of_nothing

SidebarLoader_OLD:
    type: task
    definitions: 1
    script:
    - if <[2].if_null[false]> == false:
        - run SidebarLoader_Individual def:<[1]>

    - else:
        - repeat <server.online_players.size>:
            - run SidebarLoader_Individual def:<[<[value]>]>


SidebarLoader_Individual_OLD:
    type: task
    debug: false
    definitions: target
    script:
    - define war-true <red><bold>
    - define war-false <green>
    - yaml load:kingdoms.yml id:kingdoms
    - yaml load:powerstruggle.yml id:ps

    #- narrate format:debug <[target]>

    - if <[target].has_flag[kingdom]>:
        #- narrate format:debug <[target]>

        # Initialize and set Balance line
        - sidebar set title:<bold><proc[YamlSpaceAdder].context[<proc[KingdomNameReplacer].context[<[target].flag[kingdom]>]>].color[<script[KingdomColors].data_key[<[target].flag[kingdom]>]>]> "values:<&r>|Balance: <yellow>$<proc[CommaAdder].context[<yaml[kingdoms].read[<[target].flag[kingdom]>.balance].round_down>]>" players:<[target]>

        # Set Upkeep Line
        - if !<server.has_flag[PauseUpkeep]>:
            - sidebar add "values:Upkeep: <yellow>$<proc[CommaAdder].context[<yaml[kingdoms].read[<[target].flag[kingdom]>.upkeep].round_down>]>" players:<[target]>

        - else:
            - sidebar add "values:Upkeep: <aqua>Frozen!" players:<[target]>

        # Set Core Claim amount line
        - sidebar add "values:Core Claims: <yaml[kingdoms].read[<[target].flag[kingdom]>.core_claim_amount]> / <yaml[kingdoms].read[<[target].flag[kingdom]>.core_max]>" players:<[target]>

        # Set Castle Territory line
        - sidebar add "values:Castle Claims: <yaml[kingdoms].read[<[target].flag[kingdom]>.castle_territory_amount]> / <yaml[kingdoms].read[<[target].flag[kingdom]>.castle_max]>" players:<[target]>

        # Set War Status Line
        - sidebar add "values:War Status: <definition[war-<yaml[kingdoms].read[<[target].flag[kingdom]>.war_status]>]><yaml[kingdoms].read[<[target].flag[kingdom]>.war_status]>" players:<[target]>

        # Set Outpost Count Line
        - sidebar add "values:Outpost Count: <yaml[kingdoms].read[<[target].flag[kingdom]>.outpost_count]>" players:<[target]>

        # Set Prestige Line
        - sidebar add "values:Prestige: <yaml[kingdoms].read[<[target].flag[kingdom]>.prestige]>" players:<[target]>

        # Set Influences Line
        - sidebar add "values:Influence Points: <yaml[ps].read[<[target].flag[kingdom]>.dailyinfluences]>" players:<[target]>

    - else:
        - sidebar set title:<bold><gray>KINGDOMLESS

        - sidebar add "values:Upkeep: <gray>$####"
        - sidebar add "values:Core Claims: ##/##"
        - sidebar add "values:Castle Claims: ##/##"
        - sidebar add "values:War Status: N/A"
        - sidebar add "values:Outpost Count: ##"
        - sidebar add "values:Prestige: ##"

#- if !<player.has_flag[kingdom]>:
#    - if <player.has_permission[centran]>:
#        - flag player kingdom:centran
#    - if <player.has_permission[cambrian]>:
#        - flag player kingdom:cambrian
#    - if <player.has_permission[raptoran]>:
#        - flag player kingdom:raptoran
#    - if <player.has_permission[viridian]>:
#        - flag player kingdom:viridian

#    - narrate format:callout "If you are seeing this message then this means that your perms have not been set - which can break <&l>a lot <&6>of things later on. Please rejoin the server to rectify this issue!"

    - yaml id:kingdoms unload
    - yaml id:ps unload

    - if <server.has_flag[RestrictedCreative]>:
        - bossbar remove resCre
        - bossbar create resCre title:Restricted<&sp>Creative color:purple

# Problematic idea: you have to refresh these literally every second since player stats can change on the fly unlike kingdom-specific stats

PersonalSidebarLoader_OLD:
    type: task
    debug: true
    definitions: target
    script:
    - foreach <[target]>:
        - if <[value].has_flag[kingdom]>:
            #- yaml id:kingdoms load:kingdoms.yml

            - sidebar set title:<&5><bold>Personal<&sp>Stats

            - sidebar add "values:<&sp>|Balance: <red>$<[value].money.as_money>" players:<[value]>

            #- yaml id:kingdoms unload

