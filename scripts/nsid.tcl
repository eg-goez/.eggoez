############################################
# Name        : aNC.tcl
# Desc        : Just simple tCL to change $botnick / time
# Owner    : computersvirus@hotmail.com
# Auth        : eggoez
# Email        : eggoez@about.me
# WebBlog    : eggoez.com
# /irc.allnetwork.org -j:#ciut (g0eZ)
############################################

# konfigurasi
set passnickbot "password bot nick"
set basechan "#ciut"

# module info http://eg-goez.blogspot.com/2010/06/tcl-auto-act-if-have-notice-respons.html
bind notc - "*This nickname is registered*" autoident
bind notc - "*Please identify via*" autoident
bind notc - "*You are now identified for*" compautoident
proc autoident {nick uhost hand text dest} {
  putserv "PRIVMSG NickServ :identify $passnickbot"
}
putlog "NickServ IDentify Loaded on eggoez.tar.gz beta 14"
# konfigurasi yang ingin dikabarkan bot ketika berhasil mengeksekusi respon
proc compautoident {nick uhost hand text dest} {
  putquick "PRIVMSG $basechan :identifikasi nick berhasil :)"
}

# TCL BUG....
# agar bot bisa 100% WORK dalam identify abaikan baris pada line 12 & 13
# mulailah dengan mengganti langsung sebuah put** bot pada line 25 & 20
# sebagai contoh saya ingin kabar di kabarkan pada chan #ciut & pass bot nick saya adalah eggoez123 maka akan jadi seperti ini
#  putquick "PRIVMSG #ciut :identifikasi nick berhasil"
#  putserv "PRIVMSG NickServ :identify eggoez123"
# /s irc.eggoez.com:6667 -join:#ciut // for more info