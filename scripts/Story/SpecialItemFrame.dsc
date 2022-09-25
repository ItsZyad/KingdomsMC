##
## * Creates a special type of itemframe which allows the
## * player to view a book inside it without having to
## * pick the book up
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Apr 2022
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------


BookTemplate_Item:
    type: item
    material: written_book
    mechanisms:
        book_pages: <list[aaa]>
        book_author: null
        book_title: null

SpecialItemFrame_Item:
    type: item
    material: item_frame
    display name: "Auto Item Frame"
    mechanisms:
        fixed: true
    lore:
        - "If this itemframe holds a book. It will"
        - "automagically open that book for the player"
        - "when they click it!"

SpecialItemFrame_Handler:
    type: world
    events:
        on player right clicks item_frame:
        - define framed <context.entity.framed_item>

        - if <[framed].material.name> == written_book:
            - adjust <player> show_book:<[framed]>

            - determine cancelled