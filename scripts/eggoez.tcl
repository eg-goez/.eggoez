#########################################################################
#  # Script Name	: eggoez.tcl					#																
#  # Script Version	: t.c(£) v.6.9.2				#
#  # Author		: eggoez					#
#  # Release Date	: 05 Oktober 2010				#
#  # Reported any bug   : #ciut@allnetwork				#
#  # New Staff egGo     :  g0eZ						#
#  # E-mail 		: eggoez@yahoo.com				#
# "respect other people's work without changing the content of these "	#
#########################################################################
putlog "========================================"
putlog "          eggoez.tcl Part (2) Loaded        "
putlog "          eggoez@yahoo.com       "
putlog "         Editing 05 Oktober 2010       "  
putlog "             By g0eZ® egGo             "
putlog "Hargai Karya Orang Dgn Tidak Merubah Isi"
putlog "========================================"
putlog "........ Please Wait ......."
##########################
set max_length 200
set max_length_ban 5
set max_caps 15
set max_repeat 2
set inviter_ban 180
set badword_ban 5
set badwords {
""
"#?"
"j?nc?k"
"j?nc?x"
"ganc?k"
"ganc?x"
"orgasm"
"d?nc?k"
"d?nc?x"
"d?anc?k"
"d?anc?x"
"damput"
"dampot"
"ancok"
"ancuk"
"anc0k"
"d a n c ? k"
"j a n c ? k"
"fuck"
"kont?l"
"k?ont?l"
"konth?l"
"memek"
"memeq"
"memex"
"pepek"
"temp?k"
"temp?x"
"nenen"
"jembu*t"
"j?embu*t"
"jembo*t"
"j?embo*t"
"jemb0*t"
"j?emb0*t"
"jembo*d"
"j?embo*d"
"gath?l"
"kenthu"
"vagina"
"bawuk"
"bawok"
" itil "
" itel "
"ngacen?"
"nguacen?"
"ngwacen?"
"masturb"
"ngloco"
"pejuh"
"pejoh"
"nonok"
"kentu"
"coli"
" asu "
" kete "
"rakete"
"matamu"
"matane"
"kunam"
"kimpet"
"tempeek"
"anjin?"
"(?)*(?)*(?)*(?)*(?)*(?)"
":*-*:*-*:*-*:*-*:*-"
":*-*:*-*:*-*(?)*(?)*(?)"
""
}




################## g0eZ AddOns ##################

proc ccodes:filter {str} {
  regsub -all -- {\003([0-9]{1,2}(,[0-9]{1,2})?)?|\017|\037|\002|\026|\006|\007} $str "" str
  return $str
}

bind RAW - PRIVMSG msgcheck
bind RAW - NOTICE msgcheck

proc msgcheck {from key arg} {
 global botnick
 set arg [split $arg]
 set nick [lindex [split $from !] 0]
 set uhost [string range $from [expr [string first "!" $from]+1] e]
 set target [lindex $arg 0]
 if {![string match *#* $target]} { set hand "*" }
 if {[string match *#* $target]} { set hand [nick2hand $nick $target] }
 set text [string range [join [lrange $arg 1 end]] 1 end]
 if {[isbotnick $nick]} {return}
 if {[string match ** $text]} {
  set text [string range [join [lrange $arg 1 end]] 0 end]
 }
 split:pub:msg $nick $uhost $hand $target $text
}
proc split:pub:msg {nick uhost hand target text} {
# if {![string match *#* $target]} {priv:msg $nick $uhost $hand $target $text}
 if {[string match *#* $target]} {pub:msg $nick $uhost $hand $target $text}
}
proc pub:msg {nick uhost hand target text} {
 long:text $nick $uhost $hand $target $text
 caps:lock $nick $uhost $hand $target $text
 no:repeat $nick $uhost $hand $target $text
 no:badword $nick $uhost $hand $target $text
 split:cmd $nick $uhost $hand $target $text
}


proc long:text {nick uhost hand chan arg} {
 global max_length max_length_ban
 if {[matchattr $hand b] || [matchattr $hand f|f $chan] || [matchattr $hand mo|mo $chan]} { return }
 set banmask "*![lindex [split $uhost "@"] 0]@[lindex [split [maskhost $uhost] "@"] 1]"
 if {[string length $arg] >= $max_length} {
  if {[isop $nick $chan]} {
   putquick "KICK $chan $nick :jangan panjang² to $nick kasian yang akai hape itu loh.."
   return
  }
  putquick "KICK $chan $nick :Jangan panjang² donk!! Maks. $max_length karakter, ku banned $max_length_ban menit "
  newchanban $chan $banmask AutoBan LongText $max_length_ban sticky
  return
 }
}


proc caps:lock {nick uhost hand chan arg} {
 global max_caps
 set text [ccodes:filter $arg]
 set upper 0
 foreach i [split $text {}] { if [string match \[A-Z\] $i] { incr upper } }
 if {$upper == 0} { return }
 if {[string length $text] < $max_caps} { return }
 set capchar [string length $text]
 set number $upper/$capchar
 if {[matchattr $hand b] || [matchattr $hand f|f $chan] || [matchattr $hand mo|mo $chan]} { return }
 if {[expr 30 * $upper / $capchar] > $max_caps} {
  putquick "KICK $chan $nick :Ups.. CapsLock nya kecantol tuh.."
 }
}


proc no:repeat {nick uhost hand chan text} {
  global repeat_last repeat_num max_repeat
  set text [ccodes:filter $text]
  if {[matchattr $hand b] || [matchattr $hand f|f $chan] || [matchattr $hand mo|mo $chan]} { return }
  if [info exists repeat_last([set n [string tolower $nick]])] {
    if {[string compare [string tolower $repeat_last($n)] \
        [string tolower $text]] == 0} {
      if {[incr repeat_num($n)] >= ${max_repeat}} {
        putquick "KICK $chan $nick :walah.. jangan di ulang² pliss.."
        unset repeat_last($n)
        unset repeat_num($n)
      }
      return
    }
  }
  set repeat_num($n) 1
  set repeat_last($n) $text
}
bind nick - * repeat_nick
proc repeat_nick {nick uhost hand chan newnick} {
  if [matchattr $hand f] {return 0}
  global repeat_last repeat_num
  catch {set repeat_last([set nn [string tolower $newnick]]) \
         $repeat_last([set on [string tolower $nick]])}
  catch {unset repeat_last($on)}
  catch {set repeat_num($nn) $repeat_num($on)}
  catch {unset repeat_num($on)}
}
proc repeat_timr {} {
  global repeat_last
  catch {unset repeat_last}
  catch {unset repeat_num}
  timer 1 repeat_timr
}
if ![regexp repeat_timr [timers]] {
  timer 1 repeat_timr
}


proc no:badword {nick uhost handle channel args} {
 global badwords badword_ban
 set args [ccodes:filter $args] 
 foreach badword [string tolower $badwords] {     
  if {[string match *$badword* [string tolower $args]]} {
   set banmask "*![lindex [split $uhost "@"] 0]@[lindex [split [maskhost $uhost] "@"] 1]"
   set badreason "Kalau Ketik Sopan Dikit Bisa Kan!! banned $badword_ban menit"
   if {[matchattr $handle +f]} {
    putquick "NOTICE $nick :Begh Kalau Ketik Sopan Dikit Bisa Kan!! "
    return
   }
   if {[isop $nick $channel]} {
    putquick "KICK $channel $nick :ini @OP badung banget.. Ku Del ACC kamu ntar..!!"
    return
   }
   putquick "KICK $channel $nick :$badreason"
   newchanban $channel $banmask AutoBan BadWord $badword_ban sticky
  }
 }
}


bind part - * fuck:inviter
proc fuck:inviter {nick uhost hand chan reason} {
 global banmask inviter_ban
 set reason [ccodes:filter $reason]
 set banmask "*![lindex [split $uhost "@"] 0]@[lindex [split [maskhost $uhost] "@"] 1]"
 if {[string match *echo*invit* [string tolower $reason]]} {
  putquick "MODE $chan -b+b 4Fuck3!4echoX3@4inviter $banmask"
  newchanban $chan $banmask AutoBan echoXinviter $inviter_ban sticky
  putquick "KICK $chan :$nick Inviter Salah masuk euy.... "
 }
 if {[string match ** [string tolower $reason]]} {
  putquick "MODE $chan -b+b Banjir...... $banmask"
  newchanban $chan $banmask AutoBan tsunamer $inviter_ban sticky
  putquick "KICK $chan :$nick Tsunami kok disini!!"
 }
 if {[string match *#* [string tolower $reason]]} {
  putquick "MODE $chan -b+b Inviter Dilarang keras masuk sini $banmask"
  newchanban $chan $banmask AutoBan inviterjancok $inviter_ban sticky
  putquick "KICK $chan :$nick NakaL"
 }
}


set badnickban 30
set badnickkickreason "Gue gak suka Nick/Ident/Host Loe.. Banned $badnickban menit"

bind join - * join:badnick
bind nick - * change:badnick

proc join:badnick {nick uhost hand chan} {
 global botnick badwords badnickkickreason badnickban
 if {$nick == $botnick} {return}
 set ident [lindex [split $uhost "@"] 0]
 set host [lindex [split $uhost @] 1]
 foreach badnick [string tolower $badwords] {
  if {[matchattr $hand f]} { return }
  if {[string match *$badnick* [string tolower $nick]]} {
   putquick "KICK $chan $nick :$badnickkickreason"
   newchanban $chan *$badnick*!*@* AutoBan BadNick $badnickban sticky
   return 0
  }
  if {[string match *$badnick* [string tolower $ident]]} {
   putquick "KICK $chan $nick :$badnickkickreason"
   newchanban $chan *!*$badnick*@* AutoBan BadIdent $badnickban sticky
   return 0
  }
  if {[string match *$badnick* [string tolower $host]]} {
   putquick "KICK $chan $nick :$badnickkickreason"
   newchanban $chan *!*@*$badnick* AutoBan BadHost $badnickban sticky
   return 0
  }
 }
}
proc change:badnick {nick uhost hand chan newnick} {
 global botnick badwords badnickkickreason badnickban
 if {$nick == $botnick} {return}
 foreach badnick [string tolower $badwords] {
  if {[matchattr $hand f]} { return }
  if {[string match *$badnick* [string tolower $newnick]]} {
   putquick "KICK $chan $newnick :$badnickkickreason"
   newchanban $chan *$badnick*!*@* AutoBan BadNick $badnickban sticky
   return 0
  }
 }
}

proc split:cmd {nick uhost hand chan text} {
 global botnick
 set text [ccodes:filter $text]
 set cmd [lindex $text 0]
 set cmd [string tolower $cmd]
 set string [lrange $text 1 end]
 if {($cmd == ".dns") || ($cmd == "!dns")} { pub:dns $nick $uhost $hand $chan $text } 
 if {($cmd == ".dns6") || ($cmd == "!dns6") || ($cmd == "`dns6")} { pub:dns6 $nick $uhost $hand $chan $text } 
 if {($cmd == ".dwhois") || ($cmd == "!dwhois")} { pub:dwhois $nick $uhost $hand $chan $text } 
 if {($cmd == ".ip") || ($cmd == "!ip")} { pub:ipwhois $nick $uhost $hand $chan $text } 
 if {($cmd == ".port") || ($cmd == "!port")} { pub:cekport $nick $uhost $hand $chan $text } 
 if {($cmd == ".calc") || ($cmd == "!calc")} { pub:hitung $nick $uhost $hand $chan $text } 
 if {($cmd == ".jam") || ($cmd == "!jam") || ($cmd == ".time") || ($cmd == "!time")} { pub:time $nick $uhost $hand $chan $text } 
 if {($cmd == ".ping") || ($cmd == "!ping")} { pub:ping $nick $uhost $hand $chan $text } 
 if {($cmd == ".uptime") || ($cmd == "!uptime")} { pub:uptime $nick $uhost $hand $chan $text } 
 if {($cmd == ".whois") || ($cmd == "!whois")} { pub:whoisnick $nick $uhost $hand $chan $text } 
 if {($cmd == ".seen") || ($cmd == "!seen")} { pub:seen $nick $uhost $hand $chan $text } 
 if {($cmd == ".seennick") || ($cmd == "!seennick")} { pub:seennick $nick $uhost $hand $chan $text } 
 if {($cmd == ".seenstats") || ($cmd == "!seenstats")} { pub:seenstats $nick $uhost $hand $chan $text }
 if {($cmd == ".chanstats") || ($cmd == "!chanstats")} { pub:chanstats $nick $uhost $hand $chan $text }
 if {($cmd == ".lastspoke") || ($cmd == "!lastspoke")} { pub:lastspoke $nick $uhost $hand $chan $text }
 if {($cmd == ".idle") || ($cmd == "!idle")} { pub:cekidle $nick $uhost $hand $chan $text }
 if {($cmd == ".host") || ($cmd == "!host")} { pub:userhost $nick $uhost $hand $chan $text }
}


proc pub:dns {nick uhost hand chan text} {
 set hostip [lindex $text 1]
 if {$hostip == ""} {
  putquick "NOTICE $nick :Perintah : .dns <host/ip>"
  } else {
  dnslookup $hostip dns:rep $chan $hostip
 }
}
proc dns:rep {ip host status chan hostip} {
 if {!$status} {
  putquick "privmsg $chan :15\[4DN4S15\]14 Ga ada hasil untuk3 $hostip "
 } elseif {[regexp -nocase -- $ip $hostip]} {
  putquick "privmsg $chan :15\[6DN6S15\]14 Hasil untuk3 $ip 14ke3 $host "
 } else {
  putquick "privmsg $chan :15\[6DN6S15\]14 Hasil untuk3 $host 14ke3 $ip "
 }
}


proc pub:dns6 {nick uhost hand chan text} {
 global botnick
 set cmd "nslookup"
 set orig [lindex $text 1]
 if {$orig == ""} {
  putquick "NOTICE $nick :Perintah : 4.dns6 <host/ipv6>"
  return
 }
 if {[string match "*:*.*" $orig]} {
  putquick "PRIVMSG $chan :15\[4DN4S15\]3 $orig 14is invalid host/ipv6 "
  return
 }
 if {[string match "*.*:*" $orig]} {
  putquick "PRIVMSG $chan :15\[4DN4S15\]3 $orig 14is invalid host/ipv6 "
  return
 }
 catch {exec $cmd -type=any $orig} input
 set result ""
 set fnd 0
 foreach line [split $input "\n"] {
  if {[string match "*ip6.\[int|arpa\]*name*=*" $line] || [string match "*IPv6 address*=*" $line]} {
   set result [string trim [lindex [split $line "="] 1]]
   break
  } elseif {[string match "*has AAAA*" $line]} {
   set result [lindex [split $line] [expr [llength [split $line]] - 1]]
   break
  }
 }
 if {$result == ""} {
  putquick "PRIVMSG $chan :15\[6DN6S15\]14 Ga ada Hasil untuk3 $orig "
  return
 }
 putquick "PRIVMSG $chan :15\[6DN6S15\]14 Hasil untuk3 $orig 14ke3 $result "
 return
}



proc pub:dwhois {nick host handle chan text} {
 set server "isfree.schlundtec.com"
 set port 80
 set l 14
 set i 0
 set path "/cgi-bin/isfree.cgi?nodesign=1&domain=[lindex $text 1]"
 set sockdw [socket $server $port]
 puts $sockdw "GET $path HTTP/1.0"
 puts $sockdw "User.Agent:Mozilla"
 puts $sockdw "Host: $server"
 puts $sockdw ""
 flush $sockdw
 while {$i <= $l} {
  gets $sockdw linedw
  if {[string match "*Domain*frei*" $linedw]} {
   putquick "PRIVMSG $chan :15\[4DWHOI4S15\]14 Domain3 [lindex $text 1] 14Belum Terdaftar!"
   close $sockdw
   return 0
  }
  if {[string match "*Domain*registriert*" $linedw]} {
   gets $sockdw
   putquick "PRIVMSG $chan :15\[12DWhoI12S15\]14 Informasi untuk3 [lindex $text 1] 14:3 [html [gets $sockdw]]14,3 [html [gets $sockdw]]14,3 [html [gets $sockdw]]14,3 [html [gets $sockdw]]14,3 [html [gets $sockdw]] "
   close $sockdw
   return 0
 }
 incr i
 }
 close $sockdw
}
proc html { text } {
 regsub -all "</TD>" $text "" text
 regsub -all "</FONT>" $text "" text
 regsub -all "	" $text "" text
 regsub -all "&uuml;" $text "ü" text
 regsub -all "&ouml;" $text "ö" text
 regsub -all "&auml;" $text "ä" text
 regsub -all "&Uuml;" $text "Ü" text
 regsub -all "&Ouml;" $text "Ö" text
 regsub -all "&Auml;" $text "Ä" text
 regsub -all "&szlig;" $text "ß" text
 regsub -all "&quot;" $text "\"" text
 regsub -all "<tb>" $text "" text
 regsub -all "<font" $text "" text
 regsub -all "size=\"2\"" $text "" text
 regsub -all "face=\"Verdana,Arial,Helvetica,Geneva\">" $text "" text
 regsub -all "<br>" $text "" text
 regsub -all "&nbsp;" $text "" text
 regsub -all "</font>" $text "" text
 regsub -all "<td>" $text "" text
 regsub -all "</td>" $text "" text
 regsub -all "<b>" $text "" text
 regsub -all "</b>" $text "" text
 regsub -all "</pre>" $text "" text
 return $text
}



set whoisinfo(port) 43
set whoisinfo(ripe) "whois.ripe.net"
set whoisinfo(arin) "whois.arin.net"
set whoisinfo(apnic) "whois.apnic.net"
set whoisinfo(lacnic) "whois.lacnic.net"
set whoisinfo(afrinic) "whois.afrinic.net"
proc whoisinfo_setarray {} {
 global query
 set query(netname) "(none)"
 set query(country) "(none)"
 set query(orgname) "(none)"
 set query(orgid) "(none)"
 set query(range) "(none)"
}
proc whoisinfo_display { chan } {
 global query
 putquick "PRIVMSG $chan :15\[3I12P15\]14 Jarak :3 $query(range) 15- 14NamaNet :3 $query(netname) 15- 14Organisasi :3 $query(orgname) 15- 14Negara :3 $query(country) "
}
proc pub:ipwhois {nick uhost handle chan search} {
 set search [lindex $search 1]
 if {$search == ""} {
  putquick "NOTICE $nick :12ip-nya berapa g0eZ?"
  return
 }
 global whoisinfo
 global query
 whoisinfo_setarray 
 if {[whoisinfo_whois $whoisinfo(arin) $search]==1} {
  if {[string compare [string toupper $query(orgid)] "RIPE"]==0} {
   if {[whoisinfo_whois $whoisinfo(ripe) $search]==1} {
    whoisinfo_display $chan
   }
  } elseif {[string compare [string toupper $query(orgid)] "APNIC"]==0} {
   if {[whoisinfo_whois $whoisinfo(apnic) $search]==1} {
    whoisinfo_display $chan
   }
  } elseif {[string compare [string toupper $query(orgid)] "LACNIC"]==0} {
   if {[whoisinfo_whois $whoisinfo(lacnic) $search]==1} {
    whoisinfo_display $chan
   }
  } elseif {[string compare [string toupper $query(orgid)] "AFRINIC"]==0} {
   if {[whoisinfo_whois $whoisinfo(afrinic) $search]==1} {
    whoisinfo_display $chan
   }
 } else {
   whoisinfo_display $chan
  }
 } else {
  if { [info exist query(firstline)] } {
   putquick "PRIVMSG $chan :$query(firstline)"
  } else {
   putquick "PRIVMSG $chan :4Gagal!!"
  }
 }
}

proc whoisinfo_whois {server search} {
 global whoisinfo
 global query
 set desccount 0
 set firstline 0
 set reply 0
# putlog "Whois: $server:$whoisinfo(port) -> $search"
 if {[catch {set sock [socket -async $server $whoisinfo(port)]} sockerr]} {
  putquick "PRIVMSG $chan :4Gagal:3 $sockerr. 14Koneksi Gue Lagi Lemotz."
  close $sock
  return 0
 }
 puts $sock $search
 flush $sock
 while {[gets $sock whoisline]>=0} {
# putlog "Whois: $whoisline"
  if {[string index $whoisline 0]!="#" && [string index $whoisline 0]!="%" && $firstline==0} {
   if {[string trim $whoisline]!=""} {
    set query(firstline) [string trim $whoisline]
    set firstline 1
   }
  }
  if {[regexp -nocase {netname:(.*)} $whoisline all item]} {
   set query(netname) [string trim $item]
   set reply 1
  } elseif {[regexp -nocase {owner-c:(.*)} $whoisline all item]} {
   set query(netname) [string trim $item]
   set reply 1 
  } elseif {[regexp -nocase {country:(.*)} $whoisline all item]} {
   set query(country) [string trim $item]
   set reply 1
  } elseif {[regexp -nocase {descr:(.*)} $whoisline all item] && $desccount==0} {
   set query(orgname) [string trim $item]
   set desccount 1
   set reply 1
  } elseif {[regexp -nocase {orgname:(.*)} $whoisline all item]} {
   set query(orgname) [string trim $item]
   set reply 1
  } elseif {[regexp -nocase {owner:(.*)} $whoisline all item]} {
   set query(orgname) [string trim $item]
   set reply 1
  } elseif {[regexp -nocase {orgid:(.*)} $whoisline all item]} {
   set query(orgid) [string trim $item]
   set reply 1
  } elseif {[regexp -nocase {inetnum:(.*)} $whoisline all item]} {
   set query(range) [string trim $item]
   set reply 1
  } elseif {[regexp -nocase {netrange:(.*)} $whoisline all item]} {
   set query(range) [string trim $item]
   set reply 1
  }
 }
 close $sock
 return $reply
}



set portchk_setting(read) 1
proc pub:cekport {nick uhost hand chan text} {
 global portchk_setting
 set host [lindex [split $text] 1]
 set port [lindex [split $text] 2]
 if {$port == ""} {
  putquick "NOTICE $nick :PErintah :4 $portchk_setting(cmd_pub) 7<host> <port> "
  return
 }
 if {[catch {set sock [socket -async $host $port]} error]} {
  putquick "PRIVMSG $chan :15\[3POR3T15\]14 Koneksi ke3 $host 14Port3 $port 4Gak bisa bos "
 } else {
  set timerid [utimer 15 [list portchk_timeout_pub $chan $sock $host $port]]
  fileevent $sock writable [list portchk_connected_pub $chan $sock $host $port $timerid]
 }
}
proc portchk_connected {idx sock host port timerid} {
 killutimer $timerid
 set error [fconfigure $sock -error]
 if {$error != ""} {
  close $sock
  putdcc $idx "15\[4PoR4T15\]14 Koneksi ke3 $host 14Port3 $port 4Gaswat \([string totitle $error]\) "
 } else {
  fileevent $sock writable {}
  fileevent $sock readable [list portchk_read $idx $sock $host $port]
  putdcc $idx "15\[3PoR3T15\]14 Koneksi ke3 $host 14Port3 $port 10Berangkat Bos"
 }
}
proc portchk_timeout {idx sock host port} {
 close $sock
 putdcc $idx "15\[5PoR5T15\]14 Koneksi ke3 $host 14Port3 $port 5Lagi Time Out Bos"
}
proc portchk_read {idx sock host port} {
 global portchk_setting
 if {$portchk_setting(read)} {
  if {[gets $sock read] == -1} {
   putdcc $idx "15\[3PoR3T15\]14 Koneksi ke3 $host 14Port3 $port 12Gagal Sudah Ditutup Bos"
   close $sock
  } else {
   putdcc $idx "$host \($port\) > $read"
  }
 } else {
  close $sock
 }
}
proc portchk_connected_pub {chan sock host port timerid} {
 killutimer $timerid
 set error [fconfigure $sock -error]
 if {$error != ""} {
  close $sock
  putquick "PRIVMSG $chan :15\[4PoR4T15\]14 Koneksi ke3 $host 14Port3 $port 4Gagal Bos"
 } else {
  fileevent $sock writable {}
  fileevent $sock readable [list portchk_read_pub $chan $sock $host $port]
  putquick "PRIVMSG $chan :15\[3PoR3T15\]14 Koneksi ke3 $host 14Port3 $port 10Berangkat Bos"
 }
}
proc portchk_timeout_pub {chan sock host port} {
 close $sock
 putquick "PRIVMSG $chan :15\[5PoR5T15\]14 Koneksi ke3 $host 14Port3 $port 5Lagi Time Out Bos"
}
proc portchk_read_pub {sock} {
 global portchk_setting
 if {!$portchk_setting(read)} {
  close $sock
 } elseif {[gets $sock read] == -1} {
  putquick "PRIVMSG $chan :15\[3PoR3T15\]14 Koneksi ke3 $host 14Port3 $port 12Gagal Sudah Ditutup Bos "
  close $sock
 }
}

bind ctcr - PING pingreply
proc pub:ping {nick uhost hand chan text} {
 pingnick $nick
 return 0
}
proc pingnick {nick} {
 putquick "PRIVMSG $nick :\001PING [expr {abs([clock clicks -milliseconds])}]\001"
}
proc pingreply {nick uhost hand dest key args} {
 set pingnum [lindex $args 0]
 set pingserver [lindex [split $::server :] 0]
 if {[regexp -- {^-?[0-9]+$} $pingnum]} {
  putquick "NOTICE $nick :15Kamu Lag3 [expr {abs([expr [expr {abs([clock clicks -milliseconds])} - $pingnum] / 1000.000])}] 15detik, jika diukur dari3 $pingserver "
 }
}


proc pub:uptime {nick uhost hand chan arg} {
  putquick "PRIVMSG $chan :[zombieUp]"
}
proc zombieUp {} {
  set ::time(uptime) [expr [clock seconds]-$::uptime]
  set ::time(minggu) [expr $::time(uptime)/604800]
  set ::time(uptime) [expr $::time(uptime)-$::time(minggu)*604800]
  set ::time(hari) [expr $::time(uptime)/86400]
  set ::time(uptime) [expr $::time(uptime)-$::time(hari)*86400]
  set ::time(jam) [expr $::time(uptime)/3600]
  set ::time(uptime) [expr $::time(uptime)-$::time(jam)*3600]
  set ::time(menit) [expr $::time(uptime)/60]
  set ::time(uptime) [expr $::time(uptime)-$::time(menit)*60]
  set ::time(detik) $::time(uptime)
  set ::time(return) " $::time(minggu) minggu $::time(hari) hari $::time(jam) jam $::time(menit) menit $::time(detik) detik "
  return $::time(return)
}




proc pub:whoisnick { nickname hostname handle channel arguments } {
 global whois
 set target [lindex $arguments 1]
 if {$target == ""} {
 putquick "PRIVMSG $channel :Perintah : .whois <nick>"
 return 0
 }
 if {$target == "*"} {
 putquick "KICK $channel $nickname :wedew gak usah badung ah ketik aja 4//timercok 0 0 whois * "
 return 0
 }
 if { ![isop $nickname $channel] } {
  putquick "NOTICE $nickname :.whois hanya untuk @OP aja!"
  return 0
 }
 if {[string length $target] >= "31"} {
 putquick "PRIVMSG $channel :Panjang amat nick nya"; return
 }
 putquick "WHOIS $target $target"
 set ::whoischannel $channel
 bind RAW - 402 whois:nosuch
 bind RAW - 311 whois:info
 bind RAW - 319 whois:channels
 bind RAW - 301 whois:away
 bind RAW - 313 whois:ircop
 bind RAW - 330 whois:auth
 bind RAW - 317 whois:idle
 bind RAW - 275 whois:ssl
 bind RAW - 338 whois:actual
 bind RAW - 312 whois:server
 bind RAW - 716 whois:gmode
 bind RAW - 318 end:of:whois
}

proc whois:putmsg { channel arguments } { putquick "PRIVMSG $channel :$arguments" }

proc whois:info { from keyword arguments } {
set channel $::whoischannel
set ::nickname [lindex [split $arguments] 1]
set ident [lindex [split $arguments] 2]
set host [lindex [split $arguments] 3]
set realname [string range [join [lrange $arguments 5 end]] 1 end]
whois:putmsg $channel "$::nickname is $ident@$host * $realname"
}

proc whois:ircop { from keyword arguments } {
set channel $::whoischannel
set target $::nickname
whois:putmsg $channel "$target is an IRC Operator"
}

proc whois:away { from keyword arguments } {
set channel $::whoischannel
set target $::nickname
set awaymessage [string range [join [lrange $arguments 2 end]] 1 end]
whois:putmsg $channel "$target is away: $awaymessage"
}

proc whois:channels { from keyword arguments } {
set channel $::whoischannel
set channels [string range [join [lrange $arguments 2 end]] 1 end]
set target $::nickname
whois:putmsg $channel "$target on $channels"
}

proc whois:auth { from keyword arguments } {
set channel $::whoischannel
set target $::nickname
set authname [lindex [split $arguments] 2]
whois:putmsg $channel "$target is authed as $authname"
}

proc whois:idle { from keyword arguments } {
set channel $::whoischannel
set target $::nickname
set idletime [lindex [split $arguments] 2]
set signon [lindex [split $arguments] 3]
whois:putmsg $channel "$target has been idle for [duration $idletime]. signon time [ctime $signon]"
}

proc whois:ssl { from keyword arguments } {
set channel $::whoischannel
set target $::nickname
whois:putmsg $channel "$target is connected via Secure Connection (SSL)"
}

proc whois:gmode { from keyword arguments } {
set channel $::whoischannel
set target $::nickname
whois:putmsg $channel "$target is in +g mode (server side ignore)"
}

proc whois:actual { from keyword arguments } {
set channel $::whoischannel
set target $::nickname
set actualhost [lindex [split $arguments] 2]
whois:putmsg $channel "$target actually using host $actualhost"
}

proc whois:server { from keyword arguments } {
set channel $::whoischannel
set target $::nickname
set servers [lindex [split $arguments] 2]
set serverdesc [string range [join [lrange $arguments 3 end]] 1 end]
whois:putmsg $channel "$target using $servers $serverdesc"
}

proc whois:nosuch { from keyword arguments } {
set channel $::whoischannel
whois:putmsg $channel "Gak ada OL"
close:whois:bind jancok matane picek
}

proc end:of:whois { from keyword arguments } {
 set channel $::whoischannel
 set target $::nickname
 whois:putmsg $channel "$target End of /WHOIS list."
 close:whois:bind jancok matane picek
}
proc close:whois:bind { from key args } {
 unbind RAW - 402 whois:nosuch
 unbind RAW - 311 whois:info
 unbind RAW - 319 whois:channels
 unbind RAW - 301 whois:away
 unbind RAW - 313 whois:ircop
 unbind RAW - 330 whois:auth
 unbind RAW - 317 whois:idle
 unbind RAW - 275 whois:ssl
 unbind RAW - 338 whois:actual
 unbind RAW - 312 whois:server
 unbind RAW - 716 whois:gmode
 unbind RAW - 318 end:of:whois
}


proc pub:userhost {nick uhost hand chan text} {
 set ::hostchan $chan
 set target [lindex $text 1]
 if {$target == "*"} { putquick "kick $chan $nick :Gak usah Badung ah!!" ; return }
 bind RAW - 311 user:host
 putquick "whois $target"
}
proc user:host {from key args} {
 set chan $::hostchan
 set nick [lindex [split $args] 1]
 set ident [lindex [split $args] 2]
 set host [lindex [split $args] 3]
 putquick "PRIVMSG $chan :14Host3 $nick 14adalah 3\($ident15@03$host\) "
 unbind RAW - 311 user:host
}


proc pub:cekidle {nick uhost hand chan text} {
 set ::idlechan $chan
 set text [lindex $text 1]
 bind RAW - 317 idle:cek
 putquick "whois $text :$text"
}
proc idle:cek { from key args } {
 set nick [lindex [split $args] 1]
 set chan $::idlechan
 set idletime [lindex [split $args] 2]
 set signon [lindex [split $args] 3]
 putquick "PRIVMSG $chan :3$nick 14 Has Idle:3 \( [duration $idletime] 14«»3 SignOn: [ctime $signon]\)"
 unbind RAW - 317 idle:cek
}
#seen
set bs(limit) 50000
set bs(nicksize) 30
set bs(no_pub) ""
set bs(quiet_chan) "#dorami #ciut #kopiku #rhapsody #amunisi #bintang_jatuh #eggo"
set bs(no_log) "#"
set bs(log_only) ""
set bs(cmdchar) "."
set bs(flood) 5:5
set bs(ignore) 1
set bs(ignore_time) 1
set bs(smartsearch) 1
set bs(logqueries) 1
set bs(path) ""

proc pub:seen {nick uhost hand chan text} {
 set siapa [lindex $text 1]
 if {$siapa == "*"} { putquick "NOTICE $nick :14ndak usah mainin bot!! " ; return }
 bs_pubreq $nick $uhost $hand $chan $siapa 0
}
proc pub:seennick {nick uhost hand chan text} {
 set siapa [lindex $text 1]
 if {$siapa == "*"} { putquick "NOTICE $nick :14ndak usah mainin bot!!" ; return }
 bs_pubreq $nick $uhost $hand $chan $siapa 1
}
proc pub:seenstats {nick uhost hand chan args} {
 global bs
 if {[matchattr $hand +m]} {
  if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) [string tolower $chan]] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only)  [string tolower $chan]] == -1)} {return 0}
  if {[lsearch -exact $bs(quiet_chan) [string tolower $chan]] >= 0} {set target "notice $nick"} {set target "privmsg $chan"} ; puthelp "$target :[bs_stats]" ;  return 1
 }
}
proc pub:chanstats {nick uhost hand chan arg} {
 global bs
 if {[matchattr $hand +m]} {
  set chan [string tolower $chan]
  if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) $chan] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] ==  -1)} {return 0}
  if {[lsearch -exact $bs(quiet_chan) $chan] >= 0} {set target "notice $nick"} {set target "privmsg $chan"}
  if {[lindex $arg 1] != ""} {set chan [lindex $arg 1]} ; puthelp "$target :[bs_chanstats $chan]" ; return $bs(logqueries)
 }
}
proc pub:lastspoke {nick uhost hand chan args} {
  global bs botnick bs_botidle
  set chan [string tolower $chan] ; if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) $chan] >= 0 || ($bs(log_only) != "" && [lsearch -exact  $bs(log_only) $chan] == -1)} {return 0}
  if {[lsearch -exact $bs(quiet_chan) $chan] >= 0} {set target "notice $nick"} {set target "privmsg $chan"}
  set data [lindex [bs_filt [join $args]] 1]
  set ldata [string tolower $data] 
  if {[string match *\** $data]} {
    set chanlist [string tolower [chanlist $chan]]
    if {[lsearch -glob $chanlist $ldata] > -1} {set data [lindex [chanlist $chan] [lsearch -glob $chanlist $ldata]]}
  }
  if {[onchan $data $chan]} { 
    if {$ldata == [string tolower $botnick]} {puthelp "$target :Hai.. $nick" ; return 1}
    set time [getchanidle $data $chan] ; set bottime [expr ([unixtime] - $bs_botidle($chan))/60]
    if {$time < $bottime} {
      if {$time > 0} {set diftime [bs_when [expr [unixtime] - $time*60 -15]]} {set diftime "kurang lebih semenit"}
      puthelp "$target :$data terakhir berbicara di $chan $diftime yang lalu."
    } {
      set diftime [bs_when $bs_botidle($chan)]
      puthelp "$target :$data tidak berbicara apapun sejak aku join $chan $diftime yang lalu."
    }
  }
  return 1
} 

