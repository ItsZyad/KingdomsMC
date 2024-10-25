##
## All scripts related to managing kingdom upkeep.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Sep 2021
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

KingdomUpkeepHandler:
    type: world
    events:
        on system time hourly every:48:
        - if <server.has_flag[PauseUpkeep]>:
            - stop

        - define kingdomList <proc[GetKingdomList]>

        - foreach <[kingdomList]> as:kingdom:
            - run SubBalance def.kingdom:<[kingdom]> def.amount:<[kingdom].proc[GetUpkeep]>
            - run SubBalance def.kingdom:<[kingdom]> def.amount:<server.flag[kingdoms.<[kingdom]>.outposts.totalUpkeep]>

            - if <[kingdom].proc[GetBalance].is[LESS].than[0]>:
                - define days <server.flag[indebtedKingdoms].get[<[kingdom]>].add[1].if_null[1]>
                - flag server indebtedKingdoms.<[kingdom]>:<[days]>

        - narrate targets:<server.online_players> format:callout "Daily upkeep has been collected from all Kingdom banks."

        - ~run SidebarLoader def.target:<server.online_players>


NegativeBalanceAlert:
    type: world
    debug: false
    events:
        on player joins:
        - wait 10t
        - define kingdom <player.flag[kingdom]>

        - if <[kingdom].proc[GetBalance].is[LESS].than[0]>:
            - define plural days!

            - if <server.flag[indebtedKingdoms].get[<player.flag[kingdom]>]> == 1:
                - define plural day.

            - narrate format:callout "<bold>Alert!<&6> Your kingdom has been in debt for <red><server.flag[indebtedKingdoms].get[<player.flag[kingdom]>]><&6> <[plural]>"