#!/bin/bash
#auto install mysql 
#auther kim 2019-12-04
if [ -d /usr/local/mysql ];then
  echo "/usr/local/mysql install Folder exists,check please!"
  sleep 3
  exit
else
  echo "mysql install Start...!"
fi

if [ `netstat -tnlp | grep 3306 | wc -l` -eq 1 ];then
        echo "mysql already install,please check!"
	exit
else
        echo "mysql install Continue!"
fi

yum install libaio* -y
yum install wget -y
#wget -c https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.28-linux-glibc2.12-x86_64.tar.gz
cd /tmp
tar -xzf mysql-5.7.28-linux-glibc2.12-x86_64.tar.gz
mv mysql-5.7.28-linux-glibc2.12-x86_64 /usr/local/mysql-5.7.28
cd /usr/local/
ln -s mysql-5.7.28 mysql

/usr/sbin/groupadd mysql
/usr/sbin/useradd -s /sbin/nologin -M -g mysql mysql

if [ -d /data/mysql ]; then
  echo "Folder exists,check please!"
  exit
else
  mkdir -p /data/mysql
  mkdir -p /data/mysql/{data,logs,tmp}
  chown -R mysql:mysql /data/mysql
  echo "Folder exists /data/mysql created succeed!"
fi

chown -R mysql.mysql /usr/local/mysql-5.7.28
chown -R mysql.mysql /usr/local/mysql

cat > /etc/my.cnf <<EOF
[client]
socket=/data/mysql/tmp/mysql.sock
default-character-set = utf8

[mysqld]
user = mysql
port = 3306
character_set_server=utf8
basedir=/usr/local/mysql
datadir=/data/mysql/data
log-error=/data/mysql/logs/mysqld.log
pid-file=/data/mysql/tmp/mysqld.pid
socket=/data/mysql/tmp/mysql.sock

lower_case_table_names = 1
max_connections=5000
sql_mode=STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION

symbolic-links=0

long_query_time = 1
slow_query_log = ON
slow_query_log_file = /data/mysql/logs/mysqld_slow.log

default-storage-engine=INNODB

[mysqld_safe]
log-error=/data/mysql/logs/mysqld.log
pid-file=/data/mysql/tmp/mysqld.pid
EOF

touch /data/mysql/logs/mysqld.log
touch /data/mysql/tmp/mysql.sock
touch /data/mysql/tmp/mysqld.pid
chown -R mysql.mysql /data/mysql/

cp /usr/local/mysql/support-files/mysql.server /etc/rc.d/init.d/mysqld
chmod +x /etc/rc.d/init.d/mysqld

/usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql/ --datadir=/data/mysql/data/

if [ $? -eq 0 ];then
	echo "mysql Reinitialize successful!"
else
	echo "mysql failed successful!"
fi

cat >> /etc/profile <<EOF

#mysql
PATH=/usr/local/mysql/bin:/usr/local/mysql/lib:$PATH
export PATH
EOF
sleep 3
source /etc/profile

chkconfig --add mysqld
chkconfig mysqld on
/etc/init.d/mysqld start

if [ `netstat -tnlp | grep 3306 | wc -l` -eq 1 ];then
	echo "mysql install successful!"
else
	echo "mysql install failed,please check!"
fi
