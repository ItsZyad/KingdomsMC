Exchange:
    type: assignment
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:chat state:true
    interact scripts:
    - Exchange_I

Exchange_I:
    type: interact
    steps:
        1:
            click trigger:
                script:
                    - inventory open d:in@ExchangeWindow

ExchangeWindow:
    type: inventory
    title: "Exchanges"
    slots:
    - "[Info] [] [] [] [] [] [] [] []"
    - "[Info_Sec1] [Info_Sec1] [Info_Sec1] [Info_Sec1] [Info_Sec1] [Info_Sec1] [Info_Sec1] [Info_Sec1] [Info_Sec1]"
    - "[OneDollar] [TenDollar] [TwentyDollar] [FiftyDollar] [HundredDollar] [ThousandDollar] [TenThousandDollar] [HundredThousandDollar] []"
    - "[Info_Sec2] [Info_Sec2] [Info_Sec2] [Info_Sec2] [Info_Sec2] [Info_Sec2] [Info_Sec2] [Info_Sec2] [Info_Sec2]"
    - "[OneDollar_Back] [TenDollar_Back] [TwentyDollar_Back] [FiftyDollar_Back] [HundredDollar_Back] [ThousandDollar_Back] [TenThousandDollar_Back] [HundredThousandDollar_Back] []"
    - "[] [] [] [] [] [] [] [] [Exit]"

ExchangeWindowHandler:
    type: world
    events:
        on player clicks Exit in ExchangeWindow:
        - inventory close d:in@ExchangeWindow
        
        on player clicks OneDollar in ExchangeWindow:
        - if <player.money.is[OR_MORE].than[1]>:
            - take money quantity:1
            - give OneDollar
        - determine cancelled
        
        on player clicks OneDollar_Back in ExchangeWindow:
        - if <player.inventory.contains[OneDollar]>:
            - give money quantity:1
            - take OneDollar
        - determine cancelled
        
        on player clicks TenDollar in ExchangeWindow:
        - if <player.money.is[OR_MORE].than[10]>:
            - take money quantity:10
            - give TenDollar
        - determine cancelled
        
        on player clicks TenDollar_Back in ExchangeWindow:
        - if <player.inventory.contains[TenDollar]>:
            - give money quantity:10
            - take TenDollar
        - determine cancelled
        
        on player clicks TwentyDollar in ExchangeWindow:
        - if <player.money.is[OR_MORE].than[20]>:
            - take money quantity:20
            - give TwentyDollar
        - determine cancelled
        
        on player clicks TwentyDollar_Back in ExchangeWindow:
        - if <player.inventory.contains[TwentyDollar]>:
            - give money quantity:20
            - take TwentyDollar
        - determine cancelled
        
        on player clicks FiftyDollar in ExchangeWindow:
        - if <player.money.is[OR_MORE].than[50]>:
            - take money quantity:50
            - give FiftyDollar
        - determine cancelled
        
        on player clicks FiftyDollar_Back in ExchangeWindow:
        - if <player.inventory.contains[FiftyDollar]>:
            - give money quantity:50
            - take FiftyDollar
        - determine cancelled
        
        on player clicks HundredDollar in ExchangeWindow:
        - if <player.money.is[OR_MORE].than[100]>:
            - take money quantity:100
            - give HundredDollar
        - determine cancelled
        
        on player clicks HundredDollar_Back in ExchangeWindow:
        - if <player.inventory.contains[HundredDollar]>:
            - give money quantity:100
            - take HundredDollar
        - determine cancelled
        
        on player clicks ThousandDollar in ExchangeWindow:
        - if <player.money.is[OR_MORE].than[1000]>:
            - take money quantity:1000
            - give ThousandDollar
        - determine cancelled
        
        on player clicks ThousandDollar_Back in ExchangeWindow:
        - if <player.inventory.contains[ThousandDollar]>:
            - give money quantity:1000
            - take ThousandDollar
        - determine cancelled
        
        on player clicks TenThousandDollar in ExchangeWindow:
        - if <player.money.is[OR_MORE].than[10000]>:
            - take money quantity:10000
            - give TenThousandDollar
        - determine cancelled
        
        on player clicks TenThousandDollar_Back in ExchangeWindow:
        - if <player.inventory.contains[TenThousandDollar]>:
            - give money quantity:10000
            - take TenThousandDollar
        - determine cancelled
        
        on player clicks HundredThousandDollar in ExchangeWindow:
        - if <player.money.is[OR_MORE].than[100000]>:
            - take money quantity:100000
            - give HundredThousandDollar
        - determine cancelled
        
        on player clicks HundredThousandDollar_Back in ExchangeWindow:
        - if <player.inventory.contains[HundredThousandDollar]>:
            - give money quantity:100000
            - take HundredThousandDollar
        - determine cancelled
        
        on player clicks Info_Sec1 in ExchangeWindow:
        - determine cancelled
        
        on player clicks Info_Sec2 in ExchangeWindow:
        - determine cancelled
        
        on player drags in ExchangeWindow:
        - determine passively cancelled
        
        on player clicks Info in ExchangeWindow:
        - determine cancelled

Info:
    type: item
    material: stick
    display name: "Info"
    lore:
    - "In Kingdoms, money is handled on a player-by-player"
    - "basis. Money which can be lost if the player holding"
    - "dies and respawns. So exchanging it will allow you to"
    - "store it in a physical form to prevent it being lost"
    - "when you die, but does open up the possibility of it"
    - "being stolen, so watch out!"

Info_Sec1:
    type: item
    material: barrier
    lore:
    - "Convert Kingdoms currency to physical currency"

Info_Sec2:
    type: item
    material: barrier
    lore:
    - "Convert physical currency to Kingdoms currency"

OneDollar_Back:
    type: item
    material: iron_nugget
    lore:
    - "1$"
    
TenDollar_Back:
    type: item
    material: gold_nugget
    lore:
    - "10$"
    
TwentyDollar_Back:
    type: item
    material: iron_ingot
    lore:
    - "20$"
    
FiftyDollar_Back:
    type: item
    material: gold_ingot
    lore:
    - "50$"
    
HundredDollar_Back:
    type: item
    material: iron_block
    lore:
    - "100$"
    
ThousandDollar_Back:
    type: item
    material: gold_block
    lore:
    - "1,000$"
    
TenThousandDollar_Back:
    type: item
    material: diamond
    lore:
    - "10,000$"

HundredThousandDollar_Back:
    type: item
    material: Emerald
    lore:
    - "100,000$"
    
##############################################

OneDollar:
    type: item
    material: iron_nugget
    lore:
    - "1$"
    
TenDollar:
    type: item
    material: gold_nugget
    lore:
    - "10$"
    
TwentyDollar:
    type: item
    material: iron_ingot
    lore:
    - "20$"
    
FiftyDollar:
    type: item
    material: gold_ingot
    lore:
    - "50$"
    
HundredDollar:
    type: item
    material: iron_block
    lore:
    - "100$"
    
ThousandDollar:
    type: item
    material: gold_block
    lore:
    - "1,000$"
    
TenThousandDollar:
    type: item
    material: diamond
    lore:
    - "10,000$"

HundredThousandDollar:
    type: item
    material: emerald
    lore:
    - "100,000$"
