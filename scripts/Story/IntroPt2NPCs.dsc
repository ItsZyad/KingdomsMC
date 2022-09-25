##
## * All Assignment and Interact scripts
## * related to most of the NPCs you run
## * into after the dockmaster and before Hermann
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jan 2022
## @Script Ver: Indev
##
## ----------------END HEADER-----------------

MerchantTutorial_Handler:
    type: world
    events:
        on player enters cuboid:
        - if <context.area.name> == MerchantTutorialLoc:
            - if !<player.has_flag[InteractingWith]>:
                - if <player.flag[DidIntro]> == 1:
                    - flag <player> InteractingWith:<npc[875]>

                    - lookclose <npc[875]> realistic range:15 state:true

                    - narrate format:npctalk "Hey you!"
                    - wait 1s
                    - narrate format:npctalk "You look lost, need some help?"

                    - glow <npc[875]>

                    - clickable IntroTwoNPCs_HelpAccepted save:HelpAccepted def:<player>
                    - clickable IntroTwoNPCs_HelpNotAccepted save:HelpNotAccepted def:<player>

                    - narrate "<bold>OPTIONS:"
                    - narrate "- <aqua><underline><element[<&dq>Nah, I'm good, thanks<&dq>].on_click[<entry[HelpNotAccepted].command>]>"
                    - narrate "- <aqua><underline><element[<&dq>Was it too obvious?<&dq>].on_click[<entry[HelpAccepted].command>]>"

                    - lookclose <npc[875]> state:false

IntroTwoNPCs:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true
        - trigger name:proximity state:true radius:10

        on exit proximity:
        - flag InteractingWith expire:20s

    default constants:
        default_script: "IntroTwoNPCs_I"
        default_step: 1

    interact scripts:
    - NEWAlreadyInteract_Handler
    #- IntroTwoNPCs_I

IntroTwoNPCs_HelpNotAccepted:
    type: task
    definitions: target
    script:
    - glow <[target].flag[InteractingWith]> glow:false
    - flag <[target]> InteractingWith:!
    - narrate format:npctalk "hmph... fine then..."

IntroTwoNPCs_HelpAccepted:
    type: task
    definitions: target
    script:
    - engage
    - lookclose realistic range:15 state:true

    - narrate <&sp>
    - narrate format:npctalk "Heh, only a little"
    - wait 2s
    - narrate format:npctalk "So tell me, stranger, whatcha lookin' for?"
    - narrate <&sp>
    - wait 3s

    - clickable IntroTwoNPCs_HelpAccepted2 def:1|<[target]> save:HelpTypeOne
    - clickable IntroTwoNPCs_HelpAccepted2 def:2|<[target]> save:HelpTypeTwo

    - narrate "<bold>OPTIONS:"
    - narrate "- <aqua><underline><element[<&dq>Where do people buy things here?<&dq>].on_click[<entry[HelpTypeOne].command>]>"
    - narrate "- <aqua><underline><element[<&dq>I want somewhere I can get drunk...<&dq>].on_click[<entry[HelpTypeTwo].command>]>"

    # If the player has already asked for help and is now ending the convo
    - if <player.flag[HelpAccepted].is[MORE].than[1]>:
        - narrate "- <aqua><underline><element[<&dq>Alright, I'm all good now, Thanks!<&dq>].on_click[]>"

    # If the player decides to change their mind after asking for the help
    # *like a bitch*
    - else:
        - define cancelMessage "<element[<&dq>Uhh... actually... ehm. Nevermind.<&dq>].on_click[/ex flag <player> HelpAccepted:!]>"
        - narrate "- <aqua><underline><[cancelMessage]>"

    - narrate <&sp>

IntroTwoNPCs_HelpAccepted2:
    type: task
    definitions: HelpAcceptedType|target
    subpaths:
        QuestTip:
        - if <player.flag[DidIntro]> == 1:
            - narrate "<gray><italic>Tip: Use <blue>/quests <gray>to learn more about your current objectives."

    script:
    # TODO: Change out for switch-case statements later

    # If the player asks for the market
    - if <[HelpAcceptedType]> == 1:
        - narrate format:npctalk "Oh! That would be the Alderon market, of course! It's all covered in those pretty colored tents; can't miss it!"
        - wait 6s
        - narrate format:npctalk "There, you can buy and sell all sorts of things; wood, food, tools, armour - the whole nine yards!"
        - wait 4s
        - narrate format:npctalk ...
        - wait 3s
        - narrate format:npctalk "And between you and me..."
        - wait 2s
        - narrate format:npctalk "There's another place."
        - wait 2s
        - narrate <&sp>
        - narrate format:npctalk "You see, Fyndalin's run by a whole lot of bad people right now. And their favorite pasttime is banning stuff. People used to travel over the Shilak river to get those things from St. Marcus"
        - wait 9s
        - narrate <&sp>
        - narrate format:npctalk "But a while back, a bunch of mob bosses decided they wanted to capitalize on this. So they all dug underground and started running this massive black market operation."
        - wait 7s
        - narrate <&sp>
        - narrate format:npctalk "I think if you poke around the market enough, you should run into it. Or at least someone who can put you in the right direction."
        - wait 7s
        - toast icon:obsidian frame:goal "Go to Alderon and locate the black market."

        - inject IntroTwoNPCs_HelpAccepted2.subpaths.QuestTip

    - else if <[HelpAcceptedType]> == 2:
        - narrate format:npctalk "Heh, Fyndalin's got nothing more than pubs and taverns. Nearest one is the half cut glass - sailor's favorite."
        - wait 5s
        - narrate format:npctalk "The guy who runs the place actually used to be a navy captain... Might have some fun stories."
        - wait 6s
        - toast frame:goal icon:potion "Talk to the captain at the Half Cut Glass."

        - inject IntroTwoNPCs_HelpAccepted2.subpaths.QuestTip

        - define questName "A Sailor's Story"
        - define questDesc "<list[Go to the Half Cut Glass tavern|Speak to the captain]>"
        - flag <[target]> quests:->:<map[name=<[questName]>;desc=<[questDesc]>;expires=null;icon=book;status=active]>
        - run SidebarLoader def:<player>

    - else if <[HelpAcceptedType]> == 3:
        - narrate format:npctalk "Anytime, buddy"

    - glow <player.flag[InteractingWith]> glow:false
    - flag <player> InteractingWith:!
    #- flag <player> DidIntro:2

    - lookclose state:false
    - disengage

IntroTwoNPCs_I:
    type: interact
    steps:
        1:
            # All dialogue lines for when the player interacts with the NPC after
            # they've finished the first part of the tutorial
            click trigger:
                script:
                - if <player.flag[DidIntro].is[MORE].than[1]>:
                    - narrate WIP