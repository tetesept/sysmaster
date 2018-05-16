#!/bin/bash
############################
#Sysmaster				   #
############################

#Versions informationen
#Neuerungen
#Author

version()
{
	local vr="${instdir}/version/version.tmp"
	rm $vr
	touch $vr
	echo "" >> $vr
	echo " ###############################################" >> $vr
	echo " #              SysMaster Skript               #" >> $vr
	echo " ###############################################" >> $vr
	echo "" >> $vr
	echo " Autor: $autor " >> $vr
	echo " Version: $version " >> $vr
	echo " Releasedate: $chdatum " >> $vr
	echo " Lines of Code: $loc"  >> $vr
	echo "" >> $vr
	echo " Web: http://www.tetesept.de" >> $vr
	echo " Mail: $defaultmail" >> $vr
	echo "" >> $vr
	echo " New in ${version}:" >> $vr
	echo " --$chlog1" >> $vr
	echo " --$chlog2" >> $vr
	echo " --$chlog3" >> $vr
	echo "" >> $vr
	dialog --colors --backtitle "System Master Script" --title "Version Info" --ok-label "Back"  --extra-button --extra-label "Exit" --textbox $vr 0 0
	case $? in
		0)
			return 0
		;;
		3)
			exitsh
		;;
	esac
	return 1
}
