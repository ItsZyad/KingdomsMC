##
## [KPM]
## Scripts in this file are used to validate that packages are in formatted correctly.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Dec 2023
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

IsPackageDescriptorValid_KPM:
    type: task
    definitions: descriptor[MapTag]|path[ElementTag(String)]
    description:
    - Ensures that the package.yml file (addon descriptor) is formatted correctly and has all
    - the required keys. It also runs a separate task which checks that all dependencies are
    - present.

    script:
    ## Ensures that the package.yml file (package descriptor) is formatted correctly and has all
    ## the required keys. It also runs a separate task which checks that all dependencies are
    ## present.
    ##
    ## descriptor : [MapTag]
    ## path       : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - if !<[descriptor].keys.get[1]> == package:
        - run GenerateInternalError def.category:GenericError def.message:<element[Package.yml file at path: <[path].color[red]> is invalid. Cannot find <&sq>package<&sq> key.]> def.silent:false
        - determine false

    # If the descriptor file has the 'package' key then it will automatically ignore the rest of
    # the file and treat the contents of 'package' as the file.
    - define descriptor <[descriptor].get[package]>

    - define requiredKeys <list[name|version|authors|dependencies]>

    - if !<[descriptor].keys.contains[<[requiredKeys]>]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Package.yml file at path: <[path].color[red]> does not have one or more required keys.<n>Required keys are: <[requiredKeys].separated_by[, ].color[red]>]> def.silent:false
        - determine false

    - if !<[descriptor].get[version].proc[IsVersionFormatValid_KPM]>:
        - run GenerateInternalError def.category:GenericError def.message:<element[Package.yml file at path: <[path].color[red]> has a non-Kingdoms-standard version number format. Please see the Kingdoms documentation for information on how to format version numbers correctly.]> def.silent:false
        - determine false

    - if <[descriptor].get[authors].object_type> != List:
        - run GenerateInternalError def.category:GenericError def.message:<element[Package.yml file at path: <[path].color[red]> has an invalid format for the <element[<&sq>authors<&sq>].color[red]> key. It must be in list format.]> def.silent:false
        - determine false

    - if <[descriptor].contains[licenses]> && <[descriptor].get[licenses].object_type> != List:
        - run GenerateInternalError def.category:GenericError def.message:<element[Package.yml file at path: <[path].color[red]> has an invalid format for the <element[<&sq>licenses<&sq>].red> key. It must be in list format.]> def.silent:false
        - determine false

    - if <[descriptor].keys.contains[dependencies|conflicts]>:

        # The addon obviously can't have dependencies that are also conflicts.
        - if <[descriptor].get[dependencies].keys.contains[<[descriptor].get[conflicts].keys>]>:
            - run GenerateInternalError def.category:GenericError def.message:<element[Package.yml file at path: <[path].color[red]> is invalid. Package cannot have a dependency that is also a conflict]> def.silent: false
            - determine false

    - determine true


