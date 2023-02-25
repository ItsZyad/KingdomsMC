GenerateRecursiveStructures_CISK:
    type: task
    debug: false
    definitions: splitted
    DEBUG_GenerateSplittedList:
    - define text "<element[something <&lt>state get player:<&lt>dataget t:player n:ref<&gt> location<&gt>]>"
    - run SplitKeep def.text:<[text]> "def.delimiters:<list[<&gt>|<&lt>|<&co>| ]>" def.splitType:seperate save:split
    - define splitted <entry[split].created_queue.determination.get[1].filter_tag[<[filter_value].regex_matches[\s*].not>].parse_tag[<[parse_value].trim>]>

    script:
    - inject <script.name> path:DEBUG_GenerateSplittedList if:<[splitted].exists.not>
    - define player <player[ZyadTheBoss]>
    - define persistent <map[]>
    - define lineList <list[]>
    - define totalLoops 0
    - define bracketDepth 0

    - foreach <[splitted]> as:token:
        - define prevToken <[splitted].get[<[loop_index].sub[1]>]>
        - define nextToken <[splitted].get[<[loop_index].add[1]>]>

        - if <[loop_index]> < <[persistent].get[commandSize].add[2].if_null[<[loop_index]>]>:
            - foreach next

        - if <[token]> == <&lt> && !<[prevToken].ends_with[\]>:
            - run CommandMapGenerator_CISK def.splitted:<[splitted].get[<[loop_index]>].to[last]> save:command
            - define persistent.commandMap <entry[command].created_queue.determination.get[1].get[commandMap]>
            - define persistent.commandSize <entry[command].created_queue.determination.get[1].get[commandSize]>

            - define lineList:->:<[persistent].get[commandMap]>

        - else:
            - define lineList:->:<[token]>

    - determine <[lineList]>


CommandMapGenerator_CISK:
    type: task
    debug: false
    definitions: splitted
    DEBUG_GenerateSplittedList:
    - define text "<element[<&lt>state get player:<&lt>dataget t:player n:ref<&gt> location<&gt>]>"
    - run SplitKeep def.text:<[text]> "def.delimiters:<list[<&gt>|<&lt>|<&co>| ]>" def.splitType:seperate save:split
    - define splitted <entry[split].created_queue.determination.get[1].filter_tag[<[filter_value].regex_matches[\s*].not>].parse_tag[<[parse_value].trim>]>

    script:
    - define commandSize 0
    - define commandMap <map[]>
    - define persistent <map[]>

    - inject <script.name> path:DEBUG_GenerateSplittedList if:<[splitted].exists.not>

    - foreach <[splitted]> as:token:
        - define prevToken <[splitted].get[<[loop_index].sub[1]>]>
        - define nextToken <[splitted].get[<[loop_index].add[1]>]>
        - define commandSize:++

        - if <[loop_index]> < <[persistent].get[skipAmount].add[1].if_null[<[loop_index]>]>:
            - foreach next

        - if <[token]> == <&lt> && !<[prevToken].ends_with[\]>:
            - define commandMap.name:<[nextToken]>

        - else if <[token]> == <&co>:
            - if <[nextToken]> != <&lt>:
                - define commandMap.attributes:->:<map[<[prevToken]>=<[nextToken]>]>

            - else:
                - run CommandMapGenerator_CISK def.splitted:<[splitted].get[<[loop_index].add[1]>].to[last]> save:recur_split
                - define nestedCommand <entry[recur_split].created_queue.determination.get[1].get[commandMap]>
                - define persistent.skipAmount <entry[recur_split].created_queue.determination.get[1].get[commandSize].add[<[loop_index]>]>
                - define commandMap.attributes:->:<map[<[prevToken]>=<[nestedCommand]>]>

                - foreach next

        - else if <[token]> != <&sp> && <[prevToken]> != <&co> && <[nextToken]> != <&co> && <[commandMap.name]> != <[token]> && !<[token].is_in[<&gt>|<&lt>]>:
            - define commandMap.attributes:->:<map[<[token]>=null]>

        - else if <[token]> == <&gt>:
            - determine <map[commandMap=<[commandMap]>;commandSize=<[commandSize]>]>


