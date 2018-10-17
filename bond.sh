#!/bin/bash
#创建一个名为bond0的链路接口
IP=10.147.111.11
GATE=10.147.111.254
ETH1=enp4s0f0
ETH2=enp4s0f1
#ETH3=eno3
#ETH4=eno4
modprobe bonding
cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
TYPE=Bond
NAME=bond0
BONDING_MASTER=yes
BOOTPROTO=static
USERCTL=no
ONBOOT=yes
IPADDR=$IP
PREFIX=24
GATEWAY=$GATE
BONDING_OPTS="mode=0 miimon=100"
EOF
#cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-bond1
#DEVICE=bond1
#TYPE=Bond
#NAME=bond1
#BONDING_MASTER=yes
#USERCTL=no
#BOOTPROTO=none
#ONBOOT=yes
#BONDING_OPTS="mode=0 miimon=100"
#EOF
cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH1
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$ETH1
ONBOOT=yes
MASTER=bond0
SLAVE=yes
EOF
cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH2
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$ETH2
ONBOOT=yes
MASTER=bond0
SLAVE=yes
EOF
#cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH3
#TYPE=Ethernet
#BOOTPROTO=none
#DEVICE=$ETH3
#ONBOOT=yes
#MASTER=bond1
#SLAVE=yes
#EOF
#cat <<EOF> /etc/sysconfig/network-scripts/ifcfg-$ETH4
#TYPE=Ethernet
#BOOTPROTO=none
#DEVICE=$ETH4
#ONBOOT=yes
#MASTER=bond1
#SLAVE=yes
#EOF
systemctl restart network
ping $GATE -c 1
#reboot
#modprobe bonding
#lsmod | grep bonding
#cat /proc/net/bonding/bond0
#https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/networking_guide/