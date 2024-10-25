##
## Scripts in this file are responsible for handling CISK's inline commands, which are contained
## with angle brackets, like Denizen's.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Apr 2023
## @Script Ver: v2.0
##
## ------------------------------------------END HEADER-------------------------------------------

GenerateRecursiveStructures_CISK:
    type: task
    debug: false
    definitions: splitted[ListTag(ElementTag(String))]
    DEBUG_GenerateSplittedList:
    - define text <element[<&lt>state get player health<&gt>]>
    - run SplitKeep def.text:<[text]> "def.delimiters:<list[<&gt>|<&lt>|<&co>| ]>" def.splitType:seperate save:split
    - define splitted <entry[split].created_queue.determination.get[1].filter_tag[<[filter_value].regex_matches[\s*].not>].parse_tag[<[parse_value].trim>]>

    script:
    - inject <script.name> path:DEBUG_GenerateSplittedList if:<[splitted].exists.not>
    - define persistent <map[]>
    - define lineList <list[]>
    - define totalLoops 0
    - define bracketDepth 0

    - foreach <[splitted]> as:token:
        - define prevToken <[splitted].get[<[loop_index].sub[1]>]> if:<[loop_index].is[MORE].than[1]>
        - define nextToken <[splitted].get[<[loop_index].add[1]>]> if:<[loop_index].is[LESS].than[<[splitted].size>]>

        - define prevToken <element[]> if:<[loop_index].is[OR_LESS].than[1]>
        - define nextToken <element[]> if:<[loop_index].is[OR_MORE].than[<[splitted].size>]>

        - if <[loop_index]> < <[persistent].get[commandSize].add[2].if_null[<[loop_index]>]>:
            - foreach next

        - if <[token]> == <&lt> && !<[prevToken].ends_with[\]>:
            - run CommandMapGenerator_CISK def.splitted:<[splitted].get[<[loop_index]>].to[last]> save:command
            - define persistent.commandMap <entry[command].created_queue.determination.get[1].get[commandMap]>
            - define persistent.commandSize <entry[command].created_queue.determination.get[1].get[commandSize]>

            - define lineList:->:<[persistent].get[commandMap]>

        - else:
            - if <[token]> != <&gt>:
                - define lineList:->:<[token]>

    - determine <[lineList]>


CommandMapGenerator_CISK:
    type: task
    debug: false
    definitions: splitted[ListTag(ElementTag(String))]
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
        - define prevToken <[splitted].get[<[loop_index].sub[1]>]> if:<[loop_index].is[MORE].than[1]>
        - define nextToken <[splitted].get[<[loop_index].add[1]>]> if:<[loop_index].is[LESS].than[<[splitted].size>]>

        - define prevToken <element[]> if:<[loop_index].is[OR_LESS].than[1]>
        - define nextToken <element[]> if:<[loop_index].is[OR_MORE].than[<[splitted].size>]>

        - define commandSize:++

        - if <[loop_index]> < <[persistent].get[skipAmount].add[1].if_null[<[loop_index]>]>:
            - foreach next

        - else if <[token]> == <&co>:
            - if <[nextToken]> != <&lt>:
                - define commandMap.attributes:->:<map[<[prevToken]>=<[nextToken]>]>

            - else:
                - run CommandMapGenerator_CISK def.splitted:<[splitted].get[<[loop_index].add[1]>].to[last]> save:recur_split
                - define nestedCommand <entry[recur_split].created_queue.determination.get[1].get[commandMap]>
                - define persistent.skipAmount <entry[recur_split].created_queue.determination.get[1].get[commandSize].add[<[loop_index]>]>
                - define commandMap.attributes:->:<map[<[prevToken]>=<[nestedCommand]>]>

                - foreach next

        - else if <[token]> == <&lt> && !<[prevToken].ends_with[\]>:
            - if <[commandMap].get[name].exists>:
                - run CommandMapGenerator_CISK def.splitted:<[splitted].get[<[loop_index]>].to[last]> save:recur_split
                - define nestedCommand <entry[recur_split].created_queue.determination.get[1].get[commandMap]>
                - define persistent.skipAmount <entry[recur_split].created_queue.determination.get[1].get[commandSize].add[<[loop_index].sub[1]>]>
                - define commandMap.attributes:->:<map[null=<[nestedCommand]>]>

                - foreach next

            - else:
                - define commandMap.name:<[nextToken]>

        - else if <[token]> != <&sp> && <[prevToken]> != <&co> && <[nextToken]> != <&co> && <[commandMap.name]> != <[token]> && !<[token].is_in[<&gt>|<&lt>]>:
            - define commandMap.attributes:->:<map[null=<[token]>]>

        - else if <[token]> == <&gt>:
            - determine <map[commandMap=<[commandMap]>;commandSize=<[commandSize]>]>


