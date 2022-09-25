##ignorewarning invalid_data_line_quotes

DEBUG_ParliamentView_Window:
    type: inventory
    inventory: chest
    gui: true
    title: "Support in Parliament"
    slots:
    - [] [MPHostile_Item] [] [MPIndifferent_Item] [] [MPSupport_Item] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []

MPSupport_Item:
    type: item
    material: player_head
    display name: "<green><bold>Supportive MP"
    mechanisms:
        skull_skin: 81e9cb25-3fc3-4b41-8fa6-536bf143d560|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNDMxMmNhNDYzMmRlZjVmZmFmMmViMGQ5ZDdjYzdiNTVhNTBjNGUzOTIwZDkwMzcyYWFiMTQwNzgxZjVkZmJjNCJ9fX0=

MPIndifferent_Item:
    type: item
    material: player_head
    display name: "<gray><bold>Indifferent MP"
    mechanisms:
        skull_skin: 9028c375-0c55-440d-9707-80269f1fdaee|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZmQzY2ZjMjM5MDA2YjI1N2I4YjIwZjg1YTdiZjQyMDI2YzRhZGEwODRjMTQ0OGQwNGUwYzQwNmNlOGEyZWEzMSJ9fX0=

MPHostile_Item:
    type: item
    material: player_head
    display name: "<red><bold>Hostile MP"
    mechanisms:
        skull_skin: 63f4797a-496a-4368-9aba-0a2a8eca8ab2|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDdhY2ZmNThjMjExZTQ2ODA2ZDRhYzlhNzczMjBiZjU3MjUwZWQ4YmY3OTMzZWE0M2FjOGVmMmZkNzBkZWZkYyJ9fX0=

ElectionScheduler:
    type: task
    script:
    - yaml load:powerstruggle.yml id:ps

    - define nextElection <yaml[ps].read[global.nextelection]>
    - define timeNow <util.time_now>
    - define isAfterElection <[timeNow].is_after[<[nextElection]>]>

    - if <[isAfterElection]>:
        #- narrate format:debug isElection

        - define kingdomList <list[centran|viridian|raptoran|cambrian]>
        - define highestInfluence 0
        - define highestInfluenceKingdom none

        - foreach <[kingdomList]> as:kingdom:
            - define influence <yaml[ps].read[<[kingdom]>.electioninfluence]>

            - if <[influence].is[MORE].than[<[highestInfluence]>]>:
                - define highestInfluence <[influence]>
                - define highestInfluenceKingdom <[kingdom]>

        - define randomDayCount <util.random.int[21].to[42]>
        - define scheduledDate <util.time_now.add[<[randomDayCount]>d]>
        - yaml id:ps set global.nextelection:<[scheduledDate]>
        - yaml id:ps savefile:powerstruggle.yml

        - determine <[highestInfluenceKingdom]>|<[highestInfluence]>
        - yaml id:ps unload

    - yaml id:ps unload
    - determine null

VoteRigging_Handler:
    type: world
    events:
        on system time hourly every:24:
        - run ElectionScheduler save:elec
        - narrate <entry[elec].created_queue.determination.get[1]>

        on player clicks VoteRig_Influence in PopulationInfluence_Window:
        - inventory open d:VoteRigInfo_Window

        on player opens VoteRigInfo_Window:
        - yaml load:powerstruggle.yml id:ps
        - define nextElection <yaml[ps].read[global.nextelection]>

        - inventory d:<context.inventory> adjust slot:14 lore:<list[<[nextElection].from_now.formatted>]>

        - yaml id:ps unload