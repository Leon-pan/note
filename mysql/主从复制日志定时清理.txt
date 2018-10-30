#设置relay log的清除方式（在每个slave节点上）
MHA在发生切换的过程中，从库的恢复过程中依赖于relay log的相关信息，所以这里要将relay log的自动清除设置为OFF，采用手动清除relay log的方式。在默认情况下，从服务器上的中继日志会在SQL线程执行完毕后被自动删除。但是在MHA环境中，这些中继日志在恢复其他从服务器时可能会被用到，因此需要禁用中继日志的自动删除功能。定期清除中继日志需要考虑到复制延时的问题。在ext3的文件系统下，删除大的文件需要一定的时间，会导致严重的复制延时。为了避免复制延时，需要暂时为中继日志创建硬链接，因为在linux系统中通过硬链接删除大文件速度会很快。
[root@agent1 ~]# mysql -e 'set global relay_log_purge=0' -p
[root@agent2 ~]# mysql -e 'set global relay_log_purge=0' –p

#编写清理脚本并添加执行权限（在每个slave节点上）
[root@agent1 ~]# vi /home/mha/purge_relay_log.sh
#!/bin/bash
user=root
passwd=密码
port=3306
purge='/usr/local/bin/purge_relay_logs'

if [ ! -d $log_dir ]
then
   mkdir $log_dir -p
fi

$purge --user=$user --password=$passwd --disable_relay_log_purge --port=$port  >> /var/log/purge_relay_logs.log 2>&1
[root@agent1 ~]# chmod +x /home/mha/purge_relay_log.sh

#添加定时任务（在每个slave节点上）
[root@agent1 ~]# crontab –e
0 0 15 * * /home/mha/purge_relay_log.sh		//即在每个月的15号0点清理日志