CommandDelegator_CISK:
    type: task
    debug: false
    script:
    - inject <script.name> path:GetRecursiveStructure if:<[commandMap].exists.not>
    - define evaluatedLine <list[]>

    - adjust <queue> linked_player:<[player]>
    - adjust <queue> linked_npc:<[npc]> if:<[npc].exists>

    - foreach <[line]> as:token:
        - if <[token].object_type.to_uppercase> == MAP:
            - define commandMap <[token]>
            - define commandName <[commandMap].get[name]>
            - define commandScript <script[<[commandName]>Command_CISK]>

            - run CommandMapEvaluator_CISK defmap:<queue.definition_map> save:eval_commandMap
            - define commandResult <entry[eval_commandMap].created_queue.determination.get[1].if_null[N/A]>
            - define evaluatedLine:->:<[commandResult]> if:<[commandResult].equals[N/A].not>

        - else:
            - define evaluatedLine:->:<[token]>

    - determine <[evaluatedLine]>

    GetRecursiveStructure:
    - if <[splitted].exists>:
        - run GenerateRecursiveStructures_CISK def.splitted:<[splitted]> save:line

    - else:
        - run GenerateRecursiveStructures_CISK save:line

    - define line <entry[line].created_queue.determination.get[1]>


CommandMapEvaluator_CISK:
    type: task
    debug: false
    definitions: commandMap|commandScript
    script:
    - define commandName <[commandMap].get[name]>
    - define commandScript <[commandScript].if_null[<script[<[commandName]>Command_CISK]>]>
    - inject <script.name> path:GenerateAttributeShorthands if:<[commandScript].data_key[commandData.attributeSubs].exists>

    - adjust <queue> linked_player:<[player]>
    - adjust <queue> linked_npc:<[npc]> if:<[npc].exists>

    - if <[commandScript].data_key[PreEvaluationCode].exists>:
        - inject <[commandScript].name> path:PreEvaluationCode

    - foreach <[commandMap]> key:datapoint:
        - if <[datapoint]> == attributes:
            - foreach <[value]> as:attrPair:
                - define attrKeyRaw <[attrPair].keys.get[1]>
                - define attrKey <[attrKeyRaw]>
                - define attrKey <[attrSubs].get[<[attrKeyRaw]>]> if:<[attrSubs].exists.and[<[attrSubs].contains[<[attrKeyRaw]>]>]>
                - define attrVal <[attrPair].values.get[1]>

                - if <[attrVal].object_type.to_uppercase> == MAP:
                    - run CommandMapEvaluator_CISK def.commandMap:<[attrVal]> def.player:<[player]> save:recur

                    - define nestedCommandResult <entry[recur].created_queue.determination.get[1]>
                    - define attrVal <[nestedCommandResult]>
                    - define commandMap.<[datapoint]>:<-:<[attrPair]>
                    - define commandMap.<[datapoint]>:->:<map[<[attrKey]>=<[nestedCommandResult]>]>

                - inject <[commandScript].name>

    - inject <[commandScript].name> path:PostEvaluationCode

    GenerateAttributeShorthands:
    - define attrSubs <map[]>

    - foreach <[commandScript].data_key[commandData.attributeSubs]> as:subList key:key:
        - foreach <[subList].as[list]> as:sub:
            - define attrSubs.<[sub]>:<[key]>


ProduceFlaggableObject_CISK:
    type: task
    debug: false
    definitions: text[ElementTag(String)]
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


# Example Usage:
# <wait 2>
# <wait 3.5>
WaitCommand_CISK:
    type: task
    debug: false
    script:
    - if <[attrVal].div[2].exists>:
        - define waitAmount <[attrVal]>

    - else if <[attrVal]> == override:
        - define waitOverride true

    PostEvaluationCode:
    - flag <[player]> KQuests.temp.wait.amount:<[waitAmount].round_to_precision[0.01]>
    - flag <[player]> KQuests.temp.wait.override:true if:<[waitOverride].exists.and[<[waitOverride].equals[true]>]>


