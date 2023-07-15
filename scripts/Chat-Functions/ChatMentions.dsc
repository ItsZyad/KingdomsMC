ChatMentions:
    type: world
    debug: false
    events:
        on player chats:
        - if <context.message.contains[@]>:
            - if !<context.message.advanced_matches[@<&sp>]>:
                - define username <context.message.split[@].get[2].split[<&sp>].get[1]>

                - define mentionIndex <context.message.index_of[@<[username]>]>
                - define mentionLength <element[@<[username]>].length>

                - if <[username]> == everyone:
                    - if <player.in_group[Admin]> || <player.is_op>:
                        - playsound <server.online_players.exclude[<player>]> sound:ENTITY_EXPERIENCE_ORB_PICKUP

                        - determine <context.message.substring[0,<[mentionIndex]>]><red>everyone<white><context.message.substring[<[mentionIndex].add[<[mentionLength]>]>,<context.message.length>]>

                - else if <[username].as[player].if_null[false]> != false:
                    - if <player.has_flag[mentionCooldown]>:
                        - narrate format:callout "You must wait <red><player.flag_expiration[mentionCooldown].from_now.formatted> <&6>before you can do this again!"
                        - determine cancelled

                    - else:
                        - define targetPlayer <[username].as[player]>

                        - playsound <[targetPlayer]> sound:ENTITY_EXPERIENCE_ORB_PICKUP

                        - flag <player> mentionCooldown expire:30s

                        - determine <context.message.substring[0,<[mentionIndex]>]><red><[targetPlayer].nameplate><white><context.message.substring[<[mentionIndex].add[<[mentionLength]>]>,<context.message.length>]>
