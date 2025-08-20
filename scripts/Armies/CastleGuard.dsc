##
## All scripts which relate to the management, and player interaction with the castle guards tool
## are stored in this file.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jul 2022
## @Script Ver: v2.0
##
##ignorewarning invalid_data_line_quotes
## ------------------------------------------END HEADER-------------------------------------------

CastleGuard:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
    interact scripts:
    - CastleGuard_I


CastleGuard_I:
    type: interact
    steps:
        1:
            click trigger:
                script:
                - if <player.flag[kingdom]> == <npc.flag[kingdom]>:
                    - inventory open d:Guard_Window
                    - flag <player> clickedNPC:<npc>

##############################################################################


Guard_Window:
    type: inventory
    inventory: chest
    title: "Change Guard Properties"
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [ShowGuardInventory_Item] [] [ShowGuardArmour_Item] [] [] []
    - [] [GuardName_Item] [] [] [GuardAnchorPosition_Item] [] [] [GuardIncursionReports_Item] []
    - [] [EngagementRules_Item] [] [] [GuardAnchorReturn_Item] [] [] [GuardGetIncursionRecord_Item] []
    - [] [] [] [] [GuardDelete_Item] [] [] [] []


GuardDeleteConfirm_Window:
    type: inventory
    inventory: chest
    title: "Confirm Guard Deletion"
    gui: true
    slots:
    - [] [] [] [GuardConfirmDelete_Item] [] [GuardDenyDelete_Item] [] [] []


GuardConfirmDelete_Item:
    type: item
    material: green_wool
    display name: "<green><bold>Confirm Deletion"


GuardDenyDelete_Item:
    type: item
    material: red_wool
    display name: "<red><bold>Deny Deletion"

GuardName_Item:
    type: item
    material: name_tag
    display name: "<gold>Change Guard Name"


EngagementRules_Item:
    type: item
    material: iron_sword
    display name: "<light_purple>Engagement Rules"


ShowGuardInventory_Item:
    type: item
    material: player_head
    display name: "<aqua><bold>Show Inventory"


ShowGuardArmour_Item:
    type: item
    material: iron_chestplate
    display name: "<aqua><bold>Show Armour"
    mechanisms:
        hides: ALL


GuardIncursionReports_Item:
    type: item
    material: writable_book
    display name: "Show Incursion Record"
    lore:
    - "<gold><bold>Warning!"
    - "This record will only show the last 45 incursion records."
    - "Any records prior are automatically cleared."


GuardGetIncursionRecord_Item:
    type: item
    material: player_head
    display name: "Grab Incursion Record"
    mechanisms:
        skull_skin: 768ab376-5e89-4291-a0ed-1bd5ffe7526|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDAwM2E1NjUxYzRkMWY4YTA4YTEwNzAxYjAwNTBmYWEyMmNlYzI2ZmM2Njc3YmUwODgzODA2M2IyYTk3Y2RjZCJ9fX0=
    lore:
    - "<gray><bold>Note:"
    - "This button will grab the current incursion record as"
    - "it currently stands"


GuardWindowBack_Item:
    type: item
    material: player_head
    display name: Back
    mechanisms:
        skull_skin: e5b4f889-64ba-3de9-a5b4-f88964baade9|e3RleHR1cmVzOntTS0lOOnt1cmw6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNGM2ZGNjYzk2Y2YzZGRkNTFjYWE3MDYyM2UxZWIzM2QxZWFlYTU3NDVhNDUyZjhhNWM0ZDViOWJlYWFhNWNjNCJ9fX0=


GuardAnchorPosition_Item:
    type: item
    material: player_head
    display name: "<blue>Set Anchor Position"
    mechanisms:
        skull_skin: ccd469f7-1df1-42f9-8915-15de387906e4|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOWI3Y2U2ODNkMDg2OGFhNDM3OGFlYjYwY2FhNWVhODA1OTZiY2ZmZGFiNmI1YWYyZDEyNTk1ODM3YTg0ODUzIn19fQ==
    lore:
    - "The anchor position is where the guard returns when it"
    - "no longer tracks any targets."


