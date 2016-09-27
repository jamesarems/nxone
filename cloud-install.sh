##Opennebula 4.14 Install script v.01 beta
##Note
#Install it with your own risk.
#This script is in beta stage

if [ "$1" == "setup" ]; then

clear
echo "OpenNebula Setup 4.14 is $(tput setaf 1)depreciated$(tput sgr0) "
echo "Please use$(tput setaf 3)nxsetup$(tput sgr0)for latest version. "

sleep 5s
echo "Installing OpenNebula 4.14"
sleep 3s
read -p "Fully Qualified Domain Name to set:" f
read -p "Your network interface name (eg: eth0 or enp3s0 ) :" g
#read -p "Root password:" z
read -p "Cloud admin password:" y

hostnamectl set-hostname $f
yum install epel-release -y
cat << EOT > /etc/yum.repos.d/opennebula.repo
[opennebula]
name=opennebula
baseurl=http://downloads.opennebula.org/repo/4.14/CentOS/7/x86_64/
enabled=1
gpgcheck=0
EOT
yum install net-tools gcc sqlite-devel mysql-devel screen python python-pip openssl-devel curl-devel httpd php php-common rubygem-rake libxml2-devel libxslt-devel patch expat-devel gcc-c++  wget git opennebula-server openssh openssh-server opennebula-sunstone opennebula-node-kvm opennebula-gate opennebula-flow ruby-devel make autoconf -y

echo -e "1\n\n" |/usr/share/one/install_gems

sed -i 's/:host: 127.0.0.1/:host: 0.0.0.0/g' /etc/one/sunstone-server.conf
#sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
echo "oneadmin:$y" > /var/lib/one/.one/one_auth
systemctl enable opennebula
systemctl start opennebula
#find / -name ncloud.php -exec mv {} /var/www/html/ \;
#mv /var/www/html/ncloud.php /var/www/html/index.php
#chown -R apache:apache /var/www/html
#sed -i "s/nxpass/$z/g" /var/www/html/index.php
#systemctl start httpd
#systemctl enable httpd
pip install --upgrade setuptools
find / -name GateOne -exec cp -rv {} /var \;
python /var/GateOne/setup.py install
cd /var/GateOne ; screen -dmS terminal ./run_gateone.py

chmod +x /etc/rc.d/rc.local
echo "sh /var/cloud/service.sh" >> /etc/rc.d/rc.local
mv -f /var/cloud /var/cloud.bak >> /var/log/cloud.log
mkdir /var/cloud
touch /var/cloud/service.sh
chmod +x /var/cloud/service.sh
echo "cd /var/GateOne ; screen -dmS terminal ./run_gateone.py" >> /var/cloud/service.sh
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

##Branding
IP=`hostname -i`
rm -rf /usr/lib/one
find / -name nxone -exec mv -v {} /usr/lib/one \;
sed -i "s/terminalgo/$IP/g" /usr/lib/one/sunstone/views/login.erb
onezone rename 0 NXCLOUD
service opennebula restart
service opennebula-sunstone restart

##Network Settings


touch /etc/sysconfig/network-scripts/ifcfg-br0
cp /etc/sysconfig/network-scripts/ifcfg-$g /etc/sysconfig/network-scripts/ifcfg-$g.bak
#cat /dev/null > /etc/sysconfig/network-scripts/ifcfg-$g
clear
echo "Copy below content to ifcfg-$g"

echo "
DEVICE=$g
BOOTPROTO=none
NM_CONTROLLED=no
ONBOOT=yes
TYPE=Ethernet
BRIDGE=br0
" 

echo "Copy below content to /etc/sysconfig/network-scripts/ifcfg-br0"

echo "
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=dhcp
NM_CONTROLLED=no
" 
read -p "Please hit ENTER after finish copy paste. You must need to copy and paste content to the given location."

systemctl restart network.service

##Adding ssh public key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQCBYlX1NxLs7o++ySQRyuPY5dMdeAIoTh7XGE1Sp5yeaYz7AGegg8ov8jFDf7BtCiwkqboiuxPId38RFYCDLoSjbhzcVzoeMX87b/EcTJP+4DjQqe4lbfNmefK0t7qYPTvlTdK3gQEi9h5uw25RZmo2JqaJ+KoWJqU82es3bBKgEQ== imported-openssh-key" >> /root/.ssh/authorized_keys
systemctl restart sshd
cat /dev/null > /etc/motd

