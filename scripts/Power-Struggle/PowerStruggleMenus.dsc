##ignorewarning ancient_defs
##ignorewarning missing_quotes
##----------------START HEADER----------------
##
## * All the menus and items of the influence system
## * NOTE: Currently being reorganized!
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Aug 2021
## @Script Ver: v2.0
##
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

################################################
## INFLUENCE MAIN WINDOW ITEMS
## Accessed with /influence and /influence help
################################################

TotalInfluence:
    type: item
    material: emerald
    display name: "<white>Total Influence"
    flags:
        type: totalinfluence
    lore:
    - <proc[InfluenceGetter].context[totalinfluence]>

MasonsInfluence:
    type: item
    material: bricks
    display name: "<dark_purple>Mason's Guild Influence"
    flags:
        type: masonsguild
    lore:
    - <proc[InfluenceGetter].context[masonsguild]>

MercenaryInfluence:
    type: item
    material: bow
    display name: "<red>Fyndalin Militia Influence"
    flags:
        type: mercenaryguild
    lore:
    - <proc[InfluenceGetter].context[mercenaryguild]>

GovernmentInfluence:
    type: item
    material: blaze_rod
    display name: "<blue>Fyndalin Govt<&sq> Influence"
    flags:
        type: fyndalingovt
    lore:
    - <proc[InfluenceGetter].context[fyndalingovt]>

PopulationInfluence:
    type: item
    material: player_head
    display name: "<green>Popular Influence"
    flags:
        type: citypopulation
    lore:
    - <proc[InfluenceGetter].context[citypopulation]>

BlackMarketInfluence:
    type: item
    material: tnt
    display name: "<light_purple>Black Market Influence"
    lore:
    - "░░░░░░░░░ N/A ░░░░░░░░░"
    - <&sp>
    - "<white><italic>Click to see more information"

InfluenceHelp:
    type: item
    material: player_head
    display name: Help
    mechanisms:
        skull_skin: 51878713-6440-3b3b-9187-871364401b3b|e3RleHR1cmVzOntTS0lOOnt1cmw6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZGE5OWIwNWI5YTFkYjRkMjliNWU2NzNkNzdhZTU0YTc3ZWFiNjY4MTg1ODYwMzVjOGEyMDA1YWViODEwNjAyYSJ9fX0=

FyndalinAnger_Item:
    type: item
    material: player_head
    display name: <red><bold>Fyndalian Anger
    lore:
    - <proc[FyndalinAnger]>

FyndalinAngerHelp_Item:
    type: item
    material: player_head
    display name: <red>Fyndalian Anger
    lore:
    - "It's important to keep the city placated as you"
    - "silently plot your takeover."
    - <&sp>
    - "Just because you hold sway over someone, it doesn't"
    - "mean they like you..."

TotalInfluence_Help:
    type: item
    material: emerald
    display name: "<white>Total Influence"
    lore:
    - "Your kingdom's total influence is an average"
    - "of all the influence you exert in the sections"
    - "below, weighted by your kingdom's prestige"

MasonsInfluence_Help:
    type: item
    material: bricks
    display name: "<dark_gray>Mason's Guild Influence"
    lore:
    - "Fyndalin has been undergoing reconstruction since"
    - "the civil war (Although most residents would beg to"
    - "differ), and Fyndalin's masons guild is largely"
    - "in charge. Getting in their good graces may allow"
    - "you more control over construction and builds in the"
    - "city."

MercenaryInfluence_Help:
    type: item
    material: bow
    display name: "<red>Fyndalin Militia Influence"
    lore:
    - "The city militia (Formally known as the 1st Fyndalin"
    - "Police Battalion) largely owes its existence to a"
    - "series of apathetic compromises made the kingdom leaders"
    - "when they got tired of quelling rebellions themselves."
    - "It is for this reason that the militia holds considerable"
    - "control over Fyndalin's borders and defense. <red>Influencing"
    - "<red>them is a requirement if you ever wish to annex the city!"

