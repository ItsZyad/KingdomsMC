##
## Implements a warp cooldown of 30 seconds after the point where a player enters combat.
##
## Applies to the /warp and /kingdom warp commands.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Mar 2022
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

WarpCooldownEndMessage:
    type: task
    definitions: player1|player2
    script:
    - narrate targets:<[player1]>|<[player2]> "<red>You are no longer in combat mode!<&6> You can use warps again."


WarpCooldown:
    type: world
    debug: false
    events:
        on player damaged by player:
        - if <context.final_damage> != 0:
            - if !<context.player.has_flag[combatMode]> && !<context.entity.has_flag[combatMode]>:
                - flag <context.entity> combatMode expire:30s
                - flag <context.player> combatMode expire:30s

                - runlater WarpCooldownEndMessage def:<context.entity>|<context.player> delay:30s

                - narrate targets:<context.entity>|<context.player> format:callout "<red>You are in combat mode!<&6> You may not use warps for the next 30 seconds!"

        # Note to self: Should this be converted to a task script and added onto the end of the
        # handler for /kingdom warp and /warp?

        on command:
        # Is the same as return true if the command entered is /warp or /kingdom warp
        - define isWarp <context.command.equals[warp].or[<context.command.equals[kingdom].and[<context.args.get[1].equals[warp]>]>]>

        - if <[isWarp]>:
            - if <player.has_flag[combatMode]>:
                - narrate format:callout "You may not use warps, you are in <red>combat mode!"
                - determine cancelled