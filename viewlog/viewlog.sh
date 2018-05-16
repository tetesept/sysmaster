#!/bin/bash
############################
#Sysmaster				   #
############################

#Logfiles anzeigen

viewlog()
{
	local list="${instdir}/viewlog/list.tmp"
	local log="${instdir}/viewlog/viewlog.log"
	local logfiles=`ls -R  | egrep ".log|gpgopts|PW_RS_" | egrep -v "viewlog|~|dialogrc|ts-logo"`
	touch $log
	startlog $log
	rm $list
	touch $list
	local logfile
	
	#Vorhandene Logs anzeigen
    for logfile in $logfiles
    do
		echo "$logfile \"$logfile@`hostname -f`\" off\ " >> $list
    done
    local loglist=`cat $list`
	local logok
    until [ "$logok" == "ok" ]
    do
		log2view=`dialog --colors --backtitle "System Master Script" --title "ViewLog" --extra-button --extra-label "Delete Logs"  --radiolist "Select a log file to viev:" 0 0 0 $loglist 3>&1 1>&2 2>&3`
		case $? in
			1)
				return 0
			;;
			3)		
				dialog --colors --backtitle "System Master Script" --title "Firewall" --yesno "\Z1Warning\Zn \nAll Logs and Temp Files will be deleted!\nOK?"  7 80
				case $? in
				1)
					return 0
				;;
				esac	
				find ${instdir} -name '*.log' -delete
				find ${instdir} -name '*gpgopts*' -delete
				find ${instdir} -name 'PW_RS_*' -delete
				find ${instdir} -name '*.tmp*' -delete
				find ${instdir} -name '*.temp*' -delete
				find ${instdir} -name '*~' -delete
				find ${instdir} -name '*.tar.gz' -delete
				startlog $deflog
				echo "Logs deleted" >> $deflog
				return 0
			;;
		esac
		case $log2view in
			"")
				dialog --colors --backtitle "System Master Script" --title "ViewLog" --msgbox "\Z1Error\Zn \nYou have to chose a Log file. Select Log file with [Arrow-Keys], mark with [Space] and press [Enter] for OK" 6 100
			;;
			*)
				logok="ok"		
			;;
		esac
	done
	
	#gewaehltes Log anzeigen
	local dir2logfile=`find -name $log2view`
	dialog --colors --backtitle "System Master Script" --title "VM Help" --exit-label "OK" --textbox $dir2logfile 0 0
	echo "$dir2logfile vieved" >> $log
	return 1
}
