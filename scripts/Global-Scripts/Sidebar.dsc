##
## Sidebar function capable of refreshing/setting/removing the sidebar for targetted players.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Dec 2021
## @Script Ver: v1.1
##
##ignorewarning invalid_data_line_quotes
## ------------------------------------------END HEADER-------------------------------------------

# So far this is the closest thing I will have to a dedicated script that sets people's kingdom flag
SetInitialSidebar:
    type: world
    debug: false
    events:
        on player joins:
        - ~run SidebarLoader def:<player>

        - if !<player.has_flag[kingdom]>:
            - narrate format:callout "<yellow><bold>WARNING: <&r>Player kingdom flag not set! Using kingdom functions may have unexpected/untested side-effects"


SidebarLoader:
    type: task
    debug: false
    definitions: target[ListTag(PlayerTag)]|changeSBState[?ElementTag(Boolean) = true]
    description:
    - Sets the Kingdoms sidebar for a player or list of players, drawing on all the relevant information pertaining to their kingdom.
    - If a player has set their sidebar to 'hide', changeSBState can be set to false and their sidebar update will be skipped.
    - ---
    - → [Void]

    script:
    ## Sets the Kingdoms sidebar for a player or list of players, drawing on all the relevant
    ## information pertaining to their kingdom.
    ##
    ## If a player has set their sidebar to 'hide', changeSBState can be set to false and their
    ## sidebar update will be skipped.
    ##
    ## target        :  [ListTag(PlayerTag)]
    ## changeSBState : ?[ElementTag(Boolean)]
    ##
    ## >>> [Void]

    - definemap warStatusColors:
        true: <red><bold>
        false: <green>

    - define changeSBState <[changeSBState].if_null[true]>
    - define target <[target].as[list].deduplicate.filter_tag[<[filter_value].is_online>]>

    - foreach <[target]> as:player:
        - if !<[player].sidebar_lines.exists> && !<[changeSBState]>:
            - foreach next

        - if <[player].has_flag[hideSidebar]>:
            - foreach next

        - if <[player].is_online> && <[player].has_flag[kingdom]>:

            # Initialize and set Balance line
            - define kingdom <[player].flag[kingdom]>
            - define kingdomName <proc[GetKingdomName].context[<[kingdom]>]>

            - sidebar remove players:<[player]>

            # TODO: fix this as a part of the upkeep rework.
            - define totalOutpostUpkeep <server.flag[<[kingdom]>.outposts.totalUpkeep].if_null[0]>
            - sidebar set "title:<bold> <[kingdomName].proc[ConvertToSkinnyLetters].color[<[kingdom].proc[GetKingdomColor]>]>  " players:<[player]>

            - sidebar add "values:<&r>|<&sp>Balance: <yellow>$<[kingdom].proc[GetBalance].round_down.format_number>" players:<[player]>

            # Set Upkeep Line
            - if !<server.has_flag[PauseUpkeep]>:
                - sidebar add "values:<&sp>Upkeep: <yellow>$<[kingdom].proc[GetUpkeep].add[<[totalOutpostUpkeep].if_null[0]>].round_down.format_number>" players:<[player]>

            - else:
                - sidebar add "values:<&sp>Upkeep: <aqua>Frozen!" players:<[player]>

            - if <server.flag[kingdoms.<[kingdom]>.powerstruggle.influenceBonuses.bonusTax].exists>:
                - sidebar add "values:<&sp>Fyndalin Tax Bonus: <green>$<server.flag[kingdoms.<[kingdom]>.powerstruggle.influenceBonuses.bonusTax].format_number>" players:<[player]>

            # Set Core Claim amount line
            - sidebar add "values:<&sp>Core Claims: <proc[GetClaims].context[<[kingdom]>|core].size.if_null[0]> / <proc[GetMaxClaims].context[<[kingdom]>|core]>" players:<[player]>

            # Set Castle Territory line
            - sidebar add "values:<&sp>Castle Claims: <proc[GetClaims].context[<[kingdom]>|castle].size.if_null[0]> / <proc[GetMaxClaims].context[<[kingdom]>|castle]>" players:<[player]>

            # Set War Status Line
            - sidebar add "values:<&sp>War Status: <[kingdom].proc[GetKingdomWarStatus].if_true[At War].if_false[At Peace].color[<[warStatusColors].get[<[kingdom].proc[GetKingdomWarStatus]>]>]>" players:<[player]>

            # Set Outpost Count Line
            - sidebar add "values:<&sp>Outpost Count: <[kingdom].proc[GetOutposts].size.if_null[0]>" players:<[player]>

            # Set Prestige Line
            - sidebar add "values:<&sp>Prestige: <[kingdom].proc[GetPrestige].round_to_precision[0.025]> / 100" players:<[player]>

            # Set Prestige Degradation Line
            - ~run GetPrestigeDegradation save:prestigeScales
            - define prestigeScales <entry[prestigeScales].created_queue.determination.get[1]>

            - if <[prestigeScales].get[<[kingdom]>]> >= 0:
                - sidebar add "values:<&sp>Prestige Gain: <element[+<[prestigeScales].get[<[kingdom]>]>].color[green]>"

            - else:
                - sidebar add "values:<&sp>Prestige Decay: <element[<[prestigeScales].get[<[kingdom]>]>].color[red]>"

            # Separator Line
            - sidebar add values:<element[<&sp>].repeat[30]> players:<[player]>

            - define tradeEff <[kingdom].proc[GetKingdomTradeEfficiency].round_to_precision[0.001]>

            - if <[tradeEff]> >= 0:
                - sidebar add "values:<&sp>Trade Efficiency: <green>+<[tradeEff]>%"

            - else:
                - sidebar add "value:<&sp>Trade Efficiency: <red><[tradeEff]>%"

            # Separator Line
            - sidebar add values:<element[<&sp>].repeat[30]> players:<[player]>

        - else:
            - sidebar set title:<bold><gray>KINGDOMLESS

            - sidebar add values:<&sp>
            - sidebar add "values:Balance: <gray>$####"
            - sidebar add "values:Upkeep: <gray>$####"
            - sidebar add "values:Core Claims: ##/##"
            - sidebar add "values:Castle Claims: ##/##"
            - sidebar add "values:War Status: N/A"
            - sidebar add "values:Outpost Count: ##"
            - sidebar add "values:Prestige: ##"
            - sidebar add values:<&sp>


ToggleSidebar_Command:
    type: command
    description: "command for managing the Kingdoms sidebar"
    usage: /sidebar
    name: sidebar
    tab completions:
        1: hide|show

    script:
    - if <context.raw_args> == hide:
        - flag <player> hideSidebar
        - sidebar remove

    - else if <context.raw_args> == show:
        - flag <player> hideSidebar:!
        - sidebar remove
        - ~run SidebarLoader def:<player>|true
