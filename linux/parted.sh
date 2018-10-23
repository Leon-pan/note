#GPT分区大于2T
parted /dev/sda mkpart ext4 543G 3.7T
parted /dev/sdb mklabel gpt mkpart ext4 0% 100%
lsblk


#创建挂载目录
mkdir /data{01..12}
ls /


#格式化文件系统
mkfs.ext4 /dev/sda4
mkfs.ext4 /dev/sdb1
lsblk


#挂载
mount /dev/sda4 /data01
mount /dev/sdb1 /data02
df -Th


#写入分区表
cat >> /etc/fstab <<- 'EOF'
/dev/sda4 /data01       ext4    defaults        0 0
/dev/sdb1 /data02       ext4    defaults        0 0
EOF
partprobe


#MBR分区小于2T
fdisk /dev/sda <<- 'EOF'
n




w
EOF


#创建挂载目录
mkdir /data{01..09}
ls /


#格式化文件系统
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sdb1
lsblk


#挂载
mount /dev/sda3 /data01
mount /dev/sdb1 /data02
df -Th


#写入分区表
cat >> /etc/fstab <<- 'EOF'
/dev/sda3 /data01       ext4    defaults        0 0
/dev/sdb1 /data02       ext4    defaults        0 0
EOF
partprobe