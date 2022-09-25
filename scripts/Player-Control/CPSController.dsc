# Fuck off Denokit - you wasted my time for this shit

CPSLimiter:
    type: world
    debug: false
    events:
        on player clicks in inventory:
        - if <player.has_permission[kingdoms.admin]>:
            - ratelimit <player> 3t

        on player right clicks entity:
        - if <player.has_permission[kingdoms.admin]>:
            - ratelimit <player> 3t

        on player clicks block:
        - if <player.has_permission[kingdoms.admin]>:
            - ratelimit <player> 3t