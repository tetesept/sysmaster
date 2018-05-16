#!/bin/bash
############################
#Sysmaster				   #
############################

#Basisinstallation
#Installiert wichtige Progremme:


sysmailservers()
{
	local log=${instdir}/syssoft/sysmailserver.log                          #Default Logfile
	touch $log
	startlog $log		
	
	#MTA POP IMAP
	local mtaok=no
	until [ "$mtaok" == "ok" ]
	do
		mtatype=`dialog --colors --backtitle "System Master Script" --title "Install Mail Server" --checklist "Chose Sevrer Type:" 0 0 3 \
		MTA "MTA POP IMAP" on\
		FILTER "Spam/Vierenfilter" off 3>&1 1>&2 2>&3`
		if [ "$?" == "1"  ] 
		then
			return 0
		fi
		if [ "$mtatype" == ""  ]
		then
			dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nWrong input. Select al least one option" 6 100
		fi
		
		for current in $mtatype
		do
			case $current in
				"MTA")
					sysmailmta
				;;
				"FILTER")
					sysmailfilter
				;;
			esac
		done
		mtaok="ok"
	done
	return 1

}

sysmailmta()
{
    local log=${instdir}/syssoft/mailserver.log                          #Default Logfile	
	local wwwinfo=${instdir}/syssoft/wwwinfo.log
	local wwwstatus=${instdir}/syssoft/wwwstatus.log
	rm -v $wwwinfo 1>>$log 2>>$log 3>>$log
	rm -v  $wwwstatus 1>>$log 2>>$log 3>>$log
	touch $wwwinfo
		
		#Update
        (
        echo "10" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Updateing Packagelist" 8 80
			apt-get -q -y --force-yes update 1>>$log 2>>$log 3>>$log
		#postfix installieren
        (
        echo "20" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing postfix" 8 80
			apt-get -q -y --force-yes install postfix 1>>$log 2>>$log 3>>$log		
		#IMAP installieren
        (
        echo "30" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing courier-imap" 8 80
			apt-get -q -y --force-yes install courier-imap 1>>$log 2>>$log 3>>$log	
		#IMAPs installieren
        (
        echo "35" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing courier-imap" 8 80
			apt-get -q -y --force-yes install courier-imap-ssl
		#POP installieren
        (
        echo "40" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing courier-pop" 8 80
			apt-get -q -y --force-yes install courier-pop 1>>$log 2>>$log 3>>$log
		#POP installieren
        (
        echo "45" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing courier-pop" 8 80
			apt-get -q -y --force-yes install courier-pop-ssl
		#SASL installieren
        (
        echo "50" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing sasl2-bin" 8 80
			apt-get -q -y --force-yes install sasl2-bin 1>>$log 2>>$log 3>>$log		
			mkdir -v /etc/postfix/sasl  1>>$log 2>>$log 3>>$log
			cp -v -r ${instdir}/syssoft/mailserver/postfix/smtpd.conf /etc/postfix/sasl/ 1>>$log 2>>$log 3>>$log
			chown postfix:postfix /var/spool/postfix/etc/sasldb2
		#postfix-pcre installieren
        (
        echo "60" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing postfix-pcre " 8 80
			apt-get -y -q --force-yes install postfix-pcre 1>>$log 2>>$log 3>>$log
		#mailutils installieren
        (
        echo "70" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing mailutils " 8 80
			apt-get -y -q --force-yes install mailutils 1>>$log 2>>$log 3>>$log		
		#TLS installieren
        (
        echo "75" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "make-ssl-cert " 8 80	
			if [ -f  $pubfile ] || [ -f  $privfile ] || [ -f  $cafile ] || [ -f  $caprivfile ] || [ -f  $csrfile ]
			then
				zertinfo=`openssl x509 -noout -issuer -dates -in $pubfile`
				dialog --colors --backtitle "System Master Script" --title "Firewall" --msgbox "\Z1Info\Zn \nCertificat found \n $zertinfo"  8 80
			else
				dialog --colors --backtitle "System Master Script" --title "Firewall" --msgbox "\Z1Info\Zn \nCertificat not found\nStarting generation"  8 80
				strongzert
			fi
		#postfix einrichten
        (
        echo "80" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Configuring postfix" 8 80
		
			local domainname_only=`echo $hostn |  sed 's/\./ /' | awk '{print $2,$3,$4,$5}'`
					
			cp -v -r ${instdir}/syssoft/mailserver/postfix/body_checks_pcre /etc/postfix/ 1>>$log 2>>$log 3>>$log
			cp -v -r ${instdir}/syssoft/mailserver/postfix/header_checks_pcre /etc/postfix/ 1>>$log 2>>$log 3>>$log
			cp -v -r ${instdir}/syssoft/mailserver/postfix/main.cf /etc/postfix/ 1>>$log 2>>$log 3>>$log
		
			sed '/^myhostname =/d' /etc/postfix/main.cf > ${tempvz}/mailserver1.tmp1
			sed '/^mynetworks =/d' ${tempvz}/mailserver1.tmp1 > ${tempvz}/mailserver1.tmp2
			sed '/^mydestination =/d' ${tempvz}/mailserver1.tmp2 > ${tempvz}/mailserver1.tmp3
			cp -v ${tempvz}/mailserver1.tmp3 /etc/postfix/main.cf 1>>$log 2>>$log 3>>$log
			rm ${tempvz}/*.tmp*	
			
			sed -e "/^##### Localhost$/a myhostname = ${hostn}" /etc/postfix/main.cf > ${tempvz}/mailserver1.tmp1
			sed -e "/^##### Localhost$/a mynetworks = localhost, $hostn" ${tempvz}/mailserver1.tmp1 > ${tempvz}/mailserver1.tmp2
			sed -e "/^##### Localhost$/a mydestination = ${hostn}" ${tempvz}/mailserver1.tmp2 > ${tempvz}/mailserver1.tmp3
			cp -v ${tempvz}/mailserver1.tmp3 /etc/postfix/main.cf 1>>$log 2>>$log 3>>$log
			rm ${tempvz}/*.tmp*	
			
			touch /etc/postfix/virtual
			touch /etc/postfix/transport
			touch /etc/postfix/relaydomains
			
			postmap /etc/postfix/virtual 1>>$log 2>>$log 3>>$log		 	
			postmap /etc/postfix/transport 1>>$log 2>>$log 3>>$log		 	
			postmap /etc/postfix/relaydomains 1>>$log 2>>$log 3>>$log			
					
			#Relay für eigene Domain
			local domok=`grep $domainname_only /etc/postfix/relaydomains`
			if [ "$domok" == "" ]
			then				
				echo "$domainname_only 		RELAY" >> /etc/postfix/relaydomains
				postmap /etc/postfix/relaydomains 1>>$log 2>>$log 3>>$log
				echo "Relay for own Domain set" >>$log
			else
				echo "Relay for own Domain already set" >>$log
			fi
			
			#Mailname anpassen
			echo "$domainname_only" > /etc/mailname
			echo "" >> /etc/mailname
		
			#Dienste starten
			authdaemond start	
			/etc/init.d/portfix restart 1>>$log 2>>$log 3>>$log	
			chown postfix:postfix /var/spool/postfix/etc/sasldb2
		
		#firewall einrichten
        (
        echo "90" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Configuring firewall" 8 80

			#SMTP 25
			local smtpok=`grep tcp_in= /etc/firewall | grep 25`		
			if [ "$smtpok" == "" ]
			then
				local firstport=`grep tcp_in= /etc/firewall`
				if [ "$firstport" == "tcp_in=\"\"" ]
				then
					local smtpin=`grep tcp_in= /etc/firewall | sed "s/\"/\"25/"`
				else
					local smtpin=`grep tcp_in= /etc/firewall | sed "s/\"/\"25,/"`
				fi
				sed '/^tcp_in=/d' /etc/firewall > ${tempvz}/firewall.tmp1
				sed -e "/^# variables$/a ${smtpin}" ${tempvz}/firewall.tmp1 > ${tempvz}/firewall.tmp2
				cp -v ${tempvz}/firewall.tmp2 /etc/firewall 1>>$log 2>>$log 3>>$log	
				rm ${tempvz}/*.tmp*
				echo "Port 25 open"  1>>$log 2>>$log 3>>$log
			else
				echo "Port 25 already open"  1>>$log 2>>$log 3>>$log
			fi
			
			#POP3 110
			local smtpok=`grep tcp_in= /etc/firewall | grep 110`		
			if [ "$smtpok" == "" ]
			then
				local firstport=`grep tcp_in= /etc/firewall`
				if [ "$firstport" == "tcp_in=\"\"" ]
				then
					local smtpin=`grep tcp_in= /etc/firewall | sed "s/\"/\"110/"`
				else
					local smtpin=`grep tcp_in= /etc/firewall | sed "s/\"/\"110,/"`
				fi
				sed '/^tcp_in=/d' /etc/firewall > ${tempvz}/firewall.tmp1
				sed -e "/^# variables$/a ${smtpin}" ${tempvz}/firewall.tmp1 > ${tempvz}/firewall.tmp2
				cp -v ${tempvz}/firewall.tmp2 /etc/firewall 1>>$log 2>>$log 3>>$log	
				rm ${tempvz}/*.tmp*
				echo "Port 110 open"  1>>$log 2>>$log 3>>$log
			else
				echo "Port 110 already open"  1>>$log 2>>$log 3>>$log
			fi
			
			#POP3s 143
			local smtpok=`grep tcp_in= /etc/firewall | grep 143`		
			if [ "$smtpok" == "" ]
			then
				local firstport=`grep tcp_in= /etc/firewall`
				if [ "$firstport" == "tcp_in=\"\"" ]
				then
					local smtpin=`grep tcp_in= /etc/firewall | sed "s/\"/\"143/"`
				else
					local smtpin=`grep tcp_in= /etc/firewall | sed "s/\"/\"143,/"`
				fi
				sed '/^tcp_in=/d' /etc/firewall > ${tempvz}/firewall.tmp1
				sed -e "/^# variables$/a ${smtpin}" ${tempvz}/firewall.tmp1 > ${tempvz}/firewall.tmp2
				cp -v ${tempvz}/firewall.tmp2 /etc/firewall 1>>$log 2>>$log 3>>$log	
				rm ${tempvz}/*.tmp*
				echo "Port 143 open"  1>>$log 2>>$log 3>>$log
			else
				echo "Port 143 already open"  1>>$log 2>>$log 3>>$log
			fi
			
			#IMAPS 993
			local smtpok=`grep tcp_in= /etc/firewall | grep 993`		
			if [ "$smtpok" == "" ]
			then
				local firstport=`grep tcp_in= /etc/firewall`
				if [ "$firstport" == "tcp_in=\"\"" ]
				then
					local smtpin=`grep tcp_in= /etc/firewall | sed "s/\"/\"993/"`
				else
					local smtpin=`grep tcp_in= /etc/firewall | sed "s/\"/\"993,/"`
				fi
				sed '/^tcp_in=/d' /etc/firewall > ${tempvz}/firewall.tmp1
				sed -e "/^# variables$/a ${smtpin}" ${tempvz}/firewall.tmp1 > ${tempvz}/firewall.tmp2
				cp -v ${tempvz}/firewall.tmp2 /etc/firewall 1>>$log 2>>$log 3>>$log	
				rm ${tempvz}/*.tmp*
				echo "Port 993 open"  1>>$log 2>>$log 3>>$log
			else
				echo "Port 993 already open"  1>>$log 2>>$log 3>>$log
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
		/etc/firewall 1>>$log 2>>$log 3>>$log		
		#postfix restart
        (
        echo "98" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing mailutils " 8 80
			/etc/init.d/postfix restart 1>>$log 2>>$log 3>>$log		
		#done
		(
        echo "100" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Done!" 8 80		
		
		
	#Mail senden
	echo "Mais Server testen:" > ${wwwinfo}
	echo "http://mxtoolbox.com/SuperTool.aspx?action=smtp%3a${myip}&run=toolpage" >> ${wwwinfo}
	echo "" >> ${wwwinfo}	
	echo "IP:" >> ${wwwinfo}
	ifconfig | grep -E "encap|eth|br|address|net|gate" | egrep -v "#|loopback|inet6|Link encap" | awk '{print $2}' | sed s/"addr:"/""/g | sed s/"Adresse:"/""/g | egrep -v "127.0" >> ${wwwinfo}
	echo "" >> ${wwwinfo}
	mail -s "Mail Server on ${hostn} installed" $defaultmail < ${wwwinfo}
		
		
	#amavis
	echo "Dienste" >> ${wwwstatus}	
	amavisrun=`netstat -tulpen | egrep "amavis"`
	amavisport=`netstat -tulpen | egrep "amavis"  | awk '{print $5,$4}' | sed 's/ / --> /g'`
	postfixporta=`netstat -tulpen | egrep "master"  | awk '{print $5,$4}' | sed 's/ / --> /g' | head -n1`
	if [ "$amavisrun" == "" ]
	then
		echo "Amavis is not running" >> ${wwwstatus}
	else
		echo "Amavis is running" >> ${wwwstatus}
	fi
	echo $postfixporta >> ${wwwstatus}
	echo $amavisport >> ${wwwstatus}
	echo " " >> ${wwwstatus}
	
	#postfix
	postfixrun=`netstat -tulpen | egrep "master"`
	postfixportb=`netstat -tulpen | egrep "master"  | awk '{print $5,$4}' | sed 's/ / --> /g' | tail -n1`
	if [ "$postfixrun" == "" ]
	then
		echo "Postfix is not running" >> ${wwwstatus}
	else
		echo "Postfix is running" >> ${wwwstatus}	
	fi
	echo $postfixportb >> ${wwwstatus}
	echo "" >> ${wwwstatus}
	
	#pop3
	pop3run=`netstat -tulpen | egrep "couriertcpd"`
	pop3port=`netstat -tulpen | egrep "couriertcpd"  | awk '{print $5,$4}' | sed 's/ / --> /g' | head -n1`
	if [ "$amavisrun" == "" ]
	then
		echo "POP3 is not running" >> ${wwwstatus}
	else
		echo "POP3 is running" >> ${wwwstatus}
	fi
	echo $pop3port >> ${wwwstatus}
	echo " " >> ${wwwstatus}
	
	#imap
	imaprun=`netstat -tulpen | egrep "couriertcpd"`
	imapport=`netstat -tulpen | egrep "couriertcpd"  | awk '{print $5,$4}' | sed 's/ / --> /g' | tail -n1`
	if [ "$amavisrun" == "" ]
	then
		echo "IMAP is not running" >> ${wwwstatus}
	else
		echo "IMAP is running" >> ${wwwstatus}
	fi
	echo $imapport >> ${wwwstatus}
	echo " " >> ${wwwstatus}
	
	dialog --colors --backtitle "System Master Script" --title "Webserver status" --exit-label "OK" --textbox $wwwstatus 0 0
		
	return 1
}

sysmailfilter()
{
    local log=${instdir}/syssoft/mailserver.log                          #Default Logfile
		#Update
        (
        echo "10" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Updateing Packagelist" 8 80
			apt-get -q -y --force-yes update 1>>$log 2>>$log 3>>$log
		#postfix installieren
        (
        echo "20" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing postfix" 8 80
			apt-get -q -y --force-yes install postfix 1>>$log 2>>$log 3>>$log
		#amavis installieren
        (
        echo "30" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing amavis " 8 80
			apt-get -y -q --force-yes install amavis-new 1>>$log 2>>$log 3>>$log
		#spamassassin installieren
        (
        echo "40" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing spamassassin " 8 80
			apt-get -y -q --force-yes install spamassassin 1>>$log 2>>$log 3>>$log
		#razor  installieren
        (
        echo "45" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing razor" 8 80
			apt-get -y -q --force-yes install razor 1>>$log 2>>$log 3>>$log
		#pyzor  installieren
        (
        echo "50" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing pyzor" 8 80
			apt-get -y -q --force-yes install pyzor 1>>$log 2>>$log 3>>$log
		#clanav installieren
        (
        echo "55" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing clanav " 8 80
			apt-get -y -q --force-yes install clamav clamav-daemon clamav-base clamav-freshclam clamav-docs libclamav7 1>>$log 2>>$log 3>>$log
			adduser clamav amavis 1>>$log 2>>$log 3>>$log	
			groups clamav 1>>$log 2>>$log 3>>$log	
			adduser amavis clamav 1>>$log 2>>$log 3>>$log	
			groups amavis 1>>$log 2>>$log 3>>$log	
			freshclam 1>>$log 2>>$log 3>>$log	
			/etc/init.d/clamav-daemon restart  1>>$log 2>>$log 3>>$log			
		#postfix-pcre installieren
        (
        echo "60" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing postfix-pcre " 8 80
			apt-get -y -q --force-yes install postfix-pcre libpcre3 libpcre3-dev 1>>$log 2>>$log 3>>$log
		#mailutils installieren
        (
        echo "65" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Installing mailutils " 8 80
			apt-get -y -q --force-yes install mailutils 1>>$log 2>>$log 3>>$log		
		#postfix einrichten
        (
        echo "70" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Configuring postfix" 8 80		
			cp -v -r ${instdir}/syssoft/mailserver/postfix/master.cf /etc/postfix/ 1>>$log 2>>$log 3>>$log	
			local filterinstalled=`grep "content_filter=smtp-amavis" /etc/postfix/main.cf`
			if [ "$filterinstalled" = ""  ]
			then
				echo "content_filter=smtp-amavis:[127.0.0.1]:10024" >> /etc/postfix/main.cf
				echo "" >> /etc/postfix/main.cf
			fi
			/etc/init.d/portfix restart 1>>$log 2>>$log 3>>$log	
		#amavis einrichten
        (
        echo "80" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Configuring amavis" 8 80
			cp -v ${instdir}/syssoft/mailserver/amavis/15-content_filter_mode  /etc/amavis/conf.d/  1>>$log 2>>$log 3>>$log
			cp -v ${instdir}/syssoft/mailserver/amavis/20-debian_defaults  /etc/amavis/conf.d/  1>>$log 2>>$log 3>>$log
			cp -v ${instdir}/syssoft/mailserver/amavis/whitelist_sender  /etc/amavis/  1>>$log 2>>$log 3>>$log
			/etc/init.d/amavis restart 1>>$log 2>>$log 3>>$log	
		#spamassassin einrichten
        (
        echo "90" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Configuring spamassassin" 8 80
				
				sed -e "/^ENABLED=0$/a ENABLED=1" /etc/default/spamassassin > ${tempvz}/spamassassin.tmp1
				sed '/^ENABLED=0/d' ${tempvz}/spamassassin.tmp1 > ${tempvz}/spamassassin.tmp2
				cp -v ${tempvz}/spamassassin.tmp2 /etc/default/spamassassin 1>>$log 2>>$log 3>>$log	
				rm ${tempvz}/*.tmp*
				/etc/init.d/spamassassin restart  1>>$log 2>>$log 3>>$log
		#done
		(
        echo "100" ; sleep 3
        echo "XXX"
        ) | dialog --colors --backtitle "System Master Script" --title "Progress State" --gauge "Done!" 8 80		
	return 1
}

sysmailbox(){
    local log=${instdir}/syssoft/mailserver.log                          #Default Logfile
	local domainname_only=`hostname -d`

	local hostmailok=no
	until [ "$hostmailok" == "ok" ]
	do
	hostmail=`dialog --colors --backtitle "System Master Script" --title "Add Mail User" --inputbox "Enter E-Mail Adress:" 0 0 "info@$domainname_only" 3>&1 1>&2 2>&3`
            if [ "$?" == "1"  ]
            then
				return 0;
            fi
			case $hostmail in
				*@*.*)
					hostmailok=ok
				;;
                *)
                    dialog --colors --backtitle "System Master Script" --msgbox "\Z1Error\Zn \nWrong input. Define a valid E-Mail Adress like teteseptistder@best.de" 6 100
                ;;
            esac
        done		
		
		local mailhost=`echo $hostmail |  sed 's/@/ /' | awk '{print $1}'`
		local maildom=`echo $hostmail |  sed 's/@/ /' | awk '{print $2}'`
		local pass="$(pwgen -c -n -B -s 8 1)"
		
		#User
		useradd -d /home/$mailhost -p $pass -s /bin/bash -m -k /etc/skel $mailhost   1>>$log 2>>$log 3>>$log
		echo "${mailhost}:${pass}" | chpasswd
		
		#SASL
		chown postfix:postfix /var/spool/postfix/etc/sasldb2
		echo $pass | saslpasswd2 -p -c -f /var/spool/postfix/etc/sasldb2 -u localhost $mailhost
		
		#Maildir
		maildirmake.courier /home/$mailhost/Maildir  1>>$log 2>>$log 3>>$log
		chown -R $mailhost:$mailhost /home/$mailhost/Maildir  1>>$log 2>>$log 3>>$log
		chmod 775 /home/$mailhost/Maildir  1>>$log 2>>$log 3>>$log
		
		#virtual
		#echo "${hostmail}	${mailhost}" >> /etc/postfix/virtual
		#postmap /etc/postfix/virtual
		
		#Account infos an admin
		local testmail=${instdir}/syssoft/testmail
		rm -v $testmail  1>>$log 2>>$log 3>>$log
		touch -v $testmail  1>>$log 2>>$log 3>>$log
		
		echo "E-Mail Adress" >> $testmail
		echo "$hostmail" >> $testmail
		echo "" >> $testmail
		echo "Benutzername" >> $testmail
		echo "$mailhost" >> $testmail
		echo "" >> $testmail
		echo "Passwort" >> $testmail
		echo "$pass" >> $testmail
		echo "" >> $testmail
		echo "Bei der Verwendung von Outlook bitte in den erweiterten Kontoeinstellungen als Stammordner \"Inbox\" angeben" >> $testmail
		
		mail -s "E-Mail Account $hostmail auf $hostn" $defaultmail < $testmail
		
		#Testmail an Kunde
		rm -v $testmail  1>>$log 2>>$log 3>>$log
		touch -v $testmail  1>>$log 2>>$log 3>>$log
		
		echo "${hostn}" >> $testmail
		
		mail -s "Test Mail an $hostmail" $hostmail < $testmail
		
		dialog --colors --backtitle "System Master Script" --infobox "\Z1Info\Zn \nCreating $hostmail ..." 8 100
		sleep 4
		local mailstatus=`grep $hostmail /var/log/mail.log | tail -n1`
		dialog --colors --backtitle "System Master Script" --msgbox "\Z1Info\Zn \n$mailstatus" 8 100

	return 1
}
