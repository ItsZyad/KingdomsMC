##
## [SCENARIO I]
## This file holds the main scripts and handlers relating to the alliance town influence mechanic.
## This mechanic allows kingdoms to utilize different strategies to curry favor with the alliance
## towns of Penaltea to undercut their opponents.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Aug 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

SC1_AllianceTownInfluence_Command:
    type: command
    name: influence
    usage: /influence
    description: Opens the interface responsible for handling the alliance town influence mechanic.
    script:
    - if <player.has_flag[kingdom]>:
        - inventory open d:SC1_AllianceTownInfluence_Interface


SC1_AllianceTownNames:
    type: data
    Names:
        Alliance-Town-1: Rumek
        Alliance-Town-2: Kandon
        Alliance-Town-3: Rugoss
        Alliance-Town-4: Bremlek


SC1_AllianceTownInfluence_Interface:
    type: inventory
    inventory: chest
    gui: true
    title: Influence the Alliance Towns
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [SC1_ATKandon_Item] [] [SC1_ATRumek_Item] [] [SC1_ATBremlek_Item] [] [SC1_ATRugoss] []
    - [] [] [] [] [] [] [] [] []


SC1_ATKandon_Item:
    type: item
    material: player_head
    display name: <element[AT Kandon].color[<proc[GetColor].context[Default.orange]>].bold>
    mechanisms:
        skull_skin: 4137dac2-f4a7-4540-a5a0-1c38d748821f|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvMTllMzE2YmE0OGU1MWM2ZWI3M2NiMDY4YTJkNDY4ZjY3OGVlZDgyZDQ1MjlkNGIxMmVlYzhiZmE3ODE5YWE4NiJ9fX0=
    flags:
        marketName: Alliance-Town-2


SC1_ATRumek_Item:
    type: item
    material: player_head
    display name: <element[AT Rumek].color[<proc[GetColor].context[Vintage.brown].as[color].mix[<proc[GetColor].context[Vintage.white]>]>].bold>
    mechanisms:
        skull_skin: 32ffb21f-8d2f-46c2-95d2-11637c8a540e|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOTdmODJhY2ViOThmZTA2OWU4YzE2NmNlZDAwMjQyYTc2NjYwYmJlMDcwOTFjOTJjZGRlNTRjNmVkMTBkY2ZmOSJ9fX0=
    flags:
        marketName: Alliance-Town-1


SC1_ATBremlek_Item:
    type: item
    material: player_head
    display name: <element[AT Bremlek].color[<proc[GetColor].context[Vintage.white]>].bold>
    mechanisms:
        skull_skin: dcc60076-78f3-4ca2-ba1a-b70c072569e6|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZTE5OTk3NTkzZjJjNTkyYjlmYmQ0ZjE1ZWFkMTY3M2I3NmY1MTlkN2FiM2VmYTE1ZWRkMTk0NDhkMWEyMGJmYyJ9fX0=
    flags:
        marketName: Alliance-Town-4


SC1_ATRugoss:
    type: item
    material: player_head
    display name: <element[AT Rugoss].color[<proc[GetColor].context[Vintage.brown]>].bold>
    mechanisms:
        skull_skin: 31d03c73-e2ef-4872-9fbe-c68ac43ccb94|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNDQxMjE1ZDEwNmNkNWFkZWRhZTcxNzM2NGY2NDNjNjE5YTBjODgyNmYyYzZhYzRlOTdlZThjOTQ0NTQwYjkwZSJ9fX0=
    flags:
        marketName: Alliance-Town-3


SC1_AllianceTownInfluenceActions_Interface:
    type: inventory
    inventory: chest
    gui: true
    title: Select Influence Action
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [SC1_BribeInfluence_Item] [] [SC1_PromiseTrade_Item] [] [SC1_AssistDefense_Item] [] []
    - [] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []


SC1_BribeInfluence_Item:
    type: item
    material: gold_ingot
    display name: <element[Bribe Alliance].color[<proc[GetColor].context[Vintage.gold]>].bold>
    lore:
    - <element[Defensive Action].color[white].bold.italicize>
    - <&r>Bribe the alliance in charge of this town to give
    - <&r>you greater influence over it. The money you give
    - <&r>returns to its merchants allowing them to buy and
    - <&r>sell more goods.


SC1_PromiseTrade_Item:
    type: item
    material: paper
    display name: <element[Promise Trade].color[<proc[GetColor].context[Vintage.white]>].bold>
    lore:
    - <element[Defensive Action].color[white].bold.italicize>
    - <&r>You can promise the alliance in charge of this
    - <&r>town a certain value worth of trade that you
    - <&r>will conduct with it within a timeframe you decide
    - <&r>on. If you meet the trade quota, your kingdom will
    - <&r>gain influence.
    - <red>Warning: Should you fail to fullfill your kingdom's
    - <red>promise, you will lose the same amount of influence.


SC1_AssistDefense_Item:
    type: item
    material: shield
    display name: <element[Assist Defense].color[<proc[GetColor].context[Default.brown]>].bold>
    lore:
    - <element[Defensive Action].color[white].bold.italicize>
    - <&r>Trade a number of requested weapons in exchange
    - <&r>for an influence boost with this alliance. The
    - <&r>alliance will determine a number of required
    - <&r>weapons each (in game) week.


SC1_InfluenceVisualizer:
    type: procedure
    definitions: marketName[ElementTag(String)]
    debug: false
    script:
    - define kingdom <player.flag[kingdom]>
    - define influencePercentage <server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.influence.markets.<[marketName]>].if_null[0].mul[100]>
    - define influenceGraphic <list>

    - repeat <[influencePercentage].div[5]>:
        - define influenceGraphic:->:█

    - repeat <element[20].sub[<[influencePercentage].div[5]>]>:
        - define influenceGraphic:->:░

    - define influenceGraphic:->:<&sp>-<&sp>
    - define influenceGraphic:->:<[influencePercentage].round_to_precision[0.01]><element[%].escaped>
    - determine <[influenceGraphic].unseparated>


SC1_AllianceTownInfluence_Handler:
    type: world
    events:
        on player opens SC1_AllianceTownInfluence_Interface:
        - define kingdom <player.flag[kingdom]>

        - foreach <context.inventory.list_contents> as:item:
            - if <[item].material.name> == air:
                - foreach next

            - define marketName <[item].flag[marketName]>
            - define influenceGraphic <[marketName].proc[SC1_InfluenceVisualizer]>

            - inventory adjust slot:<[loop_index]> lore:<element[Influence:<n>].color[white]><[influenceGraphic]> d:<context.inventory>

        on player clicks item in SC1_AllianceTownInfluence_Interface:
        - if <context.slot> == -998:
            - determine cancelled

        - if <context.item.material.name> == air:
            - determine cancelled

        - if <context.inventory> != <context.clicked_inventory>:
            - determine cancelled

        - flag <player> datahold.scenario-1.influence.marketName:<context.item.flag[marketName]>

        - inventory open d:SC1_AllianceTownInfluenceActions_Interface