proc bs_filt {data} {
  regsub -all -- \\\\ $data \\\\\\\\ data ; regsub -all -- \\\[ $data \\\\\[ data ; regsub -all -- \\\] $data \\\\\] data
  regsub -all -- \\\} $data \\\\\} data ; regsub -all -- \\\{ $data \\\\\{ data ; regsub -all -- \\\" $data \\\\\" data ; return $data
}
proc bs_flood_init {} {
  global bs bs_flood_array ; if {![string match *:* $bs(flood)]} {putlog "$bs(version): var bs(flood) not set correctly." ; return}
  set bs(flood_num) [lindex [split $bs(flood) :] 0] ; set bs(flood_time) [lindex [split $bs(flood) :] 1] ; set i [expr $bs(flood_num) - 1]
  while {$i >= 0} {set bs_flood_array($i) 0 ; incr i -1 ; }
} ; bs_flood_init
proc bs_flood {nick uhost} {
  global bs bs_flood_array ; if {$bs(flood_num) == 0} {return 0} ; set i [expr $bs(flood_num) - 1]
  while {$i >= 1} {set bs_flood_array($i) $bs_flood_array([expr $i - 1]) ; incr i -1} ; set bs_flood_array(0) [unixtime]
  if {[expr [unixtime] - $bs_flood_array([expr $bs(flood_num) - 1])] <= $bs(flood_time)} {
    putlog "$bs(version): Flood detected from $nick." ; if {$bs(ignore)} {newignore [join [maskhost *!*[string trimleft $uhost ~]]] $bs(version) flood  $bs(ignore_time)} ; return 1
  } {return 0}
}
if {[lsearch -exact [bind time -|- "* * * * *"] bs_timedsave] > -1} {unbind time -|- "* * * * *" bs_timedsave} ; #backup frequency can be lower
proc bs_read {} {
  global bs_list userfile bs
  if {![string match */* $userfile]} {set name [lindex [split $userfile .] 0]} {
    set temp [split $userfile /] ; set temp [lindex $temp [expr [llength $temp]-1]] ; set name [lindex [split $temp .] 0]
  }
  if {![file exists $bs(path)data.seen]} {
    if {![file exists $bs(path)data.seen.bak]} {
      putlog "--- Old seen database not found!" ; putlog "--- If this is the first time you've run the script, don't worry." ; putlog "--- If there *should* be a  database file from past runs of this script... worry." ; return
    } {exec cp $bs(path)data.seen.bak $bs(path)data.seen ; putlog "--- Old seen database not found! Using backup data."}
  } ; set fd [open $bs(path)data.seen r]
  set bsu_ver "" ; set break 0
  while {![eof $fd]} {
    set inp [gets $fd] ; if {[eof $fd]} {break} ; if {[string trim $inp " "] == ""} {continue}
    if {[string index $inp 0] == "#"} {set bsu_version [string trimleft $inp #] ; continue}
    if {![info exists bsu_version] || $bsu_version == "" || $bsu_version < $bs(updater)} {
      putlog "--- Updating database to new version of bseen..."
#bugfix (b) - loading the wrong updater version
      if {[source scripts/bseen_updater1.4.2.tcl] != "ok"} {set temp 1} {set temp 0}
      if {$temp || [bsu_go] || [bsu_finish]} {
        putlog "--- A serious problem was encountered while updating the bseen database."
        if {$temp} {putlog "--- The updater script could not be found."}
        putlog "--- It is *not* safe to run the bot w/ a bseen database that is not matched to this version of bseen."
        putlog "--- If you can't find the problem, the only option is to remove the data.seen and data.seen.bak files.  Then restart the bot."
        putlog "--- Because this is a potential crash point in the bot, the bot will now halt." ; die "critical error in bseen encountered"
      } ; set break 1 ; break
    }
    set nick [lindex $inp 0] ; set bs_list([string tolower $nick]) $inp
  } ; close $fd
  if {$break} {bs_read} {putlog "--- Selesai ngeload [array size bs_list] data."}
}
proc bs_update {} {
  global bs
  putlog "--- A new version of bseen is dynamically being loaded."
  putlog "--- Verifying the integrity of the database across versions..."
  bs_save ; bs_read
}
set bs(updater) 10402 ; set bs(version) bseen1.4.2c
if {[info exists bs_list]} {
#a rehash was done
  if {[info exists bs(oldver)]} {
    if {$bs(oldver) < $bs(updater)} {bs_update} ;# old ver found
  } {bs_update} ;# pre- 1.4.0
}
set bs(oldver) $bs(updater)
if {![info exists bs_list] || [array size bs_list] == 0} {putlog "--- Loading seen database..." ; bs_read}
bind time - "* * * * *" bs_timedsave
proc bs_timedsave {min b c d e} {bs_save}
proc bs_save {} {
  global bs_list userfile bs ; if {[array size bs_list] == 0} {return}
  if {![string match */* $userfile]} {set name [lindex [split $userfile .] 0]} {
    set temp [split $userfile /] ; set temp [lindex $temp [expr [llength $temp]-1]] ; set name [lindex [split $temp .] 0]
  }
  if {[file exists $bs(path)data.seen]} {catch {exec cp -f $bs(path)data.seen $bs(path)data.seen.bak}}
  set fd [open $bs(path)data.seen w] ; set id [array startsearch bs_list]
  puts $fd "#$bs(updater)"
  while {[array anymore bs_list $id]} {set item [array nextelement bs_list $id] ; puts $fd "$bs_list($item)"} ; array donesearch bs_list $id ; close $fd
}
#bugfix -- support new PART in egg1.5.x+
if {[string trimleft [lindex $version 1] 0] >= 1050000} {
  bind part -|- * bs_part  
} {
  if {[lsearch -exact [bind part -|- *] bs_part] > -1} {unbind part -|- * bs_part}
  bind part -|- * bs_part_oldver
}
proc bs_part_oldver {a b c d} {bs_part $a $b $c $d ""}
#bugfix - new bs_part proc
proc bs_part {nick uhost hand chan reason} {bs_add $nick "[list $uhost] [unixtime] part $chan [split $reason]"}
bind join -|- * bs_join
proc bs_join {nick uhost hand chan} {bs_add $nick "[list $uhost] [unixtime] join $chan"}
bind sign -|- * bs_sign
proc bs_sign {nick uhost hand chan reason} {bs_add $nick "[list $uhost] [unixtime] quit $chan [split $reason]"}
bind kick -|- * bs_kick
proc bs_kick {nick uhost hand chan knick reason} {bs_add $knick "[getchanhost $knick $chan] [unixtime] kick $chan [list $nick] [list $reason]"}
bind nick -|- * bs_nick
proc bs_nick {nick uhost hand chan newnick} {set time [unixtime] ; bs_add $nick "[list $uhost] [expr $time -1] nick $chan [list $newnick]" ; bs_add $newnick  "[list $uhost] $time rnck $chan [list $nick]"}
bind splt -|- * bs_splt
proc bs_splt {nick uhost hand chan} {bs_add $nick "[list $uhost] [unixtime] splt $chan"}
bind rejn -|- * bs_rejn
proc bs_rejn {nick uhost hand chan} {bs_add $nick "[list $uhost] [unixtime] rejn $chan"}
bind chon -|- * bs_chon
proc bs_chon {hand idx} {foreach item [dcclist] {if {[lindex $item 3] != "CHAT"} {continue} ; if {[lindex $item 0] == $idx} {bs_add $hand "[lindex $item 2]  [unixtime] chon" ; break}}}
if {[lsearch -exact [bind chof -|- *] bs_chof] > -1} {unbind chof -|- * bs_chof} ; #this bind isn't needed any more
bind chjn -|- * bs_chjn
proc bs_chjn {bot hand channum flag sock from} {bs_add $hand "[string trimleft $from ~] [unixtime] chjn $bot"}
bind chpt -|- * bs_chpt
proc bs_chpt {bot hand args} {set old [split [bs_search ? [string tolower $hand]]] ; if {$old != "0"} {bs_add $hand "[join [string trim [lindex $old 1] ()]]  [unixtime] chpt $bot"}}
if {[string trimleft [lindex $version 1] 0] > 1030000} {bind away -|- * bs_away}
proc bs_away {bot idx msg} {
  global botnet-nick
  if {$bot == ${botnet-nick}} {set hand [idx2hand $idx]} {return}
  set old [split [bs_search ? [string tolower $hand]]]
  if {$old != "0"} {bs_add $hand "[join [string trim [lindex $old 1] ()]] [unixtime] away $bot [bs_filt [join $msg]]"}
}
bind dcc n|n unseen bs_unseen
proc bs_unseen {hand idx args} {
  global bs_list
  set tot 0 ; set chan [string tolower [lindex $args 0]] ; set id [array startsearch bs_list]
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id]
    if {$chan == [string tolower [lindex $bs_list($item) 4]]} {incr tot ; lappend remlist $item}
  }
  array donesearch bs_list $id ; if {$tot > 0} {foreach item $remlist {unset bs_list($item)}}
  putlog "--- $hand removed $chan from the bseen database.  $tot entries removed."
  putidx $idx "$chan successfully removed.  $tot entries deleted from the bseen database."
}
bind bot -|- bs_botsearch bs_botsearch
proc bs_botsearch {from cmd args} {
  global botnick ; set args [join $args]
  set command [lindex $args 0] ; set target [lindex $args 1] ; set nick [lindex $args 2] ; set search [bs_filt [join [lrange $args 3 e]]]
  if {[string match *\\\** $search]} {
    set output [bs_seenmask bot $nick $search]
    if {$output != "ga' ada yang cocok." && ![string match "I'm not on *" $output]} {putbot $from "bs_botsearch_reply $command  \{$target\} {$nick, $botnick says:  [bs_filt $output]}"}
  } {
    set output [bs_output bot $nick [bs_filt [lindex $search 0]] 0]
    if {$output != 0 && [lrange [split $output] 1 4] != "I don't remember seeing"} {putbot $from "bs_botsearch_reply $command \{$target\} {$nick, $botnick  says:  [bs_filt $output]}"}
  }
}
if {[info exists bs(bot_delay)]} {unset bs(bot_delay)}
bind bot -|- bs_botsearch_reply bs_botsearch_reply
proc bs_botsearch_reply {from cmd args} {
  global bs ; set args [join $args]
  if {[lindex [lindex $args 2] 5] == "not" || [lindex [lindex $args 2] 4] == "not"} {return}
  if {![info exists bs(bot_delay)]} {
    set bs(bot_delay) on ; utimer 10 {if {[info exists bs(bot_delay)]} {unset bs(bot_delay)}} 
    if {![lindex $args 0]} {putdcc [lindex $args 1] "[join [lindex $args 2]]"} {puthelp "[lindex $args 1] :[join [lindex $args 2]]"}
  }
}
bind dcc -|- seen bs_dccreq1
bind dcc -|- seennick bs_dccreq2
proc bs_dccreq1 {hand idx args} {bs_dccreq $hand $idx $args 0}
proc bs_dccreq2 {hand idx args} {bs_dccreq $hand $idx $args 1}
proc bs_dccreq {hand idx args no} {
  set args [bs_filt [join $args]] ; global bs
  if {[string match *\\\** [lindex $args 0]]} {
    set output [bs_seenmask dcc $hand $args]
    if {$output == "ga' ada yang cocok."} {putallbots "bs_botsearch 0 $idx $hand $args"}
    if {[string match "I'm not on *" $output]} {putallbots "bs_botsearch 0 $idx $hand $args"}
    putdcc $idx $output ; return $bs(logqueries)
  }
  set search [bs_filt [lindex $args 0]]
  set output [bs_output dcc $hand $search $no]
  if {$output == 0} {return 0}
  if {[lrange [split $output] 1 4] == "Maaf.. Aku gak pernah liat"} {putallbots "bs_botsearch 0 $idx $hand $args"}
  putdcc $idx "$output" ; return $bs(logqueries)
}
bind msg -|- seen bs_msgreq1
bind msg -|- seennick bs_msgreq2
proc bs_msgreq1 {nick uhost hand args} {bs_msgreq $nick $uhost $hand $args 0}
proc bs_msgreq2 {nick uhost hand args} {bs_msgreq $nick $uhost $hand $args 1}
proc bs_msgreq {nick uhost hand args no} { 
  if {[bs_flood $nick $uhost]} {return 0} ; global bs
  set args [bs_filt [join $args]]
  if {[string match *\\\** [lindex $args 0]]} {
    set output [bs_seenmask msg $nick $args] 
    if {$output == "ga' ada yang cocok."} {putallbots "bs_botsearch 1 \{notice $nick\} $nick $args"}
    if {[string match "I'm not on *" $output]} {putallbots "bs_botsearch 1 \{notice $nick\} $nick $args"}
    puthelp "notice $nick :$output" ; return $bs(logqueries)
  }
  set search [bs_filt [lindex $args 0]]
  set output [bs_output $search $nick $search $no]
  if {$output == 0} {return 0}
  if {[lrange [split $output] 1 4] == "Maaf.. Aku gak pernah liat"} {putallbots "bs_botsearch 1 \{notice $nick\} $nick $args"}
  puthelp "notice $nick :$output" ; return $bs(logqueries)
}


