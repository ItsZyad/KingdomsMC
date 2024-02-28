##
## [KPM]
## Scripts in this file are responsible for loading packages from the ../Kingdoms/packages
## directory, and loading them into the working scripts folder.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Dec 2023
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

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
                    - narrate format:admincallout "<red>Force Loading <[addonName].color[aqua]>..."
                    - run LoadAddon def.addonName:<[addonName]> def.addonHash:<[addonName].proc[GetAddonHash]>
                    - stop

                - narrate format:warning "Cannot load an addon which has currently unsatisfied dependencies without the ~f flag."
                - stop

            - narrate format:admincallout "Loading <[addonName].color[aqua]>..."
            - run LoadAddon def.addonName:<[addonName]> def.addonHash:<[addonName].proc[GetAddonHash]>

        - case unload:
            - define addonName <[args].get[AddonName]>

            # Is addon loaded?
            - if !<util.has_file[scripts/Packages/<[addonName]>]>:
                - narrate format:admincallout "There is no addon with the name: <[addonName].color[red]> currently loaded.<n>Perhaps it's indexed but not yet loaded?"
                - stop

            - narrate format:admincallout "Unloading <[addonName].color[aqua]>..."
            - ~run RecursiveDelete def.directory:scripts/Packages/<[addonName]>
            - adjust system delete_file:scripts/Packages/<[addonName]>

            - reload
            - narrate format:admincallout "Addon unloaded!"


LoadAddon:
    type: task
    definitions: addonName[ElementTag(String)]
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
    ##
    ## >>> [Void]

    - if !<[addonName].proc[DoesAddonExist]>:
        - narrate format:admincallout "The provided name: <[addonName].color[red]> does not correspond to any indexed addon."
        - stop

    - ~run flagvisualizer def.flag:<queue.definition_map> def.flagName:defMap

    - define addonDir <[addonName].proc[GetAddonRoot]>

    - ~filecopy origin:../<[addonDir]> destination:scripts/Packages/<[addonName]> save:folderCopy
    - adjust system delete_file:scripts/Packages/<[addonName]>/package.yml

    - narrate format:debug <entry[folderCopy].success>

    - if <entry[folderCopy].success>:
        - reload
        - narrate format:admincallout "Copied addon: <[addonName]> to working scripts directory. Addon now loaded!"

    - else:
        - narrate format:admincallout "An error occurred. File origin or destination may not exist..."


RecursiveDelete:
    type: task
    definitions: directory[ElementTag(String)]|depth[ElementTag(Integer)]
    description: Recursively deletes all files and folders inside a given directory.
    script:
    ## Recursively deletes all files and folders inside a given directory.
    ##
    ## directory : [ElementTag<String>]
    ##
    ## >>> [Void]

    - define depth <[depth].if_null[0]>

    - if <[depth]> > 1000:
        - stop

    - foreach <util.list_files[<[directory]>]> as:subdirectory:
        - if <util.list_files[<[directory]>/<[subdirectory]>].size.if_null[0]> > 0:
            - run RecursiveDelete def.directory:<[directory]>/<[subdirectory]> def.depth:<[depth].add[1]>

        - adjust system delete_file:<[directory]>/<[subdirectory]>
        - narrate format:debug "Deleted: <[subdirectory].color[aqua]>"