#!/usr/bin/expect -f

        set timeout 20
        set IPaddress [lindex $argv 0]
        set Username "netadmin"
        set Password "syntegra"
#        set Password "2smart4u"
        set Directory ~/Desktop/logs

        log_file -a $Directory/session_$IPaddress.log

        # "### /START-TELNET-SESSION/ IP: $IPaddress @ [exec date] ###\r"

        spawn telnet -l $Username $IPaddress

        expect "*assword: "

        send "$Password\r"

        expect "*>"

        send "term len 0\r"

        expect "*>"

        send "show ver\r"

        expect "*>"

        send "term len 25\r"

        expect "*>"

        send "exit\r"

        sleep 1

        # echo "\r### /END-TELNET-SESSION/ IP: $IPaddress @ [exec date] ###\r"

exit
