#!/bin/bash
############################
#Sysmaster				   #
############################

#System aufraumen

systemclean()
{
	local log="${instdir}/sysclean/sysclean.log"	
	touch $log
	startlog $log

	local rklog="${instdir}/sysclean/rklog.log"
	local rklog2="${instdir}/sysclean/rklog2.log"
	local lostfound="${instdir}/sysclean/lostfound.tmp"
	
		#update
        (
        echo "10" ; sleep 2
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Updating Package list" 8 80
			apt-get -y --force-yes update 1>>$log 2>>$log 3>>$log
		#repair
		(
        echo "20" ; sleep 2
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Try to repair system if required" 8 80
			apt-get -q -y -f --force-yes install   1>>$log 2>>$log 3>>$log
		#virusmaisl
		(
		echo "30" ; sleep 2
		echo "XXX" 
		) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Deleting Virus mails older than 30 days" 8 80
			find /var/lib/amavis/virusmails/ -mtime +31 -delete 1>>$log 2>>$log 3>>$log
        #quarantainemails
        (
        echo "40" ; sleep 2
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Deleting Spam mails older than 30 days" 8 80
			find /var/lib/amavis/quarantine/ -mtime +31 -delete 1>>$log 2>>$log 3>>$log
        #logs
        (
        echo "50" ; sleep 2
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Deleting Logs older than one Year" 8 80
			find /var/log/ -mtime +366 -delete 1>>$log 2>>$log 3>>$log
        #clean
        (
        echo "60" ; sleep 2
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Cleaning apt cache directory from downloaded packages" 8 80
        	apt-get -y --force-yes clean 1>>$log 2>>$log 3>>$log
        #autoremove
        (
        echo "70" ; sleep 2
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Deleting unused packages" 8 80
                apt-get -y --force-yes autoremove 1>>$log 2>>$log 3>>$log
		#rkhunter
        (
        echo "80" ; sleep 2
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "RKHunter Update" 8 80
        	if [ "$(which rkhunter)" != "" ]        	
        	then	
				echo "RKHunter :" >> $log
				rkhunter --update 1>>$log 2>>$log 3>>$log
        	else
        		echo "RKHunter is not installed!" >> $log
        	fi
		#clamscan
        (
        echo "85" ; sleep 2
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "ClamAV Update" 8 80
        	if [ "$(which clamscan)" != "" ]        	
        	then	
				echo "Clamscan :" >> $log
				freshclam 1>>$log 2>>$log 3>>$log
        	else
        		echo "clamscan is not installed!" >> $log
        	fi
		#L+F
        (
        echo "90" ; sleep 2
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Checking Lost+Found" 8 80
			if [ "$(ls /lost+found)" != "" ]
			then
				echo "Lost and Found:" >> $log
				rm -v $lostfound 1>>$log 2>>$log 3>>$log
				touch $lostfound
				ls -l /lost+found | grep -v "insgesamt">> $lostfound
				dialog --colors --backtitle "System Master Script" --title "Lost and Found Scan Results" --exit-label "OK" --textbox $lostfound 0 0
				cat $lostfound >> $log	
			else
				echo "Lost and Found is empty" >> $log
			fi
        #Done
        (
        echo "100" ; sleep 2
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Done!" 8 80
	return 1
}

systemscan()
{
	local log="${instdir}/sysclean/systemscan.log"	
	touch $log
	startlog $log
	
	local rklog="${instdir}/sysclean/rklog.log"
	local chlog="${instdir}/sysclean/clamavlog.log"
	local clamavlog="${instdir}/sysclean/clamavlog.log"
	
	#Rkhunter
	dialog --colors --stdout --backtitle "System Master Script" --title "Sysinfo" --msgbox "\Z1Warning\Zn \nRkhunter Scan... may take some time\n" 6 60 --and-widget --timeout 1 --nook --begin 15 15 --infobox "Scanning..." 5 30	
			
	apt-get -y --force-yes update 1>>$log 2>>$log 3>>$log
	apt-get -y --force-yes install rkhunter 1>>$log 2>>$log 3>>$log
	
	echo "RKHunter:" >> $log
	rm -v $rklog 1>>$log 2>>$log 3>>$log
	touch $rklog
	rkhunter --update  1>>$log 2>>$log 3>>$log
    rkhunter -c --cs2 --rwo 1>>$rklog 2>>$rklog 3>>$rklog
	rkhunter --propupd 1>>$log 2>>$log 3>>$log
    dialog --colors --backtitle "System Master Script" --title "Rkhunter Scan Results" --exit-label "OK" --textbox $rklog 0 0
    cat $rklog >> $log
	
	#Chrootkit
	dialog --colors --stdout --backtitle "System Master Script" --title "Sysinfo" --msgbox "\Z1Warning\Zn \nChrootkit Scan... may take some time\n" 6 60 --and-widget --timeout 1 --nook --begin 15 15 --infobox "Scanning..." 5 30	
			
	apt-get -y --force-yes update 1>>$log 2>>$log 3>>$log
	apt-get -y --force-yes install chkrootkit 1>>$log 2>>$log 3>>$log
	
	echo "Chrootkit:" >> $log
	rm -v $chlog 1>>$log 2>>$log 3>>$log
	touch $chlog
    chkrootkit -q 1>>$chlog 2>>$chlog 3>>$chlog

    dialog --colors --backtitle "System Master Script" --title "Rkhunter Scan Results" --exit-label "OK" --textbox $chlog 0 0
    cat $chlog >> $log
	
	#Clamav
	dialog --colors --stdout --backtitle "System Master Script" --title "Sysinfo" --msgbox "\Z1Warning\Zn \nClamAV Scan... may take some time\n" 6 60 --and-widget --timeout 1 --nook --begin 15 15 --infobox "Scanning..." 5 30	
	
	apt-get -y --force-yes update 1>>$log 2>>$log 3>>$log
	apt-get install clamav clamav-freshclam 1>>$log 2>>$log 3>>$log	
	
	echo "Clamav:" >> $log
	rm -v $clamavlog 1>>$log 2>>$log 3>>$log
	touch $clamavlog
	
	freshclam   1>>$log 2>>$log 3>>$log
	clamscan / -iro --exclude-dir=^/sys --exclude-dir=^/dev --exclude-dir=^/proc --detect-pua=yes 1>>$clamavlog 2>>$clamavlog 3>>$clamavlog
	dialog --colors --backtitle "System Master Script" --title "Clamav Scan Results" --exit-label "OK" --textbox $clamavlog 0 0
	cat $clamavlog >> $log
		
	return 1	
}
