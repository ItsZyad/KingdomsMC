##
## * Contains all the scripts necessary to generate low-setup paginated menus in any module.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jan 2023
## @Script Ver: v1.0
## ---------------------------END HEADER----------------------------


PaginatedInterface_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Menu
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [Page_Back] [] [Page_Forward] [] [] []


GetTrueInterface_Proc:
    type: procedure
    definitions: inventory
    debug: false
    script:
    - define outList <list[]>

    - repeat <[inventory].size> as:index:
        - define outList:->:<[inventory].slot[<[index]>]>

    - determine <[outList]>

PaginatedInterface:
    type: task
    debug: false
    definitions: itemList|page|player|footer
    ChangeFooter:
    - if <[footer].exists> && <[footer].size> == 9:
        - define interfaceBody <proc[GetTrueInterface_Proc].context[<[interface]>].get[1].to[<[itemsPerPage]>]>
        - define interfaceFooter <proc[GetTrueInterface_Proc].context[<[interface]>].get[<[itemsPerPage].add[1]>].to[last]>

        - foreach <[footer].list_contents> as:item:
            - if <[item].material.name> != air:
                - define interfaceFooter <[interfaceFooter].overwrite[<[item]>].at[<[loop_index]>]>

        - define newInterfaceItems <[interfaceBody].include[<[interfaceFooter]>]>
        - adjust def:interface contents:<[newInterfaceItems]>

    script:
    - flag <[player]> dataHold.paginated.itemList:<[itemList]> if:<player.has_flag[dataHold.paginated.itemList].not>

    - define outList <list>
    - define itemList <player.flag[dataHold.paginated.itemList]>
    - define interface <inventory[PaginatedInterface_Window]>
    - define itemsPerPage <[interface].size.sub[9]>

    - inject PaginatedInterface path:ChangeFooter

    - define maxPages <[itemList].size.div[<[itemsPerPage]>].round_up>
    - define startPoint <[page].sub[1].mul[<[itemsPerPage]>]>

    - if <[startPoint].is[LESS].than[1]> || <[page].is[MORE].than[<[maxPages]>]>:
        - define startPoint 1

    - repeat <[itemsPerPage]> from:<[startPoint]>:
        - if <[itemList].size> < <[value]>:
            - repeat stop

        - define outList:->:<[itemList].get[<[value]>]>

    - define interface <[interface].include[<[outList]>]>

    - adjust def:interface "title:<[interface].title> (page <[page]>/<[maxPages]>)"

    - definemap determination:
        newPageContents: <[interface].list_contents.get[1].to[<[itemsPerPage]>]>
        newPageNumber: <[page]>

    - flag <[player]> dataHold.paginated.page:<[page]>

    - inventory open d:<[interface]> player:<[player]>
    - determine <[determination]>


PaginatedInterface_Handler:
    type: world
    debug: false
    events:
        on player clicks Page_Back in PaginatedInterface_Window:
        - define pageNum <player.flag[dataHold.paginated.page]>
        - define itemList <player.flag[dataHold.paginated.itemList]>
        - define itemsPerPage <context.inventory.size.sub[9]>
        - define maxPages <[itemList].size.div[<[itemsPerPage]>].round_up>

        - if <[pageNum].sub[1].is[OR_MORE].than[1]>:
            - run PaginatedInterface def.itemList:<[itemList]> def.page:<[pageNum].sub[1]> def.player:<player>

        - else:
            - run PaginatedInterface def.itemList:<[itemList]> def.page:<[maxPages]> def.player:<player>

        - determine cancelled

        on player clicks Page_Forward in PaginatedInterface_Window:
        - define pageNum <player.flag[dataHold.paginated.page]>
        - define itemList <player.flag[dataHold.paginated.itemList]>
        - define itemsPerPage <context.inventory.size.sub[9]>
        - define maxPages <[itemList].size.div[<[itemsPerPage]>].round_up>

        - if <[pageNum].add[1].is[OR_LESS].than[<[maxPages]>]>:
            - run PaginatedInterface def.itemList:<[itemList]> def.page:<[pageNum].add[1]> def.player:<player>

        - else:
            - run PaginatedInterface def.itemList:<[itemList]> def.page:1 def.player:<player>

        - determine cancelled

        on player closes PaginatedInterface_Window:
        - wait 2t
        - if <player.open_inventory> == <player.inventory>:
            - flag <player> dataHold.paginated:!