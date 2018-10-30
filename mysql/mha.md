# 关闭selinux、防火墙、安装mysql配置主从复制



# 主从复制：
## 主
### 修改配置文件
[root@server ~]# vi /etc/my.cnf
server-id = 1
log-bin = mysql-bin
binlog_format=MIXED

systemctl start mysqld
grep "temporary password" /var/log/mysqld.log
mysql -uroot -p''
SET PASSWORD = 

## 从
### 修改配置文件
[root@agent1 ~]# vi /etc/my.cnf
### 配置server-id,标识从服务器
server-id=2
### 打开Mysql中继日志
relay_log = mysql-relay-bin
### 设置从服务器只读权限
read-only =1
### 打开从服务器的二进制日志
log_bin =mysql-bin
### #使得更新的数据写进二进制日志中
log_slave_updates =1
### 混合日志模式
binlog_format=MIXED

systemctl start mysqld
grep "temporary password" /var/log/mysqld.log
mysql -uroot -p''
SET PASSWORD = '';

Mysql默认安装路径为/var/lib/mysql ,空间较小推荐将安装路径配置到存储较大的目录
## 新建目录
[root@namenode ~]# mkdir /home/mysql_data

### 将/var/lib/mysql复制到新的目录
[root@namenode ~]# cp -a /var/lib/mysql /home/mysql_data/

### 修改mysql配置文件
[root@namenode ~]# vi /etc/my.cnf
 
### 建立mysql.sock软连接
[root@namenode ~]# ln -s /home/mysql_data/mysql/mysql.sock /var/lib/mysql/mysql.sock

### 重新启动mysql
[root@namenode ~]# systemctl start mysqld

## 主
### 授权复制账户
SQL>grant replication slave ,replication client on *.* to slave@'%' identified by 'Asqwop123#$';

### 查看主服务器的状态
SQL>show master status;

## 从
### 启动从服务器复制线程
SQL>grant all privileges on *.* to 'slave'@'%' identified by 'Asqwop123#$' with grant option;

SQL>change master to master_host='10.147.110.21', master_user='slave', 
master_password='Asqwop123#$', 
master_log_file='mysql-bin.000003', 
master_log_pos=510;
SQL>start slave; 

### 查看从服务器状态 
SQL>show slave status\G;


show processlist;

# MHA
### 创建工作目录
mkdir -p /home/mha/
### 下载源码包
### yum -y install wget unzip epel-release
### wget https://codeload.github.com/yoshinorim/mha4mysql-node/zip/master -O /usr/local/src/mha-node.zip
### wget https://codeload.github.com/yoshinorim/mha4mysql-manager/zip/master -O /usr/local/src/mha-manager.zip
### 解压
### unzip /usr/local/src/mha-manager.zip -d /usr/local/src
### unzip /usr/local/src/mha-node.zip -d /usr/local/src
### 安装perl及其相关依赖
yum -y install perl perl-ExtUtils-MakeMaker perl-ExtUtils-CBuilder perl-Parallel-ForkManager  perl-Config-Tiny perl-DBD-MySQL perl-Log-Dispatch 'perl(inc::Module::Install)' 'perl(Test::Without::Module)' 'perl(Log::Dispatch)'
### 编译节点端
cd /home/mha4mysql-node-master/
perl Makefile.PL 
make &&make install
### 编译管理端
cd /home/mha4mysql-manager-master/
perl Makefile.PL
make &&make install


cp /home/mha4mysql-manager-master/samples/conf/* /home/mha

vi /home/mha/app1.cnf
[server default]
manager_workdir=/var/log/masterha/app1
manager_log=/var/log/masterha/app1/manager.log
master_ip_failover_script=/home/mha4mysql-manager-master/samples/scripts/master_ip_failover
master_binlog_dir=/home/mysql_data/mysql
user=slave
password=Asqwop123#$
ssh_user=root

[server1]
hostname=10.147.110.21
candidate_master=1

[server2]
hostname=10.147.110.22
candidate_master=1
check_repl_delay=0

[server3]
hostname=10.147.110.23


masterha_check_ssh --conf=/home/mha/app1.cnf

masterha_check_repl --conf=/home/mha/app1.cnf

masterha_manager --conf=/home/mha/app1.cnf

masterha_check_status --conf=/home/mha/app1.cnf
