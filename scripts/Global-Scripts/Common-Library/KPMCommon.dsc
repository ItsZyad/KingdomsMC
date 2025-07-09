##
## [KAPI]
## All common scripts relevant to KPM including addon info getters and status checkers.
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Jan 2024
## @Script Ver: v0.1
##
## ----------------END HEADER-----------------

DoesAddonExist:
    type: procedure
    debug: false
    definitions: name[ElementTag(String)]
    description:
    - Checks if the provided name is the name of a currently indexed addon.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Checks if the provided name is the name of a currently indexed addon.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - determine <server.flag[addons.addonList].keys.contains[<[name]>]>


IsAddonLoaded:
    type: procedure
    debug: false
    definitions: name[ElementTag(String)]
    description:
    - Returns true if the provided addon is currently loaded and running on the server.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns true if the provided addon is currently loaded and running on the server.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - if !<[name].proc[DoesAddonExist]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Provided addon name: <[name].color[red]> is invalid]> def.silent:true
        - determine null

    - determine <server.flag[addons.addonList.<[name]>.loaded]>


GetAllAddonNames:
    type: procedure
    debug: false
    description:
    - Will return a list of all the names of all currently indexed addons.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Will return a list of all the names of all currently indexed addons.
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - determine <server.flag[addons.addonList].keys>


GetAddonDisplayName:
    type: procedure
    debug: false
    definitions: name[ElementTag(String)]
    description:
    - Gets the display name of the addon with the provided name.
    - ---
    - → [ElementTag(String)]

    script:
    ## Gets the display name of the addon with the provided name.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - if !<[name].proc[DoesAddonExist]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Provided addon name: <[name].color[red]> is invalid]> def.silent:true
        - determine null

    - if <server.has_flag[addons.addonList.<[name]>.displayName]>:
        - determine <server.flag[addons.addonList.<[name]>.displayName]>

    - determine <[name]>


GetAddonMissingDependencies:
    type: procedure
    debug: false
    definitions: name[ElementTag(String)]
    description:
    - Returns a list of the provided addon's currently unsatisfied dependencies.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Returns a list of the provided addon's currently unsatisfied dependencies.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - if !<[name].proc[DoesAddonExist]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Provided addon name: <[name].color[red]> is invalid]> def.silent:true
        - determine null

    - determine <server.flag[addons.addonList.<[name]>.missingDependencies]>


GetAddonNameByHash:
    type: procedure
    debug: false
    definitions: hash[*BinaryTag]|shortHash[*ElementTag(String)]
    description:
    - Gets the name of an addon using its SHA256 hash or a shortened version of it.
    - Note: Definitions hash and shortHash are mutually exclusive.
    - ---
    - → [MapTag]

    script:
    ## Gets the name of an addon using its SHA256 hash or a shortened version of it.
    ## Note: Definitions 'hash' and 'shortHash' are mutually exclusive.
    ##
    ## hash      : *[BinaryTag]
    ## shortHash : *[ElementTag<String>]
    ##
    ## >>> [MapTag]

    - if <[hash].exists> && !<[shortHash].exists>:
        - determine <server.flag[addons.addonList].values.parse_tag[<[parse_value].get[hash|name]>].get[1].get[name]>

    - if !<[shortHash].exists>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Cannot get addon name without specifying either a valid SHA256 hash or a shortened version of it.]> def.silent:false
        - determine null

    - define shortHash <[shortHash].substring[1,4]>

    - foreach <server.flag[addons.addonList].values>:
        - if <[value].get[hash].proc[GetAddonShortHash]> == <[shortHash]>:
            - determine <[value].get[name]>


GetAddonVersion:
    type: procedure
    debug: false
    definitions: name[ElementTag(String)]
    description:
    - Gets the current version of the provided addon.
    - ---
    - → [ElementTag(String)]

    script:
    ## Gets the current version of the provided addon.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - if !<[name].proc[DoesAddonExist]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Provided addon name: <[name].color[red]> is invalid]> def.silent:true
        - determine null

    - determine <server.flag[addons.addonList.<[name]>.version]>


GetAddonHash:
    type: procedure
    debug: false
    definitions: name[ElementTag(String)]
    description:
    - Gets the SHA256 hash of the provided addon.
    - ---
    - → [BinaryTag]

    script:
    ## Gets the SHA256 hash of the provided addon.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [BinaryTag]

    - if !<[name].proc[DoesAddonExist]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Provided addon name: <[name].color[red]> is invalid]> def.silent:true
        - determine null

    - determine <server.flag[addons.addonList.<[name]>.hash]>


GetAddonRoot:
    type: procedure
    debug: false
    definitions: name[ElementTag(String)]
    description:
    - Gets the root directory of the addon with the provided name.
    - ---
    - → [ElementTag(String)]

    script:
    ## Gets the root directory of the addon with the provided name.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - if !<[name].proc[DoesAddonExist]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Provided addon name: <[name].color[red]> is invalid]> def.silent:true
        - determine null

    - determine <server.flag[addons.addonList.<[name]>.rootDir]>


GetAddonAuthors:
    type: procedure
    debug: false
    definitions: name[ElementTag(String)]
    description:
    - Gets a list of authors for the provided addon.
    - ---
    - → [ListTag(ElementTag(String))]

    script:
    ## Gets a list of authors for the provided addon.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [ListTag<ElementTag<String>>]

    - if !<[name].proc[DoesAddonExist]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Provided addon name: <[name].color[red]> is invalid]> def.silent:true
        - determine null

    - determine <server.flag[addons.addonList.<[name]>.authors]>


GetAddonShortHash:
    type: procedure
    debug: false
    definitions: name[ElementTag(String)]
    description:
    - Gets the shortened version of the SHA256 hash used to identify addons.
    - ---
    - → [ElementTag(String)]

    script:
    ## Gets the shortened version of the SHA256 hash used to identify addons.
    ##
    ## name : [ElementTag<String>]
    ##
    ## >>> [ElementTag<String>]

    - determine <proc[GetAddonHash].context[<[name]>].as[element].split[@].get[2].substring[1,4]>
