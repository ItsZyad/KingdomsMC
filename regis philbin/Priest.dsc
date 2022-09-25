PriestQuest:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true
    interact scripts:
    - PriestQuest_I

PriestQuest_I:
    type: interact
    steps:
        1:
            click trigger:
                script:
                - if <player.has_flag[DoingQuest]>:
                    - if <player.inventory.contains[book].quantity[3]>:
                        - take item:book quantity:3
                        - give player i@diamond
                        - narrate format:cchat "Thank you so much!"
                        # Uncomment when game starts
                        #- flag player DoneFirstTime
                        - flag player DoingQuest:!
                        - stop
                    - else:
                        - narrate "[You are already doing a quest at this time. Please finish that before starting a new one!]"
                        - stop

                - if !<player.has_flag[DoneFirstTime]>:
                    - flag player DoingQuest
                    - narrate format:cchat "Why hello there!"
                    - wait 10t
                    - narrate format:cchat "Can you do me a favor?"
                    - wait 10t
                    - narrate format:cchat "I am just completely out of parchment, and I need some before mass next week!"
                    - wait 5t
                    - narrate format:cchat "Can you, by any chance, help me out please"
                    - narrate "[Type Yes or No]"
                - else:
                    - narrate "[You have already completed that quest]"
                    - stop
            chat trigger:
                1:
                    trigger: "/Yes/ No problem"
                    script:
                    - if !<player.has_flag[DoneFirstTime]>:
                        - random:
                            - narrate format:cchat "Alright, great!"
                            - narrate format:cchat "Thank you so much!"
                            - narrate format:cchat "Thank you!"
                        - narrate "[Get 3 Books to the Priest]"
                    - else:
                        - stop
                2:
                    trigger: "/No/"
                    script:
                    - if <!player.has_flag[DoneFirstTime]>:
                        - random:
                            - narrate format:cchat "Oh alright then..."
                            - narrate format:cchat "Shame..."
                    - else:
                        - stop
