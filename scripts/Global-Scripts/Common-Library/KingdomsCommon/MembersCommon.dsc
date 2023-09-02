##
## [KAPI]
## Common scripts, tasks, and procedures relating to the membership of a kingdom.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2023
## @Script Ver: v1.0
##
## ----------------END HEADER-----------------

GetMembers:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    script:
    ## Returns a list of all the members currently in the kingdom
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ListTag<PlayerTag>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot get kingdom members. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.members]>


AddMember:
    type: task
    definitions: kingdom[ElementTag(String)]|player[PlayerTag]
    script:
    ## Adds a player to a given kingdom
    ##
    ## kingdom : [ElementTag<String>]
    ## player  : [PlayerTag]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot add kingdom member. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if !<[player].as[player].is_in[<server.players>]>:
        - run GenerateInternalError def.category:ValueError message:<element[No player exists with matcher: <[player]>]>
        - determine cancelled

    - flag server kingdoms.<[kingdom]>.members:->:<[player]>
    - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


RemoveMember:
    type: task
    definitions: kingdom[ElementTag(String)]|player[PlayerTag]
    script:
    ## Removes the given player from a kingdom if they are a member.
    ##
    ## kingdom : [ElementTag<String>]
    ## player  : [PlayerTag]
    ##
    ## >>> [Void]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot remove kingdom member. Invalid kingdom code provided: <[kingdom]>]>
        - determine cancelled

    - if !<[player].as[player].is_in[<server.players>]>:
        - run GenerateInternalError def.category:ValueError message:<element[No player exists with matcher: <[player]>]>
        - determine cancelled

    - if <proc[GetMembers].context[<[kingdom]>].contains[<[player]>]>:
        - flag server kingdoms.<[kingdom]>.members:<-:<[player]>
        - run SidebarLoader def.target:<server.flag[kingdoms.<[kingdom]>.members].include[<server.online_ops>]>


GetAllMembers:
    type: procedure
    script:
    ## Returns a list of all the members in all kingdoms
    ##
    ## >>> [ListTag<PlayerTag>]

    - determine <proc[GetKingdomList].parse_tag[<server.flag[kingdoms.<[parse_value]>.members]>].combine.deduplicate>


IsPlayerInKingdom:
    type: procedure
    definitions: kingdom[ElementTag(String)]|player[PlayerTag]
    script:
    ## Returns true if the provided player is in the provided kingdom.
    ##
    ## kingdom : [ElementTag<String>]
    ## player  : [PlayerTag]
    ##
    ## >>> [ElementTag<Boolean>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError message:<element[Cannot check player-kingdom relationship. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<[player].as[player].is_in[<server.players>]>:
        - run GenerateInternalError def.category:ValueError message:<element[No player exists with matcher: <[player]>]>
        - determine null

    - define playerList <proc[GetMembers].context[<[kingdom]>]>

    - determine <[player].is_in[<[playerList]>]>
