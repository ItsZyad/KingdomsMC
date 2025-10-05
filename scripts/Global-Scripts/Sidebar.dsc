##
## Sidebar function capable of refreshing/setting/removing the sidebar for targetted players.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Dec 2021
## @Update 1: Jul 2024
## **** Note: This update moved all of the heavy lifting of the sidebars out of the actual task
## ****       script itself and into a data script containing all the lines of the different
## ****       sidebar modes. This will likely act as a very high-functional stopgap until I figure
## ****       out how to replicating the scrolling sidebar plugin.
##
## @Script Ver: v2.0
##
## ------------------------------------------END HEADER-------------------------------------------

# So far this is the closest thing I will have to a dedicated script that sets people's kingdom flag
SetInitialSidebar:
    type: world
    debug: false
    events:
        on player joins:
        - if !<player.has_flag[sidebar.mode]>:
            - flag <player> sidebar.mode:Default

        - if <player.proc[IsPlayerKingdomLess]>:
            - stop

        - ~run SidebarLoader def.target:<list[<player>]>


GenerateUpkeepSidebarLine:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Helper proc which returns either the default upkeep line for the sidebar or 'Frozen!' depending on if PauseUpkeep is set.
    - ---
    - → [ElementTag(String)]

    script:
    ## Helper proc which returns either the default upkeep line for the sidebar or 'Frozen!'
    ## depending on if PauseUpkeep is set.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - define totalOutpostUpkeep <[kingdom].proc[GetTotalOutpostUpkeep]>

    - if !<server.has_flag[PauseUpkeep]>:
        - determine <element[Upkeep: <yellow>$<[kingdom].proc[GetUpkeep].add[<[totalOutpostUpkeep].if_null[0]>].round_down.format_number> <element[/ IRL Day].color[<proc[GetKingdomColor].context[<[kingdom]>]>]>]>

    - determine <element[Upkeep: <aqua>Frozen!]>


GeneratePrestigeDegSidebarLine:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Helper proc which returns either the prestige degredation line for the default sidebar.
    - ---
    - → [ElementTag(String)]

    script:
    ## Helper proc which returns either the prestige degredation line for the default sidebar.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - define prestigeScales <proc[GetPrestigeDegradation]>

    - if <[prestigeScales].get[<[kingdom]>]> >= 0:
        - determine <element[Prestige Gain: <element[+<[prestigeScales].get[<[kingdom]>]>].color[green]>]>

    - determine <element[Prestige Decay: <element[<[prestigeScales].get[<[kingdom]>]>].color[red]>]>


SidebarLine_Data:
    type: data
    SidebarModes:
        Default:
            title: <element[   <[kingdomName].proc[ConvertToSkinnyLetters].color[<[kingdom].proc[GetKingdomColor]>].bold>  ]>
            lines:
            - <element[Balance: <yellow>$<[kingdom].proc[GetBalance].round_down.format_number>]>
            - <proc[GenerateUpkeepSidebarLine].context[<[kingdom]>]>
            - <element[Core Claims: <proc[GetClaims].context[<[kingdom]>|core].size.if_null[0]> / <proc[GetMaxClaims].context[<[kingdom]>|core]>]>
            - <element[Castle Claims: <proc[GetClaims].context[<[kingdom]>|castle].size.if_null[0]> / <proc[GetMaxClaims].context[<[kingdom]>|castle]>]>
            - <element[War Status: <[kingdom].proc[GetKingdomWarStatus].if_true[At War].if_false[At Peace].color[<[warStatusColors].get[<[kingdom].proc[GetKingdomWarStatus]>]>]>]>
            - <element[Prestige: <[kingdom].proc[GetPrestige].round_to_precision[0.025]> / 100]>
            - <proc[GeneratePrestigeDegSidebarLine].context[<[kingdom]>]>
            - <element[Outpost Count: <[kingdom].proc[GetOutposts].size.if_null[0]>]>
            - <element[Duchy Count: <[kingdom].proc[GetKingdomDuchies].size.if_null[0]>]>
            - <element[King: <[kingdom].proc[GetKing].name.if_null[None].color[<[kingdom].proc[GetKingdomColor]>]>]>

        Duchy:
            title: <element[   <[duchy].proc[ConvertToSkinnyLetters].bold.color[aqua]>   ]>
            lines:
            - <element[Duke: <green><[kingdom].proc[GetDuke].context[<[duchy]>].name>]>
            - <element[Balance: <yellow>$<[kingdom].proc[GetDuchyBalance].context[<[duchy]>].round_to_precision[0.01].format_number>]>
            - <element[Tax Rate: <yellow><[kingdom].proc[GetDuchyTaxRate].context[<[duchy]>].mul[100].round_to_precision[0.01].format_number>% / week]>

        Scenario-1:
            title: <element[<blue><bold>   Scenario 1   ]>
            lines:
            - <proc[SC1_GenerateTradeEffSidebarLine].context[<[kingdom]>]>
            - <element[<&sp>]>
            - <element[Alliance Influences<&co>].bold.color[aqua]>
            - <element[AT-Rumek<&co> ]><server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.markets.Alliance-Town-1].if_null[0].mul[100].round_to_precision[0.01]><&pc>
            - <element[AT-Kandon<&co> ]><server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.markets.Alliance-Town-2].if_null[0].mul[100].round_to_precision[0.01]><&pc>
            - <element[AT-Rugoss<&co> ]><server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.markets.Alliance-Town-3].if_null[0].mul[100].round_to_precision[0.01]><&pc>
            - <element[AT-Bremlek<&co> ]><server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.markets.Alliance-Town-4].if_null[0].mul[100].round_to_precision[0.01]><&pc>


