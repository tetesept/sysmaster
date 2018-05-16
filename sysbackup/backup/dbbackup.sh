#!/bin/bash
############################
#System Master Skript      #
#TeTesept		   #
############################

defaultmail=none
TARGET=/root/backup/db
IGNORE="phpmyadmin|mysql|information_schema|performance_schema|test|sys"
CONF=/etc/mysql/debian.cnf
SERVER="$(hostname -f)"
DBSTATUS=/var/log/dbbackup/bdsattus.log
DBSTATUSDIR=/var/log/dbbackup
NOW=$(date +"%Y-%m-%d")

#Clean
clean()
{
	find -P $DBSTATUSDIR -maxdepth 1 -type f -mtime +7 -exec rm {} \;
	find $TARGET -mtime +7 -exec rm {} \;
}

#Trap zum aufräumen
trap 'clean' SIGINT SIGHUP SIGILL SIGSYS SIGTERM SIGSTOP 0 1 2 3

rm /var/log/dbbackup/*.log
touch $DBSTATUS

if [ ! -r $CONF ]
then 
	echo "Error: $0 - auf $CONF konnte nicht zugegriffen werden" >> $DBSTATUS
	exit 1
fi

if [ ! -d $TARGET ] || [ ! -w $TARGET ]
then 
	echo "Error: $0 - Backup-Daten-Verzeichnis $TARGET nicht beschreibbar" >> $DBSTATUS
	exit 1
fi

if [ ! -d $DBSTATUSDIR ] || [ ! -w $DBSTATUSDIR ]
then 
	echo "Error: $0 - Backup-Log-Verzeichnis $DBSTATUSDIR nicht beschreibbar" >> $DBSTATUS
	exit 1
fi

if [ ! -r $DBSTATUS ] || [ ! -w $DBSTATUS ]
then 
	echo "Error: $0 - Backup-Log $DBSTATUS nicht beschreibbar" >> $DBSTATUS
	exit 1
fi

DBS="$(/usr/bin/mysql --defaults-extra-file=$CONF -Bse "show databases" | /bin/grep -Ev $IGNORE)"
for DB in $DBS
do
        /usr/bin/mysqldump --defaults-extra-file=$CONF -v --skip-extended-insert --skip-comments $DB > $TARGET/$DB.sql 2> /var/log/dbbackup/$DB.log
        tar  --remove-files -czf $TARGET/$DB-$NOW.tar.gz $TARGET/$DB.sql > /dev/null 2>&1
done

for i in `ls /var/log/dbbackup/ | grep -v "bdsattus.log"`
do
    DB_NAME=`echo $i | cut -d. -f1`
	dberror=`egrep -q "mysqldump: Got error|Error" /var/log/dbbackup/$DB_NAME.log`
    if [ "$dberror" ==  ""  ]
	then
        echo $i " success" | sed 's/\./ \t-->\t /' | awk '{print $1,$2,$4}'  >> $DBSTATUS
    else
        echo $i " failed" | sed 's/\./ \t-->\t /' | awk '{print $1,$2,$4}' >> $DBSTATUS
    fi;
done;

if [ "$(cat $DBSTATUS)" == ""  ]
then
        echo "Keine Datenbank vorhanden"  >> $DBSTATUS
fi


bdfail=`egrep "failed|beschreibbar|zugegriffen" $DBSTATUS`
if [ "$bdfail" == "" ]
then
	mail -s "Sucsess: DB Backup ${NOW} ${SERVER}" $defaultmail < $DBSTATUS
else
	mail -s "Failed: DB Backup ${NOW} ${SERVER}" $defaultmail < $DBSTATUS
fi

exit 0
