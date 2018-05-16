#!/bin/bash
############################
#Sysmaster				   #
############################

#System Tetst

systemtest()
{
	local log=${instdir}/systest/systest.log
	touch $log
	startlog $log
	local testlog=${instdir}/systest/testlog.log
	rm -v $testlog 1>>$log 2>>$log 3>>$log
	touch $testlog
	
	dialog --colors --backtitle "System Master Script" --title "System Performance Test" --no-kill --tailboxbg $testlog 50 100		

	echo "Test init..." 1>>$testlog 2>>$testlog 3>>$testlog
	apt-get -y -q --force-yes install sysbench 1>>$log 2>>$log 3>>$log
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog
	
	#CPU
	echo "Doing CPU performance benchmark..." 1>>$testlog 2>>$testlog 3>>$testlog
	sysbench cpu --cpu-max-prime=20000 run | egrep "total time:|events per second:" | sed 's/^[ \t]*//' 1>>$testlog 2>>$testlog 3>>$testlog
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog

	#MEM
	echo "Doing Memory performance benchmark..." 1>>$testlog 2>>$testlog 3>>$testlog
	sysbench memory run | egrep "Total operations:|MiB transferred" | sed 's/^[ \t]*//' 1>>$testlog 2>>$testlog 3>>$testlog
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog

	#DISK
	echo "Doing Disk performance benchmark..." 1>>$testlog 2>>$testlog 3>>$testlog
	sysbench fileio --file-total-size=1G prepare  | egrep " bytes written in" | sed 's/^[ \t]*//' 1>>$testlog 2>>$testlog 3>>$testlog
	sysbench fileio --file-total-size=1G --file-test-mode=rndrw run | egrep "read, |written, " | sed 's/^[ \t]*//' 1>>$testlog 2>>$testlog 3>>$testlog
	sysbench fileio cleanup | egrep "Removing" | sed 's/^[ \t]*//' 1>>$testlog 2>>$testlog 3>>$testlog
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog
	
	#Bandwidth
	echo "Doing Bandwidth benchmark..." 1>>$testlog 2>>$testlog 3>>$testlog
	apt-get install speedtest-cli 1>>$log 2>>$log 3>>$log
	speedtest-cli  1>>$testlog 2>>$testlog 3>>$testlog
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog
	
	#Latency
	echo "Doing Latency benchmark..." 1>>$testlog 2>>$testlog 3>>$testlog
	echo "EXTERN"  1>>$testlog 2>>$testlog 3>>$testlog
	ping 8.8.8.8 -c 1 | grep time=  1>>$testlog 2>>$testlog 3>>$testlog
	echo "EXTERN DNS"  1>>$testlog 2>>$testlog 3>>$testlog
	ping www.google.de -c 1 | grep time= 1>>$testlog 2>>$testlog 3>>$testlog
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog
	
	sleep 6
    killdialog
	
	local cputime1=`egrep "total time:" $testlog | head -n 1 | sed 's/^[ \t]*//'`
	local cputime2=`egrep "events per second:" $testlog | sed 's/^[ \t]*//'`
	local memtime1=`egrep "Total operations:" $testlog`
	local memtime2=`egrep "MiB transferred" $testlog`
	local disktime1=`egrep "bytes written in" $testlog`
	local disktime2=`egrep "read, " $testlog | sed 's/^[ \t]*//'`
	local disktime3=`egrep "written, " $testlog | sed 's/^[ \t]*//'`
	local upload=`egrep "Download:" $testlog | awk '{print $2,$3}'`
	local download=`egrep "Upload:" $testlog | awk '{print $2,$3}'`
	local intlat=`egrep "time=" $testlog | head -n 2 | tail -n 1 | awk '{print $7,$8,$9}' | sed 's/time=//'`
	local extlat=`egrep "time=" $testlog | tail -n 1 | awk '{print $7,$8,$9}' | sed 's/time=//'`
	
	until [ "$doexit" == "ok" ]
	do
		dialog --colors --title "Sysmaster" --backtitle "Systest Summary" --help-button --help-label "Systeminfo" --ok-label "Back"  --extra-button --extra-label "Systemmonitor" --msgbox "\Z1Results\Zn \n\nCPU\n $cputime1\n $cputime2  \nMEM\n $memtime1\n $memtime1 \nDISK\n $disktime1\n $disktime2\n $disktime3 \n\nDownload = $download \nUpload = $upload  \nLatency EXTERN = $intlat  \nLatency EXTERN DNS = $extlat " 25 90
		case $? in
                0)
                        doexit="ok"
                ;;
				2)
						systeminfo
				;;
                3)
                        sysmonitor
                ;;
		esac
	done
	return 1
}
