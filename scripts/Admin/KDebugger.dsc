##
## * Contains all the scripts relating to KDebugger - A VSCODE-style
## * debugger designed for speeding up the development process of
## * Kingdoms.
##
## * Can be used on any Denizen script.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Sep 05 2022
## @Status: INDEV
## @Version: v0.1
## ---------------------------END HEADER----------------------------

## DEBUGGER MUST BE INJECTED!
## Running this script regularly may appear to make it work regularly
## however, WILL have unforseen side-effects.

Debugger:
    type: task
    debug: false
    script:
    - if <queue.player.exists>:
        - if <player.is_op> || <player.has_permission[kingdoms.admin]>:
            - narrate format:debug <queue.script.original_name>

            - narrate "<element[                                  ].strikethrough>"

            - flag <player> adminTools.debugMode:<queue>
            - define breakpointCount <[breakpointCount].add[1].if_null[1]>

            - clickable until:30m usages:1 for:<player> save:playerContext:
                - narrate format:debug WIP

            - narrate "<gold><italic>Breakpoint #<[breakpointCount]>"
            - run FlagVisualizer def.flag:<queue.definition_map.exclude[breakpointCount]> def.flagName:<queue.script.name.bold><&sp>defs
            - narrate <n>
            - narrate "<element[Player Context].color[aqua]>:<element[Click here].underline.on_hover[Player context map].on_click[]>"

            - define breakpoints <[breakpoints].if_null[activated]>

            - if <[breakpoints]> == activated:
                - clickable until:30m usages:1 for:<player> save:debugContinue:
                    - flag <player> adminTools.debugMode:!

                - narrate <n>
                - narrate "<element[Continue script execution].underline.on_click[<entry[debugContinue].command>]>"

                - define beforeWaitTime <util.time_now.epoch_millis>

                - waituntil <player.has_flag[adminTools.debugMode].not.or[<player.is_online.not>]>

                - define afterWaitTime <util.time_now.epoch_millis>
                - define waitTime <[afterWaitTime].sub[<[beforeWaitTime]>]>
                - define afterWaitTime:!
                - define beforeWaitTime:!

            - narrate "Ran queue: <queue.id.color[gray].italicize> in: <queue.time_ran.in_milliseconds.sub[<[waitTime]>].abs.round_to_precision[0.1].color[red]><red>ms"
            - narrate "<element[                                  ].strikethrough>"

    - else:
        - narrate format:admincallout "Queue at breakpoint in script:<queue.script.name.color[red]> does not have attached player!"

DebugMode_Handler:
    type: world
    events:
        on player quits:
        - if <player.has_flag[adminTools.debugMode]>:
            - queue <player.flag[adminTools.debugMode]> clear
            - flag <player> adminTools.debugMode:!

        # Requires Denizen build 1773.
        # fuck.
        on scripts loaded:
        - narrate test targets:<server.online_ops>

TestScript_KDebug:
    type: task
    script:
    - define someNumber 4
    - define someEquation <[someNumber].log[10].mul[0.5]>

    - run TestScript2_KDebug def.eq:<[someEquation]>

TestScript2_KDebug:
    type: task
    definitions: eq
    script:
    - define someBoolean <[eq].is[MORE].than[2]>
    # a comment
    - inject Debugger

    - narrate format:debug "Script complete!"