PWD=`cut -c 10-50 /var/lib/one/.one/one_auth`

echo "*****************************************************" >> /etc/motd
echo "       Opennebula 4.14 OS by James PS             " >> /etc/motd
echo "        https://github.com/jamesarems            " >> /etc/motd
echo "                 (c) 2016           " >> /etc/motd
echo "*****************************************************" >> /etc/motd
echo "    Username : oneadmin   " >> /etc/motd
echo "    Password : $PWD      "  >> /etc/motd
echo "    Web UI : http://$IP:9869     " >> /etc/motd
echo "    Web Terminal : https://$IP:10443    " >> /etc/motd
echo "    NOTE: If you are not getting network connection, then you have to configure network manually     " >> /etc/motd
echo "    Details available on https://github.com/jamesarems/opennebula-distro" >> /etc/motd
echo "######################################################" >> /etc/motd

###
#Final message
clear
echo "Please reboot your machine to complete this installation"

#Opennebula 5.0
elif [ "$1" == "nxsetup" ]; then
clear
echo "Installing OpenNebula 5.0 SP1"
sleep 5s
read -p "Fully Qualified Domain Name to set:" f
read -p "Your network interface name (eg: eth0 or enp3s0 ) :" g
#read -p "Root password:" z
read -p "Cloud admin password :" y

hostnamectl set-hostname $f

IP=`hostname -i`
yum install epel-release -y
cat << EOT > /etc/yum.repos.d/opennebula.repo
[opennebula]
name=opennebula
baseurl=http://downloads.opennebula.org/repo/5.0/CentOS/7/x86_64
enabled=1
gpgcheck=0
EOT
yum install net-tools gcc sqlite-devel httpd screen php php-common mysql-devel python python-pip openssl-devel curl-devel rubygem-rake libxml2-devel libxslt-devel patch expat-devel gcc-c++  wget git opennebula-server openssh openssh-server opennebula-sunstone opennebula-node-kvm opennebula-gate opennebula-flow ruby-devel make autoconf -y

echo -e "1\n\n" |/usr/share/one/install_gems

sed -i 's/:host: 127.0.0.1/:host: 0.0.0.0/g' /etc/one/sunstone-server.conf
sed -i 's/:port: 9869/:port: 8080/g' /etc/one/sunstone-server.conf
#sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
#find / -name ncloud.php -exec mv {} /var/www/html/ \;
#mv /var/www/html/ncloud.php /var/www/html/index.php
#sed -i "s/nxpass/$z/g" /var/www/html/index.php
pip install --upgrade setuptools
find / -name GateOne -exec cp -rv {} /var \;

mkdir -p /var/www/html
rm -rf /var/www/html
find / -name nxhtml -exec cp -rv {} /var/www/html \;
chown -R apache:apache /var/www/html
sed -i "s/nxonehyper/$IP/g" /var/www/html/index.php
sed -i "s/nxonehyper/$IP/g" /var/www/html/terminal.php


python /var/GateOne/setup.py install
cd /var/GateOne ; screen -dmS terminal ./run_gateone.py

systemctl start httpd
systemctl enable httpd
echo "oneadmin:$y" > /var/lib/one/.one/one_auth
systemctl enable opennebula
systemctl start opennebula
chmod +x /etc/rc.d/rc.local
echo "sh /var/cloud/service.sh" >> /etc/rc.d/rc.local
mv -f /var/cloud /var/cloud.bak >> /var/log/cloud.log
mkdir /var/cloud
touch /var/cloud/service.sh
chmod +x /var/cloud/service.sh
echo "cd /var/GateOne ; screen -dmS terminal ./run_gateone.py" >> /var/cloud/service.sh
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

##Branding

#IP=`hostname -i`
rm -rf /usr/lib/one
find / -name nxone -exec mv -v {} /usr/lib/one \;
sed -i "s/terminalgo/$IP/g" /usr/lib/one/sunstone/views/login.erb
onezone rename 0 NXCLOUD
service opennebula restart
service opennebula-sunstone restart

