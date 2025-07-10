FastTravel:
    type: task
    script:
    - if <player.has_flag[fastTravelCooldown]>:
        - narrate format:callout "You have fast travelled recently, please wait another <player.flag_expiration[fastTravelCooldown].from_now.formatted_words.color[red]>"

    - else:
        - define kingdom <player.flag[kingdom]>
        - define allKingdoms <proc[GetKingdomList]>
        - define allOtherClaims <list[]>

        - foreach <[allKingdoms].exclude[<[kingdom]>]> as:currkingdom:
            - define territory <[kingdom].proc[GetClaims]>

        - define isPlayerInOtherClaims <[territory].contains[<player.location.chunk>]>

        - if !<player.has_flag[CombatMode]>:
            - if <[isPlayerInOtherClaims]>:
                - narrate format:callout "You are not allowed to fast travel from within another kingdom's claims"

            - else:
                - define warpName <context.raw_args.split[travel ].get[2].trim>
                - define warpNameUnderscored INTERNAL_STORY_<[warpName].replace[ ].with[_]>
                - define regionIndex <util.notes.find[<polygon[<[warpNameUnderscored]>]>]>
                - define regionIndex <util.notes.find[<cuboid[<[warpNameUnderscored]>]>]> if:<[regionIndex].equals[-1]>
                - define region <util.notes.get[<[regionIndex]>]>

                # - narrate format:debug RAW:<[warpName]>
                # - narrate format:debug UND:<[warpNameUnderscored]>
                # - narrate format:debug IND:<[regionIndex]>
                # - narrate format:debug REG:<[region]>

                - narrate format:callout "Fast travel will commence in 3 seconds. Don't move."
                - flag <player> fastTravelWarmup expire:3.2s
                - wait 3s

                - if <player.has_flag[fastTravelWarmup]>:
                    - teleport <player> <[region].flag[teleport]>
                    - flag <player> fastTravelWarmup:!
                    # Note: Should I stick with the original plan to limit it to
                    # only 3 fast-travels per day??
                    - flag <player> fastTravelCooldown expire:5m

        - else:
            - narrate format:callout "You may not use warps, you are in <red>combat mode!"

FastTravel_Handler:
    type: world
    debug: false
    events:
        on player walks:
        - if <player.has_flag[fastTravelWarmup]>:
            - ratelimit <player> 1t

            - define sameBlock <context.old_location.simple.equals[<context.new_location.simple>]>

            - if !<[sameBlock]>:
                - flag <player> fastTravelWarmup:!
                - narrate format:callout "Player moved. Cancelling fast travel..."

#CHAD RUHAN
TestMapScript:
    type: task
    definitions: image
    script:
    - map new:<player.location.world> image:<[image]> resize scale:FARTHEST save:map
    - give filled_map[map=<entry[map].created_map>]
