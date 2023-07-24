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

## DKingdoms Style Guide

### Basic Conventions

#### Naming Scheme
All definitions and flags in Kingdoms are camel-cased. For example;

```DenizenScript
- define someElement <element[Hello World]>
- flag server anotherElement:<[someElement]>
```

While script names are all in Pascal-case;

```DenizenScript
SomeWorldScript:
    type: world
    events:
        on player quits:
        - narrate format:callout "Bye bye, <player.name>!"
```

Definition and flag names may not start with numbers or symbols. These names may only start with a character matching: `[A-z]|[0-9]`. The only exception to this rule is the utilization of the underscore character to modify queue-level 'fake' definitions like `__player` and `__npc`.

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

Finally, the last place where whitespace is necessitated is between commands that directly affect player, entities, or the world, adn those that do not. Blocks of such commands can be placed together without an empty line between them. Commands which fall into this category are:

- All commands under the `entity`, `npc`, `player`, `item`, and `world` sections on the [Denizen meta page](https://meta.denizenscript.com/Docs/Commands)
- `clientrun` (if Clientizen is installed)
- All `discord`-related commands
- `adjustblock`
- `note`

Beyond this, developers and contributors have the discretion to add any other whitespace to make their code more readable or to emphasize certain blocks or sections of scripts.

## Direct Flag References

Where ever possible contributors and developers must avoid using direct references to player, world, entity, and server-level flags such as `server.kingdoms` or `npc.merchantData`, for example. Directly modifying the contents of flags considered essential to the functioning of Kingdoms could result in unpredictable behaviour that may corrupt game data.

Almost every flag action relating to Kingdoms can be carried out through the Kingdoms API (KAPI). For example, adding funds to kingdom's balance should always be done using the relevant task script: `AddBalance`;

```DenizenScript
- run AddBalance def.kingdom:<[kingdom]> def.amount:100
```

All KAPI scripts can be found under the `scripts/Global-Scripts/Common-Library` directory.

*TODO: Document all KAPI scripts properly.*

## Task & Procedure Scripts

Here is the format of a sample task script. All task and procedure scripts must be documented through a docstring at the top of the 'script' section.

```DenizenScript
SampleTaskScript:
    type: task
    definitions: someMap|someList|someInt
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
    
    - <...>
```

All definitions' type contracts must be established below the docstring description. Since Denizen is dynamically typed there are a number of type conventions we will utilize that do not have an analogue in Denizen. For example, Element tags can hold an array of types that are often separate in regular programming languages like integers, floats, booleans, or strings. For that reason, when documenting an ElementTag you must also provide the exact type expected within angle-brackets.

Under all definition type contracts must be an additional type contract for the return value. If the task/procedure has no return value then simply indicate that using: `>>> [Void]`.

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

## World Scripts

TODO

## Command Scripts

TODO