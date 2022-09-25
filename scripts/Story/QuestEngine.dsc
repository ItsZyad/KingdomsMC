##
## * The main file containing the components of the Common Interface
## * for Storywriting in Kingdoms (CISK) parser.
##
## * This parser will allow individuals with no knowledge of Denizen
## * to write quests and storylines for Kingdoms.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2022
## @Version: v0.1
## ---------------------------END HEADER----------------------------

#ValidKeys_CISK:
    #type: data
    # This should only be used to check keys that have a non-map value
    # like range: 5 or talkspeed: 1.2
    #branches:
    #    - 

WaitTime_CISK:
    type: procedure
    definitions: text|multiplier
    script:
    - determine <[text].split[<&sp>].size.div[1.5].div[<[multiplier]>]>

DataStorageParser_CISK:
    type: task
    definitions: npc|player|dataBlock|isDialogue|schemaName
    script:
    - define formattedData <[dataBlock].get[DATA]>
    - define isPersistent <[formattedData].get[persistent].if_null[false]>
    - define isPlayerSpec <[formattedData].get[playerSpecific].if_null[false]>
    - define data <[formattedData].get[data]>
    - define dataName <[formattedData].get[varName]>
    - define flagTarget <[npc]>

    - if <[formattedData].get[target]> == player:
        - define flagTarget <[player]>
        - define isPlayerSpec false

    - definemap dataMap:
        persistent: <[isPersistent]>
        playerSpec: <[isPlayerSpec]>
        data: <[data]>

    - if <[isPlayerSpec]>:
        - flag <[flagTarget]> questData.<[player]>.<[dataName]>:<[dataMap]>

    - else:
        - flag <[flagTarget]> questData.<[dataName]>:<[dataMap]>


ConditionsHandler_CISK:
    type: task
    definitions: npc|conditionBlock|outerBlock|schema|player|stopPoint|talkSpeed|file
    script:
    - define type <[conditionBlock].get[type]>
    - define target <[conditionBlock].get[target]>
    - define varName <[conditionBlock].get[varName]>
    - define condition <[conditionBlock].get[condition]>
    - define truthyCase <[conditionBlock].get[ifTrue]>
    - define falsyCase <[conditionBlock].get[ifFalse]>

    - choose <[type]>:
        - case data:
            - if <[varName].exists>:
                - define comparison <[condition].get[comparison]>
                - define compVal <[condition].get[value]>

                - define dataPoint <[npc].flag[questData].get[<[varName]>].if_null[<[npc].flag[questData].deep_get[<[player]>.<[varName]>]>]>

                - if <[target].starts_with[npc]>:
                    - if <[target].length.is[MORE].than[3]>:
                        - define npcID <[target].split[@].get[2]>
                        - define target <npc[<[npcID]>]>

                - if <[dataPoint].exists>:
                    - if <[dataPoint].is[<[comparison]>].than[<[compVal]>]>:
                        - run SpeechParser_CISK_OLD def.npc:<[npc]> def.handlerBlock:<[truthyCase]> def.handlerType:playerBlock def.player:<[player]> def.schema:<[schema]> until:1m usages:1

                    - else:
                        - if <[falsyCase].exists>:
                            - run SpeechParser_CISK_OLD def.npc:<[npc]> def.handlerBlock:<[falsyCase]> def.handlerType:playerBlock def.player:<[player]> def.schema:<[schema]> until:1m usages:1


