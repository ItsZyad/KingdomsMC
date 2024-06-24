##ignorewarning bad_quotes
##ignorewarning invalid_data_line_quotes

KChat_Config:
    type: data
    chatProximityThreshold: 30


ChatCallStack:
    type: task
    debug: false
    definitions: fullText|text|player
    script:
    # Found in: Chat-Functions/Misc.dsc
    - run Amogus def:<[text]> save:emotes
    - define text <entry[emotes].created_queue.determination.get[1]>
    - run AmogusMode def:<[text]>|<[player]> save:giggity
    - define text <entry[giggity].created_queue.determination.get[1]>

    # - narrate format:debug "Queue: <queue.id.color[aqua]> ran in: <queue.time_ran.in_milliseconds.color[aqua]>ms"

    - run KingdomsChat_Handler def:<player>|<[text]>


ChatCallStack_Handler:
    type: world
    debug: false
    events:
        on player chats priority:2:
        - define fullText <context.full_text>
        - define text <context.message>

        # - narrate format:debug "Queue: <queue.id.color[aqua]> ran in: <queue.time_ran.in_milliseconds.color[aqua]>ms"

        - determine passively cancelled
        - run ChatCallStack def:<[fullText]>|<[text]>|<player>

        on player quits:
        - flag player ChatMode:global


LocalChat_Command:
    type: command
    debug: false
    name: chat
    usage: /chat
    description: "Switches the player's chat configuration"
    tab completions:
        1: kingdom|proximity|global|help
        2: Optional[Message]

    script:
    - if "<script.data_key[tab completions].exclude[help].get[1].contains_any[<context.args.get[1]>].not>":
        - narrate format:callout "This is not a valid chat mode"
        - determine cancelled

    - if <context.args.size> == 1:
        - flag <player> ChatMode:<context.args.get[1]>
        - narrate format:callout "Set <player.name>'s chat mode to: <aqua><context.args.get[1]>"

    - else:
        - define prevChatMode <player.flag[ChatMode]>
        - flag <player> ChatMode:<context.args.get[1]>

        - define message <context.raw_args.split[<&sp>].remove[1].space_separated>
        - run ChatCallStack def.text:<[message]> def.player:<player>

        - flag <player> ChatMode:<[prevChatMode]>


KingdomsChat_Handler:
    type: task
    debug: false
    definitions: player|message
    script:
        - define opPrefix ""
        - if <[player].is_op>:
            - define opPrefix <red>[OP]

        - else if <[player].groups[<[player].location.world>].exclude[Default].size> != 0:
            - define group <[player].groups[<[player].location.world>].get[1]>
            - define groupPrefix <server.group_prefix[<[group]>].world[<[player].world>]>
            - define opPrefix <blue>[<[group].to_uppercase>] if:<[groupPrefix].equals[&e].not>

        ## IDEA: Muting a player can be done by setting their ChatMode to null

        - if <[player].flag[ChatMode]> == global || !<[player].has_flag[ChatMode]>:
            - narrate targets:<server.online_players> "<[opPrefix]><yellow>[Global] <gray><[player].name> <white><&gt><&gt> <[message]>"

        - else if <[player].flag[ChatMode]> == kingdom:
            - define kingdom <[player].flag[kingdom]>
            - define kingdomRealName <proc[GetKingdomName].context[<[kingdom]>]>
            - define kingdomMembers <server.flag[kingdoms.<[player].flag[kingdom]>.members]>
            - define kingdomOps <server.online_ops.filter_tag[<[filter_value].flag[kingdom].equals[<[kingdom]>]>]>
            - define applicableOps <server.online_ops.exclude[<[kingdomOps]>]>

            - narrate targets:<[applicableOps]> "<[opPrefix]><red>[SocSpy]<aqua>[<[kingdomRealName]> Kingdom] <gray><[player].name> <white><&gt><&gt> <&r><[message]>"
            - narrate targets:<[kingdomMembers].include[<[kingdomOps]>]> "<[opPrefix]><aqua>[Kingdom] <gray><[player].name> <white><&gt><&gt> <[message]>"

        - else if <[player].flag[ChatMode]> == proximity:
            - define nearThreshold <script[KChat_Config].data_key[chatProximityThreshold]>
            - define nearPlayers <[player].location.find_entities[player].within[<[nearThreshold]>]>

            - narrate targets:<[nearPlayers]> "<[opPrefix]><light_purple>[Proximity] <gray><[player].name> <white><&gt><&gt> <[message]>"

        # - narrate format:debug "Queue: <queue.id.color[aqua]> ran in: <queue.time_ran.in_milliseconds.color[aqua]>ms"


FakeChat_Command:
    type: command
    debug: false
    name: fakechat
    usage: /fakechat [player] [chat]
    permission: kingdoms.admin
    description: slander
    tab completions:
        1: <server.online_players>
        2: [chat]

    script:
    - define target <context.raw_args.split_args.get[1]>
    - define message <context.raw_args.split_args.get[2].to[last].space_separated>
    - define opPrefix ""

    - if <[target].is_player>:
        - if <[target].is_op>:
            - define opPrefix <red>[OP]

        - else if <[target].groups[<[target].location.world>].exclude[Default].size> != 0:
            - define group <[target].groups[<[target].location.world>].get[1]>
            - define groupPrefix <server.group_prefix[<[group]>].world[<[target].world>]>
            - define opPrefix <blue>[<[group].to_uppercase>] if:<[groupPrefix].equals[&e].not>

    - narrate targets:<server.online_players> "<[opPrefix]><yellow>[Global] <gray><[target]> <white><&gt><&gt> <&r><[message]>"