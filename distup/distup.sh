#!/bin/bash
############################
#Sysmaster				   #
############################

#Distribution update updaten

distributionupdate()
{
	local log=${instdir}/sysup/sysup.log
	touch $log
	startlog $log
	
    #update 	Neueinlesen der Paketlisten
    (
	echo "10" ; sleep 2
    echo "XXX" 
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Updating Package list" 8 80
		apt-get -y -q --force-yes update 1>>$log 2>>$log 3>>$log
	#upgrade 	installierte Pakete aktualisieren
	(
	echo "20" ; sleep 2
	echo "XXX"  
	) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Upgrading Packages" 8 80
		apt-get -y -q --force-yes upgrade 1>>$log 2>>$log 3>>$log
	#dist-upgrade 	neue Pakete installiert/ alte pakete entfernt
	(
    echo "40" ; sleep 2
    echo "XXX"
    ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing new Packages" 8 80
		apt-get -y -q --force-yes dist-upgrade 1>>$log 2>>$log 3>>$log
	#autoremove 	ungenutzter Abhängigkeiten deinstallieren und Fehlende Abhängigkeiten nachinstallieren
    (
    echo "60" ; sleep 2
    echo "XXX" 
    ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Deleting unused packages" 8 80
		apt-get -y -q -f --force-yes autoremove 1>>$log 2>>$log 3>>$log
	#install 		Fehlende Abhängigkeiten nachinstallieren
    (
    echo "70" ; sleep 2
    echo "XXX" 
    ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing dependencies" 8 80
		apt-get -y -q -f --force-yes check 1>>$log 2>>$log 3>>$log
	#install 		Fehlende Abhängigkeiten nachinstallieren
    (
    echo "70" ; sleep 2
    echo "XXX" 
    ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing dependencies" 8 80
		apt-get -y -q -f --force-yes install 1>>$log 2>>$log 3>>$log
    #clean 	Leeren des Paketcaches
    (
    echo "90" ; sleep 2
    echo "XXX" 
    ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Cleaning apt cache directory from downloaded packages" 8 80
		apt-get -y -q --force-yes clean 1>>$log 2>>$log 3>>$log
    #done
    (
    echo "100" ; sleep 2
    echo "XXX" 
    ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Done" 8 80
	sleep 2
}