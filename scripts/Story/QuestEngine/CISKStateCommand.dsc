##ignorewarning def_of_nothing

StateCommandMechanisms_CISK:
    type: task
    GetEntity:
    - choose <[stateMechanism]>:
        - case name:
            - define returnVal <[playerStateTarget].name>

        - case uuid:
            - define returnVal <[playerStateTarget].uuid>

        - case location:
            - define returnVal <[playerStateTarget].location.simple>

        - case health:
            - define returnVal <[playerStateTarget].health>

        - default:
            - if <[stateMechanism].starts_with[location.]>:
                - define locationComponent <[stateMechanism].split[.].get[2]>
                - definemap locationMap:
                    x: <[playerStateTarget].location.x.round>
                    y: <[playerStateTarget].location.y.round>
                    z: <[playerStateTarget].location.z.round>
                    world: <[playerStateTarget].location.world.name>

                - define returnVal <[locationMap].get[<[locationComponent]>]>

    - narrate format:debug <[returnVal]>
    - determine <[returnVal]>

    script:
    - choose <[stateAction]>:
        - case get:
            - choose <[stateTarget].keys.get[1]>:
                - case player:
                    - if <[stateTarget].values.get[1]> == null:
                        - define playerStateTarget <[player]>

                    - else:
                        - define playerStateTarget <server.players.filter_tag[<[filter_value].name.equals[<[stateTarget].values.get[1]>]>].get[1]>

                    - inject <script.name> path:GetEntity

                - case npc:
                    - narrate format:debug WIP

                - case item:
                    - narrate format:debug WIP
