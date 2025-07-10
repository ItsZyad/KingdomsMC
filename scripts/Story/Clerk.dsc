##ignorewarning invalid_data_line_quotes
##ignorewarning bad_quotes

ClerkNPC:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true
    interact scripts:
    - ClerkNPC_I
    #- AlreadyInteract_Handler

ClerkNPC_OptionList1:
    type: data
    keys:
        options:
            - "[Ask about joining a kingdom]"
            - "[Ask about Fyndalin]"
        actions:
            - ClerkNPC_JoiningKingdom
            - ClerkNPC_FyndalinDiscussion

ClerkNPC_AssignKingdom:
    type: task
    definitions: kingdom|target
    script:
    - flag <[target]> kingdom:<[kingdom]>
    - ~run SidebarLoader def:<player>
    - narrate format:npctalk "Alrighty! Great to hear! You can use <blue>/kingdom warp <&r> or <blue>/k warp <&r>to go to your new kingdom's territory!"
    - wait 2s
    - narrate format:npctalk "I also have this encyclopedia filled with (almost) everything there is to know about about your kingdom is run!"
    - wait 5s
    - narrate format:npctalk "Have a nice day!"

    - flag <player> InteractingWith:!

ClerkNPC_JoiningKingdom:
    type: task
    script:
    - engage
    - narrate format:npctalk "Of course! Let me just take your name down..."
    - lookclose state:false
    - wait 2t
    - look <npc> <player.location>
    - wait 4s
    - lookclose state:true
    - wait 1s
    - narrate format:npctalk "Alright and what kingdom would you like to join?"

    # Sloppy - find a better way when possible!
    - clickable ClerkNPC_AssignKingdom def.kingdom:centran def.target:<player> save:centran
    - clickable ClerkNPC_AssignKingdom def.kingdom:cambrian def.target:<player> save:cambrian
    - clickable ClerkNPC_AssignKingdom def.kingdom:viridian def.target:<player> save:viridian
    - clickable ClerkNPC_AssignKingdom def.kingdom:raptoran def.target:<player> save:raptoran

    - define alteaElem "<element[The Republic of Altea].on_hover[<script[KingdomDescriptions].data_key[raptoran]>]>"
    - define grovElem "<element[The Grovelian Empire].on_hover[<script[KingdomDescriptions].data_key[cambrian]>]>"
    - define muspElem "<element[The Dominion of Muspelheim].on_hover[<script[KingdomDescriptions].data_key[centran]>]>"
    - define viridElem "<element[The Imperium Viriditas].on_hover[<script[KingdomDescriptions].data_key[viridian]>]>"

    - narrate <&sp>
    - narrate "- <red><bold><[alteaElem].on_click[<entry[raptoran].command>]>"
    - narrate "- <gold><bold><[grovElem].on_click[<entry[cambrian].command>]>"
    - narrate "- <aqua><bold><[muspElem].on_click[<entry[centran].command>]>"
    - narrate "- <green><bold><[viridElem].on_click[<entry[viridian].command>]>"
    - narrate <&sp>

    - disengage

ClerkNPC_FyndalinDiscussion:
    type: task
    definitions: subpath
    script:
    - define subpath <[subpath].if_null[-1]>
    - define factAmount <script[ClerkNPCFacts].data_key[].keys.exclude[type].get[last]>
    - define randomNum <util.random.int[1].to[<[factAmount]>]>
    - define rawFact <script[ClerkNPCFacts].data_key[<[randomNum]>].get[text]>

    - if <[subpath]> == 1:
        - define libRef <script[ClerkNPCFacts].data_key[<[randomNum]>].get[lib_ref]>

        - if <[libRef].as[list].size> == 1:
            - narrate format:npctalk "I think you can find a book, in the archive, on that at the reference: <[libRef]>"

        - else:
            - narrate format:npctalk "We have a number of books on that. Here are their references:"
            - foreach <[libRef].as[list]>:
                - narrate format:npctalk <[value]>

    - else if <[subpath]> == 2:
        # Todo: Add a - random command here
        - narrate format:npctalk "Fair enough..."

    - else:
        - narrate format:npctalk "Ah, you wanna you know more about the city, eh?"
        - wait 2s

        - random:
            - narrate format:npctalk "Let me see if I can pull something up from the archives..."
            - narrate format:npctalk "Alright, let's see what I got here..."
            - narrate format:npctalk "Hmm... let me think..."

        - wait 2s

        - random:
            - narrate format:npctalk "Ah, I got it!"
            - narrate format:npctalk "Ok, I think I have something for you;"
            - narrate format:npctalk "Oh here's something interesting..."

        - wait 1s

        - define startWord "Did you know "
        - define fact <[rawFact].split[/w/]>

        - foreach <[fact]>:
            - define waitAmount <[value].split[<&sp>].size.div[2.7]>
            - narrate <&sp>

            - if <[loop_index]> != 1:
                - narrate format:npctalk <[value]>
            - else:
                - narrate format:npctalk <[startWord]><[value]>
                - define waitAmount:+:2

            - wait <[waitAmount]>s

        - if <script[ClerkNPCFacts].data_key[<[randomNum]>].get[lib_ref]>:
            - narrate format:npctalk "Interesting stuff, right? Would you like to know more?"

            - clickable ClerkNPC_FyndalinDiscussion def:1 save:learnMore until:1m usages:1
            - clickable ClerkNPC_FyndalinDiscussion def:2 save:noLearnMore until:1m usages:1

            - narrate <aqua><underline><element[Yes].on_click[<entry[learnMore].command>]>
            - narrate <aqua><underline><element[No].on_click[<entry[noLearnMore].command>]>

        - else:
            - narrate format:npctalk "Interesting stuff right?"

        - flag <player> InteractingWith:!

ClerkNPC_I:
    type: interact
    steps:
        1:
            click trigger:
                script:
                - if !<player.has_flag[InteractingWith]>:
                    - flag <player> InteractingWith:<npc>
                    - define timeOfDay Evening

                    - glow <npc> true

                    - if <player.location.world.time.is[OR_LESS].than[12500]> && <player.location.world.time.is[MORE].than[6000]>:
                        - define timeOfDay Afternoon

                    - else:
                        - define timeOfDay Morning

                    - narrate format:npctalk "Good <[timeofDay]>, sir, what can I help you with?"

                    - define optionList <script[ClerkNPC_OptionList1].data_key[keys.options]>
                    - define actionList <script[ClerkNPC_OptionList1].data_key[keys.actions]>

                    - if <player.has_flag[kingdom]>:
                        - define optionList <[optionList].remove[1]>
                        - define actionList <[actionList].remove[1]>

                    - run ParseStoryOptions def.options:<[optionList]> def.actions:<[actionList]> def.target:<player>
                    - glow <npc> false