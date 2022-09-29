ReadOnlyChest_Item:
    type: item
    material: chest
    flags:
        readOnly: true

ReadOnlyChest_Handler:
    type: world
    debug: false
    events:
        on player places ReadOnlyChest_Item:
        - if !<server.flag[readOnlyChestLocs].contains[<context.location>]>:
            - flag server readOnlyChestLocs:->:<context.location>

        on player breaks chest:
        - if <server.flag[readOnlyChestLocs].contains[<context.location>]>:
            - flag server readOnlyChestLocs:<-:<context.location>

        on player clicks in inventory:
        - ratelimit <player> 1t

        - if <server.flag[readOnlyChestLocs].exists> && <context.inventory.id_holder.is_in[<server.flag[readOnlyChestLocs]>]>:
            - if !<player.is_op> && !<player.has_permission[kingdoms.admin.adjustreadonlychest]>:
                - if <context.item.material.name.is_in[written_book|writable_book]>:
                    - inventory close
                    - adjust <player> show_book:<context.item>

            - else:
                - if <context.click> == RIGHT:
                    #- narrate format:debug <context.item>
                    - inventory close
                    - wait 1t
                    - adjust <player> show_book:<context.item>
