##ignorewarning invalid_data_line_quotes

NPCLevelProgress:
    type: procedure
    definitions: level
    script:
    - define justDecimal <[Level].round_down.sub[<[Level]>].abs.mul[100]>
    - define levelGraphic <list>

    - repeat <[justDecimal].div[5].round_to_precision[5]>:
        - define levelGraphic:->:█

    - repeat <element[20].sub[<[justDecimal].div[5].round_to_precision[5]>]>:
        - define levelGraphic:->:░

    - determine "<[levelGraphic].unseparated> - <[justDecimal].round_to_precision[0.01]><&pc>"


KingdomNameReplacer:
    type: procedure
    definitions: playerKingdom
    script:
    - determine passively <proc[YamlSpaceAdder].context[<script[KingdomRealNames].data_key[<[playerKingdom]>]>]>

YamlSpaceAdder:
    type: procedure
    definitions: yamlVal
    script:
    - determine <definition[yamlVal].replace[/sp/].with[<&sp>]>

YamlSpaceSerilizer:
    type: procedure
    definitions: Val
    script:
    - determine <definition[Val].replace[<&sp>].with[/sp/]>

Paginate:
    type: procedure
    definitions: itemArrayMap|itemsPerPage|page
    script:
    - define outArray <list>
    - define startPoint <element[<[page]>].mul[<[itemsPerPage]>]>

    - define itemArray <[itemArrayMap].get[items]>

    - narrate format:debug ARR:<[itemArray]>

    - repeat <[itemsPerPage]>:
        - if <[itemArray].size.is[LESS].than[<[value]>]>:
            - define outArray:->:<[itemArray].get[<element[<[value]>].add[<[startPoint]>]>]>
            - narrate format:debug <[itemArray].get[<element[<[value]>].add[<[startPoint]>]>]>

        - else:
            - repeat stop

    - determine <[outArray]>

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

Page_Forward:
    type: item
    material: player_head
    display name: "Next Page"
    mechanisms:
        skull_skin: 925b071a-7c83-43e7-9d83-8f231c8217d4|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZjJmM2EyZGZjZTBjM2RhYjdlZTEwZGIzODVlNTIyOWYxYTM5NTM0YThiYTI2NDYxNzhlMzdjNGZhOTNiIn19fQ==

Page_Back:
    type: item
    material: player_head
    display name: "Previous Page"
    mechanisms:
        skull_skin: 2fad8146-186b-4c9c-8c62-7d5ccb083faa|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYmIwZjZlOGFmNDZhYzZmYWY4ODkxNDE5MWFiNjZmMjYxZDY3MjZhNzk5OWM2MzdjZjJlNDE1OWZlMWZjNDc3In19fQ==

Main_Menu:
    type: item
    material: player_head
    display name: "Main Menu"
    mechanisms:
        skull_skin: 7e06b124-31bd-4163-b703-ac749b3d431d|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMTJkN2E3NTFlYjA3MWUwOGRiYmM5NWJjNWQ5ZDY2ZTVmNTFkYzY3MTI2NDBhZDJkZmEwM2RlZmJiNjhhN2YzYSJ9fX0=

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

## CREDIT:
## Mergu / Mergu#0001
CuboidIntersect:
  type: procedure
  debug: false
  definitions: c1|c2
  script:
    - define max_x <[c1].max.x.min[<[c2].max.x>]>
    - define max_y <[c1].max.y.min[<[c2].max.y>]>
    - define max_z <[c1].max.z.min[<[c2].max.z>]>
    - define min_x <[c1].min.x.max[<[c2].min.x>]>
    - define min_y <[c1].min.y.max[<[c2].min.y>]>
    - define min_z <[c1].min.z.max[<[c2].min.z>]>

    - determine <cuboid[<[c1].world.name>,<[min_x]>,<[min_y]>,<[min_z]>,<[max_x]>,<[max_y]>,<[max_z]>]>

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