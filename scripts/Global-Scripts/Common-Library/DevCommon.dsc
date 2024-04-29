##
## [KAPI]
## Common scripts that allow the dev to get and set internal game states and interact with the
## server and worlds directly as opposed to the Kingdoms API.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jun 2023
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

GenerateKingdomsDebug:
    type: task
    debug: false
    definitions: type[?ElementTag(String) = 'DEBUG']|message[ElementTag(String)]|silent[?ElementTag(Boolean) = false]
    description:
    - Writes a given message to the debug console, with 'type' being the debug message type. See the debug command meta for more info: http://meta.denizenscript.com/Docs/Commands/debug.
    - Kingdoms debug messages are silent by default, meaning they do not show to the attached player if they are an admin/op.
    - ---
    - → [Void]

    script:
    ## Writes a given message to the debug console, with 'type' being the debug message type.
    ## See the debug command meta for more info: http://meta.denizenscript.com/Docs/Commands/debug
    ## Kingdoms debug messages are silent by default, meaning they do not show to the attached
    ## player if they are an admin/op.
    ##
    ## message : [ElementTag<String>]
    ## type    : ?[ElementTag<String>]
    ## silent  : ?[ElementTag<Boolean>]
    ##
    ## >>> [Void]

    - define silent <[silent].if_null[false]>
    - define type <[type].if_null[DEBUG]>

    - if !<[message].exists>:
        - determine cancelled

    - define messagePrefix <element[[Kingdoms Debug] <&gt><&gt> ]>
    - define messagePrefix <[messagePrefix].color[yellow]>
    - define messagePrefix <[messagePrefix].color[red]> if:<[type].to_lowercase.equals[error]>
    - define messagePrefix <[messagePrefix].color[gray]> if:<[type].to_lowercase.equals[log]>

    - define formattedMessage <element[<[messagePrefix]><[message]>]>
    - debug LOG <[formattedMessage]>

    - if !<[silent]> && <player.exists> && <player.has_permission[kingdoms.admin]>:
        - narrate <[formattedMessage]>


InternalErrorTypes:
    type: data
    enum:
    - GenericError
    - TypeError
    - ValueError


DefaultInternalErrorMessages:
    type: data
    errors:
        GenericError: An internal error has occurred.
        TypeError: A value is of an invalid type.
        ValueError: A value provided cannot is invalid.