proc bs_pubreq {nick uhost hand chan args no} {
  if {[bs_flood $nick $uhost]} {return 0}
  global botnick bs ; set i 0 
  if {[lsearch -exact $bs(no_pub) [string tolower $chan]] >= 0} {return 0}
  if {$bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1} {return 0}
  set args [bs_filt [join $args]]
  if {[lsearch -exact $bs(quiet_chan) [string tolower $chan]] >= 0} {set target "notice $nick"} {set target "privmsg $chan"}
  if {[string match *\\\** [lindex $args 0]]} {
    set output [bs_seenmask $chan $hand $args]
    if {$output == "ga' ada yang cocok."} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
    if {[string match "I'm not on *" $output]} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
    puthelp "$target :$output" ; return $bs(logqueries)
  }
  set data [bs_filt [string trimright [lindex $args 0] ?!.,]]
  if {[string tolower $nick] == [string tolower $data] } {puthelp "$target :$nick, cari cermin dulu gi.." ; return $bs(logqueries)}
  if {[string tolower $data] == [string tolower $botnick] } {puthelp "$target :$nick, aku disini. kangen yaa?" ; return $bs(logqueries)}
  if {[onchan $data $chan]} {puthelp "$target :$nick, $data ada disini tuh." ; return  $bs(logqueries)}
  set output [bs_output $chan $nick $data $no] ; if {$output == 0} {return 0}
  if {[lrange [split $output] 1 4] == "Maaf.. Aku gak pernah liat"} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
  puthelp "$target :$output" ; return $bs(logqueries)
}
proc bs_output {chan nick data no} {
  global botnick bs version bs_list
  set data [string tolower [string trimright [lindex $data 0] ?!.,]]
  if {$data == ""} {return 0}
  if {[string tolower $nick] == $data} {return [concat $nick, lupa ingatan ya?]}
  if {$data == [string tolower $botnick]} {return [concat $nick, aku disini, siap melayanimu.]}
  if {[string length $data] > $bs(nicksize)} {return 0} 
  if {$bs(smartsearch) != 1} {set no 1}
  if {$no == 0} {
    set matches "" ; set hand "" ; set addy ""
    if {[lsearch -exact [array names bs_list] $data] != "-1"} { 
      set addy [lindex $bs_list([string tolower $data]) 1] ; set hand [finduser $addy]
      foreach item [bs_seenmask dcc ? [maskhost $addy]] {if {[lsearch -exact $matches $item] == -1} {set matches "$matches $item"}}
    }
    if {[validuser $data]} {set hand $data}
    if {$hand != "*" && $hand != ""} {
      if {[string trimleft [lindex $version 1] 0]>1030000} {set hosts [getuser $hand hosts]} {set hosts [gethosts $hand]}
      foreach addr $hosts {
        foreach item [string tolower [bs_seenmask dcc ? $addr]] {
          if {[lsearch -exact [string tolower $matches] [string tolower $item]] == -1} {set matches [concat $matches $item]}
        }
      }
    }
    if {$matches != ""} {
      set matches [string trimleft $matches " "]
      set len [llength $matches]
      if {$len == 1} {return [bs_search $chan [lindex $matches 0]]}
      if {$len > 999} {return [concat Ada $len data yang cocok di database, agak detil dikit napa seh.]}
      set matches [bs_sort $matches]
      set key [lindex $matches 0]
      if {[string tolower $key] == [string tolower $data]} {return [bs_search $chan $key]}
      if {$len <= 5} {
        set output [ concat Ada $len orang yang cocok nih (urut): [join $matches].]
        set output [concat $output  [bs_search $chan $key]] ; return $output
      } {
        set output [ concat Ada $len orang yang cocok, 5 nick terakhir (urut): [join [lrange $matches 0 4]].]
        set output [concat $output  [bs_search $chan $key]] ; return $output
      }
    }
  }
  set temp [bs_search $chan $data]
  if {$temp != 0} { return $temp } {
    #$data not found in $bs_list, so search userfile
    if {![validuser [bs_filt $data]] || [string trimleft [lindex $version 1] 0]<1030000} { 
      return "Maaf $nick.. Aku gak pernah liat $data."
    } {
      set seen [getuser $data laston]
      if {[getuser $data laston] == ""} {return "Maaf $nick.. Aku gak pernah liat $data."}
      if {($chan != [lindex $seen 1] || $chan == "bot" || $chan == "msg" || $chan == "dcc") && [validchan [lindex $seen 1]] && [lindex [channel info [lindex  $seen 1]] 23] == "+secret"} {
        set chan "-secret-"
      } {
        set chan [lindex $seen 1]
      }
      return [concat $nick, $data terakhir aku liat dia ada di $chan [bs_when [lindex $seen 0]] yang lalu.]
    }
  }
}
proc bs_search {chan n} {
  global bs_list ; if {![info exists bs_list]} {return 0}
  if {[lsearch -exact [array names bs_list] [string tolower $n]] != "-1"} { 
#bugfix:  let's see if the split added below fixes the eggdrop1.4.2 truncation bug
    set data [split $bs_list([string tolower $n])]
#bugfix: added a join on the $n  (c)
    set n [join [lindex $data 0]] ; set addy [lindex $data 1] ; set time [lindex $data 2] ; set marker 0
    if {([string tolower $chan] != [string tolower [lindex $data 4]] || $chan == "dcc" || $chan == "msg" || $chan == "bot") && [validchan [lindex $data 4]] &&  [lindex [channel info [lindex $data 4]] 23] == "+secret"} {
      set chan "-secret-"
    } {
      set chan [lindex $data 4]
    }
    switch -- [lindex $data 3] {
	part { 
        set reason [lrange $data 5 e]
        if {$reason == ""} {set reason "."} {set reason " Pesan : \"$reason\"."}
        set output [concat $n ($addy) terakhir aku liat dia part dari $chan [bs_when $time] yang lalu $reason] 
      }
	quit { set output [concat $n ($addy) terakhir aku liat dia kuit IRC dari $chan [bs_when $time] yang lalu. Pesan : ([join [lrange  $data 5 e]]).] }
	kick { set output [concat $n ($addy) terakhir aku liat dia di kick dari $chan oleh [lindex $data 5] [bs_when $time] yang lalu  dengan pesan ([join [lrange $data 6 e]]).] }
	rnck {
	  set output [concat $n ($addy) terakhir aku liat dia ganti nick dari [lindex $data 5] di [lindex $data 4] [bs_when $time] yang lalu.] 
	  if {[validchan [lindex $data 4]]} {
	    if {[onchan $n [lindex $data 4]]} {
	      set output [concat $output $n masih ada di [lindex $data 4] sekarang.]
	    } {
	      set output [concat $output Sekarang aku gak liat $n tuh.]
	    }
	  }
	}
	nick { 
	  set output [concat $n ($addy) terakhir aku liat dia ganti nick ke [lindex $data 5] di [lindex $data 4] [bs_when $time] yang lalu.] 
	}
	splt { set output [concat $n ($addy) terakhir aku liat dia keluar $chan karena split server [bs_when $time] yang lalu.] }
	rejn { 
	  set output [concat $n ($addy) terakhir aku liat dia masuk $chan sesudah terkena split server [bs_when $time] yang lalu.] 
	  if {[validchan $chan]} {if {[onchan $n $chan]} {set output [concat $output  $n masih ada di $chan.]} {set output [concat $output Aku gak liat $n di $chan sekarang tuh.]}}
	}
	join { 
	  set output [concat $n ($addy) terakhir aku liat dia masuk $chan [bs_when $time] yang lalu.]
	  if {[validchan $chan]} {if {[onchan $n $chan]} {set output [concat $output  $n masih ada di $chan.]} {set output [concat $output Aku gak liat $n di $chan sekarang tuh.]}}
	}
	away {
	  set reason [lrange $data 5 e]
        if {$reason == ""} {
	    set output [concat $n ($addy) was last seen returning to the partyline on $chan [bs_when $time] ago.]
	  } {
	    set output [concat $n ($addy) terakhir aku liat dia away ($reason) di $chan [bs_when $time] yang lalu.]
	  }
	}
	chon { 
	  set output [concat $n ($addy) was last seen joining the partyline [bs_when $time] ago.] ; set lnick [string tolower $n]
	  foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n is on the partyline right now.] ; set marker  1 ; break}}
	  if {$marker == 0} {set output [concat $output  I don't see $n on the partyline now, though.]}
	}
	chof { 
	  set output [concat $n ($addy) was last seen leaving the partyline [bs_when $time] ago.] ; set lnick [string tolower $n]
	  foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n is on the partyline in [lindex $item 1] still.]  ; break}}
	}
	chjn { 
	  set output [concat $n ($addy) was last seen joining the partyline on $chan [bs_when $time] ago.] ; set lnick [string tolower $n]
	  foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n is on the partyline right now.] ; set marker  1 ; break}}
	  if {$marker == 0} {set output [concat $output  I don't see $n on the partyline now, though.]}
	}
	chpt { 
	  set output [concat $n ($addy) was last seen leaving the partyline from $chan [bs_when $time] ago.] ; set lnick [string tolower $n]
	  foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n is on the partyline in [lindex $item 1] still.]  ; break}}
	}
	default {set output "error"}
    } ; return $output
  } {return 0}
}
proc bs_when {lasttime} {
  #This is equiv to mIRC's $duration() function
  set years 0 ; set days 0 ; set hours 0 ; set mins 0 ; set time [expr [unixtime] - $lasttime]
  if {$time < 60} {return "hanya $time detik"}
  if {$time >= 31536000} {set years [expr int([expr $time/31536000])] ; set time [expr $time - [expr 31536000*$years]]}
  if {$time >= 86400} {set days [expr int([expr $time/86400])] ; set time [expr $time - [expr 86400*$days]]}
  if {$time >= 3600} {set hours [expr int([expr $time/3600])] ; set time [expr $time - [expr 3600*$hours]]}
  if {$time >= 60} {set mins [expr int([expr $time/60])]}
  if {$years == 0} {set output ""} elseif {$years == 1} {set output "1 year,"} {set output "$years years,"}
  if {$days == 1} {lappend output "1 hari,"} elseif {$days > 1} {lappend output "$days hari,"}
  if {$hours == 1} {lappend output "1 jam,"} elseif {$hours > 1} {lappend output "$hours jam,"}
  if {$mins == 1} {lappend output "1 menit"} elseif {$mins > 1} {lappend output "$mins menit"}
  return [string trimright [join $output] ", "]
}
proc bs_add {nick data} {
  global bs_list bs
  if {[lsearch -exact $bs(no_log) [string tolower [lindex $data 3]]] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower [lindex $data  3]]] == -1)} {return}
  set bs_list([string tolower $nick]) "[bs_filt $nick] $data"
}
bind time -  "* * * * *" bs_trim
proc bs_lsortcmd {a b} {global bs_list ; set a [lindex $bs_list([string tolower $a]) 2] ; set b [lindex $bs_list([string tolower $b]) 2] ; if {$a > $b} {return 1}  elseif {$a < $b} {return -1} {return 0}}
proc bs_trim {min h d m y} {
  global bs bs_list ; if {![info exists bs_list] || ![array exists bs_list]} {return} ; set list [array names bs_list] ; set range [expr [llength $list] - $bs(limit) - 1] ; if  {$range < 0} {return}
  set list [lsort -increasing -command bs_lsortcmd $list] ; foreach item [lrange $list 0 $range] {unset bs_list($item)}
}
proc bs_seenmask {ch nick args} {
  global bs_list bs ; set matches "" ; set temp "" ; set i 0 ; set args [join $args] ; set chan [lindex $args 1]
  if {$chan != "" && [string trimleft $chan #] != $chan} {
    if {![validchan $chan]} {return "Aku gak pernah join $chan."} {set chan [string tolower $chan]}
  } { set $chan "" }
  if {![info exists bs_list]} {return "ga' ada yang cocok."} ; set data [bs_filt [string tolower [lindex $args 0]]]

#bugfix: unnecessarily complex masks essentially freeze the bot
  set maskfix 1
  while $maskfix {
    set mark 1
    if [regsub -all -- \\?\\? $data ? data] {set mark 0}
    if [regsub -all -- \\*\\* $data * data] {set mark 0}
    if [regsub -all -- \\*\\? $data * data] {set mark 0}
    if [regsub -all -- \\?\\* $data * data] {set mark 0}
    if $mark {break}
  }

  set id [array startsearch bs_list]
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id] ; if {$item == ""} {continue} ; set i 0 ; set temp "" ; set match [lindex $bs_list($item) 0] ; set addy [lindex  $bs_list($item) 1]
    if {[string match $data $item![string tolower $addy]]} {
      set match [bs_filt $match] ; if {$chan != ""} {
        if {[string match $chan [string tolower [lindex $bs_list($item) 4]]]} {set matches [concat $matches $match]}
      } {set matches [concat $matches $match]}
    }
  }
  array donesearch bs_list $id
  set matches [string trim $matches " "]
  if {$nick == "?"} {return [bs_filt $matches]}
  set len [llength $matches]
  if {$len == 0} {return "ga' ada yang cocok."}
  if {$len == 1} {return [bs_output $ch $nick $matches 1]}
  if {$len > 999} {return "Ada $len data yang cocok di database, agak detil dikit napa seh."}
  set matches [bs_sort $matches]
  if {$len <= 5} {
    set output [concat Ada $lenorang yang cocok (urut): [join $matches].]
  } {
    set output "Ada $len orang yang cocok, 5 nick terakhir (urut): [join [lrange $matches 0 4]]."
  }
  return [concat $output [bs_output $ch $nick [lindex [split $matches] 0] 1]]
} 
proc bs_sort {data} {global bs_list ; set data [bs_filt [join [lsort -decreasing -command bs_lsortcmd $data]]] ; return $data}
bind dcc m|m seenstats bs_dccstats
proc bs_dccstats {hand idx args} {putdcc $idx "[bs_stats]"; return 1}

bind msg m|m seenstats bs_msgstats
proc bs_msgstats {nick uhost hand args} {global bs ; if {[bs_flood $nick $uhost]} {return 0} ; puthelp "notice $nick :[bs_stats]" ; return $bs(logqueries)}
proc bs_stats {} {
  global bs_list bs ; set id [array startsearch bs_list] ; set bs_record [unixtime] ; set totalm 0 ; set temp ""
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id]
    set tok [lindex $bs_list($item) 2] ; if {$tok == ""} {putlog "Damaged seen record: $item" ; continue}
    if {[lindex $bs_list($item) 2] < $bs_record} {set bs_record [lindex $bs_list($item) 2] ; set name $item}
    set addy [string tolower [maskhost [lindex $bs_list($item) 1]]] ; if {[lsearch -exact $temp $addy] == -1} {incr totalm ; lappend temp $addy}
  }
  array donesearch bs_list $id
  return "SeenStats : [array size bs_list]/$bs(limit) nick - $totalm unique host. Oldest : [lindex  $bs_list($name) 0] terlihat [bs_when $bs_record] yang lalu."
}
bind dcc m|m chanstats bs_dccchanstats
proc bs_dccchanstats {hand idx args} {
  if {$args == "{}"} {set args [console $idx]}  
  if {[lindex $args 0] == "*"} {putdcc $idx "$hand, chanstats requires a channel arg, or a valid console channel." ; return 1}
  putdcc $idx "[bs_chanstats [lindex $args 0]]"
  return 1
}

bind msg m|m chanstats bs_msgchanstats
proc bs_msgchanstats {nick uhost hand args} {global bs ; if {[bs_flood $nick $uhost]} {return 0} ; puthelp "notice $nick :[bs_chanstats [lindex $args 0]]" ;  return $bs(logqueries)}
proc bs_chanstats {chan} {
  global bs_list ; set chan [string tolower $chan] ; if {![validchan $chan]} {return "Aku gak di $chan."}
  set id [array startsearch bs_list] ; set bs_record [unixtime] ; set totalc 0 ; set totalm 0 ; set temp ""
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id] ; set time [lindex $bs_list($item) 2] ; if {$time == ""} {continue}
    if {$chan == [string tolower [lindex $bs_list($item) 4]]} {
      if {$time < $bs_record} {set bs_record $time} ; incr totalc
      set addy [string tolower [maskhost [lindex $bs_list($item) 1]]]
      if {[lsearch -exact $temp $addy] == -1} {incr totalm ; lappend temp $addy}
    }
  }
  array donesearch bs_list $id ; set total [array size bs_list]
  return "$chan : [expr 100*$totalc/$total]% ($totalc/$total) - $totalm unique host telah tersimpan selama [bs_when $bs_record]."
}
foreach chan [string tolower [channels]] {if {![info exists bs_botidle($chan)]} {set bs_botidle($chan) [unixtime]}}
bind join -|- * bs_join_botidle
proc bs_join_botidle {nick uhost hand chan} {
  global bs_botidle botnick
  if {$nick == $botnick} {
   set bs_botidle([string tolower $chan]) [unixtime]
  }
}

bind msgm -|- "help seen" bs_help_msg_seen
bind msgm -|- "help chanstats" bs_help_msg_chanstats
bind msgm -|- "help seenstats" bs_help_msg_seenstats
proc bs_help_msg_seen {nick uhost hand args} {
  global bs ; if {[bs_flood $nick $uhost]} {return 0}
  puthelp "notice $nick :###  seen <query> \[chan\]          $bs(version)"
  puthelp "notice $nick :   Queries can be in the following formats:"
  puthelp "notice $nick :     'regular':  seen lamer; seen lamest "
  puthelp "notice $nick :     'masked':   seen *l?mer*; seen *.lame.com; seen *.edu #mychan" ; return 0
}
proc bs_help_msg_chanstats {nick uhost hand args} {
  global bs ; if {[bs_flood $nick $uhost]} {return 0}
  puthelp "notice $nick :###  chanstats <chan>          $bs(version)"
  puthelp "notice $nick :   Returns the usage statistics of #chan in the seen database." ; return 0
}
proc bs_help_msg_seenstats {nick uhost hand args} {
  global bs ; if {[bs_flood $nick $uhost]} {return 0}
  puthelp "notice $nick :###  seenstats          $bs(version)"
  puthelp "notice $nick :   Returns the status of the bseen database." ; return 0
}
bind dcc -|- seenversion bs_version
proc bs_version {hand idx args} {global bs ; putidx $idx "###  Bass's Seen script, $bs(version)."}
bind dcc -|- help bs_help_dcc
proc bs_help_dcc {hand idx args} {
  global bs
  switch -- $args {
    seen {
      putidx $idx "###  seen <query> \[chan\]          $bs(version)" ; putidx $idx "   Queries can be in the following formats:"
      putidx $idx "     'regular':  seen lamer; seen lamest " ; putidx $idx "     'masked':   seen *l?mer*; seen *.lame.com; seen *.edu #mychan"
    }
    seennick {putidx $idx "###  seen <nick>          $bs(version)"}
    chanstats {putidx $idx "###  chanstats <chan>" ; putidx $idx "   Returns the usage statistics of #chan in the seen database."}
    seenstats {putidx $idx "###  seenstats          $bs(version)" ; putidx $idx "   Returns the status of the bseen database."}
    unseen {if {[matchattr $hand n]} {putidx $idx "###  unseen <chan>          $bs(version)" ; putidx $idx "   Deletes all <chan> entries from the bseen  database."}}
    default {*dcc:help $hand $idx [join $args] ; return 0} 
  } ; return 1
}
putlog "eggoez part(2) Loaded!!"

##############################################################################
bind pub - .aksi pub_iseng
bind pub - !aksi pub_iseng
proc pub_iseng {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah 12!bunga |12 !cium |12 !ban |12 !bunuh |12 !kick |12 !slap |12 !gantung |12 !peluk |12 !cakar |12 !hajar|12 !jitak |12 !perkosa"
      return 0
    }
}

bind pub - .bunga pub_bunga
bind pub - !bunga pub_bunga
proc pub_bunga {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah .bunga <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :6huaaaaaa... accciiikk... 5dikacih bunga nih.. 6makasih makasih... 7mwaaah... mwaaaahhhh pass bibil"
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :5walaahh... 6$nick 5dacal pelits.. bunganya kok buat dili cendili cih... 6dacal .. 7:P".
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :5cieeeehhh 6$nick 5ngasih setangkai bunga plastik uy buat6 $person 5cuuupssss... ^_* 7ai lop yu, yu lop mi, yu en mi loph loph an...." 
    } else {
        putserv "PRIVMSG $chan :5hmmmmm... si 6$nick 5badung ah, mana ada nick 6$person 5di sini.. 7mending buat akuh.. 5:*"
    }
}

bind pub - .kiss pub_kiss
bind pub - .cium pub_kiss
bind pub - !kiss pub_kiss
bind pub - !cium pub_kiss
proc pub_kiss {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah .kiss <nick> atau .cium <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :5hadah.....napa kok 6aku5 mau dicium.. 6aku5 udah punya pacar6 $nick 7dasar dudung!!"
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :5huahuahua.. 6$nick 5itu bibir dicopot aja dolo yah.. trus di ciumin ke pipi kamu 7xixixixixixi6 :P"
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :6$nick 5mencium bibir merahnya6 $person 5sambil merem.. 7muaccchhh.. muaaachhh.. muaaaachhh... much..much..much.. clegukz.. nickmat khan 6$person" 
    } else {
        putserv "PRIVMSG $chan :5hmmmmm... si 6$nick 5badung ah, mana ada nick 6$person 5di sini.. 7mending cium bibil akuh.. 5:*"
    }
}

bind pub - .ban pub_banmu
bind pub - !ban pub_banmu
proc pub_banmu {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan .ban <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :5duarRRRRR kalo 6aku 7dibaannn... 5terus siapa yang bukaian.. 5dudung ach.. 7:K"
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :5begh.. 6$nick 5sarap yah koq 6kamuh 5mau 7ngebaann 5kamu sendiri 6$nick 7badung ah..5 hehehehe..."
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :6$nick 5ngalungin ban kereta keleher6 $person 7GuubrakKKKK..... 5sakit gak6 $person 5abisnya mau banned g punya access sih.." 
    } else {
        putserv "PRIVMSG $chan :5waaah pasti salah room yaaaaa.....  6$nick ..?? 5mana ada si 6$person 5di sini.. 7dasar"
    }
}