# Example Usage:
# <dataget t:npc n:x def:0>
# <dataget t:player n:y>
DatagetCommand_CISK:
    type: task
    debug: false
    commandData:
        attributeSubs:
            target: t|tr
            name: n

    script:
    - choose <[attrKey]>:
        - case target:
            - define dataTarget <[attrVal]>

        - case name:
            - define dataName <[attrVal]>

    PostEvaluationCode:
    - run ProduceFlaggableObject_CISK def.text:<[dataTarget]> save:realTarget

    - define realTarget <entry[realTarget].created_queue.determination.get[1]>
    - define data <[realTarget].flag[KQuests.data.<[dataName]>.value]>

    - determine <[data]>


# Example Usage:
# <datastore t:npc n:x v:10>
# <datastore t:player n:y v:Hello persistent>
# <datastore t:npc n:name v:<state get player name>>
DatastoreCommand_CISK:
    type: task
    debug: false
    commandData:
        attributeSubs:
            target: t|tr
            name: n
            value: v

    script:
    - choose <[attrKey]>:
        - case target:
            - define dataTarget <[attrVal]>

        - case name:
            - define dataName <[attrVal]>

        - case value:
            - define dataValue <[attrVal]>

        - case null:
            - if <[attrVal]> == persistent:
                - define dataPersistent true

    PostEvaluationCode:
    - run ProduceFlaggableObject_CISK def.text:<[dataTarget]> save:realTarget
    - define realTarget <entry[realTarget].created_queue.determination.get[1]>
    - flag <[realTarget]> KQuests.data.<[dataName]>.value:<[dataValue]>
    - flag <[realTarget]> KQuests.data.<[dataName]>.persistent:true if:<[dataPersistent].if_null[false].equals[true]>

    # TODO: Add error check for this... And all of these commands for that fact.


BreakCommand_CISK:
    type: task
    debug: false
    script:
    - flag <[player]> KQuests.temp.hasBroken

    PostEvalutionCode:
    - determine cancelled


# Example Usage:
# <goto PlayerDefinedBranch1>
GotoCommand_CISK:
    type: task
    debug: false
    script:
    - if <[attrKey]> == null:
        - define gotoBranch <[attrVal]>

    PostEvaluationCode:
    - define playerDefinedBlock <yaml[ciskFile].read[<[schema]>.branches.<[gotoBranch]>]>
    - define currentBlock_orig <[currentBlock]>
    - define currentHandler <[playerDefinedBlock]>
    - define speech <[currentHandler].get[actions]>
    - define talkSpeed <[currentHandler].get[talkSpeed].if_null[1]>

    - inject SpeechHandler_CISK

    - define currentHandler <[currentBlock_orig]>
    - determine cancelled


# Example Usage:
# <give i:stick as_drop q:10>
# <give i:obsidian to_inv q:1>
GiveCommand_CISK:
    type: task
    debug: false
    commandData:
        attributeSubs:
            item: i
            quantity: q

    script:
    - choose <[attrKey]>:
        - case item:
            - define giveItem <[attrVal]>

        - case quantity:
            - define giveQuantity <[attrVal]>

        - default:
            - if <[attrVal].is_in[as_drop|to_inv]>:
                - define giveType <[attrVal]>

    PostEvaluationCode:
    - if <[giveItem]> == exp:
        - experience give <[giveQuantity]> player:<[player]>

    - else if <[giveItem].as[item].exists>:
        - define giveItem <[giveItem].as[item]>

        - if <[giveType]> == as_drop:
            - drop <[giveItem]> quantity:<[giveQuantity]> <[npc].as[entity].location.forward[1]>

        - else:
            - give <[giveItem]> quantity:<[giveQuantity]> to:<[player].inventory>


# Example Usage:
# <state get player name>
# <state get kingdom balance>
# <state set kingdom balance:14000>
StateCommand_CISK:
    type: task
    debug: false
    commandData:
        attributeSubs:
            item: i
            player: p
            npc: n

    script:
    - choose <[attrKey]>:
        - case server:
            - if <[stateAction].exists>:
                - define stateTarget <[attrVal]>

        - default:
            - if <[attrVal].is_in[get|set]>:
                - define stateAction <[attrVal]>

            - else if <[stateTarget].exists>:
                - if <[stateAction]> == set && !<[stateMechanism].exists>:
                    - define stateMechanism <[attrKey]>
                    - define stateMechanismSet <[attrVal]>

                - else:
                    - if <[attrKey]> == null:
                        - define stateMechanism <[attrVal]>

                    - else:
                        - define stateMechanism <[attrKey]>

            - else:
                - if <[attrVal].exists>:
                    - define stateTarget <map[<[attrKey]>=<[attrVal]>]>
                    - define stateTarget <map[<[attrVal]>=<[attrKey]>]> if:<[attrKey].equals[null]>

                - else:
                    - define stateTarget <map[<[attrKey]>=self]>

    PostEvaluationCode:
    # - narrate format:debug S_ACT:<[stateAction]>
    # - narrate format:debug S_TAR:<[stateTarget]>
    # - narrate format:debug S_MEC:<[stateMechanism]>
    # - narrate format:debug S_MES:<[stateMechanismSet].if_null[N/A]>

    - inject StateCommandMechanisms_CISK


