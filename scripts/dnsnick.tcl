set dnshost(cmdchar) "."
set dnshost(cmdchar) "!"


#-----------------please don't CHANGE ANY OF THE FOLLOWING LINES----------------------
#bind pub - [string trim $dnshost(cmdchar)]dnns dns:res
bind pub n|n [string trim $dnshost(cmdchar)]amsg pub:amsg
bind pub - [string trim $dnshost(cmdchar)]User@host pub:host
bind pub - [string trim $dnshost(cmdchar)]version pub:ver
bind pub - [string trim $dnshost(cmdchar)]dnsnick dns:nick
bind pub - [string trim $dnshost(cmdchar)]dnsn dns:nick
bind raw * 311 raw:host
bind raw * 401 raw:fail

set dns_chan ""
set dns_host ""
set dns_nick ""
set dns_bynick ""

proc pub:host {nick uhost hand chan arg} {
global dns_chan
set dns_chan "$chan"
putserv "WHOIS [lindex $arg 0]"
}

proc raw:host {from signal arg} {
global dns_chan dns_nick dns_host dns_bynick
set dns_nick "[lindex $arg 1]"
set dns_host "*!*[lindex $arg 2]@[lindex $arg 3]"
foreach dns_say $dns_chan { puthelp "PRIVMSG $dns_say :14Host3 $dns_nick 14:3 \($dns_host\)." }
if {$dns_bynick == "oui"} {
                set hostip [split [lindex $arg 3] ]
                dnslookup $hostip resolve_rep $dns_chan $hostip
                set dns_bynick "non"
}
}

proc raw:fail {from signal arg} {
global dns_chan
set arg "[lindex $arg 1]"
foreach dns_say $dns_chan { puthelp "PRIVMSG $dns_say :14Gak ada OnLine si $arg" }
}

proc pub:ver {nick uhost hand chan text} {
putserv "PRIVMSG $chan : eggoez"
}

proc dns:res {nick uhost hand chan text} {
 if {$text == ""} {
            puthelp "NOTICE $nick :Gunakan: [string trim $dnshost(cmdchar)]dns <host or ip>"
        } else {
                set hostip [split $text]
                dnslookup $hostip resolve_rep $chan $hostip
        }
}

proc dns:nick {nick uhost hand chan arg} {
global dns_chan dns_bynick dnshost
 if {$arg == ""} {
 puthelp "NOTICE $nick :Gunakan: [string trim $dnshost(cmdchar)]dnsnick <nick>"
        } else {
set dns_chan "$chan"
set dns_bynick "oui"
putserv "WHOIS [lindex $arg 0]"
        }
}

proc resolve_rep {ip host status chan hostip} {
        if {!$status} {
                puthelp "privmsg $chan :15\[7DN7S15\]14 Ga ada hasil untuk3 $hostip"
        } elseif {[regexp -nocase -- $ip $hostip]} {
                puthelp "NOTICE $nick :15\[7DN7S15\]14 Hasil untuk3  $ip 14ke3 $host"
        } else {
                puthelp "privmsg $chan :15\[7DN7S15\]14 Hasil untuk3  $host 14ke3 $ip"
        }
}

putlog "Dns Nick Loaded by goezz"
