#!/bin/bash
############################
#Sysmaster				   #
############################

#Basisinstallation
#Installiert wichtige Programme

baseinst()
{
    local log=${instdir}/baseinst/baseinst.log                          #Default Logfile
	local PW_RS=${instdir}/baseinst/PW_RS_${datetime}.log
	local BASE=${instdir}/baseinst
	local GPGOPTSFILE=${instdir}/baseinst/gpgopts
	local ICINGATemplate=${instdir}/baseinst/icinga_template.txt
	local varfile=${instdir}/var/var.sh
	local varfilet1=${instdir}/var/var.tmp1
	local varfilet2=${instdir}/var/var.tmp2
	touch $log
	startlog $log
		#Check fqdn
        local hostfqdnok=no
		until [ "$hostfqdnok" == "ok" ]
		do
          	hostfqdn=`dialog --colors --backtitle "System Master Script" --title "Basisinstallation" --inputbox "Enter FQDN:" 0 0 "${hostn}" 3>&1 1>&2 2>&3`
            if [ "$?" == "1"  ]
            then
				return 0;
            fi
            case $hostfqdn in
				*.*.*)
					hostfqdnok=ok
					myip=`ifconfig | grep -E "encap|eth|br|address|net|gate" | egrep -v "#|loopback|inet6|Link encap" | awk '{print $2}' | sed s/"addr:"/""/g | sed s/"Adresse:"/""/g | egrep -v "127.0" | head -n 1`	
					#Hostname
					local hostname_only=`echo $hostfqdn | sed 's/\./ /' | awk '{print $1}'`
					echo $hostname_only > /etc/hostname
					#Hosts
					local domainname_only=`echo $hostfqdn |  sed 's/\./ /' | awk '{print $2,$3,$4,$5}'`
					mv /etc/hosts /etc/hosts.old  1>>$log 2>>$log 3>>$log
					echo 127.0.0.1 localhost > /etc/hosts	
					echo $myip	${hostname_only}.${domainname_only}		${hostname_only} >> /etc/hosts	
					echo ff02::1 ip6-allnodes >> /etc/hosts
					echo ff02::2 ip6-allrouters >> /etc/hosts
					hostname -F /etc/hostname
				;;
                *)
                    dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nWrong input. Define a valid FQDN like www.ard.de" 6 100
                ;;
            esac
        done
		#Set Default Mail
        local mailok=no
		until [ "$mailok" == "ok" ]
		do
          	mailadr=`dialog --colors --backtitle "System Master Script" --title "Basisinstallation" --inputbox "Admin Mail:" 0 0 "root@${domainname_only}" 3>&1 1>&2 2>&3`
            if [ "$?" == "1"  ]
            then
				return 0;
            fi
            case $mailadr in
				*@*.*)
					mailok=ok
					#Edit var
					sed '/^defaultmail=/d' $varfile > $varfilet1
					sed -e "/^#Allgemein Variablen$/a defaultmail=${mailadr}" $varfilet1 > $varfilet2
					cat $varfilet2 > $varfile

				;;
                *)
                    dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nWrong input. Define a valid Mail Adress like root@${domainname_only}" 6 100
                ;;
            esac
        done		
		
		#Update
        (
        echo "2" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Updateing Packagelist" 8 80
			apt-get -q -y --force-yes update 1>>$log 2>>$log 3>>$log
		#upgrade
        (
        echo "4" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Updateing Packages" 8 80
			#apt-get -q -y --force-yes upgrade 1>>$log 2>>$log 3>>$log
		#Smoth
        (
        echo "6" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Smoothing System" 8 80		
			apt-get -q -y -f --force-yes install  1>>$log 2>>$log 3>>$log
		#w3m installieren
        (
        echo "8" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing w3m" 8 80
			apt-get -q -y --force-yes install w3m  1>>$log 2>>$log 3>>$log
		#python-paramiko python-pexpect installieren
        (
        echo "10" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing python" 8 80
			apt-get -q -y --force-yes install python-paramiko python-pexpect python-gnupginterface 1>>$log 2>>$log 3>>$log
		#gnupg installieren
        (
        echo "14" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing gnupg" 8 80
			apt-get -q -y --force-yes install gnupg  1>>$log 2>>$log 3>>$log
		#sudo installieren
        (
        echo "16" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing sudo" 8 80
			apt-get -q -y --force-yes install sudo  1>>$log 2>>$log 3>>$log
		#rng-tools installieren
        (
        echo "18" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing rng-tools" 8 80
			apt-get -q -y --force-yes install rng-tools  1>>$log 2>>$log 3>>$log
		#fail2ban installieren
        (
        echo "20" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing fail2ban" 8 80
			apt-get -q -y --force-yes install fail2ban  1>>$log 2>>$log 3>>$log
			/etc/init.d/fail2ban restart 1>>$log 2>>$log 3>>$log
			
		#dnsutils installieren
        (
        echo "22" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing dnsutils" 8 80
			apt-get -q -y --force-yes install dnsutils  1>>$log 2>>$log 3>>$log
		#iptraf installieren
        (
        echo "24" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing iptraf" 8 80
			apt-get -q -y --force-yes install iptraf  1>>$log 2>>$log 3>>$log
		#htop installieren
        (
        echo "26" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing htop" 8 80
			apt-get -q -y --force-yes install htop  1>>$log 2>>$log 3>>$log
		#nano installieren
        (
        echo "28" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing nano" 8 80
			apt-get -q -y --force-yes install nano  1>>$log 2>>$log 3>>$log
		#mtr installieren
        (
        echo "30" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing mtr" 8 80
			apt-get -q -y --force-yes install mtr  1>>$log 2>>$log 3>>$log
		#tar installieren
        (
        echo "32" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing tar" 8 80
			apt-get -q -y --force-yes install tar  1>>$log 2>>$log 3>>$log
		#rsync installieren
        (
        echo "34" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing rsync" 8 80
			apt-get -q -y --force-yes install rsync  1>>$log 2>>$log 3>>$log
		#vim installieren
        (
        echo "36" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing vim" 8 80
			apt-get -q -y --force-yes install vim  1>>$log 2>>$log 3>>$log
			cp -v $instdir/baseinst/root/etc/vim/vimrc /etc/vim/ 1>>$log 2>>$log 3>>$log
		#joe installieren
        (
        echo "38" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing joe" 8 80
			apt-get -q -y --force-yes install joe  1>>$log 2>>$log 3>>$log
		#bc installieren
        (
        echo "40" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing bc" 8 80
                apt-get -q -y --force-yes install bc  1>>$log 2>>$log 3>>$log
        #postfix installieren
        (
        echo "42" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing postfix" 8 80        
			debconf-set-selections <<< "postfix postfix/mailname string $hostfqdn "
			debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
			apt-get -q -y --force-yes install postfix  1>>$log 2>>$log 3>>$log
		#mutt installieren
        (
        echo "44" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing mutt" 8 80
			apt-get -q -y --force-yes install mutt  1>>$log 2>>$log 3>>$log
		#mailutils installieren
        (
        echo "46" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing mailutils" 8 80
			apt-get -q -y --force-yes install mailutils  1>>$log 2>>$log 3>>$log
		#mailx installieren
         (
        echo "48" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing mailutils" 8 80
			apt-get -q -y --force-yes install mailx  1>>$log 2>>$log 3>>$log
		#ntpserver installieren
        (
        echo "50" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing ntpdate" 8 80
			apt-get -q -y --force-yes install ntpdate 1>>$log 2>>$log 3>>$log
			ntpdate -u -s $ntpserver 1>>$log 2>>$log 3>>$log
		#rar installieren 
        (
        echo "55" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing rar" 8 80
            apt-get -q -y --force-yes install rar 1>>$log 2>>$log 3>>$log
		#acpid installieren 
        (
        echo "57" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing acpid" 8 80
            apt-get -q -y --force-yes install acpid lsb-core 1>>$log 2>>$log 3>>$log
		#unrar installieren
        (
        echo "60" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing unrar" 8 80
            apt-get -q -y --force-yes install unrar 1>>$log 2>>$log 3>>$log
		#pwgen installieren
        (
        echo "65" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing pwgen" 8 80
            apt-get -q -y --force-yes install pwgen 1>>$log 2>>$log 3>>$log
		#pwgen installieren
        (
        echo "65" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing lsb" 8 80
            apt-get -q -y --force-yes install lsb-core 1>>$log 2>>$log 3>>$log
		#rkhunter installieren
        (
        echo "70" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing rkhunter" 8 80
			apt-get -q -y --force-yes install rkhunter 1>>$log 2>>$log 3>>$log
				#rkhunter standard config laden
				if [ -f /etc/rkhunter.conf ]
				then
					echo "Rkhunter Config found = yes" >> $log
                else
					echo "Rkhunter Config found = no" >> $log
                	cp -v -r -f $instdir/baseinst/root/etc/rkhunter.conf /etc/ 1>>$log 2>>$log 3>>$log
                fi 
		#MOTD installieren
        (
        echo "75" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Updating MOTD" 8 80
			apt-get -q -y --force-yes install update-motd 1>>$log 2>>$log 3>>$log
				#MOD Text anpassen
                if [ -d /etc/update-motd.d ]
                then
					echo "Override MOTD Config" >> $log
                else
					mkdir /etc/update-motd.d  1>>$log 2>>$log 3>>$log
                fi
			cp -v $instdir/baseinst/root/etc/update-motd.d/* /etc/update-motd.d/ 1>>$log 2>>$log 3>>$log
			cp -v $instdir/baseinst/root/etc/motd.txt /etc/ 1>>$log 2>>$log 3>>$log
			
			apt-get -q -y --force-yes install landscape-common  1>>$log 2>>$log 3>>$log
			rm /etc/update-motd.d/50-landscape-sysinfo
			
		#aliases zum System hinzufügen
		(
        echo "80" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Configuring Aliases" 8 80
			local aliasok=`grep sysmaster /root/.bashrc`
			if [ "$aliasok" == "" ]
			then
				cat $instdir/baseinst/root/root/bashrcaliases >> /root/.bashrc
				source /root/.bashrc
			fi	
			cp -v -R $instdir/baseinst/root/etc/timezone /etc/timezone 1>>$log 2>>$log 3>>$log
		#Location und Tastaturlayout setzen
        (
        echo "85" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Set Location and Key map" 8 80
            locale-gen de_DE.UTF-8 1>>$log 2>>$log 3>>$log
			update-locale LANG=de_DE.UTF-8 1>>$log 2>>$log 3>>$log
			dpkg-reconfigure -f noninteractive console-setup 1>>$log 2>>$log 3>>$log
		#Sysinfo
        (
        echo "87" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Gathering System Information" 8 80
			local sysinfo=${instdir}/baseinst/basissysinfo.log			
			rm -v $sysinfo 1>>$log 2>>$log 3>>$log
			touch $sysinfo
			
			#Release
			echo "Release:"	>> $sysinfo
			lsb_release -a 2>/dev/null | egrep "Description|Codename" 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
			echo "" >> $sysinfo

			#Kernel
			echo "Kernel:" >> $sysinfo
			uname -rm 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
			echo "" >> $sysinfo
		
			#System
			echo "System Data:" >> $sysinfo
			who -b  | sed 's/         //' 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
			uptime  | sed 's/ //' 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo	
			echo "" >> $sysinfo
			
			#CPU
			echo "CPU Cores:" >> $sysinfo
			cat /proc/cpuinfo | grep "model name" | awk '{print $4,$5,$6,$7,$8,$9,$10}' 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
			echo "" >> $sysinfo
			
			#Ram
			echo "Ram:" >> $sysinfo
			echo "MB-Slot   Modul"  >> $sysinfo
			lshw -short | grep DIMM | awk '{print $1,$3,$4,$5,$6,$7,$8}' | grep -v EMAIL 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
			#lshw -short | grep "System memory" | awk '{print $3,$4,$5,$6,$7,$8}' 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
			echo "" >> $sysinfo
			
			#Disk
			echo "Partitioning:" >> $sysinfo
			df -h | egrep "/dev/|system" 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
			echo "" >> $sysinfo
			
			#Internal Network
			echo "Internal Network:" >> $sysinfo
			ifconfig | grep -E "encap|eth|br|address|net|gate" | egrep -v "#|loopback|inet6"  1>>$sysinfo 2>>$sysinfo 3>>$sysinfo	
			echo "" >> $sysinfo	
		
		#Gen Icinga template
        (
        echo "90" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Ganerating Icinga Template" 8 80
			local temptemplate=${instdir}/baseinst/Icongatemplate.txt
			rm -v $temptemplate  1>>$log 2>>$log 3>>$log
			touch $temptemplate
			sed "s/FqDn/"${hostfqdn}"/g" $ICINGATemplate >> $temptemplate
			sed -i "s/ipipipip/"${myip}"/g" $temptemplate
			# ipipipip
		#Users
        (
        echo "95" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Adding Users" 8 80
			
			sshconfig="/etc/ssh/sshd_config"
			au="$(grep "AllowUsers" ${sshconfig})"
			
			#add root to mail
			pass="$(pwgen -c -n -B -s 16 1)"			
			echo "root@${hostfqdn};${pass}" >> ${PW_RS}			
			echo "" >> ${PW_RS}	

			#Send mail
			mutt -s "Basisinstallation und Neue Kennwoerter fuer ${hostfqdn}" $defaultmail -a ${temptemplate} -a ${sysinfo} < ${PW_RS}
	
			sleep 2
			dialog --colors --backtitle "System Master Script" --yesno "\Z1Warning\Zn \nPassword for root will be changed to ${pass}\nDid you receive a mail from $hostfqdn?" 7 100
			case $? in
				0)
					echo root:${pass} | chpasswd 1>>$log 2>>$log 3>>$log
				;;
				1)
					checkmail $*
					if [ $? -eq 1 ]
					then
						echo "Mail not received! ...but the mail appears to have been sent?" 1>>$log 2>>$log 3>>$log
					else
						echo "Mail cound not been sent!" 1>>$log 2>>$log 3>>$log
					fi
					dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nroot password has not been changed!\nSorry but this is to risky. Please do it manually" 7 100
				;;
			esac
		#done
		(
        echo "100" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Done!" 8 80		
	dialog --colors --backtitle "System Master Script" --msgbox "\Z1Warning\Zn \nDon´t forget to reboot your system and to use the \"clean logs\" Funktion " 7 60
	sleep 6
		
	return 1
}






