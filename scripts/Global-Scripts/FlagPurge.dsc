############################################################################
## THESE COMMANDS WILL ONLY BE AVAILABLE TO THOSE WHO HAVE OP PRIVELLAGES ##
############################################################################

FlagPurge_Command:
    type: command
    name: flagpurge
    usage: /flagpurge
    description: Wipes every flag with the specified name off the server (WARNING: VERY POWERFUL COMMAND)
    script:
    - if <context.raw_args> == yes && !<player.has_flag[flagPurgeConfirm]>:
        - flag player flagPurgeConfirm

    - if <player.is_op>:
        - if <player.has_flag[flagPurgeConfirm]>:
            - if <context.args.get[1]> == kingdom:
                - narrate esplode

        - else:
            - narrate format:admincallout "<red>This command is very powerful and should only be used in very specific circumstances. Are you sure you wish to purge flags? (/flagpurge yes or no)"
