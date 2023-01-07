##
## * New outpost list command - should show all owned
## * outposts in a GUI instead of in chat - with all
## * relevant metadata shown in the lore box
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Nov 2021
## @Script Ver: v1.0
##
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

Old_OutpostManager_Command:
    type: command
    usage: /old_outposts
    name: old_outposts
    permission: kingdoms.admin
    description: "Displays all the outposts currently maintained by your kingdom [CURRENTLY BROKEN]"
    script:
        - yaml load:outposts.yml id:outpost
        - define kingdom <player.flag[kingdom]>

        - narrate format:admincallout "THIS COMMAND IS DEPRECATED AND NO LONGER WORKS. ONLY USE FOR DEBUG PURPOSES!"

        - narrate format:callout "Current Outposts for the <[kingdom]> kingdom"

        - foreach <yaml[outpost].read[<[kingdom]>].keys.exclude[totalupkeep]>:
            - narrate "- <[value]>"

            - define cornerOne <yaml[outpost].read[<[kingdom]>].values.get[<[loop_index]>].get[cornerone]>
            - define cornerTwo <yaml[outpost].read[<[kingdom]>].values.get[<[loop_index]>].get[cornertwo]>

            - narrate "    X : <[cornerOne].x.round> | Y : <[cornerOne].y.round> | Z : <[cornerOne].z.round>"
            - narrate "    X : <[cornerTwo].x.round> | Y : <[cornerTwo].y.round> | Z : <[cornerTwo].z.round>"

# GET Skull_skins at https://minecraft-heads.com/custom-heads/blocks/1655-oak-log (log example)
# and grab first part of the skin Base64 from 1.13 setblock code and second part from 'value'

OutpostList_GUI:
    type: inventory
    gui: true
    inventory: chest
    title: "Outpost List"
    procedural items:
    - narrate <player.flag[outpostList]>
    - determine <player.flag[outpostList]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [Page_Back] [] [Page_Forward] [] [] []

MiningSpec_Item:
    type: item
    material: player_head
    display name: "<gray><bold>Mining Outpost"
    mechanisms:
        skull_skin: d9ce127a-ffcc-451a-98dc-fb05edebba06|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNzYxYzU3OTc0ZjEwMmQzZGViM2M1M2Q0MmZkZTkwOWU5YjM5Y2NiYzdmNzc2ZTI3NzU3NWEwMmQ1MWExOTk5ZSJ9fX0=

FarmingSpec_Item:
    type: item
    material: player_head
    display name: "<green><bold>Farming Outpost"
    mechanisms:
        skull_skin: 30939add-08ae-41b5-802f-d55a546c9a06|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvN2FhNTk2NmExNDcyNDQ1MDRjYzU2ZWY2ZWZkMmQyZjQ0NzM4YjhmMDNkOTNhNjE3NjZhZjNmYzQ0ODdmOTgwYiJ9fX0=

LoggingSpec_Item:
    type: item
    material: player_head
    display name: "<bold><element[Logging Outpost].color[#743e3e]>"
    mechanisms:
        skull_skin: 1f77726e-867b-4a66-8015-1ed701753de0|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNmQyZTMxMDg3OWE2NDUwYWY1NjI1YmNkNDUwOTNkZDdlNWQ4ZjgyN2NjYmZlYWM2OWM4MTUzNzc2ODQwNmIifX19

Unspec_Item:
    type: item
    material: player_head
    display name: "<white><bold>Unspecialized Outpost"
    mechanisms:
        skull_skin: bcccae77-0ac7-4cd0-8126-c900727c2223|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNDljMTgzMmU0ZWY1YzRhZDljNTE5ZDE5NGIxOTg1MDMwZDI1NzkxNDMzNGFhZjI3NDVjOWRmZDYxMWQ2ZDYxZCJ9fX0=

SpecTypeToItem:
    type: data
    loggers: LoggingSpec_Item
    farmers: FarmingSpec_Item
    miners: MiningSpec_Item
    none: Unspec_Item

OutpostList_Command:
    type: task
    subpaths:
        OutpostGUI_Init:
        - yaml load:outposts.yml id:outpost
        - define kingdom <player.flag[kingdom]>
        - define rawOutpostList <list[]>

        - foreach <yaml[outpost].read[<[kingdom]>].keys.exclude[totalupkeep]>:
            - define currentOutpost <yaml[outpost].read[<[kingdom]>.<[value]>]>
            - define cornerOne <[currentOutpost].get[cornerone].xyz>
            - define cornerTwo <[currentOutpost].get[cornertwo].xyz>
            - define name <[currentOutpost].get[name]>
            - define size <[currentOutpost].get[size]>
            - define upkeep <[currentOutpost].get[upkeep]>
            - define spec <[currentOutpost].get[specType]>

            - define outpostBlock <item[Unspec_Item]>

            - flag <[outpostBlock]> name:<[value]>

            # No specialization is represented by the tag being non-existant
            - if <[currentOutpost].get[specType].exists>:
                - define SpecKey <script[SpecTypeToItem].data_key[<[spec]>]>
                - define outpostBlock <item[<[SpecKey]>]>

            - define lore "<&r>Name: <green><[name]>|<&r>Corner One: <blue><[cornerOne]>|<&r>Corner Two: <blue><[cornerTwo]>|<&r>Size: <blue><[size]>|<&r>Upkeep: <red>$<[upkeep]>"
            - adjust def:outpostBlock lore:<[lore]>

            - define rawOutpostList:->:<[outpostBlock]>

        - if <[rawOutpostList].size.is[MORE].than[<player.flag[OutpostGUIPage].sub[1].mul[27]>]>:
            - run Paginate_Task def.itemArray:<[rawOutpostList]> def.itemsPerPage:27 def.page:<player.flag[OutpostGUIPage]> save:paginate
            - flag <player> outpostList:<entry[paginate].created_queue.determination.get[1]>

        - yaml id:outpost unload

        ResetOutpostPageFlag:
        - if !<player.has_flag[outpostGUIPage]>:
            - flag <player> outpostGUIPage:1

        OutpostGUI_Show:
        - inventory open d:OutpostList_GUI
        - flag <player> outpostList:!

        OutpostGUI_NextPage:
        - inject OutpostList_Command.subpaths.ResetOutpostPageFlag
        - flag <player> OutpostGUIPage:+:1
        - inject OutpostList_Command.subpaths.OutpostGUI_Init

        OutpostGUI_PrevPage:
        - inject OutpostList_Command.subpaths.ResetOutpostPageFlag
        - flag <player> OutpostGUIPage:-:1
        - inject OutpostList_Command.subpaths.OutpostGUI_Init

    script:
    - inject OutpostList_Command.subpaths.ResetOutpostPageFlag
    - inject OutpostList_Command.subpaths.OutpostGUI_Init
    - inject OutpostList_Command.subpaths.OutpostGUI_Show

OutpostList_Handler:
    type: world
    events:
        on player clicks Page_Forward in OutpostList_GUI:
        - inject OutpostList_Command.subpaths.OutpostGUI_NextPage

        on player closes OutpostList_GUI:
        - flag <player> outpostGUIPage:!

        on player clicks Unspec_Item in OutpostList_GUI:
        # Little bit of cheeky data passing
        - flag <player> outpostToBeSpeced:<context.item.flag[name]>
        - inventory open d:OutpostSpec_Window
