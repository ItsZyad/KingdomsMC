OLD_FixSplitList_CISK:
    type: task
    definitions: line
    script:
    - define rawWords <[line].split[<&sp>]>
    - define words <list[]>

    - foreach <[rawWords]> as:word:
        # Link to regex101 testing for this sequence: https://regex101.com/r/S06D4w/1
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
    #- define text "<element[[dataget t:player n:[dataget t:player n:ref]]]>"
    - define text "<element[[give i:stick to_inv q:1]]>"
    - run SplitKeep def.text:<[text]> "def.delimiters:<list[<&rb>|<&lb>|<&co>| ]>" def.splitType:seperate save:split
    - define splitted <entry[split].created_queue.determination.get[1].filter_tag[<[filter_value].regex_matches[\s*].not>].parse_tag[<[parse_value].trim>]>

    script:
    - inject <script.name> path:DEBUG_GenerateSplittedList if:<[splitted].exists.not>
    - define commandMap <map[]>
    - define totalLoops 0
    - define player <player[ZyadTheBoss]>

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

        - else if <[token]> != <&sp> && <[prevToken]> != <&co> && <[nextToken]> != <&co> && <[commandMap.name]> != <[token]>:
            - narrate format:debug TOKEN:<[token]>
            - define commandMap.attributes:->:<map[<[token]>=null]>

        - define totalLoops:++

    - determine <map[commandMap=<[commandMap]>;totalLoops=<[totalLoops]>]>


CommandDelegator_CISK:
    type: task
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
                - define attrKey <[attrKeyRaw]>
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

    - determine <[data]>

    script:
    - choose <[attrKey]>:
        - case target:
            - define dataTarget <[attrVal]>

        - case name:
            - define dataName <[attrVal]>


DatastoreCommand_CISK:
    type: task
    commandData:
        attributeSubs:
            target: t|tr
            name: n
            value: v

    PostEvaluationCode:
    - run ProduceFlaggableObject_CISK def.text:<[dataTarget]> save:realTarget
    - define realTarget <entry[realTarget].created_queue.determination.get[1]>
    - flag <[realTarget]> KQuests.data.<[dataName]>.value:<[dataValue]>

    script:
    - choose <[attrKey]>:
        - case target:
            - define dataTarget <[attrVal]>

        - case name:
            - define dataName <[attrVal]>

        - case value:
            - define dataValue <[attrVal]>


BreakCommand_CISK:
    type: task
    PostEvalutionCode:
    - determine cancelled

    script:
    - define hasBroken true


GotoCommand_CISK:
    type: task
    PostEvaluationCode:
    - define playerDefinedBlock <yaml[ciskFile].read[<[schema]>.branches.<[gotoBranch]>]>
    - define currentBlock_orig <[currentBlock]>
    - define currentHandler <[playerDefinedBlock]>
    - define speech <[currentHandler].get[actions]>
    - define talkSpeed <[currentHandler].get[talkSpeed].if_null[1]>

    - inject SpeechHandler_CISK

    - define currentHandler <[currentBlock_orig]>
    - determine cancelled

    script:
    - choose <[attrKey]>:
        - default:
            - define gotoBranch <[attrKey]>


GiveCommand_CISK:
    type: task
    commandData:
        attributeSubs:
            item: i
            quantity: q

    PostEvaluationCode:
    - if <[giveType]> == as_drop:
        - drop <[giveItem].as[item]> quantity:<[giveQuantity]> <[npc].as[entity].location.forward[1]>

    - else:
        - give <[giveItem].as[item]> quantity:<[giveQuantity]> to:<[player].inventory>

    script:
    - choose <[attrKey]>:
        - case item:
            - define giveItem <[attrVal]>

        - case quantity:
            - define giveQuantity <[attrVal]>

        - default:
            - if <[attrKey].is_in[as_drop|to_inv]>:
                - define giveType <[attrKey]>


StateCommand_CISK:
    type: task
    commandData:
        attributeSubs:
            item: i
            player: p
            npc: n

    PostEvalutionCode:
    # This command should probably be its own file...
    - narrate format:debug WIP

    script:
    - choose <[attrKey]>:
        - case server:
            - if <[stateAction].exists>:
                - define stateTarget <[attrVal]>

        - default:
            - if <[attrKey].is_in[get|set]>:
                - define stateAction <[attrKey]>

            - else if <[attrKey].is_in[player|npc|item]>:
                - define stateTarget <[attrVal]>

            - else if <[stateAction]> == set && <[stateTarget].exists>:
                - define stateMechanismSet <[attrVal]>

            - else:
                - if <[attrVal].exists>:
                    - define stateMechanism <[attrVal]>

                - else:
                    - define stateMechanism <[attrKey]>

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