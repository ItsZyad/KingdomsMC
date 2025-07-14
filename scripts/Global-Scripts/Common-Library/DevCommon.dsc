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
    definitions: category[ElementTag(String)]|message[?ElementTag(String) = 'An internal error has occurred.']|silent[?ElementTag(Boolean) = false]|formatAsError[?ElementTag(Boolean) = false]
    description:
    - Writes a given message to the debug console with the 'ERROR' type and the provided internal error code.
    - Narrates this message to the attached player if they are an have the kingdoms.admin permission or are ops when silent is provided as 'true'.
    - silent is set to 'false' by default.
    - If the error is narrated with silent set to 'false', the message that appears in chat will not be formatted as an internal error unless 'formatAsError' is set to true.
    - ---
    - → [Void]

    script:
    #TODO: Update this docstring
    ## Writes a given message to the debug console with the 'ERROR' type and the provided internal
    ## error code. Narrates this message to the attached player if they are an have the
    ## kingdoms.admin permission or are ops when silent is provided as 'true'. silent is set to 'false'
    ## by default
    ##
    ## If the error is narrated with silent set to 'false', the message that appears in chat will
    ## not be formatted as an internal error unless 'formatAsError' is set to true.
    ##
    ## category      :  [ElementTag<String>]
    ## message       : ?[ElementTag<String>]
    ## silent        : ?[ElementTag<Boolean>]
    ## formatAsError : ?[ElementTag<Boolean>]
    ##
    ## >>> [Void]

    - define silent <[silent].if_null[false]>
    - define formatAsError <[formatAsError].if_null[false]>

    - define errorType <proc[Enum].context[InternalErrorTypes.<[category]>|true]>
    - define message <[message].if_null[<script[DefaultInternalErrorMessages].data_key[errors.<[errorType]>]>]>

    - define messagePrefix <element[[Kingdoms Internal <[errorType].color[gold]>] <&gt><&gt> ].color[red]>
    - define formattedMessage <[messagePrefix]><[message].color[#ff7070]>

    - debug LOG <[formattedMessage]>
    - debug LOG " "

    - if !<[silent]>:
        - if !<[formatAsError]>:
            - narrate format:warning <[message]>

        - else:
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
    ## player     :  [PlayerTag]
    ## message    :  [ElementTag]
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
    debug: false
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


ColorPalettes:
    type: data
    Colors:
        Default:
            white: f0f0f0
            light_gray: 8f8f86
            gray: 3c4247
            black: 0b0c11
            brown: 79441e
            red: b21810
            orange: f8730b
            yellow: fac51f
            lime: 71c808
            green: 536f14
            cyan: 07939d
            light_blue: 22b6ea
            blue: 2529a6
            purple: 7f19bc
            magenta: ca31bb
            pink: f889aa

        # All color palettes' keys must be equal to or supersets of Default's keys.
        Vintage:
            white: dddddd
            light_gray: 8f8f86
            gray: 8a96a7
            dark_gray: 534f58
            black: 232323
            brown: 795a51
            red: CE4D45
            light_red: e8888b
            orange: F19C65
            gold: E8CA00
            yellow: FFD265
            lime: 71c808
            light_green: 8BC34A
            green: 2AA876
            cyan: 07939d
            light_blue: a2acca
            blue: 0A7B83
            purple: 8a638c
            magenta: ca31bb
            pink: f889aa


GetColor:
    type: procedure
    debug: false
    definitions: colorPath[ElementTag(String)]
    description:
    - Gets a color from one of the Kingdoms-standard color palettes using standard dot notation, structured like: (palette).(color)
    - ---
    - → [ElementTag(String)]

    script:
    ## Gets a color from one of the Kingdoms-standard color palettes using standard dot notation,
    ## structured like: <palette>.<color>
    ##
    ## colorPath: [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - if <[colorPath].split[.].size> != 2:
        - determine #eeeeee

    - if <script[ColorPalettes].data_key[Colors.<[colorPath]>].exists>:
        - determine #<script[ColorPalettes].data_key[Colors.<[colorPath]>]>

    - else:
        - determine #ffffff


SkinnyLetters:
    type: data
    Upper:
        Q: 𝖰
        W: 𝖶
        E: 𝖤
        R: 𝖱
        T: 𝖳
        Y: 𝖸
        U: 𝖴
        I: 𝖨
        O: 𝖮
        P: 𝖯
        A: 𝖠
        S: 𝖲
        D: 𝖣
        F: 𝖥
        G: 𝖦
        H: 𝖧
        J: 𝖩
        K: 𝖪
        L: 𝖫
        Z: 𝖹
        X: 𝖷
        C: 𝖢
        V: 𝖵
        B: 𝖡
        N: 𝖭
        M: 𝖬
    Lower:
        q: 𝗊
        w: 𝗐
        e: 𝖾
        r: 𝗋
        t: 𝗍
        y: 𝗒
        u: 𝗎
        i: 𝗂
        o: 𝗈
        p: 𝗉
        a: 𝖺
        s: 𝗌
        d: 𝖽
        f: 𝖿
        g: 𝗀
        h: 𝗁
        j: 𝗃
        k: 𝗄
        l: 𝗅
        z: 𝗓
        x: 𝗑
        c: 𝖼
        v: 𝗏
        b: 𝖻
        n: 𝗇
        m: 𝐦
    Number:
        1: 𝟣
        2: 𝟤
        3: 𝟥
        4: 𝟦
        5: 𝟧
        6: Ꮾ
        7: 𝟩
        8: 𝟪
        9: 𝟫
        0: 𝖮


ConvertToSkinnyLetters:
    type: procedure
    debug: false
    definitions: text[ElementTag(String)]
    description:
    - Returns the provided text but with all valid letters made into 'skinny' letters.
    - ---
    - [ElementTag(String)]

    script:
    ## Returns the provided text but with all valid letters made into 'skinny' letters.
    ##
    ## text : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    # TODO: Look into using .replace_text to convert to skinny letters without removing formats
    - define specialChars <list[,|!|*|.|:|/|(|)]>
    - define smallSpecialChars <list[ˏ|ǃ|∗|܂|∶|𐒃|❲|❳]>

    - define splitted <[text].split[]>
    - define output <list[]>

    - foreach <[splitted]> as:char:
        - if <script[SkinnyLetters].data_key[Lower].keys.contains_case_sensitive[<[char]>]>:
            - define output:->:<script[SkinnyLetters].data_key[Lower.<[char]>]>

        - else if <script[SkinnyLetters].data_key[Upper].keys.contains_case_sensitive[<[char]>]>:
            - define output:->:<script[SkinnyLetters].data_key[Upper.<[char]>]>

        - else if <script[SkinnyLetters].data_key[Number].keys.contains_case_sensitive[<[char]>]>:
            - define output:->:<script[SkinnyLetters].data_key[Number.<[char]>]>

        - else if <[char].is_in[<[specialChars]>]>:
            - define output:->:<[smallSpecialChars].get[<[specialChars].find[<[char]>]>]>

        - else:
            - define output:->:<[char]>

    - determine <[output].unseparated>


##ignorewarning enumerated_script_name

debug:
    type: format
    debug: false
    format: <gray>[Kingdoms Debug] <&gt><&gt> <[text]>


admincallout:
    type: format
    debug: false
    format: <light_purple>[Kingdoms Admin] <&gt><&gt><white> <[text]>


callout:
    type: format
    debug: false
    format: <white>[Kingdoms] <&gt><&gt> <&6><[text]>


warning:
    type: format
    debug: false
    format: <red>[Kingdoms] <&gt><&gt><white> <[text]>


notice:
    type: format
    debug: false
    format: <yellow>[Kingdoms] <&gt><&gt><white> <[text]>


npctalk:
    type: format
    debug: false
    format: <light_purple><bold>[NPC] <&r><red>-<&gt> <light_purple><bold>[YOU]: <white><[text]>