##
## * The main file containing the components of the Common Interface
## * for Storywriting in Kingdoms (CISK) parser.
##
## * This parser will allow individuals with no knowledge of Denizen
## * to write quests and dialogue stubs for Kingdoms.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug - Nov 2022
## @Status: INDEV
## @Version: v0.5
##ignorewarning bad_quotes
## ---------------------------END HEADER----------------------------

WaitTime_CISK:
    type: procedure
    debug: false
    definitions: text|multiplier
    script:
    - determine <[text].split[<&sp>].size.div[1.5].div[<[multiplier]>]>


#TODO: Make var handler change every script so that error messages reflect correctly

RequiredKeys_CISK:
    type: data
    top:
        - questName
        - questDesc
        - questIcon


MainParser_CISK:
    type: task
    debug: false
    definitions: file|schema|handler|npc|player
    script:
    - yaml load:quest_schemas/<[file]> id:ciskFile
    - define questRaw <yaml[ciskFile].read[<[schema]>]>
    - define questKeyList <[questRaw].list_keys>
    - define foundRequiredKeys <list[]>

    - foreach <script[RequiredKeys_CISK].data_key[top]>:
        - if <[questKeyList].contains[<[value]>]>:
            - define foundRequiredKeys:->:<[value]>

    # Turn the required key checker into its own script so it can be
    # run everytime the parser enters a new level in YAML structure.

    - if !<script[RequiredKeys_CISK].data_key[top].size.equals[<[foundRequiredKeys].size>]>:
        - define missingKeys <script[RequiredKeys_CISK].data_key[top].exclude[<[foundRequiredKeys]>]>

        - narrate "CISK Error: Missing <[missingKeys].size.color[red]> key(s) from schema: <[schema].color[red]> in file: <[file].color[red]>. Please include the following keys:"
        - narrate <&sp>
        - narrate <[missingKeys].separated_by[,].color[red]>
        - narrate <&sp>
        - narrate "And then re-run the parser."
        - determine cancelled

    - if !<[npc].flag[playerInteractions].get[<[player]>].exists>:
        - flag <[npc]> playerInteractions.<[player]>:0

    - foreach <[questKeyList]> as:key:
        - define handlerBlock <[questRaw].get[<[key]>]>

        - if <[key]> == <[handler]>:
            - inject SpeechHandler_CISK path:InitializeVars
            - inject SpeechHandler_CISK

    - if <[npc].has_flag[dialogueData]>:
        - flag <[npc]> dialogueData:!

    - foreach <list[<[npc]>|<[player]>]> as:dataTarget:
        - foreach <[dataTarget].flag[KQuests.data]>:
            - if !<[value].keys.contains[persistent]>:
                # - narrate format:debug <[key]>
                - flag <[dataTarget]> KQuests.data.<[key]>:!