GuardAnchorReturn_Item:
    type: item
    material: player_head
    display name: "<aqua>Return To Anchor Position"
    mechanisms:
        skull_skin: 224dc80c-4f14-4c9d-81f2-194d1d8116a0|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvY2M1Yjk1NDJjYTQ2YjAwMjM1ZDNkZGRhZGEwMjk5M2JjNGQyZjdlNjNhNWJmNDViMDRhZTZlNzI1OWM3M2U0OCJ9fX0=
    lore:
    - "Will make the guard return to its <element[current].underline> <element[anchor position].color[#A700A7].italicize>"


GuardDelete_Item:
    type: item
    material: barrier
    display name: "<red><bold>Delete Guard"


GuardIncursionReport_Book:
    type: book
    title: null
    author: null
    signed: true
    text:
    - null


GuardInterface_Handler:
    type: world
    events:
        on player clicks ShowGuardInventory_Item in Guard_Window:
        #- narrate format:debug <player.flag[clickedNPC]>
        - inventory open d:<player.flag[clickedNPC].inventory>
        - flag <player> lookingAtNPCInv

        on player clicks ShowGuardArmour_Item in Guard_Window:
        - inventory open d:GuardArmour_Window

        on player clicks EngagementRules_Item in Guard_Window:
        - inventory open d:EngagementRules_Window

        on player clicks GuardGetIncursionRecord_Item in Guard_Window:
        - if <player.inventory.can_fit[written_book].quantity[1]>:
            - define guard <player.flag[clickedNPC]>
            - define bookItem <item[GuardIncursionReport_Book]>
            - define bookPageList <list[]>

            - foreach <[guard].flag[incReports]> as:report:
                - define incursionNumber "Incursion Report #<[loop_index]>"
                - define dateFormatted "<[report].get[date].to_zone[UTC].format[YYYY-MM-dd @ hh:mm]> UTC"
                - define playerName <[report].get[player].name>
                - define IncNum <[report].get[incNumber].if_null[1]>
                - define kingdomName <proc[GetKingdomName].context[<[report].get[kingdom]>]>

                - define "bookPageList:->:<element[<[incursionNumber]><n><n><element[Date of Inc: ]><[dateFormatted]>]><n><element[Player: ]><[playerName]><n><element[From Kingdom: ]><[kingdomName]><n><element[Number of Incursions: ]><[incNum]>"

            - adjust def:bookItem book_pages:<[bookPageList]>
            - adjust def:bookItem "book_title:Incursion Summary <util.time_now.format[YYYY-MM-dd]>"
            - adjust def:bookItem book_author:<[guard].name>

            - give to:<player.inventory> <[bookItem]>

        - else:
            - narrate format:callout "Clear some space from your inventory to get the incursion record."

        on player clicks GuardIncursionReports_Item in Guard_Window:
        - define incursionItemList <list[]>
        - define guard <player.flag[clickedNPC]>

        - if <[guard].flag[incReports].size> == 0 || !<[guard].has_flag[incReports]>:
            - narrate format:callout "There are no incursions to report."
            - determine cancelled

        - foreach <[guard].flag[incReports]> as:report:
            - define incItem <item[IncursionRecord_Item]>
            - define dateFormatted "<[report].get[date].to_zone[UTC].format[YYYY-MM-dd @ hh:mm]> UTC"
            - define playerName <[report].get[player].name>
            - define IncNum <[report].get[incNumber].if_null[1]>
            - define kingdomName <proc[GetKingdomName].context[<[report].get[kingdom]>]>

            - adjust def:incItem lore:|<element[Date of Inc: ].bold.color[white]><[dateFormatted].color[aqua]>|<element[Player: ].bold.color[white]><[playerName].color[aqua]>|<element[From Kingdom: ].bold.color[white]><[kingdomName].color[aqua]>|<element[Number of Incursions: ].bold.color[white]><[incNum].color[aqua]>
            - define incursionItemList:->:<[incItem]>

        - flag <player> incursionItems:<[incursionItemList]>
        - inventory open d:IncursionRecords_Window
        - flag <player> incursionItems:!

        on player clicks GuardName_Item in Guard_Window:
        - flag <player> changingGuardName
        - inventory close
        - narrate format:callout "Type the desired new name for this guard here (type 'cancel' to keep the name unchanged):"

        on player chats flagged:changingGuardName:
        - if <context.message.to_lowercase> != cancel:
            - define guard <player.flag[clickedNPC]>
            # Matches the length of the name with spaces:
            # |<element[<&sp>].pad_right[<[guard].name.text_width.div[<&sp.text_width>].round>].with[<&sp>]>
            - adjust <[guard]> hologram_lines:<list[Name<&co><&sp><context.message>]>
            - adjust <[guard]> hologram_line_height:0.25

        - else:
            - narrate format:callout "Cancelled guard renaming!"

        - flag <player> changingGuardName:!
        - determine cancelled

        on player clicks GuardAnchorPosition_Item in Guard_Window:
        - inventory close
        - flag <player> redefiningGuardAnchor
        - narrate format:callout "Walk to the position where you want the new anchor position to be and type 'set' (with no slash) or type 'cancel' to stop this process"

        on player clicks GuardAnchorReturn_Item in Guard_Window:
        - inventory close
        - define anchorPosition <player.flag[clickedNPC].flag[guardPos]>
        - run StaggeredPathfind def.npc:<player.flag[clickedNPC]> def.endLocation:<[anchorPosition]> def.recursionDepth:0 def.speed:1.1

        on player chats flagged:redefiningGuardAnchor:
        - define guard <player.flag[clickedNPC]>

        - if <context.message> != cancel:
            - flag <[guard]> guardPos:<player.location>
            - run StaggeredPathfind def.npc:<[guard]> def.endLocation:<player.location.center> def.recursionDepth:0 def.speed:1.1

        - else:
            - narrate format:callout "Cancelled guard repositioning!"

        - flag player redefiningGuardAnchor:!
        - determine cancelled

        on player clicks GuardDelete_Item in Guard_Window:
        - inventory open d:GuardDeleteConfirm_Window

        on player clicks GuardDenyDelete_Item in GuardDeleteConfirm_Window:
        - inventory close

        on player clicks GuardConfirmDelete_Item in GuardDeleteConfirm_Window:
        - define guard <player.flag[clickedNPC]>
        - define kingdom <[guard].flag[kingdom]>
        - define guardInListIndex <server.flag[kingdoms.<[kingdom]>.castleGuards].find[<[guard]>]>

        - flag server kingdoms.<[kingdom]>.castleGuards:<server.flag[kingdoms.<[kingdom]>.castleGuards].remove[<[guardInListIndex]>]>

        - remove <[guard]>

        - inventory close

        on player closes inventory flagged:lookingAtNPCInv:
        - inventory open d:Guard_Window
        - flag <player> lookingAtNPCInv:!

        on player closes Guard_Window:
        - wait 2t
        - if !<player.open_inventory.exists>:
            - flag <player> clickedNPC:!


