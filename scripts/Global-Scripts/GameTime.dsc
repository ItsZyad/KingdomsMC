##
## * All scripts that keep track of and allow
## * admin control over in-game time
##
## @Author: Zyad (ITSZYAD#9280)
## @Date: Nov 2021
## @Script Ver: v1.0
##
##ignorewarning invalid_data_line_quotes
## ----------------END HEADER-----------------

# These will change as I come up with names for the kingdoms months
MonthNames:
    type: data
    1: 'January'
    2: 'February'
    3: 'March'
    4: 'April'
    5: 'May'
    6: 'June'
    7: 'July'
    8: 'August'
    9: 'September'
    10: 'October'
    11: 'November'
    12: 'December'

GameTimeFreeze_Command:
    type: command
    name: freezecalendar
    usage: /freezecalendar
    description: "Allows admins to freeze the in-game calendar and time"
    permission: kingdoms.admin.freezecalendar
    alias: freezetime
    script:
    - if <server.has_flag[freezeCal]>:
        - flag server freezeCal:!

    - else:
        - flag server freezeCal

GameTimeUpdate:
    type: world
    events:
        on system time hourly every:24:
        - if !<server.has_flag[freezeCal]>:
            - flag server IGWeek:++
            - flag server WeekCounter:++

            - if <server.flag[IGWeek].is[MORE].than[4]>:
                - flag server IGWeek:1
                - flag server IGMonth:++

                - if <server.flag[WeekCounter].mod[48]> == 0:
                    - flag server IGYear:++