#!/bin/bash
############################
#Sysmaster				   #
############################

#Hilfsfunktionen
#Loging Debuging Hilfe Signalhandler

#Prüfen ob der Benutzer als Root angemeldet ist
logroot()					
{	
	if [ "$UID" != 0 ]
	then
		dialog --colors --title "ROOT" --backtitle "System Master Script" --msgbox "\Z1Warning\Zn \nYou must be logged in as root to start the script" 6 80
		echo "No Root Access" >> $log
		exitsh
	else
		echo "Root Access OK" >> $log
	fi
}

#Internetverbindung prüfen
coninet()					
{	
	local pingubu=`ping -c 1 archive.ubuntu.com | grep loss | awk '{print $6}' | sed s/"%"/""/g` 1>>$log 2>>$log 3>>$log
	if [ "$pingubu" != "0" ]
	then		
		dialog --colors --title "Install KVM" --backtitle "System Master Script" --msgbox "\Z1Warning\Zn \narchive.ubuntu.com is not reachable \nPlease check internet connection" 8 80
		echo "Failed to ping to archive.ubuntu.com" >> $log
		exitsh
	else
		echo "Internet OK" >> $log
	fi	
}

#Defaul Mail setzen
defmailset()					
{	
	local mailisset=no
	until [ "$mailisset" == "ok" ]
	do
		local defmail=`grep defaultmail ${instdir}/var/var.sh` 1>>$log 2>>$log 3>>$log
		if [ "$defmail" == "defaultmail=" ]
		then
			defmailnew=`dialog --colors --backtitle "System Master Script" --title "Basisinstallation" --inputbox "Enter Admin Mail Adress" 0 0 "" 3>&1 1>&2 2>&3`
			if [ "$?" == "1"  ]
			then
				exitsh
			else
				sed '/^defaultmail=/d' ${instdir}/var/var.sh > ${instdir}/var/var.sh.tmp1
				sed -e "/^#Allgemein Variablen$/a defaultmail=${defmailnew}" ${instdir}/var/var.sh.tmp1 > ${instdir}/var/var.sh.tmp2
				cat ${instdir}/var/var.sh.tmp2 > ${instdir}/var/var.sh
			fi
		fi
		#Prüfen ob defmail gesetzt
		defmail=`grep defaultmail ${instdir}/var/var.sh` 1>>$log 2>>$log 3>>$log
		if [ "$defmail" != "defaultmail=" ]
		then
			mailisset=ok
		fi
	done
}

#Defaul Mail prüfen
defmailreset()					
{	
	local defmail=`grep defaultmail ${instdir}/var/var.sh | sed 's/=/ /' | awk '{print $2}'` 1>>$log 2>>$log 3>>$log
	defmailnew=`dialog --colors --backtitle "System Master Script" --title "Basisinstallation" --inputbox "Enter Admin Mail Adress" 0 0 "${defmail}" 3>&1 1>&2 2>&3`
    if [ "$?" == "1"  ]
    then
		return 0
	else
		sed '/^defaultmail=/d' ${instdir}/var/var.sh > ${instdir}/var/var.sh.tmp1
		sed -e "/^#Allgemein Variablen$/a defaultmail=${defmailnew}" ${instdir}/var/var.sh.tmp1 > ${instdir}/var/var.sh.tmp2
		cat ${instdir}/var/var.sh.tmp2 > ${instdir}/var/var.sh
	fi

}

#Logging für das jeweilige logfile starten
startlog()
{
	touch $1														
	echo "" >> $1
	echo "#------Skript started------#" >> $1
	echo "$0 $1 $2" >> $1
	echo `echo "From" && echo "$USER"@"$hostn at" && date` >> $1
	echo "" >> $1
}

#Alle aufrufe von dialog --no-kill beenden 
killdialog()
{	
	until [ "$dialogpid" == "noid" ]
	do     
		local dialogpid=`ps awux | grep "no-kill" | grep -v grep |tail -n 1 | awk '{print $2}'`
		if [ ! "$dialogpid" == "" ]
		then
			kill $dialogpid
			echo "dialog with PID $dialogpid killed" >> $log
		else
			dialogpid="noid"
		fi
	done
}

