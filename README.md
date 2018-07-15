# NXONE  V 2.0

##New Features

* Update Hypervisor core packages .

* Terminal Web console added .
  
  Users can now access hypervisor terminal console from web browser .

* Added eye catching GUI template .

* Added iCinga2 support

## About Opennebula

OpenNebula offers a simple but feature-rich and flexible solution to build and manage enterprise clouds and virtualized data centers. OpenNebula is designed to be simple. Simple to install, update and operate by the admins, and simple to use by end users. Being focused on simplicity, we integrate with existing technologies whenever possible. You’ll see that OpenNebula works with MySQL, Ceph, LVM, GlusterFS, Open vSwitch, LDAP... This allows us to deliver a light, flexible and robust cloud manager.

## About NXONE

This project is based on Opennebula systems . Users can easly deploy cloud IAAS using with this project . 

## Requirement

* Virtualization supported machine
* 2 Ethernet cards. (1 for local access and 1 for public )
* Internet connection
* Atleast 4GB RAM and 100GB storage.
* SELinux and Firewalld must be in Disabled mode .


# Usage


 > git clone https://github.com/jamesarems/opennebula-distro.git
 
 > cd  opennebula-distro
 
 > sh install.sh
 
 NOTE : If you dont need shared storage skip to Step 3 .


* Step 1  SetUp GlusterFS for NXONE

  Before setting up gluster , we need to add both hosts name in /etc/hosts file and also run *hostnamectl set-hostname "your FQDN"* .
  
  If we need to mount perticular harddisk to use glusterfs , then format it using linux filesystem and create a directory and mount it.
  
  eg : mkdir /data
  
 > mount /dev/sdc1 /data

  After that we need to create a directory inside the mount point . Glusterfs will not work with mount point itself.
  
  eg : mkdir -p /data/dr0
  
  After this we all set to go with installer. 
  
  > cloud-install gluster
  
  Run this command on both servers.
  
* Step 2  Configuring GlusterFS  

  > cloud-install glusterconf
  
* Step 3 Installing NXONE

  > cloud-install nxsetup

# LizardFS Support

We can install Lizardfs rather than using glusterFS . If you are intrested about LIzardfs then please dont install gluster .

First install Step 3 from above and continue here.

 > cloud-install lizardfs

* Step 1a  Install LizardFS master .

  > cloud-install lizardfs-master

* Step 2a  Configuring shadow server

  Execute this commands in every nodes except master.

  > cloud-install lizardfs-shadow

* Step 2b  Configuring Chunk nodes

  NOTE : You have to run this command on every nodes. 

 >  cloud-install lizardfs-chunk

# Cloning and Restore

Cloning and restore feature is added. For this feature you need to use "cloud" command .

This feature will clone your entire opennebula platform to your desired location. After any desaster you can easly revert back using restore functionality. 


# High Availability

We can configure nxone as highly available system. Please refer "Cluster" section.

# Networking

Now OpenVswitch support added. You can easly install and configer OpenVswitch on your opennebula server. After Compleating *Step 3* just enter below commands. If you are not intrested with openVswitch , then continue with Cluster setup.

 > cloud-install ovs
 
 Answer all the questions that installer asks. After that run,
 
 > cloud-install ovs-conf
 
 And follow the instructions.


# Limitation and Feature requirements 

* Please share your feedback and feature request's through Issue's.

