# KAPI Script Documentation

## Kingdom Actions

Scripts under this category get and change data relating to one or all kingdoms.

---

### `GetKingdomList(Procedure)`
#### Description: Generates a list of all the valid kingdom code names. When 'isCodeNames' is set to false the procedure generates a list of the full/real kingdom names. isCodeNames is true by default
```
    Defintions:
    - [OPTIONAL] isCodeNames: ElementTag<Boolean>

    Determines:
    --> ListTag<ElementTag<String>>
```

---

### `IsKingdomCodeValid(Procedure)`
#### Description: Checks id the kingdom code provided is a valid one.
```
    Definitions:
    - kingdomCode: ElementTag<String>

    Determines:
    --> ElementTag<Boolean>
```

---

### `IsKingdomBankrupt(Procedure)`
#### Description: Checks if the provided kingdom is bankrupt.
```
    Definitions:
    - kingdom: ElementTag<String>

    Determines:
    --> ElementTag<Boolean>
```

---

### `GetBalance(Procedure)`
#### Description: Returns the balance of a given kingdom.
```
    Definitions:
    - kingdom: ElementTag<String>

    Determines:
    --> ElementTag<Float>
```

---

### `SetBalance(Task)`
#### Description: Sets the balance of a given kingdom to a given amount.
```
    Definitions:
    - kingdom: ElementTag<String>
    - amount: ElementTag<Float>

    Determines:
    --> Void
```

---

### `AddBalance(Task)`
#### Description: Adds a given amount to the provided kingdom's balance.
```
    Definitions:
    - kingdom: ElementTag<String>
    - amount: ElementTag<Float>

    Determines:
    --> Void
```