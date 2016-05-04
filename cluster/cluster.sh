#!/bin/bash
##Run set up on two nodes
if [ "$1" == "setup" ]; then
 
clear
echo "Installing Opennebula HA components"
sleep 3s
echo "Both master and slave need to be set same root password"
read -p "Please varify your settings before pressing ENTER . To Cancel press CTRL +C"
clear
##Installation Starts
echo "Installing....."
sleep 3s
yum install pcs fence-agents-all -y
clear
echo "Password for hacluster service. This should be same for both master and slave."
passwd hacluster
gem uninstall rack sinatra
gem install --no-ri --no-rdoc rack --version=1.5.2
gem install --no-ri --no-rdoc rack-protection --version=1.5.3
gem install --no-ri --no-rdoc rack-test --version=0.6.2
gem install --no-ri --no-rdoc sinatra --version=1.4.5
gem install --no-ri --no-rdoc sinatra-contrib --version=1.4.2
gem install --no-ri --no-rdoc sinatra-sugar --version=0.5.1

systemctl disable opennebula
systemctl disable opennebula-sunstone
systemctl disable opennebula-gate
systemctl disable opennebula-flow

rm -rf /usr/bin/cloud
find / -iname cluster.sh -exec cp -r {} /usr/bin/cloud \;
chmod +x /usr/bin/cloud
systemctl start pcsd.service
systemctl enable pcsd.service
systemctl enable corosync.service
systemctl enable pacemaker.service
clear
echo 'We now just installed cluster services . Our cloud service command will available with "cloud" from your command line'

#This commands is only for master server
elif [ "$1" == "master" ] ; then

clear
echo " Please answer carefully...."
sleep 4s

read -p "master host name :" a
read -p "slave host name :" b
read -p "master ip: " c
read -p "slave ip: " d
read -p "Cluster name to create: " e
read -p "Heartbeat IP Address : " f
read -p "Subnet mask for Heartbeat IP (eg: 24 ):" h
read -p "Root password of your system:" g



clear
echo 'Username is "hacluster" and password is the one you given on the first setup'
pcs cluster auth $a $b

pcs cluster setup --name opennebula $a $b

pcs cluster start --all

pcs property set no-quorum-policy=ignore

#pcs stonith list
pcs property set stonith-enabled=false
#pcs stonith describe fence_ilo_ssh

#pcs stonith create fence_server1 fence_ilo_ssh pcmk_host_list=$a ipaddr=$c login="root" passwd="$g" action="reboot" secure=yes delay=30 op monitor interval=20s
#pcs stonith create fence_server2 fence_ilo_ssh pcmk_host_list=$b ipaddr=$d login="root" passwd="$g" action="reboot" secure=yes delay=15 op monitor interval=20s

pcs resource create $e ocf:heartbeat:IPaddr2 ip=$f cidr_netmask=$h op monitor interval=20s
#pcs resource describe ocf:heartbeat:IPaddr2



pcs resource create opennebula systemd:opennebula
pcs resource create opennebula-sunstone systemd:opennebula-sunstone
pcs resource create opennebula-gate systemd:opennebula-gate
pcs resource create opennebula-flow systemd:opennebula-flow

pcs constraint colocation add opennebula $e INFINITY
pcs constraint colocation add opennebula-sunstone $e INFINITY
#pcs constraint colocation add opennebula-novnc $e INFINITY
pcs constraint colocation add opennebula-gate $e INFINITY
pcs constraint colocation add opennebula-flow $e INFINITY

elif [ "$1" == "sync" ] ; then
clear
echo "Syncing Remote servers"
sleep 4s
read -p "slave server hostname:" p
read -p "slave server root password:" o
yum install sshpass -y >> /tmp/nebula.log

sshpass -p $o ssh -o StrictHostKeyChecking=no  root@$p 'rm -rf /var/lib/one/*'
sshpass -p $o ssh -o StrictHostKeyChecking=no  root@$p 'rm -rf /var/lib/one/.*'
sshpass -p $o scp -o StrictHostKeyChecking=no -r /etc/motd root@$p:/etc/motd 
systemctl stop opennebula
systemctl stop opennebula-sunstone
systemctl stop opennebula-gate
systemctl stop opennebula-flow

sshpass -p $o ssh -o StrictHostKeyChecking=no  root@$p 'systemctl stop opennebula'
sshpass -p $o ssh -o StrictHostKeyChecking=no  root@$p 'systemctl stop opennebula-sunstone'
sshpass -p $o ssh -o StrictHostKeyChecking=no  root@$p 'systemctl stop opennebula-gate'
sshpass -p $o ssh -o StrictHostKeyChecking=no  root@$p 'systemctl stop opennebula-flow'

