##Opennebula 4.14 Install script
yum install epel-release -y
cat << EOT > /etc/yum.repos.d/opennebula.repo
[opennebula]
name=opennebula
baseurl=http://downloads.opennebula.org/repo/4.14/CentOS/7/x86_64/
enabled=1
gpgcheck=0
EOT
yum install opennebula-server opennebula-sunstone opennebula-node-kvm -y
echo "\1\ny\n\n" |bash /usr/share/one/install_gems

sed -i 's/:host: 127.0.0.1/:host: 0.0.0.0/g' /etc/one/sunstone-server.conf

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

cp /etc/sysconfig/network-script/ifcfg-enp3s0 /etc/sysconfig/network-script/ifcfg-enp3s0.bak
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

cut -c 10-50 one_auth
