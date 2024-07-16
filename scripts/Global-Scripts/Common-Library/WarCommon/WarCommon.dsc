##
## [KAPI]
## This module contains all KAPI scripts relating to the political aspect of war in Kingdoms such
## as declarations, justifications, and active war tracking.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jul 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

IsAtWarWithKingdom:
    type: procedure
    definitions: kingdom[ElementTag(String)]|otherKingdom[ElementTag(String)]
    description:
    - Returns true if the provided kingdom is at war with the other provided kingdom.
    - ---
    - [ElementTag(Boolean)]

    script:
    ## Returns true if the provided kingdom is at war with the other provided kingdom.
    ##
    ## kingdom      : [ElementTag<String>]
    ## otherKingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot check if kingdom is at war. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - if !<proc[ValidateKingdomCode].context[<[otherKingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot check if kingdom is at war. Invalid kingdom code provided: <[otherKingdom]>]>
        - determine null

    - foreach <[kingdom].proc[GetKingdomWars]> as:warID:
        - if <[warID].proc[GetWarParticipants].contains[<[otherKingdom]>]>:
            - determine true

    - determine false


GetKingdomWarStatus:
    type: procedure
    debug: false
    definitions: kingdom[ElementTag(String)]
    description:
    - Returns true if the provided kingdom is currently at war.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns true if the provided kingdom is currently at war.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom war status. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    - determine <server.flag[kingdoms.<[kingdom]>.warStatus].if_null[false]>


GetKingdomWars:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    description:
    - Returns a list of the ids of all the active wars that the kingdom with the provided name is currently involved in.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Returns a list of the names of all the active wars that the kingdom with the provided name
    ## is currently involved in.
    ##
    ## kingdom : [ElementTag<String>]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - if !<proc[ValidateKingdomCode].context[<[kingdom]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get kingdom war list. Invalid kingdom code provided: <[kingdom]>]>
        - determine null

    # This will only contain IDs, but actual war data will be contained within kingdoms.wars
    - determine <server.flag[kingdoms.<[kingdom]>.wars].if_null[<list[]>]>


GetWarBelligerents:
    type: procedure
    definitions: warID[ElementTag(String)]
    description:
    - Returns the names of all the kingdoms that initiated the war with the provided ID.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Returns the names of all the kingdoms that initiated the war with the provided ID.
    ##
    ## warID : [ElementTag<String>]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine <list[]>

    - determine <server.flag[kingdoms.wars.<[warID]>.belligerents]>


GetWarRetaliators:
    type: procedure
    definitions: warID[ElementTag(String)]
    description:
    - Returns the names of all the kingdoms that were declared on in the war with the provided ID.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Returns the names of all the kingdoms that were declared on in the war with the provided ID.
    ##
    ## warID : [ElementTag<String>]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine <list[]>

    - determine <server.flag[kingdoms.wars.<[warID]>.retaliators]>


GetWarParticipants:
    type: procedure
    definitions: warID[ElementTag(String)]
    description:
    - Returns the names of all the kingdoms involved in the war with the provided ID.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Returns the names of all the kingdoms involved in the war with the provided ID.
    ##
    ## warID : [ElementTag<String>]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine <list[]>

    - determine <[warID].proc[GetWarRetaliators].include[<[warID].proc[GetWarRetaliators]>]>


GetWarStartDate:
    type: procedure
    definitions: warID[ElementTag(String)]
    description:
    - Returns the names of all the kingdoms involved in the war with the provided ID.
    - ---
    - → ?[TimeTag]

    script:
    ## Returns the names of all the kingdoms involved in the war with the provided ID.
    ##
    ## warID : [ElementTag<String>]
    ##
    ## >>> ?[TimeTag]

    - if <server.flag[kingdoms.wars.<[warID]>].if_null[<list[]>].is_empty>:
        - determine null

    - determine <server.flag[kingdom.wars.<[warID]>.start]>