##Network Settings


touch /etc/sysconfig/network-scripts/ifcfg-br0
cp /etc/sysconfig/network-scripts/ifcfg-$g /etc/sysconfig/network-scripts/ifcfg-$g.bak
#cat /dev/null > /etc/sysconfig/network-scripts/ifcfg-$g
clear
echo "Copy below content to ifcfg-$g"

echo "
DEVICE=$g
BOOTPROTO=none
NM_CONTROLLED=no
ONBOOT=yes
TYPE=Ethernet
BRIDGE=br0
" 

echo "Copy below content to /etc/sysconfig/network-scripts/ifcfg-br0"

echo "
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=dhcp
NM_CONTROLLED=no
" 
read -p "Please hit ENTER after finish copy paste. You must need to copy and paste content to the given location."

systemctl restart network.service

##Adding ssh public key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQCBYlX1NxLs7o++ySQRyuPY5dMdeAIoTh7XGE1Sp5yeaYz7AGegg8ov8jFDf7BtCiwkqboiuxPId38RFYCDLoSjbhzcVzoeMX87b/EcTJP+4DjQqe4lbfNmefK0t7qYPTvlTdK3gQEi9h5uw25RZmo2JqaJ+KoWJqU82es3bBKgEQ== imported-openssh-key" >> /root/.ssh/authorized_keys
systemctl restart sshd
cat /dev/null > /etc/motd

PWD=`cut -c 10-50 /var/lib/one/.one/one_auth`

echo "*****************************************************" >> /etc/motd
echo "       NXONE 1.0 OS by James PS             " >> /etc/motd
echo "        https://github.com/jamesarems            " >> /etc/motd
echo "                 (c) 2016           " >> /etc/motd
echo "*****************************************************" >> /etc/motd
echo "    Username : oneadmin   " >> /etc/motd
echo "    Password : $PWD      "  >> /etc/motd
echo "    Web UI : http://$IP     " >> /etc/motd
echo "    NOTE: Base tecnologies are copied from opennebula systems     " >> /etc/motd
echo "    Details available on https://github.com/jamesarems/opennebula-distro" >> /etc/motd
echo "######################################################" >> /etc/motd

###
#Final message
clear
echo "To configure networking run command $(tput setaf 3)cloud-install ovs$(tput sgr0) and $(tput setaf 3)cloud-install ovs-conf$(tput sgr0)"


elif [ "$1" == "ovs" ] ; then
clear
echo "Checking Repository...."
sleep 3s
yum install epel-release -y >> /var/log/ovsinstall.log
yum -y install wget openssl-devel gcc make python-devel openssl-devel kernel-devel kernel-debug-devel autoconf automake rpm-build redhat-rpm-config libtool
adduser ovs
clear
echo "Configuring OpenVswitch.."
sleep 3s
runuser -l ovs -c 'mkdir -p ~/rpmbuild/SOURCES'
runuser -l ovs -c 'wget http://openvswitch.org/releases/openvswitch-2.4.0.tar.gz -P /home/ovs/'
runuser -l ovs -c 'cp /home/ovs/openvswitch-2.4.0.tar.gz ~/rpmbuild/SOURCES/'
runuser -l ovs -c 'tar xfz /home/ovs/openvswitch-2.4.0.tar.gz'
runuser -l ovs -c `sed 's/openvswitch-kmod, //g' /home/ovs/openvswitch-2.4.0/rhel/openvswitch.spec > /home/ovs/openvswitch-2.4.0/rhel/openvswitch_no_kmod.spec`
runuser -l ovs -c 'rpmbuild -bb --nocheck /home/ovs/openvswitch-2.4.0/rhel/openvswitch_no_kmod.spec'

yum localinstall /home/ovs/rpmbuild/RPMS/x86_64/openvswitch-2.4.0-1.x86_64.rpm -y
clear
echo "OpenVswitch Version"
ovs-vsctl -V
/etc/init.d/openvswitch start
chkconfig openvswitch on
echo "Installation completed"
echo "Run $(tput setaf 3)cloud-install ovs-conf$(tput sgr0) "

