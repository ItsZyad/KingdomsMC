##
## * The main file containing the components of the Common Interface
## * for Storywriting in Kingdoms (CISK) parser.
##
## * This parser will allow individuals with no knowledge of Denizen
## * to write quests and dialogue stubs for Kingdoms.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug - Oct 2022
## @Status: INDEV
## @Version: v0.3
#ignorewarning invalid_data_line_quotes
## ---------------------------END HEADER----------------------------


RequiredKeys_CISK:
    type: data
    top:
        - "questName"
        - "questDesc"
        - "questIcon"


MainParser_CISK:
    type: task
    definitions: file|schema|handler|npc|player
    script:
    - yaml load:quest_schemas/<[file]> id:ciskFile
    - define questRaw <yaml[ciskFile].read[<[schema]>]>
    - define questKeyList <[questRaw].list_keys>
    - define foundRequiredKeys <list[]>

    #- narrate format:debug SCH:<[schema]>
    #- narrate format:debug RAW:<[questRaw]>

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


SpeechHandler_CISK:
    type: task
    InitializeVars:
    - define hasBroken <[hasBroken].if_null[false]>
    - define interactionAmounts <[npc].flag[playerInteractions].get[<[player]>]>

    # Checks if the default interaction handler should be initiated
    - define interactionKeys <[handlerBlock].keys.exclude[def]>
    - define mostInteraction <[interactionKeys].last>
    - define interactionAmounts def if:<[interactionAmounts].is[MORE].than[<[mostInteraction]>]>
    - define interactionAmounts <[interactionsAmounts].if_null[0]>
    - define currentBlock <[handlerBlock].get[<[interactionAmounts]>].if_null[<[handlerBlock]>]>

    # - narrate format:debug INT:<[interactionAmounts]>
    # - narrate format:debug HAN:<[handlerBlock]>
    # - narrate format:debug CUR:<[currentBlock]>

    - if !<[currentBlock].exists>:
        - define errMsg "Handler: <[handler]> is missing default case."
        - run WriteCiskError def.file:<[file]> def.schema:<[schema]> def.currentBlock:<[currentBlock]> def.message:<[errMsg]>

    - define talkSpeed <[currentBlock].get[talkSpeed].if_null[1]>
    - define shouldEngage <[currentBlock].get[blockingInteraction].if_null[false]>
    - define speech <[currentBlock].get[actions]>

    # - narrate format:debug SPC:<[speech]>

    script:
    ## Defs carried from MAINPARSER_CISK:
    ## file, schema, handler, npc, player

    ## Vars carried from MAINPARSER_CISK:
    ## handlerBlock, key, ...

    # Reminder to self: When passing in player defined branches, pass the player branch
    # not the parent one named 'branches'

    #- run FlagVisualizer def.flag:<queue.definition_map.get[interactionAmounts]> def.flagName:intAmnts
    #- narrate <[handler]> format:debug

    - if <[shouldEngage]> && !<[npc].engaged>:
        - engage

    - foreach <[speech]> as:line:
        - if <[hasBroken]>:
            - disengage
            - determine cancelled

        - define waitTime <proc[WaitTime_CISK].context[<[line]>|<[talkSpeed]>].round_to_precision[0.01]>

        - if <[line].as[map].exists>:
            - choose <[line].keys.get[1].to_uppercase>:
                - case OPTIONS:
                    - inject OptionsHandler_CISK

                - case DATA:
                    - inject DataHandler_CISK

                - case CONDITIONAL:
                    - inject ConditionalHandler_CISK

                - default:
                    - define errMsg "Unrecognized block '<[line].key.get[1]>'. Could this be a typo?"
                    - run WriteCiskError def.file:<[file]> def.schema:<[schema]> def.currentBlock:<[currentBlock]> def.message:<[errMsg]>
                    - determine cancelled

        - else if <[line].starts_with[/]> && <[line].ends_with[/]>:
            - define value <[line]>
            # - narrate format:debug VAL:<[value]>
            - inject CommandHandler_CISK

            - define commandScript <[commandRes].get[script]>
            - define commandPath <[commandRes].get[path]>

            # - narrate format:debug SCR:<[commandScript]>
            # - narrate format:debug PAT:<[commandPath]>

            - inject <[commandScript]> path:<[commandPath]>

        - else:
            - chat targets:<[player]> talkers:<[npc]> <[line]>
            - wait <[waitTime]>s

    - if <[shouldEngage]> && <[npc].engaged>:
        #TODO: UNCOMMENT ONCE IN PROD!
        #- flag <[npc]> playerInteractions.<[player]>:++
        - disengage