bind pub - .kill pub_kill
bind pub - .bunuh pub_kill
bind pub - !kill pub_kill
bind pub - !bunuh pub_kill
proc pub_kill {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah .kill <nick> atau .bunuh <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :5beuhh... 6aku5 salah apa say.. kok minta6 aku 5bunuh diri sih... 7gak akan terjadi 6aku bunuh diriku sendiri5 huahuahuahauha"
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :6$nick 5aku lempar juga kau nanti dari atas gedung lantai empat...7biar matek... 5hauhauahauhauhau.."
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :6$nick 5tembaK anunya6 $person 5pake 7tembak air... yak 5crutz crutz crutz.. si 6$person 5mengeluh ngeluh kesakitan.. aaaaaaaaaahhh.. tidakKKk... kapok loe 6$person  7ekekekekekekeke " 
    } else {
        putserv "PRIVMSG $chan :5wedew... 6$nick 5benran mau nembak6 $nick 5bukanya itu7 kamu sendiri,6 $person 5dodol banget sih...."
    }
}

bind pub - .kick pub_tendang
bind pub - .tendang pub_tendang
bind pub - !kick pub_tendang
bind pub - !tendang pub_tendang
proc pub_tendang {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah .kick <nick> atau .tendang <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :5waaaaaahhh...kok 6aku5 sih yang mau di tendang...7 gak jadi deh... 5males.. :C"
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :5hmmmm 6$nick 5ni mau dibawa ke RSJ kali yah.. 5mana ada tendang diri sendiri, 6$nick 7tendang bokong kamu aja sendiri yah.. 5:P"
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :6$nick 5teenndaaanggg si6 $person 5pake sepatu hansip.. pas dipantat 7DeezZZZ.. DesSSS 5pecah ngga tuh bisulnya..7 xuxuxuxuxu" 
    } else {
        putserv "PRIVMSG $chan :5waaaah pasti gak pake kacamata yaaaaa.....7 oi 6$nick 5.. si 6$person 5gak ada di sini.. 7gak liat nicklist sih.. ^_^"
    }
}

bind pub - .slap pub_slap
bind pub - !slap pub_slap
proc pub_slap {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah .slap <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :6$nick 5slapssss 7pipiku yang imut² ini sampai 4merah... 4*0^_^4*5 hmmmmm 6$nick 5sakit tau mending di cium aja gih.."
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :5jiahhh... 6$nick 5itu tanganya di away dolo dr keyboard deh.. 7tarik ke atas setinggi kepala.. tarik kekanan timpukin ke pipi kamu 5huahauhauhau.. dudulz.."
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :6$nick 2slaaaaapsssssss6 $person 5dijidat pake kursi, kompor, penggorengan, keyboard, monitor, linggis... 7JeGuuuERRR... PleeTHaaQQQ.. DeeZZiiNGhHH.. 5wkwkwkwk... punyeng yah6 $person " 
    } else {
        putserv "PRIVMSG $chan :5slaps 4eRRoR!!! 5abisnya si 6$nick 5gak liat sih, mana ada  6$person 5disini.. 7cape deh.."
    }
}

bind pub - .gantung pub_gantung
bind pub - !gantung pub_gantung
proc pub_gantung {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah .gantung <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :5DuaaaRRRR....6aku7 masih pengen hidup tauk... 4;3*"
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :5gini 6$nick 6aku5 kasih saran yach.. 5ambil tali ma kursi gih.. terus talinya diikatin dipohon.. 7nah.. gantungin tu leher kamu di tali itu 5beres dah.. xixixixixi"
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :5ayo siapa mau ikut aku ganntuuung6 $person ?? 7kita gantung di pohon tomat yah pake tali kolornya6 $nick 5aja 5Srruuuttt Sruttt... makanya jangan nakal yah.. "
    } else {
        putserv "PRIVMSG $chan :5adyah.... si 6$nick 5duduts sangad nih, mana ada si 6$person di sini.. 7gantung ChanServ aja yah... 5hahahahahakz"
    }
}

bind pub - .hug pub_hug
bind pub - .peluk pub_hug
bind pub - !hug pub_hug
bind pub - !peluk pub_hug
proc pub_hug {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah .hug <nick> atau .peluk <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :5hayah.... enak aja lo6 $nick 7mau peluk² aku lagi... 5 nanti si eggo marah lo... kalo tau.."
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :5huaaaaaaaaaaa 6$nick 5buruan lari ke pohon kelapa sana.... 7peluk tu pohon ampe pagi... 5wkwkwkwkwkwk.."
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :6$nick 5peelluuuukkk mesraa dan penuh nafsu si6 $person 5grRR tanganya si6 $nick 7nakal iks... 5wahhh si6 $person 7itu merem melek kenapa yah... . 5angeett yahhhh ^_* hauhauahuahauhauaha..." 
    } else {
        putserv "PRIVMSG $chan :5begh.... si 6$nick 5mau peluk siapa eyy... 6$person 7lo gak ada ye...5 mendingan peluk 6$botnick 5aja yah ;p"
    }
}

bind pub - .cakar pub_cakar
bind pub - !cakar pub_cakar
proc pub_cakar {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah .cakar <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :5hayah... kok main cakar² ma6 $botnick 5sihhh....... 6$nick.. 7minta digigit bibil nya yaaaaaaa..5 sksajhsajksagda"
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :5wkwkwkwkwkwk... okelah... 6$nick 5cakar aja itu anumu sendiri...6 $botnick 7ogah ah... jijik najis... 5huehueheuhehue.. "
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :6$nick 5cakar²6 $person 5pake kaki harimau... 7serrrrrrrrrrrrrrrrrr...... 5cleguks " 
    } else {
        putserv "PRIVMSG $chan :5yang mau di cakar siapa6 $nick 5??"
    }
}

bind pub - .hajar pub_banting
bind pub - !hajar pub_banting
proc pub_banting {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah .hajar <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :$nick 5bersiap² mau 7HAJAR6 $botnick .... 4tapi12 $botnick 3lariiiiii oyyy,,, 5gak kenak deh jadinya... 11:)"
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :3wedew --**6 $nick 5mulai gak 4waras 12euyyyy...."
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :6$nick 13lempar 9bogem 7banting 2jejeg 13pukul 3jewer 8injek-injek 10keplak 11jorokin 2Gigit 3Gantung 12Tebas 11Cakar 4Hajar 6santet 2jitak 3cincang 8tusuk 10bacok 2iris-iris4 $person  dengan penuh 13perasaan :P." 
    } else {
        putserv "PRIVMSG $chan :5heh..6 $nick 5abis berapa botol semalem.. 7masih aja kocak...."
    }
}

bind pub - .jitak pub_kerokin
bind pub - !jitak pub_kerokin
proc pub_kerokin {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah .jitak <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :5ewh..6 $nick 5kalo jitak 6$botnick 5nanti6 $botnick 5bilangin ke 7g0eZ 5lohh..."
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :7wkwkwkwkwkwkwk... 6$nick 5mau 6$botnick 5bantuin jitakin kepalamu gak... 7:p"
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :6$nick 5jitak kepala6 $person 5Pake Kibot Lucak Pak Pik Puk Pek Pok...4A 12I 7U 13E 9O"
    } else {
        putserv "PRIVMSG $chan :5heh..6 $nick 5masih mumet ya tu kepala.. abis berapa botol semalem.. 7masih aja kocak...."
    }
}

bind pub - .tarik pub_tarik
bind pub - !tarik pub_tarik
proc pub_tarik {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah .tarik <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :5aduchhhhh.....6 $nick 5tarik aku nichh.... 7g0eZ g0eZ... 5tolongin aku donk sayyy.........."
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :5ehhh...6$nick 5mau tarik rombong apa ya....6$ person 5mana kok gak ada.... 7badung ach..."
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :6$nick 5tarik celananya 6 $person 5ke bawah....7sssrrreeettt....!!! 5waikssssss.... mlorot uyyy.. kelihatan tuh cd nya.....6 $person 5malu yah...! 5kacian banget deh.." 
    } else {
        putserv "PRIVMSG $chan :5heh..6 $nick 5masih mumet ya tu kepala.. abis berapa botol semalem.. 7masih aja kocak...."
    }
}

bind pub - .Bom pub_bom
bind pub - !Bom pub_bom
proc pub_bom {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah .bom <nick> atau !bom <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :6$botnick 5tangkap lalu balikin lagi ach ke6 $nick 4*!*BoOoOoOoMm*!* 5biar tau rasa loh 7gOoosoOong maning gOosOong maning bOS BOs.."
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :5haaaaaa... 6$nick 7badung...5ambil tu c4.. mampusss loe 4boOoOom 5duarRRRRRRRRR.."
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :6$nick 5kasih bungkusan kado berisi 7c45 ke 6$person 5buka donk6 $person , $person 5mendadak kaget uy... waaaa 4BoOoOoOoMm 5mau teriak keburu 4DuaRRRRRR5 meletus tuh 7c4 5nya kasihan deh... "
    } else {
        putserv "PRIVMSG $chan :5heyy... si 6$nick 2bodo banget sih, mana ada 6$person 5di sini.. "
    }
}

bind pub - .perkosa pub_perkosa
bind pub - !perkosa pub_perkosa
proc pub_perkosa {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :gunakan perintah .perkosa <nick>"
      return 0
    }
    set person [lindex $arg 0]
    if {$person == $botnick} {
       putserv "PRIVMSG $chan :5hmmmmmmmmmmmmmmm...6 $nick 5mau perkosa aq.?? 6aku 6bilangin 7g0eZ 5loh.... :K"
    } elseif {$person == $nick} {
       putserv "PRIVMSG $chan :5temen² si 6$nick 5gak normal nih....6 $botnick 5jadi takut deh.... hiiiiiiiii... 7jijik....:P"
    } elseif {[onchan $person $chan]} {
        putserv "PRIVMSG $chan :6$nick 5peluk 6$person.. 5hiiiii.... mau di apain ya si6 $person 5??.. 5waaa.... kok di buka bajunya... wah wah... tanganya6 $nick 5 jahil tuh...5disentuh lagi......wedew buka celananya juga.. 7:?"
    } else {
        putserv "PRIVMSG $chan :5jiah... si 6$nick 5beggok banget deh, mana ada si 6$person 5di sini.. 7gak asik ah.. "
    }
}
putlog "="

bind pub - "!uptime" pub:ambiluptime
set jammulai [unixtime]
set vern "4«5º14g10003e15Z 15e3g10G14o5º4»"
set awaym {
"Lagi PeRangZ Ma IrCopz!"
"belajar Bikinz Scriptz!!"
"BoBo NyeNyakZ!!"
"perGi Ke SekoLahz"
"Epon YaYaNk g0eZ"
"Mandi Kramasz Bareng g0eZ"
"KangeN MaMa"
"bIkin Webz"
"Em Elz"
"bIkin Adikz"
"MojOk aMa yaYangz"
"LaGi NontOnz IteNAz"
"SurFinGz 17tahun.Comz"
"ngaskus dulu juragan"
"ngopi-ngopi dulu ah"
"olah raga malem"
"saatnya ikutan kuis"
"syuting film"
"cari gebetan"
"Curhat sama g0eZ"
"Lagi Di AJaRin Buat Bot Ama g0eZ"
"Lagi anu ama g0eZ (rahasia)"
"Ciumin bibir merahnya g0eZ"
}

proc pub:pengecekan {} {
global jammulai awaym vern
set jamsaatini [unixtime]
set uptimesekarang [return:uptime $jammulai $jamsaatini]
set readabletime [konversidurasi $uptimesekarang]
set awaymsg [lindex $awaym [rand [llength $awaym]]]
putserv "AWAY"
putserv "AWAY :$awaymsg \[UpTImE for : $readabletime\] - $vern"
timer [expr 1] pub:pengecekan
}

proc pub:ambiluptime { nick uhost hand chan text } {
global jammulai vern
set jamsaatini [unixtime]
set uptimesekarang [return:uptime $jammulai $jamsaatini]
set readabletime [konversidurasi $uptimesekarang]
}

proc return:uptime { starts ends } {

set value [expr $ends - $starts]
return $value

}

proc konversidurasi {seconds} { 
   set h [expr $seconds/3600] 
   set m [expr $seconds/60 - $h*60] 
   set s [expr $seconds - $m*60 - $h*3600] 
   return "[lindex [split $h] 0] HOuRs [lindex [split $m] 0] MiNuTes [lindex [split $s] 0] SecoNds" 
} 

set init-server {
global jammulai
set jammulai [unixtime]
pub:pengecekan
}
putlog "=="
bind pub - .hitung calc
bind pub - !hitung calc
set pi 3.1415926535897932
set e 2.71828182845905
set g 9.81
proc calc {nick host handle channel arg} {
  global pi e g
  if {$arg != "" && ![string match "\[" $arg] && ![string match "\]" $arg]} { 
    putserv "PRIVMSG $channel :eh $nick hasilnya yaitu yakni adalah ialah  [expr $arg]"
  } else {
    putserv "NOTICE $nick :12Caranya .hitung 1+1 --- konstanta: \$pi \$e \$g --- fungsi: abs(), acos(), asin(), atan(), atan2(), ceil(), cos(), cosh(), exp(), floor(), fmod(), hypot(), log(), log10(), pow(), round(), sin(), sinh(), sqrt(), tan(), tanh() --- \[ dan \] tidak boleh dipakai dalam expresi."
  }
}
putlog "==="
putlog "======"
putlog "=======" 
putlog "========"


## Enjoy,
## Sincerely,
## eggoez.blogspot.com!
##
bind pub - .jodoh Matcher
proc Matcher {nick uhost hand chan args} {
regsub -nocase -all \[{}] $args "" args
set origargs $args
set args [string tolower $args]
if {[llength $args] < 2} {
 putserv "privmsg $nick :!04Jo04Do04h! Penggunaan .jodoh <nama cowok> <nama cewek>"
 return
}

set counter 0
set compatmarker 0
while {$counter != [string length $args]} {
 if {[string range $args $counter $counter] == "l"} {incr compatmarker 2}
 if {[string range $args $counter $counter] == "o"} {incr compatmarker 2}
 if {[string range $args $counter $counter] == "v"} {incr compatmarker 2}
 if {[string range $args $counter $counter] == "e"} {incr compatmarker 2}
 if {[string range $args $counter $counter] == "y"} {incr compatmarker 3}
 if {[string range $args $counter $counter] == "o"} {incr compatmarker 1}
 if {[string range $args $counter $counter] == "u"} {incr compatmarker 3}
 incr counter
}

set compatability 0
if {$counter > 0} {set compatability [expr 5 - ([string length $args] /2)]}
if {$counter > 2} {set compatability [expr 10 - ([string length $args] /2)]}
if {$counter > 4} {set compatability [expr 20 - ([string length $args] /2)]}
if {$counter > 6} {set compatability [expr 30 - ([string length $args] /2)]}
if {$counter > 8} {set compatability [expr 40 - ([string length $args] /2)]}
if {$counter > 10} {set compatability [expr 50 - ([string length $args] /2)]}
if {$counter > 12} {set compatability [expr 60 - ([string length $args] /2)]}
if {$counter > 14} {set compatability [expr 70 - ([string length $args] /2)]}
if {$counter > 16} {set compatability [expr 80 - ([string length $args] /2)]}
if {$counter > 18} {set compatability [expr 90 - ([string length $args] /2)]}
if {$counter > 20} {set compatability [expr 100 - ([string length $args] /2)]}
if {$counter > 22} {set compatability [expr 110 - ([string length $args] /2)]}

if {$compatability < 0} {set compatability 0}
if {$compatability > 100} {set compatability 100}
if {$compatability < 50} {
  set jodoh "boleh percaya.. boleh tidak.. tapi kemungkinan anda berdua belum jodoh. Maaf yah.. :)"
} elseif {$compatability < 75} {
  set jodoh "Perlu usaha lebih giat lagi untuk melakukan pendekatan hati kalian berdua =p"
} elseif {$compatability < 90} {
  set jodoh "awal yang bagus.. mendekati jodoh.. cuit cuit.. ayo lebih mesra lagi akh.. =p"
} else {
  set jodoh "BRAVO!! anda berdua jodoh! percaya...?! tidak juga tidak apa-apa minimal anda tahu yang terbaik untuk anda yah.. =p"
}
putserv "privmsg $chan :14Kecocokan antara03 $origargs 10sebesar04 $compatability% ($jodoh)"
return
}

set channel "*"

# Edit the time cycle which is in minutes format depending on the time intervals you want the bot to flow out the advertisment
set time 20

# EDIT the text or REMOVE or ADD lines including inverted commas at the starting and ending at each line 
set text {
  "seen g0eZ"
  "seen egGo"
  "eggoez@yahoo.com"
  "ojok_add@ymail.com"
}

##### DO NOT EDIT ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING #####

if {[string compare [string index $time 0] "!"] == 0} { set timer [string range $time 1 end] } { set timer [expr $time * 60] }
if {[lsearch -glob [utimers] "* go *"] == -1} { utimer $timer go }

proc go {} {
  global channel time text timer
  foreach chan $channel {
    set line [lindex $text [rand [llength $text]]]
    putserv "PRIVMSG $chan :$line"
  }
  if {[lsearch -glob [utimers] "* go *"] == -1} { utimer $timer go }
}

putlog "========="
putlog "=========="
bind msgm - "*" msg_hi
proc msg_hi {nick uhost hand text} {
global botnick
 if {[regexp -nocase "hi" $text] || [regexp -nocase "hello" $text] || [regexp -nocase "alo" $text] || [regexp -nocase "halo" $text] > 0} { 
	putserv "PRIVMSG $nick :hi juga $nick"
 	putserv "PRIVMSG $nick :asl dunk"
	} }

bind msgm - "*" msg_asl
proc msg_asl {nick uhost hand text} {
global botnick
 if {[regexp -nocase "asl" $text] || [regexp -nocase "dimana" $text] || [regexp -nocase "umur" $text] || [regexp -nocase "tinggal" $text] > 0} { 
	putserv "PRIVMSG $nick :hmm napa seh nanya asl molo $nick"
 	putserv "PRIVMSG $nick :gua ada di samarinda :) umur maseh mudah kok baru 18 jalan hehehehe"
	putserv "PRIVMSG $nick :asl kamu juga please"
} }
bind msgm - "*" kul
proc kul {nick uhost hand text} {
global botnick
if {[regexp -nocase "kul" $text] || [regexp -nocase "ker" $text] > 0} {
	putserv "PRIVMSG $nick :gua kuliah neh di Untar Jurusan Ekonomi Angkatan 2001"
	putserv "PRIVMSG $nick :kalo kamu? eh kamu skr lagi main dimana?"
	putserv "PRIVMSG $nick :kamu kerja/kuliah?"
	putserv "PRIVMSG $nick :dimana?"
} }

bind msgm - "*" msg_pacar
proc msg_pacar {nick uhost hand text} {
global botnick
if {[regexp -nocase "pacar" $text] || [regexp -nocase "bf" $text] || [regexp -nocase "yayang" $text] > 0} {
	putserv "PRIVMSG $nick :nurut kamu aku udeh ada yg punya belom ;P"
	putserv "PRIVMSG $nick :Kalo kamu sendiri udeh ada yayang lom"
	putserv "PRIVMSG $nick :Gua baru putus ama co gua gara2 gua suka keluar malam ama temen2 gus hiks :)"
	putserv "PRIVMSG $nick :loe suka ke dugem ngga?"

} }

bind msgm - "*" msg_email
proc msg_email {nick uhost hand text} {
global botnick
if {[regexp -nocase "email" $text] || [regexp -nocase "mail" $text] > 0} {
	putserv "PRIVMSG $nick :kamu mau minta email aku yah?"
	putserv "PRIVMSG $nick :Ini gua kaseh nanti kirimin foto kamu yah , kalo ganteng sapa tau wa kecantol hehehe"
	putserv "PRIVMSG $nick :eggoez@yahoo.com"
} }

bind msgm - "*" msg_tlp
proc msg_tlp {nick uhost hand text} {
global botnick
if {[regexp -nocase "telp" $text] || [regexp -nocase "phone" $text] || [regexp -nocase "hp" $text] > 0} {
	putserv "PRIVMSG $nick :huh buat apa kamu minta nomer telpk gua?"
	putserv "PRIVMSG $nick :nih wa kaseh nanti tlp gua yah 08125737575"
	putserv "PRIVMSG $nick :Minta nomer kamu juga donk ama email kamu biar kita bisa contac nanti"
} }

bind msgm - "*" msg_ketawa
proc msg_ketawa {nick uhost hand text} {
global botnick
if {[regexp -nocase "hehe" $text] || [regexp -nocase "haha" $text] || [regexp -nocase "hihi" $text] > 0} {
	putserv "PRIVMSG $nick :hehehe kok ketawa seh"
	putserv "PRIVMSG $nick :apanya yang lucu $nick"
} }

bind msgm - "*" msg_name
proc msg_name {nick uhost hand text} {
global botnick
if {[regexp -nocase "name" $text] || [regexp -nocase "nama" $text] > 0} {
	putserv "PRIVMSG $nick :gua susan"
	putserv "PRIVMSG $nick :loe sapa , oh yah kamu lagi ngapain aza skr say"
} }

bind msgm - "*" msg_kenal
proc msg_kenal {nick uhost hand text} {
global botnick
if {[regexp -nocase "kenalan" $text] || [regexp -nocase "gabung" $text] > 0} {
	putserv "PRIVMSG $nick :boleh aza , kamu asl nya donk $nick"
	putserv "PRIVMSG $nick :tapi gua hanya mau kenalan kalo kamu serius mau chat , gimana?"
	putserv "PRIVMSG $nick : bt kalo hanya sebatas asl trus diam"
} }

bind msgm - "*" msg_dodol
proc msg_dodol {nick uhost hand text} {
global botnick
if {[regexp -nocase "dodol" $text] || [regexp -nocase "dodol" $text] > 0} {
	putserv "PRIVMSG $nick :hehehe jangan omong dodol molo"
	putserv "PRIVMSG $nick :mau wa beliin dodol sekilo ngga $nick"
} }

putlog "==========="