SidebarLoader:
    type: task
    debug: false
    definitions: target[ListTag(PlayerTag)]|overrideHiddenSidebar[?ElementTag(Boolean) = true]
    description:
    - Sets the Kingdoms sidebar for a player or list of players, drawing on all the relevant information pertaining to their kingdom.
    - If a player has set their sidebar to 'hide', overrideHiddenSidebar can be set to false and their sidebar update will be skipped.
    - ---
    - → [Void]

    script:
    ## Sets the Kingdoms sidebar for a player or list of players, drawing on all the relevant
    ## information pertaining to their kingdom.
    ##
    ## If a player has set their sidebar to 'hide', overrideHiddenSidebar can be set to false and
    ## their sidebar update will be skipped.
    ##
    ## target                :  [ListTag(PlayerTag)]
    ## overrideHiddenSidebar : ?[ElementTag(Boolean)]
    ##
    ## >>> [Void]

    - definemap warStatusColors:
        true: <red>
        false: <green>

    - define overrideHiddenSidebar <[overrideHiddenSidebar].if_null[true]>

    - if <[target].object_type> == List && <[target].get[1].object_type> == Player:
        - define target <[target].deduplicate.filter_tag[<[filter_value].is_online>]>

    - else if <[target].object_type> == Player:
        - define target <list[<[target]>].deduplicate.filter_tag[<[filter_value].is_online>]>

    - else:
        - run GenerateInternalError def.category:TypeError def.message:<element[Invalid argument passed to <script.name.color[aqua]>. Target must either be a player or list of players.]>
        - stop

    - foreach <[target]> as:player:
        - if <player.proc[IsPlayerKingdomLess]>:
            - run GenerateKingdomsDebug def.message:<element[Attempted to set player: <[target].color[red]><&sq>s sidebar, however player is not a part of a kingdom. Skipping...]>
            - foreach next

        - if !<[player].sidebar_lines.exists> && !<[overrideHiddenSidebar]>:
            - foreach next

        - if <[player].has_flag[sidebar.hide]>:
            - foreach next

        - if !<[player].is_online>:
            - foreach next

        - if <[player].has_flag[kingdom]>:
            - define kingdom <[player].flag[kingdom]>
            - define kingdomName <proc[GetKingdomName].context[<[kingdom]>]>
            - define sidebarMode <[player].flag[sidebar.mode]>

            - if <[sidebarMode]> == Duchy:
                - if <[player].proc[IsPlayerDuke]>:
                    - define duchy <[player].proc[GetPlayerDuchy]>

                - else:
                    - define sidebarMode Default

            - define sidebarData <script[SidebarLine_Data].data_key[SidebarModes.<[sidebarMode]>]>

            - sidebar remove players:<[player]>
            - sidebar set title:<[sidebarData].get[title].parsed> players:<[player]>
            - sidebar add values:<element[<&sp>].repeat[30]> players:<[player]> start:99

            - foreach <[sidebarData].get[lines]> as:line:
                - sidebar add values:<&sp><[line].parsed> players:<[player]>

            - sidebar add values:<&sp> players:<[player]>

        - else:
            - sidebar set title:<bold><gray>KINGDOMLESS

            - sidebar add values:<&sp> start:99
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
    debug: false
    description: command for managing the Kingdoms sidebar
    usage: /sidebar
    name: sidebar
    tab completions:
        1: hide|show|mode

    tab complete:
    - define args <context.raw_args.to_lowercase.split_args>

    - if <[args].get[1]> == mode:
        - determine <script[SidebarLine_Data].data_key[SidebarModes].keys>

    script:
    - define args <context.raw_args.to_lowercase.split_args>

    - if <[args].is_empty>:
        - if !<player.has_flag[sidebar.hide]>:
            - flag <player> sidebar.hide
            - sidebar remove

        - else:
            - flag <player> sidebar.hide:!
            - ~run SidebarLoader def.target:<player> def.overrideHiddenSidebar:true

        - stop

    - if <[args].get[1]> == hide:
        - flag <player> sidebar.hide
        - sidebar remove

    - else if <[args].get[1]> == show:
        - flag <player> sidebar.hide:!
        - ~run SidebarLoader def.target:<player> def.overrideHiddenSidebar:true

    - else if <[args].get[1]> == mode:
        - define mode <[args].get[2].to_titlecase.if_null[null]>

        - if <[mode].is_truthy>:
            - flag <player> sidebar.mode:<[mode]>
            - execute as_player "sidebar show"
