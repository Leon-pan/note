本文参照教程如下：
https://blog.csdn.net/as763190097/article/details/71669692
https://blog.csdn.net/shiyu1157758655/article/details/55253132
http://blog.itpub.net/26230597/viewspace-1432637/



#1.修改hosts
vi /etc/hosts


#2.关闭防火墙
systemctl stop firewalld
systemctl disable firewalld


#3.关闭selinux
setenforce 0
sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/selinux/config


#4.创建用户
groupadd oinstall
groupadd dba
useradd -g oinstall -G dba -d /u01/oracle oracle
passwd oracle


#5.安装oracle所需依赖，同时可以将oracle的安装文件上传到/u01/oracle/下
yum -y install binutils compat-libcap1 compat-libstdc++-33 compat-libstdc++-33*i686 compat-libstdc++-33*.devel compat-libstdc++-33 compat-libstdc++-33*.devel gcc gcc-c++ glibc glibc*.i686 glibc-devel glibc-devel*.i686 ksh libaio libaio*.i686 libaio-devel libaio-devel*.devel libgcc libgcc*.i686 libstdc++ libstdc++*.i686 libstdc++-devel libstdc++-devel*.devel libXi libXi*.i686 libXtst libXtst*.i686 make sysstat unixODBC unixODBC*.i686 unixODBC-devel unixODBC-devel*.i686


#6.修改系统参数
echo -e 'fs.file-max = 6815744\nkernel.shmmax = 536870912\nkernel.sem = 250 32000 100 128\nnet.core.rmem_default = 262144\nnet.core.wmem_default = 262144' >> /etc/sysctl.conf
sysctl -p

echo -e 'oracle　　　　　soft     nproc    2047\noracle              hard    nproc    16384  \noralce              soft     nofile    1024\noracle              hard    nofile     65536  \noracle              soft     stack     10240 ' >> /etc/security/limits.conf


#7.创建oracle安装目录
mkdir -p /u01/oracle_11/app/
mkdir -p /u01/oracle_11/oraInventory/
chown -R oracle:oinstall /u01/oracle_11/app/
chmod -R 775 /u01/oracle_11/app/
chown -R oracle:oinstall /u01/oracle_11/oraInventory/
chmod -R 775 /u01/oracle_11/oraInventory/



#8.修改环境变量,ORACLE_SID根据需要更改！！！
echo -e 'export ORACLE_BASE=/u01/oracle_11/app/oracle\nexport ORACLE_SID=orcl\nexport ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1\nexport SQLPATH=/u01/oracle/labs\nexport PATH=$ORACLE_HOME/bin:$PATH' >> /u01/oracle/.bash_profile
source /u01/oracle/.bash_profile

echo -e 'session required /lib64/security/pam_limits.so\nsession required pam_limits.so' >> /etc/pam.d/login

echo -e 'if [ $USER = "oracle" ]; then\n    if [ $SHELL = "/bin/ksh" ]; then\n        ulimit -p 16384\n        ulimit -n 65536  \n    else\n        ulimit -u 16384 -n 65536  \n    fi\nfi' >> /etc/profile
source /etc/profile



#9.更改database安装文件的所有者和权限
chown -R oracle:oinstall /u01/oracle/database
chmod -R 755 /u01/oracle/database



#10.增大虚拟内存
mount -o size=8G -o nr_inodes=1000000 -o noatime,nodiratime -o remount /dev/shm
echo -e 'tmpfs                   /dev/shm                tmpfs   defaults,size=8G        0 0' >> /etc/fstab
mount -o remount /dev/shm



#11.复制出来一份静默安装的响应文件response，同时用修改过的响应文件替换复制出来response（响应文件#mark标注的地方按需更改）
cp -R /u01/oracle/database/response /u01/oracle/



#12.切换oracle，准备安装
su - oracle
cd /u01/oracle/database
./runInstaller -silent -responseFile /u01/oracle/response/db_install.rsp
#当安装界面出现如下信息的时候，打开另一个终端窗口以root执行下面的脚本
/u01/oracle_11/oraInventory/orainstRoot.sh
/u01/oracle_11/app/oracle/product/11.2.0/dbhome_1/root.sh
#执行完上面的脚本后回到安装终端窗口按下Enter键以继续



#13.启动监听并安装实例（备库可以选择不安装实例）
cd /u01/oracle/response
netca /silent -responsefile /u01/oracle/response/netca.rsp
lsnrctl status

#安装实例
dbca -silent -responseFile /u01/oracle/response/dbca.rsp



#14.主库dataguard配置
#注意实例名不同，路径也不同
mkdir -p /u01/oracle_11/app/oracle/oradata/orcl/redo
mkdir -p /u01/oracle_11/app/oracle/oradata/orcl/datafile

