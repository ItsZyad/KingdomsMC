##
## Scripts in this file verify Kingdoms' game state and validate whether the correct files are
## present in the installation.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Dec 2023
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

YAMLConfigCreator:
    type: task
    definitions: useSavedConfig[?ElementTag(Boolean) = false]
    description:
    - Creates and saves the current version of the default Kingdoms config file as of v0.4.1.
    - If the 'useSavedConfig' parameter is set to true then the script will use the version of the
    - encoded config file saved to the kingdoms.config.encodedConfig flag.
    - Note: the kingdoms.config.encodedConfig flag will be ignored if it's not a binary type.
    - ---
    - → [Void]

    script:
    ## Creates and saves the current version of the default Kingdoms config file as of v0.4.1.
    ## If the 'useSavedConfig' parameter is set to true then the script will use the version of the
    ## encoded config file saved to the kingdoms.config.encodedConfig flag.
    ##
    ## Note: the kingdoms.config.encodedConfig flag will be ignored if it's not a binary type.
    ##
    ## useSavedConfig : ?[ElementTag<Boolean> = false]
    ##
    ## >>> [Void]

    # Dev note:
    # DENIZEN YIELDS TO MY WILL WHEN I PLEASE
    # I SPIT IN YOUR FACE, ODIN

    - define useSavedConfig <[useSavedConfig].if_null[false]>

    - if !<[useSavedConfig]> && <server.flag[kingdoms.config.encodedConfig].object_type> == Binary:
        - define yamlAsBinary <server.flag[kingdoms.config.encodedConfig]>

    - else:
        - define yamlAsBinary <binary[1f8b08000000000000ff4d90414bc4301484ef85fe87815e146c772d7bdaa3a09745f120089e36362f9bb8af794b93b4f4e26f37ed229a4b4832f3cde45515deac0b308e09790fd131e32b8508857026a6281e5160892fe809c96b1a42545ec3ca846809aa8b49310ece9fb4f4019d78e34ecddc73595415a68538c9706ef0229e2026bb72549786817ce4195605283fe393d49021581233d724df45275eb18bf3d546b8703a39dface49bec13b3c7b86d76cd3d3668b7edae7e7a7ca8dbf67655d4f8288bb238bc3eefcb02795578b79439c35fdd6025b1068bd2505a8b0fa0913cdc1ab8b41b976f07155d308e34345d284fc1778ec21d14b34c4beb2cfecd50ba77ebd456687ee8313a85e366e55f6fbfcdf12a5f4ef53f7efd9fbf471c12fd0081cee74aa6010000]>

    - ~log type:none <[yamlAsBinary].gzip_decompress.utf8_decode> file:plugins/Kingdoms/temp/tempConfig.yml
    - ~filecopy origin:../Kingdoms/temp/tempConfig.yml destination:../Kingdoms/config.yml overwrite

    - adjust system delete_file:../Kingdoms/temp/tempConfig.yml
    - adjust system delete_file:../Kingdoms/temp


ConfigLoader:
    type: task
    definitions: overrideMap[?MapTag(ObjectTag)]
    description:
    - Will load all nodes from the Kingdoms config into the working memory via the `kingdoms.config.nodes` flag.
    - You can also override any config node by adding the relevant submap to the overrideMap definition.
    - For example, if you wanted to override the `Armies.squad-manager-upkeep` node, you would pass in an overrideMap of: [Armies=[squad-manager-upkeep=x]]
    - If the action fails, this task will return null.
    - ---
    - → [Void]

    script:
    ## Will load all nodes from the Kingdoms config into the working memory via the
    ## `kingdoms.config.nodes` flag.
    ##
    ## You can also override any config node by adding the relevant submap to the overrideMap
    ## definition.
    ##
    ## For example, if you wanted to override the `Armies.squad-manager-upkeep` node, you would
    ## pass in an overrideMap of: [Armies=[squad-manager-upkeep=x]]
    ##
    ## If the action fails, this task will return null.
    ##
    ## overrideMap : ?[MapTag(ObjectTag)]
    ##
    ## >>> [Void]

    - define overrideMap <[overrideMap].if_null[<map[]>]>

    - yaml load:../Kingdoms/config.yml id:config
    - define configMap <yaml[config].read[Config]>
    - yaml unload id:config

    - foreach <[overrideMap]>:
        - if !<[configMap].deep_get[<[key]>].exists>:
            - foreach next

        - define configMap <[configMap].deep_with[<[key]>].as[<[value]>]>

    - flag server kingdoms.config.nodes:<[configMap]>


DEBUG_SaveCurrentConfig:
    type: task
    script:
    ## Saves a binary representation of the current kingdoms config.yml found in plugins/Kingdoms
    ## to the 'kingdoms.config.encodedConfig' flag.
    ##
    ## >>> [Void]

    - ~fileread path:../Kingdoms/config.yml save:config
    - flag server kingdoms.config.encodedConfig:<entry[config].data.gzip_compress>


Startup_Handler:
    type: world
    events:
        on server start priority:1:
        - if <proc[GetKingdomList].contains[null]> || <proc[GetKingdomList].context[false].contains[null]>:
            - debug LOG <element[]>
            - debug LOG <element[]>
            - run GenerateInternalError def.type:GenericError def.message:<element[HOLD IT! You are not allowed to use the word <&dq>null<&dq> to name any kingdom! The server will not start until you change this.]>
            - debug LOG <element[]>
            - debug LOG <element[]>

            - adjust server shutdown
            - stop

        - yaml id:dConfig load:config.yml

        - if !(<yaml[dConfig].read[Commands.File.Allow Write]> && <yaml[dConfig].read[Commands.File.Allow Read]>):
            - yaml id:dConfig set Commands.File.Allow read:true
            - yaml id:dConfig set Commands.File.Allow write:true
            - yaml id:dConfig unload

            - if !<yaml[dConfig].read[Commands.Restart.Allow]>:
                - yaml id:dConfig set Commands.Restart.Allow server restart:true

            - yaml id:dConfig savefile:config.yml
            - yaml id:dConfig unload
            - adjust server restart

        - if !<util.has_file[../Kingdoms/config.yml]>:
            - run YAMLConfigCreator save:configMap
            - run ConfigLoader

        - if !<util.has_file[../Kingdoms/addons]>:
            - yaml id:tempPackage create
            - yaml id:tempPackage set package.name:temp-package
            - yaml id:tempPackage savefile:../Kingdoms/addons/temp-package/package.yml
            - yaml id:tempPackage unload

            - adjust system delete_file:../Kingdoms/addons/temp-package/package.yml
            - adjust system delete_file:../Kingdoms/addons/temp-package