##
## [SCENARIO 1]
## This file contains all scripts relating to the royal election mechanic that'll apply on to
## Jalerad.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Jul 2024
## @Script Ver: v1.0
##
## ------------------------------------------END HEADER-------------------------------------------

SC1_JaleradKingChecker_Handler:
    type: world
    events:
        on time 0:
        - if <proc[GetMembers].context[jalerad].is_empty>:
            - stop

        - if <server.has_flag[kingdoms.scenario-1.kingdomList.jalerad.elections]>:
            - stop

        - if <proc[GetMembers].context[jalerad].filter_tag[<[filter_value].is_online>].is_empty>:
            - stop

        - define worldDay <context.world.time_full.in_days>

        - if <[worldDay].mod[7]> != 0:
            - stop

        - if <proc[GetKing].context[jalerad]> != null:
            - stop

        - flag server kingdoms.scenario-1.kingdomList.jalerad.elections

        - run AffectOfflinePlayers def.scriptName:SC1_InformPlayersOfElection def.playerList:<proc[GetMembers].context[jalerad]>
        - runlater SC1_SelectElectionWinner delay:3d


SC1_InformPlayersOfElection:
    type: task
    definitions: _playerList[ListTag(PlayerTag)]
    description:
    - INTENDED TO BE RAN BY `AffectOfflinePlayers`.
    - Will inform all of the provided players of the coming Jalerad election.
    - ---
    - → [Void]

    script:
    - if <server.has_flag[kingdoms.scenario-1.kingdomList.jalerad.elections]>:
        - define flagExpiration <duration[3d].formatted>

        - narrate format:callout "Jalerad has gone one in-game week without a king. An election has been automatically called by the Council of Lords. It will continue to run for the next: <[flagExpiration].color[aqua]>" targets:<[_playerList]>
        - narrate format:callout "Use the <element[/election vote (player)].color[gray]> command to vote for a player and <element[/election stand].color[gray]> to place yourself on the ticket." targets:<[_playerList]>


SC1_SelectElectionWinner:
    type: task
    description:
    - Will select a winner from all of the candidates in the current round of Jalerad elections.
    - If there are multiple candidates with the same number of votes then this script will initiate a runoff election between the top candidates.
    - ---
    - → [Void]

    script:
    ## Will select a winner from all of the candidates in the current round of Jalerad elections.
    ##
    ## If there are multiple candidates with the same number of votes then this script will
    ## initiate a runoff election between the top candidates.
    ##
    ## >>> [Void]

    - define candidateMap <server.flag[kingdoms.scenario-1.kingdomList.jalerad.elections.candidates]>
    - define topVotes 0
    - define topCandidates <list[]>

    - foreach <[candidateMap].sort_by_value[size]> key:candidate as:votes:
        - define voteCount <[votes].size>

        - if <[voteCount]> >= <[topVotes]>:
            - define topVotes <[voteCount]>
            - define topCandidates:->:<[candidate]>

    - if <[topCandidates].size> == 1:
        - define message <element[The election for Jalerad<&sq>s king has concluded with Lord <[topCandidates].get[1].as[player].name.color[aqua]> as the victor and new king! All hail their majesty!]>
        - run AffectOfflinePlayers def.playerList:<proc[GetMembers].context[jalerad]> def.scriptName:SC1_InformPlayersOfElectionResult def.message:<[message]>

        - flag server kingdoms.jalerad.king:<[topCandidates].get[1].as[player]>
        - flag server kingdoms.scenario-1.kingdomList.jalerad.elections:!

    - else:
        - flag server kingdoms.scenario-1.kingdomList.jalerad.elections
        - flag server kingdoms.scenario-1.kingdomList.jalerad.elections.runoffExclusions:<[candidateMap].keys.exclude[<[topCandidates]>]>
        - define flagExpiration <duration[2d].formatted>

        - define message <element[The election for Jalerad<&sq>s king has concluded in a draw between: <[topCandidates].separated_by[, ].color[light_purple]>. To break the tie, a runoff has been scheduled between the top candidates. You can vote in this election for the next: <[flagExpiration].color[aqua]>]>
        - run AffectOfflinePlayers def.playerList:<proc[GetMembers].context[jalerad]> def.scriptName:SC1_InformPlayersOfElectionResult def.message:<[message]>
        - runlater SC1_SelectElectionWinner delay:2d


