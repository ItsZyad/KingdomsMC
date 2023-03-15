##
## * All scripts relating to the player's perspective of
## * reconstruction influence actions in Fyndalin
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2021
## @Script Ver: v0.7
##
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

ReconstructionPermit_Command:
    type: command
    name: reconstruction
    usage: /reconstruction
    description: Monitors the status of reconstruction permits made by each kingdom
    tab complete:
    - if <context.args.size> == 0:
        - if <player.is_op>:
            - determine all

        - else:
            - determine list

    script:
    - yaml load:reconstruction-permits.yml id:recon

    - yaml load:kingdoms.yml id:kingdoms
    - define kingdomList <proc[GetKingdomList].context[<yaml[kingdoms].parsed_key[]>]>
    - yaml id:kingdoms unload

    - define permitList <list[]>

    - if <player.has_permission[kingdoms.admin]> || <player.has_permission[kingdoms.admin.permits]> || <player.is_op>:
        - if <context.args.size> != 0:
            - if <context.args.get[1]> == all:
                - run ReconstructionPermitAdmin_Function
                - determine cancelled

        - else:
            - define permitList <list[]>

            - foreach <[kingdomList]>:
                - if <yaml[recon].contains[<[value]>.permits]>:
                    - define permitList <[permitList].include[<yaml[recon].read[<[value]>.permits.pending]>]>

    - else:
        - define permitList:->:<yaml[recon].read[<player.flag[kingdom]>.permits.pending]>

        - if <context.args.get[1]> == list:
            - narrate format:debug WIP

        - else if <[permitList].size.is[OR_MORE].than[1]>:
            - foreach <[permitList]>:
                - narrate -------------------------
                - narrate "Date of request: <gray><yaml[recon].read[permits.permit-<[value]>.requestdate]>"
                - narrate "Request status:  <gray><yaml[recon].read[permits.permit-<[value]>.requeststatus].to_titlecase>"

                - if <player.has_permission[kingdoms.admin]> || <player.has_permission[kingdoms.admin.permits]>:
                    - narrate "Requesting player: <gray><yaml[recon].read[permits.permit-<[value]>.requestingplayer.name]> <&r>// <blue><yaml[recon].read[permits.permit-<[value]>.requestingkingdom]>"

                - if <yaml[recon].read[permits.permit-<[value]>.requeststatus]> != pending:
                    - narrate "Plot location: <red><yaml[recon].read[permits.permit-<[value]>.plotlocation.exact]> <&r>in: <blue><yaml[recon].read[permits.permit-<[value]>.plotlocation.region]>"

        - else:
            - narrate format:callout "<red>Your kingdom has no active reconstruction permits at the moment."

    - yaml id:recon unload

ReconstructionPermit_Handler:
    type: world
    events:
        on player clicks Reconstruction_Influence in GovernmentInfluence_Window:
        - yaml id:ps load:powerstruggle.yml

        - define maxPlotSize <yaml[ps].read[<player.flag[kingdom]>.maxplotsize]>
        - flag player RequestedPayout:-1

        - narrate format:callout "Reconstruction permit requests can get your kingdom a compensation (upfront payment) from the mandate council for your help. Please type the width of plot you wish to be allocated to this permit. (may not exceed <[maxPlotSize]> blocks):"
        - narrate format:callout "Type <element['cancel'].color[red]> to stop the permit application."

        - inventory close

        - yaml id:ps unload

        on player chats:
        - if <player.flag[RequestedPayout]> == -1:
            - if <context.message.is_integer>:
                - flag <player> PlotSizeReq:<context.message>
                - flag <player> RequestedPayout:<player.flag[PlotSizeReq].mul[<util.random.int[70].to[120]>]>

                - run ReconstructionPermitSave def:<player>

                - define kingdom <player.flag[kingdom]>

                - yaml load:powerstruggle.yml id:ps
                - yaml id:ps set <[kingdom]>.dailyinfluences:-:1
                - yaml id:ps savefile:powerstruggle.yml
                - yaml id:ps unload

                - run SidebarLoader def.target:<server.flag[<[kingdom]>.members].include[<server.online_ops>]>

                - narrate format:callout "Your reconstruction permit request has been recieved and should be reviewed by the mandate council in 24 hours"
                - narrate <&sp>
                - narrate format:callout "You can follow the status of your kingdom's active requests with <blue>/reconstruction"

            - else if <context.message> == cancel:
                - narrate format:callout "Permit application cancelled!"

            - else:
                - narrate format:callout "Please specify your request as a valid number."

            - flag <player> PlotSizeReq:!
            - flag <player> RequestedPayout:!
            - determine cancelled

