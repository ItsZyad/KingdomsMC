# TODO: At some point use procedures to rewrite this mess!
# TODO: Implement check for overlapping outpost claims

OutpostClaim_Command:
    type: command
    usage: /oldoutpost
    name: oldoutpost
    permission: kingdoms.oldoutpost
    tab completions:
        1: claim|redefine|delete|cancel|showborder
    description: "Allows you to define and manage your claimed outposts"
    script:
        - if <context.args.get[1]> == showborder:
            - define param <context.args.get[2]>
            - define initialLoc <player.location>

            - showfake red_wool <cuboid[<[param]>].outline_2d[<[initialLoc].up[<[value]>].y>]> duration:30s
            - wait 1s

            - repeat 5:
                - showfake glass <cuboid[<[param]>].outline_2d[<[initialLoc].up[<[value]>].y>]> duration:30s
                - wait 1s

            - showfake red_wool <cuboid[<[param]>].outline_2d[<[initialLoc].up[<[value]>].y>]> duration:30s
            - wait 1s

        - if <context.args.get[1]> == specialize:
            - if <context.args.size.is[OR_MORE].than[2]>:
                - define param <context.args.get[2]>
                - yaml id:outp load:outposts.yml

                - foreach <yaml[outp].read[<player.flag[kingdom]>].keys.exclude[totalupkeep]>:
                    - if <[param]> == <[value]>:
                        - flag player outpostName:<[param]>
                        - inventory open d:OutpostSpec_Window

                        - foreach stop

                - if !<player.has_flag[outpostName]>:
                    - narrate format:callout "Unable to find outpost with the name '<[param]>'"

            - else:
                - narrate format:callout "Please specify the name of the outpost you want to specialize"

        - if <context.raw_args> == cancel:
            - flag player FirstPos:!
            - flag player DefineClaim:!
            - flag player RedefineClaim:!
            - narrate format:callout "Cancelled current outpost claim process"

        - else if <player.has_flag[DefineClaim]>:
            - if <player.flag[DefineClaim]> == 1:
                - flag player FirstPos:<player.location>
                - narrate format:callout "Please go to the second corner of your claim area and type '/outpost [outpost name]'"
                - flag player DefineClaim:2

            - else if <player.flag[DefineClaim]> == 2:
                - if <context.args.size.is[OR_MORE].than[1]>:
                    - define PosOne <player.flag[FirstPos]>
                    - flag player FirstPos:!
                    - define PosTwo <player.location>
                    #- narrate <player.world>
                    #- narrate <context.raw_args>
                    - flag player DefineClaim:!

                    - ~yaml load:outposts.yml id:outpost

                    - define found false

                    - foreach <yaml[outpost].read[<player.flag[kingdom]>].keys.exclude[totalupkeep]>:
                        - if <[value]> == <context.raw_args>:
                            - define found true

                    - if !<[found]>:
                        - define diffX <[PosOne].x.sub[<[PosTwo].x>].abs>
                        - define diffZ <[PosOne].z.sub[<[PosTwo].z>].abs>

                        - define size <[diffX].mul[<[diffZ]>]>

                        - yaml load:kingdoms.yml id:kingdoms

                        # If the size of the current claim is less than the maximum size of an outpost then commit the claim to relevant yaml files #
                        - if <[size].is[OR_LESS].than[<yaml[kingdoms].read[<player.flag[kingdom]>.outposts.max_size]>]>:
                            - define outpostCost <[size].mul[<yaml[kingdoms].read[<player.flag[kingdom]>.outposts.outpost_cost]>].round>
                            #- narrate format:debug "outpost cost: <[outpostCost]>"

                            # Add buffs and debuffs to viridian and cambrian respectively

                            - if <player.flag[kingdom]> == viridian:
                                - define outpostCost <[outpostCost].mul[2]>

                            - else if <player.flag[kingdom]> == cambrian:
                                - define outpostCost <[outpostCost].mul[0.9]>

                            # If the kingdom bank has more cash than is needed to make the initial payment of the outpost commit claim to relevant yaml files #
                            - if <yaml[kingdoms].read[<player.flag[kingdom]>.balance].is[OR_MORE].than[<[outpostCost]>]>:
                                #- narrate format:debug <[size]>

                                - note <cuboid[<player.world.name>,<[PosOne].as_location.x>,0,<[PosOne].as_location.z>,<[PosTwo].as_location.x>,255,<[PosTwo].as_location.z>]> as:<context.raw_args>

                                # Set data in outposts.yml

                                - yaml id:outpost set outposts.<context.raw_args>:<player.flag[kingdom]>
                                - yaml id:outpost set <player.flag[kingdom]>.<context.raw_args>.cornerone:<[PosOne].as_location>
                                - yaml id:outpost set <player.flag[kingdom]>.<context.raw_args>.cornertwo:<[PosTwo].as_location>
                                - yaml id:outpost set <player.flag[kingdom]>.<context.raw_args>.size:<[size].round>
                                - yaml id:outpost set <player.flag[kingdom]>.<context.raw_args>.upkeep:<yaml[outpost].read[<player.flag[kingdom]>.<context.raw_args>.size].mul[<yaml[kingdoms].read[<player.flag[kingdom]>.outposts.outpost_upkeep]>].round>

                                # Set data in kingdoms.yml

                                - yaml id:outpost set <player.flag[kingdom]>.totalupkeep:+:<player.flag[kingdom]>.<context.raw_args>.upkeep
                                - yaml id:kingdoms set <player.flag[kingdom]>.balance:-:<[outpostCost]>
                                - yaml id:kingdoms set <player.flag[kingdom]>.upkeep:+:<yaml[outpost].read[<player.flag[kingdom]>.<context.raw_args>]>

                                - run SidebarLoader def.target:<server.flag[<player.flag[kingdom]>.members].include[<server.online_ops>]>

                            - else:
                                - narrate format:callout "You do not have enough funds in your kingdom's balance to start this outpost. Needed cash: <red>$<[outpostCost]>"

                        - else:
                            - narrate format:callout "This claim exceeds the maximum size allowed for outposts of your kingdom! The size of your current claim is: <[size]>"

                        - yaml savefile:outposts.yml id:outpost
                        - yaml savefile:kingdoms.yml id:kingdoms
                        - yaml id:kingdoms unload

