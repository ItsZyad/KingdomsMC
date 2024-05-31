##
## Contains all the scripts necessary to generate low-setup paginated menus in any module.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
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


DefaultFooter_Window:
    type: inventory
    inventory: chest
    gui: true
    title: null
    slots:
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
    definitions: itemList|page|player|footer|title|flag[ElementTag(String)]
    description:
    - Generates a template paginated interface with the itemList given.
    - Note: Interface name is always: PaginatedInterface_Window.

    script:
    ## Generates a template paginated interface with the itemList given.
    ## Note: Interface name is always: PaginatedInterface_Window.
    ##
    ## itemList : [ListTag<ItemTag>]
    ## page     : [ElementTag<Integer>]
    ## player   : [PlayerTag]
    ## footer   : [InventoryTag]
    ## title    : [ElementTag<String>]
    ## flag     : [ElementTag<String>]
    ##
    ## >>> [MapTag<ListTag,ElementTag<Integer>>]

    # - flag <[player]> dataHold.paginated.itemList:<[itemList]> if:<player.has_flag[dataHold.paginated.itemList].not>
    - define itemList <[itemList].if_null[<player.flag[dataHold.paginated.itemList]>].exclude[<item[air]>]>
    - define footer <inventory[DefaultFooter_Window]> if:<[footer].exists.not>

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

    - foreach <[outList]>:
        - inventory set slot:<[loop_index]> origin:<[value].as[item]> destination:<[interface]>

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

    ChangeFooter:
    - if <[footer].exists> && <[footer].size> == 9:
        - define interfaceBody <proc[GetTrueInterface_Proc].context[<[interface]>].get[1].to[<[itemsPerPage]>]>
        - define interfaceFooter <proc[GetTrueInterface_Proc].context[<[interface]>].get[<[itemsPerPage].add[1]>].to[last]>

        - foreach <[footer].list_contents> as:item:
            - if <[item].material.name> != air:
                - define interfaceFooter <[interfaceFooter].overwrite[<[item]>].at[<[loop_index]>]>

        - define newInterfaceItems <[interfaceBody].include[<[interfaceFooter]>]>
        - adjust def:interface contents:<[newInterfaceItems]>


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

        - if <[pageNum].sub[1].is[OR_MORE].than[1]>:
            - run PaginatedInterface def.itemList:<[itemList]> def.page:<[pageNum].sub[1]> def.player:<player> def.title:<[title]> def.footer:<[footer]>

        - else:
            - run PaginatedInterface def.itemList:<[itemList]> def.page:<[maxPages]> def.player:<player> def.title:<[title]> def.footer:<[footer]>

        - determine cancelled

        on player clicks Page_Forward in PaginatedInterface_Window priority:0:
        - inject <script.name> path:InitializeVariables

        - if <[pageNum].add[1].is[OR_LESS].than[<[maxPages]>]>:
            - run PaginatedInterface def.itemList:<[itemList]> def.page:<[pageNum].add[1]> def.player:<player> def.title:<[title]> def.footer:<[footer]>

        - else:
            - run PaginatedInterface def.itemList:<[itemList]> def.page:1 def.player:<player> def.title:<[title]> def.footer:<[footer]>

        - determine cancelled

        on player closes PaginatedInterface_Window:
        - wait 5t
        - if <player.open_inventory> == <player.inventory>:
            - customevent id:PaginatedInvClose
            - flag <player> <player.flag[datahold.paginated.tempFlagName]>:! if:<player.has_flag[datahold.paginated.tempFlagName]>
            - flag <player> dataHold.paginated:!