set shio_chan "*"
set master 1
set shio {
{
".macam" {
 "6$nick 4: 7nama-nama shio : 14kambing(1943-1955-1967-1979), tikus(1948-1960-1972-1984), kerbau(1949-1961-1973-1985), macan(1950-1962-1974-1986), kelinci(1951-1963-1975-1987), naga(1952-1964-1976-1988), ular(1941-1953-1955-1977-1989), kuda(1942-1954-1966-1978), monyet(1944-1956-1968-1980), ayam(1945-1958-1970-1981), anjing(1946-1958-1970-1982), babi(1947-1959-1971-1983)" 
}
}
 {
".shio" {
 "6$nick 4: 14Penggunaan Perintah 1.14shio kambing 14atau Shio Yang Kamu Inginkan, 1!14macam : jenis/nama shio" 
} 
}
 {
  ".asmara" {
    "6$nick 4: 14Penggunaan Perintah 4.14asmara kambing 14atau Shio Yang Kamu Inginkan, 4!14macam : jenis/nama shio" }
 }
{
  ".asmara kambing*" {
   "4$nick, 3(15 Asmara KamBiNG 03) 14Adalah 7(1943-1955-1967-1979) 14Libidonya sangat tinggi, dan disarankan jika tidak bisa menahan alihkan ke hal lain, seperti kerja, olahraga dan kesibukan lain."
   }
 }
  {
   ".asmara tikus*" {
   "4$nick, 3(15 Asmara Tikus 03) 14Adalah 7(1948-1960-1972-1984) 14Kalau selesai melakukan hubungan intim, ia bisa tiba-tiba meninggalkan begitu saja pasangannya dan melesat ke cinta yang lain." 
   }
 }
{ 
".asmara kerbau*" { 
"4$nick, 3(15 Asmara Kerbau 03) 14Adalah 7(1949-1961-1973-1985) 14Perlu diketahui pasangannya, orang Kerbau adalah pasangan fair. Ia sangat mengerti keadaan pasangannya yang menginginkan berhubungan intim, maupun tidak."  
}
 }  
{
 ".asmara macan*" { 
"4$nick, 3(15 Asmara Macan 03) 14Adalah 7(1950-1962-1974-1986) 14Mereka cenderung liar dalam hal bercinta. Dia sangat menghargai dan melayani pasangannya. hubungan intim yang dilakukannya disamping dahsyat juga romantis."  
}
 }
{
 ".asmara kelinci*" { 
"4$nick, 3(15 Asmara Kelinci 03) 14Adalah 7(1951-1963-1975-1987) 14Karakteristik seks orang Kelinci tahun ini butuh warming up sebelum melakukan hubungan intim."  
}
 }
{
 ".asmara naga*" { 
"4$nick, 3(15 Asmara Naga 03) 14Adalah 7(1952-1964-1976-1988) 14Namun sebenarnya masa kejayaan mereka ada ditahun lalu, dan masih membekas. Karena itu mereka masih merasa berkuasa terhadap pasangannya. "  
}
 }
{
 ".asmara ular*" { 
"4$nick, 3(15 Asmara Ular 03) 14Adalah 7(1941-1953-1955-1977-1989) 14Ia suka malu-malu diajak hubungan intim. Karena itu ajakan sekali belum tentu digubris, tapi apabila sudah oke atau deal, seksnya dahsyat sekali."  
}
 }
{
 ".asmara kuda*" { 
"4$nick, 3(15 Asmara Kuda 03) 14Adalah 7(1942-1954-1966-1978) 14Mereka menemukan tehnik-tehnik baru yang disukai dalam hubungan intim. Sehingga gairahnya semakin memuncak untuk terus melakukan hubungan intim." 
 }
 }
{
 ".asmara monyet*" { 
"4$nick, 3(15 Asmara Monyet 03) 14Adalah 7(1944-1956-1968-1980) 14Orang Monyet jika melakukan hubungan intim dengan pasangannya, tidak pandang tempat & waktu." 
 }
 }
{
 ".asmara ayam*" { 
"4$nick, 3(15 Asmara Ayam 03) 14Adalah 7(1945-1958-1970-1981) 14Jika mereka menginginkan untuk melakukan hubungan intim, berjalan seperti biasanya. Tidak ada perubahan maupun hal yang baru." 
 }
 }
{
 ".asmara anjing*" { 
"4$nick, 3(15 Asmara Anjing 03) 14Adalah 7(1946-1958-1970-1982) 14Karena itu dalam melakukan hubungan seks di tahun Kambing ini, mereka agak malas untuk diajak hubungan intim." 
 }
 }
{
 ".asmara babi*" { 
"4$nick, 3(15 Asmara Babi  03) 14Adalah 7(1947-1959-1971-1983) 14hubungan intim yang telah dilakukan selama ini, tetap menjadi prioritas & selalu ada pencerahan mencoba beberapa hal yang baru."  
} 
}
{
".shio tikus" { 
"4$nick, 3(15 shio tikus 03)14 adalah Mudah menyesuaikan diri & kreatif. Orang shio tikus adlh pengamat yg dpt diandalkan & panjang akal. Meskipun mereka cepat 'belajar', cerdik & mudah bersosialisasi, orang shio tikus cenderung suka pamer, terkadang menyebutkan nama orang terkenal/sering disebut dgn 'cari muka." 
}
 }
{
".shio kerbau" { 
"4$nick, 3(15 shio kerbau 03)14 adalah Tabahan, mematuhi peraturan&cenderung menyukai hal bersifat rutin, dimn bg org lain dianggap membosankan. Dpt diandalkan&bijaksana. Keinginannya tuk berkompromi seringkali membuatnya tdk mampu menemukan suatu terobosan/inovasi hingga sering disebut tdk mempunyai imajinasi yg kreatif. Orang shio kerbau mencurigai sgl sesuatu yg blm dicoba&blm terbukti, krn takut ngambil inisiatif." 
} 
}
{
".shio harimau" { 
"4$nick, 3(15 shio harimau 03)14 adalah Terlahir Tuk jadi pemimpin,menghadapi persaingan tajam,tdk takut tuk berseteru.Tdk mudah dipengaruhi, figur sbg pemimpin alami tdk perlu diragukan.Harimau dpt jadi pemacu bg org lain,lewat tehnik bicr yg mampu meyakinkn org lain, ide yg bagus&terkadang tdk dihadapkan muncul dr mulutnya scr berurutan/lewat penampilan, dimn penampilan seringkali dirancang tuk nutupi kurangnya kepercayaan diri." 
} 
}
{
".shio kelinci" { 
"4$nick, 3(15 shio kelinci 03)14 adalah Butuh teman&ingin kehadirannya diterima org. Mrasa aman bl ada dlm lingkup mrk, mrk mrs terlindung&aman.Merasa perlu berhati &banyak kemungkinan jadi pendiam. Meski hidup dlm klompok,mrk dpt mmlihara kekebasan tertentu&dlm jadi ekstrover, seringkali dp jadi fokus utama pd penghujung suatu pristiwa. Sk bertmn&bersosialisasi tdk mnjamin bhw mrk ingin tuk menyendiri.Penurut malah terkesan rendah hati&trs brusaha menghindari sgl pertentangan."
 } 
}
{
".shio naga" { 
"4$nick, 3(15 shio naga 03)14 adalah pencinta hal yg eksotik. Perlente&punya pengamatan tajam pd kecenderungan (trend) terbaru.Imajinasi yg tdk pernah kering, slalu memimpikan ide&cr baru dlm brusaha. Tdk konsisten, dpt mmbuat putus-asa temannya&dlm pkerjaan dpt mnimbulkan kekacauan apabila tdk ada orang yg mampu ngambil alih.Kuat&penuh kyakinan, dlm menentukan jalur yg menariknya, dimana dia dpt menjadi pemimpin dimanapun juga." 
}
 }
{
".shio ular" { 
"4$nick, 3(15 shio ular 03)14 adalah Dapat mengendalikan diri&lebih beradab; tdk terlalu ekstrover. Suka Yg lembut&halus,Senang warna polos. Personalitasnya memungkinan mrk mencapai puncak, tapi mrk tdk akan mau bersusah payah, tapi memanfaatkan jasa orang lain tuk mencapainya. Mrk punya keyakinan bahwa mrk ada pd tempat yg tepat&pd waktu yg tepat, yg mengartikan bahwa merekalah orang yg tepat itu." 
}
 }
{
".shio kuda" { 
"4$nick, 3(15 shio kuda 03)14 adalah Terkadang takut dgn lawan jenis, terpesona, memuja padanya sekaligus meremehkan tetapi berhubungan dgn mrk - tdk akan pernah. Suka olah raga&aktivitas sosial, Mereka memerlukan suatu perasaan berhasil dan dilihat sebagai bagian dari suatu kelompok." 
} 
}
{
".shio kambing" { 
"4$nick, 3(15 shio kambing 03)14 adalah Kasih sayang, penuh perhatian, percaya&keperdulian pd orang lain. Puas pd diri sendiri&menghindari konfrontasi bilamana memungkinkan:Tdk mau diganggu,Diplomatis&seringkali berhasil, Bkn tipe pemimpin tapi tipe pengikut, Suka dibwh pengarahan orang lain&menyukai komunitas yg domokrasi., dimn keputusan diambil bersama." 
} 
}
{
".shio monyet" { 
"4$nick, 3(15 shio monyet 03)14 adalah Penemu&pikiran cerdas, digabung dgn sifat ingin tahu, Panjang akal, Punya siasat yang selalu berhasil meskipun dihadapkan pada situasi yang sulit. Tidak pernah kehabisan kata-kata atau ide-ide; tapi herannya dia tidak pernah kehabisan akal." 
} 
}
{
".shio ayam" { 
"4$nick, 3(15 shio ayam 03)14 adalah Berketetapan hati, kebanggaan&percaya diri. Pembawaan agak kasar&menyukai tindakan agresif, Naluri seorang usahawan yang peka tidak menghalangi orang bershio ayam berbuat seolah-olah membuat gerakan-gerakan spektakuler : tapi dalam kenyataannya tersembunyi motif bahwa mereka tidak ingin muncul dan hanya menjadi pengamat saja." 
}
 }
{
".shio anjing" { 
"4$nick, 3(15 shio anjing 03)14 adalah Setia, jujur&penuh humor,Mudah dpt teman&dpt jd teman sjati.Pkerja yg rajin, anggota suatu komunitas yg dpt dipercayai&dihargai.Kadang konservatisme, mmberi tolerasi pd ksulitan&ktidaknyamanan yg dialaminya drpd mlkkn prubahan GeDe. Swaktu lingkungan skitar mrk brbh&mmbr mrk problem, perlu waktu lm tuk menyesuaikan diri, tdk peduli pd kondisi yg sdh brubah&tetap mrasa bhw sgl suatu tdk seindah sprti masa lalu" 
}
 }
{
".shio babi" { 
"4$nick, 3(15 shio babi 03)14 adalah Tak ada ambisi GeDe dlm karir,Tetap memprlh manfaat drnya,pd akhirnya.Mlht kedpn tuk menikmati masa tenang.Pencinta rumah dimana misi utama mrk:keluarga.Ini:alamiah, tdk berpura, dia menikmati suasana krabat&gembira bersm.Cinta kluarga,tekun&jauh dr anggapan mls.Rmh mrk dpt menjd bukti ttg ketrampilan mrk dlm pekerjaan sbg tukang kayu,menjahit&keahlian lain yg terkait dgn rumah tangga" 
} 
}
{
".saran" { 
"3$nick14 : Membuat Orang yang kita sayang bahagia bukan selalu dari harta ataupun benda, mendengarkan serta melakukan apa yang diminta itu jauh memberi kebahagian buat orang yang kita sayang. « g0eZ » " 
"3$nick14 : Bersih pangkat sehat « g0eZ » " 
"3$nick14 : Kejarlah cita²mu sebelum cinta, karna dengan mengejar cita² maka cinta itu akan menghampirimu dengan sendirinya, so jangan kebalik. « g0eZ » " 
"3$nick14 : Kesehatan Adalah Anugerah Yang Termahal « g0eZ » " 
"3$nick14 : Orang yang sayang ialah orang yang rela meluangkan waktu berharganya buat Orang tersayang « g0eZ » " 
"3$nick14 : Kegagalan itu bukanlah halangan, yang mungkin membuat kamu putus asa, karna kegagalan itu adalah keberhasilan yang tertunda. « g0eZ » " 
"3$nick14 : Bersih itu adalah Sebagian dari Iman « g0eZ » " 
"3$nick14 : Menanyakan apa yang terjadi kepadanya lebih baik dari pada kamu berprasangka buruk « g0eZ » " 
"3$nick14 : Chat cuman abisin uang, tenaga dan waktu kamu ajah, carilah kesbukan yang lebih menguntungkan daripada chat!! « g0eZ » "
"3$nick14 : Saran² mlulu bayar dong!!! « g0eZ » "
"3$nick14 : Bersih pangkat sehat « g0eZ » "   
"3$nick14 : Bersih Diri Itu Langkah Awal Menjauhi Kemaksiatan « g0eZ » " 
"3$nick14 : Jika kita mencintai seseorang, kita akan senantiasa mendo'akannya walaupun dia tidak berada disisi kita. « g0eZ » "
"3$nick14 : Cintailah seseorang itu atas dasar siapa dia sekarang dan bukan siapa dia sebelumnya. « g0eZ » " 
"3$nick14 : Kisah silam tidak perlu diungkit lagi, kiranya kamu benar-benar mencintainya setulus hati. « g0eZ » "
"3$nick14 : Cinta adalah keabadian..dan kenangan adalah hal terindah yang pernah dimiliki. « g0eZ » "
"3$nick14 : Jika saja kehadiran cinta sekedar untuk mengecewakan, lebih baik cinta itu tak pernah hadir. « g0eZ » "
"3$nick14 : Kita mengerjakan segala sesuatu haruslah dengan tuntas, sempurna. Jangan sampai dicela, dikeluh orang, itulah yang terbaik. « g0eZ » "
"3$nick14 : Kita bekerja harus tanpa pamrih. Itu berlaku untuk segala pekerjaan. Pengabdian tanpa syarat adalah yang terbaik. « g0eZ » "
"3$nick14 : Anda selalu berlebih-lebihan dalam pekerjaan. Anda tidak tahu kapan untuk berhentinya. Inilah masalah yang sebenarnya. « g0eZ » "
"3$nick14 : Bekerja adalah untuk melatih diri, mengabdikan diri, demi amal bhakti atau balas budi kepada dunia atas segala pemberiannya. « g0eZ » "
"3$nick14 : Carilah uang secukupnya saja untuk membiayai kehidupan, agar dapat menyisihkan waktu dan tenaga untuk berlatih rohani. « g0eZ » "
"3$nick14 : Kita bekerja tidak semata-mata untuk mencari uang, melainkan untuk menunaikan kewajiban kita. « g0eZ » "
"3$nick14 : Membantu orang lain adalah membantu kita sendiri. Kita senantiasa harus membersihkan pikiran kita, mengamalkan cinta kasih dan kasih sayang kita dengan tanpa syarat, tidak mengharapkan sesuatu imbalan, itulah jalan terbaik. « g0eZ » "
"3$nick14 : Membantu orang untuk mencapai Kebebasan Abadi dan mengenal Ajaran Sejati adalah bantuan yang terbesar, jasa yang tertinggi. « g0eZ » "
"3$nick14 : Jika masih memikirkan untuk membela nama baik kita, wibawa kita, agar orang tahu bahwa kita sangat baik, maka kita masih mempunyai ke-aku-an, masih belum terbebas dari konsepsi orang awam. « g0eZ » "
"3$nick14 : Teguran dari orang lain merupakan suatu pujian! « g0eZ » "
"3$nick14 : Manusia terlalu sombong, kesombongan adalah karma kita yang paling merepotkan, rintangan yang terbesar. « g0eZ » "
"3$nick14 : Berterus terang kepada diri sendiri adalah berterus terang kepada siapapun. « g0eZ » "
"3$nick14 : Kita harus menemukan kekuatan kasih dalam diri kita terlebih dahulu, barulah kita dapat benar-benar mengasihi orang lain. « g0eZ » "
"3$nick14 : Jika kita tulus dan berdisiplin terhadap diri sendiri, maka orang lain akan jujur terhadap kita. « g0eZ » "
"3$nick14 : Carilah dulu Kerajaan Surga di dalam diri kita, kemudian kita akan memiliki segalanya. « g0eZ » "
"3$nick14 : Memperbaiki diri kita adalah memperbaiki dunia. « g0eZ » "
"3$nick14 : Jika kita menganggap diri kita lemah, maka kita akan menjadi lemah; jika kita menganggap diri kita agung, maka kita akan menjadi agung. « g0eZ » "
"3$nick14 : Kita harus dapat menghargai diri sendiri, baru kita akan dihormati oleh orang lain. « g0eZ » "
"3$nick14 : Perasaan bertobat dan rendah hati sangatlah penting, namun mencintai diri sendiri jauh lebih penting, jika Anda tidak dapat mencintai Anda sendiri, dapatkah Anda mencintai orang lain? « g0eZ » "
"3$nick14 : Lebih baik merugikan diri daripada melukai orang lain, ini adalah kebenaran yang selalu tidak boleh kita lupakan, meskipun peraturan disiplin yang lain kurang kita perhatikan, itu bukan masalah besar. « g0eZ » "
"3$nick14 : Jika kita tidak mengubah diri dengan latihan rohani, kita tidak dapat menghindari karma kita sendiri. « g0eZ » "
"3$nick14 : Tau nick g0eZ ga? Dia Cakep Loh!!! « g0eZ » "
"3$nick14 : Apakah karma perintang itu? Sesuatu yang tidak patut kita buat, yang akan merugikan kita sendiri, orang lain dan semua ciptaan. Setelah kita berbuat, kita akan menerima ganjaran dari Hukum Sebab Akibat. « g0eZ » "
"3$nick14 : Berani berucap harus berani bertindak. « genin » "
"3$nick14 : Orang bermulut besar kadang kala berotak kecil.« genin » "
"3$nick14 : Mulut yang senyap adalah lebih baik daripada mulut yang bising. « genin »"
"3$nick14 : Duri yang tajam masih tidak dapat mengalahkan lidah yang tajam. « genin » "
"3$nick14 : Senyum lah, karena ia adalah suatu sedekah =) « genin »"
"3$nick14 : Semanis-manis gula, manis senyuman melebihi segala-galanya. « genin »"
"3$nick14 : Berhati-hati saat berbicara karena lidah itu juga bisa tergigit sewaktu-waktu. « genin » "
"3$nick14 : Apabila otak dan tenaga bersatu, gunung batu yang kukuh dapat diratakan. « genin » "
"3$nick14 : Anda dapat melihat peluang tetapi anda tidak akan dapat mencapainya sekiranya anda masih tidak berusaha. « genin »"
"3$nick14 : Sekecil-kecil tubuh manusia masih mampu memecahkan masalah yang besar. « genin »"
"3$nick14 : Hidup yang buruk menjanjikan masa depan yang buruk. « genin »"
"3$nick14 : Angan-angan akan menjadi kenyataan apabila kita merealisasikannya. « genin »"
"3$nick14 : Harapan tidak akan datang sekiranya kita masih menunggunya. « genin »"
"3$nick14 : Tidak ada masalah yang tidak dapat diselesaikan kecuali masalah malas hendak berusaha. « genin »"
"3$nick14 : Jangan mendongak ke langit karena angkuh dan jangan menunduk ke bumi karena putus asa. « genin »"
"3$nick14 : Termenung tidak mendatangkan apa-apa manfaat sebaliknya berfikir banyak menyelesaikan masalah. « genin »"
"3$nick14 : Jangan anda sandarkan hari esok sebagai janji karena esok belum tentu menjanjikan apa-apa. « genin »"
"3$nick14 : Jangan jadikan keberhasilan sebagai kepuasan dan kegagalan sebagai kekecewaaan. « genin »"
"3$nick14 : Jangan sekali-kali menjadikan kesalahan dan kegagalan orang lain sebagai batu loncatan untuk maju ke depan. « genin »"
"3$nick14 : Orang yang ulet dalam kesabaran akan berhasil walaupun waktunya lama. « genin »"
"3$nick14 : Kesempatan-kesempatan cepat sekali hilangnya tetapi sulit sekali datangnya. « genin »"
"3$nick14 : Sabar adalah senjata yang paling ampuh dalam menghadapi segala situasi « genin »"
"3$nick14 : Penyebab duka adalah kesakitan pada hati yang tidak dirawat dengan segera. « genin »"
"3$nick14 : Kebaikan yang kita lakukan mungkin tidak diindahkan tetapi kejahatan yang kita lakukan biarpun sedikit akan menjadi omongan. « genin »"
"3$nick14 : Jangan anda lari dari yang sedikit semata-mata mengejar yang banyak karena dikhuatiri kedua-duanya akan tercecer. « genin »"
"3$nick14 : Jika anda menerima khabar baik atau khabar buruk, selidikilah kabar itu. Jangan langsung percaya. « genin »"
"3$nick14 : Manusia yang paling bodoh ialah manusia yang menganggap dirinya begitu. « genin »"
"3$nick14 : Pelangi masih kelihatan buruk apabila keluar pada saat yang menyedihkan. « genin »"
"3$nick14 : Bisikan orang busuk hati sama dengan bisikan syaitan. « genin »"
"3$nick14 : Sedungu-dungu keledai barangkali ia tertawa melihat perangai kita. « genin »"
"3$nick14 : Orang yang paling dibenci ialah orang yang memang suka dirinya dibenci. « egGo »"
"3$nick14 : Hewan yang tidak berfikiran masih bisa hidup tanpa bantuan tetapi manusia yang berakal tidak dapat hidup tanpa bantuan. « egGo »"
"3$nick14 : Tidak ada lubang hidung yang lebih besar daripada lubang hidung manusia yang sombong. « egGo »"
"3$nick14 : Yang perlu ditakuti ialah kesalahan sendiri yang diperhatikan oleh manusia lain. « egGo »"
"3$nick14 : Tidak ada beban yang paling menyakitkan daripada menanggung malu sekalipun pada kesalahan yang kecil. « egGo »"
"3$nick14 : Tiada yang baiknya pada sesuatu pujian melainkan di baliknya terkandung kemudaratan. « egGo »"
"3$nick14 : Menyerah dan mengeluh merupakan permulaan kegagalan. « egGo »"
"3$nick14 : Pada hati orang yang yakin, tidak ada rasa takut dan bimbang. « egGo »"
"3$nick14 : Tangisan seorang bayi adalah kata-kata yang paling benar tetapi tangisan orang dewasa ada muslihatnya. « egGo »"
"3$nick14 : Jangan anda menunjukkan protes dengan berlaku biadab. « egGo »"
"3$nick14 : Cinta itu buta tetapi perkahwinan akan memperlihatkan segala-galanya. « egGo »"
"3$nick14 : Masalah yang kecil akan menjadi besar apabila diheboh-hebohkan. « egGo »"
"3$nick14 : Cantik, buruk, dan bodoh itu bergantung pada penilaian. « egGo »"
"3$nick14 : Hormatilah hak orang lain semoga orang lain akan menghormati hak anda juga. « egGo »"
"3$nick14 : Duri di dalam daging adalah lebih busuk daripada bangkai. « egGo »"
"3$nick14 : Jangan dibuang empedu yang pahit karena kadang kala menjadi penawar yang mujarab. « egGo »"
"3$nick14 : Waspadalah dengan gula yang manis karena kadang kala dapat menjadi racun yang berbisa. « egGo »"
"3$nick14 : Jiwa yang sakit hanya diobati oleh ubat rohani. « egGo »"
"3$nick14 : Yang paling manis di dunia ini ialah pujian daripada seseorang yang ikhlas hatinya. « egGo »"
"3$nick14 : Selaut anak pun tidak akan berguna sekiranya ibu seorang tidak mampu dibela. « egGo »"
"3$nick14 : Barang siapa yang mau menerima pendapat orang lain maka ia akan mengetahui kesalahan-kesalahan (kekurangan yang ada pada dirinya). « egGo »"
"3$nick14 : Jangan meremehkan hal yang kecil yang dapat menjadi besar, dan jangan meremehkan yang sedikit yang mungkin dapat menjadi banyak. « egGo »"
"3$nick14 : Seseorang wanita dapat menyimpan cinta dalam hatinya selama empat puluh tahun tetapi dia tidak dapat menyimpan kebenciaannya meskipun satu jam saja. « egGo »"
"3$nick14 : Jangan iri dengki. Sesungguhnya iri dengki akan menggerogoti iman sebagaimana api menggerogoti kayu bakar. « egGo »"
"3$nick14 : Setiap kenikmatan yang tidak mendekatkan diri kepada Allah adalah bencana. « egGo »"
"3$nick14 : Orang yang paling bangkrut dalam hidupnya ialah orang yang kehilangan semangat hidupnya. « egGo »"
"3$nick14 : Merangkak tetapi sampai, lebih baik dari berlari tetapi putus di tengah jalan. « egGo » "
"3$nick14 : Orang berakal itu mempunyai dua kelebihan: akal yang ia dapat mengambil faedah (dengannya) dan perkataan yang ia dapat memberi faedah (dengannya). « egGo »"
"3$nick14 : Tidak ada kekayaan yang melebihi akal, dan tidak ada kemelaratan yang melebihi kebodohan. Tidak ada harta pusaka yang melebihi adab dan tidak ada benteng (pembela) yang melebihi musyawarah. « egGo »"
"3$nick14 : Ilmu hanya berguna apabila diajarkan kepada orang lain biarpun sedikit. « egGo »"
"3$nick14 : Biarlah anda ditertawakan karena anda bertanya daripada anda ditertawakan karena anda jahil. « egGo »"
"3$nick14 : Kopi apabila ditambah gula akan menjadi manis. Gadis apabila dididik dengan ilmu agama akan menjadi lebih manis. « egGo »"
"3$nick14 : Buku yang selalu dibaca tidak akan mengumpulkan habuk dan debu. « egGo »"
"3$nick14 : Sesungguhnya, bertanya itu memalukan tetapi di situlah bermulanya pengetahuan. « egGo »"
"3$nick14 : Perkara yang paling menyakitkan hati ialah apabila bertanya, diberi jawaban yang salah oleh orang yang berlagak pandai. « egGo » "
"3$nick14 : Manusia ditindas bukan karena lemah tetapi karena ilmu yang rendah. « egGo »"
"3$nick14 : Jangan mengkritik kalau kita bukan ahli dalam hal itu. « egGo »"
"3$nick14 : Ramai manusia yang punya keahlian tetapi tidak semuanya menggunakannya pada jalan yang benar. « egGo »"
"3$nick14 : Ilmu bukan barang dagangan yang bisa diletakkan harganya. « egGo »"
"3$nick14 : Walaupun anda seorang penasehat tetapi tidak berarti anda tidak boleh dinasehati juga. « egGo »"
"3$nick14 : Sahabat yang baik itu lebih baik bagimu karena nafsumu sangat cenderung kepada kejahatan, sedangkan sahabat yang baik itu, tidak ia menyuruh melainkan kebaikan. « egGo »"
"3$nick14 : Sebaik-baik teman adalah yang berkata benar kepada anda, bukannya mereka yang membenarkan apa-apa saja yang anda katakan. « egGo »"
"3$nick14 : Teman yang baik semakin dekat ketika anda susah tetapi teman yang jahat akan semakin dekat apabila anda senang. « egGo »"
"3$nick14 : Tidak ada kematian pada persahabatan sejati. « egGo »"
"3$nick14 : Dunia adalah komedi bagi mereka yang melakukannya, atau tragedi bagi mereka yang merasakannya. « aDJi »"
"3$nick14 : Ketahuilah, apapun yang menjadikanmu tergetar, itulah Yang Terbaik untukmu ! Dan karena itulah, Qalbu seorang pecinta-Nya lebih besar daripada Singgasana-Nya « aDJi »"
"3$nick14 : Sesungguhnya seseorang bisa disebut mandiri bukan lantaran ia sudah tidak lagi meminta, tapi lebih karena ia sudah bisa memberi harapan akan kembali diberi. « n0e »"
"3$nick14 : Cinta yang sejati tidak terletak pada apa yang telah dikerjakan dan diketahui, namun pada apa yang telah dikerjakan namun tidak diketahui. « n0e »"
"3$nick14 : Tak ada orang yang terlalu miskin sehingga tidak bisa memberikan pujian. « n0e »"
"3$nick14 : Kesehatan selalu tampak lebih berharga setelah kita kehilangannya. « genin »"
"3$nick14 : Kita tidak bisa menjadi bijaksana dengan kebijaksanaan orang lain, tapi kita bisa berpengetahuan dengan pengetahuan orang lain. « aDJi »"
"3$nick14 : Seorang konsultan psikologi paling jenius sekalipun tidak lebih mengerti tentang pikiran dan keinginan kita lebih daripada diri kita sendiri. « n0e »"
"3$nick14 : Salah satu fungsi diplomasi adalah untuk menutupi kenyataan dalam bentuk moralitas. « aDJi »"
"3$nick14 : Yang terpenting dari kehidupan bukanlah kemenangan namun bagaimana bertanding dengan baik. « aDJi »"
"3$nick14 : Yang terpenting dalam Olimpiade bukanlah kemenangan, tetapi keikutsertaan ... « aDJi »"
"3$nick14 : Jika pekerjaan Anda lenyap, jati diri Anda tidak akan pernah hilang. « genin »"
"3$nick14 : Jangan biarkan jati diri menyatu dengan pekerjaan Anda. « genin »"
"3$nick14 : Sumber kekuatan baru bukanlah uang yang berada dalam genggaman tangan beberapa orang, namun informasi di tangan orang banyak. « aDJi »"
"3$nick14 : Uang merupakan hamba yang sangat baik, tetapi tuan yang sangat buruk. « aDJi »"
"3$nick14 : Ingatlah, semua ini diawali dengan seekor tikus, Tanpa inspirasi.... kita akan binasa. « aDJi »"
"3$nick14 : Kita ada di sini bukan untuk saling bersaing. Kita ada di sini untuk saling melengkapi. « aDJi »"
"3$nick14 : Saat menghadapi kesulitan, beberapa orang tumbuh sayap, sedang yang lain mencari tongkat penyangga. « genin »"
"3$nick14 : Jika kita sungguh-sungguh menginginkan cinta, maka cintalah pada akhirnya yang justru menunggu kita. « aDJi »"
"3$nick14 : Kebebasan itu berasal dari manusia, tidak dari undang-undang atau institusi. « aDJi »"
"3$nick14 : Lebih mudah menambahkan sesuatu pada reputasi yang besar daripada untuk memperoleh reputasi itu sendiri. « n0e »"
"3$nick14 : Ketika kita menjadi tua, waktu akan membuat kita dikelilingi oleh orang-orang yang mencintai kita, sebagai ganti dari orang-orang yang kita cintai. « aDJi »"
"3$nick14 : Tak melakukan apa-apa merupakan kekuatan setiap orang. « aDJi »"
"3$nick14 : Keberanian bukanlah ketidakhadiran rasa takut, tetapi melakukannya « genin »"
"3$nick14 : Kegagalan biasanya merupakan langkah awal menuju sukses, tapi sukses itu sendiri sesungguhnya baru merupakan jalan tak berketentuan menuju puncak sukses. « aDJi »"
"3$nick14 : Pastikanlah bahwa kepala Anda tidak lebih tinggi dari topi Anda. « egGo »"
"3$nick14 : Tempat untuk berbahagia itu di sini. Waktu untuk berbahagia itu kini. Cara untuk berbahagia ialah dengan membuat orang lain berbahagia. « aDJi »"
"3$nick14 : Keberanian bukanlah ketidakhadiran rasa takut, tetapi melakukannya. « genin »"
"3$nick14 : Sifat Cinta: 1. Tidak membeda-bedakan 2. Cuma-cuma atau tanpa pamrih 3. Ketidaksadaran diri 4. Bebas « aDJi »"
"3$nick14 : Hanya ikan yang bodoh yang bisa dua kali kena pancing dengan umpan yang sama."
"3$nick14 : Kebanyakan dari kita yakin bisa membuat orang lain bahagia dengan cara yang kita tentukan. « aDJi »"
"3$nick14 : Jika kita sungguh-sungguh menginginkan cinta, maka cintalah pada akhirnya yang justru menunggu kita. « aDJi »"
"3$nick14 : Orang yang tidak bisa memaafkan orang lain sama saja dengan orang yang memutuskan jembatan yang harus dilaluinya, karena semua orang perlu di maafkan. « aDJi »"
"3$nick14 : Ada dua hal yang harus Anda lupakan: Kebaikan yang Anda lakukan kepada orang lain dan kesalahan orang lain kepada Anda. « aDJi »"
"3$nick14 : Suatu kehidupan yang penuh kesalahan tak hanya lebih berharga namun juga lebih berguna dibandingkan hidup tanpa melakukan apapun. « aDJi »"
"3$nick14 : Pengetahuan ada dua macam : yang telah kita ketahui dengan sendirinya atau yang hanya kita ketahui dimana ia bisa didapatkan. « aDJi »"
"3$nick14 : Berani berucap harus berani bertindak. « acem »"
"3$nick14 : Orang bermulut besar kadang kala berotak kecil. « acem »"
"3$nick14 : Mulut yang senyap adalah lebih baik daripada mulut yang bising. « acem »"
"3$nick14 : Duri yang tajam masih tidak dapat mengalahkan lidah yang tajam. « acem »"
"3$nick14 : Senyum lah, karena ia adalah suatu sedekah =) « acem »"
"3$nick14 : Semanis-manis gula, manis senyuman melebihi segala-galanya. « acem »"
"3$nick14 : Berhati-hati saat berbicara karena lidah itu juga bisa tergigit sewaktu-waktu. « acem »"
"3$nick14 : Apabila otak dan tenaga bersatu, gunung batu yang kukuh dapat diratakan. « acem »"
"3$nick14 : Anda dapat melihat peluang tetapi anda tidak akan dapat mencapainya sekiranya anda masih tidak berusaha. « acem »"
"3$nick14 : Sekecil-kecil tubuh manusia masih mampu memecahkan masalah yang besar. « acem »"
"3$nick14 : Hidup yang buruk menjanjikan masa depan yang buruk. « acem »"
"3$nick14 : Angan-angan akan menjadi kenyataan apabila kita merealisasikannya. « acem »"
"3$nick14 : Harapan tidak akan datang sekiranya kita masih menunggunya. « acem »"
"3$nick14 : Tidak ada masalah yang tidak dapat diselesaikan kecuali masalah malas hendak berusaha. « acem »"
"3$nick14 : Jangan mendongak ke langit karena angkuh dan jangan menunduk ke bumi karena putus asa. « acem »"
"3$nick14 : Termenung tidak mendatangkan apa-apa manfaat sebaliknya berfikir banyak menyelesaikan masalah. « acem »"
"3$nick14 : Jangan anda sandarkan hari esok sebagai janji karena esok belum tentu menjanjikan apa-apa. « acem »"
"3$nick14 : Jangan jadikan keberhasilan sebagai kepuasan dan kegagalan sebagai kekecewaaan. « acem »"
"3$nick14 : Jangan sekali-kali menjadikan kesalahan dan kegagalan orang lain sebagai batu loncatan untuk maju ke depan. « acem »"
"3$nick14 : Orang yang ulet dalam kesabaran akan berhasil walaupun waktunya lama. « acem »"
"3$nick14 : Kesempatan-kesempatan cepat sekali hilangnya tetapi sulit sekali datangnya. « acem »"
"3$nick14 : Sabar adalah senjata yang paling ampuh dalam menghadapi segala situasi « acem »"
"3$nick14 : Penyebab duka adalah kesakitan pada hati yang tidak dirawat dengan segera. « acem »"
"3$nick14 : Kebaikan yang kita lakukan mungkin tidak diindahkan tetapi kejahatan yang kita lakukan biarpun sedikit akan menjadi omongan. "
"3$nick14 : Jangan anda lari dari yang sedikit semata-mata mengejar yang banyak karena dikhuatiri kedua-duanya akan tercecer. "
"3$nick14 : Jika anda menerima khabar baik atau khabar buruk, selidikilah kabar itu. Jangan langsung percaya. "
"3$nick14 : Manusia yang paling bodoh ialah manusia yang menganggap dirinya begitu. « acem »"
"3$nick14 : Pelangi masih kelihatan buruk apabila keluar pada saat yang menyedihkan. « acem »"
"3$nick14 : Bisikan orang busuk hati sama dengan bisikan syaitan. « acem »"
"3$nick14 : Sedungu-dungu keledai barangkali ia tertawa melihat perangai kita. « acem »"
"3$nick14 : Orang yang paling dibenci ialah orang yang memang suka dirinya dibenci. « acem »"
"3$nick14 : Hewan yang tidak berfikiran masih bisa hidup tanpa bantuan tetapi manusia yang berakal tidak dapat hidup tanpa bantuan. « acem »"
"3$nick14 : Tidak ada lubang hidung yang lebih besar daripada lubang hidung manusia yang sombong. « acem »"
"3$nick14 : Yang perlu ditakuti ialah kesalahan sendiri yang diperhatikan oleh manusia lain. « acem »"
"3$nick14 : Tidak ada beban yang paling menyakitkan daripada menanggung malu sekalipun pada kesalahan yang kecil. « acem »"
"3$nick14 : Tiada yang baiknya pada sesuatu pujian melainkan di baliknya terkandung kemudaratan. « acem »"
"3$nick14 : Menyerah dan mengeluh merupakan permulaan kegagalan. « acem »"
"3$nick14 : Pada hati orang yang yakin, tidak ada rasa takut dan bimbang. « acem »"
"3$nick14 : Tangisan seorang bayi adalah kata-kata yang paling benar tetapi tangisan orang dewasa ada muslihatnya. « acem »"
"3$nick14 : Jangan anda menunjukkan protes dengan berlaku biadab. « acem »"
"3$nick14 : Cinta itu buta tetapi perkahwinan akan memperlihatkan segala-galanya. « acem »"
"3$nick14 : Masalah yang kecil akan menjadi besar apabila diheboh-hebohkan. « acem »"
"3$nick14 : Cantik, buruk, dan bodoh itu bergantung pada penilaian. « acem »"
"3$nick14 : Hormatilah hak orang lain semoga orang lain akan menghorma« acem »ti hak anda juga. « acem »"
"3$nick14 : Duri di dalam daging adalah lebih busuk daripada bangkai. « eggo »"
"3$nick14 : Jangan dibuang empedu yang pahit karena kadang kala menjadi penawar yang mujarab. « acem »"
"3$nick14 : Waspadalah dengan gula yang manis karena kadang kala dapat menjadi racun yang berbisa. « acem »"
"3$nick14 : Jiwa yang sakit hanya diobati oleh ubat rohani. « acem »"
"3$nick14 : Yang paling manis di dunia ini ialah pujian daripada seseorang yang ikhlas hatinya. « acem »"
"3$nick14 : Selaut anak pun tidak akan berguna sekiranya ibu seorang tidak mampu dibela. « acem »"
"3$nick14 : Barang siapa yang mau menerima pendapat orang lain maka ia akan mengetahui kesalahan-kesalahan (kekurangan yang ada pada dirinya). « acem »"
"3$nick14 : Jangan meremehkan hal yang kecil yang dapat menjadi besar, dan jangan meremehkan yang sedikit yang mungkin dapat menjadi banyak. « acem »"
"3$nick14 : Seseorang wanita dapat menyimpan cinta dalam hatinya selama empat puluh tahun tetapi dia tidak dapat menyimpan kebenciaannya meskipun satu jam saja. « acem »"
"3$nick14 : Jangan iri dengki. Sesungguhnya iri dengki akan menggerogoti iman sebagaimana api menggerogoti kayu bakar. « acem »"
"3$nick14 : Setiap kenikmatan yang tidak mendekatkan diri kepada Allah adalah bencana. « eggo »"
"3$nick14 : Orang yang paling bangkrut dalam hidupnya ialah orang yang kehilangan semangat hidupnya. « acem »"
"3$nick14 : Merangkak tetapi sampai, lebih baik dari berlari tetapi putus di tengah jalan. « acem »"
"3$nick14 : Orang berakal itu mempunyai dua kelebihan: akal yang ia dapat mengambil faedah (dengannya) dan perkataan yang ia dapat memberi faedah (dengannya). « eggo »"
"3$nick14 : Tidak ada kekayaan yang melebihi akal, dan tidak ada kemelaratan yang melebihi kebodohan. Tidak ada harta pusaka yang melebihi adab dan tidak ada benteng (pembela) yang melebihi musyawarah. « eggo »"
"3$nick14 : Ilmu hanya berguna apabila diajarkan kepada orang lain biarpun sedikit. « acem »"
"3$nick14 : Biarlah anda ditertawakan karena anda bertanya daripada anda ditertawakan karena anda jahil. « acem »"
"3$nick14 : Kopi apabila ditambah gula akan menjadi manis. Gadis apabila dididik dengan ilmu agama akan menjadi lebih manis. « acem »"
"3$nick14 : Buku yang selalu dibaca tidak akan mengumpulkan habuk dan debu. « acem »"
"3$nick14 : Sesungguhnya, bertanya itu memalukan tetapi di situlah bermulanya pengetahuan. « acem »"
"3$nick14 : Perkara yang paling menyakitkan hati ialah apabila bertanya, diberi jawaban yang salah oleh orang yang berlagak pandai. « acem »"
"3$nick14 : Manusia ditindas bukan karena lemah tetapi karena ilmu yang rendah. « acem »"
"3$nick14 : Jangan mengkritik kalau kita bukan ahli dalam hal itu. « acem »"
"3$nick14 : Ramai manusia yang punya keahlian tetapi tidak semuanya menggunakannya pada jalan yang benar. « acem »"
"3$nick14 : Ilmu bukan barang dagangan yang bisa diletakkan harganya. « eggo »"
"3$nick14 : Walaupun anda seorang penasehat tetapi tidak berarti anda tidak boleh dinasehati juga. « acem »"
"3$nick14 : Sahabat yang baik itu lebih baik bagimu karena nafsumu sangat cenderung kepada kejahatan, sedangkan sahabat yang baik itu, tidak ia menyuruh melainkan kebaikan. « acem »"
"3$nick14 : Sebaik-baik teman adalah yang berkata benar kepada anda, bukannya mereka yang membenarkan apa-apa saja yang anda katakan. « acem »"
"3$nick14 : Teman yang baik semakin dekat ketika anda susah tetapi teman yang jahat akan semakin dekat apabila anda senang. « acem »"
"3$nick14 : Tidak ada kematian pada persahabatan sejati. "
"3$nick14 : Dunia adalah komedi bagi mereka yang melakukannya, atau tragedi bagi mereka yang merasakannya. « acem »"
"3$nick14 : Ketahuilah, apapun yang menjadikanmu tergetar, itulah Yang Terbaik untukmu ! Dan karena itulah, Qalbu seorang pecinta-Nya lebih besar daripada Singgasana-Nya. « acem »"
"3$nick14 : Sesungguhnya seseorang bisa disebut mandiri bukan lantaran ia sudah tidak lagi meminta, tapi lebih karena ia sudah bisa memberi harapan akan kembali diberi. « acem »"
"3$nick14 : Cinta yang sejati tidak terletak pada apa yang telah dikerjakan dan diketahui, namun pada apa yang telah dikerjakan namun tidak diketahui. « acem »"
"3$nick14 : Tak ada orang yang terlalu miskin sehingga tidak bisa memberikan pujian. « acem »"
"3$nick14 : Kesehatan selalu tampak lebih berharga setelah kita kehilangannya. « acem »"
"3$nick14 : Kita tidak bisa menjadi bijaksana dengan kebijaksanaan orang lain, tapi kita bisa berpengetahuan dengan pengetahuan orang lain. « acem »"
"3$nick14 : Seorang konsultan psikologi paling jenius sekalipun tidak lebih mengerti tentang pikiran dan keinginan kita lebih daripada diri kita sendiri. « acem »"
"3$nick14 : Salah satu fungsi diplomasi adalah untuk menutupi kenyataan dalam bentuk moralitas. « acem »"
"3$nick14 : Yang terpenting dari kehidupan bukanlah kemenangan namun bagaimana bertanding dengan baik. « acem »"
"3$nick14 : Yang terpenting dalam Olimpiade bukanlah kemenangan, tetapi keikutsertaan ... « acem »"
"3$nick14 : Jika pekerjaan Anda lenyap, jati diri Anda tidak akan pernah hilang. « acem »"
"3$nick14 : Jangan biarkan jati diri menyatu dengan pekerjaan Anda. « acem »"
"3$nick14 : Sumber kekuatan baru bukanlah uang yang berada dalam genggaman tangan beberapa orang, namun informasi di tangan orang banyak. « acem »"
"3$nick14 : Uang merupakan hamba yang sangat baik, tetapi tuan yang sangat buruk. « acem »"
"3$nick14 : Ingatlah, semua ini diawali dengan seekor tikus, Tanpa inspirasi.... kita akan binasa. « acem »"
"3$nick14 : Kita ada di sini bukan untuk saling bersaing. Kita ada di sini untuk saling melengkapi. « acem »"
"3$nick14 : Saat menghadapi kesulitan, beberapa orang tumbuh sayap, sedang yang lain mencari tongkat penyangga. « acem »"
"3$nick14 : Jika kita sungguh-sungguh menginginkan cinta, maka cintalah pada akhirnya yang justru menunggu kita. « acem »"
"3$nick14 : Kebebasan itu berasal dari manusia, tidak dari undang-undang atau institusi. « acem »"
"3$nick14 : Lebih mudah menambahkan sesuatu pada reputasi yang besar daripada untuk memperoleh reputasi itu sendiri. « acem »"
"3$nick14 : Ketika kita menjadi tua, waktu akan membuat kita dikelilingi oleh orang-orang yang mencintai kita, sebagai ganti dari orang-orang yang kita cintai. « acem »"
"3$nick14 : Tak melakukan apa-apa merupakan kekuatan setiap orang. « acem »"
"3$nick14 : Keberanian bukanlah ketidakhadiran rasa takut, tetapi melakukannya « acem »"
"3$nick14 : Kegagalan biasanya merupakan langkah awal menuju sukses, tapi sukses itu sendiri sesungguhnya baru merupakan jalan tak berketentuan menuju puncak sukses. « acem »"
"3$nick14 : Pastikanlah bahwa kepala Anda tidak lebih tinggi dari topi Anda. « egGo »"
"3$nick14 : Tempat untuk berbahagia itu di sini. Waktu untuk berbahagia itu kini. Cara untuk berbahagia ialah dengan membuat orang lain berbahagia. « acem »"
"3$nick14 : Keberanian bukanlah ketidakhadiran rasa takut, tetapi melakukannya. « genin »"
"3$nick14 : Sifat Cinta: 1. Tidak membeda-bedakan 2. Cuma-cuma atau tanpa pamrih 3. Ketidaksadaran diri 4. Bebas « acem »"
"3$nick14 : Hanya ikan yang bodoh yang bisa dua kali kena pancing dengan umpan yang sama.« eggo »"
"3$nick14 : Kebanyakan dari kita yakin bisa membuat orang lain bahagia dengan cara yang kita tentukan. « acem »"
"3$nick14 : Jika kita sungguh-sungguh menginginkan cinta, maka cintalah pada akhirnya yang justru menunggu kita. « acem »"
"3$nick14 : Orang yang tidak bisa memaafkan orang lain sama saja dengan orang yang memutuskan jembatan yang harus dilaluinya, karena semua orang perlu di maafkan. « acem »"
"3$nick14 : Ada dua hal yang harus Anda lupakan: Kebaikan yang Anda lakukan kepada orang lain dan kesalahan orang lain kepada Anda. « acem »"
"3$nick14 : Suatu kehidupan yang penuh kesalahan tak hanya lebih berharga namun juga lebih berguna dibandingkan hidup tanpa melakukan apapun. « acem »"
"3$nick14 : Pengetahuan ada dua macam : yang telah kita ketahui dengan sendirinya atau yang hanya kita ketahui dimana ia bisa didapatkan. « acem »"
"3$nick14 : Berani berucap harus berani bertindak. « g0eZ »"
"3$nick14 : Orang bermulut besar kadang kala berotak kecil. « g0eZ »"
"3$nick14 : Mulut yang senyap adalah lebih baik daripada mulut yang bising. « g0eZ »"
"3$nick14 : Duri yang tajam masih tidak dapat mengalahkan lidah yang tajam. « g0eZ »"
"3$nick14 : Senyum lah, karena ia adalah suatu sedekah =) « g0eZ »"
"3$nick14 : Semanis-manis gula, manis senyuman melebihi segala-galanya. « g0eZ »"
"3$nick14 : Berhati-hati saat berbicara karena lidah itu juga bisa tergigit sewaktu-waktu. « g0eZ »"
"3$nick14 : Apabila otak dan tenaga bersatu, gunung batu yang kukuh dapat diratakan. « g0eZ »"
"3$nick14 : Anda dapat melihat peluang tetapi anda tidak akan dapat mencapainya sekiranya anda masih tidak berusaha. « g0eZ »"
"3$nick14 : Sekecil-kecil tubuh manusia masih mampu memecahkan masalah yang besar. « g0eZ »"
"3$nick14 : Hidup yang buruk menjanjikan masa depan yang buruk. « g0eZ »"
"3$nick14 : Angan-angan akan menjadi kenyataan apabila kita merealisasikannya. « g0eZ »"
"3$nick14 : Harapan tidak akan datang sekiranya kita masih menunggunya. « g0eZ »"
"3$nick14 : Tidak ada masalah yang tidak dapat diselesaikan kecuali masalah malas hendak berusaha. « g0eZ »"
"3$nick14 : Jangan mendongak ke langit karena angkuh dan jangan menunduk ke bumi karena putus asa. « g0eZ »"
"3$nick14 : Termenung tidak mendatangkan apa-apa manfaat sebaliknya berfikir banyak menyelesaikan masalah. « g0eZ »"
"3$nick14 : Jangan anda sandarkan hari esok sebagai janji karena esok belum tentu menjanjikan apa-apa. « g0eZ »"
"3$nick14 : Jangan jadikan keberhasilan sebagai kepuasan dan kegagalan sebagai kekecewaaan. « g0eZ »"
"3$nick14 : Jangan sekali-kali menjadikan kesalahan dan kegagalan orang lain sebagai batu loncatan untuk maju ke depan. « g0eZ »"
"3$nick14 : Orang yang ulet dalam kesabaran akan berhasil walaupun waktunya lama. « g0eZ »"
"3$nick14 : Kesempatan-kesempatan cepat sekali hilangnya tetapi sulit sekali datangnya. « g0eZ »"
"3$nick14 : Sabar adalah senjata yang paling ampuh dalam menghadapi segala situasi « g0eZ »"
"3$nick14 : Penyebab duka adalah kesakitan pada hati yang tidak dirawat dengan segera. « g0eZ »"
"3$nick14 : Kebaikan yang kita lakukan mungkin tidak diindahkan tetapi kejahatan yang kita lakukan biarpun sedikit akan menjadi omongan. "
"3$nick14 : Jangan anda lari dari yang sedikit semata-mata mengejar yang banyak karena dikhuatiri kedua-duanya akan tercecer. "
"3$nick14 : Jika anda menerima khabar baik atau khabar buruk, selidikilah kabar itu. Jangan langsung percaya. "
"3$nick14 : Manusia yang paling bodoh ialah manusia yang menganggap dirinya begitu. « g0eZ »"
"3$nick14 : Pelangi masih kelihatan buruk apabila keluar pada saat yang menyedihkan. « g0eZ »"
"3$nick14 : Bisikan orang busuk hati sama dengan bisikan syaitan. « g0eZ »"
"3$nick14 : Sedungu-dungu keledai barangkali ia tertawa melihat perangai kita. « g0eZ »"
"3$nick14 : Orang yang paling dibenci ialah orang yang memang suka dirinya dibenci. « g0eZ »"
"3$nick14 : Hewan yang tidak berfikiran masih bisa hidup tanpa bantuan tetapi manusia yang berakal tidak dapat hidup tanpa bantuan. « g0eZ »"
"3$nick14 : Tidak ada lubang hidung yang lebih besar daripada lubang hidung manusia yang sombong. « g0eZ »"
"3$nick14 : Yang perlu ditakuti ialah kesalahan sendiri yang diperhatikan oleh manusia lain. « g0eZ »"
"3$nick14 : Tidak ada beban yang paling menyakitkan daripada menanggung malu sekalipun pada kesalahan yang kecil. « g0eZ »"
"3$nick14 : Tiada yang baiknya pada sesuatu pujian melainkan di baliknya terkandung kemudaratan. « g0eZ »"
"3$nick14 : Menyerah dan mengeluh merupakan permulaan kegagalan. « g0eZ »"
"3$nick14 : Pada hati orang yang yakin, tidak ada rasa takut dan bimbang. « g0eZ »"
"3$nick14 : Tangisan seorang bayi adalah kata-kata yang paling benar tetapi tangisan orang dewasa ada muslihatnya. « g0eZ »"
"3$nick14 : Jangan anda menunjukkan protes dengan berlaku biadab. « g0eZ »"
"3$nick14 : Cinta itu buta tetapi perkahwinan akan memperlihatkan segala-galanya. « g0eZ »"
"3$nick14 : Masalah yang kecil akan menjadi besar apabila diheboh-hebohkan. « g0eZ »"
"3$nick14 : Cantik, buruk, dan bodoh itu bergantung pada penilaian. « g0eZ »"
"3$nick14 : Hormatilah hak orang lain semoga orang lain akan menghorma« g0eZ »ti hak anda juga. « g0eZ »"
"3$nick14 : Duri di dalam daging adalah lebih busuk daripada bangkai. "
"3$nick14 : Jangan dibuang empedu yang pahit karena kadang kala menjadi penawar yang mujarab. « g0eZ »"
"3$nick14 : Waspadalah dengan gula yang manis karena kadang kala dapat menjadi racun yang berbisa. « g0eZ »"
"3$nick14 : Jiwa yang sakit hanya diobati oleh ubat rohani. « g0eZ »"
"3$nick14 : Yang paling manis di dunia ini ialah pujian daripada seseorang yang ikhlas hatinya. « g0eZ »"
"3$nick14 : Selaut anak pun tidak akan berguna sekiranya ibu seorang tidak mampu dibela. « g0eZ »"
"3$nick14 : Barang siapa yang mau menerima pendapat orang lain maka ia akan mengetahui kesalahan-kesalahan (kekurangan yang ada pada dirinya). « g0eZ »"
"3$nick14 : Jangan meremehkan hal yang kecil yang dapat menjadi besar, dan jangan meremehkan yang sedikit yang mungkin dapat menjadi banyak. « g0eZ »"
"3$nick14 : Seseorang wanita dapat menyimpan cinta dalam hatinya selama empat puluh tahun tetapi dia tidak dapat menyimpan kebenciaannya meskipun satu jam saja. « g0eZ »"
"3$nick14 : Jangan iri dengki. Sesungguhnya iri dengki akan menggerogoti iman sebagaimana api menggerogoti kayu bakar. « g0eZ »"
"3$nick14 : Setiap kenikmatan yang tidak mendekatkan diri kepada Allah adalah bencana. « eggo »"
"3$nick14 : Orang yang paling bangkrut dalam hidupnya ialah orang yang kehilangan semangat hidupnya. « g0eZ »"
"3$nick14 : Merangkak tetapi sampai, lebih baik dari berlari tetapi putus di tengah jalan. « g0eZ »"
"3$nick14 : Orang berakal itu mempunyai dua kelebihan: akal yang ia dapat mengambil faedah (dengannya) dan perkataan yang ia dapat memberi faedah (dengannya). « eggo »"
"3$nick14 : Tidak ada kekayaan yang melebihi akal, dan tidak ada kemelaratan yang melebihi kebodohan. Tidak ada harta pusaka yang melebihi adab dan tidak ada benteng (pembela) yang melebihi musyawarah. « eggo »"
"3$nick14 : Ilmu hanya berguna apabila diajarkan kepada orang lain biarpun sedikit. « g0eZ »"
"3$nick14 : Biarlah anda ditertawakan karena anda bertanya daripada anda ditertawakan karena anda jahil. « g0eZ »"
"3$nick14 : Kopi apabila ditambah gula akan menjadi manis. Gadis apabila dididik dengan ilmu agama akan menjadi lebih manis. « g0eZ »"
"3$nick14 : Buku yang selalu dibaca tidak akan mengumpulkan habuk dan debu. « g0eZ »"
"3$nick14 : Sesungguhnya, bertanya itu memalukan tetapi di situlah bermulanya pengetahuan. « g0eZ »"
"3$nick14 : Perkara yang paling menyakitkan hati ialah apabila bertanya, diberi jawaban yang salah oleh orang yang berlagak pandai. « g0eZ »"
"3$nick14 : Manusia ditindas bukan karena lemah tetapi karena ilmu yang rendah. « g0eZ »"
"3$nick14 : Jangan mengkritik kalau kita bukan ahli dalam hal itu. « g0eZ »"
"3$nick14 : Ramai manusia yang punya keahlian tetapi tidak semuanya menggunakannya pada jalan yang benar. « g0eZ »"
"3$nick14 : Ilmu bukan barang dagangan yang bisa diletakkan harganya. "
"3$nick14 : Walaupun anda seorang penasehat tetapi tidak berarti anda tidak boleh dinasehati juga. « g0eZ »"
"3$nick14 : Sahabat yang baik itu lebih baik bagimu karena nafsumu sangat cenderung kepada kejahatan, sedangkan sahabat yang baik itu, tidak ia menyuruh melainkan kebaikan. « g0eZ »"
"3$nick14 : Sebaik-baik teman adalah yang berkata benar kepada anda, bukannya mereka yang membenarkan apa-apa saja yang anda katakan. « g0eZ »"
"3$nick14 : Teman yang baik semakin dekat ketika anda susah tetapi teman yang jahat akan semakin dekat apabila anda senang. « g0eZ »"
"3$nick14 : Tidak ada kematian pada persahabatan sejati. « eggo »"
"3$nick14 : Dunia adalah komedi bagi mereka yang melakukannya, atau tragedi bagi mereka yang merasakannya. « g0eZ »"
"3$nick14 : Ketahuilah, apapun yang menjadikanmu tergetar, itulah Yang Terbaik untukmu ! Dan karena itulah, Qalbu seorang pecinta-Nya lebih besar daripada Singgasana-Nya. « g0eZ »"
"3$nick14 : Sesungguhnya seseorang bisa disebut mandiri bukan lantaran ia sudah tidak lagi meminta, tapi lebih karena ia sudah bisa memberi harapan akan kembali diberi. « g0eZ »"
"3$nick14 : Cinta yang sejati tidak terletak pada apa yang telah dikerjakan dan diketahui, namun pada apa yang telah dikerjakan namun tidak diketahui. « g0eZ »"
"3$nick14 : Tak ada orang yang terlalu miskin sehingga tidak bisa memberikan pujian. « g0eZ »"
"3$nick14 : Kesehatan selalu tampak lebih berharga setelah kita kehilangannya. « g0eZ »"
"3$nick14 : Kita tidak bisa menjadi bijaksana dengan kebijaksanaan orang lain, tapi kita bisa berpengetahuan dengan pengetahuan orang lain. « g0eZ »"
"3$nick14 : Seorang konsultan psikologi paling jenius sekalipun tidak lebih mengerti tentang pikiran dan keinginan kita lebih daripada diri kita sendiri. « g0eZ »"
"3$nick14 : Salah satu fungsi diplomasi adalah untuk menutupi kenyataan dalam bentuk moralitas. « g0eZ »"
"3$nick14 : Yang terpenting dari kehidupan bukanlah kemenangan namun bagaimana bertanding dengan baik. « g0eZ »"
"3$nick14 : Yang terpenting dalam Olimpiade bukanlah kemenangan, tetapi keikutsertaan ... « g0eZ »"
"3$nick14 : Jika pekerjaan Anda lenyap, jati diri Anda tidak akan pernah hilang. « g0eZ »"
"3$nick14 : Jangan biarkan jati diri menyatu dengan pekerjaan Anda. « g0eZ »"
"3$nick14 : Sumber kekuatan baru bukanlah uang yang berada dalam genggaman tangan beberapa orang, namun informasi di tangan orang banyak. « g0eZ »"
"3$nick14 : Uang merupakan hamba yang sangat baik, tetapi tuan yang sangat buruk. « g0eZ »"
"3$nick14 : Ingatlah, semua ini diawali dengan seekor tikus, Tanpa inspirasi.... kita akan binasa. « g0eZ »"
"3$nick14 : Kita ada di sini bukan untuk saling bersaing. Kita ada di sini untuk saling melengkapi. « g0eZ »"
"3$nick14 : Saat menghadapi kesulitan, beberapa orang tumbuh sayap, sedang yang lain mencari tongkat penyangga. « g0eZ »"
"3$nick14 : Jika kita sungguh-sungguh menginginkan cinta, maka cintalah pada akhirnya yang justru menunggu kita. « g0eZ »"
"3$nick14 : Kebebasan itu berasal dari manusia, tidak dari undang-undang atau institusi. « g0eZ »"
"3$nick14 : Lebih mudah menambahkan sesuatu pada reputasi yang besar daripada untuk memperoleh reputasi itu sendiri. « g0eZ »"
"3$nick14 : Ketika kita menjadi tua, waktu akan membuat kita dikelilingi oleh orang-orang yang mencintai kita, sebagai ganti dari orang-orang yang kita cintai. « g0eZ »"
"3$nick14 : Tak melakukan apa-apa merupakan kekuatan setiap orang. « g0eZ »"
"3$nick14 : ngebut benjut « spy_dol »"
"3$nick14 : ngremet asalkan slamet « spy_dol »"
"3$nick14 : pelan yang penting jalan « spy_dol »"
"3$nick14 : gak ada akar eggo pun jadi « okelah »"
"3$nick14 : 1 + 1 - 1 = 1 « eggoez »"
"3$nick14 : ribbbbbbbbeeeet banget jadi manusia « eggoez »"
"3$nick14 : tetap semangaaatttttttttt!!!! « catHy »"
"3$nick14 : Tak Kan Ada Yang Abadi Di Dunia Ini « eggoez »"
"3$nick14 : Keberanian bukanlah ketidakhadiran rasa takut, tetapi melakukannya « g0eZ »"
"3$nick14 : Kegagalan biasanya merupakan langkah awal menuju sukses, tapi sukses itu sendiri sesungguhnya baru merupakan jalan tak berketentuan menuju puncak sukses. « g0eZ »"
"3$nick14 : Pastikanlah bahwa kepala Anda tidak lebih tinggi dari topi Anda. « egGo »"
"3$nick14 : Tempat untuk berbahagia itu di sini. Waktu untuk berbahagia itu kini. Cara untuk berbahagia ialah dengan membuat orang lain berbahagia. « g0eZ »"
"3$nick14 : Keberanian bukanlah ketidakhadiran rasa takut, tetapi melakukannya. « genin »"
"3$nick14 : Sifat Cinta: 1. Tidak membeda-bedakan 2. Cuma-cuma atau tanpa pamrih 3. Ketidaksadaran diri 4. Bebas « g0eZ »"
"3$nick14 : Hanya ikan yang bodoh yang bisa dua kali kena pancing dengan umpan yang sama."
"3$nick14 : Kebanyakan dari kita yakin bisa membuat orang lain bahagia dengan cara yang kita tentukan. « g0eZ »"
"3$nick14 : Jika kita sungguh-sungguh menginginkan cinta, maka cintalah pada akhirnya yang justru menunggu kita. « g0eZ »"
"3$nick14 : Orang yang tidak bisa memaafkan orang lain sama saja dengan orang yang memutuskan jembatan yang harus dilaluinya, karena semua orang perlu di maafkan. « g0eZ »"
"3$nick14 : Ada dua hal yang harus Anda lupakan: Kebaikan yang Anda lakukan kepada orang lain dan kesalahan orang lain kepada Anda. « g0eZ »"
"3$nick14 : Suatu kehidupan yang penuh kesalahan tak hanya lebih berharga namun juga lebih berguna dibandingkan hidup tanpa melakukan apapun. « g0eZ »"
"3$nick14 : Pengetahuan ada dua macam : yang telah kita ketahui dengan sendirinya atau yang hanya kita ketahui dimana ia bisa didapatkan. « g0eZ »"
 }
 }
}

