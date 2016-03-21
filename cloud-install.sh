##Opennebula 4.14 Install script v.01 beta
##Note
#Install it with your own risk.
#This script is in beta stage

hostnamectl set-hostname nebula.cloud.local
yum install epel-release -y
cat << EOT > /etc/yum.repos.d/opennebula.repo
[opennebula]
name=opennebula
baseurl=http://downloads.opennebula.org/repo/4.14/CentOS/7/x86_64/
enabled=1
gpgcheck=0
EOT
yum install net-tools gcc sqlite-devel mysql-devel openssl-devel curl-devel rubygem-rake libxml2-devel libxslt-devel patch expat-devel gcc-c++  wget git opennebula-server openssh openssh-server opennebula-sunstone opennebula-node-kvm -y
echo "\1\ny\n\n" |/usr/share/one/install_gems

sed -i 's/:host: 127.0.0.1/:host: 0.0.0.0/g' /etc/one/sunstone-server.conf
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl enable opennebula
systemctl start opennebula
systemctl enable opennebula-sunstone
systemctl start opennebula-sunstone


cat << EOT > /var/lib/one/.ssh/config
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOT
chown oneadmin:oneadmin /var/lib/one/.ssh/config
chmod 600 /var/lib/one/.ssh/config

systemctl enable messagebus.service
systemctl start messagebus.service
systemctl enable libvirtd.service
systemctl start libvirtd.service
systemctl enable nfs.service
systemctl start nfs.service

##Network Settings


touch /etc/sysconfig/network-script/ifcfg-br0
cp /etc/sysconfig/network-script/ifcfg-enp3s0 /etc/sysconfig/network-script/ifcfg-enp3s0.bak
cat /dev/null > /etc/sysconfig/network-script/ifcfg-enp3s0
echo "
DEVICE=enp3s0
BOOTPROTO=none
NM_CONTROLLED=no
ONBOOT=yes
TYPE=Ethernet
BRIDGE=br0
" >> /etc/sysconfig/network-script/ifcfg-enp3s0

echo "
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=dhcp
NM_CONTROLLED=no
" >> /etc/sysconfig/network-script/ifcfg-br0

systemctl restart network.service

##Adding ssh public key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQCBYlX1NxLs7o++ySQRyuPY5dMdeAIoTh7XGE1Sp5yeaYz7AGegg8ov8jFDf7BtCiwkqboiuxPId38RFYCDLoSjbhzcVzoeMX87b/EcTJP+4DjQqe4lbfNmefK0t7qYPTvlTdK3gQEi9h5uw25RZmo2JqaJ+KoWJqU82es3bBKgEQ== imported-openssh-key" >> /root/.ssh/authorized_keys
systemctl restart sshd
cat /dev/null > /etc/motd

PWD='cut -c 10-50 one_auth'
IP='hostname -i'

echo "*****************************************************" >> /etc/motd
echo "       Opennebula 4.14 OS by James PS             " >> /etc/motd
echo "        https://github.com/jamesarems            " >> /etc/motd
echo "                 (c) 2016           " >> /etc/motd
echo "*****************************************************" >> /etc/motd
echo "    Username : oneadmin   " >> /etc/motd
echo "    Password : $PWD      "  >> /etc/motd
echo "    Web UI : http://$IP:9869     " >> /etc/motd
echo "    NOTE: If you are not getting network connection, then you have to configure network manually     " >> /etc/motd
echo "    Details available on https://github.com/jamesarems/opennebula-distro" >> /etc/motd
echo "######################################################" >> /etc/motd
