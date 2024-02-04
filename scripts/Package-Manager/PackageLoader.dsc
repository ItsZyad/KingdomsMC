##
## [KPM]
## Scripts in this file are responsible for loading packages from the ../Kingdoms/packages
## directory, and loading them into the working scripts folder.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Dec 2023
## @Script Ver: INDEV
##
## ------------------------------------------END HEADER-------------------------------------------

PackageLoader_KPM:
    type: task
    definitions: packageName
    script:
    - narrate format:debug WIP


Addon_Command:
    type: command
    name: addon
    usage: /addon [load|unload|info|help] (AddonName) [~f]
    description: Blanket command for managing Kingdoms add-ons.
    permission: kingdoms.admin.addons
    data:
        ValidOperations: <list[load|unload|info|help]>
        ValidFlags: <list[~f]>

        args:
            AddonOperation:
                type: linear
                required: true
                accepted: <[value].is_in[<script[Addon_Command].data_key[data.ValidOperations].parsed>]>
                tab completes: <script[Addon_Command].data_key[data.ValidOperations].parsed>
                explanation: What the command should do with the given addon.

            AddonName:
                type: linear
                required: true
                accepted: <[value].is_in[<server.flag[addons.addonList].values.parse_tag[<[parse_value].get[name]>]>]>
                tab completes: <server.flag[addons.addonList].values.parse_tag[<[parse_value].get[name]>]>
                explanation: The name of the addon in question.

            AddonFlag:
                type: linear
                required: false
                accepted: <[value].is_in[<script[Addon_Command].data_key[data.ValidFlags].parsed>]>
                tab completes: <script[Addon_Command].data_key[data.ValidFlags].parsed>
                explanation: Flags that modify the behaviour of the command. For example, the ~f flag forces the current operation.

    tab complete:
    - inject CommandManager path:TabCompleteEngine

    script:
    - inject CommandManager path:ArgManager

    - define args <[arg]>
    - define arg:!

    # - ~run flagvisualizer def.flag:<[args]> def.flagName:args
    # - ~run flagvisualizer def.flag:<[errors]> def.flagName:errors if:<[errors].exists>

    - choose <[args].get[AddonOperation].to_lowercase>:
        - case load:
            - define addonName <[args].get[AddonName]>

            # Has missing dependencies...
            - if <[addonName].proc[GetAddonMissingDependencies].size> > 0:

                # And a force load flag...
                - if <[args].get[AddonFlag]> == ~f:
                    - run LoadAddon def.addonName:<[addonName]> def.addonHash:<[addonName].proc[GetAddonHash]>
                    - stop

                - else:
                    - narrate format:warning "Cannot load an addon which has currently unsatisfied dependencies without the ~f flag."
                    - stop

            - run LoadAddon def.addonName:<[addonName]> def.addonHash:<[addonName].proc[GetAddonHash]>

    CheckUnsatisfiedDependencies:
    - narrate format:debug WIP


LoadAddon:
    type: task
    definitions: addonName[ElementTag(String)]|addonHash[BinaryTag]
    description:
    - Loads the addon with the provided name and hash.
    - This task script includes no logic for checking whether the addon name provided belongs to a
    - valid addon or any other such verification.

    script:
    ## Loads the addon with the provided name and hash.
    ##
    ## This task script includes no logic for checking whether the addon name provided belongs to a
    ## valid addon or any other such verification.
    ##
    ## addonName : [ElementTag<String>]
    ## addonHash : [BinaryTag]
    ##
    ## >>> [Void]

    - narrate format:admincallout "Loading <[addonName].color[aqua]>..."

    - ~run flagvisualizer def.flag:<queue.definition_map> def.flagName:defMap

    - narrate format:debug WIP