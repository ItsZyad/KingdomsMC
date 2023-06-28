UsableBookshelf_Item:
    type: item
    material: bookshelf
    display name: Usable Bookshelf


UsableBookshelf_GUI:
    type: inventory
    inventory: chest
    title: Bookshelf
    procedural items:
    - determine <player.flag[BookshelfItems]>
    slots:
    - [] [] [] [] [] [] [] [] []


#NewBookshelfHandler:
#    type: task
#    script:


UsableBookshelf_Handler:
    type: world
    events:
        # When player clicks a bookshelf with an empty hand
        on player right clicks block type:bookshelf:
        - ratelimit <player> 1t
        - define invOpen true

        - if <player.is_sneaking>:
            - define invOpen false

        - if <[invOpen]>:
            - determine passively cancelled
            - animate <player> animation:ARM_SWING
            - playsound <player> sound:ITEM_BOOK_PUT volume:1.5 pitch:0.7

            - if <server.flag[Bookshelves].get[<context.location>].exists>:
                - flag <player> BookshelfItems:<server.flag[Bookshelves].get[<context.location>]>

            - else:
                - flag <player> BookshelfItems:<list[]>

            - flag <player> BookshelfLocation:<context.location>

            - define bookshelfGui <proc[BookshelfClone]>
            - definemap openShelfInfo:
                gui: <[bookshelfGui]>
                players: <server.flag[Bookshelves].deep_get[open.<context.location>.players].if_null[<list[]>].include[<player>]>

            - flag server Bookshelves.open.<context.location>:<[openShelfInfo]>

            - inventory open d:<server.flag[Bookshelves].deep_get[open.<context.location>.gui]>
            #- narrate format:debug <server.flag[Bookshelves].deep_get[open.<context.location>.gui]>

            - flag <player> BookshelfItems:!

        on player breaks bookshelf:
        - if <server.flag[Bookshelves].get[<context.location>].exists>:
            - define loc <context.location>
            - drop <server.flag[Bookshelves].get[<[loc]>]> <player.flag[BookshelfLocation]>
            - flag server Bookshelves.<[loc]>:!

        on player clicks item in UsableBookshelf_GUI:
        - define bookTypes <list[book|written_book|book_and_quil|enchanted_book]>

        - if <context.clicked_inventory.script.name> == UsableBookshelf_GUI:
            #- narrate format:debug <context.click>

            - if <[bookTypes].contains[<context.cursor_item.material.name>].not> && <[bookTypes].contains[<context.item.material.name>].not>:
                - determine cancelled

            - else:
                - if <context.inventory.list_contents.size> != 0:
                    - flag server Bookshelves.<player.flag[BookshelfLocation]>:<context.inventory.list_contents>

                - define currentBookshelf <server.flag[Bookshelves].deep_get[open.<player.flag[BookshelfLocation]>]>

                - foreach <[currentBookshelf].get[players].exclude[<player>]> as:player:
                    - inventory clear d:<[player].open_inventory> player:<[player]>
                    - inventory set d:<[player].open_inventory> origin:<server.flag[Bookshelves].get[<player.flag[BookshelfLocation]>]> player:<[player]>

        - else if <context.click.is_in[SHIFT_LEFT|SHIFT_RIGHT|DOUBLE_CLICK]>:
            - if !<[bookTypes].contains[<context.cursor_item.material.name>]> && !<[bookTypes].contains[<context.item.material.name>]>:
                - determine cancelled

        on player closes UsableBookshelf_GUI:
        - if <context.inventory.list_contents.size> != 0:
            - flag server Bookshelves.<player.flag[BookshelfLocation]>:<context.inventory.list_contents>

        - else:
            - flag server Bookshelves.<player.flag[BookshelfLocation]>:<list[]>

        - flag server Bookshelves.open.<player.flag[BookshelfLocation]>.players:<-:<player>

        - if <server.flag[Bookshelves].deep_get[open.<player.flag[BookshelfLocation]>.players].size> == 0:
            - flag server Bookshelves.open.<player.flag[BookshelfLocation]>:!

        - flag <player> BookshelfLocation:!

BookshelfClone:
    type: procedure
    #definitions: inventoryName
    script:
    - define tempTradeInv <inventory[UsableBookshelf_GUI]>

    - determine <[tempTradeInv]>