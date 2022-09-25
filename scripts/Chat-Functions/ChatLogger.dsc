SaveLogs_Command:
    type: command
    usage: /savelogs
    name: savelogs
    description: Tells the server to save the log files at the end of the day
    permission: kingdoms.admin
    script:
    - if <context.args.size> != 0:
        - define param <context.args.get[1]>

        - if <[param]> == -p:
            - flag server SaveLogs:Persistent
            - narrate format:admincallout "Logging of chat messages will now be on at all times, or until switched off manually."

        - else if <[param]> == on || <[param]> == -o:
            - flag server SaveLogs
            - narrate format:admincallout "Logging of chat messages will be on for today."

        - else if <[param]> == off || <[param]> == -f:
            - flag server SaveLogs:!
            - narrate format:admincallout "Logging of chat messages will be off until switched on manually."

        - else:
            - narrate format:admincallout "Unrecognized parameter."

    - else:
        - narrate format:admincallout "Missing parameters."

ChatLog:
    type: world
    events:
        on player chats:
        - yaml load:chatlog-latest.yml id:chat

        - define ESTTime <util.time_now.to_zone[UTC-8]>

        - yaml set id:chat file.logs:->:[<[ESTTime].hour>:<[ESTTime].minute>:<[ESTTime].second><&sp>EST]<&sp><player.name><&co><&sp><context.message>

        - yaml id:chat savefile:chatlog-latest.yml
        - yaml id:chat unload

        on system time 11:59:
        - if <server.has_flag[SaveLogs]>:
            - yaml id:chat lode:chatlog-latest.yml
            - yaml create id:dayLog

            - yaml id:chat copykey:file file to_id:dayLog

            - yaml id:dayLog savefile:chatlog-<util.time_now.format[yyyy-mm-dd]>.yml
            - yaml id:chat file:!

            - yaml id:chat savefile:chatlog-latest.yml

            - yaml id:dayLog unload
            - yaml id:chat unload

            - if <server.flag[SaveLogs]> != Persistent:
                - flag server SaveLogs:!

        - else:
            - yaml id:chat lode:chatlog-latest.yml

            - yaml id:chat file:!

            - yaml id:chat savefile:chatlog-latest.yml

            - yaml id:chat unload
