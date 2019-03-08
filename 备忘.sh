#JAVA_PATH
export JAVA_HOME=/usr/java/jdk1.8
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH


1.高版本无法识别URL中的中文
解决方法：在tomcat目录下的conf/catalina.properties中，找到最后注释掉的一行 ＃tomcat.util.http.parser.HttpParser.requestTargetAllow=|，改成tomcat.util.http.parser.HttpParser.requestTargetAllow=|{}，表示把｛｝放行
2.页面中文显示乱码
解决方法：在tomcat目录下conf/server.xml中，找到  
<Connector port="8888" protocol="HTTP/1.1"
               connectionTimeout="20000"
redirectPort="8443"/>
在8443后面添加 URIEncoding="UTF-8" 
3.去掉tomcat访问项目路径
解决方法：在tomcat目录下conf/server.xml中，找到
<Host name="localhost"  appBase="webapps" unpackWARs="true" autoDeploy="true">
在下面添加一行<Context path="" docBase="web" reloadable="true" /> docBase里面写的是项目名
4.tomcat指定jdk版本路径
编辑bin/catalina.sh
编辑bin/setclasspath.sh
在文件开头的空白处加上如下两句
export JAVA_HOME=/usr/java/jdk1.8/
export JRE_HOME=/usr/java/jdk1.8//jre
5.tomcat开机自启
vi /home/apache-tomcat-8.0.53/bin/startup.sh
export JAVA_HOME=/usr/java/jdk1.8
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
#export CATALINA_HOME=/home/apache-tomcat-8.0.53
vi /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local


Asqwop123#$

grant all privileges on *.* to 'root'@'%' identified by 'Asqwop123#$';

create database hive default character set utf8;
grant all privileges on hive.* to 'hive'@'%' identified by 'hive_123#$';
grant all privileges on hive.* to 'hive'@'localhost' identified by 'hive_123#$';

create database monitor default character set utf8;
grant all privileges on monitor.* to 'monitor'@'%' identified by 'monitor_123#$';
grant all privileges on monitor.* to 'monitor'@'localhost' identified by 'monitor_123#$';

create database oozie default character set utf8;
grant all privileges on oozie.* to 'oozie'@'%' identified by 'oozie_123#$';
grant all privileges on oozie.* to 'oozie'@'localhost' identified by 'oozie_123#$';

create database hue default character set utf8;
grant all privileges on hue.* to 'hue'@'%' identified by 'hue_123#$';
grant all privileges on hue.* to 'hue'@'localhost' identified by 'hue_123#$';

create database sentry default character set utf8;
grant all privileges on sentry.* to 'sentry'@'%' identified by 'sentry_123#$';
grant all privileges on sentry.* to 'sentry'@'localhost' identified by 'sentry_123#$';


#CDH
mysql5.7 → mysql5.6
oozie的主节点需要同时安装spark
hive、oozie在特定情况下需要单独复制jdbc包
zookeeper 缩减至 datanode[01-05]，不超过五台
kafka 调整java Heap Size of Broker
打印GC日志-Xloggc:/var/log/hbase/hbase-gc.log -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintAdaptiveSizePolicy


#Linux备份
cd /home
tar cvpzf backup.tar.gz / --exclude=/proc --exclude=/home/backup.tar.gz --exclude=/mnt --exclude=/sys


tar xvpfz backup.tar.gz -C /
mkdir /proc
mkdir /mnt
mkdir /sys

restorecon -Rv /


nginx日志分割？

广西华为虚拟化10.147.101.200



#PXE安装
label linux
  menu label ^Install CentOS 7 local
  kernel vmlinuz
  append initrd=initrd.img inst.repo=http://192.168.197.128/CentOS7 devfs=nomount




  subnet 192.168.197.0 netmask 255.255.255.0 {
        range 192.168.197.150 192.168.197.200;
        option subnet-mask 255.255.255.0;
        default-lease-time 21600;
        max-lease-time 43200;
        next-server 192.168.197.128;
        filename "/pxelinux.0";
}

#Linux iso挂载
mount -o loop -t iso9660 /home/CentOS-7-x86_64-Everything-1708.iso /media
vi /etc/yum.repos.d/CentOS-Media.repo
yum --disablerepo=\* --enablerepo=c7-media [command]

#时间设置
timedatectl


hwclock  --show
hwclock --systohc


#数据库日志清理
mysql -e 'set global relay_log_purge=0' -p

crontab -e


0 0 15 * * /home/mha/purge_relay_log.sh


#hadoop复制因子
hadoop fsck /

hadoop fsck -locations

hadoop fs -setrep -w -R 2 /

dfs.replication


#Oracle字符
select userenv('language') from dual;
select * from nls_database_parameters;

#Oracle删库
dbca -silent -deleteDatabase -sourceDB orcl -sid orcl -sysDBAUserName orcl -sysDBAPassword password


