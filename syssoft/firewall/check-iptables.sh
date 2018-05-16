#!/bin/sh

policy=`iptables -L | grep INPUT | awk '{print $4}' | sed "s/)//g"`

if [ ${policy} != "DROP" ]
then
        echo "Rule policy is set to ACCEPT. Reloading Rules...\n" >> /var/log/iptables.log
        /etc/firewall
fi
