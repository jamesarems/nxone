#!/bin/bash
##Run set up on two nodes
if [ "$1" == "setup" ]; then
 
clear
echo "Installing Opennebula HA components"
sleep 3s
echo "Both master and slave need to be set same root password"
read -p "Please varify your settings before pressing ENTER . To Cancel press CTRL +C"
clear
echo "Installing....."
sleep 3s
yum install pcs fence-agents-all -y
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

systemctl start pcsd.service
systemctl enable pcsd.service
systemctl enable corosync.service
systemctl enable pacemaker.service

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




pcs cluster auth $a $b

pcs cluster setup --name opennebula $a $b

pcs cluster start --all

pcs property set no-quorum-policy=ignore

#pcs stonith list
pcs stonith describe fence_ilo_ssh

pcs stonith create fence_server1 fence_ilo_ssh pcmk_host_list=$a ipaddr=$c login="root" passwd="$g" action="reboot" secure=yes delay=30 op monitor interval=20s
pcs stonith create fence_server2 fence_ilo_ssh pcmk_host_list=$b ipaddr=$d login="root" passwd="$g" action="reboot" secure=yes delay=15 op monitor interval=20s

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
else
echo "Invalid parameter"
fi