rsync -apvog --rsh="sshpass -p $o ssh -o StrictHostKeyChecking=no -l root" /var/lib/one/ $p:/var/lib/one/
clear
echo "Syncing completed"

elif [ "$1" == "help" ] ; then
echo "$(tput setaf 1)sync$(tput sgr0)  :  Sync between opennebula master and slave"
echo "$(tput setaf 1)setup$(tput sgr0)  :  Setup Cluster service"
echo "$(tput setaf 1)master$(tput sgr0)  :  Configure master cluster server"
echo "$(tput setaf 1)clone$(tput sgr0)  :  Clone entire opennebula"
echo "$(tput setaf 1)restore$(tput sgr0)  :  Restore entire opennebula from clone image"
echo "$(tput setaf 1)add-host$(tput sgr0)  :  Add KVM host to opennebula"
echo "$(tput setaf 1)attach-pcs$(tput sgr0)  :  Attach lost ha service"
echo "$(tput setaf 1)mount-gluster$(tput sgr0)  :  Mount detached glusterfs"
echo "$(tput setaf 1)attach-lizard$(tput sgr0)  :  Attach lizardfs service to master server"

elif [ "$1" == "clone" ] ; then
clear
echo "**********************************"
echo "Cloning entire OpenNebula Platform"
echo "**********************************"
sleep 2s
read -p "First mount shared storage / Disk to a directory. If you forget to mount press CTRL+C . Otherwise press ENTER"
clear
read -p "Mounted location (eg: /mnt/disk ) :" a

yum install rsync -y
mkdir $a/nebula-clone
mkdir $a/nebula-clone/one-{var,usr,etc}
rsync -apvog --progress /var/lib/one/ $a/nebula-clone/one-var/
rsync -apvog --progress /usr/lib/one/ $a/nebula-clone/one-usr/
rsync -apvog --progress /etc/one/ $a/nebula-clone/one-etc/
clear
echo "Cloning finished . Clone image saved under  $(tput setaf 2)$a/nebula-clone$(tput sgr0) For restoration use $(tput setaf 3)restore$(tput sgr0) option "

elif [ "$1" == "restore" ] ; then
clear
echo "**********************************"
echo "Restoring entire OpenNebula Platform"
echo "**********************************"
sleep 2s
read -p "First mount Disk/Shared storage containing cloned files . If you forget to mount press CTRL+C . Otherwise press ENTER"
clear
read -p "Currect location to the clone image path (eg: /mnt/disk/nebula-clone ) :" a

yum install rsync -y
service opennebula stop
service opennebula-sunstone stop
service opennebula-flow stop
rm -rf /var/lib/one/*
rm -rf /var/lib/one/.*
rm -rf /usr/lib/one/*
rm -rf /etc/one/*
rsync -apvog --progress $a/one-var/ /var/lib/one/
rsync -apvog --progress $a/one-usr/ /usr/lib/one/
rsync -apvog --progress $a/one-etc/ /etc/one/
chown -R oneadmin:oneadmin /var/lib/one

clear
echo "Restoration finished ."

elif [ "$1" == "add-host" ] ; then
clear
read -p "KVM Host IP/FQDN : " a
echo "Adding KVM host to OpenNebula"
sleep 3s

runuser -l oneadmin -c 'onehost create $a -i kvm -v kvm -n ovswitch'
runuser -l oneadmin -c 'onehost list'

elif [ "$1" == "attach-pcs" ] ; then
clear
echo " Attaching crashed machine to the running cluster"
systemctl start pcsd.service
pcs cluster start --all
clear
echo "Attaching please wait......."
sleep 6s
pcs status

elif [ "$1" == "attach-lizard" ] ; then
clear
echo "Re attaching lizardfs services and volumes"
systemctl restart lizardfs-master
mfsmaster reload
mfschunkserver restart
mfsmetalogger start
mfscgiserv start
echo "All services are attached"

elif [ "$1" == "mount-lizard" ] ; then
clear
echo "Mounting opennebula directory"
umount /var/lib/one
mfsmount /var/lib/one
chown oneadmin:oneadmin /var/lib/one
df -h

elif [ "$1" == "mount-gluster" ] ; then
clear
echo "Mounting opennebula directory"
read -p "Gluster store node (Eg : node1.example.com:/dr1 ) : " a
umount /var/lib/one
mount -t glusterfs $a /var/lib/one
chown oneadmin:oneadmin /var/lib/one
df -h

else
echo "Invalid parameter . Fore more type help"
fi