GenerateInternalError:
    type: task
    debug: false
    definitions: category[ElementTag(String)]|message[?ElementTag(String) = 'An internal error has occurred.']|silent[?ElementTag(Boolean) = false]
    description:
    - Writes a given message to the debug console with the 'ERROR' type and the provided internal error code.
    - Narrates this message to the attached player if they are an have the kingdoms.admin permission or are ops when silent is provided as 'true'.
    - silent is set to 'false' by default.
    - ---
    - → [Void]

    script:
    #TODO: Update this docstring
    ## Writes a given message to the debug console with the 'ERROR' type and the provided internal
    ## error code. Narrates this message to the attached player if they are an have the
    ## kingdoms.admin permission or are ops when silent is provided as 'true'. silent is set to 'false'
    ## by default
    ##
    ## category     : [ElementTag<String>]
    ## message      : ?[ElementTag<String>]
    ## silent       : ?[ElementTag<Boolean>]
    ##
    ## >>> [Void]

    - define silent <[silent].if_null[false]>
    - define errorType <proc[Enum].context[InternalErrorTypes.<[category]>|true]>
    - define message <[message].if_null[<script[DefaultInternalErrorMessages].data_key[errors.<[errorType]>]>]>

    - define messagePrefix <element[[Kingdoms Internal <[errorType].color[gold]>] <&gt><&gt> ].color[red]>
    - define formattedMessage <[messagePrefix]><[message].color[#ff7070]>

    - debug LOG <[formattedMessage]>
    - debug LOG " "

    - if !<[silent]>:
        - narrate <[formattedMessage]>


ActionBarToggler:
    type: task
    debug: false
    definitions: player[PlayerTag]|message[ElementTag]|toggleType[?ElementTag(String)]
    description:
    - Toggles a consistent message to be displayed to the player's actionbar based on the toggleType provided.
    - If no toggleType is provided then the script will disable any enabled actionbar message.
    - ---
    - → [Void]

    script:
    ## Toggles a consistent message to be displayed to the player's actionbar based on the
    ## toggleType provided. If no toggleType is provided then the script will disable any enabled
    ## actionbar message.
    ##
    ## player     : [PlayerTag]
    ## message    : [ElementTag]
    ## toggleType : ?[ElementTag<String>]
    ##
    ## >>> [Void]

    - define toggleType <[toggleType].if_null[false]>

    - if <[toggleType]>:
        - flag <[player]> datahold.persistentActionbar

    - else:
        - flag <[player]> datahold.persistentActionbar:!

    - define existingActionbar <n><player.flag[datahold.actionbar].if_null[<element[]>]>

    - while <[player].has_flag[datahold.persistentActionBar]>:
        - actionbar <element[<[message]><[existingActionbar]>]> targets:<[player]>
        - wait 2s
        - define existingActionbar <element[]>


Actionbar_Handler:
    type: world
    debug: false
    events:
        on player receives actionbar:
        - flag <player> datahold.actionbar:<context.message> expire:2s


Enum:
    type: procedure
    definitions: enumKey[ElementTag(String)]|useDefault[?ElementTag(Boolean) = false]
    description:
    - Gets the data from the specified enum key. enum keys are dot-operated, meaning that the key: 'TerritoryType.Core' will get the Core constant inside the TerritoryType enum.
    - If useDefault is set to true, the procedure will use the first key in the enum as a default value.
    - useDeafult is set to false by default.
    - ---
    - → [?ElementTag(String) = null]

    script:
    ## Gets the data from the specified enum key. enum keys are dot-operated, meaning that the key:
    ## 'TerritoryType.Core' will get the Core constant inside the TerritoryType enum. If useDefault
    ## is set to true, the procedure will use the first key in the enum as a default value.
    ## useDeafult is set to false by default.
    ##
    ## Example usage:
    ## - define enumKey <proc[Enum].context[InternalErrorTypes.Generic]>
    ##
    ## enumKey    : [ElementTag<String>]
    ## useDefault : ?[ElementTag<Boolean>]
    ##
    ## >>> ?[ElementTag<String>]

    - define splitKey <[enumKey].split[.]>
    - define enum <[splitKey].get[1]>
    - define useDefault <[useDefault].if_null[false]>

    - if !<script[<[enum]>].exists>:
        - determine null

    - define key <[splitKey].get[2]>
    - define keyIndex <script[<[enum]>].data_key[enum].find[<[key]>]>

    - if <[keyIndex].exists>:
        - determine <script[<[enum]>].data_key[enum].get[<[keyIndex]>]>

    - if !<[useDefault]>:
        - determine null

    - determine <script[<[enum]>].data_key[enum].get[1]>


EnforceType:
    type: procedure
    definitions: def[ObjectTag]|type[ElementTag(String)]|subtype[?ElementTag(String)]
    description:
    - Returns the definition passed into it if its type matches the type passed in. Additionally, a Kingdoms-standard subtype can be provided (only applicable for ElementTags) to further isolate a type.
    - If the definition provided does not match the type provided, the procedure will return null.
    - ---
    - → [ObjectTag]

    script:
    ## Returns the definition passed into it if its type matches the type passed in. Additionally,
    ## a Kingdoms-standard subtype can be provided (only applicable for ElementTags) to further
    ## isolate a type. If the definition provided does not match the type provided, the procedure
    ## will return null.
    ##
    ## def     : [ObjectTag]
    ## type    : [ElementTag<String>]
    ## subtype : ?[ElementTag<String>]
    ##
    ## >>> [ObjectTag]

    - define type <[type].to_lowercase>
    - define actualType <[def].object_type.to_lowercase>
    - define subtype <[subtype].to_lowercase> if:<[subtype].exists>

    - if <[actualType]> != <[type]>:
        - determine null

    - if <[actualType]> != element || !<[subtype].exists>:
        - determine <[def]>

    - choose <[subtype]>:
        - case string:
            - determine <[def]>

        - case integer:
            - if <[def].is_integer>:
                - determine <[def]>

        - case float:
            - if <[def].is_decimal>:
                - determine <[def]>

        - case boolean:
            - if <[def].is_boolean>:
                - determine <[def]>

    - determine null

##ignorewarning enumerated_script_name

debug:
    type: format
    format: <gray>[Kingdoms Debug] <&gt><&gt> <[text]>


admincallout:
    type: format
    format: <light_purple>[Kingdoms Admin] <&gt><&gt><white> <[text]>


callout:
    type: format
    format: <white>[Kingdoms] <&gt><&gt> <&6><[text]>


warning:
    type: format
    format: <red>[Kingdoms] <&gt><&gt><white> <[text]>


notice:
    type: format
    format: <yellow>[Kingdoms] <&gt><&gt><white> <[text]>


npctalk:
    type: format
    format: <light_purple><bold>[NPC] <&r><red>-<&gt> <light_purple><bold>[YOU]: <white><[text]>