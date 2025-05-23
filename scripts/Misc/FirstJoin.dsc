##
## Anytime a pre or post-join action needs to be done to adjust the player experience, it will be
## in this file.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jul 2021
## @Update 1: May 2022
## @Update 2: May 2024
## @Script Ver: v1.1
##
##ignorewarning invalid_data_line_quotes
## ------------------------------------------END HEADER-------------------------------------------

KingdomSelection_Handler:
    type: world
    debug: false
    events:
        on player joins:
        - if !<player.is_in[<server.players>]> || <player.has_flag[testingKSH]>:
            - wait 1s

            - narrate <element[<&sp>].underline.repeat[40]><n>
            - narrate "<gold><bold>Sorry to Bother!<n>"
            - narrate "Before you get playing, please just ensure that you have adjusted your video settings so that your GUI size is 2 or 1."
            - narrate <element[Minecraft does a poor job of scaling text based on screen resolution and UI size. By adjusting the size of your UI you will avoid a bunch of issues relating to text running off the screen that may occur while playing.].italicize.color[<element[Vintage.light_red].proc[GetColor]>]>
            - narrate <&sp>
            - narrate "<gold><bold>Thank you!"
            - narrate <element[<&sp>].underline.repeat[40]>
            - narrate <&sp>

        - define joinColor <green>
        - if <player.is_op>:
            - define joinColor <red>

        - define joinMsg null
        - foreach <proc[GetConfigNode].context[Flavor.custom-player-messages].if_null[<map[]>]>:
            - if <[key]> == <player.name>:
                - define joinMsg <[value]>

        - if <[joinMsg]> == null:
            - random:
                - define joinMsg "has graced us with their presence"
                - define joinMsg "has returned at last!"
                - define joinMsg "has dropped by for some Kingdoms"
                - define joinMsg "has joined the game, hope you brought pizza!"
                - define joinMsg "has just landed!"
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