# Why tf did this take me two hours to figure out?

CommaAdder:
    type: procedure
    definitions: number
    script:
    - if <[number].length.is[MORE].than[3]>:
        - define splitNum <list>
        - define newList <list>
        - define index 0

        - repeat <[number].length>:
            - if <[number].char_at[<[value]>].is_integer>:
                - define splitNum:->:<[number].char_at[<[value]>]>

            - else:
                - determine <[number]>

        - repeat <[splitNum].size>:
            - define index <[splitNum].size.sub[<[value].sub[1]>]>

            #- narrate format:debug "value: <[value]>"
            #- narrate format:debug "val @: <[splitNum].get[<[index]>]>"
            #- narrate format:debug ------

            - define newList:->:<[splitNum].get[<[index]>]>

            - if <[value].mod[3]> == 0 && <[value]> != 0 && <[value]> != <[splitNum].size>:
                - define newList:->:,

        - determine <[newList].reverse.unseparated>

    - determine <[number]>