#su  - oracle

$sqlplus / as sysdba
#查看数据库是否运行在归档模式：
SQL>archive log list;

#若不处于归档模式（Archive Mode），先关闭数据库
SQL>shutdown immediate;

#启动数据库到mount状态下
SQL>startup mount;

#查询数据库是否是MOUNTED状态
SQL>select open_mode from v$database;

#把数据库修改为归档模式并打开数据库
SQL>alter database archivelog;
SQL>alter database open;

#查看数据库是否运行在归档模式：
SQL>archive log list;

#更改数据库为强制记录日志状态
SQL>alter database force logging;

#检查是否为强制记录状态
SQL>select name,log_mode,force_logging from v$database;

#查询主库当前redo logfile的数量（standby logfile的数量和大小均要与redo logfile相同）
SQL>select thread#,group#,members,bytes/1024/1024 from v$log;

#创建同样数量和大小的standby logfile
#注意实例名不同，路径也不同
SQL>alter database add standby logfile group 11('/u01/oracle_11/app/oracle/oradata/orcl/redo/redo11_stb01.log') size 50M;
SQL>alter database add standby logfile group 12('/u01/oracle_11/app/oracle/oradata/orcl/redo/redo12_stb01.log') size 50M;
SQL>alter database add standby logfile group 13 ('/u01/oracle_11/app/oracle/oradata/orcl/redo/redo13_stb01.log')size 50M;

#检查是否创建成功
SQL>select group#,thread#,sequence#,archived,status from v$standby_log;

#查看数据库口令文件的使用模式的值是否EXCLUSIVE
SQL>show parameter remote_login_passwordfile;

#如果不是，执行以下命令进行设置，并且重启数据库，使其生效：
SQL>alter system set remote_login_passwordfile=EXCLUSIVE scope=spfile;
SQL>shutdown immediate;
SQL>startup;

#主库参数配置，dg_config填写的是主备库的db_unique_name
SQL>show parameter db_unique_name;
SQL>alter system set log_archive_config='dg_config=(orcl,orcls)' scope=spfile;

#设置归档日志的存放位置
#注意实例名不同，路径也不同，db_unique_name写的是show parameter db_unique_name查询到的结果
SQL>alter system set log_archive_dest_1='location=/u01/oracle_11/app/oracle/oradata/orcl/archivelog valid_for=(all_logfiles,all_roles) db_unique_name=orcl' scope=spfile;
#第一个ocrls是备库tnsname.ora的连接名，第二个ocrls是备库的DB_UNIQUE_NAME
SQL>alter system set log_archive_dest_2='SERVICE=orcls ASYNC VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=orcls' scope=spfile;

#启用设置的日志路径
SQL>alter system set log_archive_dest_state_1=enable scope=spfile;
SQL>alter system set log_archive_dest_state_2=enable scope=spfile;

#设置归档日志进程的最大数量
SQL>alter system set log_archive_max_processes=30 scope=both;

#设置standby库从哪个数据库获取归档日志（只对standby库有效，在主库上设置是为了在故障切换后，主库可以成为备库使用）
SQL>alter system set fal_server=orcls scope=both;

#设置文件管理模式，此项设置为自动，不然在主库创建数据文件后，备库不会自动创建
SQL>alter system set standby_file_management=auto scope=spfile;

#启用Oracle_Managed Files文件管理功能
#注意SID不同，路径也不同
SQL>alter system set db_create_file_dest='/u01/oracle_11/app/oracle/oradata/orcl/datafile' scope=spfile;

#如果主备库文件的存放路径不同，还需要设置以下两个参数，相同则不需（这步路径的先后顺序在主备库上的设置是不同的）
#SQL>alter system set db_file_name_convert='/u01/oracle_11/app/oracle/oradata/orcls/datafile','/u01/oracle_11/app/oracle/oradata/orcl/datafile','/u01/oracle_11/app/oracle/oradata/orcls/tempfile','/u01/oracle_11/app/oracle/oradata/orcl/tempfile' scope=spfile;
#SQL>alter system set log_file_name_convert='/u01/oracle_11/app/oracle/oradata/orcls/redo','/u01/oracle_11/app/oracle/oradata/orcl/redo' scope=spfile;

#生成配置文件
SQL>create pfile from spfile;



#15.备库dataguard配置

#su - oracle

#将主库的密码文件传输给备库，删除备库原有的密码文件，将新传的文件重命名为删除的密码文件
cd /u01/oracle_11/app/oracle/product/11.2.0/dbhome_1/dbs
scp orapworcl 10.1.20.124:/u01/oracle_11/app/oracle/product/11.2.0/dbhome_1/dbs/

