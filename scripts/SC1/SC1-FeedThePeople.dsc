##
## [SCENARIO I]
## The scripts in this file handle the food mechanic which will be central to the progression of
## the story (and possible diplomatic events) during scenario 1.
##
## Each kingdom will have food reserves that feed the common people. If food reserves drop too low
## for more than 3 days, the people will revolt and end the game for the kingdom.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jun 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

SC1_PopulationData:
    type: data
    Jalerad:
        population: 67000
        basePopGrowth: 0.45

        # Each unit of food reserves equates to half a vanilla minecraft hunger point. So for
        # example, if I were to add one piece of bread to the national reserve that would add 5
        # food points.
        #
        # food point consumption is calculated at the end of each in-game day. All citizens have
        # the same flat food consumption rate. But those in the army will have the food consumption
        # calculated at 1.25 times the consumption of a citizen.
        baseFoodReserves: 50000

    Talpenhern:
        population: 51000
        basePopGrowth: 0.61
        baseFoodReserves: 27000


SC1_EndConditionMessage:
    type: task
    definitions: playerList[ListTag(PlayerTag)]|loseCause[ElementTag(String)]
    description:
    - Will send out a message to the players provided that their kingdom has lost the game for the reason provided under 'loseCause'.
    - ---
    - → [Void]

    script:
    - define kingdom <[playerList].get[1].flag[kingdom]>

    - if <[loseCause]> == food:
        - foreach <[playerList]> as:player:
            - narrate <n> targets:<[player]>
            - narrate <n> targets:<[player]>
            - narrate <element[After 3 long months of starvation and famine, the peasants in your kingdom decided enough was enough and initiated a revolt against you and government.]> targets:<[player]>
            - narrate <element[Owing to your failure - as the ruling class - to provide a sufficiently stable food supply, the revolters decided to banish you to the wilderness after storming your palace.]> targets:<[player]>
            - narrate <n> targets:<[player]>
            - narrate <element[GAME OVER.].bold.color[red]> targets:<[player]>
            - narrate <n> targets:<[player]>
            - narrate <n> targets:<[player]>

    - if <server.has_flag[kingdoms.gameWinner]>:
        - foreach <server.flag[kingdoms.gameWinner].proc[GetMembers]> as:player:
            - narrate <n> targets:<[player]>
            - narrate <n> targets:<[player]>
            - narrate <element[After many trials and tribulations, your kingdom has emerged as the clear victor in the struggle for supremacy between the kingdoms and states of the region.]> targets:<[player]>
            - narrate <element[While the future is unlikely to be free of hardships and challenges. You and your people have proven your resilience, hardiness, and tough spirit.]> targets:<[player]>
            - narrate <n> targets:<[player]>
            - narrate <element[YOU WIN.].bold.color[green]> targets:<[player]>
            - narrate <n> targets:<[player]>
            - narrate <n> targets:<[player]>


SC1_Food_Handler:
    type: world
    enabled: false
    events:
        after time 23:
        - define worldDay <context.world.time.full.in_days.round>

        - foreach <proc[GetKingdomList]> as:kingdom:
            - if <server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.starvingMonths]> > 3:
                - flag server PauseUpkeep
                - gamerule <context.world> doDaylightCycle false
                - gamerule <context.world> doFireTick false
                - gamerule <context.world> doWeatherCycle false

                - flag server kingdoms.gameLosers:->:<[kingdom]>

                - if <proc[GetKingdomList].exclude[<server.flag[kingdoms.gameLosers]>].size> == 1:
                    - flag server kingdoms.gameWinner:<proc[GetKingdomList].exclude[<server.flag[kingdoms.gameLosers]>].get[1]>

                - run AffectOfflinePlayers def.playerList:<[kingdom].proc[GetMembers]> def.scriptName:SC1_EndConditionMessage def.otherDefs:<map[loseCause=food]>

        - if <[worldDay].mod[30]> == 0:
            - run SC1_PopulationGrowthTick
            - run SC1_FoodTick

        on player joins priority:2:
        - define kingdom <player.flag[kingdom]>

        - if !<[kingdom].is_in[<server.flag[datahold.scenario-1.playersNotSeenFoodMsg].keys.if_null[<list[]>]>]>:
            - stop

        - if !<player.is_in[<server.flag[datahold.scenario-1.playersNotSeenFoodMsg.<[kingdom]>].if_null[<list[]>]>]>:
            - stop

        - narrate format:callout targets:<player> "Your kingdom was unable to fully satisfy its citizens food demand this month, while you were offline. This is month #<server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.starvingMonths].if_null[0]> of your deficit. If your kingdom goes 3 months with an active food deficit, your people will revolt and attempt to overthrow you!"
        - flag server datahold.scenario-1.playersNotSeenFoodMsg.<[kingdom]>:<-:<player>

        - if <server.flag[datahold.scenario-1.playersNotSeenFoodMsg.<[kingdom]>].is_empty>:
            - flag server datahold.scenario-1.playersNotSeenFoodMsg.<[kingdom]>:!


