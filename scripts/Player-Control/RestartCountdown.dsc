RestartCountdown:
    type: command
    name: restartin
    usage: /restartin
    description: sets a timer for server restart (in seconds)
    permission: kingdoms.admin
    script:
    - if <context.args.size> != 0:
        - define time <context.args.get[1]>

        - if <[time].is[OR_LESS].than[3600]>:
            - narrate targets:<server.online_players> format:callout "Attention Players! Server restart will be commencing in: <red><[time].as[duration].formatted>"
            - flag server RestartTimer:<[time]>

        - else:
            - narrate format:admincallout "Cannot set a restart timer longer than 1 hour!"

RestartCounter:
    type: world
    debug: false
    events:
        on system time secondly every:1:
        - if <server.has_flag[RestartTimer]>:
            - if <server.flag[RestartTimer]> != 0:
                - flag server RestartTimer:-:1

            - else:
                - flag server RestartTimer:!
                - kick <server.online_players.exclude[<server.online_ops>]> "reason:Server restart commenced by admin! Please check back in a couple minutes, Thank you!"