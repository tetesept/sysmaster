#!/bin/bash
############################
# Sysmaster
# TeTesept
############################

curdir=`echo $0 | sed 's/check_backup//'`
newest_backup_file=`ls -ltr /var/log/dupl_backup/ | egrep "Full|Inc" | tail -n 1 | awk '{print $9}'`
backup_path="/var/log/dupl_backup/"
bpf=${backup_path}${newest_backup_file}

if [ "$newest_backup_file" == "" ]
then
        echo "Error in Init. Unable to find newest backup file"
        exit 0
fi

less $bpf

