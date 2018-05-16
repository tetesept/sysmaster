#!/bin/bash
############################
#Sysmaster				   #
############################

#sysstat

pwddir=`pwd`
log="${pwddir}/trace.log"
timer="30"
date=`date +%H:%M_%d.%m.%y`
touch $log

echo "----------------" | tee -a $log	
#ping
echo -ne "${date} " | tee -a $log
ping -c 1 8.8.8.8 | grep ttl | awk '{print $7,$8}' | sed 's/time=/Ping:\t /' | tee -a $log
#Load
echo -ne "${date} " | tee -a $log
echo -ne "Load:\t " | tee -a $log
cat /proc/loadavg | awk '{print $1,$2,$3}' |  tee -a $log
#Iowait
echo -ne "${date} " | tee -a $log
echo -ne "IOWait:\t " | tee -a $log
iostat | grep -A 2 "iowait"  |  head -n 2 | tail -n 1 |   awk '{print $4}' |  tee -a $log
#Mem
echo -ne "${date} " | tee -a $log
echo -ne "FreeM:\t " | tee -a $log
free -m | awk '{print $6}' |  head -n 2 | tail -n 1 |  tee -a $log
#CPU
echo -ne "${date} " | tee -a $log
echo -ne "Idle:\t " | tee -a $log
iostat | grep -A 1 "avg-cpu" | grep -v avg-cpu | sed ':a;N;$!ba;s/\n/ /g' |  awk '{print $6}'  |  tee -a $log