#Signalhandler fuer SIGINT
sighandSIGINT() 
{	
	dialog --colors --title "Sysmaster" --backtitle "System Master Script" --msgbox "\Z1Notice\Zn \nStrg+C pressed you are going to exit\nIf something went wrong please consider the Log-Files" 7 60
    echo "Exit via Strg+C" >> $log 
	echo "Killing dialog" >> $log
	killdialog
	clear
	exitsh
}

#Debug Funktion "debug on" = debugging einschalten oder "debug off" = debugging ausschalten
debug()
{	
	if [ "$1" == "off"  ]
	then
		set +x
		echo "${fett}--------------------DEBUG=OFF-------------------${reset}"
		echo ""
	elif [ "$1" == "on" ] || [ "$1" = "" ]
	then
		echo ""
		echo "${fett}--------------------DEBUG=ON--------------------${reset}"
		set -x
	else
		echo ""
		echo "Error. Wrong Input: $0 $1"
		echo "Use \"debug on\" to enter debug mode"
		echo "Use \"debug off\" to leave debug mode "
		echo ""
		exit
	fi                        
}

#Standard Exit verhalten
exitsh()
{	
	clear
	echo "${fett}${skname} ${version}(${chdatum}) ${USER}@${hostn} termed.....Bye!${reset}"
	exit 1
}

#Konsolen Help anzeigen
starthelp()
{
	echo ""
    echo "Usage:${fett} ./${skmain} [OPTION]${reset}"
    echo ""
    echo "Options:"
    echo "${fett}   -i${reset}      System Info"
    echo "${fett}   -d${reset}      System Update"
	echo "${fett}   -g${reset}      System Upgrade"
	echo "${fett}   -r${reset}      Check for new Release"
	echo "${fett}   -m${reset}      Systemmonitor"
	echo "${fett}   -t${reset}      Systemtest"
    echo "${fett}   -b${reset}      Basisinstallation"
    echo "${fett}   -u${reset}      Install Backup"
	echo "${fett}   -n${reset}      Install Nagios Client"
	echo "${fett}   -f${reset}      Install Firewall"
	echo "${fett}   -e${reset}      Server First install Package"
	echo "${fett}   -s${reset}      Get Backup Status"
	echo "${fett}   -l${reset}      Show Logfiles"
	echo "${fett}   -z${reset}      Show Version Info"
    echo ""
    echo "${fett}Execute ./${skmain} whithout any Parameter to enter Mastermenue.${reset}"
    echo ""
}

#IP Adresse auf erreichbarkeit pruefen
#return true wenn IP noch nicht vergeben 
checkip()
{
	echook=`ping -c 3 $1 | grep loss |  sed s/", "/"\n"/g | grep loss | awk '{print $1}' | sed s/"%"/""/g`
	case $echook in
	100)	
		dialog --colors --backtitle "System Master Script" --title "Checkip" --infobox "\Z1Notice\Zn \nIP-Adress seams to be ok and not in use" 6 50
		sleep 3
		return 1
	;;
	0)
		dialog --colors --backtitle "System Master Script" --title "Checkip" --msgbox "\Z1Warning\Zn \nIP-Adress seams to be already in use" 6 50 3>&1 1>&2 2>&3
		sleep 3
		return 0
	;;
	*)
		dialog --colors --backtitle "System Master Script" --title "Checkip" --msgbox "\Z1Warning\Zn \nIP-Adress seams to be invalid or the Networt is Unrechable \nNetwork connection wont work"  7 80 3>&1 1>&2 2>&3
		sleep 3
		return 0
	;;	
	esac	
}

#Pruefen ob mail gesendet wurde
#return true wenn Mail gesendet wurde 
checkmail()
{
	curlogtimespanstart=`echo ${datetime} | sed s/"_"/" "/g | sed s/":"/" "/g  | awk '{print $2}'`
	curlogtimespanstop=`echo $curlogtimespanstart + 1 | bc`
	sendmail=`egrep "sent" /var/log/syslog | egrep "${curlogtimespanstart}:|${curlogtimespanstop}:" | grep relay=smtp`
	if [ "$sendmail" == "" ]
	then
		dialog --colors --backtitle "System Master Script" --title "Check Mail" --msgbox "\Z1Error\Zn \nMail cound not been sent!" 6 50
		sleep 3
		return 0	
	fi
	return 1
}

