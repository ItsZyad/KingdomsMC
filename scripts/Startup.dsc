##
## Scripts in this file verify Kingdoms' game state and validate whether the correct files are
## present in the installation.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Dec 2023
## @Script Ver: v0.1
##
## ------------------------------------------END HEADER-------------------------------------------

YAMLConfigCreator:
    type: task
    description:
    - Creates and returns the a MapTag of the default Kingdoms config file as of version 0.4.1.

    script:
    ## Creates and returns the a MapTag of the default Kingdoms config file as of version 0.4.1.
    ##
    ## >>> [MapTag]

    - determine <map[]>


Startup_Handler:
    type: world
    events:
        on server start priority:1:
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
            - define configMap <entry[configMap].created_queue.determination.get[1]>

            - yaml id:config create
            - yaml id:config set config:<[configMap]>
            - yaml id:config savefile:../Kingdoms/config.yml
            - yaml id:config unload

        - if !<util.has_file[../Kingdoms/packages]>:
            - yaml id:tempPackage create
            - yaml id:tempPackage set package.name:temp-package
            - yaml id:tempPackage savefile:../Kingdoms/packages/temp-package/package.yml
            - yaml id:tempPackage unload

            - adjust system delete_file:../Kingdoms/packages/temp-package