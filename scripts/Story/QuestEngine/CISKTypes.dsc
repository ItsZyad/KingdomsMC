##
## This file contains procedures which are meant to take in raw ElementTags in CISK formats and
## convert them into their Denizen equivalents.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Apr 2023
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------


LocationType_CISK:
    type: procedure
    definitions: rawLoc|player
    description:
    - Converts CISK-format locations to Denizen and back
    - (Type cast for rawLoc is dynamic)
    script:
    # CISK -> DENZ
    - if <[rawLoc].object_type.to_uppercase> != LOCATION:
        - define formattedLocation <[rawLoc].split[,]>

        - choose <[formattedLocation].size>:
            - case 3:
                - define realLocation <location[<[rawLoc]>,0,0,<[player].location.world.name>]>

            - case 5:
                - define realLocation <location[<[rawLoc]>,<[player].location.world.name>]>

            - case 6:
                - define realLocation <location[<[rawLoc]>]>

        - if <[realLocation].exists>:
            - determine <[realLocation]>

        - else:
            - determine null

    # DENZ -> CISK
    - else:
        - determine <element[<[rawLoc].x>,<[rawLoc].y>,<[rawLoc].z>]>