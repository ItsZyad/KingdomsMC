##ignorewarning def_of_nothing

StateCommandMechanisms_CISK:
    type: task
    debug: false
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

    - determine <[returnVal]> if:<[returnVal].exists>

    GetPlayer:
    - choose <[stateMechanism]>:
        - case kingdom:
            - define returnVal <[entityStateTarget].flag[kingdom]>

        - case balance:
            - define returnVal <[entityStateTarget].money>

    - determine <[returnVal]> if:<[returnVal].exists>

    GetKingdom:
    - define nonMapKeys <[targetKingdomFlag].keys.filter_tag[<[targetKingdomFlag].get[<[filter_value]>].deep_keys.exists.not>]>

    - if <[stateMechanism].is_in[<[nonMapKeys]>]>:
        - define returnVal <[targetKingdomFlag].get[<[stateMechanism]>]>

    - determine <[returnVal]> if:<[returnVal].exists>

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
                    - inject <script.name> path:GetPlayer

                - case npc:
                    - if <[stateTarget].values.get[1]> == null:
                        - define entityStateTarget <[npc]>

                    - else:
                        - define entityStateTarget <server.npcs.filter_tag[<[filter_value].name.equals[<[stateTarget].values.get[1]>]>].get[1]>

                    - inject <script.name> path:GetEntity

                - case kingdom:
                    - if <[stateTarget].values.get[1]> == null:
                        - define targetKingdomFlag <server.flag[kingdoms.<[player].flag[kingdom]>]>

                    - else:
                        - define targetKingdom <proc[GetKingdomList].get[<[stateTarget]>]>
                        - define targetKingdomFlag <server.flag[kingdoms.<[targetKingdom]>]>

                    - inject <script.name> path:GetKingdom

                - case item:
                    - if <[stateTarget].values.get[1]> == null:
                        - define itemStateTarget <[player].item_in_hand>

                    - else:
                        - narrate format:debug WIP
