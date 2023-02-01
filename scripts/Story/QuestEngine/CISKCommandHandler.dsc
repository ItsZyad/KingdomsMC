OLD_FixSplitList_CISK:
    type: task
    definitions: line
    script:
    - define rawWords <[line].split[<&sp>]>
    - define words <list[]>

    - foreach <[rawWords]> as:word:
        - if <[word].contains[regex:(?<&lt>!\\)\<&lb>]> || <[word].contains[regex:(?<&lt>!\\)\<&rb>]>:
            - define letters <[word].split[regex:\<&lb>|\<&rb>]>
            - define brackets <[word].to_list.filter_tag[<[filter_value].is_in[<&lb>|<&rb>]>]>
            - define words <[words].include[<[brackets]>]>

        - define words:->:<[word]>

    - determine <[words]>


OLD_GRS_CISK:
    type: task
    definitions: list
    script:
    - define commandList <list[]>
    - define inCommand false
    - define commandCount 0

    - foreach <[list]> as:word:
        - narrate format:debug <[word]>

        - if <[word]> == <&lb>:
            - narrate format:debug OPEN_BRAC:<[list].get[<[loop_index].add[1]>].to[last]>

            - run GenerateRecursiveStructres_CISK def.list:<[list].get[<[loop_index].add[1]>].to[last]> save:recurList
            - define returnedList <entry[recurList].created_queue.determination.get[1]>
            - define commandList <[commandList].include_single[<[returnedList]>]>

        - else if <[word]> == <&rb>:
            - determine <[commandList]>

        - else:
            - define commandList:->:<[word]>

    # - narrate format:debug <[commandList]>


GenerateRecursiveStructres_CISK:
    type: task
    definitions: splitted
    DEBUG_GenerateSplittedList:
    - define text "<element[[dataget t:player n:[dataget t:player n:ref]]]>"
    - run SplitKeep def.text:<[text]> "def.delimiters:<list[<&rb>|<&lb>|<&co>| ]>" def.splitType:seperate save:split
    - define splitted <entry[split].created_queue.determination.get[1].filter_tag[<[filter_value].regex_matches[\s*].not>].parse_tag[<[parse_value].trim>]>

    script:
    - inject <script.name> path:DEBUG_GenerateSplittedList if:<[splitted].exists.not>
    - define commandMap <map[]>
    - define totalLoops 0

    - foreach <[splitted]> as:token:
        - define prevToken <[splitted].get[<[loop_index].sub[1]>]>
        - define nextToken <[splitted].get[<[loop_index].add[1]>]>

        - if <[loop_index]> < <[skipAmount].if_null[<[loop_index]>]>:
            - foreach next

        - if <[token]> == <&lb>:
            - define commandMap.name:<[nextToken]>

        - else if <[token]> == <&rb>:
            - foreach stop

        - else if <[token]> == <&co>:
            - if <[nextToken]> != <&lb>:
                - define commandMap.attributes:->:<map[<[prevToken]>=<[nextToken]>]>

            - else:
                - run <script.name> def.splitted:<[splitted].get[<[loop_index].add[1]>].to[last]> save:recur_split
                - define nestedCommand <entry[recur_split].created_queue.determination.get[1].get[commandMap]>
                - define skipAmount <entry[recur_split].created_queue.determination.get[1].get[totalLoops].add[<[loop_index]>]>
                - define commandMap.attributes:->:<map[<[prevToken]>=<[nestedCommand]>]>

        - define totalLoops:++

    - determine <map[commandMap=<[commandMap]>;totalLoops=<[totalLoops]>]>


CommandDelegator_CISK:
    type: task
    definitions: line
    GetRecursiveStructure:
    - run GenerateRecursiveStructres_CISK save:command_map
    - define commandMap <entry[command_map].created_queue.determination.get[1].get[commandMap]>

    GenerateAttributeShorthands:
    - define invertedMap <map[]>

    - foreach <[commandScript].data_key[commandData.attributeSubs]> as:subList key:key:
        - foreach <[subList].as[list]> as:sub:
            - define invertedMap.<[sub]>:<[key]>

    script:
    - inject <script.name> path:GetRecursiveStructure if:<[commandMap].exists.not>
    - define commandName <[commandMap].get[name]>
    - define commandScript <script[<[commandName]>Command_CISK]>

    - inject <script.name> path:GenerateAttributeShorthands if:<[commandScript].data_key[commandData.attributeSubs].exists>
    #- run <[commandScript].name> def.commandMap:<[commandMap]> def.attrSubs:<[invertedMap]> save:command

    - define attrSubs <[invertedMap]>

    - foreach <[commandMap]> key:datapoint:
        - if <[datapoint]> == attributes:
            - foreach <[value]> as:attrPair:
                - define attrKeyRaw <[attrPair].keys.get[1]>
                - define attrKey <[attrSubs].get[<[attrKeyRaw]>]> if:<[attrSubs].contains[<[attrKeyRaw]>]>
                - define attrVal <[attrPair].values.get[1]>

                - narrate format:debug ATTR_KEY:<[attrKey]>
                - narrate format:debug ATTR_VAL:<[attrVal]>

                - if <[attrVal].as[map]> == <[attrVal]>:
                    - run CommandDelegator_CISK def.commandMap:<[attrVal]> save:recur

                    - define nestedCommandResult <entry[recur].created_queue.determination.get[1]>
                    - define attrVal <[nestedCommandResult]>
                    - define commandMap.<[datapoint]>:<-:<[attrPair]>
                    - define commandMap.<[datapoint]>:->:<map[<[attrKey]>=<[nestedCommandResult]>]>

                - inject <[commandScript].name>

    - inject <[commandScript].name> path:PostEvaluationCode


