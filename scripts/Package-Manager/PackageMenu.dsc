##
## All scripts in this file relate to the user-facing portion of KPM.
## (Basically just the config menu system for now).
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Feb 2024
## @Script Ver: INDEV
##
## ------------------------------------------END HEADER-------------------------------------------

AddonMissingDepends_Item:
    type: item
    material: player_head
    display name: <red><bold>Unnamed Addon
    mechanisms:
        skull_skin: cab6cd15-e451-48d2-9c63-24f90f2441fe|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZjlmZjk4ODQyY2I2NjQwNWQyMGE4ZTZiMmVmZmFjNDYwMTBiOGY1NjAyZWE3MzI2ZDRkMTg1YjliNWRjZTA2In19fQ==


AddonNormal_Item:
    type: item
    material: player_head
    display name: <gray><bold>Unnamed Addon
    mechanisms:
        skull_skin: 55dea4fb-3202-4c60-987d-c7db2f726a38|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNzQzOGQwOGJkMDQwNWMwNWY0N2VhODZkNjY2NDM0MzRmZGQyZThjNDZmZjFlNmY4ODJiYjliZjg5MWM3ZDNhNSJ9fX0=


AddonGUI:
    type: task
    definitions: player
    description:
    - Displays a paginated menu of all the currently indexed addons in the server which will allow
    - server admins to configure, load, unload, and interact with all addons on the server.

    script:
    ## Displays a paginated menu of all the currently indexed addons in the server which will allow
    ## server admins to configure, load, unload, and interact with all addons on the server.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [Void]

    - define itemList <list[]>

    - foreach <proc[GetAllAddonNames]> as:addon:
        - define item <item[AddonMissingDepends_Item]>
        - define displayName <[addon].proc[GetAddonDisplayName]>

        - if <[addon].proc[GetAddonMissingDependencies].size> == 0:
            - define item <item[AddonNormal_Item]>
            - adjust def:item display:<[displayName].color[white].bold>

        - else:
            - adjust def:item display:<[displayName].color[red].bold>
            - adjust def:item "lore:<red>This addon is missing dependencies<&co>"
            - adjust def:item lore:<[item].lore.include[<[addon].proc[GetAddonMissingDependencies].parse_tag[- <[parse_value]>]>]>

        - adjust def:item flag:addonName:<[addon]>

        - define itemList:->:<[item]>

    - run PaginatedInterface def.itemList:<[itemList]> def.player:<[player]> def.page:1 def.title:<element[Indexed Addons]> def.flag:addonList


LoadAddon_Item:
    type: item
    material: green_wool
    display name: <dark_green><bold>Load Addon


AddonLoading_Item:
    type: item
    material: yellow_wool
    display name: <yellow><bold>Loading...


AddonUnloading_Item:
    type: item
    material: yellow_wool
    display name: <gold><bold>Unloading...


UnloadAddon_Item:
    type: item
    material: red_wool
    display name: <red><bold>Unload Addon


ForceLoadAddonDisabled_Item:
    type: item
    material: gray_wool
    display name: <gray><bold>Force Loading Disabled


ForceLoadAddonEnabled_Item:
    type: item
    material: red_wool
    display name: <red><bold>Force Loading Enabled


AddonControls_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Addon Controls
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [LoadAddon_Item] [] [ForceLoadAddonDisabled_Item] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [InterfaceFiller_Item] [Info_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item]
    - [] [] [] [] [] [] [] [] []


AddonGUI_Handler:
    type: world
    events:
        on player clicks AddonMissingDepends_Item in PaginatedInterface_Window flagged:addonList:
        - flag <player> datahold.addons.addonName:<context.item.flag[addonName]>
        - inventory open d:AddonControls_Window

        on player opens AddonControls_Window:
        - define addonName <player.flag[datahold.addons.addonName]>

        # If addon is already loaded then replace the load button with unload one.
        - if <proc[IsAddonLoaded].context[<[addonName]>]>:
            - inventory set origin:UnloadAddon_Item slot:<context.inventory.find_item[LoadAddon_Item]> d:<context.inventory>

        - definemap addonInfo:
            1: <element[Addon Name:     ].color[gray]><[addonName].color[gold]>
            2: <element[Unique Hash:     ].color[gray]><[addonName].proc[GetAddonHash].as[element].substring[8,21].color[gold]>
            3: <element[Addon Version:  ].color[gray]><[addonName].proc[GetAddonVersion].color[gold]>
            4: <element[Addon Authors: ].color[gray]><[addonName].proc[GetAddonAuthors].separated_by[<n>].color[gold]>

        - inventory adjust slot:<context.inventory.find_item[Info_Item]> lore:<[addonInfo].values> d:<context.inventory>

        on player clicks LoadAddon_Item flagged:!datahold.addons.addonLoadCooldown:
        - execute as_player "addon load <player.flag[datahold.addons.addonName]>"
        - flag <player> datahold.addons.addonLoadCooldown

        - inventory set origin:AddonLoading_Item slot:<context.inventory.find_item[LoadAddon_Item]> d:<context.inventory>

        on custom event id:KingdomsAddonLoaded:
        - flag <player> datahold.addons.addonLoadCooldown expire:5s
        - inventory set origin:UnloadAddon_Item slot:<context.inventory.find_item[AddonLoading_Item]> d:<context.inventory>

        on player clicks UnloadAddon_Item flagged:!datahold.addons.addonLoadCooldown:
        - execute as_player "addon unload <player.flag[datahold.addons.addonName]>"
        - flag <player> datahold.addons.addonLoadCooldown

        - inventory set origin:AddonUnloading_Item slot:<context.inventory.find_item[UnloadAddon_Item]> d:<context.inventory>

        on custom event id:KingdomsAddonUnloaded:
        - flag <player> datahold.addons.addonLoadCooldown expire:5s
        - inventory set origin:LoadAddon_Item slot:<context.inventory.find_item[AddonUnloading_Item]> d:<context.inventory>

        on custom event id:KingdomsAddonLoadError:
        - inventory adjust slot:<context.inventory.find_item[LoadAddon_Item]> d:<context.inventory> "lore:<red>An Error Occurred!"
        - wait 10s
        - inventory adjust slot:<context.inventory.find_item[LoadAddon_Item]> d:<context.inventory> lore:<list[]>

        on player clicks ForceLoadAddonDisabled_Item in AddonControls_Window:
        - inventory set slot:<context.slot> d:<context.inventory> origin:ForceLoadAddonEnabled_Item
        - flag <player> datahold.addons.forceLoad

        on player clicks ForceLoadAddonEnabled_Item in AddonControls_Window:
        - inventory set slot:<context.slot> d:<context.inventory> origin:ForceLoadAddonDisabled_Item
        - flag <player> datahold.addons.forceLoad:!

        on player closes AddonControls_Window:
        - flag <player> datahold.addons.addonName:!