##LizardsFS installation
#Experimental
elif [ "$1" == "lizardfs" ]; then
clear
read -p "Lizardfs master IP :" a
echo " $a  mfsmaster " >> /etc/hosts
echo "Installing LizardFS packages"
sleep 3s
curl http://packages.lizardfs.com/lizardfs.key > /etc/pki/rpm-gpg/RPM-GPG-KEY-LizardFS
curl http://packages.lizardfs.com/yum/el7/lizardfs.repo > /etc/yum.repos.d/lizardfs.repo 
yum update -y
yum install lizardfs-master lizardfs-chunkserver lizardfs-cgiserv lizardfs-metalogger lizardfs-client -y
clear
echo "LizardFS packages installed. Run this step on every lizardfs nodes"

elif [ "$1" == "lizardfs-master" ]; then
clear
echo "Master server configuration"
cp /etc/mfs/mfsmaster.cfg.dist /etc/mfs/mfsmaster.cfg
cp /etc/mfs/mfsexports.cfg.dist /etc/mfs/mfsexports.cfg
sed -i 's/maproot=0/maproot=9869/g' /etc/mfs/mfsexports.cfg
cp /etc/mfs/mfsgoals.cfg.dist /etc/mfs/mfsgoals.cfg
cp /etc/mfs/mfstopology.cfg.dist /etc/mfs/mfstopology.cfg
cp /var/lib/mfs/metadata.mfs.empty /var/lib/mfs/metadata.mfs
sed -i 's/# PERSONALITY = master/PERSONALITY = master/g' /etc/mfs/mfsmaster.cfg
systemctl enable lizardfs-master
systemctl start lizardfs-master
clear
echo "Lizardfs master is configured."

elif [ "$1" == "lizardfs-shadow" ]; then
clear
echo "Shadow server configuration"
cp /etc/mfs/mfsmaster.cfg.dist /etc/mfs/mfsmaster.cfg
cp /etc/mfs/mfsexports.cfg.dist /etc/mfs/mfsexports.cfg
#cp /etc/mfs/mfsgoals.cfg.dist /etc/mfs/mfsgoals.cfg
#cp /etc/mfs/mfstopology.cfg.dist /etc/mfs/mfstopology.cfg
#cp /var/lib/mfs/metadata.mfs.empty /var/lib/mfs/metadata.mfs
sed -i 's/# PERSONALITY = master/PERSONALITY = shadow/g' /etc/mfs/mfsmaster.cfg
systemctl enable lizardfs-master
systemctl start lizardfs-master
clear
echo "Lizardfs shadow is configured."

elif [ "$1" == "lizardfs-chunk" ]; then
HOST=`hostname -i`
clear
echo "LizardFS chunk configuration"
echo "**************************************************************"
echo "NOTE : you have to mount HDD to your local directory. Atleast 2 mount points needed."
echo " Eg : /mnt/chunk1  and /mnt/chunk2"
echo "**************************************************************"
read -p "If you mounted disk already, then press ENTER otherwise CTRL+C to exit"
clear
read -p "Mounted location 1 :" a
echo "Primary location is  $a"
read -p "Mounted location 2 :" b
echo "Secondary location is $b"
echo "$a" >> /etc/mfs/mfshdd.cfg
echo "$b" >> /etc/mfs/mfshdd.cfg
cp /etc/mfs/mfsmetalogger.cfg.dist /etc/mfs/mfsmetalogger.cfg
chown -R mfs:mfs $a
chown -R mfs:mfs $b
mfschunkserver start
mfsmetalogger start
mfscgiserv start
clear
echo "Chunk server started"
echo "*******************************************************************************"
echo "You can now acces web at http://$HOST:9425/mfs.cgi?masterhost=mfsmaster       "
echo "*******************************************************************************"

elif [ "$1" == "ovs-conf" ] ; then
clear
echo "Configuring OVS NXONE network"
clear
read -p "Your network adapter name (eg: eth0 , ens0p1) :" a
read -p "Main IP Address:" b
read -p "Subnet Prefix (eg : 24 for 255.255.255.0 ) :" c
read -p "Your Router Gateway:" d
read -p "DNS server to connect (eg : 8.8.8.8) :" e