SpeechHandler_CISK:
    type: task
    debug: false
    InitializeVars:
    - define hasBroken <[hasBroken].if_null[false]>
    - define interactionAmounts <[npc].flag[playerInteractions].get[<[player]>]>

    # Checks if the default interaction handler should be initiated
    - define interactionKeys <[handlerBlock].keys.exclude[def]>
    - define mostInteraction <[interactionKeys].last>
    - define interactionAmounts def if:<[interactionAmounts].is[MORE].than[<[mostInteraction]>]>
    - define interactionAmounts <[interactionsAmounts].if_null[0]>
    - define currentBlock <[handlerBlock].get[<[interactionAmounts]>].if_null[<[handlerBlock]>]>

    - if !<[currentBlock].exists>:
        - define errMsg "Handler: <[handler]> is missing default case."
        - run WriteCiskError def.file:<[file]> def.schema:<[schema]> def.currentBlock:<[currentBlock]> def.message:<[errMsg]>

    - define talkSpeed <[currentBlock].get[talkSpeed].if_null[1]>
    - define shouldEngage <[currentBlock].get[blockingInteraction].if_null[false]>
    - define speech <[currentBlock].get[actions]>

    script:
    ## Defs carried from MAINPARSER_CISK:
    ## file, schema, handler, npc, player

    ## Vars carried from MAINPARSER_CISK:
    ## handlerBlock, key, ...

    # Reminder to self: When passing in player defined branches, pass the player branch
    # not the parent one named 'branches'

    - if <[shouldEngage]> && !<[npc].engaged>:
        - engage

    - foreach <[speech]> as:line:
        - if <[hasBroken]> || <[player].has_flag[KQuests.temp.hasBroken]>:
            - disengage
            - flag <[player]> KQuests.temp.hasBroken:!
            - determine cancelled

        - define waitTime <[waitTime].if_null[1]>
        - define waitOverride null

        - if <[line].as[map].exists>:
            - choose <[line].keys.get[1].to_uppercase>:
                - case OPTIONS:
                    - define waitTime 0
                    - inject OptionsHandler_CISK

                - case DATA:
                    - inject DataHandler_CISK

                - case CONDITIONAL:
                    - inject ConditionalHandler_CISK

                - case RANDOM:
                    - inject RandomizationHandler_CISK

                - default:
                    - define errMsg "Unrecognized block '<[line].key>'. Could this be a typo?"
                    - run WriteCiskError def.file:<[file]> def.schema:<[schema]> def.currentBlock:<[currentBlock]> def.message:<[errMsg]>
                    - determine cancelled

        - else:
            - run SplitKeep def.text:<[line]> "def.delimiters:<list[<&gt>|<&lt>|<&co>| ]>" def.splitType:seperate save:split
            - define splitted <entry[split].created_queue.determination.get[1].filter_tag[<[filter_value].regex_matches[\s*].not>].parse_tag[<[parse_value].trim>]>

            - run CommandDelegator_CISK def.splitted:<[splitted]> def.player:<[player]> def.npc:<[npc]> save:evaluated_line
            - define evaluatedLine <entry[evaluated_line].created_queue.determination.get[1]>
            - define waitTime 0

            - if <[evaluatedLine].size> > 0:
                - define waitTime <proc[WaitTime_CISK].context[<[evaluatedLine].space_separated>|<[talkSpeed]>].round_to_precision[0.01]>
                - define waitTime 1 if:<[waitTime].is[LESS].than[0.1]>
                - chat targets:<[player]> talkers:<[npc]> <[evaluatedLine].space_separated>

        - if <[player].has_flag[KQuests.temp.wait.override]>:
            - define waitOverride 0
            - flag <[player]> KQuests.temp.wait.override:!

        - if !<[waitOverride].exists> || <[waitOverride]> == null:
            - wait <[waitTime]>s

        - if <[player].has_flag[KQuests.temp.wait]>:
            - wait <[player].flag[KQuests.temp.wait]>s
            - flag <[player]> KQuests.temp.wait:!

    - if <[shouldEngage]> && <[npc].engaged>:
        #TODO: UNCOMMENT ONCE IN PROD!
        #- flag <[npc]> playerInteractions.<[player]>:++
        - disengage


OptionsHandler_CISK:
    type: task
    script:
    ## Defs carried from MAINPARSER_CISK:
    ## file, schema, handler, npc, player

    ## Defs carried from SPEECHHANDLER_CISK:
    ## waitTime, currentBlock, interactionAmounts, talkSpeed, shouldEngage, speech, hasBroken, line

    - define optionList <[optionList].if_null[<list[]>]>

    - narrate <&sp>
    - narrate <aqua><bold>OPTIONS<&co>

    - foreach <[line].get[OPTIONS]>:
        - define index <[value].keys.get[1]>
        - define prompt <[value].get[prompt]>
        - define speech <[value].get[actions]>

        - clickable save:option until:1m for:<[player]>:
            - run SpeechHandler_CISK defmap:<queue.definition_map>
            - flag <[player]> clickedOption

        - narrate "- <underline><element[<[prompt]>].on_click[<entry[option].command>]>"
        - define optionList:->:<entry[option].id>

    - narrate <n>

    - waituntil <[player].has_flag[clickedOption]> rate:1s

    - foreach <[optionList]>:
        - clickable cancel:<[value]>

    - flag <[player]> clickedOption:!