##############################################################################


GuardArmour_Window:
    type: inventory
    inventory: chest
    title: Armour
    procedural items:
    - determine <player.flag[clickedNPC].inventory.equipment.reverse>
    slots:
    - [] [] [] [] [GuardBlockedSlot_Item] [GuardBlockedSlot_Item] [GuardBlockedSlot_Item] [GuardBlockedSlot_Item] [GuardBlockedSlot_Item]


GuardBlockedSlot_Item:
    type: item
    material: barrier
    display name: "<red><bold>Unused"


GuardArmour_Handler:
    type: world
    events:
        # yes i know, duplicate events.
        # suck my ass
        on player closes GuardArmour_Window:
        - define slots <context.inventory.list_contents.get[1].to[4]>
        - definemap armourMap:
            helmet: <[slots].get[1]>
            chestplate: <[slots].get[2]>
            leggings: <[slots].get[3]>
            boots: <[slots].get[4]>

        - adjust <player.flag[clickedNPC]> equipment:<[armourMap]>

        on player left clicks in GuardArmour_Window:
        - wait 1t
        - define slots <context.inventory.list_contents.get[1].to[4]>
        - definemap armourMap:
            helmet: <[slots].get[1]>
            chestplate: <[slots].get[2]>
            leggings: <[slots].get[3]>
            boots: <[slots].get[4]>

        - adjust <player.flag[clickedNPC]> equipment:<[armourMap]>

##############################################################################


IncursionRecords_Window:
    type: inventory
    inventory: chest
    title: "Incursion Records"
    gui: true
    procedural items:
    - determine <player.flag[incursionItems]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []


IncursionRecord_Item:
    type: item
    material: writable_book
    display name: "<red><bold>Incursion Record"
    mechanisms:
        hides: ALL
    enchantments:
    - sharpness:1

##############################################################################


EngagementRules_Window:
    type: inventory
    inventory: chest
    title: "Engagment Rules"
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [EngageOnSight_Item] [] [EngageIfKingdom_Item] [] [GuardReportOnly_Item] [] [GuardDoNotEngage_Item] []
    - [] [] [] [] [GuardWindowBack_Item] [] [] [] []


EngageOnSight_Item:
    type: item
    material: diamond_sword
    display name: "<red><bold>Kill on Sight"
    enchantments:
    - sharpness:1
    mechanisms:
        hides: <list[enchants|attributes]>
    flags:
        engagementRule: always


EngageIfKingdom_Item:
    type: item
    material: player_head
    display name: "<&color[#ff8812]><bold>Engage Certain Kingdoms"
    mechanisms:
        skull_skin: bcccae77-0ac7-4cd0-8126-c900727c2223|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNDljMTgzMmU0ZWY1YzRhZDljNTE5ZDE5NGIxOTg1MDMwZDI1NzkxNDMzNGFhZjI3NDVjOWRmZDYxMWQ2ZDYxZCJ9fX0=
    flags:
        engagementRule: kingdom


GuardReportOnly_Item:
    type: item
    material: writable_book
    display name: "<yellow><bold>Report Incursions Only"
    flags:
        engagementRule: report


GuardDoNotEngage_Item:
    type: item
    material: barrier
    display name: "<gray><bold>Do Not Engage"
    flags:
        engagementRule: none


GuardEngagement_Handler:
    type: world
    events:
        on player clicks item in EngagementRules_Window:
        - if <context.item.has_flag[engagementRule]>:
            - define npc <player.flag[clickedNPC]>
            - define flagVal <context.item.flag[engagementRule]>

            - flag <[npc]> engagementRule:<[flagVal]>
            - customevent id:GuardChangedEngagement context:<map[npc=<[npc]>|engagement_rule=<[flagVal]>]>

        on player clicks EngageOnSight_Item in EngagementRules_Window:
        - define guard <player.flag[clickedNPC]>
        - flag <[guard]> targetInfo.whichAttack:<proc[GetKingdomList].exclude[<[guard].flag[kingdom]>]>
        - flag <[guard]> targetInfo.whichWarn:<list[]>
        - narrate format:callout "Guard will now engage all other kingdoms with hostility!"

        on player clicks GuardReportOnly_Item in EngagementRules_Window:
        - define guard <player.flag[clickedNPC]>

        - if <[guard].flag[targetInfo.reportInc].size> == 0:
            - flag <[guard]> targetInfo.whichAttack:<list[]>
            - flag <[guard]> targetInfo.reportInc:<proc[GetKingdomList].exclude[<[guard].flag[kingdom]>]>
            - narrate format:callout "Guard will now report all activity, within 20 blocks, that they see!"

        - else:
            - flag <[guard]> targetInfo.reportInc:<list[]>
            - narrate format:callout "Guard will no longer report activity!"

        on player clicks GuardDoNotEngage_Item in EngagementRules_Window:
        - define guard <player.flag[clickedNPC]>
        - flag <[guard]> targetInfo.whichAttack:<list[]>
        - flag <[guard]> targetInfo.whichWarn:<list[]>
        - narrate format:callout "Guard will no longer engage."

        on player clicks EngageIfKingdom_Item in EngagementRules_Window:
        - define guard <player.flag[clickedNPC]>
        - define kingdomEngagementWindow <inventory[GuardKingdomEngagement_Window]>

        - foreach <[kingdomEngagementWindow].list_contents>:
            - define kingdom <[value].flag[kingdom]>

            - if <[guard].flag[targetInfo.whichAttack].contains[<[kingdom]>]>:
                - inventory adjust d:<[kingdomEngagementWindow]> slot:<[loop_index]> lore:<element[Engaging members of this kingdom].color[red].bold>

            - else:
                - inventory adjust d:<[kingdomEngagementWindow]> slot:<[loop_index]> lore:<element[Not engaging members of this kingdom].color[white].bold>

        - inventory open d:<[kingdomEngagementWindow]>

        on player clicks GuardWindowBack_Item in EngagementRules_Window:
        - inventory open d:Guard_Window