CommandDelegator_CISK:
    type: task
    debug: false
    GetRecursiveStructure:
    - if <[splitted].exists>:
        - run GenerateRecursiveStructures_CISK def.splitted:<[splitted]> save:line

    - else:
        - run GenerateRecursiveStructures_CISK save:line

    - define line <entry[line].created_queue.determination.get[1]>

    script:
    - inject <script.name> path:GetRecursiveStructure if:<[commandMap].exists.not>
    - define evaluatedLine <list[]>
    - define player <player[ZyadTheBoss]> if:<[player].exists.not>

    - adjust <queue> linked_player:<[player]>
    - adjust <queue> linked_npc:<[npc]> if:<[npc].exists>

    - foreach <[line]> as:token:
        - if <[token].as[map]> == <[token]>:
            - define commandMap <[token]>
            - define commandName <[commandMap].get[name]>
            - define commandScript <script[<[commandName]>Command_CISK]>

            - run CommandMapEvaluator_CISK defmap:<queue.definition_map> save:eval_commandMap
            - define commandResult <entry[eval_commandMap].created_queue.determination.get[1].if_null[N/A]>
            - define evaluatedLine:->:<[commandResult]> if:<[commandResult].equals[N/A].not>

        - else:
            - define evaluatedLine:->:<[token]>

    # - narrate format:debug <red>EVAL_LINE:<[evaluatedLine]>
    - determine <[evaluatedLine]>


CommandMapEvaluator_CISK:
    type: task
    debug: false
    definitions: commandMap|commandScript
    GenerateAttributeShorthands:
    - define attrSubs <map[]>

    - foreach <[commandScript].data_key[commandData.attributeSubs]> as:subList key:key:
        - foreach <[subList].as[list]> as:sub:
            - define attrSubs.<[sub]>:<[key]>

    script:
    - define commandName <[commandMap].get[name]>
    - define commandScript <[commandScript].if_null[<script[<[commandName]>Command_CISK]>]>
    - inject <script.name> path:GenerateAttributeShorthands if:<[commandScript].data_key[commandData.attributeSubs].exists>

    - foreach <[commandMap]> key:datapoint:
        - if <[datapoint]> == attributes:
            - foreach <[value]> as:attrPair:
                - define attrKeyRaw <[attrPair].keys.get[1]>
                - define attrKey <[attrKeyRaw]>
                - define attrKey <[attrSubs].get[<[attrKeyRaw]>]> if:<[attrSubs].contains[<[attrKeyRaw]>]>
                - define attrVal <[attrPair].values.get[1]>

                - if <[attrVal].as[map]> == <[attrVal]>:
                    - run CommandMapEvaluator_CISK def.commandMap:<[attrVal]> save:recur

                    - define nestedCommandResult <entry[recur].created_queue.determination.get[1]>
                    - define attrVal <[nestedCommandResult]>
                    - define commandMap.<[datapoint]>:<-:<[attrPair]>
                    - define commandMap.<[datapoint]>:->:<map[<[attrKey]>=<[nestedCommandResult]>]>

                - inject <[commandScript].name>

    - inject <[commandScript].name> path:PostEvaluationCode


ProduceFlaggableObject_CISK:
    type: task
    debug: false
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
    debug: false
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
    debug: false
    commandData:
        attributeSubs:
            target: t|tr
            name: n
            value: v

    PostEvaluationCode:
    - run ProduceFlaggableObject_CISK def.text:<[dataTarget]> save:realTarget
    - define realTarget <entry[realTarget].created_queue.determination.get[1]>
    - flag <[realTarget]> KQuests.data.<[dataName]>.value:<[dataValue]>

    # TODO: Add error check for this... And all of these commands for that fact.

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
    debug: false
    PostEvalutionCode:
    - determine cancelled

    script:
    - define hasBroken true


GotoCommand_CISK:
    type: task
    debug: false
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
    debug: false
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

    PostEvaluationCode:
    # - narrate format:debug S_ACT:<[stateAction]>
    # - narrate format:debug S_TAR:<[stateTarget]>
    # - narrate format:debug S_MEC:<[stateMechanism]>
    # - narrate format:debug S_MES:<[stateMechanismSet].if_null[N/A]>

    - inject StateCommandMechanisms_CISK

    script:
    - choose <[attrKey]>:
        - case server:
            - if <[stateAction].exists>:
                - define stateTarget <[attrVal]>

        - default:
            - if <[attrKey].is_in[get|set]>:
                - define stateAction <[attrKey]>

            - else if <[attrKey].is_in[player|npc|item]>:
                - if <[attrVal].exists>:
                    - define stateTarget <map[<[attrKey]>=<[attrVal]>]>

                - else:
                    - define stateTarget <map[<[attrKey]>=self]>

            - else if <[stateTarget].exists>:
                - if <[stateAction]> == set && !<[stateMechanism].exists>:
                    - define stateMechanism <[attrKey]>
                    - define stateMechanismSet <[attrVal]>

                - else:
                    - if <[attrVal]> == null:
                        - define stateMechanism <[attrKey]>

                    - else:
                        - define stateMechanism <[attrVal]>