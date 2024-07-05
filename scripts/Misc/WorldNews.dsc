##
## File containing the scripts related to the world news interface accessible through /news
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jan 2023
## @Script Ver: INDEV
##
## ----------------END HEADER-----------------


WorldNews_Command:
    type: command
    name: news
    usage: /news add|remove [inhand]|ID [expiry]|... [title]|... [description]|...
    description: Admin command for managing world news
    permissions: kingdoms.admin.news
    tab complete:
    - define args <context.raw_args.split_args>

    - if <[args].size> == 0:
        - determine <list[add|remove|open]>

    - choose <[args].get[1]>:
        - case add:
            - choose <[args].size>:
                - case 1:
                    - determine <list[inhand]>

                - case 2:
                    - determine <list[[expiry]]>

                - case 3:
                    - determine <list[[title]]>

                - case 4:
                    - determine <list[[subtitle]]>

                - case 5:
                    - determine <list[[kingdoms]]>

    script:
    - define args <context.raw_args.split_args>
    - define action <[args].get[1]>

    - choose <[action]>:
        - case open:
            - flag <player> dataHold.viewingNews
            - run MailboxViewer def.player:<player>

        - case add:
            - if <[args].get[2]> == inhand:
                - if <player.item_in_hand.material.name> == written_book:
                    - if <[args].size> < 3:
                        - narrate format:admincallout "You must specify an expiry date for this news snippet.<n>You may write <element[null].color[red]> for no expiry"
                        - determine cancelled

                    - define bookContent <player.item_in_hand.book_pages>
                    - define expiry <[args].get[3].as[duration].if_null[null]>
                    - define title <[args].get[4]>
                    - define subtitle <[args].get[5].if_null[<list[]>]>
                    - define targetKingdoms <[args].get[6].split[,].if_null[<list[all]>]>

                    - define title <player.item_in_hand.book_title> if:<[title].length.equals[0]>
                    - define subtitle <list[]> if:<[subtitle].length.equals[0]>
                    - define targetKingdoms <list[all]> if:<[targetKingdoms].length.equals[0]>

                    - define newsID <server.flag[news.articles].last.get[newsID].if_null[0].add[1]>

                    - definemap newNews:
                        content: <[bookContent].utf8_encode.gzip_compress>
                        title: <[title]>
                        subtitle: <[subtitle]>
                        expiry: <[expiry]>
                        kingdoms: <[targetKingdoms]>
                        newsID: <[newsID]>

                    - flag server news.articles:->:<[newNews]>
                    - narrate format:admincallout "Added news article."

                - else:
                    - narrate format:admincallout "The item to add to the news list must be of type: <underline>book"

        - case remove:
            - define newsID <[args].get[2]>

            - if !<[newsID].exists>:
                - narrate format:admincallout "You must provide a Temp. News ID corresponding to the article you want to remove."
                - determine cancelled

            - define article <server.flag[news.articles].filter_tag[<[filter_value].get[newsID].equals[<[newsID]>]>]>
            - flag server news.articles:<server.flag[news.articles].exclude[<[article]>].max[1]>

            - narrate format:admincallout "Removed news article with ID: <[newsID]>"


Letter_Command:
    type: command
    name: letter
    usage: /letter [kingdom] [unsigned] ?[title]
    description: Admin command for managing world news
    permissions: kingdoms.admin.news
    tab complete:
    - define args <context.raw_args.split_args>

    - choose <[args].size>:
        - case 0:
            - determine <proc[GetKingdomList].exclude[<player.flag[kingdom]>]>

        - case 1:
            - determine <list[true|false]>

        - case 2:
            - determine <list[?[title]]>

    script:
    - define args <context.raw_args.split_args>
    - define kingdom <[args].get[1]>
    - define isUnsigned <[args].get[2]>
    - define title <[args].get[3].if_null[null]>

    - if !<[kingdom].proc[ValidateKingdomCode]>:
        - narrate format:callout <element[The provided kingdom: <[kingdom].color[red]> is not a valid kingdom!]>
        - stop

    - if !<player.item_in_hand.material.name.is_in[written_book|writable_book]>:
        - narrate format:callout <element[The item in your hand must be a valid book item!]>
        - stop

    - if !<[isUnsigned].is_boolean>:
        - define isUnsigned false

    - define author <player.name>

    - if <[isUnsigned]>:
        - define author Unknown

    - define bookContent <player.item_in_hand.book_pages>
    - define expiry <duration[72h]>
    - define subtitle <element[A letter from a neighbouring kingdom]>
    - define title <player.item_in_hand.book_title.if_null[Letter]> if:<[title].equals[null]>
    - define letterID <server.flag[letters.articles].last.get[letterID].if_null[0].add[1]>

    - definemap newLetter:
        content: <[bookContent].utf8_encode.gzip_compress>
        title: <[title]>
        subtitle: <[subtitle]>
        expiry: <[expiry]>
        kingdom: <[kingdom]>
        originKingdom: <player.flag[kingdom]>
        letterID: <[letterID]>
        author: <[author]>

    - flag server letters.articles:->:<[newLetter]>
    - narrate format:callout "Sent letter to: <[kingdom].proc[GetKingdomShortName]>."

    - take from:<player.inventory> o:<player.item_in_hand>


