##ignorewarning invalid_data_line_quotes

FyndalinTreatyInformation:
    type: data
    treaties:
        1:
            name: "The Treaty of Viridia"
            date: "Feb 1648"
            desc:
            - "- Enforced Fyndalin's disarmament. Mandates no formal army"
            - "  units apart from police and militia."
            abiding: true

        2:
            name: "The Lake Marten Accords"
            date: "Mar 1648"
            desc:
            - "- Enforced the demilitarization of the Fyndalin peninsula"
            - "- Lays out the reparation terms imposed on Fyndalin."
            abiding: true

        3:
            name: "The Muspelheim/Oberplattstad Concensus"
            date: "Jun 1648 -> Jan 1649"
            desc:
            - "- A set of conferences, held at the Muspel capital, which"
            - "  decided the fate of the city of Fyndalin; how it would be"
            - "  reconstructed, who would be responsible for rebuilding"
            - "  each part of the city etc. It was this agreement that also"
            - "  prevented the city from containing any defensive works or"
            - "  non-wood buildings larger than 50x80 meters (with some "
            - "  exceptions."
            abiding: true

        4:
            name: "The St. Marcus Accords"
            date: "Oct 1655"
            desc:
            - "- Enforced the full subordination of Fyndalin to Muspelheim and"
            - "  formalized the Fyndalin protectorate."
            abiding: true

        5:
            name: "The Lake Avelli Agreement"
            date: "Apr 1690"
            desc:
            - "- Enforced the dissolution of the Fyndalin protectorate."
            - "- Formed the Mandated Republic of Fyndalin with Paulus."
            - "  Artursen as its first prime minister"
            - "- Formed the madate council with 3 permanent members:"
            - "    > Muspelheim"
            - "    > Viridia"
            - "    > Grovelia-Precipium"
            abiding: true

        6:
            name: "Lake Avelli (Revised)"
            date: "Jan 1691"
            desc:
            - "- Admitted the Republic of Altea as the fourth permanent"
            - "  member of the mandate council."
            abiding: true

FyndalinTreaties_Window:
    type: inventory
    inventory: chest
    gui: true
    title: "The Treaties of Fyndalin"
    procedural items:
    - determine <player.flag[TreatyItems]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []

TreatyWindow_Handler:
    type: world
    events:
        on player clicks FyndalinTreaties_Item in InfluenceWindow:
        - define treatyList <list[]>

        - foreach <script[FyndalinTreatyInformation].data_key[treaties]> as:treaty:
            - define treatyItem <item[paper]>
            - define treatyName <[treaty].get[name]>
            - define treatyDate <[treaty].get[date]>
            - define treatyDesc <[treaty].get[desc]>
            - define treatyAbiding <[treaty].get[abiding]>

            - adjust def:treatyItem display:<[treatyName].bold.color[white]>
            - adjust def:treatyItem "lore:<list[<white>Date: <[treatyDate]>| ]>"
            - adjust def:treatyItem "lore:<[treatyItem].lore.include[<[treatyDesc]>| ]>"

            - if !<[treatyAbiding]>:
                - adjust def:treatyItem "lore:<[treatyItem].lore.include[<red>Fyndalin has renouced this treaty!]>"

            - else:
                - adjust def:treatyItem "lore:<[treatyItem].lore.include[<aqua>Fyndalin still abides by this treaty.]>"

            - define treatyList:->:<[treatyItem]>

        - define formattedTreatyList <list[].pad_left[9].with[air]>
        - define count 0

        - foreach <[treatyList]>:
            - if <[count].mod[4]> == 0 && <[count]> != 0:
                - define formattedTreatyList:->:<item[air]>

                - if <[treatyList].size.sub[<[count]>].mod[4]> != 0:
                    - define formattedTreatyList:->:<item[air]>
                    - define formattedTreatyList:->:<item[air]>
                    - while next

            - define formattedTreatyList:->:<item[air]>
            - define formattedTreatyList:->:<[treatyList].get[<[loop_index]>]>

            - define count <[count].add[1]>

        - flag <player> TreatyItems:<[formattedTreatyList]>
        - inventory open d:FyndalinTreaties_Window
        - flag <player> TreatyItems:!