##############################################################################


GuardKingdomEngagement_Window:
    type: inventory
    inventory: chest
    title: Engage Certain Kingdoms
    gui: true
    procedural items:
    - define kingdomList <proc[GetKingdomList]>
    - define itemList <list[<item[air]>]>

    - foreach <[kingdomList]> as:kingdom:
        - define kingdomColorName <proc[GetKingdomColor].context[<[kingdom]>].name>
        - define item <item[<[kingdomColorName]>_banner]>

        - adjust def:item display:<element[Engage Members of <proc[GetKingdomShortName].context[<[kingdom]>]>].bold.color[<proc[GetColor].context[Default.<[kingdomColorName]>]>]>
        - adjust def:item flag:kingdom:<[kingdom]>

        - define itemList:->:<[item]>
        - define itemList:->:<item[air]>

        - if <[loop_index].mod[4]> == 0:
            - define itemList:->:<item[air]>

    - determine <[itemList]>

    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []


GuardKingdomEngagement_Handler:
    type: world
    events:
        on player clicks item in GuardKingdomEngagement_Window:
        - define kingdom <context.item.flag[kingdom]>
        - define guard <player.flag[clickedNPC]>
        - define kingdomEngagementWindow <inventory[GuardKingdomEngagement_Window]>

        - if <[kingdom]> == <player.flag[kingdom]>:
            - narrate format:callout "You cannot make your guards attack your own kingdom members!"
            - determine cancelled

        - if <[guard].flag[targetInfo.whichAttack].contains[<[kingdom]>]>:
            - flag <[guard]> targetInfo.whichAttack:<-:<[kingdom]>

        - else:
            - flag <[guard]> targetInfo.whichAttack:->:<[kingdom]>

        - foreach <[kingdomEngagementWindow].list_contents>:
            - define kingdom <[value].flag[kingdom]>

            - if <[guard].flag[targetInfo.whichAttack].contains[<[kingdom]>]>:
                - inventory adjust d:<[kingdomEngagementWindow]> slot:<[loop_index]> lore:<element[Engaging members of this kingdom].color[red].bold>

            - else:
                - inventory adjust d:<[kingdomEngagementWindow]> slot:<[loop_index]> lore:<element[Not engaging members of this kingdom].color[white].bold>

        - inventory open d:<[kingdomEngagementWindow]>

##############################################################################


GuardSetup:
    type: task
    definitions: player[PlayerTag]
    description:
    - Will spawn and set up a castle guard NPC under the same kingdom as the provided player.
    - ---
    - → [Void]

    script:
    ## Will spawn and set up a castle guard NPC under the same kingdom as the provided player.
    ##
    ## player : [PlayerTag]
    ##
    ## >>> [Void]

    - define numberOfGuards <server.flag[kingdoms.<[player].flag[kingdom]>.castleGuards].size.if_null[0]>

    - create player "<red><bold>[<[numberOfGuards].add[1]>]Castle Guard" <[player].location> traits:sentinel save:new_guard
    - assignment set script:CastleGuard to:<entry[new_guard].created_npc>
    - define npc <entry[new_guard].created_npc>

    - adjust <[npc]> owner:<[player]>

    - flag <[npc]> targetInfo.whichAttack:<list[]>
    - flag <[npc]> targetInfo.whichWarn:<list[]>
    - flag <[npc]> targetInfo.reportInc:<list[]>

    ##ignore_warning bad_execute

    - execute as_server "sentinel addtarget event:pvp --id <[npc].id>" silent
    - execute as_server "sentinel addtarget event:pvsentinel --id <[npc].id>" silent
    - execute as_server "sentinel addtarget players --id <[npc].id>" silent
    - execute as_server "sentinel targettime 20 --id <[npc].id>" silent
    - execute as_server "sentinel speed 1.25 --id <[npc].id>" silent

    - execute as_server "sentinel addignore denizen_proc:GuardIgnoreFriendlies:<[npc]> --id <[npc].id>" silent
    - execute as_server "sentinel addtarget denizen_proc:GuardTargetSelection:<[npc]> --id <[npc].id>" silent

    - equip <[npc]> hand:stone_sword head:leather_cap chest:leather_chestplate legs:leather_leggings boots:leather_boots
    - execute as_server "sentinel squad <[player].flag[kingdom]>_castle_guards --id <[npc].id>" silent
    - execute as_server "sentinel guarddistance 40 --id <[npc].id>" silent
    - execute as_server "sentinel realistic true --id <[npc].id>" silent
    - execute as_server "sentinel range 50 --id <[npc].id>" silent
    - execute as_server "sentinel chaserange 70 --id <[npc].id>" silent

    - define kingdom <[player].flag[kingdom]>
    - flag <[npc]> kingdom:<[kingdom]>
    - flag <[npc]> GuardPos:<[player].location>
    - flag server kingdoms.<[kingdom]>.castleGuards:->:<[npc]>
    - flag server kingdoms.<[kingdom]>.castleGuards:<server.flag[kingdoms.<[kingdom]>.castleGuards].deduplicate>