ConditionalHandler_CISK:
    type: task
    script:
    ## Defs carried from MAINPARSER_CISK:
    ## file, schema, handler, npc, player

    ## Defs carried from SPEECHHANDLER_CISK:
    ## waitTime, currentBlock, interactionAmounts, talkSpeed, shouldEngage, speech, hasBroken, line

    - define handler <[line].keys.get[1]>
    - define ifBlock <[line].get[CONDITIONAL]>
    - define compOperation <[line].deep_get[CONDITIONAL.comparison]>
    - define compOperands <[line].deep_get[CONDITIONAL.operands]>
    - define compOperation != if:<[compOperation].equals[NOT_EQUAL]>
    - define parsedOperands <list[]>

    - foreach <[compOperands]> as:operand:
        # TODO: Add a regex check here to make sure it's only firing on lines that have commands.

        - run SplitKeep def.text:<[operand]> "def.delimiters:<list[<&gt>|<&lt>|<&co>| ]>" def.splitType:seperate save:split
        - define splitted <entry[split].created_queue.determination.get[1].filter_tag[<[filter_value].regex_matches[\s*].not>].parse_tag[<[parse_value].trim>]>

        - run CommandDelegator_CISK def.splitted:<[splitted]> def.player:<[player]> save:evaluated_line
        - define evaluatedLine <entry[evaluated_line].created_queue.determination.get[1]>
        - define result <[evaluatedLine].get[1]>

        - if <[result].exists>:
            - define parsedOperands:->:<[result]>
            - define result:!

        - else:
            - define parsedOperands:->:<[operand]>

    - define ifTrue <[line].deep_get[CONDITIONAL.true.actions]>
    - define ifFalse <[line].deep_get[CONDITIONAL.false.actions]>
    - define speech null

    - if <[parsedOperands].get[1].is[<[compOperation]>].than[<[parsedOperands].get[2]>]>:
        - define speech <[ifTrue]>

    - else:
        - define speech <[ifFalse]>

    - inject SpeechHandler_CISK


DataHandler_CISK:
    type: task
    script:
    ## Defs carried from MAINPARSER_CISK:
    ## file, schema, handler, npc, player

    ## Defs carried from SPEECHHANDLER_CISK:
    ## waitTime, currentBlock, interactionAmounts, talkSpeed, shouldEngage, speech, hasBroken, line

    - define dataBlock <[line].get[DATA]>
    - define targetName <[dataBlock].get[target]>
    - define dataName <[dataBlock].get[varName]>
    - define dataVal <[dataBlock].get[data]>
    - define isPersistent <[dataBlock].get[persistent]>

    - if <[targetName].regex_matches[^npc|player]>:
        - if <[targetName].contains_text[<&at>]>:
            - define targetType <[targetName].split[<&at>].get[1]>
            - define targetID <[targetName].split[<&at>].get[2]>
            - define lookupList <list>

            - choose <[targetType]>:
                - case player:
                    - define lookupList <server.players.parse_tag[<[parse_value].name>]>
                    - define dataTarget <player[<[targetID]>]>
                - case npc:
                    - define lookupList <server.npcs.parse_tag[<[parse_value].id>]>
                    - define dataTarget <npc[<[targetID]>]>

            - if <[dataTarget].exists> || <[dataTarget]> == null:
                - define errMsg "Invalid target specified: '<[targetName]>'"
                - run WriteCiskError def.file:<[file]> def.schema:<[schema]> def.currentBlock:<[handler]> def.message:<[errMsg]>

        - else:
            - define dataTarget <queue.definition_map.get[<[targetName]>]>

    - if !<[dataTarget].exists>:
        - define errMsg "Internal error occured while calculating data target result"
        - run WriteCiskError def.file:<[file]> def.schema:<[schema]> def.currentBlock:<[handler]> def.message:<[errMsg]>
        - determine cancelled

    - flag <[dataTarget]> KQuests.data.<[dataName]>.value:<[dataVal]>