NewsArticle_Item:
    type: item
    material: player_head
    display name: <white><bold>News Article
    mechanisms:
        skull_skin: b435f748-a357-4c58-b63b-d585765374b5|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZTgyNTQxOWU0MjlhZmMwNDBjOWU2OGIxMDUyM2I5MTdkN2I4MDg3ZDYzZTc2NDhiMTA4MDdkYThiNzY4ZWUifX19


EmptyNews_Item:
    type: item
    material: player_head
    display name: <gray><bold>No News or Letters Found
    mechanisms:
        skull_skin: c42fe8de-3315-435b-a911-2fd93aabd58c|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvODhhZTdlOGVhOGRkNWZmOGRlM2MzNjEwYTFjMWI2M2U4MGI3ZGRiZGRmZDUzMTRkZjNiYjhhYjQ4ZmZiNyJ9fX0=


MailboxViewer:
    type: task
    definitions: player
    script:
    - define containsRelevantArticles <server.flag[letters.articles].if_null[<list[]>].filter_tag[<[filter_value].get[kingdom].equals[<[player].flag[kingdom]>]>].is_empty.not>
    - define containsRelevantNews <server.flag[news.articles].if_null[<list[]>].filter_tag[<[filter_value].get[kingdoms].contains[<[player].flag[kingdom]>]>].is_empty.not>

    - if !<[containsRelevantArticles]> && !<[containsRelevantNews]>:
        - define itemList <list[<item[EmptyNews_Item]>]>

    - else:
        - define newsList <server.flag[news.articles].if_null[<list[]>].include[<server.flag[letters.articles].if_null[<list[]>]>]>
        - define itemList <list[]>
        - define newsItem <item[NewsArticle_Item]>

        - foreach <[newsList]> as:article:
            - if <[article].get[kingdoms].if_null[<list[all]>].get[1]> == all || <[article].get[kingdoms].contains[<[player].flag[kingdom]>]>:
                - adjust def:newsItem display:<white><bold><[article].get[title]>
                - flag <[newsItem]> articleData:<[article].exclude[content]>
                - flag <[newsItem]> articleData.content:<[article].get[content].gzip_decompress.utf8_decode.as[list]>
                - flag <[newsItem]> articleData.originalFlag:<[article]>

                - if <[article].get[subtitle].size> != 0:
                    - adjust def:newsItem lore:<[article].get[subtitle].italicize>

                - adjust def:newsItem lore:<[newsItem].lore.include[<element[<n><gold><bold>Right click to retrieve from the mailbox]>]>

                - if <[player].is_op> || <player.has_permission[kingdoms.admin]>:
                    - adjust def:newsItem lore:<[newsItem].lore.include[<dark_gray><element[Temporary Article ID: #<[article].get[newsID].if_null[<[article].get[letterID]>]>]>]>

                - define itemList:->:<[newsItem]>

    - run PaginatedInterface def.itemList:<[itemList]> def.page:1 def.player:<[player]> def.title:News


WorldNewsInterface_Handler:
    type: world
    events:
        on player left clicks NewsArticle_Item in PaginatedInterface_Window flagged:dataHold.viewingNews:
        - define virtualBook <item[written_book]>

        - adjust def:virtualBook book_pages:<context.item.flag[articleData].get[content]>
        - adjust def:virtualBook book_title:null
        - adjust def:virtualBook book_author:null
        - inventory close
        - adjust <player> show_book:<[virtualBook]>

        on player right clicks NewsArticle_Item in PaginatedInterface_Window flagged:dataHold.viewingNews:
        - if <context.item.flag[articleData].contains[letterID]>:
            - define bookItem <item[written_book]>
            - adjust def:bookItem book_pages:<context.item.flag[articleData].get[content]>
            - adjust def:bookItem book_title:<context.item.flag[articleData].get[title]>
            - adjust def:bookItem book_author:<context.item.flag[articleData].get[author]>
            - adjust def:bookItem lore:<element[From: <context.item.flag[articleData].get[originKingdom].proc[GetKingdomShortName]>].color[gray].italicize>

            - give to:<player.inventory> o:<[bookItem]>

            - flag server letters.articles:<-:<context.item.flag[articleData].get[originalFlag]>
            - inventory close
            - run MailboxViewer def.player:<player>

        on custom event id:PaginatedInvClose flagged:dataHold.viewingNews:
        - flag <player> dataHold.viewingNews:!


Mailbox_Item:
    type: item
    material: chest
    display name: <gold><bold>Mailbox
    recipes:
        1:
            type: shaped
            input:
            - material:*_planks|material:*_planks|material:*_planks
            - material:paper|chest|material:paper
            - material:*_planks|material:*_planks|material:*_planks


Mailbox_Handler:
    type: world
    events:
        on player places Mailbox_Item:
        - flag <context.location> mailbox:<player.flag[kingdom]>

        on player breaks chest location_flagged:mailbox:
        - flag <context.location> mailbox:!

        on player right clicks chest location_flagged:mailbox:
        - ratelimit <player> 2t
        - determine passively cancelled

        - if <player.flag[kingdom]> == <context.location.flag[mailbox]> || <player.has_permission[kingdoms.admin.mailbox]>:
            - flag <player> dataHold.viewingNews
            - run MailboxViewer def.player:<player>

        - else:
            - narrate format:callout "You cannot open another kingdom's mailbox!"
