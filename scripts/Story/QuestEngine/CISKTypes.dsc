LocationType_CISK:
    type: procedure
    definitions: rawLoc[(ElementTag) Anticipated Format: x,y,z(,pitch)(,yaw)(,world)]|player[(PlayerTag)]
    script:
    - define formattedLocation <[rawLoc].split[,]>

    - choose <[formattedLocation].size>:
        - case 3:
            - define realLocation <location[<[rawLoc]>,0,0,<[player].location.world.name>]>

        - case 5:
            - define realLocation <location[<[rawLoc]>,<[player].location.world.name>]>

        - case 6:
            - define realLocation <location[<[rawLoc]>]>

        - default:
            - narrate format:debug "Invalid arguments for CISK location type casting."

    - determine <[realLocation]>