#Hadoop类测试
/opt/cloudera/parcels/CDH-5.14.2-1.cdh5.14.2.p0.3/lib/hadoop-0.20-mapreduce/hadoop-examples-2.6.0-mr1-cdh5.14.2.jar
/opt/cloudera/parcels/CDH-5.14.2-1.cdh5.14.2.p0.3/lib/hadoop-0.20-mapreduce/hadoop-examples.jar
/opt/cloudera/parcels/CDH-5.14.2-1.cdh5.14.2.p0.3/lib/hadoop-0.20-mapreduce/hadoop-examples-mr1.jar
/opt/cloudera/parcels/CDH-5.14.2-1.cdh5.14.2.p0.3/lib/hadoop-0.20-mapreduce/hadoop-test-2.6.0-mr1-cdh5.14.2.jar
/opt/cloudera/parcels/CDH-5.14.2-1.cdh5.14.2.p0.3/lib/hadoop-0.20-mapreduce/hadoop-test-mr1.jar


sudo hadoop jar /opt/cloudera/parcels/CDH-5.14.2-1.cdh5.14.2.p0.3/lib/hadoop-0.20-mapreduce/hadoop-test-mr1.jar TestDFSIO -write -nrFiles 10 -fileSize 1000


sudo hadoop jar /opt/cloudera/parcels/CDH-5.14.2-1.cdh5.14.2.p0.3/lib/hadoop-0.20-mapreduce/hadoop-test-mr1.jar TestDFSIO -read -nrFiles 10 -fileSize 1000


sudo hadoop jar /opt/cloudera/parcels/CDH-5.14.2-1.cdh5.14.2.p0.3/lib/hadoop-0.20-mapreduce/hadoop-test-mr1.jar TestDFSIO -clean
#hdfs拷贝
hadoop distcp -D ipc.client.fallback-to-simple-auth-allowed=true hdfs://source_path/ hdfs://destination_path/


#Kerberos认证
kadmin.local

listprincs

kadmin.local -q "addprinc HTTP"

kinit hdfs
kinit -kt /path user

klist

kadmin.local:  modprinc -maxrenewlife 90day krbtgt/EXAMPLE.COM@EXAMPLE.COM

kadmin.local:  modprinc -maxrenewlife 90day +allow_renewable hue/namenode01.hadoop@EXAMPLE.COM

#CDH高可用
yum -y install cloudera-manager-server cloudera-manager-daemons


\cp -f mysql-connector-java-*.jar /usr/share/cmf/lib/

vi /etc/cloudera-scm-server/db.properties

sed -i '/^server_host=/c\server_host=10.1.20.54' /etc/cloudera-scm-agent/config.ini

先mysql主从复制，宕机后安装cms，再改agent地址并重启agent，删除cm，添加新的cm，解除所有宕机角色，将HDFS HA转为SNN


梅西商贸地址
36.24.187.209:9020
http://qdj1212.zicp.io:9020/mxsmsystem


梅西商贸海宁服务器地址
122.225.95.186

远程桌面连接时发生身份验证错误
登录实例或者本地计算机。
以管理员身份运行以下 PowerShell 脚本。
New-Item -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name CredSSP -Force
New-Item -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP -Name Parameters -Force
Get-Item -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters | New-ItemProperty -Name AllowEncryptionOracle -Value 2 -PropertyType DWORD -Force
重启实例或者本地计算机。


#recover.bat
forfiles /p "D:\广西\app\apache-tomcat-8.0.53\webapps" /s /m *.* /c "cmd /c del /F /S /Q @path
forfiles /p "D:\广西\app\apache-tomcat-8.0.53\webapps" /s /m hldc.war /c "cmd /c del /F /S /Q @path


#GitLab升级
yum install gitlab-ce-9.5.10-ce.0.el7.x86_64

yum install gitlab-ce-10.8.7-ce.0.el7.x86_64

yum install gitlab-ce-11.3.4-ce.0.el7.x86_64

vi /etc/gitlab/gitlab.rb
gitlab_rails['gitlab_default_projects_features_builds'] = false
gitlab-ctl reconfigure
设置取消持续集成和部署

更改存储路径
gitlab-ctl stop
mkdir /home/git
rsync -av /var/opt/gitlab/git-data/repositories /home/git/git-data/
vi /etc/gitlab/gitlab.rb
git_data_dirs({ "default" => { "path" => "/home/git/git-data", 'gitaly_address' => 'unix:/var/opt/gitlab/gitaly/gitaly.socket' } })
gitlab-ctl upgrade
ls /home/git/git-data/
gitlab-ctl start


#排序命令
grep 'org.apache.hadoop.hbase.regionserver.HRegionServer: datanode07.hadoop' /home/log/hbase/hbase-cmf-hbase-REGIONSERVER-datanode07.hadoop.log.out |grep '2019-01-02 05'| awk -F 'of' '{print$2}' | awk -F ',' '{print$1}'|sort |uniq -c

#left join
SELECT
	a.lzly,
	a.qwlzrq,
	b.NAME
FROM
	a
LEFT JOIN b ON a.create_by = b.id;

