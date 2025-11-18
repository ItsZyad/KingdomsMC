##
## [KAPI]
## Common scripts, tasks, and procedures relating to the membership of a kingdom.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2023
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

GetMembers:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Returns a list of all the members currently in the kingdom.
    - ---
    - → [ListTag(PlayerTag)]

    script:
    ## Returns a list of all the members currently in the kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ListTag<PlayerTag>]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom members. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.members].if_null[<list[]>]>


AddMember:
    type: task
    debug: false
    definitions: kingdom[ElementTag(String)]|player[PlayerTag]
    description:
    - Adds a player to a given kingdom.
    - ---
    - → [Void]

    script:
    ## Adds a player to a given kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ## player  : [PlayerTag]
    ##
    ## >>> [Void]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot add kingdom member. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if !<[player].as[player].is_in[<server.players>]>:
        - run GenerateInternalError def.category:ValueError def.message:<element[No player exists with matcher: <[player]>]>
        - determine cancelled

    - if <[player].is_in[<[kingdom].proc[GetMembers]>]>:
        - determine cancelled

    - flag <[player]> kingdom:<[kingdom]>
    - flag server kingdoms.<[kingdom]>.members:->:<[player]>
    - run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>]>


RemoveMember:
    type: task
    debug: false
    definitions: kingdom[ElementTag(String)]|player[PlayerTag]
    description:
    - Removes the given player from a kingdom if they are a member.
    - ---
    - → [Void]

    script:
    ## Removes the given player from a kingdom if they are a member.
    ##
    ## kingdom : [ElementTag<String>]
    ## player  : [PlayerTag]
    ##
    ## >>> [Void]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot remove kingdom member. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if !<[player].as[player].is_in[<server.players>]>:
        - run GenerateInternalError def.category:ValueError def.message:<element[No player exists with matcher: <[player]>]>
        - determine cancelled

    - if <proc[GetMembers].context[<[kingdom]>].contains[<[player]>]>:
        - flag server kingdoms.<[kingdom]>.members:<-:<[player]>
        - flag <[player]> kingdom:!
        - run SidebarLoader def.target:<[kingdom].proc[GetMembers].include[<server.online_ops>].include[<[player]>]>


GetAllMembers:
    type: procedure
    debug: false
    description:
    - Returns a list of all the members in all kingdoms.
    - ---
    - → [ListTag(PlayerTag)]

    script:
    ## Returns a list of all the members in all kingdoms.
    ##
    ## >>> [ListTag<PlayerTag>]

    - determine <proc[GetKingdomList].parse_tag[<server.flag[kingdoms.<[parse_value]>.members]>].combine.deduplicate>


SetKing:
    type: task
    debug: false
    definitions: kingdom[ElementTag(String)]|player[PlayerTag]
    description:
    - Sets a player as king of the provided kingdom. However the provided player must already be a member of the provided kingdom.
    - ---
    - → [Void]

    script:
    ## Sets a player as king of the provided kingdom. However the provided player must already be a
    ## member of the provided kingdom.
    ##
    ## kingdom : [ElementTag(String)]
    ## player  : [PlayerTag]
    ##
    ## >>> [Void]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot set king. Invalid kingdom code provided: <[kingdom].color[red]>]>
        - determine cancelled

    - if !<[player].as[player].is_in[<server.players>]>:
        - run GenerateInternalError def.category:ValueError def.message:<element[Cannot set king. No player exists with matcher: <[player].color[red]>]>
        - determine cancelled

    - if !<[player].as[player].is_in[<[kingdom].proc[GetMembers]>]>:
        - run GenerateInternalError def.category:ValueError def.message:<element[Cannot set king. Provided player: <[player].color[red]> is not a member of the provided kingdom: <[kingdom].color[aqua]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.king:<[player]>


GetKing:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Returns the PlayerTag associated with the person currently kin of the provided kingdom.
    - Returns null if the provided kingdom does not currently have a king.
    - ---
    - → ?[PlayerTag]

    script:
    ## Returns the PlayerTag associated with the person currently kin of the provided kingdom.
    ##
    ## Returns null if the provided kingdom does not currently have a king.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> ?[PlayerTag]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get king. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.king].if_null[null]>


IsPlayerInKingdom:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]|player[PlayerTag]
    description:
    - Returns true if the provided player is in the provided kingdom.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns true if the provided player is in the provided kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ## player  : [PlayerTag]
    ##
    ## >>> [ElementTag<Boolean>]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot check player-kingdom relationship. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<[player].as[player].is_in[<server.players>]>:
        - run GenerateInternalError def.category:ValueError def.message:<element[No player exists with matcher: <[player]>]>
        - determine null

    - define playerList <proc[GetMembers].context[<[kingdom]>]>

    - determine <[player].is_in[<[playerList]>]>


IsPlayerKing:
    type: procedure
    debug: false
    definitions: player[PlayerTag]
    description:
    - Returns true if the provided player is the king of their kingdom.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns true if the provided player is the king of their kingdom.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [ElementTag<Boolean>]

    - define kingdom <player.flag[kingdom]>

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot check if a player is king. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.king].equals[<player>].if_null[false]>