OptionsParser_CISK:
    type: task
    definitions: npc|optionsBlock|handlerBlock|handlerType|schema|player|stopPoint|talkSpeed|file
    script:
    - define options <[optionsBlock].get[OPTIONS]>
    - narrate <&sp>
    - narrate <aqua><bold>OPTIONS<&co>

    - define optionList <list[]>

    - foreach <[options]>:
        - define prompt <[value].get[prompt]>
        - define action <[value].get[action]>

        #- narrate format:debug <[prompt]>
        #- narrate format:debug <[action]>

        - if <[action]> == /continue/:
            #- narrate format:debug HANDLER-BLOCK-OPTNS:<[handlerBlock]>
            - clickable save:option until:1m:
                - run SpeechParser_CISK_OLD def.npc:<[npc]> def.handlerBlock:<[handlerBlock]> def.handlerType:<[handlerType]> def.player:<[player]> def.schema:<[schema]> def.fromLine:<[stopPoint]> until:1m usages:1
                - flag <player> clickedOption

        - else if <[action].starts_with[/goto]>:
            - define gotoScript "<[action].split[/goto ].get[2].replace_text[/].with[]>"

            - yaml load:quest_schemas/<[file]> id:quest
            - define playerDefinedBlock <yaml[quest].read[<[schema]>.branches.<[gotoScript]>]>
            - yaml id:quest unload

            - clickable save:option until:1m:
                - run SpeechParser_CISK_OLD def.npc:<[npc]> def.handlerBlock:<[playerDefinedBlock]> def.handlerType:playerBlock def.player:<[player]> def.schema:<[schema]> until:1m usages:1
                - flag <player> clickedOption

        - narrate "- <underline><element[<[prompt]>].on_click[<entry[option].command>]>"
        - define optionList:->:<entry[option].id>

    - waituntil <player.has_flag[clickedOption]>

    - foreach <[optionList]>:
        - clickable cancel:<[value]>

    - flag <player> clickedOption:!


SpeechParser_CISK_OLD:
    type: task
    definitions: npc|handlerBlock|handlerType|outerBlock|player|schema|file|fromLine
    script:
    - define fromLine <[fromLine].if_null[0]>

    - define talkSpeedMultiplier 1
    - define interactionAmounts <[npc].flag[playerInteractions].get[<[player]>]>
    - define speech null

    - if <[handlerType]> == playerBlock:
        - define speech <[handlerBlock].get[speech]>

    - else:
        - define speech <[handlerBlock].deep_get[<[interactionAmounts]>.actions].if_null[<[handlerBlock].deep_get[def.actions]>]>

    - define speech <[speech].get[<[fromLine].add[1]>].to[last]>
    - define blockingInterac <[handlerBlock].deep_get[<[interactionAmounts]>.blockingInteraction].if_null[false]>

    # If the entire click trigger has a talkspeed param set it as the default
    # however if each interact step was its own one defined then make it over-
    # ride the upper-level talkSpeed.

    - if <[handlerBlock].contains[talkSpeed]>:
        - define talkSpeedMultiplier <[handlerBlock].get[talkSpeed]>

    - if <[handlerBlock].deep_get[<[interactionAmounts]>.talkSpeed].exists>:
        - define talkSpeedMultiplier <[handlerBlock].deep_get[<[interactionAmounts]>.talkSpeed]>

    - if <[blockingInterac]> && !<[npc].engaged>:
        - engage

    - foreach <[speech]>:
        - define waitTime <proc[WaitTime_CISK].context[<[value]>|<[talkSpeedMultiplier]>].round_to_precision[0.01]>

        - if <[value].as_map.exists>:
            - choose <[value].keys.get[1].to_uppercase>:
                - case OPTIONS:
                    - run OptionsParser_CISK def.npc:<[npc]> def.optionsBlock:<[value]> def.handlerBlock:<[handlerBlock]> def.handlerType:<[handlerType]> def.schema:<[schema]> def.player:<[player]> def.stopPoint:<[loop_index]> def.talkSpeed:<[talkSpeedMultiplier]> def.file:<[file]>
                    - foreach stop

                - case DATA:
                    - yaml load:quest_schemas/<[file]> id:questFile
                    - define isDialogue <yaml[questFile].read[<[schema]>.type].equals[dialogue]>
                    - yaml id:questFile unload

                    - run DataStorageParser_CISK def.npc:<[npc]> def.player:<[player]> def.dataBlock:<[value]> def.isDialogue:<[isDialogue]> def.schemaName:<[schema]>

                - case CONDITIONAL:
                    - run ConditionsHandler_CISK def.npc:<[npc]> def.player:<[player]> def.conditionBlock:<[value]> def.outerBlock:<[speech]> def.schema:<[schema]> def.player:<[player]> def.stopPoint:<[loop_index]> def.talkSpeed:<[talkSpeedMultiplier]> def.file:<[file]>

        - else if <[value].starts_with[/]> && <[value].ends_with[/]>:
            - if <[value]> == /continue/:
                - if <[outerBlock].exists>:
                    - run SpeechParser_CISK_OLD def.npc:<[npc]> def.handlerBlock:<[outerBlock]> def.handlerType:<[handlerType]> def.outerBlock:null def.player:<[player]> def.schema:<[schema]> def.file:<[file]>

                - else:
                    - narrate format:ciskerror "[Internal] Unspecified exit block in file: <[file]>, in schema: <[schema]>, at handler block: <[handlerBlock].keys.get[1]>"

        - else:
            - chat targets:<[player]> talkers:<[npc]> <[value]>
            - wait <[waitTime]>s

    - if <[blockingInterac]> && <[npc].engaged>:
        - disengage