GovernmentInfluence_Help:
    type: item
    material: blaze_rod
    display name: "<blue>Fyndalin Govt<&sq> Influence"
    lore:
    - "It is no secret that the mandate of Fyndalin is an"
    - "incredibly corrupt government. Its sole function is"
    - "to provide a theatre through which the four kingdoms"
    - "can exert their influence in the region. The more"
    - "ministers you are able to sway inside the mandate"
    - "government, the more resources are able to siphon"
    - "out of the city, and the more it will become a puppet-"
    - "like government."

PopulationInfluence_Help:
    type: item
    material: player_head
    display name: "<green>Popular Influence"
    lore:
    - "They say that a leader without his people's support"
    - "is not a leader at all. It is for this reason that"
    - "you should probably ensure that public opinion"
    - "of your kingdom doesn't drop too low in Fyndalin."
    - "The peasants are unlikely to directly stop from"
    - "enforcing your will in the city, however if they're"
    - "not fond of you, they might provide some spirited"
    - "resistence if ever you choose to integrate Fyndalin."

FyndalinTreaties_Item:
    type: item
    material: paper
    display name: "<yellow>Treaties of Fyndalin"
    lore:
    - "Learn more by clicking the help button."

FyndalinTreatiesHelp_Item:
    type: item
    material: paper
    display name: "<yellow>Treaties of Fyndalin"
    lore:
    - "Fyndalin was unconditionally bound to a number of"
    - "agreements after its defeat following its defeat in"
    - "the civil war. These collection of documents are"
    - "collectively known as the continental treaties of"
    - "assured security (or the CTAS). These agreements form"
    - "the basis of Fyndalin's disarmament and place in the"
    - "modern world."

##############################################################
## FYNDALIN TAKEOVER ITEMS
## Accessed by clicking on total influence item in /influence
##############################################################


FyndalinTakeoverImpossible_Item:
    type: item
    material: player_head
    display name: "<gray><bold>Takeover Not Possible"
    mechanisms:
        skull_skin: b21a939f-178c-48ff-aa2e-ab365cfdc79f|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNTk1YWNhNzJkY2NlMTI5ODQ3NTM5OGZiN2FkZmY4NDQ3YzlhNjcwZTZjZjY0ZGQzOTMzYmJjOTQ5MThlOTkifX19

FyndalinTakeoverPossible_Item:
    type: item
    material: player_head
    display name: "<red><bold>Takeover Possible"
    mechanisms:
        skull_skin: 3d80d659-36cd-4aee-8540-8cdb548ede75|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvM2FmNTk3NzZmMmYwMzQxMmM3YjU5NDdhNjNhMGNmMjgzZDUxZmU2NWFjNmRmN2YyZjg4MmUwODM0NDU2NWU5In19fQ==

FyndalinTakeoverHelp_Item:
    type: item
    material: player_head
    display name: "<bold>Help"
    mechanisms:
        skull_skin: 51878713-6440-3b3b-9187-871364401b3b|e3RleHR1cmVzOntTS0lOOnt1cmw6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZGE5OWIwNWI5YTFkYjRkMjliNWU2NzNkNzdhZTU0YTc3ZWFiNjY4MTg1ODYwMzVjOGEyMDA1YWViODEwNjAyYSJ9fX0=
    lore:
    - "Kingdoms are able to initiate coups in Fyndalin once"
    - "they trail ahead every other Kingdom's influence by"
    - "at least 30% and have above 50% influence, themselves."
    - "Kingdoms that do not have the support (or have not, at"
    - "least, bought the indifference) of the Fyndalin militia"
    - "are more likely to fail at this endeavour."


## IT IS IMPERETIVE THAT THESE SUB-INVENTORY NAMES START WITH THE INFLUENCE TYPE
## I.E. "MERCENARY", "GOVERNMENT", "MASONS", "POPULATION", "BLACKMARKET"


#MAIN INF. SUB-WINDOW
MercenaryInfluence_Window:
    type: inventory
    title: "Influence Fyndalin Officers"
    inventory: chest
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [Bribe_Influence] [] [] [] [] [] [] []
    - [] [WeaponTransfer_MercInfluence] [] [] [] [] [] [] []
    - [] [] [] [] [Back_Influence] [] [] [] []

