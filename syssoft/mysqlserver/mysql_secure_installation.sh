#!/bin/sh

config=".my.cnf.$$"
command=".mysql.$$"
mysql_client=""

log=syssoft/mysqlserver/mysqlsecuresql.log
rm $log
touch $log

echo $instdir

trap "interrupt" 1 2 3 6 15

password="$1"
rootpass="$1"
echo_n=
echo_c=

get_root_password() {
    echo "Logging into mysql..." 1>>$log 2>>$log 3>>$log
	status=1
    while [ $status -eq 1 ]; do
        rootpass=$password
        make_config
        do_query ""
        status=$?
    done
	echo " ... Success!" 1>>$log 2>>$log 3>>$log
	echo "" 1>>$log 2>>$log 3>>$log
}

set_echo_compat() {
    case `echo "testing\c"`,`echo -n testing` in
	*c*,-n*) echo_n=   echo_c=     ;;
	*c*,*)   echo_n=-n echo_c=     ;;
	*)       echo_n=   echo_c='\c' ;;
    esac
}

prepare() {
    touch $config $command
    chmod 600 $config $command
}

find_mysql_client()
{
  for n in ./bin/mysql mysql
  do  
    $n --no-defaults --help > /dev/null 2>&1
    status=$?
    if test $status -eq 0
    then
      mysql_client=$n
      return
    fi  
  done
  echo "Can't find a 'mysql' client in PATH or ./bin" 1>>$log 2>>$log 3>>$log
  exit 1
}

do_query() {
    echo "$1" >$command
    $mysql_client --defaults-file=$config <$command
    return $?
}

basic_single_escape () {
    echo "$1" | sed 's/\(['"'"'\]\)/\\\1/g'
}

make_config() {
    echo "# mysql_secure_installation config file" >$config
    echo "[mysql]" >>$config
    echo "user=root" >>$config
    esc_pass=`basic_single_escape "$rootpass"`
    echo "password='$esc_pass'" >>$config
}

remove_anonymous_users() {
	echo "Remove Anonymous Users..." 1>>$log 2>>$log 3>>$log
    do_query "DELETE FROM mysql.user WHERE User='';"
    if [ $? -eq 0 ]; then
		echo " ... Success!" 1>>$log 2>>$log 3>>$log
		else
		echo " ... Failed!" 1>>$log 2>>$log 3>>$log
		clean_and_exit
    fi
	echo "" 1>>$log 2>>$log 3>>$log
    return 0
}

remove_remote_root() {
	echo "Remove Remote Root..." 1>>$log 2>>$log 3>>$log
    do_query "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    if [ $? -eq 0 ]; then
	echo " ... Success!" 1>>$log 2>>$log 3>>$log
    else
	echo " ... Failed!" 1>>$log 2>>$log 3>>$log
    fi
	echo "" 1>>$log 2>>$log 3>>$log
}

remove_test_database() {
    echo "Dropping test database..." 1>>$log 2>>$log 3>>$log
    do_query "DROP DATABASE test;" 2> /dev/null
    if [ $? -eq 0 ]; then
	echo " ... Success!" 1>>$log 2>>$log 3>>$log
    else
	echo " ... Failed!  Not critical, keep moving..." 1>>$log 2>>$log 3>>$log
    fi
	echo "" 1>>$log 2>>$log 3>>$log
    echo "Removing privileges on test database..." 1>>$log 2>>$log 3>>$log
    do_query "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
    if [ $? -eq 0 ]; then 
	echo " ... Success!" 1>>$log 2>>$log 3>>$log
    else
	echo " ... Failed!  Not critical, keep moving..." 1>>$log 2>>$log 3>>$log
    fi
	echo "" 1>>$log 2>>$log 3>>$log
    return 0
}

reload_privilege_tables() {
    echo "Reload Privilege Tables..." 1>>$log 2>>$log 3>>$log
    do_query "FLUSH PRIVILEGES;"
    if [ $? -eq 0 ]; then
		echo " ... Success!" 1>>$log 2>>$log 3>>$log
		echo "" 1>>$log 2>>$log 3>>$log
		return 0
    else
		echo " ... Failed!" 1>>$log 2>>$log 3>>$log
		echo "" 1>>$log 2>>$log 3>>$log
		return 1
    fi
}

interrupt() {
    echo
    echo "Aborting!" 1>>$log 2>>$log 3>>$log
    echo
    cleanup
    stty echo
    exit 1
}

cleanup() {
    echo "Cleaning up..." 1>>$log 2>>$log 3>>$log
    rm -f $config $command
	echo " ... Success!" 1>>$log 2>>$log 3>>$log
	echo "" 1>>$log 2>>$log 3>>$log
}

clean_and_exit() {
	cleanup
	exit 1
}

#Main
echo "Secure Mysql:" 1>>$log 2>>$log 3>>$log
prepare
find_mysql_client
set_echo_compat

get_root_password

remove_anonymous_users
remove_remote_root
remove_test_database
reload_privilege_tables

cleanup
