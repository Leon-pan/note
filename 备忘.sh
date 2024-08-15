#JAVA_PATH
export JAVA_HOME=/usr/java/jdk1.8
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
#Windows JAVA_PATH
JAVA_HOME=JDK安装的绝对路径
CLASSPATH=.;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\lib\tools.jar;
Path=%JAVA_HOME%\bin;%JAVA_HOME%\jre\bin


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


#CDH
mysql5.7 → mysql5.6
oozie的主节点需要同时安装spark
hive、oozie在特定情况下需要单独复制jdbc包
zookeeper 缩减至 datanode[01-05]，不超过五台
kafka 调整java Heap Size of Broker
打印GC日志-Xloggc:/var/log/hbase/hbase-gc.log -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintAdaptiveSizePolicy
#获取指定服务的元数据信息
http://<cmserver>:7180/api/v10/clusters/<cluster_name>/services/<service_name>/config
#获取集群信息
curl -v -k -X GET -u <cm_admin_user>:<cm_admin_pass> http://<cmserver>:7180/api/v10/clusters/
#获取运行状态
curl -v -k -X GET -u <cm_admin_user>:<cm_admin_pass> http://<cmserver>:7180/api/v1/clusters/Cluster%201/services

#chrome插件
Check My Links、LinkMiner、Wappalyzer、FireShot、猫抓、ElasticSearch Head、Proxy SwitchyOmega、Tampermonkey


#Linux备份
cd /home
tar cvpzf backup.tar.gz / --exclude=/proc --exclude=/home/backup.tar.gz --exclude=/mnt --exclude=/sys


tar xvpfz backup.tar.gz -C /
mkdir /proc
mkdir /mnt
mkdir /sys

restorecon -Rv /


#rsync
#定时备份到远程服务器
rsync -avH --delete --log-file=/var/log/rsync.log /home/nexus/ 10.129.140.200:/back/nexus --exclude=sonatype-work/nexus/storage/snapshots/com/czcb --exclude=sonatype-work/nexus/storage/snapshots-TEST/com/czcb

#远程服务器根据定时备份每天生成一个增量备份
rsync -avH --delete --log-file=/var/log/rsync.log --link-dest /back/nexus /back/nexus /back/2023-12-11
rsync -avH --delete --log-file=/var/log/rsync.log --link-dest /back/2023-12-11 /back/nexus /back/2023-12-12
rsync -avH --delete --log-file=/var/log/rsync.log --link-dest /back/`date -d last-day +%F` /back/nexus /back/`date +%F`


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
#同步系统时钟
hwclock --systohc


#禁止数据库日志自动清理
mysql -e 'set global relay_log_purge=0' -p

crontab -l

0 0 15 * * /home/mha/purge_relay_log.sh


#hadoop复制因子
hadoop fsck /

hadoop fsck -locations

hadoop fs -setrep -w -R 2 /
hadoop fs -setrep 2 /

dfs.replication


#Oracle字符
select userenv('language') from dual;
select * from nls_database_parameters;

#Oracle删库
dbca -silent -deleteDatabase -sourceDB orcl -sid orcl -sysDBAUserName orcl -sysDBAPassword password


#Hadoop类测试
sudo -u hdfs hadoop jar /opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/hadoop-test-mr1.jar
sudo -u hdfs hadoop jar /opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/hadoop-examples.jar
#写
sudo -u hdfs hadoop jar /opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/hadoop-test-mr1.jar TestDFSIO -write -nrFiles 10 -fileSize 1000
#读
sudo -u hdfs hadoop jar /opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/hadoop-test-mr1.jar TestDFSIO -read -nrFiles 10 -fileSize 1000
#清理
sudo -u hdfs hadoop jar /opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/hadoop-test-mr1.jar TestDFSIO -clean
#π
sudo -u hdfs hadoop jar /opt/cloudera/parcels/CDH/lib/hadoop-0.20-mapreduce/hadoop-examples.jar pi 10 100


#hdfs拷贝
hadoop distcp -D ipc.client.fallback-to-simple-auth-allowed=true hdfs://source_path/ hdfs://destination_path/


#sqoop连接测试
sqoop list-databases --connect jdbc:mysql://10.1.20.201 --username root --password inteast.com


#CDH高可用
yum -y install cloudera-manager-server cloudera-manager-daemons


\cp -f mysql-connector-java-*.jar /usr/share/cmf/lib/

vi /etc/cloudera-scm-server/db.properties

sed -i '/^server_host=/c\server_host=10.1.20.54' /etc/cloudera-scm-agent/config.ini

先mysql主从复制，宕机后安装cms，再改agent地址并重启agent，删除cm，添加新的cm，解除所有宕机角色，将HDFS HA转为SNN


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


echo -e 'root     soft     nproc     65536\nroot     hard     nproc     65536\nroot     soft     nofile     65536\nroot     hard     nofile     65536' >> /etc/security/limits.conf
sed -i s/4096/65536/ /etc/security/limits.d/20-nproc.conf
ulimit -n
ulimit -u
/etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536

wget -t0 -c -r -np -k -L -p -nc --reject=html https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/5/

参数说明：
-t0：无限次重试
-c：继续执行上次终端的任务
-L：仅顺着关联的连接
-r：递归下载方式
-nc：文件存在时，下载文件不覆盖原有文件
-np：不查询父目录
-p：下载页面所需所有资源，如图片、声音等
-k：将下载内容中的链接转换为本地连接
--reject：排除html文件类型


#解压jar
jar -xvf x.jar BOOT-INF/classes/application.properties

#压缩jar
jar -uvf x.jar BOOT-INF/


