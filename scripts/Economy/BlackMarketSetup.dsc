# !Todo: [Later] Move this to the admin commands file when it's cleaned-up
##ignorewarning raw_object_notation
##ignorewarning deprecated_tag_part

## No header will be added :: File slated for deletion / rework.

SpecifySpawnLoc_Command:
    type: command
    name: specify
    usage: /specify
    description: Specify Black Market Merchant Spawn Location
    permission: kingdoms.admin.specify
    tab completions:
        1: MerchantType|help
        2: orama|totalist|syndicates|blackstone
    script:
    - if <context.args.get[1]> == help:
        - narrate "<&n>                                       <&n.end_format>"
        - narrate <&sp>
        - narrate format:admincallout "Used to specify the location of black market merchants and their faction affiliation"
        - narrate "<gray>Command format: <blue>/specify"
        - narrate "1: <gold><&lt>MerchantType<&gt>"
        - narrate "2: <gold><&lt>FactionAffiliation<&gt> <red>{orama/totalist/syndicates/blackstone}"
        - narrate "<&n>                                       <&n.end_format>"
        - narrate <&sp>

    - else:
        - yaml load:blackmarket-formatted.yml id:bm
        - define validFactions <list[orama|blackstone|syndicates|totalist]>
        - define merchantType <context.args.get[1]>
        - define selectedFaction <context.args.get[2]>

        - define isValidFaction false
        - define isValidLocation false

        # Checks if the location is already present in the file #
        - if !<yaml[bm].read[spawnlocation.<[merchantType]>].contains[<player.location.center>]> || !<yaml[bm].contains[spawnlocation.<[merchantType]>]>:
            - define isValidLocation true

            - if <[validFactions].contains[<[selectedFaction].to_lowercase>]>:
                - define isValidFaction true

            - else:
                - narrate format:admincallout "That is not a valid faction name! Please try again."

        - else:
            - narrate format:admincallout "There already a merchant assigned to this location! Please try again."

        - if <[isValidFaction]> && <[isValidLocation]>:
            - yaml id:bm set spawnlocation.<[merchantType]>:->:<player.location.center>
            - yaml id:bm set spawnlocation.factions.<[selectedFaction].to_lowercase>:->:<player.location>

            - narrate format:admincallout "Successfully set merchant location and faction. Please use <blue>/bmrefresh <light_purple>to spawn the new merchant. (in some instances you may have to run the command twice)"

        - yaml id:bm savefile:blackmarket-formatted.yml
        - yaml id:bm unload

OldSpecifySpawnLoc_Command:
    type: command
    usage: /oldspecify
    name: oldspecify
    description: Specify Black Market Merchant Spawn Location
    permission: kingdoms.admin.specify.old
    script:
    - narrate "<red>This command is deprecated! If at all possible, please type <blue>/oldspecify cancel <red>and use <blue>/specify <red>instead!"

    - yaml load:blackmarket-formatted.yml id:bm

    - if <context.args.get[1]> == cancel:
        - flag player specifyConfirm:!
        - flag player args:!
        - yaml id:bm unload

        - narrate format:admincallout "Operation cancelled!"

    - if <context.args.get[1]> == confirm:
        - flag player specifyConfirm
    - else:
        # Created a separate variable for args since <context.args> on the confirmation pass would return 'confirm'
        - flag player args:<context.args>

    - if <player.has_flag[specifyConfirm]>:

        # If a merchant type is not specified it will allow any merchant type to spawn there #
        - if <player.flag[args].size.is[LESS].than[1]>:

            # Checks if the location is already present in the file #
            - if <yaml[bm].list_keys[spawnlocation.any].contains[<player.location.center>]>:
                - yaml id:bm set spawnlocation.any:->:<player.location.center>

                - narrate format:callout "Merchant location set!"

            - yaml id:bm savefile:blackmarket-formatted.yml

        - else:

            - define validFactions <list[orama|blackstone|syndicates|totalist]>

            # Checks if the location is already present in the file #
            - if !<yaml[bm].list_keys[spawnlocation.<player.flag[args].get[1]>].contains[<player.location.center>]>:
                - yaml id:bm set spawnlocation.<player.flag[args].get[1]>:->:<player.location.center>

                - if <[validFactions].contains[<player.flag[args].get[2].to_lowercase>]>:
                    - yaml id:bm set spawnlocation.factions.<player.flag[args].get[2].to_lowercase>

                    - narrate format:callout "<player.flag[args].get[1]> Merchant location set!"

            - yaml id:bm savefile:blackmarket-formatted.yml

        - flag player specifyConfirm:!
        - flag player args:!

    - else:
        - narrate format:callout "Please note that the Black Market Merchant will spawn in the same location as well as direction that you are currently in. Please type: /specify confirm to set the location."

    - yaml id:bm unload

