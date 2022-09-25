IntroNPC:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true
    interact scripts:
    - IntroNPC_I
    #- AlreadyInteract_Handler

IntroNPC_KingdomDiscussion:
    type: task
    script:
    - narrate format:npctalk Oh...
    - wait 2s
    - narrate format:npctalk "The kingdoms..."
    - wait 3s
    - narrate format:npctalk "Right, yeah... err... of course you'd want to join the kingdoms."
    - wait 3s
    - narrate format:npctalk "How silly of me. Why would you be here for any other reaon..."
    - wait 4s
    - narrate format:npctalk "...A traveller from far away; visiting these parts."
    - wait 3s
    - narrate format:npctalk "Sorry... it's nothing against you- I know you're new and naive. But a word of warning"
    - wait 5s
    - narrate <&sp>
    - narrate format:npctalk "People in this town are lovely and will treat you like family. But there are a few things you don't talk about unless you want trouble."
    - wait 8s
    - narrate <&sp>
    - narrate format:npctalk "If you want to join one of the kingdoms then you should go look for this guy called Hermann at the city clerk's office near the castle. He'll get it sorted out for you ASAP."
    - wait 9s
    - narrate <&sp>
    - narrate format:npctalk "If you have trouble finding the place - use this map. It should give you the general gist of things."
    - wait 1s
    - give to:<player.inventory> filled_map[map=345]
    #- narrate <&sp>
    #- narrate "<gray><italic>Tip: There will be NPCs on your way to the city clerk that will give you starter quests. You are not required go through them if you already know how the game works."

IntroNPC_I:
    type: interact
    steps:
        1:
            click trigger:
                script:
                - if !<player.has_flag[DidIntro]>:
                    - lookclose range:10
                    - narrate format:npctalk "Oh why hello there, traveller! I've never seen you around these parts..."
                    - wait 2s
                    - narrate format:npctalk "You must be new!"
                    - wait 1s
                    - narrate format:npctalk "Welcome to Fyndalin!"
                    - wait 2s
                    - narrate format:npctalk "Here, you'll find everything you need! Markets, inns, taverns."
                    - wait 3s
                    - narrate format:npctalk "You could even take up a job. I can always use an extra set of hands down here at the dock."
                    - wait 3s

                    - narrate <&sp>

                    - clickable IntroNPC_KingdomDiscussion save:KDisc usages:1 until:10m

                    - narrate "<bold>OPTIONS:"
                    - narrate "- <aqua><underline><element[[Ask about the kingdoms]].on_click[<entry[KDisc].command>]>"
                    - narrate <&sp>

                    - flag <player> DidIntro:1

                    - wait 2s
                    - lookclose false

