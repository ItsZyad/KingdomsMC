FlagVisualizer:
    type: task
    definitions: flag|flagName|recursionDepth
    script:
    - define recursionDepth <[recursionDepth].if_null[0]>
    - define tabWidth <[recursionDepth].mul[4]>

    - if <[recursionDepth]> > 49:
        - narrate format:admincallout "Recursion depth exceeded 50! Killing queue: <script.queues.get[1]>"
        - determine cancelled

    - if <[flag].as[entity].exists>:
        - define name <[flag].name.color[aqua]>
        - define uuid <[flag].uuid>

        - determine passively "<[name]> <element[[uuid]].color[light_purple].on_hover[<[uuid].color[light_purple]>]>"

    - else if <[flag].time_zone_id.exists>:
        - define ESTTime <[flag].to_zone[America/New_York]>
        - define formattedTime <[ESTTime].format[YYYY-MM-dd/hh:mm]>

        - determine passively "<[flag].color[light_purple].on_hover[<[formattedTime]> UTC]>"

    - else if <[flag].as[map]> == <[flag]>:
        - narrate "<proc[MakeTabbed].context[<element[MAP :: <[flagName].color[green]> (Size: <[flag].size.color[yellow]>)].italicize.color[gray]>|<[tabWidth]>]>"

        - foreach <[flag]>:

            # # Ensures only 10 items are written from the map
            # # as to avoid chat spam
            # - if <[loop_index]> >= 10:
            #     - narrate "<proc[MakeTabbed].context[And <[flag].size.sub[10]> more...]>"
            #     - foreach stop

            - run FlagVisualizer def.flag:<[value]> def.flagName:<[key]> def.recursionDepth:<[recursionDepth].add[1]> save:Recur

            - if <entry[Recur].created_queue.determination.get[1].as[list].size> == 1:
                - define line "<list[<[key].color[aqua].italicize><&co> ]>"
                - define line:->:<entry[Recur].created_queue.determination.get[1].color[white]>
                - narrate <proc[MakeTabbed].context[<[line].unseparated>|<[tabWidth]>]>

    - else if <[flag].as[list]> == <[flag]>:
        - narrate "<proc[MakeTabbed].context[<element[LIST :: <[flagName].color[green]> (Size: <[flag].size.color[yellow]>)].italicize.color[gray]>|<[tabWidth]>]>"
        - define longestNumber <[flag].length>

        - foreach <[flag]>:

            # # Ensures only 20 items are written from the list
            # # as to avoid chat spam
            # - if <[loop_index]> >= 20:
            #     - narrate "<proc[MakeTabbed].context[And <[flag].size.sub[20]> more...]>"
            #     - foreach stop

            - run FlagVisualizer def.flag:<[value]> def.flagName:<&sp> def.recursionDepth:<[recursionDepth].add[1]> save:Recur

            - if <entry[Recur].created_queue.determination.get[1].as[list].size> == 1:
                - define formattedIndex <[loop_index].pad_left[<[longestNumber].length.sub[1]>].with[0]>
                - narrate "<proc[MakeTabbed].context[<element[<[formattedIndex].color[gray]>: <entry[Recur].created_queue.determination.get[1].color[white]>]>|<[tabWidth]>]>"

    - else:
        - determine passively <[flag]>

MakeTabbed:
    type: procedure
    definitions: element|tabLevel
    script:
    - define tabbedList "<list[<element[ ].repeat[<[tabLevel]>]>|<[element]>]>"
    - determine <[tabbedList].unseparated>