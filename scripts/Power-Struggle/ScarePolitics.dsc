##ignorewarning invalid_data_line_quotes

SmallInitimidation_Influence:
    type: item
    material: wooden_sword
    display name: "Small Initimidation Campaign"
    flags:
        campaignMod: 25
        time: 4

MediumInitimidation_Influence:
    type: item
    material: stone_sword
    display name: "Medium Initimidation Campaign"
    flags:
        campaignMod: 35
        time: 7

LargeInitimidation_Influence:
    type: item
    material: iron_sword
    display name: "Large Initimidation Campaign"
    flags:
        campaignMod: 50
        time: 12

Intimidation_Window:
    type: inventory
    inventory: chest
    gui: true
    title: "Size of Alignment Campaign"
    slots:
    - [] [SmallInitimidation_Influence] [] [] [MediumInitimidation_Influence] [] [] [LargeInitimidation_Influence] []

IntimidationHanderScript:
    type: task
    definitions: campaignModifier|changeYml
    script:
    - define kingdom <player.flag[kingdom]>
    - define kingdomList <list[cambrian|viridian|raptoran|centran].exclude[<[kingdom]>]>
    - define randomVal <util.random.int[1].to[<[kingdomList].size>]>
    - define randomKingdom <[kingdomList].get[<[randomVal]>]>

    - yaml load:kingdoms.yml id:kingdoms
    - define prestigeMultiplier <yaml[kingdoms].read[<[kingdom]>.prestige].div[100]>
    - define influenceModifier <element[100].sub[<[campaignModifier]>]>

    # x = ln(qy + 0.159) + 1.83885
    # where: q: {25,35,50}
    #          0 < y < 1
    - define influenceAmount <element[<[prestigeMultiplier].div[<[influenceModifier]>].add[0.159]>].ln.add[1.83885]>

    # x = -(y / 32) + (1 / 32) - 0.02
    # where: 0 < y < 1
    - define kingdomInfluenceHit <element[<[prestigeMultiplier].div[32]>].mul[-1].add[<element[1].div[32]>].sub[0.02]>

    - if <[changeYml]>:
        # randomizes the influence amount to a value between
        # originalinfluence / 2 --> (originalinfluence / 2) + originalinfluence
        - define influenceRandomized <util.random.decimal[<[influenceAmount].div[2]>].to[<[influenceAmount].add[<[influenceAmount].div[2]>]>]>

        # randomizes the influence hit amount to a value between
        # originalinfluencehit / 2 --> (originalinfluencehit / 2) + originalinfluencehit
        - define influenceHitRandomized <util.random.decimal[<[kingdomInfluenceHit].div[2]>].to[<[kingdomInfluenceHit].add[<[kingdomInfluenceHit].div[2]>]>]>

        - if <yaml[kingdoms].read[<[kingdom]>.balance].is[OR_MORE].than[<[campaignModifier].mul[500]>]>:
            - yaml id:kingdoms <[kingdom]>.balance:-:<[campaignModifier].mul[500]>
            - yaml id:kingdoms savefile:kingdoms.yml

            - yaml load:powerstruggle.yml id:ps
            - yaml id:ps set <[randomKingdom]>.fyndalingovt:-:<[influenceRandomized]>
            - yaml id:ps set <[kingdom]>.fyndalingovt:-:<[influenceHitRandomized]>
            - yaml id:ps savefile:powerstruggle.yml
            - yaml id:ps unload

        - else:
            - inventory close
            - narrate format:callout "Your kingdom does not have sufficient funds to carry out this influence action"

    - else:
        - determine <list[<[influenceAmount]>].include[<[kingdomInfluenceHit]>]>

    - yaml id:kingdoms unload

IntimidationInfluence_Handler:
    type: world
    events:
        on player clicks InitimidatePolitics_Influence in GovernmentInfluence_Window:
        - inventory open d:Intimidation_Window

        on player opens Intimidation_Window:
        - foreach <context.inventory.list_contents>:
            - if <[value].material.name> != air:
                - define campaignMod <[value].flag[campaignMod]>
                - define timePeriod <[value].flag[time]>

                - run IntimidationHanderScript def:<[campaignMod]>|false save:inf

                - define influenceAmounts <entry[inf].created_queue.determination.get[1]>
                - define influencePercentages <[influenceAmounts].parse[round_to_precision[0.001].mul[100]]>

                - inventory adjust slot:<[loop_index]> "lore:|<white>Cost<&co> <element[$<proc[CommaAdder].context[<[campaignMod].mul[500]>]>].color[red].bold>|<white>Estimated Impact on Rival Kingdom<&co> <element[-<[influencePercentages].get[1]><&pc>].color[red].bold>|<white>Estimated Impact on us<&co> <element[-<[influencePercentages].get[2]><&pc>].color[red].bold>|<white>Time Period: <element[<[timePeriod]> days].color[red].bold>" d:<context.inventory>

        on player clicks item in Intimidation_Window:
        #- narrate format:debug <context.item.script.name>

        - define kingdom <player.flag[kingdom]>

        - yaml load:powerstruggle.yml id:ps

        - if <yaml[ps].read[<[kingdom]>.dailyinfluences]> <= 0:
            - narrate format:callout "Your kingdom has exhasuted its influence points today"
            - determine cancelled

        - if <context.item.material.name> != air:
            - if <server.flag[kingdom.influence.noIntimidationUse].exists>:
                - inventory close
                - narrate format:callout "You cannot use this influence action while your kingdom is already undertaking an intimidation campaign. Wait for another <server.flag_expiration[<[kingdom]>.influence.noIntimidationUse].from_now.formatted.color[red].bold> before using."

            - else:
                - choose <context.item.script.name>:

                    - case SmallInitimidation_Influence:
                        - runlater delay:4d IntimidationHanderScript def:25|true
                        - flag server <[kingdom]>.influence.noIntimidationUse expire:4d

                    - case MediumInitimidation_Influence:
                        - runlater delay:7d IntimidationHanderScript def:35|true
                        - flag server <[kingdom]>.influence.noIntimidationUse expire:7d

                    - case LargeInitimidation_Influence:
                        - runlater delay:12d IntimidationHanderScript def:50|true
                        - flag server <[kingdom]>.influence.noIntimidationUse expire:12d

                - yaml id:ps set <[kingdom]>.dailyinfluences:--
                - yaml id:ps savefile:powerstruggle.yml

                - run SidebarLoader def.target:<server.flag[<[kingdom]>].get[members].include[<server.online_ops>]>

                - narrate format:callout "The <script[KingdomRealNames].data_key[<player.flag[kingdom]>]> has dispatched agents to secure the support of key MPs in the Fyndalin parliament."

        - yaml id:ps unload
