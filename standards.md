
---

# DKingdoms Contribution Standards

This document exists for the benefit of tenured developers and contributors to the DKingdoms project ('Kingdoms'). Please refer to this document should you wish to submit a pull request to the [Kingdoms public repository](https://github.com/ItsZyad/KingdomsMC). Failure to meet the standards and guidelines laid out in this document may result in the rejection of your PR or significant delay in its acceptance.

As of the writing of this version of the standards document, Kingdoms is written entirely in [Denizen™️](https://denizenscript.com/). Denizen is a plugin for Bukkit/Spigot/PaperMC servers that loads and runs user-written scripts automatically, allowing server owners to quickly and easily customize their server in a manner similar to plugin development. If you are not already familiar with Denizen then this document is not for you.

Prospective contributors to Kingdoms must first have a solid grasp of Denizen, and to a lesser extent, the operation of Minecraft servers in general. If you are interested in contributing to Kingdoms but are not familiar with Denizen please refer to its official guide here:

### [Denizen Beginner's Guide](https://guide.denizenscript.com/index.html)

## Pull Requests

Before submitting any pull request to the public Kingdoms repository, please check your code against all of the following points:

- The code you are submitting for review must either be entirely yours or is free/safe to use (i.e. entirely public domain).
  - If your code is under any pre-existing license, you must note it in the pull request.
- You must have made an effort to ensure the functionality of your PR prior to submission. While a few bugs can be expected in any PR, reviewers can reject a submission if it becomes excessively difficult to test due to a large amount of bugs/logical errors.
- PRs must adhere to the Kingdoms Style Guide, outlined below. 
  - **Important:** To encourage involvement in the project, reviewers will exercise leniency on this rule with first or second-time contributors.
  - For regular contributors, minor style violations will not lead to an outright rejection of a PR. however reviewers **will** reject PRs should they find too many style violations.
​
---

# DKingdoms Style Guide

## Basic Conventions

### Naming Scheme
All definitions, flags, and entry names in Kingdoms are camel-cased. For example;

```DenizenScript
- define playerKingdom <player.flag[kingdom]>

- run GetSomeData def.kingdom:<[kingdom]> save:someData
- define someData <entry[someData].created_queue.determination.get[1]>

- flag server anotherDataPoint:<[someData]>
```

Additionally any named command modifiers, such as `key:` and `as:` on `foreach` loops are to be defined in camel-case, while all script names are all in Pascal-case;

```DenizenScript
SomeWorldScript:
    type: world
    events:
        on player quits:
        - narrate format:callout "Bye bye, <player.name>!"
```

Definition and flag names may not start with numbers or symbols. These names may only start with a character matching: `[A-z]`. The only exception to this rule is the utilization of the underscore character to modify queue-level 'fake' definitions like `__player` and `__npc`.

### Comments
Comment lines must never exceed 100 characters. If you wish to write a comment longer than 100 characters you must separate it between multiple lines.

Comments starting with `Todo` will be highlighted yellow by the Denizen VSCode plugin. Should you wish to write a Todo comment longer than 100 characters or a comment spanning several lines, you must start each subsequent line of the comment with `Todo/` to maintain the highlighting;

```DenizenScript
# TODO: This is a multi-line todo comment.
# TODO/ This is the second line of the comment!
```

### Indentation
Standard indentation size for both Denizen, YAML, and JSON files is to be 4 space characters.

**Indenting with tabs is not allowed.**

### Spacing
There must be exactly two lines of whitespace between scripts and one line **after** subpaths, events, tab completes, descriptions, and any other multi-line script section;

```DenizenScript
SomeWorldScript:
    type: world
    events:
        on player quits:
        - narrate format:callout "Bye bye, <player.name>!"

        on player joins:
        - narrate format:callout "Hello, <player.name>!"


SomeOtherScript:
    type: task
    description:
    - This script exists to explain the Kingdoms spacing conventions...
    - How cool!

    script:
    - narrate format:debug "Test"
```

When working *within* a script, spacing should be utilized to highlight logical forks, comments, and commands that interact directly with the world. Therefore one line of whitespace should be placed before and after code blocks like `while`, `foreach`, and `if` statements (among others);

```DenizenScript
- define merchant <player.flag[dataHold.interactingMerchant]>
- define interactingPlayers <[merchant].flag[dataHold.interactingPlayers]>

- if !<player.has_flag[datahold.merchantMode]>:
    - determine cancelled

...
```

The only exception to this rule is when the header line of a code block immediately follows another header. For example;

```DenizenScript
- if <player.flag[dataHold.merchantMode]> == buy:
    - if !<context.item.has_flag[price]>:
        - determine cancelled
```

Comments must also be preceded with at least one line of whitespace. Optionally, they can also be followed by another empty line;

```DenizenScript
...

# Some comment 
- foreach <player.flag[someIterableFlag]>:
    - narrate format:callout <[value]>

...
```

Finally, the last place where whitespace is necessitated is between commands that directly affect players, entities, or the world, and those that do not. Commands which fall into this category are:

- All commands under the `entity`, `npc`, `player`, `item`, and `world` sections on the [Denizen meta page](https://meta.denizenscript.com/Docs/Commands)
- `clientrun` (if Clientizen is installed)
- All `discord`-related commands
- `adjustblock`
- `note`

Beyond this, developers and contributors have the discretion to add any other whitespace to make their code more readable, or to emphasize certain sections of script that they believe warrant emphasizing.

## Direct Flag References

_Important Note: This section of standards will not apply until KAPI is fully implemented_

---

Where ever possible contributors and developers must avoid using direct references to kingdoms-related flags such as `server.kingdoms` or `npc.merchantData`, for example. Directly modifying the contents of flags considered essential to the functioning of Kingdoms could result in unpredictable behaviour that may corrupt game data.

Almost every flag action relating to Kingdoms can be carried out through the Kingdoms API (KAPI). For example, adding funds to a kingdom's balance, setting upkeep, or modifying claims can be done through direct flag actions, however all have KAPI equivalents;

```DenizenScript
- run AddBalance def.kingdom:<[kingdom]> def.amount:100
- run SetUpkeep def.kingdom:<[kingdom]> def.amount:500
- run AddCoreClaim def.kingdom:<[kingdom]> def.chunk:<chunk[1,1,world]>
```

All KAPI scripts can be found under the `scripts/Global-Scripts/Common-Library` directory.

*TODO: Document all KAPI scripts properly.*

## Task & Procedure Scripts

Here is the format of a sample task script. All task and procedure scripts must be documented through a docstring at the top of the 'script' section.

```DenizenScript
SampleTaskScript:
    type: task
    definitions: someMap[MapTag]|someList[ListTag]|someInt[ElementTag(Integer)]
    script:
    ## Here would be a short description of the script and how it interacts with the definitions
    ## provided. Note that you must make reference to all of the definitions provided in this
    ## docstring.
    ##
    ## All normal rules regarding comments also apply to docstrings.
    ##
    ## someMap  : [MapTag]
    ## someList : [ListTag]
    ## someInt  : [ElementTag<Integer>]
    ##
    ## >>> [Void]
    
    ...
```

All definitions' type contracts must be established below the docstring description. Since Denizen is dynamically typed, there are a number of type conventions we will utilize that do not have an analogue in Denizen. For example, Element tags can hold an array of types that are often separate in regular programming languages like integers, floats, booleans, or strings. For that reason, when documenting an ElementTag you must also provide the exact type expected within angle-brackets.

Under all definition type contracts must be an additional type contract for the return value. If the task has no return value then simply indicate that using: `>>> [Void]`. However all procedure scripts must have a return value.

Formatting conventions for all type contracts are listed below:

| Type   | Format | Notes  |
|:--------|:--------|--------|
| Integer | `[ElementTag<Integer>]` |
| String  | `[ElementTag<String>]` |
| Float/Double | `[ElementTag<Float>]` | *For the purposes of Denizen programming, the difference between Floats and Doubles is largely irrelevant so both are represented with the type notation 'Float'.*|
| Boolean | `[ElementTag<Boolean>]` |
| Lists   | `[ListTag]` `[ListTag<*Type>]` | Multi-type or type-indeterminate lists should just be represtented with `[ListTag]`
| Maps    | `[MapTag]` `[MapTag<*Type:*Type>]` | ^Same as above
| All other tags | `[*Tagname+'Tag']` | Example: Locations --> `[LocationTag]` 

In addition to an in-script docstring, there must also be an identical copy of the docstring under the 'description' key of the script. But do note that the Denizen VSCode extension gets very unhappy when it sees angle brackets in places that it doesn't recognize (even in description keys), so be sure to replace all square brackets with regular parentheses;

```DenizenScript
SampleTaskScript:
    type: task
    definitions: someMap[MapTag]|someList[ListTag]|someInt[ElementTag(Integer)]
    description:
    - Here would be a short description of the script and how it interacts with the definitions provided.
    - All normal rules regarding comments also apply to docstrings.
    - ---
    - → [Void]
    
    ...
```

## Data Scripts

Usage of data scripts is encouraged throughout the Kingdoms codebase, especially when it comes to the representation of large datasets as not to clutter regular scripts. However, Denizen data scripts have no required keys other than `type: data`, meaning that it becomes easy to format and structure them inconsistently leading to confusion.

Data scripts in Kingdoms are not allowed to utilize non-nested keys. All data must be contained within a parent key. For example:

```DenizenScript
SomeItemsAndNumbers:
    type: data
    Items:
        wood:
            oak_planks: 100
            spruce_planks: 100
        stone:
            cobblestone: 50
            andesite: 30
```


Additionally, all naming schemes outlined for definitions and flags apply to data script keys, unless the data refers to items, player names, or any other non-Kingdoms-related datapoint.

## Command Scripts

TODO

## Subpaths

Subpathing is an essential tool that you can use to avoid code clutter in larger task and procedure scripts. They also have the added performance benefit of reducing the number of scripts processed by Denizen on every reload. However subpathed code may only be called from within the same script. Pull requests featuring scripts that call subpathed code from another script will almost certainly be rejected.

Additionally, always ensure that subpaths are written below the `script:` key on any script that contains them;

```DenizenScript
SomeTaskScript:
    type: task
    script:
    - narrate "This is a script to demonstrate subpath formatting!"
    - inject <script.name> path:OtherCode

    OtherCode:
    - repeat 10:
        - narrate "Subpaths are cool!"
```

All naming and spacing conventions mentioned in above sections apply to subpaths. Subpath name must be in Pascal-cased and be preceded by one empty line.

Optionally, in cases where a script has too many subpaths, the submitter may opt to add a deliniator between them in the following format: 

```DenizenScript
SomeTaskScript:
    type: task
    script:
    - narrate "This is a script to demonstrate subpath formatting!"
    - inject <script.name> path:OtherCode

    OtherCode:
    - repeat 10:
        - narrate "Subpaths are cool!"

    #------------------------------------------------------------------------------------------

    OtherOtherCode:
    - narrate "More code goes here..."
```
*(although this is not required, and the amount of subpaths deemed "too many" can be determined by the submitter)*

Should a deliniator be included, it must be on a comment line starting at an indentation level of 4 spaces, and consist of dash characters which stretch from the start of the comment to column 100 of the line. The deliniator must then be preceded and followed by empty lines.