#############################################################################################################################################################

                    - else:
                        - if <player.has_flag[RedefineClaim]>:
                            - narrate format:debug <context.raw_args>

                            - define cornerOne <yaml[outpost].read[<player.flag[kingdom]>.<context.raw_args>.cornerone]>
                            - define cornerTwo <yaml[outpost].read[<player.flag[kingdom]>.<context.raw_args>.cornertwo]>
                            - define diffX <[cornerOne].x.sub[<[cornerTwo].x>].abs>
                            - define diffZ <[cornerOne].z.sub[<[cornerTwo].z>].abs>

                            - narrate format:debug DX:<[diffX]>
                            - narrate format:debug DY:<[diffZ]>

                            - define size <[diffX].mul[<[diffZ]>]>

                            - yaml load:kingdoms.yml id:kingdoms

                            # Outpost overlap checker #

                            - define doesOutpostOverlap false

                            # Redefined claims #
                            - define newClaims <cuboid[<player.world.name>,<[PosOne].as_location.x>,0,<[PosOne].as_location.z>,<[PosTwo].as_location.x>,255,<[PosTwo].as_location.z>]>

                            # Looping through all the outposts and if the new claims overlap with
                            # any of them then set doesOutpostOverlap to true

                            - foreach <yaml[outpost].read[outposts].to_pair_lists>:
                                - define kingdom <[value].get[2]>
                                - define otherOutpostName <[value].get[1]>
                                - define otherCornerOne <yaml[outpost].read[<[kingdom]>.<[otherOutpostName]>.cornerone]>
                                - define otherCornerTwo <yaml[outpost].read[<[kingdom]>.<[otherOutpostName]>.cornertwo]>
                                - define otherOutpost <cuboid[KingdomsUTD,<[otherCornerOne]>,<[otherCornerTwo]>]>

                                - if <[otherOutpost].intersects[<[newClaims]>]>:
                                    - define doesOutpostOverlap true
                                    - foreach stop

                            # If the size of the current claim is less than the maximum size of an outpost then commit the claim to relevant yaml files #
                            - if <[size].is[OR_LESS].than[<yaml[kingdoms].read[<player.flag[kingdom]>.outposts.max_size]>]>:
                                #- narrate format:debug <[size]>

                                - if !<[doesOutpostOverlap]>:
                                    # Clear old outpost notable and replace it with redefined one

                                    - note remove as:<player.flag[RedefineClaim]>
                                    - note <cuboid[<player.world.name>,<[PosOne].as_location.x>,0,<[PosOne].as_location.z>,<[PosTwo].as_location.x>,255,<[PosTwo].as_location.z>]> as:<context.raw_args>

                                    # Set location of outpost in outposts.yml #
                                    - yaml id:outpost set <player.flag[kingdom]>.<context.raw_args>.cornerone:<[PosOne].as_location>
                                    - yaml id:outpost set <player.flag[kingdom]>.<context.raw_args>.cornertwo:<[PosTwo].as_location>
                                    - yaml id:outpost set <player.flag[kingdom]>.<context.raw_args>.size:<[size].round>
                                    - yaml id:outpost set <player.flag[kingdom]>.<context.raw_args>.upkeep:<yaml[outpost].read[<player.flag[kingdom]>.<context.raw_args>.size].mul[<yaml[kingdoms].read[<player.flag[kingdom]>.outposts.outpost_upkeep]>].round>

                                    - yaml id:outpost set <player.flag[kingdom]>.totalupkeep:+:<player.flag[kingdom]>.<context.raw_args>.upkeep

                                    - flag player RedefineClaim:!

                                - else:
                                    - narrate format:callout "You cannot expand your outpost into this area! There is already another claim here."

                            - else:
                                - narrate format:callout "This claim exceeds the maximum size allowed for outposts of your kingdom! The size of your current claim is: <red><[size]>"
                                - narrate format:callout "You may try again by making the redefinition smaller, or you can type /outpost cancel to revert the outpost to its original size."

                            - yaml savefile:outposts.yml id:outpost
                            - yaml id:kingdoms unload

                        - else:
                            - narrate format:callout "You already have an outpost by this name!"

                    - yaml unload id:outpost

                - else:
                    - narrate format:callout "You did not specify a name for this outpost please redo your second position"