ModifyMerchantItems_Command:
    type: command
    usage: /merchantitems
    name: merchantitems
    description: Modifies the items of each Black Market Merchent
    tab complete:
    - yaml load:blackmarket-formatted.yml id:bmf
    - determine <yaml[bmf].read[merchant_items].keys>
    - yaml unload id:bmf

    permission: kingdoms.admin.items
    script:
    - flag <player> whichMerchant:<context.args.get[1].to_lowercase>
    - run GenerateMerchantItemList
    - inventory open d:ModifyMerchantItems_GUI

GenerateMerchantItemList:
    type: task
    script:
    - yaml load:blackmarket-formatted.yml id:bmf
    - define whichMerchant <player.flag[whichMerchant]>
    - define itemList <yaml[bmf].read[merchant_items.<[whichMerchant]>.items].keys>
    - define merchantData <list[]>

    - foreach <[itemList]>:
        - define chance <yaml[bmf].read[merchant_items.<[whichMerchant]>.items.<[value]>]>
        - define price <yaml[bmf].read[prices.<[value]>]>
        - define item <[value].as_item>
        - adjust def:item lore:<element[Price: ].bold.color[aqua]><[price].bold.color[white]>|<element[Spawn Chance: ].bold.color[aqua]><[chance].bold.color[white]>

        - define merchantData:->:<[item]>

    - yaml id:bmf unload
    - flag <player> merchantData:<[merchantData]>

ModifyMerchantItems_GUI:
    type: inventory
    inventory: chest
    title: Specify Items For <player.flag[whichMerchant].to_titlecase>
    procedural items:
    - determine <player.flag[merchantData]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []

ModifyMerchantItems_Handler:
    type: world
    events:
        on player clicks item in ModifyMerchantItems_GUI:
        - ratelimit <player> 1t
        - if <context.item.material.name> != air && <context.clicked_inventory.script.exists>:
            - flag <player> EnteringBMItemInfo:<context.item>
            - inventory close
            - yaml load:blackmarket-formatted.yml id:bmf

            - define newItem <player.flag[EnteringBMItemInfo]>
            - adjust def:newItem lore:<list>
            - narrate format:debug NEW:<[newItem]>
            - define newItem <[newItem].as_element.replace_text[i@]>

            - narrate format:debug NEW:<[newItem]>
            - define price <yaml[bmf].read[prices.<[newItem]>]>
            - define chance <yaml[bmf].read[merchant_items.<player.flag[whichMerchant]>.items.<[newItem]>]>

            - yaml id:bmf unload

            - narrate format:admincallout "Current spawn chance and price for: <context.item.material.name.color[aqua].bold> are: <element[$<[price]>].color[aqua].bold> & <element[<[chance].mul[100]><&pc>].color[aqua].bold>"
            - narrate format:admincallout "Please enter the spawn chance and price separated by commas like such: 0.25,5000"
            - determine cancelled

        on player chats flagged:EnteringBMItemInfo:
        - if <context.message> == cancel:
            - narrate format:admincallout "Cancelled operation."
            - determine cancelled

        - define newItem <player.flag[EnteringBMItemInfo]>
        - adjust def:newItem lore:<list>
        - define newItem <[newItem].as_element.replace_text[i@]>
        - define chance <context.message.split[,].get[1]>
        - define price <context.message.split[,].get[2]>
        - define whichMerchant <player.flag[whichMerchant]>

        #- narrate format:debug <[price].as_decimal>
        #- narrate format:debug <[chance].as_decimal>

        - yaml load:blackmarket-formatted.yml id:bmf
        - yaml id:bmf set merchant_items.<[whichMerchant]>.items.<[newItem]>:<[chance].as_decimal>
        - yaml id:bmf set prices.<[newItem]>:<[price].as_decimal>
        - yaml savefile:blackmarket-formatted.yml id:bmf
        - yaml id:bmf unload

        - run GenerateMerchantItemList
        - inventory open d:ModifyMerchantItems_GUI
        - flag <player> EnteringBMItemInfo:!
        - determine cancelled

        on player closes ModifyMerchantItems_GUI:
        - if !<player.has_flag[EnteringBMItemInfo]>:
            - flag <player> whichMerchant:!
            - flag <player> merchantData:!
