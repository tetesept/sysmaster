#!/bin/bash
############################
#Sysmaster				   #
############################

# Script zum Anlegen eines SFTP-Users mit eigener chroot-Umgebung.

if [ $# != "4" ]
then
        echo "Usage: `basename $0` \${usernam} \${password} \${server} \${home}"
        exit $E_NOARGSfi
fi

username=$1
password=$2
server=$3
home=$4

if [ -z $home ]
then
        echo ef
        home=home3
fi

echo username=$username
echo password=$password
echo server=$server
echo home=$home

# Passwort generieren...
#pass="$(pwgen -c -s -n 12 1 | awk '{print $1}')"

# Bentuzer/Home-Verzeichnis/Shell setzen...
useradd -d /${home}/$username -m -s /bin/false $username;

# Passwort setzen...
echo "$username:$password" | chpasswd;

# Ergebnis mailen...
echo "$username:$password"  | mail -s "Backup-User angelegt fuer $server" "root@localhost"

# Berechtigungen der Verzeichnisse setzen...
chown root:$username /${home}/$username
chmod 755 /${home}/$username
usermod -d /${home}/$username $username

# Backup-Verzeichnis einrichten...
mkdir /${home}/$username/backup
chown $username:$username /${home}/$username/backup
chmod 755 /${home}/$username/backup

#Eintrag in den sshd einfuegen...
echo "Match User" $username >>/etc/ssh/sshd_config
echo "ChrootDirectory /${home}/"$username >>/etc/ssh/sshd_config
echo "ForceCommand internal-sftp" >>/etc/ssh/sshd_config
echo "###" >>/etc/ssh/sshd_config

#Liste updaten
echo $username" "$server >> /root/scripts/backupuser.txt

# sshd neustarten....
service ssh reload

# EOF
