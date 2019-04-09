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

	echo "Preparing Test..." 1>>$testlog 2>>$testlog 3>>$testlog
	apt-get -y -q --force-yes install sysbench 1>>$log 2>>$log 3>>$log
	apt-get -y -q --force-yes install mbw 1>>$log 2>>$log 3>>$log
	apt-get -y -q --force-yes install speedtest-cli 1>>$log 2>>$log 3>>$log
	useradd --no-create-home benchmark  1>>$log 2>>$log 3>>$log
	
	#CPU Test1 
	echo "----CPU Test 1 Latency----" 1>>$testlog 2>>$testlog 3>>$testlog
	sysbench cpu --cpu-max-prime=10000 --time=0 --events=10000 run  | egrep "total time:|Latency|min:|avg:|max:" | sed 's/^[ \t]*//' 1>>$testlog 2>>$testlog 3>>$testlog
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog
	
	#CPU Test2
	echo "----CPU Test 2 Calculate----" 1>>$testlog 2>>$testlog 3>>$testlog
	 { time echo "scale=3800; 4*a(1)" | bc -l | grep null; } 2>&1 | grep real | sed 's/m/m /'  1>>$testlog 2>>$testlog 3>>$testlog
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog

	#MEM Test1
	echo "----MEM Test 1 Latency----" 1>>$testlog 2>>$testlog 3>>$testlog
	sysbench memory --memory-block-size=1M --memory-total-size=100G --num-threads=1 run | egrep "total time:|Latency|min:|avg:|max:" | sed 's/^[ \t]*//' 1>>$testlog 2>>$testlog 3>>$testlog
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog

	#MEM Test2
	echo "----MEM Test 2 Throughput----" 1>>$testlog 2>>$testlog 3>>$testlog
	mbw -b 4096 32 -t0 | grep AVG  1>>$testlog 2>>$testlog 3>>$testlog
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog

	
	#DISK Test 1
    echo "----DISK Test 1 RndRW----" 1>>$testlog 2>>$testlog 3>>$testlog
	sysbench fileio --file-total-size=5G prepare  | egrep "none" 1>>$testlog 2>>$testlog 3>>$testlog
	sysbench fileio --num-threads=1 --file-total-size=1G --file-test-mode=rndrw run | egrep "read,|written," | sed 's/^[ \t]*//' 1>>$testlog 2>>$testlog 3>>$testlog
    sysbench fileio --file-total-size=5G cleanup | egrep "none"  1>>$testlog 2>>$testlog 3>>$testlog
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog

	#DISK Test 2
	echo "----DISK Test 2 SeqRW----" 1>>$testlog 2>>$testlog 3>>$testlog
	echo "read" 1>>$testlog 2>>$testlog 3>>$testlog
	{ dd if=/dev/zero of=/tmp/test.file bs=100M count=50 oflag=direct ;} 2>&1  | grep copied 1>>$testlog 2>>$testlog 3>>$testlog
	echo "written" 1>>$testlog 2>>$testlog 3>>$testlog
	{ dd if=/tmp/test.file of=/dev/null bs=1M count=10000 ;} 2>&1 | grep copied  1>>$testlog 2>>$testlog 3>>$testlog
	rm /tmp/test.file  1>>$testlog 2>>$testlog 3>>$testlog
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog
	

	#Bandwidth
	echo "----Bandwidth Test----" 1>>$testlog 2>>$testlog 3>>$testlog
	
	speedtest-cli 1>>$testlog 2>>$testlog 3>>$testlog
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog
	
	#Latency
	echo "----Latency Test----" 1>>$testlog 2>>$testlog 3>>$testlog
	echo "EXTERN IP"  1>>$testlog 2>>$testlog 3>>$testlog
	ping 8.8.8.8 -c 1 | grep time=  1>>$testlog 2>>$testlog 3>>$testlog
	echo "EXTERN DNS"  1>>$testlog 2>>$testlog 3>>$testlog
	ping www.google.de -c 1 | grep time= 1>>$testlog 2>>$testlog 3>>$testlog
	echo "" 1>>$testlog 2>>$testlog 3>>$testlog
	
	
	sleep 6
    killdialog
	
	until [ "$doexit" == "ok" ]
	do
		dialog --colors --title "Sysmaster" --backtitle "Systest Summary" --help-button --help-label "Systeminfo" --ok-label "Back"  --extra-button --extra-label "Systemmonitor" --textbox $testlog 55 100
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
