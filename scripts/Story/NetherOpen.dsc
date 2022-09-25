NetherPortal_Handler:
    type: world
    events:
        on player creates portal:
        - if <server.has_flag[NetherClosed]>:
            - determine cancelled