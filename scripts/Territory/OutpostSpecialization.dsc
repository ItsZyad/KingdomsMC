##ignorewarning invalid_data_line_quotes

OutpostSpec_Window:
    type: inventory
    inventory: chest
    gui: true
    title: "Specialize This Outpost"
    slots:
    - [] [] [OutpostSpecFarming_Item] [] [OutpostSpecMining_Item] [] [OutpostSpecLogging_Item] [] []

OutpostSpecFarming_Item:
    type: item
    material: wheat
    display name: "<green><bold>Agriculture Specialization"
    lore:
    - "<white>- Farmer NPCs recieve a <red>25<&pc> <white>bonus to yields"
    - "<red>  Note: Specializing outposts increases their upkeep by 25<&pc>"
    flags:
        specType: farmers

OutpostSpecMining_Item:
    type: item
    material: gold_ingot
    display name: "<gray><bold>Mining Specialization"
    lore:
    - "<white>- Miner NPCs recieve a <red>10<&pc> <white>bonus to yields"
    - "<white>  as well as a <red>15<&pc> <white>increased chance of"
    - "<white>  spawning rare/precious ores."
    - "<red>  Note: Specializing outposts increases their upkeep by 25<&pc>"
    flags:
        specType: miners

OutpostSpecLogging_Item:
    type: item
    material: stick
    display name: "<bold><element[Logging Specialization].color[#743e3e]>"
    lore:
    - "<white>- Player tree chops have a chance of giving double blocks"
    - "<white>- Logger NPCs recieve a <red>25<&pc> <white>yeild increase for"
    - "<white>  trees corresponding to the biome they're in. and a <red>10<&pc>"
    - "<white>  general yield increase."
    - "<red>  Note: Specializing outposts increases their upkeep by 25<&pc>"
    flags:
        specType: loggers

NPCSpecMod:
    type: data
    miners: 1.1|1.15
    loggers: 1.25|1.1
    farmers: 1.25|1

OutpostSpecialize_Handler:
    type: world
    events:
        on player clicks OutpostSpec* in OutpostSpec_Window:
        - yaml load:outposts.yml id:outp
        - define outpost <player.flag[outpostName]>

        - if <player.has_flag[outpostToBeSpeced]>:
            - define outpost <player.flag[outpostToBeSpeced]>

        - yaml id:outp set <player.flag[kingdom]>.<[outpost]>.specType:<context.item.flag[specType]>
        - yaml id:outp set <player.flag[kingdom]>.<[outpost]>.specMod:<script[NPCSpecMod].data_key[<context.item.flag[specType]>]>

        - define currUpkeep <yaml[outp].read[<player.flag[kingdom]>.<[outpost]>.upkeep]>
        - yaml id:outp set <player.flag[kingdom]>.<[outpost]>.upkeep:+:<[currUpkeep].mul[0.25]>

        - yaml id:outp savefile:outposts.yml
        - yaml id:outp unload

        - flag <player> outpostToBeSpeced:!
        - flag <player> outpostName:!
        - inventory close