rm -rf /etc/sysconfig/network-scripts/ifcfg-br0
touch /etc/sysconfig/network-scripts/ifcfg-br0
cp /etc/sysconfig/network-scripts/ifcfg-$a /etc/sysconfig/network-scripts/ifcfg-$g.bak
clear
echo "Copy this content to your ifcfg-$a"
echo "
DEVICE=$a
BOOTPROTO=none
NM_CONTROLLED=no
ONBOOT=yes
TYPE=OVSPort
DEVICETYPE=ovs
TYPE=Ethernet
OVS_BRIDGE=br0
"

echo "Copy this to /etc/sysconfig/network-scripts/ifcfg-br0"

echo "
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=none
IPADDR=$b
PREFIX=$c
GATEWAY=$d
DNS1=$e
TYPE=OVSBridge
DEVICETYPE=ovs
NM_CONTROLLED=no
"

read -p "WARNING : After copy and paste , please press ENTER. If you are not placing the lines on correct location , you will loose your netwok connection."

#echo "After copy and paste, type below commands"
#echo "********************************"
#echo "ovs-vsctl add-br br0"
#echo "ovs-vsctl add-port br0 $a "
#echo "systemctl restart network"
#echo "********************************"
#echo "NOTE: if your connection were dropped , need to get direct connection from server"
clear
echo "Please be patient $(tput setaf 4)nxone$(tput sgr0) network is configuring...! "

ovs-vsctl add-br br0
ovs-vsctl add-port br0 $a
systemctl restart network
ovs-vsctl show
sleep 5s
clear

echo "$(tput setaf 4)NXONE$(tput sgr0)OVS network configured."
echo "Please $(tput setaf 3)REBOOT$(tput sgr0) your machine to complete installation process"

elif [ "$1" == "gluster" ] ; then
clear
echo "Installing GlusterFS"
read -p "Gluster node 1 hostname:" a
read -p "Gluster node 2 hostname:" b
sleep 4s
cat << EOT > /etc/yum.repos.d/glusterfs.repo
[gluster]
name=gluster
baseurl=http://buildlogs.centos.org/centos/7/storage/x86_64/gluster-3.8/
enabled=1
gpgcheck=0
EOT
yum install glusterfs-server  -y
service glusterd start
gluster peer probe $a
gluster peer probe $b
clear
echo "Before glusterconf , please install glusterfs in all your node"

elif [ "$1" == "glusterconf" ]; then

clear
echo "Configuring GlusterFS for OpenNebula.."
sleep 4s
read -p "Gluster node 1 hostname:" a
read -p "Gluster node 2 hostname:" b
read -p "GlusterFS volume name:" c
read -p "Mounted directory location to point Gluster volume:" d
gluster peer probe $a
gluster peer probe $b
gluster volume create $c replica 2 $a:$d $b:$d force
gluster volume start $c
echo "mount -a" >> /var/cloud/service.sh
clear
gluster volume info
echo "Configuration Completed"

elif [ "$1" == "help" ] ; then
echo "$(tput setaf 1)gluster$(tput sgr0)  :  Install GlusterFS Packages"
echo "$(tput setaf 1)glusterconf$(tput sgr0)  :  Configure GlusterFS"
echo "$(tput setaf 1)lizard$(tput sgr0)  :  Install LizardFS Packages"
echo "$(tput setaf 1)lizard-master$(tput sgr0)  :  Configure LizardsFS master"
echo "$(tput setaf 1)lizard-shadow$(tput sgr0)  :  Configure LizardFS shadow server"
echo "$(tput setaf 1)lizard-chunk$(tput sgr0)  :  Configure LizardFS chunk server"
echo "$(tput setaf 1)ovs$(tput sgr0)  :  Install OpenVswitch packages"
echo "$(tput setaf 1)ovs-conf$(tput sgr0)  :  Configure OpenVswitch"

else

echo "Error pharsing command. Please check . Type $(tput setaf 3)help$(tput sgr0) for more"


fi