ReconstructionPermitSave:
    type: task
    definitions: player
    script:
    - yaml id:recon load:reconstruction-permits.yml

    - define unixTime <util.time_now.epoch_millis>

    - yaml id:recon set permits.permit-<[unixTime]>.requestingplayer.name:<[player].name>
    - yaml id:recon set permits.permit-<[unixTime]>.requestingplayer.uuid:<[player].uuid>
    - yaml id:recon set permits.permit-<[unixTime]>.requestingkingdom:<[player].flag[kingdom]>
    - yaml id:recon set permits.permit-<[unixTime]>.estimatedpayout:<[player].flag[RequestedPayout]>
    - yaml id:recon set permits.permit-<[unixTime]>.requestedplotsize:<[player].flag[PlotSizeReq]>
    - yaml id:recon set permits.permit-<[unixTime]>.requeststatus:pending
    - yaml id:recon set permits.permit-<[unixTime]>.requestdate:<util.time_now.format[yyyy-MM-dd]>
    - yaml id:recon set permits.permit-<[unixTime]>.plotcuboid:None
    - yaml id:recon set <player.flag[kingdom]>.permits.pending:->:<[unixTime]>
    - yaml id:recon savefile:reconstruction-permits.yml
    - yaml id:recon unload

ReconstructionPermitAdmin_Window:
    type: inventory
    inventory: chest
    title: "Reconstruction Permits"
    procedural items:
    - determine <player.flag[ReconWindow]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []

ReconstructionPermitApproval_Window:
    type: inventory
    inventory: chest
    title: "Approval for Permit"
    slots:
    - [] [] [PermitApprove] [] [] [] [PermitDecline] [] []

PermitApprove:
    type: item
    material: green_wool
    display name: "Approve Permit"

PermitDecline:
    type: item
    material: red_wool
    display name: "Decline Permit"

PlotRegionWand:
    type: item
    material: blaze_rod
    display name: "<light_purple><bold>Plot Wand"

ReconstructionPermitAdmin_Function:
    type: task
    script:
    - yaml load:reconstruction-permits.yml id:recon

    - yaml load:kingdoms.yml id:kingdoms
    - define kingdomList <proc[GetKingdomList].context[<yaml[kingdoms].parsed_key[]>]>
    - yaml id:kingdoms unload

    - define outInv <inventory[]>
    - define permitList <list[]>

    - foreach <[kingdomList]>:
        - define itemTemplate <item[paper]>

        - if <yaml[recon].contains[<[value]>]>:
            - define currPermitNumber <yaml[recon].read[<[value]>.permits.pending]>

            - foreach <[currPermitNumber]>:
                - define currPermit <yaml[recon].read[permits.permit-<[value]>]>

                - define requestingPlayer "<&r>Requesting Player: <blue><[currPermit].get[requestingplayer].get[name]>"
                - define requestingKingdom "<&r>On behalf of: <blue><script[KingdomRealNames].data_key[<[currPermit].get[requestingkingdom]>]>"
                - define requestedPlotSize "<&r>Requested Size: <blue><[currPermit].get[requestedplotsize]>"
                - define requestDate "<&r>Request Date: <blue><[currPermit].get[requestdate]>"

                - define lore <list[<[requestingPlayer]>|<[requestingKingdom]>|<[requestedPlotSize]>|<[requestDate]>]>

                - adjust def:itemTemplate lore:<[lore]>
                - adjust def:itemTemplate display_name:<&r><gray>Permit-<[value]>
                - flag <[itemTemplate]> permitId:permit-<[value]>

                - define permitList:->:<[itemTemplate]>

    - yaml id:recon unload

    #- narrate <[permitList]>
    - flag player ReconWindow:<[permitList]>
    - inventory open d:ReconstructionPermitAdmin_Window
    - flag player ReconWindow:!

