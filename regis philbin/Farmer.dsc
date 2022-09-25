FarmerQuest:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true
    interact scripts:
    - FarmerQuest_I

FarmerQuest_I:
    type: interact
    steps:
        1:
            click trigger:
                script:
                - if <player.has_flag[DoingQuest]>:
                    - if <player.inventory.contains[<iron_hoe>].quantity[1]>:
                        - take item:iron_hoe quantity:1
                        - give player i@bread quantity:16
                        - give player i@apple quantity:4
                        - narrate format:cchat "Thank you so much! Here, have some bread and apples for your trouble."
                        # Uncomment when game starts
                        #- flag player DoneFirstTime_F
                        - flag player DoingQuest:!
                        - stop
                    - else:
                        - narrate "[Make sure you meet the requirements for completion of this quest or that you don't have another quest running with /kingdoms quests]"
                        - stop
                    
                - if !<player.has_flag[DoneFirstTime_F]>:
                    - flag player DoingQuest
                    - if <server.has_file[/PlayerData/<player.uuid>]>:
                        - ~yaml load:/PlayerData/<player.uuid> id:<player.uuid>
                    - else:
                        - yaml create id:<player.uuid>
                    
                    - yaml id:<player.uuid> set quests.activequests:->:"Village Farmer Quest"
                    - ~yaml savefile:/PlayerData/<player.uuid> id:<player.uuid>
                    - yaml unload id:<player.uuid>

                    - look <npc> <player.location>
                    - narrate format:cchat "Huh? Oh, hi There"
                    - wait 20t
                    - narrate format:cchat "You don't look like you're from around these parts"
                    - wait 10t
                    - narrate format:cchat "In any case, you wouldn't happen to have seen my cythe?"
                    - wait 5t
                    - narrate format:cchat "I've just been looking all over for it today. I saw some of them looters run off with it and some of my other stuff this morning. Couldn't catch em' though."
                    - wait 15t
                    - narrate format:cchat "If you would be able to find it for me. Well, I just can't tell you how grateful I would be."
                    - narrate "[Type Yes or No]"
                - else:
                    - narrate "[You have already completed that quest]"
                    - stop
            chat trigger:
                1:
                    trigger: "/Yes/, Sure thing"
                    script:
                    - if !<player.has_flag[DoneFirstTime_F]>:
                        - random:
                            - narrate format:cchat "Why, thank you!"
                            - narrate format:cchat "Thank you so much!"
                            - narrate format:cchat "Thanks!"
                        - narrate "[Find the Farmer's Iron Hoe]"
                    - else:
                        - stop
                2:
                    trigger: "/No/, I'm quite busy"
                    script:
                    - if <!player.has_flag[DoneFirstTime]>:
                        - random:
                            - narrate format:cchat "Oh well, I understand"
                            - narrate format:cchat "Hmph, fine then..."
                            - narrate format:cchat "..."
                    - else:
                        - stop