#MAIN INF. SUB-WINDOW
GovernmentInfluence_Window:
    type: inventory
    title: "Influence Fyndalin Govt<&sq>"
    inventory: chest
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [Bribe_Influence] [] [InitimidatePolitics_Influence] [] [] [] [Loan_From_Fyndalin_Influence] []
    - [] [Reconstruction_Influence] [] [] [] [] [] [Loan_To_Fyndalin_Influence] []
    - [] [] [] [] [Back_Influence] [] [] [] []

#MAIN INF. SUB-WINDOW
MasonsInfluence_Window:
    type: inventory
    title: "Influence Masons Guild"
    inventory: chest
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [Bribe_Influence] [] [] [] [] [] [] []
    - [] [MaterialTransfer_MasonInfluence] [] [] [] [] [] [] []
    - [] [] [] [] [Back_Influence] [] [] [] []

#MAIN INF. SUB-WINDOW
PopulationInfluence_Window:
    type: inventory
    title: "Influence Popular Sentiment"
    inventory: chest
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [Propaganda_Influence] [] [VoteRig_Influence] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [Back_Influence] [] [] [] []

#MAIN INF. SUB-WINDOW
BlackMarketInfluence_Window:
    type: inventory
    title: "Influence Black Market Factions"
    inventory: chest
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [FactionOneInfluence_Option] [] [FactionTwoInfluence_Option] [] [FactionThreeInfluence_Option] [] [FactionFourInfluence_Option] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [Back_Influence] [] [] [] []

#MAIN WEAPON WINDOW
WeaponTransferSelection_Window:
    type: inventory
    title: "Weapon Transfer Selections"
    inventory: chest
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [TransferSwords] [] [TransferArmour] [] [TransferRanged] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [Back_Influence] [] [] [] []

# VOTE RIG SUB-WINDOW
VoteRigInfo_Window:
    type: inventory
    title: "Fyndalin Elections Tampering"
    inventory: chest
    gui: true
    slots:
    # Note: If you change the position of NextElection_Influence be sure to change
    # the slot whose lore is modified in VoteRigging.dsc
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [NextElection_Influence] [] [] [] []
    - [] [] [] [] [Back_Influence] [] [] [] []

#MAIN MATERIAL WINDOW
MaterialTransferSelection_Window:
    type: inventory
    title: "Material Transfer Selections"
    inventory: chest
    gui: true
    slots:
    - [bricks] [cobblestone] [cobblestone_slab] [stone_bricks] [stone_brick_slab] [cobblestone_stairs] [stone_brick_stairs] [glass] [glass_pane]
    - [oak_log] [oak_planks] [oak_slab] [oak_stairs] [oak_fence] [] [] [] []
    - [spruce_log] [spruce_planks] [spruce_slab] [spruce_stairs] [spruce_fence] [] [] [] []
    - [iron_bars] [oak_sign] [spruce_sign] [lantern] [torch] [] [] [] []
    - [] [] [] [] [Back_Influence] [] [] [] []

#WEAPONS SUB-WINDOW
TransferSwords_Window:
    type: inventory
    title: "Transfer Meele Weapons"
    inventory: chest
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [stone_sword] [] [iron_sword] [] [diamond_sword] [] [netherite_sword] []
    - [] [stone_axe] [] [iron_axe] [] [diamond_axe] [] [netherite_axe] []
    - [] [] [] [] [Back_Influence] [] [] [] []

#WEAPONS SUB-WINDOW
TransferRanged_Window:
    type: inventory
    title: "Transfer Meele Weapons"
    inventory: chest
    gui: true
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [bow] [] [crossbow] [] [arrow] [] []
    - [] [] [] [] [Back_Influence] [] [] [] []