GuardIgnoreFriendlies:
    type: procedure
    debug: false
    definitions: entity|context
    script:
    - ratelimit <queue> 1s

    - if <[entity].is_player>:
        - if <[entity].flag[kingdom].equals[<[context].flag[kingdom]>].if_null[false]>:
            - determine passively true
            - execute as_server "sentinel forgive --id <[context].id>" silent
            - stop

    - if <[entity].has_trait[sentinel]>:
        - if <[entity].flag[kingdom].equals[<[context].flag[kingdom]>].if_null[false]>:
            - determine passively true
            - execute as_server "sentinel forgive --id <[context].id>" silent
            - stop


GuardTargetSelection:
    type: procedure
    debug: false
    definitions: entity[EntityTag]|context[NPCTag]
    description:
    - Will return true if the provided entity is not in the same kingdom as the guard (provided as <[context]>), and the guard has orders to attack the entity.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Will return true if the provided entity is not in the same kingdom as the guard (provided as
    ## <[context]>), and the guard has orders to attack the entity.
    ##
    ## entity  : [EntityTag]
    ## context : [NPCTag]
    ##
    ## >>> [ElementTag<Boolean>]

    - ratelimit <queue> 1s
    - define guard <[context]>
    - define nearestPlayers <[guard].location.find_players_within[<[guard].sentinel.guard_distance_minimum>]>
    - define nearestPlayer <[nearestPlayers].get[1].if_null[null]>

    - if <[nearestPlayer]> == null:
        - determine passively false
        - execute as_server "sentinel forgive --id <[guard].id>" silent

    - if !<[nearestPlayer].has_flag[kingdom]>:
        - determine passively false
        - execute as_server "sentinel forgive --id <[guard].id>" silent

    - define targetKingdoms <[guard].flag[targetInfo.whichAttack]>
    - define warnKingdoms <[guard].flag[targetInfo.whichWarn]>
    - define reportInc <[guard].flag[targetInfo.reportInc]>

    - if <[nearestPlayer].is_op>:
        - determine false

    - if <[nearestPlayer].flag[kingdom]> == <[guard].flag[kingdom]>:
        - determine passively false
        - execute as_server "sentinel forgive --id <[guard].id>" silent

    - if <[nearestPlayer].flag[kingdom].is_in[<[warnKingdoms]>]>:
        #- chat talkers:<[guard]> targets:<[nearestPlayer]> "Hey! You there! This is restricted territory, you are prohibited from entering!"
        - determine passively false
        - execute as_server "sentinel forgive --id <[guard].id>" silent

    - if <[nearestPlayer].flag[kingdom].is_in[<[targetKingdoms].as[list]>]>:
        - determine true

    - else:
        - if <[guard].flag[kingdom]> != <[nearestPlayer].flag[kingdom]> && !<[nearestPlayer].is_op>:
            - definemap incReport:
                date: <util.time_now>
                player: <[nearestPlayer]>
                kingdom: <[nearestPlayer].flag[kingdom]>
                incNumber: 1

            - if <[nearestPlayer]> == <[guard].flag[incReports].last.get[player]> && <[guard].flag[incReports].last.get[date].from_now.in_seconds.is[OR_LESS].than[600]>:
                - flag <[guard]> incReports:<-:<[guard].flag[incReports].last>

            - define currIncNumber <[incReport].get[incNumber]>
            - flag <[guard]> incReports:->:<[incReport].exclude[incNumber].include[incNumber=<[currIncNumber].add[1]>]>

            - if <[guard].flag[incReports].size.is[MORE].than[45]>:
                - flag <[guard]> incReports:<[guard].flag[incReports].remove[1]>

        - determine passively false
        - execute as_server "sentinel forgive --id <[guard].id>" silent


#- This is less shit now but still kinda shit. I really don't know what else Denizen wants me to do
#- when there are not one but two mechanisms that *should* improve pathfinding accuracy that
#- actually do fuck all :\ (McMonkey, fix distance_margin and path_distance_margin, you fucker)
#-
#- ~Zyad 19/Aug/'25

StaggeredPathfind:
    type: task
    debug: false
    definitions: npc[NPCTag]|endLocation[LocationTag]|recursionDepth[?ElementTag(Integer)]|speed[?ElementTag(Integer)]
    description:
    - Will make the provided NPC walk to the provided endLocation in a series of 20 block intervals to avoid having Minecraft's default pathfinding teleport them to far away places.
    - ---
    - → [Void]

    script:
    ## Will make the provided NPC walk to the provided endLocation in a series of 20 block
    ## intervals to avoid having Minecraft's default pathfinding teleport them to far away places.
    ##
    ## npc            :  [NPCTag]
    ## endLocation    :  [LocationTag]
    ## speed          : ?[ElementTag<Integer>]
    ## recursionDepth : ?[ElementTag<Integer>]
    ##
    ## >>> [Void]

    - define recursionDepth <[recursionDepth].if_null[0]>
    - define speed <[speed].if_null[1]>
    - define shortPos false

    # I can only hope that the Denizen team will fix these one day, so I'll leave this here.
    - adjust <[npc]> distance_margin:0
    - adjust <[npc]> path_distance_margin:0

    - inject <script.name> path:PathfindLoop

    PathfindLoop:
    - define path <[npc].location.find_path[<[endLocation]>]>

    # At some point this check should no longer be necessary, but for now I need to trust this task
    # a whole lot more before that happens.
    - if <[recursionDepth].is[MORE].than[49]>:
        - teleport <[npc]> <[endLocation]>
        - narrate format:debug targets:<server.online_ops> "Recursion Depth Exceeded <[recursionDepth]> Steps! Killing Queue: <script.name>_<script.queues.get[1].numeric_id>"
        - determine cancelled

    - else:
        - define walkPos <[path].get[20].if_null[<[path].last>]>

        # This will intentionally send the NPC about two blocks behind the intended target so that
        # they can be later "pushed" forward the appropriate number of blocks to compensate for the
        # fact that Citizens NPCs always fall short of their intended target location when using
        # default pathfinding.
        - if <[npc].location.distance[<[endLocation]>].is[OR_LESS].than[20]>:
            - define walkPos <[endLocation].backward_flat[2]>
            - define shortPos true

        # Maybe if efficiency starts becoming a problem, push the rate up to 15t or even 1s.
        - waituntil !<[npc].is_navigating> rate:10t
        - ~walk <[npc]> <[walkPos]> speed:<[speed]>

        - if !<[shortPos]> && <[npc].location.distance[<[endLocation]>].is[MORE].than[2.5]>:
            - run StaggeredPathfind path:PathfindLoop def.npc:<[npc]> def.endLocation:<[endLocation]> def.recursionDepth:<[recursionDepth].add[1]> def.speed:<[speed]>

        # Take the NPC the last little bit (this is the "push" I referred to above) to the intended
        # target location and then correct their pitch and yaw to match the original endLocation
        # parameter.
        - else:
            - ~walk <[npc]> <[endLocation].forward_flat[1]>
            - teleport <[npc]> <[npc].location.with_yaw[<[endLocation].yaw>].with_pitch[<[endLocation].pitch>]>


GuardTickEvent_Handler:
    type: world
    events:
        on sentinel npc has no more targets:
        - if <npc.has_flag[GuardPos]>:
            - wait 1s
            - run StaggeredPathfind def.npc:<npc> def.endLocation:<npc.flag[GuardPos]> def.recustionDepth:0 def.speed:1