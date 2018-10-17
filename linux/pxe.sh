#!/bin/bash
#by pjl

GREEN='\E[1;32m' #绿
RED='\E[1;31m' #红
RES='\E[0m'

Init(){
	#关闭selinux
	setenforce 0
	sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/selinux/config

	#关闭防火墙
	systemctl stop firewalld
	systemctl disable firewalld >& /dev/null
	echo -e  "${GREEN}执行完毕~${RES}"
}

Create_SSH(){
	#设置ssh无密码登陆
	ssh-keygen -t rsa
	echo -e  "${GREEN}执行完毕~${RES}"
	ll ~/.ssh/
}

Copy_SSH(){
	read -p "请输入需要传输的ip地址：" sship
	ssh-copy-id -i ~/.ssh/id_rsa.pub root@$sship
	echo -e  "${GREEN}执行完毕~${RES}"
}

Install_PXE(){
	mkdir /root/yum_bak >& /dev/null
	mv -f /etc/yum.repos.d/* /root/yum_bak
	cat > /etc/yum.repos.d/pxe.repo <<- 'EOF'
	[pxe]
	name=pxe
	baseurl=file:///root/pxe
	enabled=1
	gpgcheck=0
	EOF
	yum install -y dhcp
	cat > /etc/dhcp/dhcpd.conf <<- 'EOF'
	  subnet 10.147.110.0 netmask 255.255.255.0 {
        range 10.147.110.100 10.147.110.200;
        option subnet-mask 255.255.255.0;
        default-lease-time 21600;
        max-lease-time 43200;
        next-server 10.147.110.11;
        filename "/pxelinux.0";
}
	EOF
	systemctl start dhcpd
	netstat -tunlp|grep dhcp
	yum install -y tftp-server
	sed -i '/\<disable/c\\tdisable\t\t\t= no' /etc/xinetd.d/tftp
	systemctl start tftp
	netstat -tunlp|grep 69
	yum install -y httpd
	systemctl start httpd
	#将CentOS解压后的镜像上传到/var/www/html
	\cp -f /root/yum_bak/* /etc/yum.repos.d/
}

date
echo -e "\n	${RED}MHA脚本${RES}
	${GREEN}1.${RES} 初始化系统环境${RED}[必需]
	${GREEN}2.${RES} 生成SSH密钥
	${GREEN}3.${RES} 复制SSH密钥
	${GREEN}4.${RES} 安装PXE服务
 "
echo && stty erase '^H' && read -p "请输入数字 [1-8]：" num
case "$num" in
	1)
	Init
	;;
	2)
	Create_SSH
	;;
	3)
	Copy_SSH
	;;
	4)
	Install_PXE
	;;
	*)
	echo "请输入正确的数字 [1-8]"
	;;
esac