##
## Contains all scripts related to specializing an outpost.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Mar 2023
## @Updated: Jan 2025
## @Script Ver: v2.0
##
## ------------------------------------------END HEADER-------------------------------------------

OutpostSpec_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Specialize This Outpost
    slots:
    - [] [] [OutpostSpecFarming_Item] [] [OutpostSpecMining_Item] [] [OutpostSpecLogging_Item] [] []
    - [] [] [] [] [Back_Item] [] [] [] []


OutpostSpecFarming_Item:
    type: item
    material: wheat
    display name: <green><bold>Agriculture Specialization
    lore:
    - <white>- Farmer NPCs recieve a <red>25<&pc> <white>bonus to yields.
    - <red>Note: Specializing outposts increases their upkeep by 25<&pc>.
    - <white><bold>Upgrade Cost: <light_purple>$<proc[CalculateOutpostSpecializationCost].context[<player.flag[kingdom]>|<player.flag[datahold.outpostSpec.name]>].format_number>

    flags:
        specType: farmers
        specNoun: Agriculture


OutpostSpecMining_Item:
    type: item
    material: gold_ingot
    display name: <gray><bold>Mining Specialization
    lore:
    - <white>- Miner NPCs recieve a <red>10<&pc> <white>bonus to yields
    - <white>  as well as a <red>15<&pc> <white>increased chance of
    - <white>  spawning rare/precious ores.
    - <red>Note: Specializing outposts increases their upkeep by 25<&pc>.
    - <white><bold>Upgrade Cost: <light_purple>$<proc[CalculateOutpostSpecializationCost].context[<player.flag[kingdom]>|<player.flag[datahold.outpostSpec.name]>].format_number>

    flags:
        specType: miners
        specNoun: Mining


OutpostSpecLogging_Item:
    type: item
    material: stick
    display name: <bold><element[Logging Specialization].color[#743e3e]>
    lore:
    - <white>- Player tree chops have a chance of giving double blocks
    - <white>- Logger NPCs recieve a <red>25<&pc> <white>yeild increase for
    - <white>  trees corresponding to the biome they're in. and a <red>10<&pc>
    - <white>  general yield increase.
    - <red>Note: Specializing outposts increases their upkeep by 25<&pc>.
    - <white><bold>Upgrade Cost: <light_purple>$<proc[CalculateOutpostSpecializationCost].context[<player.flag[kingdom]>|<player.flag[datahold.outpostSpec.name]>].format_number>

    flags:
        specType: loggers
        specNoun: Logging


NPCSpecMod:
    type: data
    miners: 1.1|1.15
    loggers: 1.25|1.1
    farmers: 1.25|1


CalculateOutpostSpecializationCost:
    type: procedure
    definitions: kingdom[ElementTag(String)]|outpost[ElementTag(String)]
    description:
    - Returns the amount of money needed by the provided kingdom to specialize the provided outpost.
    - Will return null if the action fails.
    - ---
    - → ?[ElementTag(Float)]

    script:
    ## Returns the amount of money needed by the provided kingdom to specialize the provided
    ## outpost.
    ##
    ## Will return null if the action fails.
    ##
    ## kingdom : [ElementTag(String)]
    ## outpost : [ElementTag(String)]
    ##
    ## >>> ?[ElementTag(Float)]

    - if !<proc[IsKingdomCodeValid].context[<[kingdom]>]>:
        - determine null

    - if !<proc[DoesOutpostExist].context[<[kingdom]>|<[outpost]>]>:
        - determine null

    - define respecMultiplier 1

    - if <proc[GetOutpostSpecialization].context[<[kingdom]>|<[outpost]>]> != None:
        - define respecMultiplier <proc[GetConfigNode].context[Territory.outpost-respec-multiplier]>

    - define outpostVol <proc[GetOutpostArea].context[<[kingdom]>|<[outpost]>].volume>
    - define scaledPrestige <proc[GetPrestige].context[<[kingdom]>].div[100].if_null[0]>

    - determine <[outpostVol].sqrt.round.power[<element[1].sub[<[scaledPrestige]>]>].mul[<[respecMultiplier]>]>


OutpostSpecialize_Handler:
    type: world
    events:
        on player clicks OutpostSpec* in OutpostSpec_Window:
        - define outpost <player.flag[datahold.outpostSpec.name]>
        - define kingdom <player.flag[kingdom]>
        - define currUpkeep <server.flag[kingdoms.<[kingdom]>.outposts.outpostList.<[outpost]>.upkeep]>

        - run SetOutpostSpecialization def.kingdom:<[kingdom]> def.outpost:<[outpost]> def.spec:<context.item.flag[specType]>
        - run SetOutpostSpecializationModifier def.kingdom:<[kingdom]> def.outpost:<[outpost]> def.modifier:<script[NPCSpecMod].data_key[<context.item.flag[specType]>]>
        - run SubUpkeep def.kingdom:<[kingdom]> def.amount:<proc[GetOutpostUpkeep].context[<[kingdom]>|<[outpost]>]>
        - run SetOutpostUpkeep def.kingdom:<[kingdom]> def.outpost:<[outpost]> def.amount:<proc[GetOutpostUpkeep].context[<[kingdom]>|<[outpost]>].mul[1.25]>
        - run AddUpkeep def.kingdom:<[kingdom]> def.amount:<proc[GetOutpostUpkeep].context[<[kingdom]>|<[outpost]>]>

        - narrate format:callout "Specialized outpost: <[outpost].color[red]> in: <context.item.flag[specNoun].color[gold]>"

        - inventory close

        on player clicks Back_Item in OutpostSpec_Window:
        - run OutpostList def.player:<player>
