#!/bin/bash
############################
#Sysmaster				   #
############################

#Sysmaster absolutes Verzeichnis setzen
pwddir=`pwd`
instdir=`echo $0 | sed 's/\/sysmaster.sh//g'`
readinstaldir=`echo ${instdir} | sed 's/^[.]*//'`

#Includes der Funktionen
. ${instdir}/var/var.sh													#Standard Variablen																						
. ${instdir}/funk/funk.sh												#Allgemeine Funktionen												
. ${instdir}/info/info.sh												#Informationen über Hardware, Systemkonfiguration und Konnektivität
. ${instdir}/version/version.sh											#Versionsinformationen anzeigen											
. ${instdir}/viewlog/viewlog.sh											#Zeigt die Log-Files der einzelnen Unterprogramme an					
. ${instdir}/helpme/helpme.sh											#Zeigt Hilfe zu den Funktioenn des Skriptes an
. ${instdir}/baseinst/baseinst.sh										#Standart Programme installieren und konfigurieren
. ${instdir}/sysup/sysup.sh												#System aktualisieren
. ${instdir}/distup/distup.sh											#System aktualisieren
. ${instdir}/sysclean/sysclean.sh										#System bereinigen und nach Viren suchen										
. ${instdir}/relcheck/relcheck.sh										#Nach neuem Release suchen und Release-Version aktualisieren
. ${instdir}/syssoft/syssoft.sh											#Systemsoftware installieren Webserver Firewall Nagios
. ${instdir}/sysbackup/sysbackup.sh										#Duplicity Backup einrichten
. ${instdir}/systools/systools.sh										#Verwaltungs uns Analystetools 
. ${instdir}/systest/systest.sh											#Performance Test der Systems
. ${instdir}/syssoft/sysmail.sh											#Mailserver installieren und einrichten

#Start Path
#echo -n "${fett}Starting "
	echo -n "${bldblu}S "
	sleep 0.1
	echo -n "${bldred}Y "
	sleep 0.1
	echo -n "${bldblu}S "
	sleep 0.1
	echo -n "${bldred}M "
	sleep 0.1
	echo -n "${bldblu}A "
	sleep 0.1
	echo -n "${bldred}S "
	sleep 0.1
	echo -n "${bldblu}T "
	sleep 0.1
	echo -n "${bldred}E "
	sleep 0.1
	echo -n "${bldblu}R "
	sleep 0.1
	echo "${reset}${fett}by ${reset}${bldblu}T${bldred}homas${bldblu}S${bldred}chewe${reset}"
	sleep 0.5

#sleep 1

#MD5 setzen
find $instdir -name "*.sh" ! -name "*sysmaster.sh" -print0 | xargs -0 md5sum > ${instdir}/MD5SUM

#Selbstreinigung
#find $instdir -name "*.log" -exec rm -Rv {} \;

#Erstinstallation erzwingen
#apt-get purge dialog

#Starte das Logging
startlog $log															#--> ./funk/funk.sh

#Path Variable des absoluten Verzeichnisses setzen
#pathset=`grep $readinstaldir /root/.profile` 
#if [ "$pathset" == "" ]
#then
#	echo "Setting PATH variable" >>$log	
#	newpath=`grep PATH /etc/environment | sed "s,\",\"$readinstaldir:," | grep PATH`
#	touch /root/.profile
#	echo $newpath >> $log	
#	echo "" >> /root/.profile
#	echo "export $newpath" >> /root/.profile
#	echo "PATH variable set = OK" >>$log	
#else
#	echo "PATH variable set = Skiping Already Set" >>$log	
#fi

#Zum einblenden der Konsolenbefehle aktivieren 
#local debugmode=off
#echo "Debug Mode = $debugmode" >>$log
#debug $debugmode

#Signalhandler fuer Strg+C
echo "Init Signalhandler = OK" >>$log
trap 'sighandSIGINT' 2 										#--> ./funk/funk.sh

#CHarset UTF8
echo "Init CHarset = OK" >>$log
export NCURSES_NO_UTF8_ACS=1

#Main_Master-Menue
#Ruft die GUI für das Hautmenue auf 

mastermenu() 
{
#Hauptmenue
	while(true)
	do
    	main_master_menu=`dialog --keep-tite --help-button --colors --cancel-label "Exit" --backtitle "System Master Script" --title "Master Menu" --menu "\Zu\ZbMove pressing [UP] or [DOWN], [Enter] to select\Zn" 0 0 0\
			Software-Management "Do basic things/Install Server" \
			System-Management "System Info/Update/Upgrade/Release/Clean"\
			Admin-Tools "System Trace/System Monitor"\
			View-Logfiles "Consider Logfiles"\
			Version "Show Version Information"\
			Exit "Quit Sysmaster" \
			3>&1 1>&2 2>&3`
			case $? in
			2)
				helpme														#--> ./helpme/helpme.sh
			;;
			1)
				exitsh														#--> ./funk/funk.sh
			;;
			esac
			case $main_master_menu in
