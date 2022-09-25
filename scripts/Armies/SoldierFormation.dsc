########################
## THIS FILE IS INDEV ##
########################

## VERSION NUMBERS / GENERAL METADATA DO NOT EXIST FOR INDEV MODULES!

# TODO: Add if case in caller function which throws an error to the player if the squad isn't assigned a leader yet
# Also TODO: Compensate for Denizen's shitty definition handling

# Command for test function:
# /ex run FormationWalk def:<util.parse_yaml[<yaml[squads].read[<player.flag[kingdom]>.newsquad.npclist]>]>

FormationWalk:
    type: task
    definitions: npcList_mapped
    script:
    - define squadLeader <npc[865]>

    - define npcList <[npcList_mapped].get[null]>
    - define NPCsPerRow <[npcList].size.div[2].round>

    # How far to the squad leader's left the script should start placing NPCs
    #- if <[NPCsPerRow].mod[2]> == 0:
    #    - define jumpsLeft <[NPCsPerRow].sub[2]>
    #- else:
    - define jumpsLeft <[NPCsPerRow].sub[1.5]>

    - define squadLeadBehind <[squadLeader].location.backward_flat[1].right[<[jumpsLeft]>]>

    - narrate format:debug <[npcList]>

    - foreach <[npclist].exclude[<[squadLeader]>]>:
        - narrate format:debug "Loop Index: <[loop_index]>"

        - if <[loop_index].sub[1].mod[<[NPCsPerRow]>]> == 0:
            - define squadLeadBehind <[squadLeadBehind].backward_flat[1].right[<[jumpsLeft]>]>

        - narrate format:debug <[squadLeadBehind].simple>
        - walk <[value]> <[squadLeadBehind]>

        - define squadLeadBehind <[squadLeadBehind].left[2]>

    # TEST CODE: Follow the Leader #

    - foreach <[npclist]>:
        - walk <[value]> <[value].location.forward_flat[14]> auto_range

# Have a menu that allows you to enter garrison definition mode which first
# clears all other fake blocks before letting you start.

# It will then give the player a garrison definition flag and keep the fake
# blocks until that flag is removed/player exits garrison mode.

DEBUG_RefreshGarrisonArea:
    type: task
    definitions: target
    script:
    - define fakeBlockList <[target].flag[definingGarrison]>

    - if <[target].has_flag[definingGarrison]>:
        - foreach <[fakeBlockList]>:
            - showfake players:<server.online_players> red_stained_glass <[value]> d:100s
            #- flag <[target]> definingGarrison:!

DEBUG_GarrisonBrush_ITEM:
    type: item
    material: spectral_arrow
    display name: "<light_purple><bold>Garrison Brush"

DEBUG_GarrisonBrush_HANDLER:
    type: world
    events:
        on player left clicks block with:DEBUG_GarrisonBrush_ITEM:
        - flag <player> definingGarrison:!
        - showfake cancel target:<server.online_players> <player.fake_block_locations>

        on player right clicks block with:DEBUG_GarrisonBrush_ITEM:
        - ratelimit <player> 1t

        - define posRelative <list[-2|-1|0|1|2]>
        - define elevatedBy 1

        - if <player.cursor_on[100].material.name> == grass:
            - define elevatedBy 0

        - else if <player.cursor_on[100].material> == <material[tall_grass[half=BOTTOM]]>:
            - define elevatedBy 0

        - else if <player.cursor_on[100].material> == <material[tall_grass[half=TOP]]>:
            - define elevatedBy -1

        - foreach <[posRelative]> as:leftRight:
            #- if !<player.fake_block_locations.contains[<player.cursor_on[100].above[<[elevatedBy]>].left[<[leftRight]>]>]>:

            - foreach <[posRelative]> as:upDown:
                #- if !<player.fake_block_locations.contains[<player.cursor_on[100].above[<[elevatedBy]>].left[<[leftRight]>].backward[<[upDown]>]>]>:

                - define fakeBlockloc <player.cursor_on[100].above[<[elevatedBy]>].left[<[leftRight]>].backward[<[upDown]>]>

                - showfake players:<server.online_players> red_stained_glass <[fakeBlockLoc]> d:100
                - flag <player> definingGarrison:->:<[fakeBlockLoc]>

            #- narrate targets:<player[ZyadTheBoss]> <player.flag[definingGarrison].size>

        - runlater DEBUG_RefreshGarrisonArea def.target:<player> def.fakeBlockList:<player.flag[definingGarrison]> delay:99s