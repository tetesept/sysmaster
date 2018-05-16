#!/bin/bash
############################
#System Master Skript      #
#TeTesept                  #
############################

### variables ###
defaultmail=none
targetserver=none
datum=`date +%Y%m%d%H%M`
datumwin=`date +"%d.%m.%y %H:%M"`
LOGPATH=/var/log/dupl_backup/
SERVER="$(hostname -f)"
log=incmaillog.log
if [ -f  $log ]
then
	rm $log
fi
touch $log

if ! [ -d /var/log/dupl_backup  ]
then
	mkdir /var/log/dupl_backup
fi

### configure this ###
user=                                   		# Username Backupuser
pw=                                     		# Password Backupuser
excludefile=/root/backup/exclude        		# Location of Excludefile
bsource=/                               		# Source of your Backup, eg. / for the whole Server excluding what is inside the excludefile
btarget=${targetserver}/backup     		        # Target of your Backup >>> IP/backup, eg. 192.168.0.1/backup

### The GPG-Key ###
export PASSPHRASE='your-gpg-key'

### Do Not Touch This!!! ###

duplicity incr --exclude-filelist ${excludefile} ${bsource} sftp://${user}:${pw}@${btarget} >> "${LOGPATH}backup_inc${datum}.log"
duplicity collection-status sftp://${user}:${pw}@${btarget} >> "${LOGPATH}collection_status${datum}.log"

unix2dos ${LOGPATH}backup_inc${datum}.log 1>> /dev/null 2>> /dev/null 3>> /dev/null
unix2dos ${LOGPATH}collection_status${datum}.log 1>> /dev/null 2>> /dev/null 3>> /dev/null

echo "Incremental Backup ${SERVER} ${datumwin}" 1>> $log 2>> $log 3>> $log
echo "" 1>> $log 2>> $log 3>> $log
echo "-----------------------------------Backup_inc-------------------------------------" 1>> $log 2>> $log 3>> $log
cat "${LOGPATH}backup_inc${datum}.log" | sed 's/[\r]/./g' 1>> $log 2>> $log 3>> $log
echo "-----------------------------------Collection_status-------------------------------" 1>> $log 2>> $log 3>> $log
cat "${LOGPATH}collection_status${datum}.log" 1>> $log 2>> $log 3>> $log


cat $log | sed 's/^[.]//g' | sed 's/^[ \t]*//;s/[ \t]*$//' |  mail -s "Incr_${datum} ${SERVER}" $defaultmail
cat $log >> ${LOGPATH}Inc_${datum}

rm ${LOGPATH}collection_status${datum}.log
rm ${LOGPATH}backup_inc${datum}.log
rm $log


unset PASSPHRASE
unset pw
