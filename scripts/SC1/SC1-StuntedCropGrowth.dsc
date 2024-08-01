##
## [SCENARIO I]
## The scripts in the file are all part of the system that stunts crop growth in the Penaltea
## region. This mechanic forms the basis of the scarcity that drives tensions in this scenario.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jun 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

StuntedCropGrowth_Handler:
    type: world
    debug: false
    events:
        on block grows priority:-2:
        - if <server.has_flag[PreGameStart]>:
            - stop

        - define growChance <util.random_chance[35]>

        - if !<[growChance]>:
            - determine cancelled


# Yeah yeah I know this doesn't belong here. I wasn't about to make a file for this bitty litte
# script.

SC1_FlagCheck_Handler:
    type: world
    events:
        on player joins:
        - if !<player.flag[kingdom].is_in[jalerad|talpenhern]> && !<player.is_op>:
            - run AddMember def.kingdom:jalerad def.member:<player>
            - ~run SidebarLoader def.target:<player>

            - execute as_player "k warp"
            - inventory clear destination:<player.inventory>