RandomizationHandler_CISK:
    type: task
    script:
    ## Defs carried from MAINPARSER_CISK:
    ## file, schema, handler, npc, player

    ## Defs carried from SPEECHHANDLER_CISK:
    ## waitTime, currentBlock, interactionAmounts, talkSpeed, shouldEngage, speech, hasBroken, line

    - define handler <[line].keys.get[1]>
    - define randomBlock <[line].get[RANDOM]>
    - define randomActions <[randomBlock].get[actions]>
    - define randomIndex <util.random.int[1].to[<[randomActions].size>]>

    - run SpeechHandler_CISK defmap:<queue.definition_map.include[speech=<[randomActions].get[<[randomIndex]>]>]>


WriteCiskError:
    type: task
    definitions: file|schema|currentBlock|message
    script:
    - narrate <n>
    - if !<[currentBlock].exists>:
        - narrate format:ciskerror "Error in file: <[file]>, schema: <[schema]>;"

    - else:
        - narrate format:ciskerror "Error in file: <[file]>, schema: <[schema]> @ handler block: <[currentBlock]>;"

    - narrate format:ciskerror_noheader <[message]>
    - narrate format:ciskerror_noheader "Please fix this error and re-run the parser."
    - narrate <n>


ciskerror:
    type: format
    format: <&gt><&gt> <bold>CISK ERROR: <gray><[text]>


ciskerror_noheader:
    type: format
    format: <red><&gt><&gt> <gray><[text]>


CISKAssignment:
    type: assignment
    actions:
        on click:
        - if <player.has_flag[CISKAdmin.enabled]>:
            - narrate "<gray><strikethrough>                         "
            - narrate "<bold>NPC ID: <blue><npc.id>"
            - narrate "<bold>ASSIGNED FILE: <blue><npc.flag[file]>"
            - narrate "<bold>ASSIGNED SCHEMA: <blue><npc.flag[schema]>"
            - narrate "<gray><strikethrough>                         "

        - else:
            - define file <npc.flag[file]>
            - define schema <npc.flag[schema]>

            - run MainParser_CISK def.file:<[file]> def.schema:<[schema]> def.handler:click def.npc:<npc> def.player:<player>


ResetCISKFlag_Handler:
    type: world
    events:
        on player quits:
        - flag <player> CISKAdmin:!


CISKCommand:
    type: command
    name: cisk
    usage: /cisk
    description: Umbrella command for the CISK Engine
    permission: kingdoms.admin.cisk
    tab completions:
        1: assign|admin
        2: [FileName]
        3: [SchemaName]
        4: [NPCID]

    script:
    - define args <context.raw_args.split_args>

    - if <[args].get[1]> == assign:
        - define file <context.args.get[2]>
        - define schema <context.args.get[3]>
        - define npc <npc[<context.args.get[4]>]>

        - if !<util.has_file[quest_schemas/<[file]>]>:
            - narrate format:admincallout "Server does not have CISK file with name: <[file]>."
            - determine cancelled

        - yaml load:quest_schemas/<[file]> id:schema

        - if !<yaml[schema].contains[<[schema]>]>:
            - narrate format:admincallout "CISK file: <[file]> does not contain a schema with the name: <[schema]>."
            - determine cancelled

        - yaml id:schema unload

        - if !<server.npcs.parse_tag[<[parse_value].id>].contains[<[npc].id>]>:
            - narrate format:admincallout "There is no npc with that ID."
            - determine cancelled

        - flag <[npc]> file:<[file]>
        - flag <[npc]> schema:<[schema]>

        - assignment clear to:<[npc]>
        - assignment set CISKAssignment to:<[npc]>
        - narrate format:admincallout "Assigned quest: <[schema]> to npc: <[npc].name>"

    - else if <[args].get[1]> == admin:
        - if <player.has_flag[CISKAdmin.enabled]>:
            - flag <player> CISKAdmin:!

        - else:
            - flag <player> CISKAdmin.enabled

        - narrate format:admincallout "CISK NPC debug view: <red><player.flag[CISKAdmin].exists.if_true[Activated].if_false[Deactivated]>!"
