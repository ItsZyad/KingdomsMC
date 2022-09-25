HoboJoe:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        #- trigger name:proximity state:true radius:2

        on click:
        - define hasSeenPlayer <npc.flag[seenPlayers].contains[<player>]>
        - define hasPlayerFT <npc.flag[fastTravelPlayers].contains[<player>]>

        - if <[hasSeenPlayer]>:
            - narrate WIP

        - else:
            - engage
            - chat range:3 "Why hello there stranger!"
            - wait 3s

            - if <player.has_flag[kingdom]>:
                - chat range:3 "I say... You look rather familiar... Do I know ya' from somewhere?"
                - wait 4s

            - else:
                - chat range:3 "Say... You look like you've come from afar, what brings ya to Fyndalin?"

            - disengage