# Example Usage:
# <anchor set l:140,64,320 n:test>
# <anchor set l:140,320 n:test>
# <anchor remove n:test>
# <anchor get n:test>
AnchorCommand_CISK:
    type: task
    debug: false
    description:
    - CISK COMMAND - Sets or removes an anchor location for the attached NPC to walk to
    - Note: Users can ommit the y coordinates. Parser will automatically find the y of that loc.
    - Example Usage-
    - <&lt>anchor set l:140,64,320 n:test<&gt>
    - <&lt>anchor set l:140,320 n:test<&gt>
    - <&lt>anchor remove n:test<&gt>
    - <&lt>anchor get n:test<&gt>
    commandData:
        attributeSubs:
            location: l
            name: n

    script:
    - choose <[attrKey]>:
        - case location:
            - define anchorLocationRaw <[attrVal].split[,]>

        - case name:
            - define anchorName <[attrVal]>

        - case null:
            - if !<[anchorMode].exists>:
                - define anchorMode <[attrVal]>

    PostEvaluationCode:
    - if !<[anchorName].exists>:
        - determine cancelled

    - choose <[anchorMode]>:
        - case set:
            - if <[anchorLocationRaw].size> == 2:
                - define anchorLocation <proc[IncompleteLocationGeneratorHelper_CISK].context[<[anchorLocationRaw]>]>

            - else if <[anchorLocationRaw].size> >= 3:
                - define anchorLocation <proc[LocationType_CISK].context[<[anchorLocationRaw].separated_by[,]>|<[player]>]>

            - flag <npc> KQuests.anchors.<[anchorName]>:<[anchorLocation]> if:<[anchorLocation].exists>

        - case get:
            - determine <proc[LocationType_CISK].context[<npc.flag[KQuests.anchors.<[anchorName]>]>]>

        - case remove:
            - if <[npc].has_flag[KQuests.anchors.<[anchorName]>]>:
                - flag <npc> KQuests.anchors.<[anchorName]>:!


IncompleteLocationGeneratorHelper_CISK:
    type: procedure
    debug: false
    definitions: locationRaw[ListTag]
    script:
    - define locationChunk <location[<[locationRaw].x>,64,<[locationRaw]>].chunk>
    - define XZLocationList <[locationChunk].surface_blocks.parse_tag[<[parse_value].x>,<[parse_value].z>]>
    - define realLocationIndex <[XZLocationList].find[<[locationRaw].comma_separated>]>
    - determine <[locationChunk].surface_blocks.get[<[realLocationIndex]>]>


# Example Usage:
# <walk t:npc to:140,64,320>
# <walk t:npc forward:10>
# <walk t:npc anchor:ANCHOR_NAME>
WalkCommand_CISK:
    type: task
    debug: false
    description:
    - CISK COMMAND - Walks an NPC to a specified location
    - Note: Will use Kingdoms walk which teleports the specified entity the last couple blocks due to Minecraft pathfinding failing
    - Example Usage<&co>
    - <&lt>walk t:npc to:140,64,320<&gt>
    - <&lt>walk t:npc forward:10<&gt>
    - <&lt>walk t:npc anchor:ANCHOR_NAME<&gt>
    commandData:
        attributeSubs:
            target: t|tr

    script:
    - choose <[attrKey]>:
        - case target:
            - define walkTarget <[attrVal]>

        - case to:
            - define walkLocationRaw <[attrVal].split[,]>

        - case anchor:
            - define anchorName <[attrVal]>

        - default:
            - if <[attrKey].is_in[forward|backward|left|right]>:
                - definemap relativeLocation:
                    distance: <[attrVal]>
                    direction: <[attrKey]>

    PostEvaluationCode:
    # TODO: Add checks to this

    - run ProduceFlaggableObject_CISK def.text:<[walkTarget]> save:realTarget
    - define realTarget <entry[realTarget].created_queue.determination.get[1]>

    - if <[walkLocationRaw].exists>:
        - define realLocation <location[<[realTarget].location.world.name>,<[walkLocationRaw].comma_separated>]>

    - else if <[anchorName].exists>:
        - define realLocation <[realTarget].flag[KQuests.anchors.<[anchorName]>].as[location]>

    - else if <[relativeLocation].exists>:
        - define direction <[relativeLocation].get[direction]>
        - define distance <[relativeLocation].get[distance]>

        - choose <[direction]>:
            - case forward:
                - define realLocation <[realTarget].location.forward_flat[<[distance]>]>

            - case backward:
                - define realLocation <[realTarget].location.backward_flat[<[distance]>]>

            - case right:
                - define realLocation <[realTarget].location.right[<[distance]>]>

            - case left:
                - define realLocation <[realTarget].location.left[<[distance]>]>

    - if <[realLocation].distance[<[realTarget]>]> < 1.5:
        - teleport <[realTarget]> <[realLocation]>

    - else:
        - ~run NPCWalkHelper_CISK def.target:<[realTarget]> def.location:<[realLocation]>