#############################################################################################################################################################

        - else:
            - if <context.raw_args> == claim:
                - flag player DefineClaim:1
                - narrate format:callout "Entered outpost claim mode. Please go to the first corner of your claim and type '/outpost'"
                - narrate format:callout "To cancel at anytime type '/outpost cancel'"

            - else if <context.args.get[1]> == redefine:
                - if <player.has_permission[kingdoms.outpost.redefine]>:
                    - yaml load:outposts.yml id:outpost

                    - define found false

                    - foreach <yaml[outpost].read[<player.flag[kingdom]>].keys>:
                        - narrate <[value]>
                        - if <[value]> == <context.args.get[2]>:
                            - define found true

                    - if <[found]>:
                        - flag player DefineClaim:1
                        - flag player RedefineClaim:<context.args.get[2]>

                        - narrate format:callout "Now redefining: <context.args.get[2]>. Go to the first corner of your selection"

                    - else:
                        - narrate format:callout "There doesn't seem to be an outpost by that name in your kingdom"

                    - yaml unload id:outpost

                - else:
                    - narrate format:callout "You are not allowed to redefine the claims of outposts! This must be performed by a higher-ranking member of your kingdom."

            - else if <context.args.get[1]> == delete:
                - if <player.has_permission[kingdoms.outpost.delete]>:
                    - define name <context.args.get[2]>
                    - yaml load:outposts.yml id:outposts

                    - yaml id:outposts set <player.flag[kingdom]>.<[name]>:!
                    - yaml id:outposts set outposts.<[name]>:!
                    - note remove as:<[name]>
                    - narrate format:callout "Successfully deleted outpost by the name <[name]>"

                - else:
                    - narrate format:callout "You do not have sufficient permissions to delete an outpost! This must be performed by a higher-ranking member of your kingdom."

                - yaml id:outposts savefile:outposts.yml
                - yaml id:outposts unload