SC1_InformPlayersOfElectionResult:
    type: task
    definitions: _playerList[ListTag(PlayerTag)]|message[ElementTag(String)]
    description:
    - INTENDED TO BE RAN BY `AffectOfflinePlayers`.
    - Will inform all of the provided players of the results of the Jalerad election.
    - ---
    - → [Void]

    script:
    ## INTENDED TO BE RAN BY <<AffectOfflinePlayers>>.
    ## Will inform all of the provided players of the results of the Jalerad election.
    ##
    ## >>> [Void]

    - if <server.has_flag[kingdoms.scenario-1.kingdomList.jalerad.elections]>:
        - narrate format:callout <[message]> targets:<[_playerList]>


SC1_KingElection_Command:
    type: command
    name: election
    usage: /election [candidates|vote|stand|duration] [...|(player)|...]
    description: This command handles everything to do with the Jalerad king elections, when they happen. You can only use this command if you are a member of Jalerad.
    tab complete:
    - define args <context.raw_args.split_args>
    - define kingdom <player.flag[kingdom]>

    - choose <[args].get[1].to_lowercase>:
        - case vote:
            - if <[args].size> > 1:
                - determine <list[yes|no]>

            - else:
                - determine <[kingdom].proc[GetMembers].parse_tag[<[parse_value].name>]>

        - default:
            - determine <list[...]>

    - determine <list[candidates|vote|stand|duration]>

    script:
    - define args <context.raw_args.split_args>
    - define kingdom <player.flag[kingdom]>

    - if <[kingdom]> != jalerad:
        - narrate format:callout "You cannot use this command if you are not in Jalerad!"
        - stop

    - if !<server.has_flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.elections]>:
        - narrate format:callout "There are currently no active elections in Jalerad."
        - stop

    - if !<script.data_key[<[args].get[1].to_titlecase>].exists>:
        - narrate format:callout "Unrecognized sub-command: <[args].get[1].color[red]>. Please try again."
        - stop

    - inject <script.name> path:Subcommands.<[args].get[1].to_titlecase>

    Subcommands:
        Vote:
        - define candidateName <[args].get[2]>
        - define candidate <server.players.filter_tag[<[filter_value].name.equals[<[candidateName]>]>].get[1].if_null[null]>

        - if <[candidate]> == null:
            - narrate format:callout "<[candidateName].color[red]> is not a valid player on this server. Please select a valid candidate to vote for"
            - stop

        - if <[candidate]> == <player>:
            - narrate format:callout "You cannot vote for yourself."
            - stop

        - if !<server.has_flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.elections.candidates.<[candidateName]>]>:
            - narrate format:callout "This player has not registered themselves as a candidate in this election."
            - stop

        - if <server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.elections.candidates.<[candidateName]>].contains[<player.uuid>]>:
            - narrate format:callout "You have already registered your vote for this candidate. You cannot vote twice!"
            - stop

        - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.elections.candidates.<[candidateName]>:->:<player.uuid>

        - narrate format:callout "You have successfully registered your vote for: <[candidateName].color[aqua]> to be king of Jalerad!"

        Candidates:
        - narrate format:callout "The candidates currently standing for election as king are:<n>- <server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.elections.candidates].keys.separated_by[<n>- ]>"

        Stand:
        - if <server.has_flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.elections.candidates.<player.uuid>]>:
            - narrate format:callout "You have already registered yourself in this election. You cannot register twice!"
            - stop

        - if <server.flag[kingdoms.scenario-1.kingdomList.<[kingdom]>.elections.runoffExclusions].if_null[<list[]>].contains[<player.uuid>]>:
            - narrate format:callout "You cannot register yourself in this runoff election since you were not one of the top two candidates in the last round of voting."
            - stop

        - flag server kingdoms.scenario-1.kingdomList.<[kingdom]>.elections.candidates.<player.uuid>:<list[]>

        - narrate format:callout "You have successfully registered yourself as a candidate in this election!"
        - narrate format:callout "Remember! You can still vote, as long as it's for other candidates."

        Duration:
        - define flagExpiration <server.flag_expiration[kingdoms.scenario-1.kingdomList.jalerad.elections].from_now.formatted>

        - narrate format:callout "The current election will end in: <[flagExpiration].color[aqua]>."