#Sub_Baseinstallation
				Software-Management) 
                    sys_sub_menu=`dialog --cancel-label "Exit" --backtitle "System Master Script" --title "System Sub Menu" --menu "Move pressing [UP] or [DOWN], [Enter] to select" 0 0 0 \
                    Baseinstallation "A vast number of things..." \
                    Backup "Scheduled Server Backup to SFTP" \
					DBBackup "Scheduled Database Backup to SFTP" \
					Restore "Restore Server Backup from SFTP" \
					Collection_Status "Collection Status of the Backup" \
					Firewall "Install and configure IPTables" \
					Icinga "Install and configure NRPE Client" \
                    Webserver "Install and configure Apache2 Vsftpd PHP7 Mysql" \
					Mailserver "Install and configure Postfix Amavis Spamassassin Clamav" \
					Back "Go back to Master Menue" \
                    3>&1 1>&2 2>&3`
                    if [ $? != 0 ]
                    then
                       	exitsh											#--> ./funk/funk.sh	
                    fi
                    case $sys_sub_menu in
                            Baseinstallation)
								echo "-> Basisinsallation" >>$log
                               	baseinst								#--> ./info/info.sh
                            ;;
                            Backup)
								echo "-> Sysbackup" >>$log
                                sysbackup						   		#--> ./sysbackup/sysbackup.sh
                            ;;
							DBBackup)
								echo "-> SysDBbackup" >>$log
								sysdbbackup								#--> ./sysbackup/sysbackup.sh
							;;
							Restore)
								echo "-> Sysrestore" >>$log
								sysrestore								#--> ./sysbackup/sysbackup.sh
							;;
							Collection_Status)
								echo "-> Syscollectionstatus" >>$log
								syscollectionstatus						#--> ./sysbackup/sysbackup.sh
							;;
							Firewall)
								echo "-> Sysfirewall" >>$log
                                sysfirewall								#--> ./sysbackup/sysbackup.sh
                            ;;
							Icinga)
								echo "-> Sysicinga" >>$log
								sysicinga								#--> ./sysbackup/sysicinga.sh
							;;
                            Webserver)
								echo "-> Syswebserver" >>$log
								syswebserver        					#--> ./sysbackup/sysbackup.sh
							;;
							Mailserver)
								echo "-> Sysmailserver" >>$log
								sysmailservers    						#--> ./sysbackup/sysbackup.sh
                            ;;
                            Back)
                            ;;
                    esac
			;;
#Sub_System-Management 
				System-Management) 
                    sys_sub_menu=`dialog --cancel-label "Exit" --backtitle "System Master Script" --title "System Sub Menu" --menu "Move pressing [UP] or [DOWN], [Enter] to select" 0 0 0 \
                    System_Info "Show System Informationen and Hardware configuration" \
                    System_Update "Ony Updates existing Packages" \
					Distribution_Upgrade "Updates existing Packages and installs new ones" \
                    Release_Upgrade "Upgrade System to the next Release. System Reboot is required!" \
					System_Clean "Clean System" \
					System_Scan "Scan System and check for Virus" \
					Make_Vserver "Install Virtual Kernel an V-Tools" \
					Back "Go back to Master Menue" \
                    3>&1 1>&2 2>&3`
                    if [ $? != 0 ]
                    then
                       	exitsh											#--> ./funk/funk.sh	
                    fi
                    case $sys_sub_menu in
                            System_Info)
								echo "-> Sysinfo" >>$log
                               	systeminfo								#--> ./info/info.sh
                            ;;
                            System_Update)
								echo "-> Systemupdate" >>$log
                                systemupdate							#--> ./sysup/sysup.sh
                            ;;
							Distribution_Upgrade)
								echo "-> Distributionupdate" >>$log
                                distributionupdate						#--> ./sysup/sysup.sh
                            ;;
                            Release_Upgrade)
								echo "-> Releaseupgrade" >>$log
								relcheck        						#--> ./relcheck/relcheck.sh
                            ;;
							System_Clean)
								echo "-> Systemclean" >>$log
								systemclean								#--> ./sysclean/sysclean.sh
							;;
							System_Scan)
								echo "-> Systemclean" >>$log
								systemscan								#--> ./sysclean/sysclean.sh
							;;
							Make_Vserver)
								echo "-> Systemvserver" >>$log
								sysvirtualserver						#--> ./systools/systools.sh
							;;
                            Back)
                            ;;
                    esac
			;;