#HBase社区推荐java参数
MASTER  -Xmx16g -Xms16g -Xmn4g -Xss256k -XX:MaxPermSize=256m -XX:SurvivorRatio=2 -XX:+UseParNewGC -XX:ParallelGCThreads=12 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=16 -XX:+CMSParallelRemarkEnabled -XX:MaxTenuringThreshold=15 -XX:+UseCMSCompactAtFullCollection  -XX:+UseCMSInitiatingOccupancyOnly  -XX:CMSInitiatingOccupancyFraction=70 -XX:-DisableExplicitGC -XX:+HeapDumpOnOutOfMemoryError -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -Xloggc:/app/hbase/log/gc/gc-hbase-hmaster-`hostname`.log"

REGIONSERVER  -XX:+UseG1GC -Xmx30g -Xms30g -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:-ResizePLAB -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:ParallelGCThreads=16 -XX:ConcGCThreads=8 -XX:G1HeapWastePercent=3 -XX:InitiatingHeapOccupancyPercent=35 -XX:G1MixedGCLiveThresholdPercent=85 -XX:MaxDirectMemorySize=25g -XX:G1NewSizePercent=1 -XX:G1MaxNewSizePercent=15 -verbose:gc -XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCApplicationStoppedTime -XX:+PrintHeapAtGC -XX:+PrintGCDateStamps -XX:+PrintAdaptiveSizePolicy -XX:PrintSafepointStatisticsCount=1 -XX:PrintFLSStatistics=1 -Xloggc:/app/hbase/log/gc/gc-hbase-regionserver-`hostname`.log"

REGIONSERVER -Xmx32g -Xms32g -Xmn6g -Xss256k -XX:MaxPermSize=384m -XX:SurvivorRatio=6 -XX:+UseParNewGC -XX:ParallelGCThreads=10 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=16 -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 -XX:CMSMaxAbortablePrecleanTime=5000 -XX:CMSFullGCsBeforeCompaction=5 -XX:+CMSClassUnloadingEnabled -XX:+HeapDumpOnOutOfMemoryError

REGIONSERVER -Xmx12g -Xms12g -Xmn3g  -Xss256k -XX:MetaspaceSize=128m -XX:SurvivorRatio=6 -XX:+UseParNewGC  -XX:ParallelGCThreads=10 -XX:+UseConcMarkSweepGC -XX:ParallelCMSThreads=16 -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 -XX:CMSMaxAbortablePrecleanTime=500 -XX:CMSFullGCsBeforeCompaction=5 -XX:+CMSClassUnloadingEnabled -XX:+HeapDumpOnOutOfMemoryError

#Hbase G1垃圾回收策略
-XX:+UseG1GC
-XX:+UnlockExperimentalVMOptions    //解锁jdk低版本中一些参数
-XX:MaxGCPauseMillis=100    //设置一个期望的最大GC暂停时间，这是一个柔性的目标，JVM会尽力去达到这个目标
-XX:-ResizePLAB     //线程较多时关闭PLAB的大小调整，以避免大量的线程通信所导致的性能下降
-XX:+ParallelRefProcEnabled     //并行引用处理，减少remark阶段处理发现的引用过程时间
-XX:+AlwaysPreTouch     //为JVM分配指定的内存大小，而不是等JVM访问这些内存的时候,才真正分配
-XX:ParallelGCThreads=33    //并行垃圾线程数,8+（逻辑处理器-8）（5/8）该公式由Oracle推荐。
-XX:ConcGCThreads=16     //并发标记阶段线程数,默认情况下G1垃圾收集器会将这个线程总数设置为1/4的ParallelGCThreads
-XX:G1HeapWastePercent=3    //可回收的内存超过这个比例时，开始mixed gc的周期
-XX:InitiatingHeapOccupancyPercent=35   //如果整个堆的使用率超过这个值，G1会触发一次并发周期。
-XX:G1MixedGCLiveThresholdPercent=85    //如果一个分区中的存活对象比例超过这个值，就不会被挑选为垃圾分区，这个参数的值越大，某个分区越容易被当做是垃圾分区
-XX:MaxDirectMemorySize=25g      //堆外内存最大大小，默认与最大堆栈大小相同
-XX:G1NewSizePercent=3      //新生代占堆的最小比例
-XX:G1MaxNewSizePercent=20      //新生代占堆的最大比例
-XX:+PrintGC
-XX:+PrintGCDetails
-XX:+PrintGCApplicationStoppedTime
-XX:+PrintHeapAtGC
-XX:+PrintGCDateStamps
-XX:+PrintAdaptiveSizePolicy
-XX:PrintSafepointStatisticsCount=1
-XX:PrintFLSStatistics=1
-Xloggc:/var/log/hbase/hbase-gc-%t-%p.log


echo -e 'root　　　　　soft     nproc    65536\nroot              hard    nproc    65536  \nroot              soft     nofile    65536\nroot              hard    nofile     65536' >> /etc/security/limits.conf