ProduceFlaggableObject_CISK:
    type: task
    definitions: text
    script:
    - choose <[text]>:
        - case player:
            - determine <player>

        - case npc:
            - determine <npc>

        - default:
            - if <[text].starts_with[item]>:
                - define itemRef <[text].split[@].get[2]>
                - determine <item[<[itemRef]>]>


DatagetCommand_CISK:
    type: task
    commandData:
        attributeSubs:
            target: t|tr
            name: n

    PostEvaluationCode:
    - run ProduceFlaggableObject_CISK def.text:<[dataTarget]> save:realTarget
    - define realTarget <entry[realTarget].created_queue.determination.get[1]>
    - define data <[realTarget].flag[KQuests.data.<[dataName]>.value]>

    ## This is just for debugging purposes
    - define data <[realTarget].flag[dataHold.<[dataName]>]>

   # - run flagvisualizer def.flag:<[commandMap]> def.flagName:CommandMap

    # - narrate format:debug COMM_MAP:<[commandMap]>
    # - narrate format:debug DATA_TAR:<[dataTarget]>
    # - narrate format:debug REAL_TAR:<[realTarget]>
    # - narrate format:debug DATA_NAME:<[dataName]>
    # - narrate format:debug DATA:<[data]>
    # - narrate format:debug ======================

    - determine <[data]>

    script:
    - choose <[attrKey]>:
        - case target:
            - define dataTarget <[attrVal]>

        - case name:
            - define dataName <[attrVal]>


OLD_DatagetCommand_CISK:
    type: task
    definitions: commandMap|attrSubs
    commandData:
        attributeSubs:
            target: t|tr
            name: n
    script:
    - define dataTarget null
    - define dataName null

    - foreach <[commandMap]> key:datapoint:
        - if <[datapoint]> == attributes:
            - foreach <[value]> as:attrPair:
                - define attrKeyRaw <[attrPair].keys.get[1]>
                - define attrKey <[attrSubs].get[<[attrKeyRaw]>]> if:<[attrSubs].contains[<[attrKeyRaw]>]>
                - define attrVal <[attrPair].values.get[1]>

                - narrate format:debug ATTR_KEY:<[attrKey]>
                - narrate format:debug ATTR_VAL:<[attrVal]>

                - if <[attrVal].as[map]> == <[attrVal]>:
                    ## Replace w/NestedCommandHandler later
                    - run DatagetCommand_CISK def.commandMap:<[attrVal]> def.attrSubs:<[attrSubs]> save:recur
                    - define nestedCommandResult <entry[recur].created_queue.determination.get[1]>
                    - define attrVal <[nestedCommandResult]>
                    - define commandMap.<[datapoint]>:<-:<[attrPair]>
                    - define commandMap.<[datapoint]>:->:<map[<[attrKey]>=<[nestedCommandResult]>]>

                - choose <[attrKey]>:
                    - case target:
                        - define dataTarget <[attrVal]>

                    - case name:
                        - define dataName <[attrVal]>

        - narrate format:debug ----------------

    - run ProduceFlaggableObject_CISK def.text:<[dataTarget]> save:realTarget
    - define realTarget <entry[realTarget].created_queue.determination.get[1]>
    - define data <[realTarget].flag[KQuests.data.<[dataName]>.value]>
    ## This is just for debugging purposes
    - define data <[realTarget].flag[dataHold.<[dataName]>]>
   # - run flagvisualizer def.flag:<[commandMap]> def.flagName:CommandMap
    - narrate format:debug COMM_MAP:<[commandMap]>

    - narrate format:debug DATA_TAR:<[dataTarget]>
    - narrate format:debug REAL_TAR:<[realTarget]>
    - narrate format:debug DATA_NAME:<[dataName]>
    - narrate format:debug DATA:<[data]>
    - narrate format:debug ======================

    - determine <[data]>