#WEAPONS SUB-WINDOW
TransferArmour_Window:
    type: inventory
    title: "Transfer Meele Weapons"
    inventory: chest
    gui: true
    slots:
    - [] [iron_helmet] [] [golden_helmet] [] [diamond_helmet] [] [netherite_helmet] []
    - [] [iron_chestplate] [] [golden_chestplate] [] [diamond_chestplate] [] [netherite_chestplate] []
    - [] [iron_leggings] [] [golden_leggings] [] [diamond_leggings] [] [netherite_leggings] []
    - [] [iron_boots] [] [golden_boots] [] [diamond_boots] [] [netherite_boots] []
    - [] [] [] [] [Back_Influence] [] [] [] []


# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# START INFLUENCE SUB-WINDOWS ITEMS
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV

Back_Influence:
    type: item
    material: player_head
    display name: Back
    mechanisms:
        skull_skin: e5b4f889-64ba-3de9-a5b4-f88964baade9|e3RleHR1cmVzOntTS0lOOnt1cmw6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNGM2ZGNjYzk2Y2YzZGRkNTFjYWE3MDYyM2UxZWIzM2QxZWFlYTU3NDVhNDUyZjhhNWM0ZDViOWJlYWFhNWNjNCJ9fX0=

Bribe_Influence:
    type: item
    material: diamond
    display name: Bribe Officials
    lore:
    - "It's no secret that in cash-strapped Fyndalin people"
    - "may need a few extra <&dq>Monetary Incentives<&dq>"
    - "to do their jobs (and maybe, in the process, return"
    - "us the favor)."
    - "Note<&co> Bribes withdraw from the kingdom's bank"

InitimidatePolitics_Influence:
    type: item
    material: iron_sword
    display name: "Intimidate Unaligned MPs"
    lore:
    - "<bold><red>[This action will reduce your influence"
    - "<bold><red>at the cost of another kingdom at random]"
    - "Parliamentarians these days, all they know is"
    - "take bribes, shill out to they mandate, rig"
    - "elections, and LIE."

Reconstruction_Influence:
    type: item
    material: paper
    display name: Reconstruction Permits
    lore:
    - "Fyndalin has been undergoing a reconstruction process"
    - "since the days of the war that ravaged the landscape"
    - "in and around the city. Although the council has been"
    - "slowly and steadily pulling funds from the reconstruction."
    - "<italic>(for reasons that are in no way related to the infamous"
    - "<italic>levels of corruption present in the mandate council)"

Loan_From_Fyndalin_Influence:
    type: item
    material: player_head
    display name: "Take Loan from Fyndalin"
    mechanisms:
        skull_skin: b08f3e78-fa26-484a-97a3-03ce8cc26ff0|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNDgwODM5MDY5OWJiMDY5NTNjODZjMWEzNTU3OTJlZTYzNjc4OTgxNjE4ZjgwNDdiNzVjOTNiYTA3YTk4MWEwOCJ9fX0=

    lore:
    - "<bold><red>[Negative Influence Action]"
    - "Allows you to take a set number of 0 interest loan from Fyndalin."
    - "Each loan will, however, cause to lose an amount of influence"
    - "proportional to the amount you took out."

Loan_To_Fyndalin_Influence:
    type: item
    material: player_head
    display name: "Give Loan to Fyndalin"
    mechanisms:
        skull_skin: d789eebe-d604-47a8-9c5b-8ef4f9f29c96|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOGVlYjE4ZTY2OTVjMzliNDQxZDA0ZjdjYTUzZWRhMTM0NmE1YTk0N2Q0ZmU4YmEzN2IzM2I5MjMyODhiNGUzMCJ9fX0=

    lore:
    - "Allows you to give 0 interest loan to Fyndalin."
    - "Each loan will grant your kingdom a certain amount of"
    - "influence provided that Fyndalin accepts the loan."

VoteRig_Influence:
    type: item
    material: player_head
    display name: "Rig Local Elections"
    mechanisms:
        skull_skin: afee5492-b231-4e5e-adfb-79c78097b1f3|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNzhjYjk4OWVmMjljNzM0ZmUwNWE5NWJmYTE1YWYwOGFiYmI2NGExNzNlYTMyZjBmNmYwNmQ2ZTM0ZjliZDM4In19fQ==

    lore:
    - "Through the infinite kindness and charity of out kingdom"
    - "we can send a small delegation to help the vastly under-"
    - "-staffed election committee of Fyndalin to carry out their"
    - "duties. While we're at it we can make sure nobody's voting"
    - "for dissident par- err... I mean <gray><italic>committing voter fraud?"

