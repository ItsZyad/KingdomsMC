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
        - define yamlAsBinary <binary[1f8b08000000000000ffbd57ef6f133718fe8ec4fff002d202129700832f19422ab48c0a2868749dd88a52e7ce494c7c7666fb1a82a2fded7b5efb2e7749caa4a1752735beb35fbfcffbf3b17be7ceb53f376ff02ff1331a8de2cf28bdb75fa3eee4a81d379b9a5db423c8cf36c81ab36bfe19ade33bc6389cd71ffd5ed298664774d127c21ce125c9110d3a82239ed803c176281f44c9f89e06decd1f83a4f11c26c46f609c43b49ff59304c54f8aab7723c6687d35084ce8f5b741d6e7f085d6f5440ac33ae95aa7b97a953da985fa2c76d1bfca93511481ce366471388fb13c87edd8fa89df79167e0db07291c1bf41924b03949c33c83dbac29335afac3bbf9b21ee59478c1194a7594649b8cd4c239e3092401764747dcfb6276747bf7c387e77420ffa8ffb8fe9f8e4f0e80c0ebf3df8889c3f7af0e8097ddfb39bf86b795a906b7e18e41afd683da1d399f234515a12461f94d6f4b9f28104f9b9d4325843c1d24cea0595922a5348e7833005cdec92c24c92c8432534bd56665ad8d2536ecd444dfbab52b7204b56bbb46edea7136b24d909b6022faf9c9326e815cd842761563496c24113312c944f2a9307658dd02aacd236490b5d4d95e9ef7a92d1efd71faeeb7cfec7eaba79e3454cd3f0e60d46fe591ae984aebfa22d74f88e4ede9dd28b5707273f1fd1e9abe30f7476f0e6d7237afe91307778ab15be444d204943eac5a6eeedad64469412cbcf577428c7810e503fcfb5b54547745c295d40e6210dde1c9f1e65e085418f2de5c5d7efdf6e19f7db4ca2125c5b757e662b5d90b6a2205114d6789297d2908a25c3f575c9d5eb45507ea26441855c4814b3c995f4f749686d975c7710eee288a254b101a2622c9674a9045d0c22469afd6b72d16ee199ac8393757186145c251b9f0e5cc9735db85354772127a2d281aac5c45913d04fe846547e8c0f9b88cefcb3026e298c982206031a0be7443ef7adaa2891d51259ad6a087e7df0600f4f28f45f83520a6502febe17682ee562484ff6611047555625158ae923977417811d6b0b6df7105811282ced3620f841400614b3102e7c0b138a33bf10392c8e0eee018b2f11d854e5184ec0c71d90082e689e4a296272b574f5dc8d2c19594c2bd022f31429933b293c6a099e4caa503954d8a2104182ca7c642ab83a565dea1231e7e4573ea094c632b7253e4b8badc27b6828eeb5b8b03c8b858932daf21985f4f85b6e7e3bbe82a68a5b02738239b589eec43aac2db458213c287596dae41e22d615f582c5ef7d6c99b0bd63c93572db56b16e10897c767b2b66c7818f9469a21684ccb1b7253743c1dab852d2297029742589fd746ca9a195ad1c79e9c01e3d8f7d7ce86c1cdb0950b42e6b16b9f47623234a5b9968e4d9fb3adb339b5a898da6209d53c1ba1585d542a21320ed63548acaa53e580ad76a3d7b9f956850b5d08a53d12ef083702cd04a435c6f9e6cafe4b3cacc87f4b069ffd306768f016a835353e03bd88003b65a64db845043915fc85ce180fc9ab2da94a5a7f18a9633247c93dca5f233cc23f839c23c95a946b7b74331e7bcd61d6d408a8486ce62d50acba2b5ba16ce9ce4e54e70e06dffe1937fcf041d039a1a75e84c616c24fdba537b7cd740212251b9f00137984d263b2592c0b2c6c67f2a94a6853cdcdb610560d51a36a484e8d654bdcf143859990d546281a52ac28c7e202dcd142f7f7cc1fbd74f0d25349e6ec2c6dd318dc7db76a96ff9c1360ee9c72bf8bcf1a22dfb3a3ab1007daaf986ecea63933976cc01446568a1ca2b9dab2732eebaa4324b2a41bbfb49deb78273f59fda00851b0b389b490c178c6a7ae56501279b74b84a12cac43abe6ff23500d2b8d97a0f62f51d5bf0b6e466e256097d7a67c060d2440b71a70043d1dce006bc8c4d6ae1efbcbed64a2f37fa3a6716d4658d015944cd1aa9ed6bc1d19724d471e170654ab1d8619a1467adcc9cf123916e28b3881bd058c9d2c2125a27dd81ea2565d0075acb78a931693b74c92602dceed43395d6bd7bdbb8d89d31ea9078b5b1faa51697d6ed505934294f678d8dd78a74c9cff10f0612ffd922bc9bd0b3a1cb7489c3119ba829fac3eea16d99c3222b470e9aa8bc6635bf5b7aa80b1c3581654b1187e49ef26d524394e3d32820d9387a7e6ab524ebb2a4bd4dd2761426d5d7af2baf4148b8b2326a70aa606d5cd5f1bf1927712330b2b8d5dbcddbd35a75e539d1a57c36a4a735ccb35dd997b05e7e11e542cbbdfc7f96e3618a32337413d55ad32dceccdf8d3080869c120000]>

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