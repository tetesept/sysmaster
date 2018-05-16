#!/bin/bash
############################
#Sysmaster				   #
############################

#Systeminformationen

systeminfo()
{
	local log=${instdir}/info/info.log					#Default Logfile
	touch $log
	startlog $log
	
	local sysinfo=${instdir}/info/sysinfo.log			
	rm -v $sysinfo 1>>$log 2>>$log 3>>$log
	touch $sysinfo

		dialog --colors --stdout --backtitle "System Master Script" --title "Sysinfo" --msgbox "\Z1Warning\Zn \nCollectin System data may take some time\n" 6 60 --and-widget --timeout 1 --nook --begin 15 15 --infobox "Fetching data..." 5 30	
		
		if [ "$(which landscape-sysinfo)" == "" ]
		then
            		apt-get -q -y --force-yes install landscape-common 1>>$log 2>>$log 3>>$log
        fi
		if [ "$(which w3m)" == "" ]
		then
            		apt-get -q -y --force-yes install w3m 1>>$log 2>>$log 3>>$log
        	fi
        	
		#Summary
		echo "--------------------------------Summary--------------------------------"	>> $sysinfo
		echo "" >> $sysinfo
		/usr/bin/landscape-sysinfo |  egrep -v "landscape.canonical.com|Graph this data" 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		echo "-----------------------------------------------------------------------"	>> $sysinfo
		echo "" >> $sysinfo
		
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
		
		#Users
		echo "Loged in Users:" >> $sysinfo
		who 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		echo "" >> $sysinfo

		#CPU
		echo "CPU Typ:" >> $sysinfo
		echo "Architekture: `dpkg --print-architecture`" >> $sysinfo
		echo "" >> $sysinfo
		
		echo "CPU Cores:" >> $sysinfo
		cat /proc/cpuinfo | grep "model name" | awk '{print $4,$5,$6,$7,$8,$9,$10}' 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		echo "" >> $sysinfo

		#VT
		echo "VT (Virtualization Technology):" >> $sysinfo
		local hyper=`grep flags /proc/cpuinfo | egrep '(vmx|svm)' /proc/cpuinfo`
		if [ -z "$hyper" ]
		then
			echo "No"  >> $sysinfo
		else
			echo "Yes" >> $sysinfo
		fi		
		echo "" >> $sysinfo
 
        #Ram
        echo "Ram:" >> $sysinfo
        echo "MB-Slot   Modul"  >> $sysinfo
		lshw -short | egrep "DIMM|Systemspeicher|System memory|System Memory" | awk '{print $3,$4,$5,$6,$7,$8}' |  egrep -v "EMAIL|DIMM DRAM "  >> $sysinfo
		echo "" >> $sysinfo

		#Disk
		echo "Disks:" >> $sysinfo
		#lshw -short | grep /0/1/0.0.0/ | sed 's/\/0\/1\/0.0.0\//Part /g' 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		#lshw -short | grep disk | grep -v DVD | awk '{print $2,$3,$4,$5,$6,$7,$8}' 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT  1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		echo "" >> $sysinfo

		#Partitionierung
		echo "Partitioning:" >> $sysinfo
		local disk=`df -P | awk '{print $4}' | head -n 2 | tail -n1` 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		df -h | egrep "/dev/|system" 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		echo "" >> $sysinfo
		
		#LVM
		if [ "$(which lvdisplay)" != "" ]
		then
			if [ "$(vgs)" != "" ]
			then
				echo "LVM Physikal Volumes" 1>>$sysinfo
				pvs | grep -v "Attr PSize" | awk '{print $1,$2,$3,$5}'   1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
				echo "" >> $sysinfo
				echo "LVM Volume Groups:" 1>>$sysinfo
				vgs | grep -v "#PV" | awk '{print $1,$6}' 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
				echo "" >> $sysinfo
				echo "LVM Logical Volumes" 1>>$sysinfo
				lvs | egrep -v "LSize|Copy" | awk '{print $1,$2,$4}' | sed 's/ / auf /'  1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
			else
				echo "LVM:" >> $sysinfo
				echo "LVM in use but no Volume Group found" >> $sysinfo
			fi
		else
			echo "LVM:" >> $sysinfo
			echo "LVM is not in use" >> $sysinfo
		fi
		echo "" >> $sysinfo

		#Raid
		echo "Software-Raid:" >> $sysinfo
		if [ "$(which mdadm)" != "" ]
        	then
        	    cat /proc/mdstat 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		else
			echo "Software-Raid is not in use" >> $sysinfo
		fi
		echo "" >> $sysinfo

		#Grub
		echo "Bootloader:" >> $sysinfo
		if [ -f /boot/grub/grub.cfg  ]
		then
			echo "Grub found:"  >> $sysinfo
			egrep "menuentry"  /boot/grub/grub.cfg | egrep "Windows|Ubuntu|Debian" | egrep -v "Ubuntu,|submenu" |  sed s/"{"/""/g | awk '{print $1,$2,$3,$4,$5,$6,$7,82,$9,$10}'  1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		elif [ -f /boot/grub/menu.lst ]
		then
			echo "Grub found:"  >> $sysinfo
		    egrep "root|title|initrd|kernel"  /boot/grub/menu.lst | egrep "Windows|Ubuntu|Debian" | egrep -v "Ubuntu,|submenu" |  sed s/"{"/""/g | awk '{print $1,$2,$3,$4,$5,$6,$7,82,$9,$10}' 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		else
		    echo "Grub not found!" >> $sysinfo
		fi
		echo "" >> $sysinfo

		#Internal Network
		echo "Internal Network:" >> $sysinfo
		ifconfig | grep -E "encap|eth|br|address|net|gate" | egrep -v "#|loopback|inet6"  1>>$sysinfo 2>>$sysinfo 3>>$sysinfo	
		echo "" >> $sysinfo
		
		#Ports
		echo "Open Ports:" >> $sysinfo
		netstat -tulpen | egrep "tcp6|udp6" | egrep -v "Local" | awk '{print $1,$4,$9}' | sed 's/tcp6/tcp/g' | sed 's/udp6/udp/g' | sed 's/:::/ /g' | sed 's/ /\t/g' 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		echo "" >> $sysinfo

		#External Network
	    echo "External IP:" >> $sysinfo
		myipadr=`w3m www.whatismyipaddress.com 2> /dev/null | egrep -A 2 "Your IPv4 Address|My IP Address Is" | head -n 2 | tail -n 1`
		echo $myipadr 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		echo "" >>$sysinfo
						
		#ISP Info
		echo "ISP Info:" >> $sysinfo
		w3m www.whatismyipaddress.com 2> /dev/null | egrep -A 10 "My IP Information"  | egrep "ISP:|Country:"	1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		echo "" >>$sysinfo
		
		#DNS-Server
		echo "DNS-Server:" >> $sysinfo
		cat /etc/resolv.conf | grep name | awk '{print $2}' 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		echo "" >> $sysinfo
		
		#RDNS
		echo "RDNS:" >> $sysinfo
		w3m https://wtfismyip.com/ | head -n 7 | tail -n 1 | sed 's/^[ \t]*//' 1>>$sysinfo 2>>$sysinfo 3>>$sysinfo
		echo "" >> $sysinfo
		
		#Blacklist
		echo "Blacklist check:" >> $sysinfo
		blcheck=`w3m www.spamhaus.org/query/ip/8.8.8.8 | grep "8.8.8.8 is listed"`
		if [ "$blcheck" == "" ]
		then
			echo "$myipadr is not listed" >> $sysinfo
		else
			echo "$myipadr is listed!" >> $sysinfo
		fi
		echo "" >> $sysinfo
		
		#Pakete
		echo "Pakete:" >> $sysinfo
		ubuntu-support-status --show-unsupported  >> $sysinfo
		echo "" >> $sysinfo		
				
		#Ende
		dialog --colors --backtitle "System Master Script" --title "System Info" --exit-label "OK" --textbox $sysinfo 0 0
		return 1
}
