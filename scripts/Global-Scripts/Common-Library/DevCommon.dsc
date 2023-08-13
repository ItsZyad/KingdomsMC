##
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
    definitions: type|message|silent
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
    - run debug_debug def.type:<[type]> def.formattedMessage:<[formattedMessage]>

    - if !<[silent]> && <player.exists> && <player.has_permission[kingdoms.admin]>:
        - narrate <[formattedMessage]>


# wow so meta...
DEBUG_DEBUG:
    type: task
    definitions: type|formattedMessage
    script:
    - debug DEBUG --------------------------
    - debug type:<[type]> <[formattedMessage]>


InternalErrorCategories_Data:
    type: data
    errorCats:
        generic: GEN
        internal: INT
        squads: SQA
        armies: SQA
        quests: QUE
        npcs: NPC
        rnpcs: NPC
        territory: TER
        economy: ECO
        blackmarket: BMA
        powerstrugle: PWR


GenerateInternalError:
    type: task
    definitions: message|silent|category|id|codeOverride
    script:
    #TODO: Update this docstring
    ## Writes a given message to the debug console with the 'ERROR' type and the provided internal
    ## error code. Narrates this message to the attached player if they are an have the
    ## kingdoms.admin permission or are ops when silent is provided as 'true'. It is set to 'false'
    ## by default
    ##
    ## id           : [ElementTag<Integer>]
    ## category     : [ElementTag<String>]
    ## message      : ?[ElementTag<String>]
    ## silent       : ?[ElementTag<Boolean>]
    ## codeOverride : ?[ElementTag<Boolean>]
    ##
    ## >>> [Void]

    - define silent <[silent].if_null[false]>
    - define categoryCode <script[InternalErrorCategories_Data].data_key[errorCats.<[category]>]>
    - define codeOverride <[codeOverride].if_null[false]>

    - if !<[categoryCode].exists>:
        - run GenerateInternalError def.message:<element[Cannot generate internal error: CatCode not provided]> def.id:001B def.category:internal def.silent:false
        - determine cancelled

    - if !<[id].exists>:
        - run GenerateInternalError def.message:<element[Cannot generate internal error: ID not provided]> def.id:001A def.category:internal def.silent:false
        - determine cancelled

    - define messagePrefix <element[[Internal Error <[categoryCode]><[id]>] <&gt><&gt>].color[red]>

    - if <server.has_flag[kingdomsCache.errorCodes.<[categoryCode]><[id]>]> && !<[codeOverride]>:
        - define formattedMessage <[messagePrefix]><server.flag[kingdomsCache.errorCodes.<[categoryCode]><[id]>]>

    - else:
        - define formattedMessage <[messagePrefix]><[message].color[white]>
        - flag server kingdomsCache.errorCodes.<[categoryCode]><[id]>:<[formattedMessage]>

    - debug DEBUG --------------------------
    - debug ERROR <[formattedMessage]>

    - if !<[silent]>:
        - narrate <[formattedMessage]>


ActionBarToggler:
    type: task
    debug: false
    definitions: player|message|toggleType
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
    definitions: enumKey
    script:
    ## Gets the data from the specified enum key. enum keys are dot-operated, meaning that the key:
    ## 'TerritoryType.Core' will get the Core constant inside the TerritoryType enum.
    ##
    ## enumKey : [ElementTag<String>]
    ##
    ## >>> ?[ElementTag<String>]

    - define splitKey <[enumKey].split[.]>
    - define enum <[splitKey].get[1]>

    - if !<script[<[enum]>].exists>:
        - determine null

    - define key <[splitKey].get[2]>
    - define keyIndex <script[<[enum]>].data_key[enum].find[<[key]>]>

    - if !<[keyIndex].exists>:
        - determine null

    - determine <script[<[enum]>].data_key[enum].get[<[keyIndex]>]>