ReconstructionPermitAdmin_Handler:
    type: world
    events:
        on player clicks paper in ReconstructionPermitAdmin_Window:
        - yaml load:reconstruction-permits.yml id:recon

        - define permit <yaml[recon].read[permits.<context.item.flag[permitId]>]>
        - flag player permitId:<context.item.flag[permitId]>
        - flag player activePermit:<[permit]>

        - yaml id:recon unload
        - determine passively cancelled

        - inventory open d:ReconstructionPermitApproval_Window

        on player clicks PermitApprove in ReconstructionPermitApproval_Window:
        - define permit <player.flag[activePermit]>
        - define permitId <player.flag[permitId]>
        - define permitIdRaw <[permitId].split[permit-].get[2]>
        - define reqKingdom <[permit].get[requestingkingdom]>
        - define reqPlayerId <[permit].get[requestingplayer].get[uuid]>

        - yaml load:powerstruggle.yml id:ps
        - yaml load:reconstruction-permits.yml id:recon

        - yaml id:recon set permits.<[permitId]>.requeststatus:approved
        - yaml id:recon set <[reqKingdom]>.permits.pending:<-:<[permitIdRaw]>
        - yaml id:recon set <[reqKingdom]>.permits.approved:->:<[permitIdRaw]>

        - flag <[reqPlayerId].as[player]> approvedPermit:<[permitId]>

        - yaml id:ps savefile:powerstruggle.yml
        - yaml id:recon savefile:reconstruction-permits.yml

        - yaml id:ps unload
        - yaml id:recon unload

        - determine passively cancelled

        - inventory close
        - give to:<player.inventory> PlotRegionWand

        on player clicks PermitDecline in ReconstructionPermitApproval_Window:
        - define permit <player.flag[activePermit]>
        - define permitId <player.flag[permitId]>
        - define reqPlayerId <[permit].get[requestingplayer].get[uuid]>
        - define reqKingdom <[reqPlayerId].as[player].flag[kingdom]>

        - flag <[reqPlayerId].as[player]> declinedPermit:<[permitId]>

        - yaml load:reconstruction-permits.yml id:recon
        - yaml id:recon set permits.<[permitID]>:!
        - yaml id:recon set <[reqKingdom]>.permits.pending:<-:<[permitId]>
        - yaml id:recon savefile:reconstruction-permits.yml
        - yaml id:recon unload

        - flag player permitId:!
        - flag player activePermit:!

        - run ReconstructionPermitAdmin_Function

        on player clicks block with:PlotRegionWand:
        - if <player.has_flag[plotCornerOne]>:
            - flag player plotCornerTwo:<context.location>
            - narrate format:admincallout "Corner Two Marked!"

            - define finalCuboid <cuboid[<player.world.name>,<player.flag[plotCornerOne].xyz>,<player.flag[plotCornerTwo].xyz>]>

            - yaml load:reconstruction-permits.yml id:recon
            - yaml id:recon set permits.<player.flag[permitId]>.plotcuboid:<[finalCuboid]>
            - yaml id:recon savefile:reconstruction-permits.yml

            - define kingdom <yaml[recon].read[permits.<player.flag[permitId]>.requestingKingdom]>
            - define plotId <player.flag[permitId].split[-].get[2]>

            - narrate format:admincallout "Saved plot location as: <blue><[finalCuboid]>"
            - note <[finalCuboid]> as:INTERNAL_RECONPERMIT_<[kingdom]>_<[plotId]>

            - yaml id:recon unload

            - flag player permitId:!
            - flag player activePermit:!
            - flag player plotCornerOne:!
            - flag player plotCornerTwo:!

            - take from:<player.inventory> item:PlotRegionWand
            - adjust <player> we_selection:<[finalCuboid]>
            - execute as_player "rg define -w <player.location.world.name> INTERNAL_RECONPERMIT_<[kingdom]>_<[plotId]>"
            - execute as_player "rg addowner -w <player.location.world.name> INTERNAL_RECONPERMIT_<[kingdom]>_<[plotId]> <player>"
            - execute as_player "rg setpriority -w <player.location.world.name> INTERNAL_RECONPERMIT_<[kingdom]>_<[plotId]> 1"

            - foreach <server.flag[<[kingdom]>.members]> as:player:
                - execute as_player "rg addmember -w <player.location.world.name> INTERNAL_RECONPERMIT_<[kingdom]>_<[plotId]> <[player]>"

            - wait 1s
            - narrate format:admincallout "Warning! Defining reconstruction areas sets your worldedit selections. Be sure to change them before using WE!"

        - else:
            - flag player plotCornerOne:<context.location>
            - narrate format:admincallout "Corner One Marked!"

        on player drops PlotRegionWand:
        - determine cancelled

        on player joins:
        - wait 2s
        - if <player.has_flag[approvedPermit]>:
            - narrate format:callout "Your request with id: <player.flag[approvedPermit].color[red]> for a reconstruction permit has been approved!"
            - flag player approvedPermit:!

        - else if <player.has_flag[declinedPermit]>:
            - narrate format:callout "Your request for a reconstruction permit <gray>(#<player.flag[declinedPermit]>) <&6>has been rejected"
            - flag player declinedPermit:!

# PlayerBuildPlot_Handler:
#     type: world
#     debug: false
#     events:
#         on player places block:
#         - define loc <context.location>

#         - if <[loc].in_region> && !<player.worldguard.can_build[<[loc]>]>:
#             - define kingdom <player.flag[kingdom]>

#             - if <[loc].cuboids[INTERNAL_RECONPERMIT_<[kingdom]>].size> != 0:
#                 - narrate format:debug <[loc].cuboids[INTERNAL_RECONPERMIT]>
#                 - determine BUILDABLE