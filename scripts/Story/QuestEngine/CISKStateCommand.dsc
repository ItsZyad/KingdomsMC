##ignorewarning def_of_nothing
##ignorewarning bad_execute

DenizenCISKMechMirrors:
    type: data
    entity:

        # PROPERTY-MECHANISM KEYS
        name:
            prop: /
            mech: display_name
        location:
            prop: location.simple
            mech: location
        health:
            prop: /
            mech: /
        oxygen:
            prop: /
            mech: /
        speed:
            prop: /
            mech: /
        isSwimming:
            prop: swimming
            mech: swimming
        isFlying:
            prop: is_flying
            mech: flying
        foodLevel:
            prop: food_level
            mech: food_level
        maxHealth:
            prop: health_max
            mech: max_health

        # PROPERTY-ONLY KEYS
        isTrading:
            prop: is_trading
        isAnimate:
            prop: is_living
        isMob:
            prop: is_mob
        isMonster:
            prop: is_monster
        isProjectile:
            prop: is_projectile
        isSpawned:
            prop: is_spawned
        maxOxygen:
            prop: max_oxygen
        onFire:
            prop: on_fire
        entityType:
            prop: entity_type
        uuid:
            prop: /
        direction:
            prop: location.yaw.simple
        type:
            prop: entity_type

# TODO: Make more of these ^

StateCommandMechanisms_CISK:
    type: task
    debug: false
    GetEntity:
    - define entityMechs <script[DenizenCISKMechMirrors].data_key[entity]>

    - if !<[stateMechanism].contains_text[.]>:
        - foreach <[entityMechs].keys> as:mech:
            - define mechInfo <[entityMechs].get[<[mech]>]>
            - define dynamicPropName <[mechInfo].get[prop]>
            - define dynamicPropName <[mech]> if:<[mechInfo].get[prop].equals[/]>

            - if <[stateMechanism]> == <[dynamicPropName]>:
                - define returnVal <element[<&lt>[entityStateTarget].<[dynamicPropName]><&gt>].parsed>
                - foreach stop

    - else:
        - if <[stateMechanism].starts_with[location.]>:
            - define locationComponent <[stateMechanism].split[.].get[2]>
            - definemap locationMap:
                x: <[entityStateTarget].location.x.round>
                y: <[entityStateTarget].location.y.round>
                z: <[entityStateTarget].location.z.round>
                world: <[entityStateTarget].location.world.name>

            - define returnVal <[locationMap].get[<[locationComponent]>]>

    - determine <[returnVal]> if:<[returnVal].exists>

    SetEntity:
    - define entityMechs <script[DenizenCISKMechMirrors].data_key[entity]>

    - foreach <[entityMechs].keys> as:mech:
        - define mechInfo <[entityMechs].get[<[mech]>]>

        - if !<[mechInfo].contains[mech]>:
            - foreach next

        - define dynamicMechName <[mechInfo].get[mech]>
        - define dynamicMechName <[mech]> if:<[mechInfo].get[mech].equals[/]>

        # - narrate format:debug STM:<[stateMechanism]>
        # - narrate format:debug DMN:<[dynamicMechName]>

        - if <[stateMechanism]> == <[dynamicMechName]>:
            - choose <[stateMechanism]>:
                - case location:
                    - define stateMechanismSet <proc[LocationType_CISK].context[<[stateMechanismSet]>|<[player]>]>

            - execute as_server "ex adjust <[entityStateTarget]> <[dynamicMechName]>:<[stateMechanismSet]>"
            # - narrate format:debug "ex adjust <[entityStateTarget]> <[dynamicMechName]>:<[stateMechanismSet]>"
            - foreach stop

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

    - else if <[stateMechanism].starts_with[outposts.]>:

        ## WARNING: Assumes that there can only be an outposts mechanism in the form of outposts.x
        ##          Any other format will bug out.

        - define outpostSecondComponent <[stateMechanism].split[.].get[2]>
        - define outpostKeyList <[targetKingdomFlag].get[outposts].deep_keys.filter_tag[<[filter_value].contains_text[.].not>]>
        - define returnVal <[targetKingdomFlag].deep_get[outposts.<[outpostSecondComponent]>]> if:<[outpostKeyList].contains[<[outpostSecondComponent]>]>

    - else if <[stateMechanism].starts_with[influence.]>:
        - define influenceArgs <[stateMechanism].split[.]>
        - define influenceInfo <[targetKingdomFlag].get[powerstruggle]>

        - choose <[influenceArgs].get[2]>:
            - case mercenaries:
                - define returnVal <[influenceInfo].get[mercenaryGuild]>

            - case government:
                - define returnVal <[influenceInfo].get[fyndalinGovt]>

            - case masons:
                - define returnVal <[influenceInfo].get[masonsGuild]>

            - case populace:
                - define returnVal <[influenceInfo].get[cityPopulation]>

            - case points:
                - define returnVal <[influenceInfo].get[influencePoints]>

            - case blackmarket:
                - define BMFactionsList <[influenceInfo].get[BMFactionInfluence].keys>

                - if <[influenceArgs].get[3].is_in[<[BMFactionList]>]>:
                    - define returnVal <[influenceInfo].deep_get[BMFactionInfluence.<[influenceArgs].get[3]>]>

    - narrate format:debug RET:<[returnVal]>
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

        - case set:
            - choose <[stateTarget].keys.get[1]>:
                - case player:

                    - if <[stateTarget].values.get[1]> == null:
                        - define entityStateTarget <[player]>

                    - else:
                        - define entityStateTarget <server.players.filter_tag[<[filter_value].name.equals[<[stateTarget].values.get[1]>]>].get[1]>

                    - inject <script.name> path:SetEntity
                    #- inject <script.name> path:SetPlayer