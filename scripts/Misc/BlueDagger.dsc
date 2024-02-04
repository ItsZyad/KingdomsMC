##
## All things related to CJ's clandestine sabotage organization
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Aug 2022
## @Script Ver: INDEV
##
#- Note: file slated for deletion.
##
## ----------------END HEADER-----------------

BD_Command:
    type: command
    name: bd
    usage: /bd
    description: All things related to your neighbourhood friendly clandestine sabotage organization
    permission: kingdoms.bluedagger
    tab completions:
        1: warp|deposit|withdraw|balance
    script:
    - define kingdom <player.flag[kingdom]>
    - define BDInfo <server.flag[bd]>
    - define args <context.raw_args.split_args>

    - choose <[args].get[1]>:
        - case warp:
            - narrate format:callout "Warping... Please wait."
            - wait 3s

            - teleport <player> <[BDInfo].get[warp]>

        - case balance:
            - narrate format:callout "<element[<[BDInfo].get[name]>'s Balance].color[gold].bold>: $<[BDInfo].get[balance].if_null[0].format_number>"

        - case deposit:
            - define amount <[args].get[2]>

            - if <[amount].is_integer> && <[amount]> > 0:
                - if <player.money> >= <[amount]>:
                    - flag server bd.balance:+:<[amount]>

                - else:
                    - narrate format:callout "You do not have sufficient funds to do this!"

            - else:
                - narrate format:callout "Please ensure that you have entered a valid number!"

        - case withdraw:
            - define amount <[args].get[2]>

            - if <[amount].is_integer> && <[amount]> > 0:
                - if <[BDInfo].get[balance]> <= <[amount]>:
                    - flag server bd.balance:-:<[amount]>

                - else:
                    - narrate format:callout "The organization's balance does not have sufficient funds to do this!"

            - else:
                - narrate format:callout "Please ensure that you have entered a valid number!"
