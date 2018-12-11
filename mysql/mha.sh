#关闭selinux、防火墙、安装mysql



#主从复制：
##主
#修改配置文件
[root@server ~]# vi /etc/my.cnf
server-id = 1
log-bin = mysql-bin
binlog_format=MIXED

systemctl start mysqld
grep "temporary password" /var/log/mysqld.log
mysql -uroot -p'password'
SET PASSWORD = 'new password';

##从
#修改配置文件
[root@agent1 ~]# vi /etc/my.cnf
#配置server-id,标识从服务器
server-id=2
#打开Mysql中继日志
relay_log = mysql-relay-bin
#设置从服务器只读权限
read-only =1
#打开从服务器的二进制日志
log_bin =mysql-bin
#使得更新的数据写进二进制日志中
log_slave_updates =1
#混合日志模式
binlog_format=MIXED

systemctl start mysqld
grep "temporary password" /var/log/mysqld.log
mysql -uroot -p'password'
SET PASSWORD = 'new password';

Mysql默认安装路径为/var/lib/mysql ,空间较小推荐将安装路径配置到存储较大的目录
#新建目录
[root@namenode ~]# mkdir /home/mysql_data

#将/var/lib/mysql复制到新的目录
[root@namenode ~]# cp -a /var/lib/mysql /home/mysql_data/

#修改mysql配置文件
[root@namenode ~]# vi /etc/my.cnf
 
#建立mysql.sock软连接
[root@namenode ~]# ln -s /home/mysql_data/mysql/mysql.sock /var/lib/mysql/mysql.sock

#重新启动mysql
[root@namenode ~]# systemctl start mysqld

##主
#授权复制账户
SQL>grant replication slave ,replication client on *.* to slave@'%' identified by 'password';

#查看主服务器的状态
SQL>show master status;

##从
#启动从服务器复制线程
SQL>grant all privileges on *.* to 'slave'@'%' identified by 'password' with grant option;

SQL>change master to master_host='IP', master_user='slave', 
master_password='password', 
master_log_file='mysql-bin.000003', 
master_log_pos=510;
SQL>start slave; 

#查看从服务器状态 
SQL>show slave status\G;


SQL>show processlist;

#MHA

#创建工作目录
[root@server ~]# mkdir -p /home/mha/
#下载源码包
#[root@server ~]# yum -y install wget unzip epel-release
#[root@server ~]# wget https://codeload.github.com/yoshinorim/mha4mysql-node/zip/master -O /usr/local/src/mha-node.zip
#[root@server ~]# wget https://codeload.github.com/yoshinorim/mha4mysql-manager/zip/master -O /usr/local/src/mha-manager.zip
#解压
#[root@server ~]# unzip /usr/local/src/mha-manager.zip -d /usr/local/src
#[root@server ~]# unzip /usr/local/src/mha-node.zip -d /usr/local/src
#安装perl及其相关依赖
[root@server ~]# yum -y install perl perl-ExtUtils-MakeMaker perl-ExtUtils-CBuilder perl-Parallel-ForkManager  perl-Config-Tiny perl-DBD-MySQL perl-Log-Dispatch 'perl(inc::Module::Install)' 'perl(Test::Without::Module)' 'perl(Log::Dispatch)'
#编译节点端
[root@server ~]# cd /home/mha4mysql-node-master/
[root@server ~]# perl Makefile.PL 
[root@server ~]# make &&make install
#编译管理端
[root@server ~]# cd /home/mha4mysql-manager-master/
[root@server ~]# perl Makefile.PL
[root@server ~]# make &&make install

#复制配置文件
[root@server ~]# cp /home/mha4mysql-manager-master/samples/conf/* /home/mha

#编辑配置文件
[root@server ~]# vi /home/mha/app1.cnf
[server default]
manager_workdir=/var/log/masterha/app1
manager_log=/var/log/masterha/app1/manager.log
master_ip_failover_script=/home/mha4mysql-manager-master/samples/scripts/master_ip_failover
master_binlog_dir=/home/mysql_data/mysql
user=slave
password=password
ssh_user=root

[server1]
hostname=IP
candidate_master=1

[server2]
hostname=IP
candidate_master=1
check_repl_delay=0

[server3]
hostname=IP

#MHA测试
masterha_check_ssh --conf=/home/mha/app1.cnf

masterha_check_repl --conf=/home/mha/app1.cnf

masterha_manager --conf=/home/mha/app1.cnf

masterha_check_status --conf=/home/mha/app1.cnf




附：my.cnf配置文件
#主：
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
#datadir=/var/lib/mysql
datadir=/home/mysql_data/mysql
#socket=/var/lib/mysql/mysql.sock
socket=/home/mysql_data/mysql/mysql.sock
server-id = 1
log-bin = mysql-bin
binlog_format=MIXED
lower_case_table_names=1
sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid


character-set-server=utf8
collation-server=utf8_unicode_ci


default_storage_engine=innodb

skip_external_locking=1
open_files_limit=65535

# connection
interactive_timeout=28800
wait_timeout=28800
lock_wait_timeout=28800
skip_name_resolve=1
max_connections=2000
max_user_connections=1000
max_connect_errors=1000000

# table cache performance settings #
table_open_cache=10240
table_definition_cache=10240
table_open_cache_instances=16

# session memory settings #
read_buffer_size=64M
read_rnd_buffer_size=262144
sort_buffer_size=64M
tmp_table_size=67108864
join_buffer_size=256M
thread_cache_size=256

# innodb set
innodb_buffer_pool_size=40G
innodb_page_size=16384
innodb_lock_wait_timeout=60
innodb_open_files=60000


[mysql]
default-character-set=utf8

[client]
default-character-set=utf8





#备
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
#datadir=/var/lib/mysql
datadir=/home/mysql_data/mysql
#socket=/var/lib/mysql/mysql.sock
socket=/home/mysql_data/mysql/mysql.sock
server-id=2
relay_log = mysql-relay-bin
read-only =1
log_bin =mysql-bin
log_slave_updates =1
binlog_format=MIXED

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid