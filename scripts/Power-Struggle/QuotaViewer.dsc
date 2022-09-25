##ignorewarning def_of_nothing

QuotaViewer:
    type: command
    name: quotas
    usage: /quotas
    description: Shows all the active black market trade quotas for your kingdom
    permission: kingdom.quotas
    script:
    - define kingdom <player.flag[kingdom]>
    - define syndicates <light_purple>
    - define orama <red>
    - define blackstone <gray>
    - define totalist <white>
    - define quotaData <server.flag[promisedTrade<[kingdom]>]>

    - if <[quotaData].get[1].exists>:
        - narrate format:debug <[quotaData].get[1]>

        - narrate "<&n>                                       <&n.end_format>"
        - narrate <&sp>

        - foreach <[quotaData]>:

            - yaml load:blackmarket-formatted.yml id:bmf
            - define faction <yaml[bmf].read[factiondata.<[value].get[2]>.name]>
            - yaml id:bmf unload

            - define volume <[value].get[1]>
            - define originalVolume <[value].get[3]>

            - narrate "Open commitment with <[<[value].get[2]>]><[faction]><&r>, with a remaining promised trade volume of <blue>$<[volume]>"
            - narrate "<&n>                                       <&n.end_format>"
            - narrate <&sp>

    - else:
        - narrate format:callout "Your kingdom has no active trade commitments with the black market factions."