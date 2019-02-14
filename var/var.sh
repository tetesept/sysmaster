#!/bin/bash
############################
#Sysmaster				   #
############################

#Hilfsvariablen
#Globale variablen
#Defaultparameter

#Script Info Variablen
skname="Systemmaster"
version="v0.3"                                							#Verionsnummer
chdatum="07.12.2018"                            						#Datum der letzten Aenderung
autor="Thomas Schewe"                           						#Letzter Autor
autormail="none"        												#E-Mail Adresse des Autors
loc=`find $instdir -name '*.sh' | xargs wc -l | tail -n 1 | awk '{print $1}'`	#LOC Counter

#CHangelog (Neu in $version)
chlog1="Mail TSL support, POP3S included, IMAPS included"				#Neuerung 1
chlog2="Ubuntu 18.04 LTS Support (Beta)"								#Neuerung 2
chlog3="Generate Strong Zertifikate"									#Neuerung 3

#ideen
#
#
#
#
#
#

#Allgemein Variablen
defaultmail=tetesept@tetesept.loca
currel=`lsb_release -a | grep Release | sed 's/\./ /' | awk '{print $2}'`
datetime=`date +%Y%m%d_%H:%M:%S`										#Date and Time
date=`date +%Y%m%d`														#Date
tempvz=/tmp																
temp=/tmp/$0_$date.tmp													#TMP Files
tmp=/tmp/$0_$date.tmp													#TMP Files
adminip=none 															#IP Office
monip=none																#IP Icinga
observip=none															#IP Observium
ntpserver=none                           								#Default NTP-Server
ipdns=8.8.8.8															#Default DNS1
ipdns2=8.8.4.4															#Default DNS2
log=${instdir}/sysmaster.log											#Default Logfile
deflog=${instdir}/sysmaster.log											#Default Logfile
fett=`tput bold`														#Stdout FETT
reset=`tput sgr0`														#Stdout RESET
txtund=$(tput sgr 0 1)          										#Underline
bldred=${fett}$(tput setaf 1) 											#red
bldblu=${fett}$(tput setaf 4) 											#blue
bldwht=${fett}$(tput setaf 7) 											#white
first=$1																#Save $1
second=$2																#Save $2
hostn=`hostname -f`														#FQDN
skmain=`echo $0 | sed 's/\//\n/g' | tail -n1`							#name des aufgerufenen Programms
sshconfig="/etc/ssh/sshd_config"										#Default Path to SSH Config
umcfile="/etc/update-manager/release-upgrades"  						#Default Path to Update-Manager Config
ethif="/etc/network/interfaces"											#Default Config fuer Interfaces
systemhelpme="${instdir}/helpme/systemhelpme.help"						#Help File System
miscellaneoushelpme="${instdir}/helpme/miscellaneoushelpme.help"		#Help File Miscellaneous         	
myip=`ifconfig | grep -E "encap|eth|br|address|net|gate" | egrep -v "#|loopback|inet6|Link encap" | awk '{print $2}' | sed s/"addr:"/""/g | sed s/"Adresse:"/""/g | egrep -v "127.0"`
pubfile="/etc/myssl/public.pem"
privfile="/etc/myssl/privkey.pem"
cafile="/etc/myssl/cacert.pem"
caprivfile="/etc/myssl/cakey.pem"
csrfile="/etc/myssl/cert.csr"

