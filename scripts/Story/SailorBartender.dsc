##
## * All scripts related to Sammy the bartender
##
## * Note: Sammy is considered as an NPC part of the
## * Second phase of the Intro. In other words,
## * is a natural extension of the interactions which
## * took place in IntroPt2NPCs.dsc
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jan 2022
## @Script Ver: Indev
##
## ----------------END HEADER-----------------

SailorBartender:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true
        - trigger name:proximity state:true radius:2

        on enter proximity:
        - wait 6s

        - if !<npc.flag[PlayerInteractions].deep_get[<player>.FirstInteracResult].exists>:
            - if !<player.has_flag[InteractingWith]> && !<player.has_flag[StoppingFlag]>:
                - glow <npc>

                - flag <player> InteractingWith:<npc>
                - narrate format:npctalk "So are we going to keep staring at each other or..."

                - clickable SailorBartender_ConvStart save:AwkwardStart def:1|<player>

                - narrate "<bold>OPTIONS:"
                - narrate format:dialogueoption "<element[<&dq>Ah...Uh- yeah, sorry! A-Are you the captain?<&dq>].on_click[<entry[AwkwardStart].command>]>"

                - narrate <&sp>

        on exit proximity:
        - flag player StoppingFlag
        - wait 7s
        - flag player StoppingFlag:!

        on click:
        - flag player StoppingFlag expire:7s
        - define FirstInteracResult <npc.flag[PlayerInteractions].deep_get[<player>.FirstInteracResult]>

        - narrate <[FirstInteracResult].if_null[false]>

        - if <[FirstInteracResult].if_null[false]>:
            - inject SailorBartender_SecondInteraction path:KickedOut

        - else:
            - clickable SailorBartender_ConvStart def:1|<player>|<npc> save:AskCaptain
            - clickable SailorBartender_ConvStart def:2|<player>|<npc> save:AskDrink

            - narrate "<bold>OPTIONS:"
            - narrate format:dialogueoption "<element[<&dq>Hi, excuse me. Are you the captain?<&dq>].on_click[<entry[AskCaptain].command>]>"
            - narrate format:dialogueoption "<element[<&dq>Hey, get me a stiff drink, will ya<&dq>].on_click[<entry[AskDrink].command>]>"

SailorBartender_SecondInteraction:
    type: task
    subpaths:
        KickedOut:
        - narrate WIP

    script:
    - narrate <&sp>