PackageDependencyChecker_KPM:
    type: task
    definitions: descriptor[MapTag]|path[ElementTag(String)]
    description:
    - Checks if the addon with the provided descriptor and path has all its dependencies satisfied
    - and fills the server flag datahold.KPM.missingDependencies with a list of the names of the
    - missing dependencies.

    script:
    ## Checks if the addon with the provided descriptor and path has all its dependencies satisfied
    ## and fills the server flag datahold.KPM.missingDependencies with a list of the names of the
    ## missing dependencies.
    ##
    ## descriptor : [MapTag]
    ## path       : [ElementTag<String>]
    ##
    ## >>> [Void]

    # TODO: (future configurable) Add a config option which lets you prevent the loading of any
    # TODO/ addon with unsatisfied dependencies.

    - if !<[descriptor].keys.get[1]> == package:
        - run GenerateInternalError def.category:GenericError def.message:<element[Package.yml file at path: <[path].color[red]> is invalid. Cannot find <&sq>package<&sq> key.]> def.silent:false
        - stop

    # If the descriptor file has the 'package' key then it will automatically ignore the rest of
    # the file and treat the contents of 'package' as the file.
    - define descriptor <[descriptor].get[package]>

    - foreach <[descriptor].get[dependencies]> key:dependency as:versionInfo:

        # Find the dependency in question. Only edge-case is if it's kingdoms- in which
        # case just find the current kingdoms version from the YAML file.
        - if <[dependency]> == kingdoms:
            - yaml load:kingdoms.yml id:k
            - define currentVersion <yaml[k].read[version].split[ ].get[2]>
            - yaml id:k unload

        #- Note to self: I really need to move all the last remaining essential information
        #- out of the kingdoms.yml and into flag-based storage and do away with this
        #- outdated convention.

        - else:
            - foreach <server.flag[addons.addonList]> as:addon:
                - if <[addon].get[name]> == <[dependency]>:
                    - define currentVersion <[addon].get[version]>
                    - foreach stop

            - flag server datahold.KPM.missingDependencies.<[descriptor].get[name]>:->:<[dependency]>
            - foreach next

        # Format checking all version keys in one go.
        - foreach <[versionInfo]> as:version:
            - if !<[version].proc[IsVersionFormatValid_KPM]>:
                - run GenerateInternalError def.category:GenericError def.message:<element[Package.yml file at path: <[path].color[red]> is invalid. Dependency version number: <[version].color[red]> for dependency: <[dependency]> is not formatted correctly. Please see the Kingdoms documentation for information on how to format version numbers correctly.<n>]> def.silent:false
                - stop

        - if <[versionInfo].keys.contains[max-version]> && !<[versionInfo].keys.contains[min-version]>:
            - run IsVersionValid_KPM def.givenVersions:<list[<[currentVersion]>]> def.currentVersion:<[versionInfo].get[max-version]> save:validationResult

        - else if !<[versionInfo].keys.contains[max-version]> && <[versionInfo].keys.contains[min-version]>:
            - run IsVersionValid_KPM def.givenVersions:<list[<[versionInfo].get[min-version]>]> def.currentVersion:<[currentVersion]> save:validationResult

        - else if <[versionInfo].keys.contains[max-version|min-version]>:
            - run IsVersionValid_KPM def.givenVersions:<list[<[versionInfo].get[min-version]>|<[versionInfo].get[max-version]>]> def.currentVersion:<[currentVersion]> save:validationResult

        - else if <[versionInfo].keys.contains[version]>:
            - run IsVersionValid_KPM def.givenVersions:<list[<[versionInfo].get[version]>]> def.currentVersion:<[currentVersion]> save:validationResult

        - define validVersion <entry[validationResult].created_queue.determination.get[1].if_null[false]>

        - if !<[validVersion]>:
            - flag server datahold.KPM.missingDependencies.<[descriptor].get[name]>:->:<[dependency]>

    - if <server.flag[datahold.KPM.missingDependencies.<[descriptor].get[name]>].size> > 0:
        - narrate format:notice "Required dependenc(ies): <server.flag[datahold.KPM.missingDependencies.<[descriptor].get[name]>].comma_separated.color[red]> for addon: <[descriptor].get[name].color[gold]> are unsupported or outdated. Addon will remain indexed, but to activate it you must install valid dependenc(ies) or use <element[/addon load ~f].color[red]>.<n>"


