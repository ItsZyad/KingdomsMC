##
## * WARNING: Powerful Subcommand
## * Contains all the code relating to the purgeflags
## * subcommand of the admintools which removes specified
## * from a player, set of players, entity, or server.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jul 2022
## @Script Ver: INDEV
##
## ----------------END HEADER-----------------

PurgeFlags_Subcommand:
    type: task
    definitions: player|flag
    script:
    - if <[player]> == *:
        - define player <server.players>

    - narrate format:debug WIP