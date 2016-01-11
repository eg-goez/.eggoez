#########################################################################
#				* Script Name			: egguard.tcl					#																
#				* Script Version		: t.c(£) v.3.9.60				#
#				* Author				: paimo (creator)				#
#				* Release Date			: 05 Oktober 2010				#
#              	* Last Modifing			: 26 September 2012				#
#				* Made By				: g0eZ							#
#				* E-mail				: eggoez@about.me				#
#				* Report Bug			: #ciut irc.allanetwork.org		#
#########################################################################
#Desc : auto Guard variable # setting by Paimo to be modified by me (eggoez)
set max_length 200
set max_length_ban 5
set max_caps 15
set max_repeat 3
set inviter_ban 180
set badword_ban 1
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
   putquick "KICK $chan $nick :jangan panjang² to $nick kasian yang pakai hape itu loh.."
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

putlog "egGuard Success Loaded..."
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
set basechan "#ciut"
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
