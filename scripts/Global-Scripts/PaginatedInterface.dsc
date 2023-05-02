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
    description:
    - Generates a template paginated interface with the itemList given.
    - Interface name is always: PaginatedInterface_Window
    - -=-=-=-=-=-=-=-=-=-=-=-=-=-
    - @itemList [ListTag[ItemTag]] A list of items to be displayed in the interface.
    - @page: [ElementTag[Integer]] The page number that the interface starts on.
    - @player: [PlayerTag] Player for which the interface will be displayed.
    - ?footer: [InventoryTag] Additional buttons to add in the footer of the interface (other than prev/next page).
    - ?title: [ElementTag[String]] Interface title.
    - ?flag: [ElementTag[String]] A flag to be applied to the player while they are looking at the interface.

    definitions: itemList|page|player|footer|title|flag
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
    # - flag <[player]> dataHold.paginated.itemList:<[itemList]> if:<player.has_flag[dataHold.paginated.itemList].not>
    - define itemList <[itemList].if_null[<player.flag[dataHold.paginated.itemList]>].exclude[<item[air]>]>

    - flag <[player]> dataHold.paginated.itemList:<[itemList]>
    - flag <[player]> dataHold.paginated.footer:<[footer]>
    - flag <[player]> dataHold.paginated.title:<[title]>

    - define outList <list>
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

    - adjust def:interface title:<[title]> if:<[title].exists>
    - adjust def:interface "title:<[interface].title> (page <[page]>/<[maxPages]>)"

    - definemap determination:
        newPageContents: <[interface].list_contents.get[1].to[<[itemsPerPage]>]>
        newPageNumber: <[page]>

    - if <[flag].exists>:
        - flag <[player]> datahold.paginated.tempFlagName:<[flag]>
        - flag <[player]> <[flag]>

    - flag <[player]> dataHold.paginated.page:<[page]>

    - inventory open d:<[interface]> player:<[player]>
    - determine <[determination]>


PaginatedInterface_Handler:
    type: world
    debug: false
    InitializeVariables:
    - define pageNum <player.flag[dataHold.paginated.page]>
    - define itemList <player.flag[dataHold.paginated.itemList]>
    - define itemsPerPage <context.inventory.size.sub[9]>
    - define maxPages <[itemList].size.div[<[itemsPerPage]>].round_up>
    - define footer <player.flag[dataHold.paginated.footer]>
    - define title <player.flag[dataHold.paginated.title]>

    #Todo: add custom events that fire when player changes page
    events:
        on player clicks Page_Back in PaginatedInterface_Window priority:0:
        - inject <script.name> path:InitializeVariables
        - narrate format:debug PAGE_BACK

        - if <[pageNum].sub[1].is[OR_MORE].than[1]>:
            - run PaginatedInterface def.itemList:<[itemList]> def.page:<[pageNum].sub[1]> def.player:<player> def.title:<[title]> def.footer:<[footer]>

        - else:
            - run PaginatedInterface def.itemList:<[itemList]> def.page:<[maxPages]> def.player:<player> def.title:<[title]> def.footer:<[footer]>

        - determine cancelled

        on player clicks Page_Forward in PaginatedInterface_Window priority:0:
        - inject <script.name> path:InitializeVariables
        - narrate format:debug PAGE_FORWARD

        - if <[pageNum].add[1].is[OR_LESS].than[<[maxPages]>]>:
            - run PaginatedInterface def.itemList:<[itemList]> def.page:<[pageNum].add[1]> def.player:<player> def.title:<[title]> def.footer:<[footer]>

        - else:
            - run PaginatedInterface def.itemList:<[itemList]> def.page:1 def.player:<player> def.title:<[title]> def.footer:<[footer]>

        - determine cancelled

        on player closes PaginatedInterface_Window:
        - wait 2t
        - if <player.open_inventory> == <player.inventory>:
            - customevent id:PaginatedInvClose
            - flag <player> <player.flag[datahold.paginated.tempFlagName]>:!
            - flag <player> dataHold.paginated:!