bind pubm - * pub_shio
if {$master==1} {
}

proc pub_shio {nick uhost hand chan arg} {
 global shio shio_chan botnick
 if {(([lsearch -exact [string tolower $shio_chan] [string tolower $chan]] != -1) || ($shio_chan == "*")) && (![matchattr $hand b]) && ($nick != $botnick)} {
  foreach i $shio {
   if {[string match [string tolower [lindex $i 0]] [string tolower $arg]]} {
    putserv "PRIVMSG $chan :[subst [lindex [lindex $i 1] [rand [llength [lindex $i 1]]]]]"
   }
  }
 }
}

putlog "============"
bind mode - * thanksfor:mode

proc thanksfor:mode { nick host hand chan mode target } {
global botnick
if {$target == $botnick} {
   if {$mode == "+v"} { 
	   puthelp "PRIVMSG $chan :15M14akasih 15U14ntuk 15Voice14-nya $nick"
      }
	  if {$mode == "-v"} { 
	   puthelp "PRIVMSG $chan :15H14adah 15K14ok 15DeVoice14 Sih $nick"
      }
   if {$mode == "+o"} { 
	   puthelp "PRIVMSG $chan :15M14akasih 15U14ntuk 15Op14-nya $nick"
      }
	  if {$mode == "-o"} { 
	   puthelp "PRIVMSG $chan :15H14adah 15K14ok 15DeOp14 Sih $nick"
      }
	 if {$mode == "+h"} { 
	   puthelp "PRIVMSG $chan :15M14akasih 15U14ntuk 15HalfOp14-nya0 $nick"
   }
   if {$mode == "-h"} { 
	   puthelp "PRIVMSG $chan :15H14adah 15K14ok 15DeHalfOp14 Sih $nick"
      }
}
}
putlog "============="

