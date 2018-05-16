#/bin/bash
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
log=fullmaillog.log
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
user=								# Username Backupuser
pw=									# Password Backupuser
excludefile=/root/backup/exclude	# Location of Excludefile
bsource=/							# Source of your Backup, eg. / for the whole Server excluding what is inside the excludefile
btarget=${targetserver}/backup			# Target of your Backup >>> IP/backup, eg. 192.168.0.1/backup
cycle=2								# Number of Fullbackups to keep, eg. 5 to keep 5 Fullbackups

### The GPG Key ###
export PASSPHRASE='your-gpg-key'

### Do Not Touch This!!! ###

duplicity full --exclude-filelist ${excludefile} ${bsource} sftp://${user}:${pw}@${btarget} > "${LOGPATH}backup_full${datum}.log"
duplicity remove-all-but-n-full ${cycle} --force sftp://${user}:${pw}@${btarget} > "${LOGPATH}remove_full${datum}.log"
duplicity verify --exclude-filelist ${excludefile} sftp://${user}:${pw}@${btarget} ${bsource} > "${LOGPATH}verify_backup${datum}.log"
duplicity collection-status sftp://${user}:${pw}@${btarget} > "${LOGPATH}collection_status2${datum}.log"

unix2dos ${LOGPATH}backup_full${datum}.log 1>> /dev/null 2>> /dev/null 3>> /dev/null
unix2dos ${LOGPATH}remove_full${datum}.log 1>> /dev/null 2>> /dev/null 3>> /dev/null
unix2dos ${LOGPATH}verify_backup${datum}.log 1>> /dev/null 2>> /dev/null 3>> /dev/null
unix2dos ${LOGPATH}collection_status2${datum}.log 1>> /dev/null 2>> /dev/null 3>> /dev/null

echo "Full Backup ${SERVER} ${datumwin}" 1>> $log 2>> $log 3>> $log
echo "" 1>> $log 2>> $log 3>> $log
echo "-----------------------------------Backup_full-------------------------------------" 1>> $log 2>> $log 3>> $log
cat "${LOGPATH}backup_full${datum}.log" | sed 's/[\r]/./g'  1>> $log 2>> $log 3>> $log
echo "-----------------------------------Remove_full-------------------------------------" 1>> $log 2>> $log 3>> $log
cat "${LOGPATH}remove_full${datum}.log" 1>> $log 2>> $log 3>> $log
echo "" 1>> $log 2>> $log 3>> $log
echo "-----------------------------------Verify_backup-----------------------------------" 1>> $log 2>> $log 3>> $log
cat "${LOGPATH}verify_backup${datum}.log" | sed 's/[\r]/./g' 1>> $log 2>> $log 3>> $log
echo "" 1>> $log 2>> $log 3>> $log
echo "-----------------------------------Collection_status-------------------------------" 1>> $log 2>> $log 3>> $log
cat "${LOGPATH}collection_status2${datum}.log" 1>> $log 2>> $log 3>> $log
echo "" 1>> $log 2>> $log 3>> $log
echo "-----------------------------------------------------------------------------------" 1>> $log 2>> $log 3>> $log

cat $log | sed 's/^[.]//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | mail -s "Full_${datum} ${SERVER}" $defaultmail
cat $log >> ${LOGPATH}Full_${datum}

rm ${LOGPATH}backup_full${datum}.log
rm ${LOGPATH}remove_full${datum}.log
rm ${LOGPATH}verify_backup${datum}.log
rm ${LOGPATH}collection_status2${datum}.log
rm $log

unset PASSPHRASE
unset pw

