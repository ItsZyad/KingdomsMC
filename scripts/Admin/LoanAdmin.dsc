##
## * Contains all of the code relating to the admin window
## * for the loans to Fyndalin
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jul 2022
## @Script Ver: INDEV
##
## ----------------END HEADER-----------------

LoanAdmin_Window:
    type: inventory
    inventory: chest
    title: Loan Admin
    gui: true
    procedural items:
    - determine <proc[LoanAdminGeneration_Proc]>
    slots:
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [] [] [] [] [] []
    - [] [] [] [Page_Back] [] [Page_Forward] [] [] []

LoanAdminOffer_Item:
    type: item
    material: player_head
    display name: <blue><bold>Loan Offer
    mechanisms:
        skull_skin: 7193fa7b-4dbe-4e92-a840-3d95d2839240|eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvZDllOTA2OGQxNWI0ZDhhNGI2NGZiYjA2NzQ0MTBkYjM0OWE2YzZhYWQ3OWZlOGE1YWI3MWU5NGRhMjQwZmZmNiJ9fX0=

LoanAdminGeneration_Proc:
    type: procedure
    script:
    - define loanOffers <server.flag[fyndalin.loanOffers]>
    - define loanList <list[]>

    - foreach <[loanOffers]> as:offer:
        - define loanItem <item[LoanAdminOffer_Item]>
        - define amount <[offer].get[amount]>
        - define kingdom <[offer].get[kingdom]>
        - define expiry <[offer].get[expiry]>
        - define kingdomColor <script[KingdomTextColors].data_key[<[kingdom]>]>

        - define lore "<bold><element[Offer Amount: ].color[white]><[amount].color[aqua]>|<element[Kingdom: ].color[white]><[kingdom].color[<[kingdomColor]>]>|<element[Expiry Date: ].color[white]><[expiry].color[aqua]>"

        - adjust def:loanItem lore:<[lore]>
        - define loanList:->:<[loanItem]>

    - determine <[loanItem]>