SC1_Food_Command:
    type: command
    name: food
    usage: /food
    description: Brings up the food management menu for your kingdom
    script:
    - if !<player.has_flag[kingdom]>:
        - stop

    - inventory open d:SC1_FoodManager_Window


SC1_PopulationGrowthTick:
    type: task
    script:
    - define daysPassed <context.world.time.full.in_days.round>

    - if <[daysPassed].mod[30]> == 0:
        - foreach <proc[GetKingdomList]> as:kingdom:
            - define population <[kingdom].proc[GetKingdomPopulation]>
            - define popGrowth <[kingdom].proc[GetKingdomPopGrowth]>

            - if !(<[popGrowth].is_truthy> && <[population].is_truthy>):
                - foreach next

            - run AddKingdomPopulation def.kingdom:<[kingdom]> def.amount:<[population].mul[<[popGrowth]>]>


SC1_FoodTick:
    type: task
    definitions: world[WorldTag]
    script:
    - if <server.has_flag[PreGameStart]>:
        - stop

    - foreach <proc[GetKingdomList]> as:kingdom:
        - define foodConsumption <[kingdom].proc[SC1_FoodFullfillmentGetter]>
        - define currFood <[kingdom].proc[GetKingdomFoodReserves]>

        - run SetKingdomFoodReserves def.kingdom:<[kingdom]> def.amount:<[currFood].sub[<[foodConsumption]>]>
        - define currFood <[kingdom].proc[GetKingdomFoodReserves]>

        - if <[currFood]> < 0:
            - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.starvingMonths:++
            - narrate format:callout targets:<[kingdom].proc[GetMembers]> "Your kingdom was unable to fully satisfy its citizens food demand this month. This is month #<server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.starvingMonths].if_null[0]> of your deficit. If your kingdom goes 3 months with an active food deficit, your people will revolt and attempt to overthrow you!"

            - define offlineMembers <[kingdom].proc[GetMembers].exclude[<server.online_players>]>
            - flag server datahold.scenario-1.playersNotSeenFoodMsg.<[kingdom]>:<[offlineMembers]> if:<[offlineMembers].is_empty.not>


SC1_NextFoodTickCalculator:
    type: procedure
    definitions: world[WorldTag]
    script:
    - define daysPassed <[world].time.full.in_days.round>
    - define tickProgress <[daysPassed].mod[30].div[30].mul[100].round>
    - define tickGraphic <list[]>

    - repeat <[tickProgress].div[5]>:
        - define tickGraphic:->:█

    - repeat <element[20].sub[<[tickProgress].div[5]>]>:
        - define tickGraphic:->:░

    - define tickGraphic:->:<&sp>-<&sp>
    - define tickGraphic:->:<[tickProgress].round_to_precision[0.01]><element[%].escaped>
    - determine <[tickGraphic].unseparated>