#Sub_Admin-Tools 			
			Admin-Tools)
				admintools_sub_menu=`dialog --cancel-label "Exit" --backtitle "System Master Script" --title "Admin Tools Sub Menu" --menu "Move pressing [UP] or [DOWN], [Enter] to select" 0 0 0 \
					Set_Mailadress "Set the default Mail Adresse" \
					Generate_Certificate "Generate Strong Certificate" \
					System_Monitor "Open System Monitor" \
					System_Test "Performance Test" \
					Upload_File "Upload_File" \
					Download_File "Download_File" \
					System_Trace_Start "Start System Trace" \
					System_Trace_Stop "Stop System Trace" \
					System_Trace_Analys "Start System Analyse" \
					System_Trace_Reset "Start System Reset" \
					Back "Go back to Master Menue" \
                    3>&1 1>&2 2>&3`
					if [ $? != 0 ]
                    then
                       	exitsh											#--> ./funk/funk.sh	
                    fi
                    case $admintools_sub_menu in		
							Set_Mailadress)
								echo "-> SetMailadress" >>$log			#--> ./funk/funk.sh	
								defmailreset
							;;
							Generate_Certificate)
								echo "-> GenerateCertificate" >>$log	#--> ./systools/systools.sh
								strongzert
							;;					
							Upload_File)
								echo "-> Transupload" >>$log
								transupload									#--> ./systools/systools.sh	
							;;
							Download_File)
								echo "-> Transdownload" >>$log
								transdownload									#--> ./systools/systools.sh	
							;;
							System_Trace_Start)
								echo "-> Systracestart" >>$log
								systracestart								#--> ./systools/systools.sh							
							;;
							System_Trace_Stop)
								echo "-> Systracestop" >>$log
								systracestop								#--> ./systools/systools.sh							
							;;
							System_Trace_Analys)
								echo "-> Systraceanalyse" >>$log
								systraceanalyse								#--> ./systools/systools.sh	
							;;
							System_Trace_Reset)
								echo "-> Systracereset" >>$log
								systracereset								#--> ./systools/systools.sh	
							;;
							System_Monitor)
								echo "-> Systemmonitor" >>$log
								sysmonitor									#--> ./systools/systools.sh	
							;;
							System_Test)
								echo "-> Systemtest" >>$log
								systemtest									#--> ./systools/systools.sh	
							;;
			                Back)
                            ;;
                    esac
			;;
#Sub_View-Logfiles
			View-Logfiles)
				echo "-> Viewlog" >>$log
				viewlog													#--> ./viewlog/viewlog.sh
			;;
#Sub_Version
			Version) 
				echo "-> Version" >>$log
				version													#--> ./version/version.sh
        	;;
#Sub_Exit
			Exit) 
				echo "-> Exit" >>$log
				exitsh													#--> ./funk/funk.sh			 
			;;					
		esac
	done
}


#------------Main-----------------
#Dialog Installieren falls nicht vorhanden
if [ "$(which dialog)" == "" ] 
then
	clear
    if [ "$UID" != 0 ]
    then
        echo "${fett}You must be logged in as root to start the script${reset}"
		echo "No root Access = Error. Exit" >>$log
        exit
    fi
	echo ""
	#Integrität ueberpruefen
	echo "${fett}Intregrety check${reset}"
	sleep 1
	touch $instdir/MD5SUM.log
	md5sum -c $instdir/MD5SUM | tee -a $instdir/MD5SUM.log
	cat $instdir/MD5SUM.log >> $log
	echo ""
	MD5SUMStatus=`egrep "WARNUNG|GESCHEITERT" $instdir/MD5SUM.log`
	if [ "$MD5SUMStatus" != "" ]
	then
		MD5SUMStatus=failed
		#exit 0
	fi
	rm $instdir/MD5SUM.log
	sleep 1
	#Dialog installieren
	echo "${fett}Installing Graphical User Interface${reset}"
	sleep 1
	echo "Installing Dialog" >>$log
	apt-get --force-yes install dialog | tee -a $log
	#Falls Dialog nicht installiert werden konnte Internetverbindung prüfen
	#Falls die Internetverbindung ok ist Source liste anpassen um Dialog zu installieren
	if [ "$(which dialog)" == "" ]
	then
		pingubu=`ping -c 1 archive.ubuntu.com | grep loss | awk '{print $6}' | sed s/"%"/""/g`
		if [ "$pingubu" != "0" ]
		then
			echo "${fett}Error${reset}. Failed to connect to archive.ubuntu.com"
			echo "Check Internet connection"
		else
			cp /etc/apt/sources.list /etc/apt/sources.list.backup  1>> $log 2>> $log 3>> $log
			sed s/restricted/"restricted universe multiverse"/g /etc/apt/sources.list.backup > /etc/apt/sources.list
			apt-get -y update 1>> $log 2>> $log 3>> $log
			apt-get -y --force-yes install dialog 1>>$log 2>>$log 3>>$log
		fi
	fi
	if [ "$(which dialog)" == "" ]
	then
		clear
		echo ""        
		echo "${fett}Error${reset}. Failed to install dialog"
		echo "Check sources.list and Internet connectivity" 
		echo ""
		echo "Failed to install dialog" >>$log
		exit 0
	fi
	#Dialog standard konfiguration einbinden
	echo ""
	echo "${fett}Initializing Graphical User Interface${reset}"
	sleep 1 
	dialog --print-version | tee -a $log
	which dialog | tee -a $log
	cp -v ${instdir}/baseinst/root/root/.dialogrc /root/.dialogrc | tee -a $log
	sleep 1
	echo "Dialog environment loaded"		
	echo ""
	sleep 1
	echo "${fett}Installation Complete!${reset}"	
	echo ""
	sleep 1
	echo "${fett}Starting GUI...${reset}"	
	sleep 2
