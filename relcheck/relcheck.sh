#!/bin/bash
############################
#Sysmaster				   #
############################

#Release check und Upgrade

relcheck()
{
        local log=${instdir}/relcheck/relcheck.log
		touch $log
		startlog $log

        local relinfo=${instdir}/relcheck/relinfo.log
        local temp=${instdir}/relcheck/relcheck.temp		
        rm -v $relinfo 1>>$log 2>>$log 3>>$log
        rm -v $temp 1>>$log 2>>$log 3>>$log
        touch $relinfo
        touch $temp
                
        #Nur LTS oder Normale Releases 
        dialog --colors --backtitle "System Master Script" --title "New Release Check" --extra-button --extra-label "LTS-Releases" --ok-label "Normal-Release" --yesno "Do you want to check if there is a new Ubuntu-Release?"  5 80
        case $? in
			3)
				grep -v Prompt $umcfile > $temp
				echo "Prompt=lts" >> $temp
				mv -f $temp $umcfile
            ;;
            0)
				grep -v Prompt $umcfile > $temp
				echo "Prompt=normal" >> $temp
				mv -f $temp $umcfile
            ;;
            1)
				return 0
            ;;
        esac

		#update-manager installieren und auf neues Releas pruefen
        dialog --colors --backtitle "System Master Script" --title "New Release Check" --no-kill --tailboxbg $relinfo 10 50		
        sleep 1
        echo "Searchin for new Releases..." >> $relinfo
		sleep 1
		if [ "$(which do-release-upgrade)" == "" ]                
        then
			apt-get -q -y --force-yes install update-manager-core 1>>$log 2>>$log 3>>$log 
		fi
		do-release-upgrade --check-dist-upgrade-only | egrep "Neue Freigabe|Keine neue Freigabe|New|No" >> $relinfo
        local newrel=`do-release-upgrade --check-dist-upgrade-only | egrep "New|Neue Freigabe" | tee -a $log | awk '{print $1}' | tail -n 1`
		local relname=`do-release-upgrade --check-dist-upgrade-only | egrep "New|Neue Freigabe" | awk '{print $3}' | tail -n 1`       
        sleep 3
        killdialog
        
        #wenn neues Release gefunden update durchführen?
        if [ "$newrel" == "Neue" ] || [ "$newrel" == "New" ] 
        then
			dialog --colors --backtitle "System Master Script" --title "New Release Check" --yesno "\Z1Warning\Zn \nDo you want to perform a Distribution-Update to $relname?\nA Reboot is required!" 8 80 3>&1 1>&2 2>&3
            if [ "$?" == "0" ]
			then
				echo "Distribution update to $relname = yes" >> $log
				distributionupdate
				relupgrade $relname
			else
				return 0
            fi
		else
			dialog --colors --backtitle "System Master Script" --title "New Release Check" --msgbox "\Z1Info\Zn \nNo new Release found" 6 80 3>&1 1>&2 2>&3
			return 1
        fi
        return 1
}

#Release update zur sicherheit im konsolen Modus durchführen
relupgrade()
{
	local log=${instdir}/relcheck/distup.log
	touch $log								
    startlog $log   			

	dialog --colors --backtitle "System Master Script" --title "Distribution Update" --yesno "\Z1Warning\Zn \nAre you sure you want to Upgrade?\nSwitching to console mode!"  7 50 3>&1 1>&2 2>&3
    echo "Switching to console mode" >> $log
    if [ "$?" == "0" ]
	then
		echo "Distribution update to $1 starts" >> $log
	else
		return 0
    fi	
	clear
	echo ""
	echo "  #####################"
	echo "  #${fett}Distribution Update${reset}#"
	echo "  #####################"
    echo ""
	sleep 2
    do-release-upgrade --mode=server
	echo "Update Done" >> $log
	return 1
}
