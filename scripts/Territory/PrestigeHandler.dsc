##
## So far, this file holds only the scripts responsible for the prestige degradation mechanic. But
## later when the game starts doing some fancier stuff with prestige, it'll all be pooled here.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Apr 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

PrestigeDegradation_Handler:
    type: world
    events:
        on system time hourly every:24:
        - run GetPrestigeDegradation save:prestigeScales
        - define prestigeScales <entry[prestigeScales].created_queue.determination.get[1]>

        - foreach <[prestigeScales]> key:kingdom as:scale:
            - if <[scale]> > 0:
                - run AddPrestige def.kingdom:<[kingdom]> def.amount:<[scale].div[2]>

            - else:
                - run SubPrestige def.kingdom:<[kingdom]> def.amount:<[scale]>


GetPrestigeDegradation:
    type: task
    description:
    - Generates a set of values for each kingdom on how much prestige they should gain or lose
    - depending on each kingdom's prestige deviation from the average.
    - ---
    - RET: `[MapTag((ElementTag(String)), (ElementTag(Float)))]`

    script:
    ## Generates a set of values for each kingdom on how much prestige they should gain or lose
    ## depending on each kingdom's prestige deviation from the average.
    ##
    ## >>> [MapTag<<ElementTag<String>>, <ElementTag<Float>>>]


    - foreach <proc[GetKingdomList]> as:kingdom:
        - define allPrestige.<[kingdom]> <[kingdom].proc[GetPrestige]>

    - define averagePrestige <[allPrestige].values.average>

    # That is, difference between the prestige and the average
    - define prestigeDiff <[allPrestige].parse_value_tag[<[parse_value].sub[<[averagePrestige]>]>]>

    - define prestigeScales <[prestigeDiff].parse_value_tag[<[parse_value].div[200].round_to_precision[0.001]>]>

    - determine <[prestigeScales]>