IsVersionValid_KPM:
    type: task
    definitions: givenVersions|currentVersion
    description:
    - Helper script which makes version checking with recurring keys like min/max-version a bit easier and less repetitive. However, it does assume that versions are formatted in one of the following formats-
    - [RELEASE].[MAJOR].[MINOR].[PATCH]
    - [RELEASE].[MAJOR].[MINOR].[PATCH].[SUB-PATCH]
    - [RELEASE].[MAJOR].[MINOR]p[PATCH]
    - [RELEASE].[MAJOR].[MINOR]p[PATCH].[SUB-PATCH]
    - [RELEASE].[MAJOR].[MINOR]rc[RELEASE-CANDIDATE].[CANDIDATE-PATCH]
    - ...and will ignore any other formats, returning false by default, along with an unrecognized version error.
    - <red>[NOTE]
    - When providing 'givenVersions' with its list of versions, the first one should be the minimum version and the second one the maximum.

    script:
    ## Helper script which makes version checking with recurring keys like min/max-version a bit
    ## easier and less repetitive.
    ##
    ## However, it does assume that versions are formatted in one of the following formats:
    ##
    ## - <RELEASE>.<MAJOR>.<MINOR>.<PATCH>
    ## - <RELEASE>.<MAJOR>.<MINOR>.<PATCH>.<SUB-PATCH>
    ## - <RELEASE>.<MAJOR>.<MINOR>p<PATCH>
    ## - <RELEASE>.<MAJOR>.<MINOR>p<PATCH>.<SUB-PATCH>
    ## - <RELEASE>.<MAJOR>.<MINOR>rc<RELEASE-CANDIDATE>.<CANDIDATE-PATCH>
    ## - v<Any of the above>
    ##
    ## and will ignore any other formats, returning false by default, along with an unrecognized
    ## version error.
    ##
    ## givenVersions  : [ListTag<ElementTag<String>>]
    ## currentVersion : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - if <[givenVersions].size> == 1:
        - define minVersionComponents <[givenVersions].get[1].split[regex:<&bs>.|p|rc].parse_tag[<[parse_value].replace_text[regex:\D]>]>
        - define currVersionComponents <[currentVersion].split[regex:<&bs>.|p|rc].parse_tag[<[parse_value].replace_text[regex:\D]>]>
        - define minVersionComponents <[minVersionComponents].pad_right[<[currVersionComponents].size>].with[0]>
        - define currVersionComponents <[currVersionComponents].pad_right[<[minVersionComponents].size>].with[0]>

        - if <[minVersionComponents].get[1]> == any:
            - define minVersionComponents <list[<[currVersionComponents].get[1].sub[1]>]>

        - foreach <[currVersionComponents]> as:comp:
            - if <[comp]> >= <[minVersionComponents].get[<[loop_index]>]> && <[comp].add[<[minVersionComponents].get[<[loop_index]>]>]> != 0:
                - determine true

    - else if <[givenVersions].size> == 2:
        - define minVersionComponents <[givenVersions].get[1].split[regex:<&bs>.|p|rc].parse_tag[<[parse_value].replace_text[regex:\D]>]>
        - define maxVersionComponents <[givenVersions].get[2].split[regex:<&bs>.|p|rc].parse_tag[<[parse_value].replace_text[regex:\D]>]>
        - define currVersionComponents <[currentVersion].split[regex:<&bs>.|p|rc].parse_tag[<[parse_value].replace_text[regex:\D]>]>
        - define largestSize <list[<[minVersionComponents].size>|<[maxVersionComponents].size>|<[currVersionComponents].size>].highest[]>

        - if <[minVersionComponents].get[1]> == any:
            - define minVersionComponents <list[<[currVersionComponents].get[1].sub[1]>]>

        - if <[maxVersionComponents].get[1]> == any:
            - define minVersionComponents <list[<[currVersionComponents].get[1].add[1]>]>

        - define minVersionComponents <[minVersionComponents].pad_right[<[largestSize]>].with[0]>
        - define maxVersionComponents <[maxVersionComponents].pad_right[<[largestSize]>].with[0]>
        - define currVersionComponents <[currVersionComponents].pad_right[<[largestSize]>].with[0]>

        - define stopCheckingMax false
        - define stopCheckingMin false

        - foreach <[currVersionComponents]> as:comp:
            - if <[comp]> <= <[maxVersionComponents].get[<[loop_index]>]> && !<[stopCheckingMax]>:
                - if <[comp].add[<[maxVersionComponents].get[<[loop_index]>]>]> != 0:
                    - define stopCheckingMax true

            - if <[comp]> > <[minVersionComponents].get[<[loop_index]>]> && !<[stopCheckingMin]>:
                - if <[comp].add[<[minVersionComponents].get[<[loop_index]>]>]> != 0:
                    - define stopCheckingMin true

            - if <[stopCheckingMax]> && <[stopCheckingMin]>:
                - determine true

    - determine false


IsVersionFormatValid_KPM:
    type: procedure
    definitions: version
    description:
    - Helper function which checks if version numbers are formatted in a Kingdoms-standard manner.

    script:
    ## Helper function which checks if version numbers are formatted in a Kingdoms-standard manner.
    ##
    ## version : [ElementTag<String>]
    ##
    ## >>> [ElementTag<Boolean>]

    - define versionMatchRegex <element[(?&ltThreePoints&gt^(?&gtv&pipeV)?(?&gt(?&gt&bsd+&bs&dot)+&bsd+)$)&pipe(?&ltPatchIndicator&gt^(?&gtv&pipeV)?(?&gt&bsd+&bs&dot)+&bsd+p&bsd+(?&gt&bs&dot&bsd+)?$)&pipe(?&ltSinglePoint&gt^(?&gtv&pipeV)?&bsd+(?&gtp&bsd+)?$)&pipe(?&ltReleaseCandidate&gt^(?&gtv&pipeV)?(?&gt&bsd+&bs&dot)+&bsd+rc&bsd+(?&gt&bs&dot&bsd+)?$)]>

    - determine <[version].regex_matches[<[versionMatchRegex].unescaped>]>