else
		echo "Dialog is installed = OK" >>$log
fi

#Prüfen ob Benutzer als root amgemeldet ist
logroot																	#--> ./funk/funk.sh

#Prüfen ob der Server mit dem internet Verbunden ist 
#coninet																	#--> ./funk/funk.sh

#Hinterlegen der Standard Mail Adresse
defmailset

#Direktwahl mit Optionahndler
while getopts idgmtbunfweslz option 											#Optionahndler
do
	case $option in
        	i)
				echo "Direkt -> Info" >>$log
        	    systeminfo												#--> ./sysinfo/sysinfo.sh
        	;;
        	d)
				echo "Direkt -> Update" >>$log
				systemupdate
			;;
			g)
				echo "Direkt -> Distupdate" >>$log
				distributionupdate
			;;
			m)
				echo "Direkt -> Systemmonitor" >>$log
				sysmonitor
			;;
			t)
				echo "Direkt -> Systemtest" >>$log
				systemtest
			;;
			b)
				echo "Direkt -> Baseinsallation" >>$log
        	    baseinst												            
        	;;
        	u)
				echo "Direkt -> Systembackup" >>$log
        	    sysbackup	
			;;
			n)
				echo "Direkt -> Icinga" >>$log
        	    sysicinga	
			;;
			f)
				echo "Direkt -> Firewall" >>$log
        	    sysfirewall	
			;;
			w)
				echo "Direkt -> WInfo" >>$log
				winfo
			;;
			e)
				echo "Direkt -> Everything" >>$log
				distributionupdate
				baseinst
				sysbackup
				sysicinga
				sysfirewall
				systemclean
			;;
			s)
				echo "Direkt -> Collectionstatus" >>$log
				syscollectionstatus
			;;
			l)
				echo "Direkt -> Show Logfiles" >>$log
				viewlog
			;;
			z)
				echo "Direkt -> Versioninfo" >>$log
				version
			;;
        	?)
				echo "Error wrong option: $0 $first $second" >>$log
				starthelp
                exit
        	;;
	esac
done


#Kein Mastermenu aufrufen bei Direktwahl
if  [ "$1" == "-i" ] || [ "$1" == "-d" ] || [ "$1" == "-g" ] || [ "$1" == "-m" ] || [ "$1" == "-t" ] || [ "$1" == "-b" ] || [ "$1" == "-u" ] || [ "$1" == "-n" ]
then
	echo "No GUI -> Directoption $0 $first $second" >>$log	
	exitsh																#--> ./funk/funk.sh	
fi
if [ "$1" == "-f" ] || [ "$1" == "-w" ] || [ "$1" == "-e" ] || [ "$1" == "-s" ] || [ "$1" == "-l" ] || [ "$1" == "-z" ]   
then
	echo "No GUI -> Directoption $0 $first $second" >>$log	
	exitsh																#--> ./funk/funk.sh	
fi

#Mastermenu wenn keien option angegeben wurden, ansonsten Hilfe text bei fehlerhafter Optionseingabe
if [ "$1" == ""  ]
then
	echo "Starting GUI..." >>$log	
	mastermenu															#--> ./sysmaster.sh 
else
	echo "Error wrong option: $0 $first $second" >>$log
	starthelp															#--> ./funk/funk.sh 
fi
exit 1


