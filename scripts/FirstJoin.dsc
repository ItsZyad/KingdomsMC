##
## * Anytime a pre or post-join action needs to be done to
## * adjust the player experience, it will be in this file
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jul 2021
## @Updated: May 2022
## @Script Ver: N/A
##
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

# Note: future configurable
CustomJoinMessages:
    type: data
    player_list:
        fuzzysloth: "the trident king has returned!"

KingdomSelection_Handler:
    type: world
    debug: false
    events:
        on player joins:
        # Get players out of the pre-migration world
        - if <server.worlds.contains[KingdomsCurrent]> && <player.location.world.name> != KingdomsCurrent:
            - teleport <player> <world[KingdomsCurrent].spawn_location>

        - if !<player.has_flag[kingdom]>:
            - wait 1s

            - narrate "<gold><bold>Sorry to Bother!"
            - narrate "<underline>Welcome to Kingdoms!<underline.end_format> Before you get playing, please just ensure that you have adjusted your video settings so that your GUI size is 2 or 1."
            - narrate "<gray><italic>Minecraft does a poor job of scaling text based on screen resolution and UI size. By adjusting the size of your UI you will avoid a bunch of issues relating to text running off the screen that may occur while playing."
            - narrate <&sp>
            - narrate "<gold><bold>Thank you!"
            - narrate <element[<&sp>].underline.repeat[40]>
            - narrate <&sp>

        - define joinColor <green>
        - if <player.is_op>:
            - define joinColor <red>

        - define joinMsg null
        - foreach <script[CustomJoinMessages].data_key[player_list]>:
            - if <[key]> == <player.name>:
                - define joinMsg <[value]>

        - if <[joinMsg]> == null:
            - random:
                - define joinMsg "has graced us with their presence"
                - define joinMsg "has returned at last!"
                - define joinMsg "has dropped by for some Kingdoms"
                - define joinMsg "has joined the game, hope you brought pizza!"
                - define joinMsg "has joined the game"
                - define joinMsg "has joined the game"
                - define joinMsg "has joined the game"
                - define joinMsg "has joined the game"
                - define joinMsg "has joined the game"

        - determine "<gray>[<[joinColor]>+<gray>]<yellow> <player.name> <white><[joinMsg]>"

        on player quits:
        - define leaveMsg null

        - random:
            - define leaveMsg "has left to finally touch grass"
            - define leaveMsg "has left the game"
            - define leaveMsg "has left the game"
            - define leaveMsg "has left the game"
            - define leaveMsg "has joinedn't the game"

        - determine "<gray>[<red>-<gray>]<yellow> <player.name> <white><[leaveMsg]>"