SC1_FoodFullfillmentGetter:
    type: procedure
    definitions: kingdom[ElementTag(String)]
    script:
    - define foodReserves <[kingdom].proc[GetKingdomFoodReserves]>
    - define population <[kingdom].proc[GetKingdomPopulation]>
    - define SMCount <[kingdom].proc[GetKingdomSquadManagers].size>
    - define allSquads <[kingdom].proc[GetKingdomSquads]>
    - define civilianPopulation <[population]>

    # Military food consumption.
    - if <[SMCount]> > 0:
        - define civilianPopulation:-:<[SMCount].mul[100]>

        - foreach <[allSquads]>:
            - define squadName <[value].get[name]>
            - define manpower <proc[GetSquadManpower].context[<[kingdom]>|<[squadName]>]>
            - define civilianPopulation:-:<[manpower]>

    # Civilian food consumption.
    - define foodConsumption <[civilianPopulation].mul[5].mul[<util.random.decimal[0.94].to[1.06]>]>
    - define foodConsumption <[foodConsumption].add[<[population].sub[<[civilianPopulation]>].mul[7]>]>

    - determine <[foodConsumption]>


SC1_FoodManagerInfo_Item:
    type: item
    material: player_head
    display name: <yellow><bold>Food Information
    mechanisms:
        skull_skin: da4d885d-2505-4f25-bfee-a0de07950191|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDAxYWZlOTczYzU0ODJmZGM3MWU2YWExMDY5ODgzM2M3OWM0MzdmMjEzMDhlYTlhMWEwOTU3NDZlYzI3NGEwZiJ9fX0=


SC1_FoodManagerActions_Item:
    type: item
    material: player_head
    display name: <yellow><bold>Food Actions
    mechanisms:
        skull_skin: 30939add-08ae-41b5-802f-d55a546c9a06|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvN2FhNTk2NmExNDcyNDQ1MDRjYzU2ZWY2ZWZkMmQyZjQ0NzM4YjhmMDNkOTNhNjE3NjZhZjNmYzQ0ODdmOTgwYiJ9fX0=


SC1_NextFoodTick_Item:
    type: item
    material: clock
    display name: <red><bold>Next Food Tick


SC1_FoodReserves_Item:
    type: item
    material: chest
    display name: <gold><bold>Food Fullfillment


SC1_CurrentPopulation_Item:
    type: item
    material: player_head
    display name: <aqua><bold>Current Population


SC1_AddFood_Item:
    type: item
    material: wheat
    display name: <green><bold>Add Food To Reserves


SC1_FoodManager_Window:
    type: inventory
    inventory: chest
    gui: true
    title: Food Manager
    slots:
    - [InterfaceFiller_Item] [SC1_FoodManagerInfo_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item]
    - [] [SC1_NextFoodTick_Item] [] [SC1_FoodReserves_Item] [] [SC1_CurrentPopulation_Item] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [InterfaceFiller_Item] [SC1_FoodManagerActions_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item]
    - [] [SC1_AddFood_Item] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []


SC1_CalculateFoodPoints:
    type: procedure
    debug: false
    definitions: contents[ListTag(ItemTag)]
    script:
    - define totalPoints 0

    - foreach <[contents]> as:item:
        - if <[item].has_inventory>:
            - define totalPoints:+:<[item].inventory_contents.proc[SC1_CalculateFoodPoints]>

        - if <[item].material.food_points.exists>:
            - define totalPoints:+:<[item].material.food_points.mul[<[item].quantity>]>

    - determine <[totalPoints]>


SC1_IngestFoodItems:
    type: task
    definitions: inventory[InventoryTag]
    script:
    - foreach <[inventory].list_contents> as:item:
        - if <[item].has_inventory>:
            - define totalPoints:+:<[item].inventory_contents.proc[SC1_CalculateFoodPoints]>

        - if <[item].material.food_points.exists>:
            - define totalPoints:+:<[item].material.food_points.mul[<[item].quantity>]>


SC1_FoodInput_Window:
    type: inventory
    inventory: chest
    title: Food Input Menu
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [InterfaceFiller_Item] [Info_Item] [Check_Item] [Cross_Item]


