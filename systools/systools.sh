#!/bin/bash
############################
#Sysmaster				   #
############################

systracestart()
{
	local log=${instdir}/systools/systemtracestart.log                          #Default Logfile
	local crontabfile=${instdir}/systools/crontabfile.log
	local tracefile=${pwddir}/systools/trace.sh
	touch $crontabfile
	touch $log
	startlog $log
	
	dialog --colors --backtitle "System Master Script" --msgbox "\Z1Note\Zn \nStarting Trace..." 7 100
	
	apt-get -q -y --force-yes install sysstat 1>>$log 2>>$log 3>>$log
	chmod +x $tracefile
	
	crontab -l > $crontabfile
	findjob=`grep trace.sh $crontabfile`	
	if [ "$findjob" == "" ]
	then
		echo "* * * * * $tracefile > /dev/null 2>&1 3>&1" >> $crontabfile
		crontab $crontabfile
		dialog --colors --backtitle "System Master Script" --msgbox "\Z1Note\Zn \nTrace active" 7 100
	else
		dialog --colors --backtitle "System Master Script" --msgbox "\Z1Note\Zn \nTrace alreaddy active" 7 100	
	fi
}

systracereset()
{
	local log=${instdir}/systools/systemtracereset.log                          #Default Logfile
	touch $log
	startlog $log

	dialog --colors --backtitle "System Master Script" --msgbox "\Z1Note\Zn \nTrace resetted" 7 100	
	rm /root/trace.log

}

systracestop()
{
	local log=${instdir}/systools/systemtracestop.log                          #Default Logfile
	local crontabfile=${instdir}/systools/crontabfile.log
	local newcrontabfile=${instdir}/systools/newcrontabfile.log

	touch $log
	startlog $log
	
	crontab -l > $crontabfile
	findjob=`grep trace.sh $crontabfile`
	if [ "$findjob" == "" ]
	then
		dialog --colors --backtitle "System Master Script" --msgbox "\Z1Note\Zn \nTrace alreaddy inactive" 7 100
	else
		cat $crontabfile | sed '/trace.sh/d' > $newcrontabfile
		crontab $newcrontabfile
		dialog --colors --backtitle "System Master Script" --msgbox "\Z1Note\Zn \nTrace inactive" 7 100	
	fi

}

systraceanalyse()
{
	local log=${instdir}/systools/systemtracestop.log                          #Default Logfile
	local tracelog=/root/trace.log
	local filterlog=${instdir}/systools/filtertrace.log

	touch $filterlog
	touch $log
	startlog $log
	
	local filterok=no
	until [ "$filterok" == "ok" ]
		do
			filter=`dialog --colors --backtitle "System Master Script" --title "Chose a Filter" --radiolist "Chose OS:" 0 0 0 \
			All "Everithing" on\
			Ping "Latency" off\
			Load "Load" off\
			FreeMem "Free Menmory" off\
			CpuIdle "CPU Idle" off\
			IOWait "HDD wait" off 3>&1 1>&2 2>&3`
			if [ "$?" == "1"  ] 
			then
				return 0
			fi
			case $filter in
				"")
					dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nYou have to chose an Filter. Select Filter with [Arrow-Keys], mark with [Space] and press [Enter] for OK" 6 100
				;;
				All)
					cat $tracelog > $filterlog
					filterok=ok						
				;;
				Ping)
					grep "Ping" $tracelog > $filterlog
					filterok=ok
				;;
				Load)
					grep "Load" $tracelog > $filterlog
					filterok=ok
					;;
				FreeMem)
					grep "FreeM" $tracelog > $filterlog
					filterok=ok
				;;
				IOWait)
					grep "Iowait" $tracelog > $filterlog
					filterok=ok
				;;
				CpuIdle)
					grep "Idle" $tracelog > $filterlog
					filterok=ok
				;;
		esac
	done
	dialog --colors --backtitle "System Master Script" --textbox $filterlog 50 100
}

sysmonitor()
{
	local log=${instdir}/systools/sysmonitor.log                          #Default Logfile
	touch $log
	startlog $log
	
	if [ "$(which glances)" == "" ]
	then
		dialog --colors --stdout --backtitle "System Master Script" --title "Sysinfo" --msgbox "\Z1Info\Zn\nInstalling Glances and PySensors...\n\nHow to Analyse:\nGREEN : the statistic is “OK”\nBLUE : the statistic is “CAREFUL” (to watch)\nVIOLET : the statistic is “WARNING” (alert)\nRED : the statistic is “CRITICAL” (critical)\n"q" : to exit" 16 60 --and-widget --timeout 1 --nook --begin 15 15 --infobox "Installing..." 6 30	
		apt-get -q -y --force-yes install python-pip build-essential python-dev 1>>$log 2>>$log 3>>$log
		pip install Glances 1>>$log 2>>$log 3>>$log
		pip install PySensors 1>>$log 2>>$log 3>>$log
	fi
	glances
	return 1
}

