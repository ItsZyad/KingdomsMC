##
## * All scripts related to managing kingdom
## * upkeep
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Sep 2021
## @Script Ver: v0.2
##
## ----------------END HEADER-----------------

KingdomUpkeepHandler:
    type: world
    events:
        on system time hourly every:48:
        - if !<server.has_flag[RestrictedCreative]>:
            - if !<server.has_flag[PauseUpkeep]>:
                - define kingdomList <script[KingdomRealNames].data_key[].keys>

                - foreach <[kingdomList]> as:kingdom:
                    - flag server kingdoms.<[kingdom]>.balance:-:<server.flag[kingdoms.<[kingdom]>.upkeep]>
                    - flag server kingdoms.<[kingdom]>.balance:-:<server.flag[kingdoms.<[kingdom]>.outposts.totalUpkeep]>

                    - if <server.flag[<[kingdom]>].deep_get[influenceBonuses.bonusTax].exists>:
                        - flag server kingdoms.<[kingdom]>.balance:+:<server.flag[<[kingdom]>].deep_get[influenceBonuses.bonusTax]>

                    - if <server.flag[kingdoms.<[kingdom]>.balance].is[LESS].than[0]>:
                        - define days <server.flag[indebtedKingdoms].get[<[kingdom]>].add[1].if_null[1]>
                        - narrate format:debug <[days]>

                        - flag server indebtedKingdoms.<[kingdom]>:<[days]>

                - narrate targets:<server.online_players> format:callout "Daily upkeep has been collected from all Kingdom banks."

                - run SidebarLoader def.target:<server.online_players>


NegativeBalanceAlert:
    type: world
    debug: false
    events:
        on player joins:
        - wait 10t
        - define kingdom <player.flag[kingdom]>

        - if <server.flag[kingdoms.<[kingdom]>.balance].is[LESS].than[0]>:
            - define plural days!

            - if <server.flag[indebtedKingdoms].get[<player.flag[kingdom]>]> == 1:
                - define plural day.

            - narrate format:callout "<bold>Alert!<&6> Your kingdom has been in debt for <red><server.flag[indebtedKingdoms].get[<player.flag[kingdom]>]><&6> <[plural]>"