CommandHandler_CISK:
    type: task
    BreakCommand:
    - define hasBroken true
    - determine cancelled

    GotoCommand:
    - define gotoScript "<[value].split[/goto ].get[2].replace_text[/].with[]>"
    - define playerDefinedBlock <yaml[ciskFile].read[<[schema]>.branches.<[gotoScript]>]>

    # - narrate format:debug SCH:<[schema]>
    # - narrate format:debug SCR:<[gotoscript]>

    - define currentBlock_orig <[currentBlock]>
    - define currentHandler <[playerDefinedBlock]>
    - define speech <[currentHandler].get[actions]>

    # - narrate format:debug CUR:<[currentHandler]>
    # - narrate format:debug BLO:<[currentBlock_orig]>
    # - narrate format:debug SPC:<[speech]>

    #- inject SpeechHandler_CISK path:InitializeVars
    - inject SpeechHandler_CISK

    - define currentHandler <[currentBlock_orig]>
    - determine cancelled

    WaitCommand:
    - define waitTime "<[value].split[/wait ].get[2].replace_text[/].with[]>"

    - if <[waitTime].is_integer.or[<[waitTime].is_decimal>]>:
        - wait <[waitTime]>s

    - else:
        - define errMsg "Expected decimal or integer argument in wait command."
        - run WriteCiskError def.file:<[file]> def.schema:<[schema]> def.currentBlock:<[handler]> def.message:<[errMsg]>
        - determine cancelled

    script:
    ## Defs carried from MAINPARSER_CISK:
    ## file, schema, handler, npc, player

    ## Defs carried from SPEECHHANDLER_CISK:
    ## waitTime, currentBlock, interactionAmounts, talkSpeed, shouldEngage, speech, hasBroken

    - if <[value]> == /break/:
        - define commandRes <map[script=CommandHandler_CISK;path=BreakCommand]>

    - else if <[value].starts_with[/goto]>:
        - define commandRes <map[script=CommandHandler_CISK;path=GotoCommand]>

    - else if <[value].starts_with[/wait]>:
        - define commandRes <map[script=CommandHandler_CISK;path=WaitCommand]>

    - else:
        - define errMsg "Unrecognized command '<[line]>'"
        - run WriteCiskError def.file:<[file]> def.schema:<[schema]> def.currentBlock:<[handler]> def.message:<[errMsg]>


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
        - define index <[value].key>
        - define prompt <[value].get[prompt]>
        - define speech <[value].get[actions]>

        - clickable save:option until:1m for:<[player]>:
            - ~run SpeechHandler_CISK defmap:<queue.definition_map>
            - narrate format:debug <script.queues>
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

    - define ifBlock <[line].get[CONDITIONAL]>
    - define targetName <[ifBlock].get[target]>
    - define varName <[ifBlock].get[varName]>
    - define conditionComp <[ifBlock].deep_get[condition.comparison]>
    - define conditionVal <[ifBlock].deep_get[condition.value]>

    - if <[targetName].regex_matches[^npc|player]>:
        - if <[targetName].contains_text[<&at>]>:
            - define targetType <[targetName].split[<&at>].get[1]>
            - define targetID <[targetName].split[<&at>].get[2]>
            - define lookupList <list>

            - case player:
                - define lookupList <server.players.parse_tag[<[parse_value].name>]>
                - define conditionTarget <player[<[targetID]>]>
            - case npc:
                - define lookupList <server.npcs.parse_tag[<[parse_value].id>]>
                - define conditionTarget <npc[<[targetID]>]>

            - if <[conditionTarget].exists> || <[conditionTarget]> == null:
                - define errMsg "Invalid target specified: '<[targetName]>'"
                - run WriteCiskError def.file:<[file]> def.schema:<[schema]> def.currentBlock:<[handler]> def.message:<[errMsg]>
                - determine cancelled

        - else:
            - define conditionTarget <queue.definition_map.get[<[targetName]>]>

    ## To be treated as speech blocks
    - define ifTrue <[ifBlock].deep_get[ifTrue.actions]>
    - define ifFalse <[ifBlock].deep_get[ifFalse.actions]>

    - define conditionData <[conditionTarget].flag[KQuests.data.<[varName]>]>
    - define conditionData <server.flag[KQuests.data.<[varName]>]> if:<[conditionTarget].equals[server]>
    - define speech null

    - if <[conditionData].is[<[conditionComp]>].than[<[conditionVal]>]>:
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
    - define dataVal <[dataBlock].get[data]>
    - define isPersistent <[dataBlock].get[persistent]>
    - define isPlayerSpecific <[dataBlock].get[playerSpecific]>

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

    # - narrate format:debug DTAR:<[dataTarget]>
    # - narrate format:debug TARN:<[targetName]>
    # - narrate format:debug DATA:<[dataVal]>

    - flag <[dataTarget]> <[targetName]>:<[dataVal]>

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


CISKAssignment:
    type: assignment
    actions:
        on click:
        - define file <npc.flag[file]>
        - define schema <npc.flag[schema]>

        - run MainParser_CISK def.file:<[file]> def.schema:<[schema]> def.handler:click def.npc:<npc> def.player:<player>


CISKCommand:
    type: command
    name: cisk
    usage: /cisk
    description: Umbrella command for the CISK Engine
    permission: kingdoms.admin.cisk
    tab completions:
        1: assign
        2: [FileName]
        3: [SchemaName]
        4: [NPCID]

    script:
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

    - assignment set CISKAssignment to:<[npc]>
    - narrate format:admincallout "Assigned quest: <[schema]> to npc: <[npc].name>"
