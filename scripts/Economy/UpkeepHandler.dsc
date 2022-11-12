##
## * All scripts related to managing kingdom
## * upkeep
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Sep 2021
## @Script Ver: v0.2
## @ Clean Code Classification: 3
##
## ----------------END HEADER-----------------

KingdomUpkeepHandler:
    type: world
    events:
        on system time hourly every:48:
        - if !<server.has_flag[RestrictedCreative]>:
            - if !<server.has_flag[PauseUpkeep]>:
                - yaml load:kingdoms.yml id:kingdoms
                - define kingdomList <proc[GetKingdomList].context[<yaml[kingdoms].parsed_key[]>]>

                - yaml load:outposts.yml id:outposts

                - foreach <[kingdomList]>:
                    - yaml id:kingdoms set <[value]>.balance:-:<yaml[kingdoms].read[<[value]>.upkeep]>
                    - yaml id:kingdoms set <[value]>.balance:-:<yaml[outposts].read[<[value]>.totalupkeep]>

                    - if <server.flag[<[value]>].deep_get[influenceBonuses.bonusTax].exists>:
                        - yaml id:kingdoms set <[value]>.balance:+:<server.flag[<[value]>].deep_get[influenceBonuses.bonusTax]>

                    - if <yaml[kingdoms].read[<[value]>.balance].is[LESS].than[0]>:
                        - define days <server.flag[indebtedKingdoms].get[<[value]>].add[1].if_null[1]>
                        - narrate format:debug <[days]>

                        - flag server indebtedKingdoms.<[value]>:<[days]>

                - narrate targets:<server.online_players> format:callout "Daily upkeep has been collected from all Kingdom banks."

                - yaml id:kingdoms savefile:kingdoms.yml
                - yaml id:kingdoms unload
                - yaml id:outposts unload

                - run SidebarLoader def.target:<server.online_players>

IsKingdomBankrupt:
    type: procedure
    definitions: KingdomBalance|kingdom
    script:
    - if <[KingdomBalance].is[LESS].than[0]>:
        - if <server.flag[indebtedKingdoms].get[<[kingdom]>].is[OR_MORE].than[4]>:
            - determine true

    - determine false

NegativeBalanceAlert:
    type: world
    events:
        on player joins:
        - wait 10t
        - yaml load:kingdoms.yml id:kingdoms
        - define kingdom <player.flag[kingdom]>

        - if <yaml[kingdoms].read[<[kingdom]>.balance].is[LESS].than[0]>:
            - define plural days!
            - if <server.flag[indebtedKingdoms].get[<player.flag[kingdom]>]> == 1:
                - define plural day.

            - narrate format:callout "<bold>Alert!<&6> Your kingdom has been in debt for <red><server.flag[indebtedKingdoms].get[<player.flag[kingdom]>]><&6> <[plural]>"

        - yaml id:kingdoms unload