set speaks_chans "*"
set speaks_time 500
set hello_chans "*"
set brb_chans "*"
set bye_chans "*"
set ping_chans "*"

set spoken.v "Auto talk"
# Set the next lines as the random speaks msgs you want to say
set speaks_msg {
{"owgh nooo.. keyboard aq rusak.. jiakakakakak"}
{"\001ACTION tarik g0eZ\001"}
{"\001ACTION ciumin bibir g0eZ\001"}
{"\001ACTION is away (4Be 4Right 4Back)\001"}
{"\001ACTION slaps g0eZ around a bit with a large trout\001"}
{"\001ACTION bisik² di telinga catHy lagi apa?\001"}
{"\001ACTION 13lukis²06 idungnya 04 sHizuKa 06 11 j13a11d13i 04a r08a09i11n13b01o10w\001"}
{"\001ACTION 15Tabok catHy Pake 4Bunga Sekalian 7Tanah dan 12Potnya :P\001"}
{"\001ACTION celupin g0eZ ke aspal panas....gulung2 diatas paku payung....digilas pake eskavator.....diiris2 pake gergaji mesin....dipake nimbun lubang lumpur lapindo\001"}
{"\001ACTION 12Lempar 13 spy_dol 12 pake Eskavator 04 Bruakk...!!!\001"}
{"emuachhhh..."}
{"ring xixixixiix"}
{"aku bukan pengemis cintaaa..."}
{"masa sich.."}
{"lho.. si g0eZ sayank td mana?"}
{"*celingak celinguk*"}
{"hush.. hushh hushh ..."}
{"hoyyyy..."}
{"mas, egGo mana yachh ?..."}
{"yak desgghh..."}
{"bleuh"}
{"weh ada cewek"}
{"welah"}
{"hoekkkkk !!!!"}
{"wik !"}
{"hiyek"}
{"emang ?"}
{"GRRRRRRRRRRR"}
{"woooooooo"}
{"au ah gelap"}
{"halo sapa nih"}
{"pokoknya gue asyik jek"}
{"xuxuxux,,,lucu juga ya "}
{"Hormattt !!!!! Grak !"}
{"ah pada kujum nih.."}
{"bubar bubar !"}
{"aahh.. seneeeeengg..!!!!"}
{"nantuk..."}
{"*sigh*"}
{"*blah* =p~"}
{"capek bangeett..!!!"}
{"arrgh.. dammit !"}
{"*hiks*"}
{"sebel..!!"}
{"kalo ketiduran gimana ?"}
{"udah kayak ibu-ibu rumah tangga deh gue..!"}
{"huwaa.. !"}
{"mirip ngga ?"}
{"libur euy..!!"}
{"ring kekekkeke.!!"}
{"pamit dolo kawans..."}
{"masa?"}  
{"freak !"}
{"immortal rejection! "}
{"1 +1 - 1 = 1"}
{"hmm... emang lagi apa??"}
{"dah maem kan??"}
{"huek.. kenyaaaangg.. !"}
{"see ? i'm a survivor..!"}
{"cuci-cuci mata donk.. "}
{"aduhh.. itu bener-bener deh.. *hiks* "}
{"aceman loe..."}
{"begini"}
{"lho"}
{"g0eZ <: badung ni anak ( katanya sih )"}
{"hah"}
{"brisik"}
{"mama mama"}
{"beli bakso dolo lah..."}
{"/ns id kdlkdlskdlsldjskdjsk"}
{"laper!"}
{"wik"}
{"wooow keren skallii"}
{"anu dulu ah..."}
{"gwe keren kan?"}
{"ada yang punya ef be gak nick??"}
{"duarrrrrrrrrr!!!"}
{"weleh-weleh"}
{"cleguks"}
{"glekz"}
{"GuBraaKKKKK--^^"}
{"hmmm.. chat bikin sebel aja..."}
{"tiada hari tanpa sendiri"}
{"main uno dulu ah"}
{"kok jadi ngomong sendiri gw.."}
{"ah... jadi kebelet gwe"}
{"ada yang punya psy gak nih??"}
{"sewa bot berapa ya om??"}
{"aduh lupa gak gwe tutup tadi.."}
{"semangat....."}
{"tak ada yang abadi"}
{"gue crewet ya..."}
{"ajarin aku buat bot donk..."}
{"bos bos... gue minta SOP nya"}
{"walah......"}
{"acemmmmmmmmmm"}
{"kagak kuat gue.."}
{"tarik mang.."}
{"ah elo.."}
{"ealah.."}
{"siapa yang pv gue tadi.."}
{"males ah..."}
{"gue pipis dolo ea..."}
{"bikin susu coklat dulu ah..."}
{"aku gak kemana² tp aku ada di mana²"}
{"anday ada kesempatan ke 3"}
{"!seen g0eZ"}
{"mad mad beliin gwe pulsa donk mad.."}
{"heuheuheuheuehueheuheu"}
{"aw aw aw"}
{"sakit om.."}
{"jangan om"}
{"kul gak lulus lg..."}
{"aduh.. apes banget gwe"}
{"kapan itu?"}
{"brb ( masih mencari )"}
{"wkwkwkwkwkwkwkwk"}
{"eh eh...."}
{"kalo seandainya aku g ol apa di cari ya??"}
{"uang tinggal 3 ribu mau beli pulsa.. gak jadi ah..."}
{"oh goD"}
{"bos g0eZ td mana yah..."}
{"hmmmmmmmmm...."}
{"mikir bentaran yah.."}
{"ewh.."}
{"jiah..."}
{"begh.."}
{"tid tid tid... ada sms nih.."}
{"sms yayankz dolo ah..."}
{"di jamin puasSSS"}
{"alamat ef loe apa bro?"}
{"di sms gak balesin..."}
{"iya tah?"}
{"ahay..."}
{"kagak bisa bobok gue.."}
{"sipppp.."}
{"jadi donk say..."}
{"perasaan ada yang panggil yah.."}
{"boSS adem bos..."}
{"aku iki sopo nginvite rene..."}
{"duh lemot..."}
{"dc lagi dc lagi... hobi kok dc mlulu"}
{"huhuhuhuhuhuhuh..."}
{"Duh gwe dapet lagi ini.."}
{"mau enaknya aja loe.. anaknya kagak mau.."}
{"dasar pecundang.."}
{"kangen kamu yank.."}
{"dimanakah aku inih..."}
{"@_@"}
{"^_^"}
{"*_*"}
{"o_O"}
{"x_X"}
{"entah lah.."}
{"mau kencan dulu say.."}
{"kujum?"}
{"gak maooo..."}
{"guz.."}
{"hello..."}
{"waks..."}
{"i am nothing with you.."}
{"alone..."}
{"ah cepek.."}
{"crutz.."}
{"aw... aw..."}
{"hmmmmmmmmmmmmmmmmmmmmmmm.."}
{"apa lo.. hueheuheuhe"}
{"gak papa gak mama sama ajah.."}
{"tunggu!!"}
{"ada esemes.."}
{"bot.."}
{"ngeri juga gwe.."}
{"aku menunggumu disini.."}
{"bicara donk.."}
{"ah elo.."}
{"ngomong kek dr tadi.."}
{"ekekekekekeke"}
{"wkwkwkwkwkwkwkw"}
{"jijik aku.."}
{"\001ACTION Diam Diam DC..\001"}
{"derita loe.."}
{"cumi..."}
{"takut.. :C"}
{"iya iya..."}
}