SailorBartender_ConvStart:
    type: task
    definitions: convoStart|target|npc
    subpaths:
        # Subpath for awkwardly apologizing for being awkward
        # or the Zyad subpath :')
        1:
        - narrate format:npctalk ...
        - wait 3s
        - narrate format:npctalk Captain?
        - wait 2s
        - narrate format:npctalk "Who sent ya here, boy?"
        - wait 2s
        - narrate format:npctalk "I haven't had anyone call me that in years..."
        - wait 3s

        # IDEA: Maybe have a dialogue line where the player can
        # try to lie to the captain and there's a random chance
        # that the captain calls bullshit...

        - clickable SailorBartender_ConvStart.subpaths.Truth-1 save:Truth-1

        - narrate <&sp>
        - narrate "<bold>OPTIONS:"
        - narrate format:dialogueoption "<element[<&dq>It was that merchant down by the docks... Do you know each other?<&dq>].on_click[<entry[Truth-1].command>]>"

        Truth-1:
        - narrate format:npctalk *sigh*
        - wait 2s
        - narrate format:npctalk "That dumbass just doesn't know how to keep his mouth shut"
        - wait 4s
        - narrate format:npctalk "He wasn't supposed to know, by the way. Pete just happened to walk in while I was packing up some of my old sailing gear - from when I was back in the navy"
        - wait 8s
        - narrate <&sp>
        - narrate format:npctalk "It's just embarassing..."

        - wait 3s

        - clickable SailorBartender_ConvStart.subpaths.Truth-2 save:Truth-2

        - narrate <&sp>
        - narrate "<bold>OPTIONS:"
        - narrate format:dialogueoption "<element[<&dq>Why do you not want people to know you were in the navy?<&dq>].on_click[<entry[Truth-2].command>]>"
        - narrate <&sp>

        Truth-2:
        - narrate format:npctalk "Boy, there's clearly many things you still don't know about this city..."
        - wait 5s
        - narrate format:npctalk "And I don't got the time to explain it all to'ya."
        - wait 4s
        - narrate format:npctalk "But you see that ship out there on the dock?"
        - wait 4s
        - narrate format:npctalk "I used to be the captain of it during the war..."
        - wait 4s
        - narrate format:npctalk "Glorious days they were..."
        - wait 3s
        - narrate format:npctalk "My men and I sunk nearly 23 coalition ships at 3 different engagements - US ALONE!"
        - wait 5s
        - narrate <&sp>
        - narrate format:npctalk "We were the best crew of the best navy in the world! And even that wasn't enough to change the inevitable."
        - wait 6s
        - narrate <&sp>
        - narrate format:npctalk "There were just so many of them."
        - wait 3s
        - narrate format:npctalk "We'd sink a ship and 3 more appear over the horizon..."

        - wait 4s

        - clickable SailorBartender_ConvStart.subpaths.Truth-3 save:Truth-3

        - narrate <&sp>
        - narrate "<bold>OPTIONS:"
        - narrate format:dialogueoption "<element[<&dq>...But you were still the best... Right?<&dq>].on_click[<entry[Truth-3].command>]>"
        - narrate <&sp>

        Truth-3:
        - narrate format:npctalk "THAT'S NOT WHAT MATTERS!"
        - wait 3s
        - narrate format:npctalk "What matters is what it represents!"
        - wait 5s
        - narrate format:npctalk "After we... uhm"
        - wait 3s
        - narrate format:npctalk "<italic>Lost... the war."
        - wait 3s
        - narrate format:npctalk "The president ordered all ships in the navy scuttled to preserve the last shread of honor we had."
        - wait 4s
        - narrate <&sp>
        - narrate format:npctalk "I... Well- I delayed. I just couldn't bring myself to do it. After everything my crew and I had been through..."
        - wait 5s
        - narrate <&sp>
        - narrate format:npctalk "Safe to say I regret it. They kept it as a war trophy. They put it on display behind this very tavern."
        - wait 4s
        - narrate <&sp>
        - narrate format:npctalk "I knew I would never forget the pain. But I hoped that enough people would just forget me..."
        - wait 6s
        - narrate <&sp>
        - narrate format:npctalk "Clearly not..."
        - wait 3s
        - narrate format:npctalk "You're here asking me about it..."

    ###############################################################################################################

        # Subpath where the player doesn't realize they're already
        # talking to the captain
        2:
        - narrate format:npctalk "You got it"
        - wait 1s
        - lookclose <[npc]> state:false
        - wait 1s
        - look <[npc]> <[npc].location.backward_flat[3]>
        - wait 2s
        - walk <[npc]> <[npc].anchor[DrinkLoc1]>
        - animate <[npc]> animation:ARM_SWING
        - wait 2s
        - narrate format:npctalk "So, stranger, what brings you to Fyndalin?"
        - wait 1s
        - animate <[npc]> animation:AMR_SWING

        2-1:
        - walk <[npc]> <[npc].anchor[DrinkLoc2]>
        #- walk <[npc]> <[npc].location.right[2]>
        #- wait 2s
        #- walk <[npc]> <[npc].location.left[2]>
        #- look <[npc]> <player.location>
        #- lookclose <npc> state:true

    script:
    - inject SailorBartender_ConvStart.subpaths.<[convoStart]>

TEMP_Set_NPC_Yaw:
    type: task
    definitions: npc|newYaw
    script:
    - define loc <[npc].location>
    #- define adjustedLoc <location[<[loc].x>,<[loc].y>,<[loc].z>,<[loc].pitch>,<[newYaw]>,<[loc].world.name>]>

    - look <[npc]> <[loc]> yaw:<[newYaw]>