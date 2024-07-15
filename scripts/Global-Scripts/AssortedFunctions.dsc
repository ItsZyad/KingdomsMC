##ignorewarning invalid_data_line_quotes

## No header will be added :: file slated for deletion or rework.

New_Paginate_Task:
    type: task
    definitions: itemList|itemsPerPage|page
    script:
    - define outList <list>
    - define highestStartPoint <[itemList].size.sub[<[itemsPerPage]>]>
    - define startPoint <[page].sub[1].mul[<[itemsPerPage]>]>

    #- narrate HIGHEST:<[highestStartPoint]>
    #- narrate START:<[startPoint]>

    - if <[startPoint].is[LESS].than[1]>:
        - define startPoint 1

    - else if <[startPoint].is[MORE].than[<[highestStartPoint]>]>:
        - define startPoint <[highestStartPoint]>

    - repeat <[itemsPerPage]> from:<[startPoint]>:
        - define outList:->:<[itemList].get[<[value]>]>

    - determine <[outList]>


Paginate_Task:
    ## HOW TO USE:
    # - run Paginate_Task ... save:paginate
    # - ... <entry[paginate].created_queue.determination.get[1]>

    type: task
    definitions: itemArray|itemsPerPage|page
    script:
    - define outArray <list>
    - define startPoint <[page].mul[<[itemsPerPage]>].sub[<[itemsPerPage]>].add[1]>

    - if <[page]> == 1 || <[page].is[LESS].than[1]>:
        - define startPoint 1

    - repeat <[itemsPerPage]> from:<[startPoint]>:
        - define outArray:->:<[itemArray].get[<[value]>]>

    - determine <[outArray]>


OutpostNameEscaper:
    type: procedure
    definitions: outpostName
    script:
    - define escaped <[outpostName].replace[<&sp>].with[-]>

    - determine <[escaped]>


isBetween:
    type: procedure
    definitions: value|num1|num2|inclusive
    script:
    - define comparison <list[MORE|LESS]>

    - if <[inclusive].if_null[true]>:
        - define comparison <list[OR_MORE|OR_LESS]>

    - if <[value].is[<[comparison].get[1]>].than[<[num1]>]> && <[value].is[<[comparison].get[2]>].than[<[num2]>]>:
        - determine true

    - determine false


SplitKeep:
    type: task
    debug: false
    definitions: text|delimiters|splitType
    script:
    - define letters <[text].to_list>
    - define originalSize <[letters].size>
    - define splitType <[splitType].if_null[inline]>
    - define delimiters <[delimiters].unescaped.as[list]>
    - define index 1

    - define outList <list[]>
    - define currentElem <list[]>

    # - narrate format:debug DELIMS:<[delimiters].last>

    - foreach <[letters]> as:letter:
        - if <[letter].is_in[<[delimiters]>]>:
            # - narrate format:debug VALID_DELIM:<[letter]>

            - if <[splitType]> == inline:
                - define currentElem:->:<[letter]>
                - define outList:->:<[currentElem].unseparated>

            - else if <[splitType]> == seperate:
                - define outList:->:<[currentElem].unseparated>
                - define outList:->:<[letter]>

            - define currentElem <list[]>

        - else:
            - define currentElem:->:<[letter]>

    - define outList:->:<[currentElem].unseparated>

    # - narrate format:debug <[outList]>
    - determine <[outList]>


ClearDatahold_Handler:
    type: world
    events:
        on player quits:
        - define persistentData <player.flag[datahold.persistent]> if:<player.has_flag[datahold.persistent]>
        - flag <player> datahold:!
        - flag <player> datahold.persistent:<[persistentData]> if:<player.has_flag[datahold.persistent]>


TempSaveInventory:
    type: task
    debug: false
    definitions: player
    script:
    - if !<[player].has_flag[inventory_hold_outposts]>:
        - repeat 36:
            - flag <[player]> inventory_hold_outposts:->:<[player].inventory.slot[<[value]>]>
            - inventory set slot:<[value]> origin:<item[air]>


LoadTempInventory:
    type: task
    debug: false
    definitions: player
    script:
    - if <player.has_flag[inventory_hold_outposts]>:
        - repeat 36:
            - inventory set slot:<[value]> origin:<[player].flag[inventory_hold_outposts].get[<[value]>]>

        - flag <[player]> inventory_hold_outposts:!


Invert:
    type: procedure
    debug: false
    definitions: number[ElementTag(Float)]
    description:
    - Makes positive numbers negative and makes negative numbers positive.
    - ---
    - → [ElementTag(Float)]

    script:
    - determine <[number].sub[<[number].mul[2]>]>

##ignorewarning bad_execute
AffectOfflinePlayers:
    type: task
    definitions: playerList[ListTag(PlayerTag)]|scriptName[ElementTag(String)]|otherDefs[MapTag]|scriptPath[?ElementTag(String)]
    description:
    - Divides the provided playerList def into two lists- one containing online players, and the other offline players.
    - It will then run the script with the provided name twice- once with the list of online players, and again each time one of the offline players joins.
    - In all cases, the definitions will be passed in under the name 'playerList'.
    - ---
    - → [Void]

    script:
    ## Divides the provided playerList def into two lists- one containing online players, and the
    ## other offline players.
    ##
    ## It will then run the script with the provided name twice- once with the list of online
    ## players, and again each time one of the offline players joins.
    ##
    ## In all cases, the definitions will be passed in under the name 'playerList'.
    ##
    ## playerList : [ListTag<PlayerTag>]
    ## scriptName : [ElementTag<String>]
    ## scriptPath : [ElementTag<String>]
    ##
    ## >>> [Void]

    - define onlinePlayers <[playerList].filter_tag[<[filter_value].is_online>]>
    - define offlinePlayers <[playerList].exclude[<[onlinePlayers]>]>
    - define runString <list[<element[run <[scriptName]>]>]>

    - foreach <[otherDefs].exclude[_playerList]> key:defName as:def:
        - define runString:->:<element[def.<[defName]>:<[def]>]>

    - if <[scriptPath].exists>:
        - define runString:->:<element[path:<[scriptPath]>]>

    - foreach <[offlinePlayers]> as:player:
        - flag server waitingForOfflinePlayer.<[player].uuid>:->:<[runString].space_separated>

    - execute as_server "ex <[runString].include[<element[def._playerList:<[onlinePlayers]>]>].space_separated>"


AffectOfflinePlayers_Handler:
    type: world
    events:
        on player joins:
        - if !<server.has_flag[waitingForOfflinePlayer.<player.uuid>]>:
            - stop

        - foreach <server.flag[waitingForOfflinePlayer.<player.uuid>]> as:runString:
            - execute as_server "ex <[runString].include[<element[def._playerList:<list[<player>]>]>]>"
