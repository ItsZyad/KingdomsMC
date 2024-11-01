##
## New outpost list command - should show all owned outposts in a GUI instead of in chat - with all
## relevant metadata shown in the lore box.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Nov 2021
## @Updated: Oct 2024
## @Script Ver: v2.0
##
## ------------------------------------------END HEADER-------------------------------------------

# GET Skull_skins at https://minecraft-heads.com/custom-heads/blocks/1655-oak-log (log example)
# and grab first part of the skin Base64 from 1.13 setblock code and second part from 'value'

OutpostList_GUI:
    type: inventory
    gui: true
    inventory: chest
    title: "Outpost List"
    procedural items:
    - determine <player.flag[outpostList]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [Page_Back] [] [Page_Forward] [] [] []


MiningSpec_Item:
    type: item
    material: player_head
    display name: <gray><bold>Mining Outpost
    mechanisms:
        skull_skin: d9ce127a-ffcc-451a-98dc-fb05edebba06|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNzYxYzU3OTc0ZjEwMmQzZGViM2M1M2Q0MmZkZTkwOWU5YjM5Y2NiYzdmNzc2ZTI3NzU3NWEwMmQ1MWExOTk5ZSJ9fX0=


FarmingSpec_Item:
    type: item
    material: player_head
    display name: <green><bold>Farming Outpost
    mechanisms:
        skull_skin: 30939add-08ae-41b5-802f-d55a546c9a06|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvN2FhNTk2NmExNDcyNDQ1MDRjYzU2ZWY2ZWZkMmQyZjQ0NzM4YjhmMDNkOTNhNjE3NjZhZjNmYzQ0ODdmOTgwYiJ9fX0=


LoggingSpec_Item:
    type: item
    material: player_head
    display name: <bold><element[Logging Outpost].color[#743e3e]>
    mechanisms:
        skull_skin: 1f77726e-867b-4a66-8015-1ed701753de0|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNmQyZTMxMDg3OWE2NDUwYWY1NjI1YmNkNDUwOTNkZDdlNWQ4ZjgyN2NjYmZlYWM2OWM4MTUzNzc2ODQwNmIifX19


Unspec_Item:
    type: item
    material: player_head
    display name: <white><bold>Unspecialized Outpost
    mechanisms:
        skull_skin: bcccae77-0ac7-4cd0-8126-c900727c2223|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNDljMTgzMmU0ZWY1YzRhZDljNTE5ZDE5NGIxOTg1MDMwZDI1NzkxNDMzNGFhZjI3NDVjOWRmZDYxMWQ2ZDYxZCJ9fX0=


SpecTypeToItem:
    type: data
    loggers: LoggingSpec_Item
    farmers: FarmingSpec_Item
    miners: MiningSpec_Item
    none: Unspec_Item


OutpostList:
    type: task
    debug: false
    definitions: player[PlayerTag]
    description:
    - Displays the outpost list GUI for the provided player.
    - ---
    - → [Void]

    script:
    ## Displays the outpost list GUI for the provided player.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [Void]

    - define kingdom <[player].flag[kingdom]>
    - define rawOutpostList <list[]>

    - foreach <[kingdom].proc[GetOutposts].keys> as:outpostName:
        - define area <proc[GetOutpostArea].context[<[kingdom]>|<[outpostName]>]>
        - define name <proc[GetOutpostDisplayName].context[<[kingdom]>|<[outpostName]>]>
        - define length <proc[GetOutpostArea].context[<[kingdom]>|<[outpostName]>].size.x>
        - define width <proc[GetOutpostArea].context[<[kingdom]>|<[outpostName]>].size.z>
        - define upkeep <proc[GetOutpostUpkeep].context[<[kingdom]>|<[outpostName]>]>
        - define outpostBlock <item[Unspec_Item]>
        - flag <[outpostBlock]> name:<[name]>

        # TODO: Figure out what I'm gonna do with outpost specs.
        # - define spec <[currentOutpost].get[specType]>

        # No specialization is represented by the tag being non-existant
        # - if <[currentOutpost].get[specType].exists>:
        #     - define SpecKey <script[SpecTypeToItem].data_key[<[spec]>]>
        #     - define outpostBlock <item[<[SpecKey]>]>

        - definemap lore:
            1: <element[Name: ]><[name].color[green]>
            2: <element[Area: <[area].corners.first.xyz.color[blue]> <element[-<&gt>].color[gray]> <[area].corners.last.xyz.color[blue]>]>
            3: <element[Dimensions: <[length].color[aqua]> x <[width].color[aqua]>]>
            4: <element[Upkeep: <red>$<[upkeep].format_number>]>

        - adjust def:outpostBlock lore:<[lore].values>

        - define rawOutpostList:->:<[outpostBlock]>

    - run PaginatedInterface def.itemList:<[rawOutpostList]> def.page:1 def.player:<[player]> def.title:<element[Outpost List]>