NPCWalkHelper_CISK:
    type: task
    debug: false
    definitions: target|location
    script:
    - walk <[target]> <[location]> auto_range
    - waituntil <[target].is_navigating.not> rate:10t
    - teleport <[target]> <[location]>

# Example Usage:
# <run SampleTestScript>
RunCommand_CISK:
    type: task
    description:
    - CISK COMMAND - Runs a Denizen task script inside a CISK container, automatically passing in
    - the context associated with the current CISK queue.
    - Example Usage<&co>
    - <&lt>run SampleTaskScript<&gt>

    script:
    - define scriptName <[attrVal]>
    - foreach stop

    PostEvaluationCode:
    - if <util.scripts.contains[s<&at><[scriptName]>]>:
        - definemap contextData:
            player: <player>
            npc: <npc>

        - run <[scriptName]> defmap:<[contextData]>

    - else:
        - run GenerateInternalError def.silent:true def.category:GenericError def.message:<element[Unable to run script: <[scriptName]> within quest schema. Maybe a task script by that name does not exist?]>


# Example Usage:
# <add 3 5>
# <add <state get player health> 10>
AddCommand_CISK:
    type: task
    debug: false
    description:
    - CISK COMMAND - Adds two numbers together
    - Example Usage<&co>
    - <&lt>add 3 5<&gt>
    - <&lt>add <&lt>state get player health<&gt> 10<&gt>

    script:
    - define operands:->:<[attrVal]>

    PreEvaluationCode:
    - define operands <list[]>

    PostEvaluationCode:
    # TODO: Add error-checking as usual

    - if <[operands].unseparated.add[1].exists>:
        - determine <[operands].get[1].add[<[operands].get[2]>]>

# Example Usage:
# <sub 3 5>
# <sub <state get player health> 10>
SubCommand_CISK:
    type: task
    debug: false
    description:
    - CISK COMMAND - Subtracts the first number from the second
    - Example Usage<&co>
    - <&lt>sub 3 5<&gt>
    - <&lt>sub <&lt>state get player health<&gt> 10<&gt>

    script:
    - define operands:->:<[attrKey]>

    PreEvaluationCode:
    - define operands <list[]>

    PostEvaluationCode:
    - if <[operands].unseparated.sub[1].exists>:
        - determine <[operands].get[1].sub[<[operands].get[2]>]>


# Example Usage:
# <mul 3 5>
# <mul <state get player health> 10>
MulCommand_CISK:
    type: task
    debug: false
    description:
    - CISK COMMAND - Multiplies two numbers together
    - Example Usage<&co>
    - <&lt>mul 3 5<&gt>
    - <&lt>mul <&lt>state get player health<&gt> 10<&gt>

    script:
    - define operands:->:<[attrKey]>

    PreEvaluationCode:
    - define operands <list[]>

    PostEvaluationCode:
    - if <[operands].unseparated.mul[1].exists>:
        - determine <[operands].get[1].mul[<[operands].get[2]>]>


# Example Usage:
# <div 3 5>
# <div <state get player health> 10>
DivCommand_CISK:
    type: task
    debug: false
    description:
    - CISK COMMAND - Divides the first number by the second
    - Example Usage<&co>
    - <&lt>div 3 5<&gt>
    - <&lt>div <&lt>state get player health<&gt> 10<&gt>

    script:
    - define operands:->:<[attrKey]>

    PreEvaluationCode:
    - define operands <list[]>

    PostEvaluationCode:
    - if <[operands].unseparated.div[1].exists>:
        - determine <[operands].get[1].div[<[operands].get[2]>]>
