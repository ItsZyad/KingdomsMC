Amogus:
    type: task
    debug: false
    definitions: text
    script:
    - if <[text].contains[<&co>amogus<&co>]>:
        - determine <[text].replace_text[<&co>amogus<&co>].with[ඞ]>

    - determine <[text]>


AmogusToggler:
    type: command
    debug: false
    name: amogus
    usage: /amogus
    description: ඞ
    script:
    - if <player.has_flag[amogus]>:
        - flag <player> amogus:!
        - narrate format:callout "You will no longer ඞ :("
    - else:
        - flag <player> amogus
        - narrate format:callout "You will now ඞ <&gt>:)"


AmogusMode:
    type: task
    debug: false
    definitions: text|player
    script:
    - if <[player].has_flag[amogus]>:
        - if <[text].contains[a]>:
            # Thank Alex, I guess...
            - determine <[text].replace_text[a].with[ඞ].replace_text[A].with[ඞ]>

    - determine <[text]>


MuteHandler:
    type: world
    debug: false
    events:
        on player chats server_flagged:BlanketMute:
        - if !<player.has_permission[kingdoms.admin]>:
            - determine cancelled