#这步主库备库都需要配置，两边所配置的HOST、GLOBAL_DBNAME、SID_NAME、SERVICE_NAME等是不同的
cd $ORACLE_HOME/network/admin

#修改listener.ora文件
vi listener.ora

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = server.net)(PORT = 1521))
    )
  )

ADR_BASE_LISTENER = /u01/oracle_11/app/oracle

SID_LIST_LISTENER=
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = orcl)
      (ORACLE_HOME = /u01/oracle_11/app/oracle/product/11.2.0/dbhome_1)
      (SID_NAME = orcl)
    )
  )

#修改tnsnames.ora文件，没有则创建
vi tnsnames.ora
ORCL =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = server.net)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl)
    )
  )

ORCLS =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = agent1.net)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcls)
    )
  )

#重启监听
$lsnrctl stop
$lsnrctl start

#测试是否成功，若成功会显示OK (0 msec)字样
$tnsping orcl
$tnsping orcls

#备库需要创建的文件目录
mkdir -p $ORACLE_BASE/admin/orcls/adump
mkdir -p $ORACLE_BASE/admin/orcls/dpdump
mkdir -p /u01/oracle_11/app/oracle/oradata/orcls/redo
mkdir -p /u01/oracle_11/app/oracle/oradata/orcls/datafile/
mkdir -p /u01/oracle_11/app/oracle/oradata/orcls/control/
mkdir -p /u01/oracle_11/app/oracle/flash_recovery_area/orcls/control
mkdir -p /u01/oracle_11/app/oracle/flash_recovery_area/ORCLS/onlinelog/

#备库使用主库经修改的pfile（initorcl.ora）文件重命名为initorcls.ora放置在/u01/oracle_11/app/oracle/product/11.2.0/dbhome_1/dbs/路径下，并使用其手动建库
$sqlplus / as sysdba

#指定pfile文件的路径
SQL>startup nomount pfile='$ORACLE_HOME/dbs/initorcls.ora'

#根据pfile创建spfile
SQL>create spfile from pfile;

#从spfile启动
SQL>shutdown immediate;
SQL>exit
$sqlplus / as sysdba

#启动并检查db_unique_name
SQL>startup nomount;
SQL>show parameter db_unique_name;

#使用rman同步主备库（在备库上操作）
$rman target sys/password@orcl auxiliary sys/password@orcls;
RMAN>duplicate target database for standby from active database nofilenamecheck;

#复制完成后，打开数据库开启实时同步
$sqlplus / as sysdba
SQL>alter database archivelog;
SQL>alter database open;
SQL>archive log list;
SQL>alter database recover managed standby database using current logfile disconnect from session;

#复制完成后，最好能够将主库shutdown一下再startup
SQL>SELECT SWITCHOVER_STATUS FROM V$DATABASE;
状态RESOLVABLE GAP为正在重做日志传输，稍等片刻再执行上一条命令出现TO STANDBY即为成功

#查看数据库状态（主库应为PRIMARY，备库为STANDBY）
SQL>select database_role from v$database;

#检查归档日志是否能正常传输（日志的序号必须是一样的）
SQL>select SEQUENCE#, FIRST_TIME, NEXT_TIME, APPLIED, ARCHIVED from V$ARCHIVED_LOG;

#切换日志测试
主库
SQL>alter system switch logfile;
SQL>select SEQUENCE#, FIRST_TIME, NEXT_TIME, APPLIED, ARCHIVED from V$ARCHIVED_LOG;

备库
SQL>select SEQUENCE#, FIRST_TIME, NEXT_TIME, APPLIED, ARCHIVED from V$ARCHIVED_LOG;
SQL>select max(sequence#)from v$archived_log;





#可能用到的命令
#SQL>create user test identified by test;
#SQL>grant connect, resource to test;
#SQL>show parameter spfile;
#SQL>show parameter;
#SQL>show parameter LOG_ARCHIVE_DEST_2
#SQL>SELECT SWITCHOVER_STATUS FROM V$DATABASE;
#SQL>select open_mode,database_role,switchover_status from v$database;
#cp /u01/oracle_11/app/oracle/admin/orcl/pfile/init.ora.* /u01/oracle_11/app/oracle/product/11.2.0/dbhome_1/dbs/
#mv /u01/oracle_11/app/oracle/product/11.2.0/dbhome_1/dbs/init.ora.* /u01/oracle_11/app/oracle/product/11.2.0/dbhome_1/dbs/initorcl.ora

export ORACLE_SID='orcls2'
startup nomount pfile='/u01/oracle_11/app/oracle/product/11.2.0/dbhome_1/dbs/initorcls2.ora'
rman target sys/password@orcl1 auxiliary sys/password@orcls2;