if {![string match "*speaks_time*" [timers]]} {
 timer $speaks_time time_speaks
}

proc time_speaks {} {
 global speaks_msg speaks_chans speaks_time
 if {$speaks_chans == "*"} {
  set speaks_temp [channels]
 } else {
  set speaks_temp $speaks_chans
 }
 foreach chan $speaks_temp {
  set speaks_rmsg [lindex $speaks_msg [rand [llength $speaks_msg]]]
  foreach msgline $speaks_rmsg {
   puthelp "PRIVMSG $chan :[subst $msgline]"
  }
 }
 if {![string match "*time_speaks*" [timers]]} {
  timer $speaks_time time_speaks
 }
}



##  hello ##
set Reponden3.v "hello Respon"
bind pub - hello hello_speak 
bind pub - alo hello_speak 
bind pub - aloo hello_speak 
bind pub - alooo hello_speak 
bind pub - hallo hello_speak 
bind pub - hai hello_speak 
bind pub - hi hello_speak 

set ranhello {
  "hello there, nice to meet you"
  "hello how are you ^_^"
  "ramein channel donk saayyyy"
  "halo halo bandung, wakil bos gua orang Makassar"
  "Hi too, ohh ur so cutee xP~"
  "halooooooooo"
  "apaaaaaaa , suka yaaaaa ma Saya,hmm"
  "chat in channel please"
  "yes, Hello too, do I know ya ?"
  "alo sayank"
  "Hi there"
  "hello, whats up"
  "oi oi oi oi oi"  
  "Halo juga nich, kamu sapa nich, kok sok kenal banget ma saya =P"
  "hello how are you ^_^"
  "Hai bro apa kabarmu, bagaimana dengan kabar keluargamu ?"
  "hey whats up"
  "yeah, yeah hi HI"
  "hello, nice to see yea!"
  "Hi i'm happy today!!"
  "hai hai hai hai juga"
  "apa khbar nich nama kamu siapa"
  "halo juga perkenalkan nama ku Yazmien Octavia, kalau kamu siapa?"
  "asl gua = 20 f jember, rumah gua di kencong , tebak yg mana :P"
  "hi ,  =)  , kenalan yukk"
  "asl pls, I like to chat with you in channel"
  "Hi juga, kamu makin kiyut aja dech, gemesssss"
  "alo juga, siapa disitu ?"
  ",konnichiwa (halo dalam bahasa jepang)<== maklum baru belajar :P"
  ",how do you do? i'm happy to meet you"
  ",halo juga saya senang dapat berjumpa dengan anda lagi"
  "it was nice meeting you"
  "menyenakan dapat bertemu dengan anda lagi"
  "how are you today ? are you okay ?"
}

proc hello_speak {nick uhost hand chan text} {
 global botnick hello_chans ranhello
if {(([lsearch -exact [string tolower $hello_chans] [string tolower $chan]] != -1) || 
($hello_chans == "*"))} {
set helos [lindex $ranhello [rand [llength $ranhello]]]
putserv "PRIVMSG $chan :$nick $helos"
  }
} 

##  Brb  ##
set Reponden4.v "Brb Respon"
bind pub - brb brb_speak 
bind pub - gtg brb_speak 
bind pub - away brb_speak 
set ranbrb {
  "ok"
  "where you going?"
  "me too, smoke time!"
  "when you coming back. miss ya already! ;)"
  "mo kemana nich, kok ga ngajak ngajak hehehe"
  "jangan lama lama yah , aku masih kangen nich..."
  "kalo mo ke WC aku ikut, kalo ke kamar juga hehehehhe"
  "ok darling, but don't be so long ok pls, I need You honey"
  ",Alesan .. paling juga gebetan"
  "5 menit aja hehehehehee"
  "ikut donk..."
  ",ape ?? mo kmana lu jang ? TEGA LUH tinggalin gua sendiri ?? co macam apa pulak kau :("
  "brb boleh tapi nicknamenya tetep disini kan ?"
  "ok,  saya tunggu yah.. jangan lama2 kangen buanget  nich kekek.."
  "brb mau kemana.. mau beli pipis yeh.. ikut donk.."
  "ye.. baru juga elo masuk udah brb payah.. loe..."
}

proc brb_speak {nick uhost hand chan text} {
 global botnick brb_chans ranbrb
if {(([lsearch -exact [string tolower $brb_chans] [string tolower $chan]] != -1) || 
($brb_chans == "*"))} {
set brbs [lindex $ranbrb [rand [llength $ranbrb]]]
putserv "PRIVMSG $chan :$nick $brbs"
  }
} 

##  Bye  ##
set Reponden5.v "Bye respon"
bind pub - bye bye_speak 
bind pub - dadah bye_speak 
set ranbye {
  "ati ati dijalan yahh, byeee, kalo jatoh, bangun sendiri yahhh"
  "sampe jumpa besok di waktu dan jam seta channel yang sama hihihihi tha tha"
  "ati ati Ntar ketabrak becak lagi"
  "thathaaa"
  "nice to meet you today, hope can see you agaiin tomorrow"
  "ati-ati di jalan bro!!"
  "ok see u later frend"
  "kok buru-buru amat tadikan baru datang kok udah mau pergi.."
  "ok deh.. bye.. juga"
  "see u tommorow night"
  "see u tonight"
  "mata ashita (sampai jumpa besok)"
  "sayoonara fren :)"
  "sampai besok sobat"
  "iyah..take care yaahh ^_^"
  "take care fren, nice to meet u :)"
  "good bye.. juga :)"
  "nice to meet you today, hope can see you agaiin tomorrow"
  "GBU & tetep semangat yah.."
}

proc bye_speak {nick uhost hand chan text} {
 global botnick bye_chans ranbye
if {(([lsearch -exact [string tolower $bye_chans] [string tolower $chan]] != -1) || 
($bye_chans == "*"))} {
set byes [lindex $ranbye [rand [llength $ranbye]]]
putserv "PRIVMSG $chan : $nick $byes"
  }
} 
##  acem ##
set Reponden6.v "acem respon"
bind pub - ctm acem_speak 
bind pub - mbod acem_speak 
set ranacem {
  "opo bos..."
  "hay say.."
  "ya.."
  "ada apa?"
  "ya bos.."
  "apa bos.."
  "males ah..."

}

proc acem_speak {nick uhost hand chan text} {
 global botnick acem_chans ranacem
if {(([lsearch -exact [string tolower $acem_chans] [string tolower $chan]] != -1) || 
($acem_chans == "*"))} {
set acems [lindex $ranacem [rand [llength $ranacem]]]
putserv "PRIVMSG $chan : $nick $acems"
  }
} 
putlog "=============="

set update "01.01.2003"
bind join - * sayinfo 
set info_owner {
    "hay bos"
    "hayah kok baru datang bos"
    "waaaaaaa ada si"
    "AsekkKKkk.... akhirnya dateng juga si"
    "wb BOSSS!!! mo LAPoR NiH, catHy nakal tadi "
    "B0zZz... tadi banyak cewek cari tuhh.. "
    "ah kok baru datang bosSS.. abis kencan ya"
	"bosSS LaporRR.. Channel aman terKEndali BosS"
}
set info_localowner {
    "KaBurrrRRrrr...... ADA Siluman DataNG... !!!"
    "PAK gimana kabarnya si ehem.. ehemm.. :)))"
    "Pak!! ada SaLaM dArI SeLinGkuHan TuH !!!"
}
set info_master {
    "hehehe... MASTER DatanG !!"
    "MASTER !!! Bagi ShELL dOOnGG !!!"
    "MASTER aBiS KeLayaPaN Nih !"
    "MASTER.... Masterku Tampan, xixixi..."
}
set info_friend {
    "WOW !!! andravalid raja nya hacker !!!"
    "Cewek-cewek... Awass digombal !!! "
    "Oi... masandra tadi selingkuhanmu selingkuh lagi"
    "Met DatanG rippers !!!"
    "Hehehehe ada rippers kaborz ah"
    "KabuRRRR..... ada rippers !!!"
    "Wiw atut ada Mr Gele
}
set info_oper {
    "You simple oper, watch out !"
    "Operator detected!"
    "You gonna lose your flags if you do something bad!"
    "I'm watching you..."
}
set info_loser {
    "NgaPain Loe DiSiNI ???"
    "Wakss... ada Homo jOiN"
}

# main()

proc sayinfo { nick host handle chan } {
   global botnick
   if { $nick != $botnick } {
       if {[matchattr $handle n]} {
           putserv "PRIVMSG $chan :[rand_owner $nick] $nick "
       } elseif {[matchattr $handle |n $chan]} {
           putserv "PRIVMSG $chan :[rand_localowner $nick] $nick "
       } elseif {[matchattr $handle m]} {
           putserv "PRIVMSG $chan :[rand_master $nick] $nick "
       } elseif {[matchattr $handle |m $chan]} {
           putserv "PRIVMSG $chan :[rand_master $nick] $nick "
       } elseif {[matchattr $handle f]} {
           putserv "PRIVMSG $chan :[rand_friend $nick] $nick "
       } elseif {[matchattr $handle |f $chan]} {
           putserv "PRIVMSG $chan :[rand_friend $nick] $nick "
       } elseif {[matchattr $handle o]} {
           putserv "PRIVMSG $chan :[rand_oper $nick] $nick "
       } elseif {[matchattr $handle |o $chan]} {
           putserv "PRIVMSG $chan :[rand_oper $nick] $nick ]"
       } elseif {[matchattr $handle d]} {
           putserv "PRIVMSG $chan :[rand_loser $nick] $nick "
       } elseif {[matchattr $handle |d $chan]} {
           putserv "PRIVMSG $chan :[rand_loser $nick] $nick "
       }
   }
}

# random(s)

proc rand_owner {nick} {
     global info_owner
     set result [lindex $info_owner [rand [llength $info_owner]]]
     return "$result"
}
proc rand_localowner {nick} {
     global info_localowner
     set result [lindex $info_localowner [rand [llength $info_localowner]]]
     return "$result"
}
proc rand_master {nick} {
     global info_master
     set result [lindex $info_master [rand [llength $info_master]]]
     return "$result"
}
proc rand_friend {nick} {
     global info_friend
     set result [lindex $info_friend [rand [llength $info_friend]]]
     return "$result"
}
proc rand_oper {nick} {
     global info_oper
     set result [lindex $info_oper [rand [llength $info_oper]]]
     return "$result"
}
proc rand_loser {nick} {
     global info_loser
     set result [lindex $info_loser [rand [llength $info_loser]]]
     return "$result"
}

putlog "==============="

bind pub - .help pub_help
proc pub_help {nick uhost handle chan arg} {
    global botnick
    if {$arg == ""} {
      putserv "NOTICE $nick :Perintah 1 : | 12.dns | 12.dns6 | 12.dwhois | 12.ip | 12.port | 12.dnsnick | 12.host  | 12.nsinfo | 12.csinfo | 12.idle <nick> | "
	  putserv "NOTICE $nick :Perintah 2 : | 12.aksi | 12.saran | 12.hitung | 12.shio | 12.ping me | 12.jam | 12.google |  12.jodoh |  12.whois | 12.country | 12.cmd |   "
	  putserv "NOTICE $nick :.Help : 12,1«14« 3R4unn6i7ng 8T7cL9 12g010e14Z 11»13» "
      return 0
    }
}
putlog "....... Successfully ........."
set cprev "."
set fromchan "NONE"
set cctarget "NONE"
set fromchancs "NONE"
set cctargetcs "NONE"
set fromchanns "NONE"
set cctargetns "NONE"
bind pub - "${cprev}version" proc:version
bind pub - "${cprev}csinfo" proc:csinfo
bind pub - "${cprev}nsinfo" proc:nsinfo
bind ctcr - VERSION ctcr:version
bind notc - * notc:version

proc proc:version {nick uhost hand chan text} {
    global botnick fromchan cctarget
    if {[string tolower $nick] != [string tolower $botnick]} {
        set fromchan $chan
        set cctarget [lindex $text 0]
        putquick "PRIVMSG $cctarget :\001VERSION\001"
        return 1
    }
}

proc proc:csinfo {nick uhost hand chan text} {
    global botnick fromchancs cctargetcs
    if {[string tolower $nick] != [string tolower $botnick]} {
        set fromchancs $chan
        set cctargetcs [lindex $text 0]
        putquick "cs info $cctargetcs"
        return 1
    }
}

proc proc:nsinfo {nick uhost hand chan text} {
    global botnick fromchanns cctargetns
    if {[string tolower $nick] != [string tolower $botnick]} {
        set fromchanns $chan
        set cctargetns [lindex $text 0]
        putquick "ns info $cctargetns"
        return 1
    }
}

proc ctcr:version {nick uhost hand dest key arg} {
    global botnick fromchan cctarget
    if {($fromchan == "NONE") || ($cctarget == "NONE")} {return 0}
    if {[string tolower $nick] != [string tolower $botnick]} {
        putquick "PRIVMSG $fromchan :14(06$nick 14VERSION 15reply4!14) 1: \00314$arg\003"
        set fromchan "NONE"
        set cctarget "NONE"
        return 1
    }
}

proc notc:version {nick uhost hand text {dest ""}} {
    global botnick fromchan cctarget fromchancs cctargetcs fromchanns cctargetns
    if {$dest == ""} { set dest $botnick }
    if {($fromchan != "NONE") && ($cctarget != "NONE")} {
        if {([string tolower $nick] == [string tolower $cctarget]) && ([string match "*version*" [lindex [string tolower $text] 0]])} {
            putquick "PRIVMSG $fromchan :14(06$nick 14VERSION 15reply4!14) 1: \00314$text\003"
            set fromchan "NONE"
            set cctarget "NONE"
            return 1
        }
    }   
    if {($fromchancs != "NONE") && ($cctargetcs != "NONE")} {
        if {[string tolower $nick] == "chanserv"} {
            putquick "PRIVMSG $fromchancs :\00314$text\003"
            if {[string match "*end of info*" [zzstripcodes [string tolower $text]]]} {
                set fromchancs "NONE"
                set cctargetcs "NONE"
                return 1
            }
        }
    }
    if {($fromchanns != "NONE") && ($cctargetns != "NONE")} {
        if {[string tolower $nick] == "nickserv"} {
            putquick "PRIVMSG $fromchanns :\00314$text\003"
            if {[string match "*end of info*" [zzstripcodes [string tolower $text]]]} {
                set fromchanns "NONE"
                set cctargetns "NONE"
                return 1
            }
        }
    }
}

bind pub - "${cprev}whois" whois:nick

proc whois:nick { nickname hostname handle channel arguments } {
    global whois
    set target [lindex [split $arguments] 0]
    if {$target == ""} {
        putquick "PRIVMSG $channel :14Whois contohnya :  .whois g0eZ"
        return 0
    }
    putquick "WHOIS $target $target"
    set ::whoischannel $channel
    set ::whoistarget $target
    bind RAW - 401 whois:nosuch
    bind RAW - 311 whois:info
    bind RAW - 319 whois:channels
    bind RAW - 312 whois:server
    bind RAW - 301 whois:away
    bind RAW - 313 whois:ircop
    bind RAW - 317 whois:idle
    bind raw - 338 whois:host
    bind raw - 318 whois:eof
}

proc whois:putmsg { channel arguments } {
    putquick "PRIVMSG $channel :\00314$arguments\003"
}

proc whois:info { from keyword arguments } {
    set channel $::whoischannel
    set nickname [lindex [split $arguments] 1]
    set ident [lindex [split $arguments] 2]
    set host [lindex [split $arguments] 3]
    set realname [string range [join [lrange $arguments 5 end]] 1 end]
    whois:putmsg $channel "14$nickname is $ident@$host * $realname"
    unbind RAW - 311 whois:info
}

proc whois:ircop { from keyword arguments } {
    set channel $::whoischannel
    set target $::whoistarget
    whois:putmsg $channel "14$target is an IRC Operator"
    unbind RAW - 313 whois:ircop
}

proc whois:away { from keyword arguments } {
    set channel $::whoischannel
    set target $::whoistarget
    set awaymessage [string range [join [lrange $arguments 2 end]] 1 end]
    whois:putmsg $channel "14$target is away: $awaymessage"
    unbind RAW - 301 whois:away
}
putlog "---------------------------------------------------------	"
proc whois:channels { from keyword arguments } {
    set channel $::whoischannel
    set channels [string range [join [lrange $arguments 2 end]] 1 end]
    set target $::whoistarget
    whois:putmsg $channel "14$target on $channels"
    unbind RAW - 319 whois:channels
}
putlog " 	You Are Used eggoez.tcl All About This	"
proc whois:server { from keyword arguments } {
    set channel $::whoischannel
    set server [lindex [split $arguments] 2]
    set info [string range [join [lrange $arguments 3 end]] 1 end]
    set target $::whoistarget
    whois:putmsg $channel "14$target using $server $info"
    unbind raw - 312 whois:server
}
putlog "	Thank's Have Used eggoez.tcl	"
proc whois:nosuch { from keyword arguments } {
    set channel $::whoischannel
    set target $::whoistarget
    whois:putmsg $channel "14Gak ada OnLine si \"$target\""
    unbind RAW - 401 whois:nosuch
}
putlog "	eggoez@yahoo.com 	"
proc whois:idle { from keyword arguments } {
    set channel $::whoischannel
    set target $::whoistarget
    set idletime [lindex [split $arguments] 2]
    set signon [lindex [split $arguments] 3]
    whois:putmsg $channel "14$target has been idle for [duration $idletime]. signon time [ctime $signon]"
    unbind RAW - 317 whois:idle
}
putlog "	http://eggoez.blogspot.com	"
proc whois:host { from keyword arguments }  {
    set channel $::whoischannel
    set target $::whoistarget
    set hostname [lindex [split $arguments] 2]
    whois:putmsg $channel "14$target actually using host $hostname"
    unbind raw - 338 whois:auth
}
putlog "	http://facebook.com/eggoez	"
proc whois:eof { from keyword arguments } {
    set channel $::whoischannel
    set target $::whoistarget
    set eof [string range [join [lrange [split $arguments] 2 end]] 1 end]
    whois:putmsg $channel "14$target $eof"
    unbind raw - 318 whois:eof
}
putlog "	Thank's  For catHy muacHH	"
bind ctcp - VERSION ctcppingreply
proc ctcppingreply {nick uhost hand dest key arg} {
    global botnick
    putserv "NOTICE $nick :\001VERSION 6ciut8IR4C 14B7eta 5(9New5) 3By g0eZ 15( 12http://ciut.peperonity.com 15)\001"
    return 1
}
putlog "	#ciut	"
bind ctcp - FINGER ctcpfingerreply
proc ctcpfingerreply {nick uhost hand dest key arg} {
    global botnick
    putserv "NOTICE $nick :\001FINGER 6ciut8IR4C 14B7eta 5(9New5) 3By g0eZ 15( 12http://ciut.peperonity.com 15)\001"
    return 1
}
putlog "	Community Channel In AllNetwork	"
proc zzstripcodes {text} {
    regsub -all -- "\003(\[0-9\]\[0-9\]?(,\[0-9\]\[0-9\]?)?)?" $text "" text
    regsub -all -- "\t" $text " " text
    set text "[string map -nocase [list \002 "" \017 "" \026 "" \037 ""] $text]"
    return $text
}
putlog "	Done!	"
putlog "------------------------------------------------------------	"
bind pub - .time timecheck
bind pub - .jam timecheck
bind RAW - 391 timereply
set servtime "plasa.id.allnetwork.org"
proc timecheck { nick uhost hand chan text } {
 global botnick servtime
 putquick "TIME $servtime"
 set ::timechan $chan
}
proc timereply { from keyword arguments } {
 set channel $::timechan
 time:output $channel $arguments
}
proc time:output { channel arguments } {
global botnick servtime
 set day [lindex [split $arguments] 2]
 if {$day == ":Monday"} { set hari "Senin" }
 if {$day == ":Tuesday"} { set hari "Selasa" }
 if {$day == ":Wednesday"} { set hari "Rabu" }
 if {$day == ":Thursday"} { set hari "Kamis" }
 if {$day == ":Friday"} { set hari "03Jum'at" }
 if {$day == ":Saturday"} { set hari "Sabtu" }
 if {$day == ":Sunday"} { set hari "04Minggu" }
 set tanggal [lindex [split $arguments] 4]
 set month [lindex [split $arguments] 3]
 if {$month == "January"} { set bulan "Januari" }
 if {$month == "February"} { set bulan "Februari" }
 if {$month == "March"} { set bulan "Maret" }
 if {$month == "April"} { set bulan "April" }
 if {$month == "May"} { set bulan "Mei" }
 if {$month == "June"} { set bulan "Juni" }
 if {$month == "July"} { set bulan "Juli" }
 if {$month == "August"} { set bulan "Agustus" }
 if {$month == "September"} { set bulan "September" }
 if {$month == "October"} { set bulan "Oktober" }
 if {$month == "November"} { set bulan "November" }
 if {$month == "December"} { set bulan "Desember" }
 set tahun [lindex [split $arguments] 5]
 set jam [lindex [split $arguments] 7]
 putquick "PRIVMSG $channel :Sekarang $hari - $tanggal $bulan $tahun - $jam "
}
putlog "egggoez eggdrop.goez aready runing..."
## ----------------------------------------------------------------------------------------------------------------------------------
# Indonesia Speak : Terimakasih saya ucapkan telah memakai tcl tcl yang telah saya rancang
# Tiada Rasa Untuk sombong, saya hanyalah sekedar ingin punya dan mungkin teman² ingin memakai
# saya hanyalah orang yang kurang dari sempurna, andai ada kesalahan
# saya pribadi minta maaf, semoga ini bermanfaat buat kalian semua..... semangat...............................
# - HARGAILAH KARYA ORANG LAIN DENGAN TIDAK MERUBAH ISI WALAUPUN HANYA SEDIKIT -
##-----------------------------------------------------------------------------------------------------------------------------------

