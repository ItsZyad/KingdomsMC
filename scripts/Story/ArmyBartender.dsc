ArmyBartenderNPC:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true

    default constants:
        default_script: "ArmyBartenderNPC_I"

    interact scripts:
    #- ArmyBartenderNPC_I
    - NEWAlreadyInteract_Handler

TutMerchantNPC_OptionList1:
    type: data
    keys:
        options:
            - "Wait, why?"
            - "[Ask about Fyndalin]"
        actions:
            - ClerkNPC_JoiningKingdom
            - ClerkNPC_FyndalinDiscussion

#BarWhyClosed:
#    type: task
#    script:

ArmyBartenderNPC_I:
    type: task
    script:
    - if <player.flag[DidIntro]> == 1:
        - if <npc.has_flag[IntroMerchant]>:
            - narrate format:npctalk "Sorry buddy, we're closing up for the day..."
            - wait 3s
            - narrate format:npctalk "...And tomorrow too. "
            - wait 2s

            #- clickable BarWhyClosed
