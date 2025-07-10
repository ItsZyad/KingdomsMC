Quests_Command:
    type: command
    name: quests
    usage: /quests
    description: Shows all the player's current and finished quests.
    tab completions:
        1: active|completed
    script:
    - if <player.has_flag[quests]>:
        - define outList <list>
        - define completionToBool <map[active=false;completed=true]>

        - foreach <player.flag[quests]>:
            - define status <[value].get[status]>
            - narrate format:debug COMP:<[status]>

            - if <[status]> == <context.args.get[1]>:
                - define icon <[value].get[icon]>
                - define expires <[value].get[expires]>
                - define desc <[value].get[desc]>
                - define name <[value].get[name]>

                - define questItem <item[<[icon]>]>
                - adjust def:questItem flag:name:<[name]>
                - adjust def:questItem flag:desc:<[desc]>
                - adjust def:questItem flag:expires:<[expires]>

                - if <[expires]> == null:
                    - define expires <gray>N/A

                - narrate format:debug DESC_RAW:<[desc]>

                - foreach <[desc]>:
                    - define descList:->:-<&sp><[value]>

                - narrate format:debug DESC:<[descList]>
                - narrate ------------

                - define loreName <element[<aqua>Name: <&r><bold><[name]>]>
                - define loreDesc <element[<aqua>Description:]>
                - define loreExp <element[<aqua>Time to Finish: <[expires]>]>

                - define loreList <list[<[loreName]>|<[loreDesc]>|<[loreExp]>]>
                - define loreList <[loreList].insert[<[descList]>].at[3]>

                - adjust def:questItem lore:<[loreList]>
                - adjust def:questItem display:<bold><light_purple><[status].to_titlecase><&sp>Quest

                - narrate format:debug LORE:<[loreList]>
                - narrate ------------

                - define outList:->:<[questItem]>

        - if <[outList].size.is[MORE].than[27]>:
            - run Paginate_Task def.itemArray:<[outList]> def.itemsPerPage:27 def.page:1 save:PaginatedList
            - narrate format:debug <entry[PaginatedList].created_queue.determination>
            - flag <player> QuestList:<entry[PaginatedList].created_queue>

        - else:
            - flag <player> QuestList:<[outList]>

        - inventory open destination:QuestsGUI

    - else:
        - narrate format:callout "You have not done any quests or objectives yet!"

QuestsGUI:
    type: inventory
    inventory: chest
    gui: true
    title: <player.name>'s Quests
    procedural items:
    - determine <player.flag[QuestList]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [Page_Back] [] [Page_Forward] [] [] []