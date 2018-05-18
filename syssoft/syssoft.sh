#!/bin/bash
############################
#Sysmaster				   #
############################

#Basisinstallation
#Installiert wichtige Progremme:

syswebserver()
{
    local log=${instdir}/syssoft/syswebserver.log                          #Default Logfile
	local ftpinfo=${instdir}/syssoft/ftpinfo.log
	local checklog=${instdir}/syssoft/checkwebserver.log                         
	rm -v $checklog  1>>$log 2>>$log 3>>$log
	rm -v $ftpinfo  1>>$log 2>>$log 3>>$log
	touch $checklog
	touch $ftpinfo
	touch $log
	startlog $log

	#Web Server
	#Update
        (
        echo "5" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Updateing Packagelist" 8 80
		 apt-get -q -y --force-yes update 1>>$log 2>>$log 3>>$log
	#Apache2
        (
        echo "10" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing Apache2" 8 80		
		apt-get -q -y --force-yes install apache2 1>>$log 2>>$log 3>>$log
	#php7.0
        (
        echo "15" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing php7.0" 8 80	
		apt-get -q -y --force-yes install php7.0 1>>$log 2>>$log 3>>$log
	#Mod enable
        (
        echo "20" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Enabeling mods" 8 80			
		a2enmod rewrite 1>>$log 2>>$log 3>>$log
		a2enmod ssl 1>>$log 2>>$log 3>>$log
	#WWW Content
        (
        echo "30" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Process Site Config" 8 80			
		cp -v -f -r $instdir/syssoft/webserver/000-default.conf /etc/apache2/sites-enabled/000-default.conf 1>>$log 2>>$log 3>>$log
	#WWW Content
        (
        echo "35" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Adding WWW Default Content" 8 80			
		mkdir /var/www/sites 1>>$log 2>>$log 3>>$log
		cp -v -f -r $instdir/syssoft/webserver/html/* /var/www/sites/ 1>>$log 2>>$log 3>>$log
		rm -rv /var/www/html  1>>$log 2>>$log 3>>$log
	#MySql Server
	#MySql root password
        (
        echo "40" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Generating mysql root Password" 8 80		
		local mysqlpass="$(pwgen -c -n -B -s 16 1)"		
	#Install MySql
        (
        echo "45" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing Mysql" 8 80			
			if [ "$(which mysql)" == "" ] 
			then
				local secureinstall="ok"
			fi	
			debconf-set-selections <<< 'templates/mysql_debconf', password=hSucaSvUjk
			debconf-set-selections <<< 'templates/mysql_debconf_again', password=hSucaSvUjk
			debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password hSucaSvUjk'			
			debconf-set-selections <<< 'mysql-server mysql-server/root_password password hSucaSvUjk'
			debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password hSucaSvUjk'
			apt-get -q -y --force-yes install mysql-server 1>>$log 2>>$log 3>>$log
	#MySql secure install
        (
        echo "50" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Performing Mysql secure installation" 8 80		
			echo $secureinstall
			if [ "$secureinstall" == "ok" ] 
			then
				${instdir}/syssoft/mysqlserver/mysql_secure_installation.sh hSucaSvUjk
			fi		
	#MySql root password
        (
        echo "55" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Set Mysql root password" 8 80			
		mysqladmin --user=root --password=hSucaSvUjk password $mysqlpass
	#zert
        (
        echo "60" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing Vsftpd" 8 80		
		
		local zertinfook=nok
		until [ "$zertinfook" == "ok" ]
		do			
			if [ -f  $pubfile ] || [ -f  $privfile ] || [ -f  $cafile ] || [ -f  $caprivfile ] || [ -f  $csrfile ]
			then
				local zertinfo=`openssl x509 -noout -issuer -dates -in $pubfile`
				dialog --colors --backtitle "System Master Script" --title "Firewall" --yesno "\Z1Info\Zn \nCertificat found. Data Ok? \n $zertinfo"  10 80
				case $? in
				0)
					zertinfook=ok
				;;
				1)
					zertinfook=nok
					strongzert
				;;
			esac	
			else
				dialog --colors --backtitle "System Master Script" --title "Firewall" --msgbox "\Z1Info\Zn \nCertificat not found\nStarting generation"  8 80
				strongzert
			fi
		done	
	#Zerz info nach Webserver
        (
        echo "55" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Writing Zert info to Apache Webserver" 8 80			
		
		local zertservername=`openssl x509 -noout -issuer -dates -in /etc/myssl/public.pem | head -n 1 |awk '{print $18}' | sed "s/\,//"`		
		
		cp -v -f -r $pubfile ${pubfile}.backup 1>>$log 2>>$log 3>>$log
		rm -rv $pubfile 1>>$log 2>>$log 3>>$log
		sed "s/www.example.com/${zertservername}/" ${pubfile}.backup > $pubfile			
	#vsftpd
        (
        echo "65" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing Vsftpd" 8 80		
		apt-get -q -y --force-yes install vsftpd 1>>$log 2>>$log 3>>$log
	#Adding FTP User
        (
        echo "70" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Adding FTP User" 8 80			
		local ftpload=`grep "ftpload" /etc/passwd | cut -d: -f1`
		local ftppass="$( pwgen -c -n -B -s 12 1)"
	
		if [ -z ${ftpload} ]
		then		
			useradd -d /home/ftpload -s /bin/false -m -k /etc/skel ftpload 1>>$log 2>>$log 3>>$log
			echo "/bin/false" >> /etc/shells
			echo "ftpload:${ftppass}" | chpasswd
		else
			echo "ftpload:${ftppass}" | chpasswd
			echo "ftpload already exists!" >> $log			
		fi;
		
		usermod --home /var/www/ ftpload 1>>$log 2>>$log 3>>$log
		chown -R ftpload:ftpload /var/www 1>>$log 2>>$log 3>>$log
		chown root:ftpload /var/www 1>>$log 2>>$log 3>>$log
		chmod 755 /var/www/ 1>>$log 2>>$log 3>>$log
		chmod 775 /var/www/html/  1>>$log 2>>$log 3>>$log
		adduser www-data ftpload  1>>$log 2>>$log 3>>$log
		adduser ftpload www-data  1>>$log 2>>$log 3>>$log
	#VSFtpd config
        (
        echo "75" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Chroot FTP User" 8 80		
		local vschroot=`egrep "TSconfig" /etc/vsftpd.conf`
		if [ "$vschroot" == "" ]
		then	
			echo "" >> /etc/vsftpd.conf
			echo "#TSconfig" >> /etc/vsftpd.conf
			echo "write_enable=YES" >> /etc/vsftpd.conf
			echo "local_umask=002" >> /etc/vsftpd.conf
			echo "chroot_local_user=YES" >> /etc/vsftpd.conf
			#echo allow_writeable_chroot=YES >> /etc/vsftpd.conf
		fi
	#vsftpd restart
        (
        echo "80" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Vsftpd restart" 8 80		
			service vsftpd restart 1>>$log 2>>$log 3>>$log
	#open ssh server
        (
        echo "82" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Vsftpd restart" 8 80		
			apt-get -q -y --force-yes install ssh openssh-server 1>>$log 2>>$log 3>>$log
	#SSH config
        (
        echo "87" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Chroot SFTP User" 8 80	
		local sshconftag=`egrep "TSconfig" /etc/ssh/sshd_config.conf`
		if [ "$sshconftag" == "" ]
		then
			#Backup sshconfig
			cp -v /etc/ssh/sshd_config /etc/ssh/sshd_config.old 1>>$log 2>>$log 3>>$log
			
			#chroot sftpload
			echo "" >>/etc/ssh/sshd_config
			echo "#config" >>/etc/ssh/sshd_config
			echo "#Subsystem sftp internal-sftp" >>/etc/ssh/sshd_config
			echo "Match User ftpload" >>/etc/ssh/sshd_config
			echo "ChrootDirectory /var/www/" >>/etc/ssh/sshd_config
			echo "#ForceCommand internal-sftp" >>/etc/ssh/sshd_config
			echo "###" >>/etc/ssh/sshd_config
			/etc/init.d/ssh restart
			
			#Subsystem
			sed '/Subsystem sftp \/usr\/lib\/openssh\/sftp-server/d' /etc/ssh/sshd_config > /etc/ssh/sshd_config.tmp1
			cat /etc/ssh/sshd_config.tmp1 > /etc/ssh/sshd_config 
			rm -v /etc/ssh/*.tmp* 1>>$log 2>>$log 3>>$log
			
			service ssh restart 1>>$log 2>>$log 3>>$log

		fi	
	#firewall
        (
        echo "90" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Configuring Firewall" 8 80		
		
		local httpinok=`grep tcp_in= /etc/firewall | grep 80`
		local httpsinok=`grep tcp_in= /etc/firewall | grep 80`
		local ftpinaok=`grep tcp_in= /etc/firewall | grep 20`
		local ftpinbok=`grep tcp_in= /etc/firewall | grep 21`
		
		#HTTP freischalten
		if [ "$httpinok" == "" ]
		then
			local firstport=`grep tcp_in= /etc/firewall`
			if [ "$firstport" == "tcp_in=\"\"" ]
			then
				local httpin=`grep tcp_in= /etc/firewall | sed "s/\"/\"80/"`			#Ausführen falls dies der erste port ist (komma werlassen)
			else
				local httpin=`grep tcp_in= /etc/firewall | sed "s/\"/\"80,/"`			#Ausführen falls es schon andere Port gibt (komma hinzufügen)
			fi
			sed '/^tcp_in=/d' /etc/firewall > ${tempvz}/firewall.tmp1
			sed -e "/^# variables$/a ${httpin}" ${tempvz}/firewall.tmp1 > ${tempvz}/firewall.tmp2
			cp -v ${tempvz}/firewall.tmp2 /etc/firewall 1>>$log 2>>$log 3>>$log
			rm ${tempvz}/*.tmp*
			echo "Port 80 open"  1>>$log 2>>$log 3>>$log
		else
			echo "Port 80 already open"  1>>$log 2>>$log 3>>$log
		fi
		
		#HTTPS freischalten
		if [ "$httpinok" == "" ]
		then
			local firstport=`grep tcp_in= /etc/firewall`
			if [ "$firstport" == "tcp_in=\"\"" ]
			then
				local httpin=`grep tcp_in= /etc/firewall | sed "s/\"/\"443/"`			#Ausführen falls dies der erste port ist (komma werlassen)
			else
				local httpin=`grep tcp_in= /etc/firewall | sed "s/\"/\"443,/"`			#Ausführen falls es schon andere Port gibt (komma hinzufügen)
			fi
			sed '/^tcp_in=/d' /etc/firewall > ${tempvz}/firewall.tmp1
			sed -e "/^# variables$/a ${httpin}" ${tempvz}/firewall.tmp1 > ${tempvz}/firewall.tmp2
			cp -v ${tempvz}/firewall.tmp2 /etc/firewall 1>>$log 2>>$log 3>>$log
			rm ${tempvz}/*.tmp*
			echo "Port 443 open"  1>>$log 2>>$log 3>>$log
		else
			echo "Port 443 already open"  1>>$log 2>>$log 3>>$log
		fi
		
		#FTPA freischalten
		if [ "$ftpinaok" == "" ]
		then
			local ftpina=`grep tcp_in= /etc/firewall | sed "s/\"/\"20,/"`
			sed '/^tcp_in=/d' /etc/firewall > ${tempvz}/firewall.tmp1
			sed -e "/^# variables$/a ${ftpina}" ${tempvz}/firewall.tmp1 > ${tempvz}/firewall.tmp2
			cp -v ${tempvz}/firewall.tmp2 /etc/firewall 1>>$log 2>>$log 3>>$log
			rm ${tempvz}/*.tmp*	
			echo "Port 20 open"  1>>$log 2>>$log 3>>$log
		else
			echo "Port 20 already open"  1>>$log 2>>$log 3>>$log
		fi
		
		#FTPB freischalten
		if [ "$ftpinbok" == "" ]
		then
			local ftpinb=`grep tcp_in= /etc/firewall | sed "s/\"/\"21,/"`
			sed '/^tcp_in=/d' /etc/firewall > ${tempvz}/firewall.tmp1
			sed -e "/^# variables$/a ${ftpinb}" ${tempvz}/firewall.tmp1 > ${tempvz}/firewall.tmp2
			cp -v ${tempvz}/firewall.tmp2 /etc/firewall 1>>$log 2>>$log 3>>$log
			rm ${tempvz}/*.tmp*	
			echo "Port 21 open"  1>>$log 2>>$log 3>>$log
		else
			echo "Port 21 already open"  1>>$log 2>>$log 3>>$log
		fi
	
		#TCPIN freischalten
		local allowin=`egrep "iptables -A INPUT -p tcp --sport 1024: -m multiport --destination-ports" /etc/firewall | egrep "syn" | sed "s/#//"`
		local allowinkomment=`egrep "iptables -A INPUT -p tcp --sport 1024: -m multiport --destination-ports" /etc/firewall  | sed "s/iptables/ /" | awk '{print $1}'`
		if [ "$allowinkomment" == "#" ]
		then
			sed '/^#iptables -A INPUT -p tcp --sport 1024: -m multiport --destination-ports/d' /etc/firewall > ${tempvz}/firewall.tmp1
			sed -e "/^# INCOMING SYN packets for protocol TCP$/a ${allowin}" ${tempvz}/firewall.tmp1 > ${tempvz}/firewall.tmp2
			cp -v ${tempvz}/firewall.tmp2 /etc/firewall 1>>$log 2>>$log 3>>$log
			rm ${tempvz}/*.tmp*	
			echo "Incomming TCP allowed"  1>>$log 2>>$log 3>>$log
		else
			echo "Incomming TCP already allowed"  1>>$log 2>>$log 3>>$log
		fi
		
		#Firewall Regeln anwenden
		/etc/firewall   1>>$log 2>>$log 3>>$log
		
	#done
		(
        echo "100" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Done!" 8 80		
	
	#Email
	echo "Home Directory" >> ${ftpinfo}
	echo "/var/www/sites" >> ${ftpinfo}
	echo "" >> ${ftpinfo}
	echo "IP:" >> ${ftpinfo}
	echo $myip >> ${ftpinfo}
	echo "" >> ${ftpinfo}
	echo "FTP User for $hostn " >> ${ftpinfo}
	echo "ftpload@${hostn}:$ftppass" >> ${ftpinfo}
	echo "" >> ${ftpinfo}
	echo "Mysql User for $hostn " >> ${ftpinfo}
	echo "mysql/root@${hostn}:$mysqlpass" >> ${ftpinfo}
	echo "" >> ${ftpinfo}
	mail -s "Web Server on ${hostn} installed" $defaultmail < ${ftpinfo}
		
	#Webserver status	
	echo "Dienste:" >> ${checklog}
	
	local apacheport=`netstat -tulpen | egrep "apache" | awk '{print $5,$4}' | sed 's/ / --> /g'`
	local apacherun=`netstat -tulpen | egrep "apache"`
	if [ "$apacherun" == "" ]
	then
		echo "Apache is not running" >> ${checklog}
	else
		echo "Apache is running" >> ${checklog}
	fi
	echo $apacheport  >> ${checklog}
	echo ""	 >> ${checklog}
	
	local mysqlport=`netstat -tulpen | egrep "mysql" | awk '{print $5,$4}' | sed 's/ / --> /g'`
	local mysqlrun=`netstat -tulpen | egrep "mysql"`
	if [ "$mysqlrun" == "" ]
	then
		echo "Mysql is not running" >> ${checklog}
	else
		echo "Mysql is running" >> ${checklog}
	fi
	echo $mysqlport  >> ${checklog}
	echo "" >> ${checklog}
	
	local ftpport=`netstat -tulpen | egrep "vsftpd" | awk '{print $5,$4}' | sed 's/ / --> /g'`
	local ftprun=`netstat -tulpen | egrep "vsftpd"`
	if [ "$ftprun" == "" ]
	then
		echo "Vsftpd is not running" >> ${checklog}
	else
		echo "Vsftpd is running" >> ${checklog}
	fi
	echo $ftpport  >> ${checklog}
	echo "" >> ${checklog}
	
	echo ${readinstaldir}
	cat ${readinstaldir}syssoft/mysqlserver/mysqlsecuresql.log  >> ${checklog}
	dialog --colors --backtitle "System Master Script" --title "Webserver status" --exit-label "OK" --textbox $checklog 0 0
	
	systemctl restart apache2
	
	return 1
}

sysicinga()
{
    local log=${instdir}/syssoft/sysiconga.log                          #Default Logfile
	touch $log
	startlog $log		
		#Update
        (
        echo "20" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Updateing Packagelist" 8 80
			apt-get -q -y --force-yes update 1>>$log 2>>$log 3>>$log
		#plugins installieren
        (
        echo "40" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing nagios-plugins" 8 80
			apt-get -q -y --force-yes install nagios-plugins 1>>$log 2>>$log 3>>$log
			cp -v -r -f $instdir/syssoft/icinga/usr/lib/nagios/plugins/* /usr/lib/nagios/plugins/ 1>>$log 2>>$log 3>>$log
			chmod 775 /usr/lib/nagios/plugins/check_*
		#plugins installieren
        (
        echo "50" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing nagios-plugins" 8 80
			apt-get -q -y --force-yes install sudo  1>>$log 2>>$log 3>>$log
			echo ""  >> /etc/sudoers
			echo "nagios  ALL=(ALL) NOPASSWD: CHECK_RAID" >> /etc/sudoers
			echo ""  >> /etc/sudoers
		#nrpe installieren
        (
        echo "60" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing nagios-nrpe-server " 8 80
			apt-get -y -q --force-yes install nagios-nrpe-server 1>>$log 2>>$log 3>>$log
		#gnupg installieren
        (
        echo "80" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing NRPE Config" 8 80
			local nrpeloc=`echo /etc/nagios/nrpe_local.cfg | xargs wc -l | tail -n 1 | awk '{print $1}'`
			if [ "$nrpeloc" == "3" ]
			then
				echo "NRPE Config found = no  --> override" >> $log
				cp -v -f -r $instdir/syssoft/icinga/nagios/nrpe_local.cfg /etc/nagios/nrpe_local.cfg 1>>$log 2>>$log 3>>$log
			else
				echo "NRPE Config found = yes --> nothing to do" >> $log
			fi
		#nagios restart
        (
        echo "60" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Restarting nagios-nrpe-server " 8 80
			 /etc/init.d/nagios-nrpe-server restart 1>>$log 2>>$log 3>>$log	
		#done
		(
        echo "100" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Done!" 8 80		
	return 1
}

sysfirewall()
{
	local log=${instdir}/syssoft/sysfirewall.log                          #Default Logfile
	touch $log
	startlog $log
	
    dialog --colors --backtitle "System Master Script" --title "Firewall" --yesno "\Z1Warning\Zn \nSSH session could be disconnecter after Firewall is enabled\nOK?"  7 85
    case $? in
         1)
			return 0
         ;;
    esac	

	# cron stoppen, sonst wird Firewall geladen und ssh getrennt	
	if [ -e /etc/init.d/cron ]
	then
		/etc/init.d/cron stop
	else
		echo "Application cron not installed."  1>>$log 2>>$log 3>>$log
	fi;

	cp -v ${instdir}/syssoft/firewall/firewall /etc/firewall 1>>$log 2>>$log 3>>$log
	cp -v ${instdir}/syssoft/firewall/firewall.open /etc/firewall.open 1>>$log 2>>$log 3>>$log
	cp -v ${instdir}/syssoft/firewall/init-firewall /etc/init.d/firewall 1>>$log 2>>$log 3>>$log
	ln -s /etc/init.d/firewall /etc/rc2.d/S99firewall 1>>$log 2>>$log 3>>$log
	ln -s /etc/init.d/firewall /etc/rc3.d/S99firewall 1>>$log 2>>$log 3>>$log
	ln -s /etc/init.d/firewall /etc/rc5.d/S99firewall 1>>$log 2>>$log 3>>$log
	chmod 775 /etc/firewall 1>>$log 2>>$log 3>>$log
	chmod 775 /etc/firewall.open 1>>$log 2>>$log 3>>$log
	chmod 775 /etc/init.d/firewall 1>>$log 2>>$log 3>>$log
	
	#Fix für Allow all bug
	cp -v ${instdir}/syssoft/firewall/check-iptables.sh /etc/cron.daily/check-iptables.sh 1>>$log 2>>$log 3>>$log
	
	#Firewall neu starten
	/etc/init.d/firewall start
	
	# cron wieder starten
	/etc/init.d/cron start
	
	return 1
}




