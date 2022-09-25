##
## * Helper functions for anything story-related
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Dec 2021
## @Script Ver: N/A
##
## ----------------END HEADER-----------------

ParseStoryOptions:
    type: task
    definitions: options|actions|target
    script:
    - if <[options].size> != 0:
        - narrate <&sp>
        - narrate "<bold>OPTIONS:"

        - foreach <[options]>:
            - clickable <[actions].get[<[loop_index]>]> save:clickthing

            - if <[value].starts_with[<&lb>]>:
                - narrate "- <aqua><underline><element[<[value]>].on_click[<entry[clickthing].command>]>"

            - else:
                - narrate "- <aqua><element[<[value]>].on_click[<entry[clickthing].command>]>"

        - clickable CancelInteraction def.target:<[target]> save:cancel
        - narrate "- <gray><element[Cancel].on_click[<entry[cancel].command>]>"

        - narrate <&sp>

CancelInteraction:
    type: task
    definitions: target
    script:
    - disengage
    - flag <[target]> InteractingWith:!
    - narrate format:callout "Action Cancelled!"

dialogueoption:
    type: format
    format: "- <aqua><underline><[text]>"

KingdomDescriptions:
    type: data
    centran: "The oldest, most entrenched power on the continent. In Muspelheim, there is no shortage of tradition and respect for history. While having historical roots means the Muspel people can lay claim to just about any land in the region, it also means their most glorious days are long behind them."
    raptoran: "In a land of kingdoms and empires, Altea stands as the lone republic. It is also one of the youngest states on the continent, and it sees its formative years as the sole opportunity to prove its worth. However, being staunchly anti-imperialist, it is hard to see Altea spreading its influence through land claims only."
    viridian: "Viridia is a kingdom of merchants, uninterested in the petty politics of the region. The only time its involvement is apparent is when there is some monetary gain possible. However, its distance from politics makes it one of the most lucrative black market partners on the whole continent."
    cambrian: "It's hard to put your finger on what exactly Grovelia wants, most of the time. Largely due to the kingdom's secrecy, but also because the commanders themselves do not have a cohesive strategy, sometimes. Nevertheless, having exited a series of brutal civil wars, Grovelia is the place where warriors are made. Whatever they decide to do, they will pursue it with a vengence."

NEWAlreadyInteract_Handler:
    type: interact
    steps:
        1:
            click trigger:
                script:
                - engage

                - if <player.has_flag[InteractingWith]>:
                    - if <player.flag[InteractingWith]> == <npc>:
                        - narrate format:callout "You are already in an interaction with this NPC!"

                    - else:
                        - narrate format:callout "You are already interacting with an NPC!"

                - else:
                    - inject <npc.constant[default_script]>

                - disengage
