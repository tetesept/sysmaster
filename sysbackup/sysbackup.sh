#!/bin/bash
############################
#Sysmaster				   #
############################

#Basisinstallation
#Installiert wichtige Progremme:

sysbackup()
{
    local log=${instdir}/sysbackup/sysbackup.log                          #Default Logfile
	local targetbackupserver=none
	local CUSTOMER=backup
	local GPGOPTSFILE=${instdir}/sysbackup/${hostn}.gpgopts
	local BACKUPINFO=${instdir}/sysbackup/backupinfo.tmp
	local BASE=${instdir}/baseinst
	local dupver=`apt-cache policy duplicity | grep Installiert |  sed 's/\./ /g' | awk '{print $3}'`
	touch $log
	startlog $log
		
		#Subdirectory eingeben
		local precustomer=`echo $hostn |  sed 's/\./ /g' | awk '{print $2}'`
		
		local customerok=no
		until [ "$customerok" == "ok" ]
		do
			CUSTOMER=`dialog --colors --backtitle "System Master Script" --title "Create Backup" --inputbox "Enter Subdirectory" 0 0 "${precustomer}" 3>&1 1>&2 2>&3`
			if [ "$?" == "1"  ]
			then
				return 0;
			fi
			case $CUSTOMER in
				*[a-z]|[A-Z]*)
					customerok=ok                        
				;;
				*)
					dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nWrong input. Define a valid Customer like ard" 6 100
				;;
			esac
		done
		
		
		#Sftp Server eingeben eingeben		
		local ipok=no
		until [ "$ipok" == "ok" ]
		do
			targetbackupserver=`dialog --colors --backtitle "System Master Script" --title "Create Backup" --inputbox "Enter Backupserver IP-Adress" 0 0 "${precustomer}" 3>&1 1>&2 2>&3`
			if [ "$?" == "1"  ]
			then
				return 0;
			fi
			case $targetbackupserver in
				*.*.*.*.* | *..* | [!0-9]* | *[!0-9] | *[0-9][0-9][0-9][0-9]* | *2[5-9][5-9]* )
					dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nWrong input. Define a valid IP-Address like 214.68.7.15" 6 100			
				;;	
				
				*.*.*.* | *[0-9]* | *[0-9][0-9]* | *1[0-9][0-9]* | *2[0-5][0-9]* )
					ipok=ok                        
				;;
				*)
					dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nWrong input. Define a valid IP-Address like 214.68.7.15" 6 100
				;;
			esac
		done
			
		#Komponenten installieren
		#update
        (
        echo "10" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing python" 8 80
			apt-get -q -y --force-yes update 1>>$log 2>>$log 3>>$log
		#misc
        (
        echo "20" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing div" 8 80
			apt-get -q -y --force-yes install gnupg rng-tools tar rar pwgen dos2unix 1>>$log 2>>$log 3>>$log
		#python
        (
        echo "30" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing python" 8 80
			apt-get -q -y --force-yes install python libc6 librsync1 python-lockfile 1>>$log 2>>$log 3>>$log
		#python-paramiko 
        (
        echo "40" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing python-paramiko" 8 80
			apt-get -q -y --force-yes install python-paramiko 1>>$log 2>>$log 3>>$log
		#python-pexpect
		(
        echo "50" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing python-pexpect" 8 80
			apt-get -q -y --force-yes install python-pexpect 1>>$log 2>>$log 3>>$log
		#python-gnupginterface
        (
        echo "60" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing ython-gnupginterface" 8 80
			apt-get -q -y --force-yes install python-gnupginterface 1>>$log 2>>$log 3>>$log
		#python-gnupginterface
        (
        echo "70" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing python-gobject-2" 8 80
			apt-get -q -y --force-yes install python-gobject-2 1>>$log 2>>$log 3>>$log
		#lxcfs
        (
        echo "70" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Removing lxcfs" 8 80
			apt-get -q -y --force-yes remove lxcfs 1>>$log 2>>$log 3>>$log			
		#duplicity installieren
        (
        echo "85" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing duplicity" 8 80
			apt-get -q -y --force-yes install duplicity  1>>$log 2>>$log 3>>$log
		#done
		(
        echo "100" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Done!" 8 80	
				
		#Create Backup Users
		local userpass="$(pwgen -c -n -s 12 1)"
		local user=bu`date +%y%m%d%H%M%S`
		echo "Backupuser for $hostn" > $BACKUPINFO
		echo "${user}" >> $BACKUPINFO
		echo "${userpass} " >> $BACKUPINFO
		
		#GPG Key erzeugen
		sed -i 's/\#HRNGDEVICE\=\/dev\/null/HRNGDEVICE\=\/dev\/urandom/g' /etc/default/rng-tools
		
		dialog --colors --stdout --backtitle "System Master Script" --title "Sysinfo" --msgbox "\Z1Warning\Zn \nGathering Enthopie may take some time\n" 6 60 --and-widget --timeout 1 --nook --begin 15 15 --infobox "Gathering Enthopie..." 5 30	
		
		/etc/init.d/rng-tools start 1>>$log 2>>$log 3>>$log
		
		local pass="$(pwgen 16 -c -n -s | awk '{print $1}')"
		echo " " >> $BACKUPINFO
		echo "GnuPG Passphrase für ${hostn}" >> $BACKUPINFO
		echo "${pass}" >> $BACKUPINFO
		
		echo " " >> $BACKUPINFO
		echo "Bitte auf dem SFTP Server als root ausführen:" >> $BACKUPINFO	
		echo "./add-backup-user.sh ${user} ${userpass} ${hostn} home3" >> $BACKUPINFO
		
		echo "Key-Type: DSA" > ${GPGOPTSFILE}
		echo "Key-Length: 1024" >> ${GPGOPTSFILE}
		echo "Subkey-Type: ELG-E" >> ${GPGOPTSFILE}
		echo "Subkey-Length: 1024" >> ${GPGOPTSFILE}
		echo "Name-Real: ${CUSTOMER}" >> ${GPGOPTSFILE}
		echo "Name-Comment: ${hostn}" >> ${GPGOPTSFILE}
		echo "Name-Email: backup@${hostn}" >> ${GPGOPTSFILE}
		echo "Expire-Date: 0" >> ${GPGOPTSFILE}
		echo "Passphrase: ${pass}" >> ${GPGOPTSFILE}
		echo "%pubring: /root/.gnupg/pubring.gpg" >> ${GPGOPTSFILE}
		echo "%secring: /root/.gnupg/secring.gpg" >> ${GPGOPTSFILE}
		echo "%commit" >> ${GPGOPTSFILE}
		echo "%echo done" >> ${GPGOPTSFILE}
		echo "#EOF" >> ${GPGOPTSFILE}

		mkdir -v /root/.gnupg 1>>$log 2>>$log 3>>$log
		touch /root/.gnupg/pubring.gpg 1>>$log 2>>$log 3>>$log
		touch /root/.gnupg/secring.gpg 1>>$log 2>>$log 3>>$log
	
		gpg --gen-key --no-options --batch --no-default-keyring --keyring /root/.gnupg/pubring.gpg --secret-keyring /root/.gnupg/secring.gpg ${GPGOPTSFILE} 1>>$log 2>>$log 3>>$log
		cp -rv /root/.gnupg ${instdir}/sysbackup/${hostn}.gnupg 1>>$log 2>>$log 3>>$log
		gpg --export >> ${instdir}/sysbackup/${hostn}.pub 1>>$log 2>>$log 3>>$log
		gpg --export-secret-keys >> ${instdir}/sysbackup/${hostn}.key 1>>$log 2>>$log 3>>$log
		tar -cvzf ${instdir}/sysbackup/${hostn}_gpg.tar.gz ${instdir}/sysbackup/${hostn}.* 1>>$log 2>>$log 3>>$log
		
		mutt -s "Backup GPG-Key für ${hostn}." $defaultmail -a ${GPGOPTSFILE} -a ${instdir}/sysbackup/${hostn}_gpg.tar.gz -a ${instdir}/extern/backupserver/add-backup-user.sh < ${BACKUPINFO}
		
		rm -r sysbackup/${hostn}.gnupg
		rm sysbackup/${hostn}.key
		rm sysbackup/${hostn}.pub
		rm sysbackup/${hostn}.gpgopts
			
		/etc/init.d/rng-tools stop 1>>$log 2>>$log 3>>$log

		#Duplicity
		mkdir -v -p /var/log/dupl_backup 1>>$log 2>>$log 3>>$log
		mkdir -v -p /root/backup 1>>$log 2>>$log 3>>$log
		
		cp -v ${instdir}/sysbackup/backup/* /root/backup 1>>$log 2>>$log 3>>$log
		
		chmod +x /root/backup/*.sh
		
		#Zufallstag Montag - Samstag
		randday=`echo $((($RANDOM % (7-1))+1))`
		
		#Zufallsstunde mir gewichtung auf Morgends
		randAMPM=`echo $((($RANDOM % (5-1))+1))`
		if [ "$randAMPM" == "1" ]
		then
			randhour=`echo $((($RANDOM % (24-21))+21))`		#Abends 21-23 Uhr
		else
			randhour=`echo $((($RANDOM % (6-0))+0))`		#Morgends 0-5 uhr
		fi
		
		#Cron jobs
		crontab -l > /root/crontab
		cjob=`grep Fullbackup /root/crontab`
		if [ "$cjob" == "" ]
		then
			echo >> /root/crontab
			echo "#Fullbackup Sonntag um 3:00 Uhr" >> /root/crontab
			echo "0 $randhour * *  $randday /root/backup/fullbackup.sh" >> /root/crontab
			echo "#Inkrementelles Backup Freitag - Samstag 3:00 Uhr" >> /root/crontab
			echo "#0 $randhour * * 1-6 /root/backup/incrbackup.sh" >> /root/crontab
			/usr/bin/crontab /root/crontab
			echo "Cron Job added" 1>>$log 2>>$log 3>>$log
		else
			echo "Cron Job alreaddy added" 1>>$log 2>>$log 3>>$log
		fi
		
		echo "" 1>>$log 2>>$log 3>>$log
		echo "SSH Keys" 1>>$log 2>>$log 3>>$log
		#Accept ssh Fingerprints 
		mkdir ~/.ssh  1>>$log 2>>$log 3>>$log
		#touch ~/.ssh/config
		#echo "Host *" >> ~/.ssh/config
		#echo "    StrictHostKeyChecking no" >> ~/.ssh/config	
		ssh-keyscan -H $targetbackupserver >> ~/.ssh/known_hosts
		/etc/init.d/ssh restart
		
		#Edit FULL DUblicitty config
		sed '/^user=/d' /root/backup/fullbackup.sh > /root/backup/fullbackup.sh.tmp1
		sed '/^pw=/d' /root/backup/fullbackup.sh.tmp1 > /root/backup/fullbackup.sh.tmp2
		sed '/^export PASSPHRASE=/d' /root/backup/fullbackup.sh.tmp2 > /root/backup/fullbackup.sh.tmp3
		sed '/^defaultmail=/d' /root/backup/fullbackup.sh.tmp3 > /root/backup/fullbackup.sh.tmp4
		sed '/^targetserver=/d' /root/backup/fullbackup.sh.tmp4 > /root/backup/fullbackup.sh.tmp5
		
		sed -e "/^### configure this ###$/a pw=${userpass}" /root/backup/fullbackup.sh.tmp5 > /root/backup/fullbackup.sh.tmp6
		sed -e "/^### configure this ###$/a user=${user}" /root/backup/fullbackup.sh.tmp6 > /root/backup/fullbackup.sh.tmp7
		sed -e "/^### The GPG Key ###$/a export PASSPHRASE='${pass}'" /root/backup/fullbackup.sh.tmp7 > /root/backup/fullbackup.sh.tmp8
		sed -e "/^### variables ###$/a defaultmail=${defaultmail}" /root/backup/fullbackup.sh.tmp8 > /root/backup/fullbackup.sh.tmp9
		sed -e "/^### configure this ###$/a targetserver=${targetbackupserver}" /root/backup/fullbackup.sh.tmp9 > /root/backup/fullbackup.sh.tmp10	
		cat /root/backup/fullbackup.sh.tmp10 > /root/backup/fullbackup.sh 
		
		#Edit INC Dublicitty config
		sed '/^user=/d' /root/backup/incrbackup.sh > /root/backup/incrbackup.sh.tmp1
		sed '/^pw=/d' /root/backup/incrbackup.sh.tmp1 > /root/backup/incrbackup.sh.tmp2
		sed '/^export PASSPHRASE=/d' /root/backup/incrbackup.sh.tmp2 > /root/backup/incrbackup.sh.tmp3
		sed '/^defaultmail=/d' /root/backup/incrbackup.sh.tmp3 > /root/backup/incrbackup.sh.tmp4
		sed '/^targetserver=/d' /root/backup/incrbackup.sh.tmp4 > /root/backup/incrbackup.sh.tmp5
		
		sed -e "/^### configure this ###$/a pw=${userpass}" /root/backup/incrbackup.sh.tmp5 > /root/backup/incrbackup.sh.tmp6
		sed -e "/^### configure this ###$/a user=${user}" /root/backup/incrbackup.sh.tmp6 > /root/backup/incrbackup.sh.tmp7
		sed -e "/^### The GPG-Key ###$/a export PASSPHRASE='${pass}'" /root/backup/incrbackup.sh.tmp7 > /root/backup/incrbackup.sh.tmp8
		sed -e "/^### variables ###$/a defaultmail=${defaultmail}" /root/backup/incrbackup.sh.tmp8 > /root/backup/incrbackup.sh.tmp9
		sed -e "/^### configure this ###$/a targetserver=${targetbackupserver}" /root/backup/incrbackup.sh.tmp9 > /root/backup/incrbackup.sh.tmp10
		cat /root/backup/incrbackup.sh.tmp10 > /root/backup/incrbackup.sh 
		
		rm /root/backup/*.tmp*
	return 1
}

sysrestore()
{
    local log=${instdir}/sysbackup/sysrestore.log                          #Default Logfile
	local backupcol=${instdir}/sysbackup/sysrestore_status.log
	rm -v $backupcol  1>>$log 2>>$log 3>>$log
	touch $backupcol
	touch $log
	startlog $log
	
	#Try fetchin backup Server
	targetserver=`grep user= /root/backup/fullbackup.sh | sed s/"targetserver="/""/g`

	local pingubu=`ping -c 1 $targetserver | grep loss | awk '{print $6}' | sed s/"%"/""/g` 1>>$log 2>>$log 3>>$log
	if [ "$pingubu" != "0" ]
	then		
		dialog --colors --title "Sysrestore" --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nSFTP is not reachable \nPlease check connection" 8 80
		echo "Failed to ping to SFTP" >> $log
		exitsh
	else
		echo "Ping to SFTP successful" >> $log
	fi
	
	#Restore verzeichniss erstellen
	if [ -d /root/backup/restore ]; then
		echo "Backup Dir: /root/backup, already exists!" 1>>$log 2>>$log 3>>$log
	else
		mkdir -pv /root/backup/restore 1>>$log 2>>$log 3>>$log
	fi
	
	#Try fetchin login Data
	user=`grep user= /root/backup/fullbackup.sh | sed s/"user="/""/g`
	password=`grep pw= /root/backup/fullbackup.sh | sed s/"pw="/""/g`
	passphrase=`grep PASSPHRASE= /root/backup/fullbackup.sh | sed s/"export PASSPHRASE='"/""/g | sed s/"'"/""/g`
	
	#Backup zugangsdaten eingeben
	local inputok="no"
	until [ "$inputok" == "ok" ]
	do
		restoredata=$(dialog --separate-widget $'\n' --ok-label "Ok" --backtitle "System Master Script" --title "Sysrestore" --form "creating new " 12 80 0 \
        "SFTP User: "              1 1 "${user}"       	1 25 40 0 \
        "SFTP Password:"           2 1 "${password}"   	2 25 40 0 \
        "Passphrase:"              3 1 "${passphrase}"	3 25 40 0 \
		"Age in Days:"             4 1 "0"        		4 25 40 0 \
		3>&1 1>&2 2>&3) 	
		if [ $? != 0 ]
		then
          	return 1									
        fi
		
		VARIABLEN=$(echo "$restoredata" | tr "\n" " ")
		user=$(echo "$VARIABLEN" | awk '{print $1}')		
		password=$(echo "$VARIABLEN" | awk '{print $2}')	
		passphrase=$(echo "$VARIABLEN" | awk '{print $3}')
		oldbackup=$(echo "$VARIABLEN" | awk '{print $4}')
		export PASSPHRASE=${passphrase}

		if [ "$user"  != ""  ]
		then
			if [ "$password" != "" ]
			then
				if [ "$passphrase" != "" ]
				then
					inputok="ok"
				else
					dialog --colors --title "Sysbackup" --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nDefine a valid passphrase" 6 80	
				fi
			else
				dialog --colors --title "Sysbackup" --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nDefine a valid password" 6 80	
			fi
		else
			dialog --colors --title "Sysbackup" --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nDefine a valid username" 6 80		
		fi
	done
			
	#Collection status
	bsource=/root/restore				# Source of your Backup, eg. / for the whole Server excluding what is inside the excludefile
	btarget=${targetserver}/backup			# Target of your Backup >>> IP/backup, eg. 192.168.0.1/backup
	mkdir -v -p $bsource 1>>$log 2>>$log 3>>$log
	
	if [ "$currel" == "16" ]
	then
		duplicity collection-status sftp://${user}:${password}@${btarget} 1>>$backupcol 2>>$backupcol 3>>$backupcol
	else
		duplicity collection-status scp://${user}:${password}@${btarget} 1>>$backupcol 2>>$backupcol 3>>$backupcol
	fi
	
	dialog --colors --backtitle "System Master Script" --title "System Info" --exit-label "OK" --extra-button --extra-label "Exit" --textbox $backupcol 0 0
	if [ "$?" == "3"  ]
	then
		return 0;
	fi

	#Restore Type
	restoreopt=`dialog --cancel-label "Exit" --backtitle "System Master Script" --title "Config Tools Sub Menu" --menu "Move pressing [UP] or [DOWN], [Enter] to select" 0 0 0 \
		Full_Restore_to_Folder "Restore the whole system to /root/backup/restore" \
		File_Restore_to_Folder "Restore a file to /root/backup/restore" \
		DB_Restore_to_Folder "Restore a db to /root/backup/restore" \
		Back "Go back to Master Menue" \
        3>&1 1>&2 2>&3`
	if [ $? != 0 ]
    then
       	exitsh							#--> ./funk/funk.sh	
    fi
	
	if [ "$restoreopt" == "File_Restore_to_Folder" ]
	then
		file_to_restore=`dialog --colors --backtitle "System Master Script" --title "File to restore" --inputbox "Enter PathtoFile:" 0 0 "/" 3>&1 1>&2 2>&3`
		if [ "$?" == "1"  ]
		then
			return 0;
		fi
		file_to_restore=`echo $file_to_restore | sed 's/\///'`
	fi
	
	#Restore saubermachen
	dialog --colors --backtitle "System Master Script" --infobox "\Z1Note\Zn \nCleaning restore folder..." 5 50
	sleep 3
	rm -R /root/backup/restore 1>>$log 2>>$log 3>>$log
	dialog --colors --backtitle "System Master Script" --infobox "\Z1Note\Zn \nCleaning restore folder...Done" 5 50
	sleep 3
	
	#Restore
	local restoreinfo=${instdir}/sysbackup/sysrestore_info.log
	rm -v $restoreinfo 1>>$log 2>>$log 3>>$log	
	touch $restoreinfo
	dialog --colors --backtitle "System Master Script" --title "New Release Check" --no-kill --tailboxbg $restoreinfo 50 120
	
	echo "" >> $restoreinfo
	echo "#################"  >> $restoreinfo
	echo "#   Sysmaster   #"  >> $restoreinfo
	echo "#    Restore    #"  >> $restoreinfo
	echo "#################"  >> $restoreinfo
    echo ""  >> $restoreinfo
	sleep 2
	echo "!!!Warning!!!"  >> $restoreinfo
	echo "Starting Restore..."  >> $restoreinfo
	echo "Don't force an unexpected reboot!"  >> $restoreinfo
	echo ""  >> $restoreinfo
	sleep 5
	
	echo "Restore $restoreopt" 1>>$log 2>>$log 3>>$log
	#Restore was auch immer
	case $restoreopt in									
		Full_Restore_to_Folder)
			echo "I put the system back!" 1>>$log 2>>$log 3>>$log
			if [ "$currel" == "16" ]
			then
				duplicity -t ${oldbackup}D --force sftp://${user}:${password}@${btarget} /root/backup/restore/ >> $restoreinfo
			else
				duplicity -t ${oldbackup}D --force scp://${user}:${password}@${btarget} /root/backup/restore/ >> $restoreinfo		
			fi
		;;
		Full_Restore_to_System)
			echo "I put the system back!"  1>>$log 2>>$log 3>>$log
			if [ "$currel" == "16" ]
			then
				duplicity -t ${oldbackup}D --force sftp://${user}:${password}@${btarget} /root/backup/restore/ >> $restoreinfo
			else
				duplicity -t ${oldbackup}D --force scp://${user}:${password}@${btarget} /root/backup/restore/ >> $restoreinfo
			fi			
			mv -r -v -a /root/backup/restore / | tee $log		
		;;
		File_Restore_to_Folder)
			echo "I put the file back!"  1>>$log 2>>$log 3>>$log
			if [ "$currel" == "16" ]
			then
				duplicity -t ${oldbackup}D  --verbosity 5 --file-to-restore ${file_to_restore} sftp://${user}:${password}@${btarget} /root/backup/restore/ >> $restoreinfo
			else
				duplicity -t ${oldbackup}D  --verbosity 5 --file-to-restore ${file_to_restore} scp://${user}:${password}@${btarget} /root/backup/restore/ >> $restoreinfo
			fi
			echo $file_to_restore 1>>$log 2>>$log 3>>$log
		;;
		DB_Restore_to_Folder)
			echo "I put the db back!"  1>>$log 2>>$log 3>>$log
			if [ "$currel" == "16" ]
			then
				duplicity -t ${oldbackup}D  --verbosity 5 --file-to-restore root/backup/db sftp://${user}:${password}@${btarget} /root/backup/restore/ >> $restoreinfo
			else
				duplicity -t ${oldbackup}D  --verbosity 5 --file-to-restore root/backup/db scp://${user}:${password}@${btarget} /root/backup/restore/ >> $restoreinfo
			fi
		;;
		Back)
        ;;
    esac
	
	killdialog
	unset passphrase
	unset password	
	
	dialog --colors --backtitle "System Master Script" --title "System Info" --exit-label "OK" --msgbox "\Z1Note\Zn \nRestore Done!\nData restored to /root/backup/restore/" 0 0
	
	return 0
}

sysdbbackup()
{
	local log=${instdir}/sysbackup/sysdbbackup.log                          #Default Logfile
	touch $log
	startlog $log
	
	TARGET=/root/backup/db
	CONF=/etc/mysql/debian.cnf
	
	mkdir -v -p /root/backup/db 1>>$log 2>>$log 3>>$log
	mkdir -v -p /var/log/dbbackup/ 1>>$log 2>>$log 3>>$log
	
	if [ ! -r $CONF ]
	then 
		dialog --colors --title "Sysbackup" --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nAuf $CONF konnte nicht zugegriffen werden" 7 80
		return 0
	fi
	
	cp -v ${instdir}/sysbackup/backup/dbbackup.sh /root/backup 1>>$log 2>>$log 3>>$log
	chmod 775 /root/backup/dbbackup.sh
	
	#Cron jobs
	crontab -l > /root/crontab
	cjob=`egrep "#DB Backup" /root/crontab`
	if [ "$cjob" == "" ]
	then
		echo >> /root/crontab
		echo "#DB Backup" >> /root/crontab
		echo "0 2 * * * /root/backup/dbbackup.sh" >> /root/crontab
		/usr/bin/crontab /root/crontab
		echo "Cron Job added" 1>>$log 2>>$log 3>>$log
	else
		echo "Cron Job alreaddy added" 1>>$log 2>>$log 3>>$log
	fi
	return 0
}

syscollectionstatus()
{
	local log=${instdir}/sysbackup/syscollectionstatus.log                          #Default Logfile
	local status=${instdir}/sysbackup/collectionstatus.log                          #Default Logfile
	touch $log
	rm -v $status  1>>$log 2>>$log 3>>$log
	touch $status
	startlog $log
	
	if [ -f /root/backup/fullbackup.sh ]
	then
		echo "Backup directory found" 1>>$log 2>>$log 3>>$log
	else
		echo "Backup directory not found" 1>>$log 2>>$log 3>>$log
		dialog --colors --title "Sysbackup" --backtitle "System Master Script" --msgbox "\Z1Error\ZnBackup is not active!\nYou have to install a backup first" 7 80
		return 0
	fi
	
	targetserver=`grep user= /root/backup/fullbackup.sh | sed s/"targetserver="/""/g`
	user=`grep user /root/backup/fullbackup.sh | sed 's/=/ /' | awk '{print $2}' | head -n 1`                                             
	pw=`grep pw /root/backup/fullbackup.sh | sed 's/=/ /' | awk '{print $2}' | head -n 1`                                                    
	bsource=/                                                     
	btarget=${targetserver}/backup    
	PASSPHRASE=`grep PASSPHRASE /root/backup/fullbackup.sh | sed 's/=/ /' | awk '{print $3}' | head -n 1 | sed "s/'//g"`
	export $PASSPHRASE
	
	echo "-----------------Crontab----------------" >> $status
	crontab -l >> $status
	echo "" >> $status
	
	echo "-----------------Collection-------------" >> $status
	duplicity collection-status sftp://${user}:${pw}@${btarget} >> $status
	
	duplicity verify --exclude-globbing-filelist ${excludefile} scp://${user}:${pw}@${btarget} ${bsource} >> $status
	
	dialog --colors --backtitle "System Master Script" --title "System Collection Status " --exit-label "OK" --textbox $status 0 0
}
