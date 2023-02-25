##ignorewarning def_of_nothing

StateCommandMechanisms_CISK:
    type: task
    GetEntity:
    - choose <[stateMechanism]>:
        - case name:
            - define returnVal <[entityStateTarget].name>

        - case uuid:
            - define returnVal <[entityStateTarget].uuid>

        - case location:
            - define returnVal <[entityStateTarget].location.simple>

        - case health:
            - define returnVal <[entityStateTarget].health>

        - case isSwimming:
            - define returnVal <[entityStateTarget].swimming>

        - case isFlying:
            - define returnVal <[entityStateTarget].is_flying>

        - default:
            - if <[stateMechanism].starts_with[location.]>:
                - define locationComponent <[stateMechanism].split[.].get[2]>
                - definemap locationMap:
                    x: <[entityStateTarget].location.x.round>
                    y: <[entityStateTarget].location.y.round>
                    z: <[entityStateTarget].location.z.round>
                    world: <[entityStateTarget].location.world.name>

                - define returnVal <[locationMap].get[<[locationComponent]>]>

    - narrate format:debug <[returnVal]>
    - determine <[returnVal]>

    script:
    - choose <[stateAction]>:
        - case get:
            - choose <[stateTarget].keys.get[1]>:
                - case player:
                    - if <[stateTarget].values.get[1]> == null:
                        - define entityStateTarget <[player]>

                    - else:
                        - define entityStateTarget <server.players.filter_tag[<[filter_value].name.equals[<[stateTarget].values.get[1]>]>].get[1]>

                    - inject <script.name> path:GetEntity

                - case npc:
                    - if <[stateTarget].values.get[1]> == null:
                        - define entityStateTarget <[npc]>

                    - else:
                        - define entityStateTarget <server.npcs.filter_tag[<[filter_value].name.equals[<[stateTarget].values.get[1]>]>].get[1]>

                    - inject <script.name> path:GetEntity

                - case item:
                    - if <[stateTarget].values.get[1]> == null:
                        - define itemStateTarget <[player].item_in_hand>

                    - else:
                        - narrate format:debug WIP