WeaponTransfer_MercInfluence:
    type: item
    material: iron_sword
    display name: Weapons Transfer
    lore:
    - "The Mandate Council has always kept Fyndalin's weapon"
    - "stashes under keen supervision. However recent changes"
    - "in leadership, and decreased interest in the populace"
    - "of the kingdoms in their involvement in Fyndalin, brings"
    - "us a chance to supply the Fyndalin militia, and bring"
    - "them into our influence."
    - "<red><bold>Note: Failing to deliver weapons after a deal is"
    - "<red><bold>made will likely result in a reduction of influence"

TransferRanged:
    type: item
    display name: Transfer Ranged
    material: bow
    flags:
        transferType: ranged
    mechanisms:
        hides: ALL

TransferSwords:
    type: item
    display name: Transfer Melee
    material: iron_sword
    flags:
        transferType: melee
    mechanisms:
        hides: ALL

TransferArmour:
    type: item
    display name: Transfer Armour
    material: iron_helmet
    flags:
        transferType: armour
    mechanisms:
        hides: ALL

MaterialTransfer_MasonInfluence:
    type: item
    display name: Transfer Material
    material: brick
    lore:
    - "Fyndalin's reconstruction is (supposedly) the main goal"
    - "of the mandate council. However due to a lack of interest"
    - "from the kingdoms, and a general unwillingness to allow"
    - "Fyndalin to become a regional power again, has lead to"
    - "this effort stalling time and time again. Maybe this time"
    - "might be different..."

NextElection_Influence:
    type: item
    display name: "<light_purple><bold>Next Election:"
    material: player_head
    mechanisms:
        skull_skin: 55489e80-c5e9-466a-afd8-c4011f272222|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvY2Q5MWY1MTI2NmVkZGM2MjA3ZjEyYWU4ZDdhNDljNWRiMDQxNWFkYTA0ZGFiOTJiYjc2ODZhZmRiMTdmNGQ0ZSJ9fX0=

Propaganda_Influence:
    type: item
    display name: Propaganda Campaign
    material: book
    lore:
    - "The people of Fyndalin have some strong about their foreign"
    - "overlords, most of them quite negative. However maybe we can"
    - "change their minds with the power of (completely true and"
    - "trustworthy) information!"

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# START BLACK MARKET SUB-WINDOWS ITEMS
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV

FactionOneInfluence_Option:
    type: item
    material: black_banner
    display name: "<blue><bold>Blackstone Faction"
    flags:
        factionInfo: <list[blackstone|1]>

FactionTwoInfluence_Option:
    type: item
    material: red_banner
    display name: "<red><bold>Orama Crime Family"
    flags:
        factionInfo: <list[orama|2]>

FactionThreeInfluence_Option:
    type: item
    material: purple_banner
    display name: "<dark_purple><bold>Combined Syndicates"
    flags:
        factionInfo: <list[syndicates|3]>

FactionFourInfluence_Option:
    type: item
    material: white_banner
    display name: "<&r><bold>Totalist Faction"
    flags:
        factionInfo: <list[totalist|4]>

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# START INFLUENCE WINDOW ITEMS
# VVVVVVVVVVVVVVVVVVVVVVVVVVVV

MercenaryInfluence_Option:
    type: item
    material: bow
    display name: <&r>Influence Fyndalin Officers

MasonsInfluence_Option:
    type: item
    material: bricks
    display name: <&r>Influence Fyndalin Masons

GovernmentInfluence_Option:
    type: item
    material: blaze_rod
    display name: <&r>Influence Fyndalin Government

PopularInfluence_Option:
    type: item
    material: player_head
    display name: <&r>Influence Fyndalin Populace

BlackMarketInfluence_Option:
    type: item
    material: tnt
    display name: <&r>Influence Black Market Factions