#研发用户
useradd develop
passwd develop --stdin <<< develop
echo 'develop        ALL=(ALL)       NOPASSWD: ALL'  >> /etc/sudoers


#生成10个随机字符（包含数字，大写字母，小写字母，特殊字符）
< /dev/urandom tr -dc a-zA-Z0-9_+\~\!\@\#\$\%\^\&\*|head -c ${1:-10};echo


#iptables
yum install iptables-services
iptables -A INPUT -s 127.0.0.1/32 -p tcp --dport 9200 -j ACCEPT
iptables -A INPUT -s 10.33.60.237/32 -p tcp --dport 9200 -j ACCEPT
iptables -A INPUT -p tcp --dport 9200 -j DROP
#iptables -A DOCKER -s 127.0.0.1 -p tcp --dport 6379 -j ACCEPT
#iptables -A DOCKER -p tcp --dport 6379 -j DROP
#iptables -I INPUT -p tcp -s 172.0.0.0/8 -j DROP
#iptables -I INPUT -p tcp -s 172.1.0.0/24 -j ACCEPT
#禁止所有IP访问，但主动发起的不禁止,追加到最后
#iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#iptables -A INPUT -p tcp -j DROP
service iptables save
cat /etc/sysconfig/iptables


#nginx
yum install -y gcc gcc-c++ perl
./configure --prefix=/usr/local/nginx --with-stream --with-stream_realip_module --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-pcre=../pcre-8.44 --with-openssl=../openssl-1.1.1g --with-zlib=../zlib-1.2.11


#证书验证
openssl x509 -in cert.pem -noout -text


#find
find / -path /proc -a -prune -o -path /sys -a -prune -o -type f -exec grep -n3 "<?php"  {} \;


#jenkins
item = Jenkins.instance.getItemByFullName("your-job-name-here")
//THIS WILL REMOVE ALL BUILD HISTORY
item.builds.each() { build ->
  build.delete()
}
item.updateNextBuildNumber(1)


#利用跳板机打tunneling隧道
在自己笔记本上操作    ssh -R 21889:OPS1带外IP:22 root@公网跳板机 -p端口
远程支持人员  ssh root@公网跳板机 -p端口 
ssh root@localhost -p21889 ---21889自定义端口


#screen命令
screen -ls查看有没有在部署的切屏
screen -dmS 自定义切屏名称--创建切屏
screen -r 名称---已独享模式进入切屏
screen -x 自定义名称--进入切屏，ctrl+a+d是退出切屏，切屏里的操作就是退出了后台还能继续执行,ctrl+c+d 杀掉当前切屏  在切屏中exit，直接删除了那个切屏 ctrl+A+[---在切屏里往上下翻记录，按ESC退出翻动
screen -X -S 122128 quit----删除切屏


kubectl run --namespace test test --rm --tty -i --image registry.cn-hangzhou.aliyuncs.com/show/show_api-tool-core-backend:1.0 --command sh

kubectl --context work-work1 get pods

gcloud container images list --repository=k8s.gcr.io/metrics-server
gcloud container images list-tags k8s.gcr.io/metrics-server/metrics-server


#日志
docker logs --since 2021-08-28+08:00 --until 2021-08-29+08:00 ${containerid}
sed -n '/2021-08-28 09:25:55/,/2021-08-28 09:28:55/p'  ${logfie}

kubectl logs --since-time="2022-03-09T00:00:00+00:00" deploy/${deployname}

#传输
nc -l 8888|tar -xzf - -C /tmp

tar -czf - /etc |nc IP 8888


# 按VmSwap使用量对进程排序，输出进程名称、进程ID以及SWAP用量
$ for file in /proc/*/status ; do awk '/VmSwap|Name|^Pid/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 3 -n -r | head


#抓包
tcpdump udp -i eth0 -t dst port 53
-t不输出时间
-n不解析dns
-nn不解析域名和端口
-XX打印报文

#抓包的同时打印
tcpdump udp -i eth0 -U -t dst port 53 -w - | tee dump.cap | tcpdump -n -XX -r -


#扫描磁盘
for host in `ls /sys/class/scsi_host/`; do echo "- - -" > /sys/class/scsi_host/${host}/scan; done


#pssh
echo "StrictHostKeyChecking no" > ~/.ssh/config
pssh -h iplist -A "uptime"


#strace诊断
strace -Tttfvy
-T 显示每一调用所耗时间
-tt 在输出中的每一行加上时间信息
-f 跟踪由fork调用所产生的子进程
-v 输出所有系统调用


#查看TCP连接数
netstat -antp | awk 'NR>2 {print $6}' | sort | uniq -c


#查找10M以上的文件
find / -path /sys -prune -o -path /proc -prune -o -path /run -prune -o -type f -size +10M
#find / -path /proc -a -prune -o -path /sys -a -prune -o -path /run -a -prune -o -type f -size +10M


#统计空间大小除了系统目录
du -ah --exclude="proc" --exclude="run" --exclude="var" -d1 /


#筛选除ppid为2的进程
ps -ef | awk '{if($3!=2)print}'


#列出所有非系统进程名
ps -eo ppid,cmd | awk '{if($1!=2)print}' | awk '{$1="";print}'
ps -eo ppid,cmd | awk '{if($1!=2)print}' | awk '{$1="";print}' | awk '{print $1}' | sort | uniq -c


#目标值相加
awk '{sum+=$1}END{print sum}'


#查看目标文件超过150字符的行
cat data.txt|grep ".\{150\}"


#获取目标文件最长的一行，显示10000个字符
awk '{if (length(max)<length()) max=$0}END{print max}' data.txt|cut -c 1-10000


#vi dos转unix
set ff=unix