winfo()
{
	clear
	echo ""
	echo "${fett}The Useless Wether Info Funktion ${reset}"
	sleep 1
	curl wttr.in/Offenbach 
	echo ""
	exit
}

sysftpacces()
{
	apt-get -q -y --force-yes install vsftpd 1>>$log 2>>$log 3>>$log	
		
	local ftploaduser=ftpload$(($RANDOM % 10))$(($RANDOM % 10))$(($RANDOM % 10))$(($RANDOM % 10))
	local ftpload=`grep "${ftploaduser}" /etc/passwd | cut -d: -f1`
	local ftppass="$( pwgen -c -n -B -s 12 1)"	
		
	if [ -z ${ftpload} ]
	then		
		useradd -d /home/${ftploaduser} -s /bin/bash -m -k /etc/skel ${ftploaduser} 1>>$log 2>>$log 3>>$log
		echo "${ftploaduser}:${ftppass}" | chpasswd
	else
		echo "${ftploaduser}:${ftppass}" | chpasswd
		echo "${ftploaduser} already exists!" >> $log			
	fi;
		
	usermod --home /home/${ftploaduser} ${ftploaduser} 1>>$log 2>>$log 3>>$log
	chown -R ${ftploaduser}:${ftploaduser} /var/www 1>>$log 2>>$log 3>>$log
	chmod 755 /home/${ftploaduser}
	
	local vschroot=`grep allow_writeable_chroot /etc/vsftpd.conf`
	if [ "$vschroot" == "" ]
	then	
		echo write_enable=YES >> /etc/vsftpd.conf
		echo local_umask=022 >> /etc/vsftpd.conf
		echo chroot_local_user=YES >> /etc/vsftpd.conf
		echo allow_writeable_chroot=YES >> /etc/vsftpd.conf
	fi
		service vsftpd restart 1>>$log 2>>$log 3>>$log
	return 1
}

syssftpacces()
{
	local sftploaduser=sftpload$(($RANDOM % 10))$(($RANDOM % 10))$(($RANDOM % 10))$(($RANDOM % 10))
	local sftpload=`grep "${sftploaduser}" /etc/passwd | cut -d: -f1`
	local sftppass="$( pwgen -c -n -B -s 12 1)"	
	
	if [ -z ${sftpload} ]
	then		
		useradd -d /var/www/ -m -s /bin/false ${sftploaduser};
		echo "${sftploaduser}:${sftppass}" | chpasswd
	else
		echo "${sftploaduser}:${sftppass}" | chpasswd
		echo "${sftploaduser} already exists!" >> $log			
	fi;
		
	usermod --home /home/${sftploaduser} ${sftploaduser} 1>>$log 2>>$log 3>>$log
	chown -R ${sftploaduser}:${sftploaduser} /var/www 1>>$log 2>>$log 3>>$log
	chmod 755 /home/${sftploaduser}
	
	#Eintrag in den sshd einfuegen.
	echo 'Match User' ${sftploaduser} >>/etc/ssh/sshd_config
	echo 'ChrootDirectory /home/'${sftploaduser} >>/etc/ssh/sshd_config
	echo 'ForceCommand internal-sftp' >>/etc/ssh/sshd_config
	echo '###' >>/etc/ssh/sshd_config
	service ssh reload
	return 1
}

syssshacces()
{
	local sshloaduser=sftpload$(($RANDOM % 10))$(($RANDOM % 10))$(($RANDOM % 10))$(($RANDOM % 10))
	local sshload=`grep "${sftploaduser}" /etc/passwd | cut -d: -f1`
	local sshpass="$( pwgen -c -n -B -s 12 1)"	
	
	if [ -z ${sshload} ]
	then		
		useradd -d /var/www/ -m -s /bin/false ${sshloaduser};
		echo "${sshloaduser}:${sshpass}" | chpasswd
	else
		echo "${sshloaduser}:${sshpass}" | chpasswd
		echo "${sshloaduser} already exists!" >> $log			
	fi;
		
	usermod --home /home/${sshloaduser} ${sshloaduser} 1>>$log 2>>$log 3>>$log
	chown -R ${sshloaduser}:${sshloaduser} /var/www 1>>$log 2>>$log 3>>$log
	chmod 755 /home/${sshloaduser}
	
	#Eintrag in den sshd einfuegen.
	local sshconfig="/etc/ssh/sshd_config"
	local au="$(grep "AllowUsers" ${sshconfig})"
	if [ "${au}" != "" ]; 
	then
		sshuser=$(grep ${user} ${sshconfig})
		if [ "${sshuser}" = "" ]
		then
			sed -i "s/${au}/$au ${user}/g" ${sshconfig} >> ${LOG}
			/etc/init.d/ssh reload
		fi;
	fi;
	service ssh reload
	return 1
}