SC1_FoodManager_Handler:
    type: world
    events:
        on player opens SC1_FoodManager_Window:
        - define world <player.location.world>
        - define kingdom <player.flag[kingdom]>

        - define foodInfoItemSlot <context.inventory.find_item[SC1_FoodManagerInfo_Item]>
        - define nextTickItemSlot <context.inventory.find_item[SC1_NextFoodTick_Item]>
        - define foodFullfillmentSlot <context.inventory.find_item[SC1_FoodReserves_Item]>
        - define currentPopItemSlot <context.inventory.find_item[SC1_CurrentPopulation_Item]>

        - inventory adjust slot:<[foodInfoItemSlot]> d:<context.inventory> lore:<[kingdom].proc[GetKingdomShortName]>
        - inventory adjust slot:<[nextTickItemSlot]> d:<context.inventory> lore:<white><element[Progress to next food tick:]>|<proc[SC1_NextFoodTickCalculator].context[<[world]>]>
        - inventory adjust slot:<[foodFullfillmentSlot]> d:<context.inventory> lore:<element[Current food fullfillment:]>|<element[<[kingdom].proc[GetKingdomFoodReserves].round.format_number.color[aqua]> / <[kingdom].proc[SC1_FoodFullfillmentGetter].round.format_number.color[blue]>]>
        - inventory adjust slot:<[currentPopItemSlot]> d:<context.inventory> lore:<element[<[kingdom].proc[GetKingdomPopulation].format_number.color[aqua]> citizens]>

        on player clicks SC1_AddFood_Item in SC1_FoodManager_Window:
        - inventory open d:SC1_FoodInput_Window

        on player opens SC1_FoodInput_Window:
        - define infoItemSlot <context.inventory.find_item[Info_Item]>
        - inventory adjust slot:<[infoItemSlot]> d:<context.inventory> lore:<element[Click to get current food points!]>

        on player clicks Check_Item in SC1_FoodInput_Window:
        - determine passively cancelled

        - define kingdom <player.flag[kingdom]>

        - define inputContents <context.inventory.list_contents.get[1].to[45]>
        - define foodPoints <[inputContents].proc[SC1_CalculateFoodPoints]>

        # Remove all the food items from the interface and add up the food point total.
        - foreach <context.inventory.list_contents> as:item:
            - if <[item].material.name> == air:
                - foreach next

            # This is not a recursive task because (to my knowledge) you can't have an item with an
            # inventory inside another item with an inventory.
            #
            # Although this may change with the new backpack feature they're adding...
            - if <[item].has_inventory>:
                - define outerIndex <[loop_index]>

                - foreach <[item].inventory_contents>:
                    - if <[value].material.food_points.exists>:
                        - inventory adjust slot:<[outerIndex]> d:<context.inventory> inventory_contents:<[value].inventory_contents.remove[<[loop_index]>]>

            - if <[item].material.food_points.exists>:
                - inventory set slot:<[loop_index]> d:<context.inventory> o:air

        - run AddKingdomFoodReserves def.kingdom:<[kingdom]> def.amount:<[foodPoints]>
        - inventory open d:SC1_FoodManager_Window

        on player clicks Cross_Item in SC1_FoodInput_Window:
        - inventory open d:SC1_FoodManager_Window

        on player closes SC1_FoodInput_Window:
        - define inputContents <context.inventory.list_contents.get[1].to[45]>

        - if !<[inputContents].is_empty>:
            - give to:<player.inventory> <[inputContents].exclude[<item[air]>]>

        on player clicks Info_Item in SC1_FoodInput_Window:
        - define inputContents <context.inventory.list_contents.get[1].to[45]>
        - inventory adjust slot:<context.slot> d:<context.inventory> lore:<element[Click to get current food points!]>|<element[<[inputContents].proc[SC1_CalculateFoodPoints].color[aqua]> food points]>

        - determine cancelled

        on player clicks InterfaceFiller_Item in SC1_FoodInput_Window:
        - determine cancelled
