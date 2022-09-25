FileFetcher:
    type: command
    name: fetch
    usage: /fetch
    description: Fetches a text file to be converted into a minecraft book
    permission: kingdoms.admin.fetchtext
    tab completions:
        1: clear|info|fileName
    script:
    - if <context.args.get[1]> == clear:
        - if <player.has_flag[fetchedText]>:
            - flag player fetchedText:!

        - else:
            - narrate format:admincallout "You have not fetched any text file yet."

    - else if <context.args.get[1]> == info:
        - if <player.has_flag[fetchedText]>:
            - narrate format:admincallout "You currently have the following text file loaded: <aqua><player.flag[fetchedText]>"

        - else:
            - narrate format:admincallout "You have no file loaded."

    - else:
        - if <context.args.get[1].ends_with[.txt]>:
            - define fileName <context.args.get[1]>

            - if <server.has_file[story_texts/<[fileName]>]>:
                - flag player fetchedText:<[fileName]>

                - narrate format:admincallout "Fetched <aqua><[fileName]><light_purple>!"

            - else:
                - narrate format:admincallout "That file does not exist!"

        - else:
            - narrate format:admincallout "You can only use this command to load text files."

ParseBook:
    type: command
    name: parsebook
    usage: /parsebook
    description: "Turns a string of plain text into one that is formatted like a minecraft book using Denizen lists."
    # If another use is designed for the fetch command, make a
    # different permission node for this command
    permission: kingdoms.admin.fetchtext
    tab completions:
        1: withfile|textHere
        2: author
        3: title
    script:
    - if <context.args.size> != 0:
        - define param <context.args.get[1]>
        - define author <context.args.get[2]>
        - define titleUnformatted <context.args.get[3].to[last]>
        - define title <[titleUnformatted].space_separated>

        - if <[param]> == withfile:
            - narrate format:debug <player.flag[fetchedText]>

            - yaml load:<player.flag[fetchedText]> id:file
            - define text <yaml[file].parsed_key[].get[null]>

            - define book <item[written_book[book_author=<[author]>;book_title=<[title]>;book_pages=<list[<[text]>]>]]>

            - give item:<[book]>

            - yaml id:file unload