MainParser_CISK_OLD:
    type: task
    definitions: file|schemaName|handler|npc|player
    script:
    - yaml load:quest_schemas/<[file]> id:questFile
    - define questRaw <yaml[questFile].read[<[schemaName]>]>
    - define questKeyList <[questRaw].list_keys>

    - define foundRequiredKeys <list[]>

    - foreach <[questRaw]> key:key:
        - if <[key]>

    - foreach <script[RequiredKeys_CISK].data_key[top]>:
        - if <[questKeyList].contains[<[value]>]>:
            - define foundRequiredKeys:->:<[value]>

    # Turn the required key checker into its own script so it can be
    # run everytime the parser enters a new level in YAML structure.

    - if !<script[RequiredKeys_CISK].data_key[top].size.equals[<[foundRequiredKeys].size>]>:
        - define missingKeys <script[RequiredKeys_CISK].data_key[top].exclude[<[foundRequiredKeys]>]>

        - narrate "CISK Error: Missing <[missingKeys].size.color[red]> key(s) from schema: <[schemaName].color[red]> in file: <[file].color[red]>. Please include the following keys:"
        - narrate <&sp>
        - narrate <[missingKeys].separated_by[,].color[red]>
        - narrate <&sp>
        - narrate "And then re-run the parser."
        - determine cancelled

    - if !<[npc].flag[playerInteractions].get[<[player]>].exists>:
        - flag <[npc]> playerInteractions.<[player]>:0

    - foreach <[questKeyList]> as:key:
        - define value <[questRaw].get[<[key]>]>

        - if <[key]> == <[handler]>:
            - run SpeechParser_CISK_OLD def.npc:<[npc]> def.handlerBlock:<[value]> def.handlerType:<[key]> def.player:<[player]> def.schema:<[schemaName]> def.file:<[file]>

        #- narrate format:debug VAL:<[value]>
        #- narrate format:debug KEY:<[key]>
        #- narrate format:debug ---------------------

    - if <[npc].has_flag[dialogueData]>:
        - flag <[npc]> dialogueData:!


ciskerror:
    type: format
    format: "<&gt><&gt> <bold>CISK ERROR: <gray><[text]>"

ciskerror_noheader:
    type: format
    format: "<red><&gt><&gt> <gray><[text]>"

Debugger_CISK:
    type: task
    script:
    - narrate WIP


CISKAssignment_OLD:
    type: assignment
    actions:
        on click:
        - define file <npc.flag[file]>
        - define schema <npc.flag[schema]>

        - run MainParser_CISK_OLD def.file:<[file]> def.schemaName:<[schema]> def.handler:click def.npc:<npc> def.player:<player>


CISKCommand_OLD:
    type: command
    name: cisk_old
    usage: /cisk_old
    description: "Umbrella command for the CISK Engine"
    tab completions:
        1: assign

    tab complete:
    - define argsList <list[]>

    - if <context.args.get[1]> == assign:
        - define argsList <list[FileName]>

        - if <context.args.size> == 2:
            - define argsList:->:SchemaName

            - if <context.args.size> == 3:
                - define argsList:->:NPCId

    - determine <[argsList]>

    script:
    - define file <context.args.get[2]>
    - define schema <context.args.get[3]>
    - define npc <npc[<context.args.get[4]>]>

    - flag <[npc]> file:<[file]>
    - flag <[npc]> schema:<[schema]>

    - assignment set CISKAssignment_OLD to:<[npc]>