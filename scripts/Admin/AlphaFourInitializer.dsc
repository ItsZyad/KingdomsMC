######### TEMP FILE
######### Please delete after Alpha 4 data schemes updated!
##ignorewarning invalid_data_line_quotes

GameStateAdjuster:
    type: task
    script:
    - run DEBUG_GenerateKingdomFlags
    - run RNPCFlagGenerator

    ## Delete obsolete flags
    - flag server centran:!
    - flag server cambrian:!
    - flag server viridian:!
    - flag server raptoran:!
    - flag server Debug_testKingdom:!
    - flag server IGMonth:!
    - flag server IGWeek:!
    - flag server IGYear:!
    - flag server originalQuotaAmount:!
    - flag server squad1:!
    - flag server weekcounter:!
    - flag server npcID:!
    - flag server RNPCs:!


DEBUG_GenerateKingdomFlags:
    type: task
    script:
    - define kingdomNames <list[centran|cambrian|viridian|raptoran|fyndalin]>

    - yaml load:kingdoms.yml id:kingdoms
    - yaml load:powerstruggle.yml id:ps
    - yaml load:blackmarket-formatted.yml id:bmf

    - foreach <[kingdomNames]> as:kingdom:
        - define oldKingdomFlag <server.flag[<[kingdom]>]>

        - flag server kingdoms.<[kingdom]>.members:<[oldKingdomFlag].get[members]>
        - flag server kingdoms.<[kingdom]>.openWarp:<[oldKingdomFlag].get[openWarp]> if:<[oldKingdomFlag].get[openWarp].exists>
        - flag server kingdoms.<[kingdom]>.loans:<[oldKingdomFlag].get[loans]> if:<[oldKingdomFlag].get[loans].exists>
        - flag server kingdoms.<[kingdom]>.powerstruggle:<[oldKingdomFlag].get[powerstruggle]> if:<[oldKingdomFlag].get[powerstruggle].exists>

        - define YKI <yaml[kingdoms].read[<[kingdom]>]>
        - define YPI <yaml[ps].read[<[kingdom]>]>
        - define YBI <yaml[bmf].read[factiondata.opinions.<[kingdom]>]>

        - flag server kingdoms.<[kingdom]>.balance:<[YKI].get[balance]>
        - flag server kingdoms.<[kingdom]>.warps:<[YKI].get[warp_location]>
        - flag server kingdoms.<[kingdom]>.description:<[YKI].get[description]>
        - flag server kingdoms.<[kingdom]>.prestige:<[YKI].get[prestige]>
        - flag server kingdoms.<[kingdom]>.upkeep:<[YKI].get[upkeep]>
        - flag server kingdoms.<[kingdom]>.warStatus:<[YKI].get[war_status]>
        - flag server kingdoms.<[kingdom]>.claims.core:<[YKI].get[core_claims]>
        - flag server kingdoms.<[kingdom]>.claims.castle:<[YKI].get[castle_territory]>
        - flag server kingdoms.<[kingdom]>.claims.coreMax:<[YKI].get[core_max]>
        - flag server kingdoms.<[kingdom]>.claims.castleMax:<[YKI].get[castle_max]>
        - flag server kingdoms.<[kingdom]>.npcTotal:<[YKI].deep_get[npcs.npc_total]>
        - flag server kingdoms.<[kingdom]>.outposts.costMultiplier:<[YKI].deep_get[outposts.outpost_cost]>
        - flag server kingdoms.<[kingdom]>.outposts.upkeepMultiplier:<[YKI].deep_get[outposts.outpost_upkeep]>
        - flag server kingdoms.<[kingdom]>.outposts.maxSize:<[YKI].deep_get[outposts.max_size]>
        - flag server kingdoms.<[kingdom]>.outposts.totalUpkeep:0

        - flag server kingdoms.<[kingdom]>.powerstruggle.cityPopulation:<[YPI].get[citypopulation]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.influencePoints:<[YPI].get[dailyinfluences]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.fyndalinGovt:<[YPI].get[fyndalingovt]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.maxPlotSize:<[YPI].get[maxplotsize]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.totalInfluence:<[YPI].get[totalinfluence]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.mercenaryGuild:<[YPI].get[mercenaryguild]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.masonsGuild:<[YPI].get[masonsguild]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.prestigeMultiplier:<[YPI].get[perstigemultiplier]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.electionInfluence:<[YPI].get[electioninfluence]>
        - flag server kingdoms.<[kingdom]>.powerstruggle.BMFactionInfluence:<[YBI]> if:<[YBI].exists>

        - flag server kingdoms.<[kingdom]>.armies.maximumAllowedSMs:4

    - flag server kingdoms.claimInfo.allClaims:<yaml[kingdoms].read[all_claims]>

    - yaml id:kingdoms unload
    - yaml id:ps unload


RNPCFlagGenerator:
    type: task
    script:
    - definemap RNPCNameEquivalents:
        mine: Miners
        farm: Farmers
        ranch: Loggers

    - foreach <util.notes[cuboids]> as:note:
        - define areaType <[note].split[_].get[2].to_lowercase>
        - define NPCType <[RNPCNameEquivalents].get[<[areaType]>]>

        - if <[NPCType].exists>:
            - define kingdom <[note].split[_].get[3]>
            - define NPCID <[note].split[_].get[4]>
            - define bothExist <[kingdom].exists.and[<[NPCID].exists>]>

            - if <[bothExist]>:
                - flag server kingdoms.<[kingdom]>.RNPCs.<[NPCType]>.<[NPCID]>.NPC:<npc[<[NPCID]>]>
                - flag server kingdoms.<[kingdom]>.RNPCs.<[NPCType]>.<[NPCID]>.area:<[note]>
