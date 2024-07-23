##
## This module contains all scripts relating to the list action of the duchy subcommand.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jul 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

Duchy_Item:
    type: item
    material: player_head
    display name: <element[Duchy].color[<proc[GetColor].context[Vintage.brown]>].bold>
    mechanisms:
        skull_skin: af081ea7-3b8e-4a24-aaac-dbec776ee903|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMzI4OGZjNmYxMzAwNTk1Njg1M2IyOGM5MDA4YjI5MGYwNGY3NjVjNGJhNTBhOGU5Y2Q2MmMwZGJlMmIyYWRhNyJ9fX0=


DuchyListSubcommand:
    type: task
    definitions: kingdom[ElementTag(String)]|player[PlayerTag]
    description:
    - Generates and displays the window which shows the list of duchies belonging to the provided kingdom.
    - ---
    - → [Void]

    script:
    ## Generates and displays the window which shows the list of duchies belonging to the provided
    ## kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ## player  : [PlayerTag]
    ##
    ## >>> [Void]

    - define duchyList <[kingdom].proc[GetKingdomDuchies]>
    - define itemList <list[]>

    - foreach <[duchyList]> as:duchy:
        - definemap lore:
            1: <element[Name: <[kingdom].proc[GetDuchyDisplayName].context[<[duchy]>].color[aqua]>]>
            2: <element[Duke: <[kingdom].proc[GetDuke].context[<[duchy]>].name.color[green]>]>
            3: <element[Balance: <element[$<[kingdom].proc[GetDuchyBalance].context[<[duchy]>].format_number>].color[white]>]>
            4: <element[Royal Rate: <element[<[kingdom].proc[GetDuchyTaxRate].context[<[duchy]>].mul[100].format_number>%].color[white]>]>

        - define duchyItem <item[Duchy_Item]>
        - adjust def:duchyItem lore:<[lore].values>
        - adjust def:duchyItem display:<[kingdom].proc[GetDuchyDisplayName].context[<[duchy]>].color[<proc[GetColor].context[Vintage.brown]>].bold>

        - define itemList:->:<[duchyItem]>

    - run PaginatedInterface def.itemList:<[itemList]> def.player:<[player]> def.page:1 def.title:<element[Duchy List]>
