## OpenNebula-Automation  V 1.1 Beta
OpenNebula offers a simple but feature-rich and flexible solution to build and manage enterprise clouds and virtualized data centers. OpenNebula is designed to be simple. Simple to install, update and operate by the admins, and simple to use by end users. Being focused on simplicity, we integrate with existing technologies whenever possible. You’ll see that OpenNebula works with MySQL, Ceph, LVM, GlusterFS, Open vSwitch, LDAP... This allows us to deliver a light, flexible and robust cloud manager.

# Requirement

* Virtualization supported machine
* 2 Ethernet cards. (1 for local access and 1 for public )
* DHCP Network (Not necessary )
* Internet
* Atleast 4GB RAM and 100GB storage.
* SELinux and Firewalld msut be in Disabled mode .

# Usage

This project is under beta stage. Please use it carefully. 

If installation goes success, you can login your machine via ssh console with our *cloud.pem* file.

* Step 1  SetUp GlusterFS for OpenNebula

  Before setting up gluster , we need to add both hosts name in /etc/hosts file and also run *hostnamectl set-hostname "your FQDN"* .
  
  If we need to mount perticular harddisk to use glusterfs , then format it using linux filesystem and create a directory and mount it.
  
  eg : mkdir /data
  
 mount /dev/sdc1 /data

  After that we need to create a directory inside the mount point . Glusterfs will not work with mount point itself.
  
  eg : mkdir -p /data/dr0
  
  After this we all set to go with installer. 
  
   bash cloud-install.sh gluster
  
  Run this command on both servers.
  
* Step 2  Configuring GlusterFS  

  bash cloud-install.sh glusterconf
  
* Step 3 Installing OpenNebula With KVM

  bash cloud-install.sh setup

# LizardFS Support

We can install Lizardfs rather than using glusterFS . If you are intrested about LIzardfs then please dont install gluster .

First install LIzard and continue Step 3.

* Step 1a  Install LizardFS master .

  bash cloud-install.sh lizardfs-master

* Step 2a  Configuring shadow server

  Execute this commands in every nodes except master.

  bash cloud-install.sh lizardfs-shadow

* Step 2b  Configuring Chunk nodes

  NOTE : You have to run this command on every nodes. 

  bash cloud-install.sh lizardfs-chunk


# High Availability

We can configure opennebula as highly available system. Please refer "Cluster" section.

# Networking

Now OpenVswitch support added. You can easly install and configer OpenVswitch on your opennebula server. After Compleating *Step 3* just enter below commands. If you are not intrested with openVswitch , then continue with Cluster setup.

 bash cloud-install.sh ovs
 
 Answer all the questions that installer asks. After that run,
 
 bash cloud-install.sh ovs-conf
 
 And follow the instructions.


# Limitation

* Please submit in bug reports. Currently no limitations.