syntaxip()
{
	local ipok=no
		until [ "$ipok" == "ok" ]
		do
			ip=`dialog --colors --backtitle "System Master Script" --title "Syntax" --inputbox "Enter IP/Network-Address" 0 0 "" 3>&1 1>&2 2>&3 --and-widget --timeout 1 --nook --begin 15 15 --infobox "Please wait while checking given IP-Address...." 0 0`
            if [ "$?" == "1"  ]
            then
				return 0;
			fi
			case $ip in
				*.*.*.*.* | *..* | [!0-9]* | *[!0-9] | *[0-9][0-9][0-9][0-9]* )
					dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nWrong input. Define a valid IP-Address like 10.49.1.25" 6 100			
					ipok=no		
				;;					
				*.*.*.* | *[0-9]* | *[0-9][0-9]* | *1[0-9][0-9]* | *2[0-5][0-5]* )
				#IP Pruefen
				local echook=`ping -c 1 $ip | grep loss |  sed s/", "/"\n"/g | grep loss | awk '{print $1}' | sed s/"%"/""/g`
				case $echook in
					0)		
						dialog --colors --backtitle "System Master Script" --title "Syntax" --infobox "\Z1Notice\Zn \nIP-Address is rechable" 7 60 3>&1 1>&2 2>&3
						sleep 2
						ipok=ok
					;;
					100)
						dialog --colors --backtitle "System Master Script" --title "Syntax" --infobox "\Z1Notice\Zn \nIP-Address is not rechable" 7 60 3>&1 1>&2 2>&3
						sleep 2
						ipok=ok
					;;
					*)
						dialog --colors --backtitle "System Master Script" --title "Syntax" --yesno "\Z1Warning\Zn \nIP-Address seams to be invalid\nChange IP Address?"  7 60 3>&1 1>&2 2>&3
						case $? in
							1)
								ipok=ok
							;;
							2)
								ipok=no
							;;
						esac
					;;
				esac
			;;
               *)
				dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nWrong input. Define a valid IP-Address like 10.49.1.25" 6 100
				ipok=no
			;;
               esac
		done
	echo $ip
}

syntaxsm()
{
	local subok=no
		until [ "$subok" == "ok" ]
		do
			sm=`dialog --colors --backtitle "System Master Script" --title "Syntax" --inputbox "Enter Subnetmask" 0 0 "255.255.255.0" 3>&1 1>&2 2>&3`
            if [ "$?" == "1"  ]
            then
				return 0;
			fi
			case $sm in
				*.*.*.*.* | *..* | [!0-9]* | *[!0-9] | *[0-9][0-9][0-9][0-9]* )
					dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nWrong input. Define a valid Subnetmask like 255.255.255.0" 6 100				
				;;					
				*.*.*.* | *[0-9]* | *[0-9][0-9]* | *1[0-9][0-9]* | *2[0-5][0-5]* )
					subok=ok		
				;;
				*)
					dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nWrong input. Define a valid Subnetmask like 255.255.255.0" 6 100
				;;
            esac
		done	
	echo $sm
}

syntaxpf()
{
	local subok=no
		until [ "$subok" == "ok" ]
		do
			pf=`dialog --colors --backtitle "System Master Script" --title "Syntax" --inputbox "Enter Network Prefix" 0 0 "24" 3>&1 1>&2 2>&3`
            if [ "$?" == "1"  ]
            then
				return 0;
			fi
			case $pf in				
				[0-9] | 1[0-9] | 2[0-4] )
					subok=ok		
				;;
				*)
					dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nWrong input. Define a valid prefix like 24" 6 100
				;;
            esac
		done	
	echo $pf

}