sysvirtualserver()
{
	local log=${instdir}/systools/sysvirtualserver.log                          #Default Logfile
	touch $log
	startlog $log

		#Update
        (
        echo "20" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Updateing Packagelist" 8 80
			apt-get -q -y --force-yes update 1>>$log 2>>$log 3>>$log
		#virtual Kernel installieren
        (
        echo "40" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing virtual Kernel" 8 80
			apt-get -q -y --force-yes install --install-recommends linux-virtual-lts-xenial  1>>$log 2>>$log 3>>$log
		#virtual tools installieren
        (
        echo "50" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing virtual tools" 8 80
			apt-get -q -y --force-yes install --install-recommends linux-tools-virtual-lts-xenial  1>>$log 2>>$log 3>>$log
		#nrpe cloud tools
        (
        echo "60" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing cloud tools " 8 80
			apt-get -q -y --force-yes install --install-recommends linux-cloud-tools-virtual-lts-xenial  1>>$log 2>>$log 3>>$log
		#V-Module installieren
        (
        echo "80" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing V-Module" 8 80
			local hv_vmbus=`grep hv_vmbus /etc/initramfs-tools/modules`
			if [ "$hv_vmbus" == "" ]
			then
				echo hv_vmbus >> /etc/initramfs-tools/modules
			fi

			local hv_storvsc=`grep hv_storvsc /etc/initramfs-tools/modules`
			if [ "$hv_storvsc" == "" ]
			then
				echo hv_storvsc >> /etc/initramfs-tools/modules
			fi

			local hv_blkvsc=`grep hv_blkvsc /etc/initramfs-tools/modules`
			if [ "$hv_blkvsc" == "" ]
			then
				echo hv_blkvsc >> /etc/initramfs-tools/modules
			fi

			local hv_netvsc=`grep hv_netvsc /etc/initramfs-tools/modules`
			if [ "$hv_netvsc" == "" ]
			then
				echo hv_netvsc >> /etc/initramfs-tools/modules
			fi
		#initramfs restart
        (
        echo "60" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Update initramfs " 8 80
			update-initramfs -u  1>>$log 2>>$log 3>>$log
		#Sheduler restart
        (
        echo "60" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Changing CPU Sheduler to non elevated" 8 80

		local elevator=`grep CMDLINE_LINUX /etc/default/grub`
		if [ "$elevator"  == "" ]
		then
			cp /etc/default/grub /etc/default/grub.back
			local CMDLINE_LINUX=`grep GRUB_CMDLINE_LINUX_DEFAULT /etc/default/grub`
			sed -i 's/$CMDLINE_LINUX/#$CMDLINE_LINUX/' /etc/default/grub
			echo "GRUB_CMDLINE_LINUX_DEFAULT=\"elevator=noop\"" >> /etc/default/grub
		fi
		#Grub restart
        (
        echo "60" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Updating Grub" 8 80
			update-grub  1>>$log 2>>$log 3>>$log
		#nagios restart
        (
        echo "60" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Init reboot" 8 80
		    dialog --colors --backtitle "System Master Script" --title "Firewall" --yesno "\Z1Warning\Zn \nReboote is required\nReboote now?"  7 80
			case $? in
			1)
                echo "No Reboot" >> $log
			;;
			0)
				echo "Reboot" >> $log
				reboot
			;;
			esac
		#done
		(
        echo "100" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Done!" 8 80	
	return 1
}

transupload()
{
	local log=${instdir}/systools/transupload.log                          #Default Logfile
	touch $log
	startlog $log
	
	FILE=$(dialog --stdout --title "Please choose a file" --fselect $HOME/ 15 100)
	clear
	tmpfile=$( mktemp -t transferXXX )
	basefile=$(basename "$FILE" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
	
	echo "Uploading File in progress"
	curl --progress-bar --upload-file "$FILE" "https://transfer.sh/$basefile" >> $tmpfile
	durl=`cat $tmpfile`
	echo "User URL in your Browser or wget to download your File "
	
	echo ""
	echo "$fett $durl $reset"
	echo ""
	
	exit
	
	
	rm $tmpfile
}

transdownload()
{
	local log=${instdir}/systools/transdownload.log                          #Default Logfile
	touch $log
	startlog $log
	
	durl=`dialog --inputbox "Download URL:" 0 0 "https://transfer.sh/"`
	wget $durl
	dialog --msgbox "\Z1Notice\Zn \nFile saved to $instdir" 8 80
	
}


strongzert()
{
    local log=${instdir}/systools/transdownload.log                          #Default Logfile
    touch $log
    startlog $log

	mkdir -p /etc/myssl/
	mkdir -p /etc/myssl/old_$date
	mv -v etc/myssl/* /etc/myssl/old_$date 1>>$log 2>>$log 3>>$log

	clear

	#Key generieren und Passphrase vergeben
	openssl genrsa -out $privfile 2048

	#Key Rechte setzen
	chmod 600 $privfile
	
	#CSR genereiren
	openssl req -new -key $privfile -out $csrfile
	
	#Zertifikat generieren
	openssl x509 -req -days 999 -in $csrfile -signkey $privfile -out $pubfile    
    openssl rsa -in $privfile -out ${privfileu}.unencrypted
	
	#Key sichern
	mv -f ${privfileu}.unencrypted $privfile
	
	#Root Zertifikat erstellen CA
	openssl req -new -x509 -extensions v3_ca -keyout $caprivfile -out $cafile -days 999
	
	#Restart diesnte
	service postfix reload 1>>$log 2>>$log 3>>$log
	service apache2 reload 1>>$log 2>>$log 3>>$log
	
	read -p "Press enter to continue"
	
	if [ -f  $pubfile ] || [ -f  $privfile ] || [ -f  $cafile ] || [ -f  $caprivfile ] || [ -f  $csrfile ]
	then
			openssl x509 -noout -issuer -dates -in $pubfile
	
			dialog --colors --backtitle "System Master Script" --title "Firewall" --msgbox "\Z1Info\Zn \nCertificat generation successful\nCertificat have been copied to /etc/myssl/"  8 80
	else
			dialog --colors --backtitle "System Master Script" --title "Firewall" --msgbox "\Z1Error\Zn \nCertificat generation not successful\nPlease retry"  8 80
	fi


}
