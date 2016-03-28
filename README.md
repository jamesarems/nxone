## OpenNebula-Distribution
OpenNebula offers a simple but feature-rich and flexible solution to build and manage enterprise clouds and virtualized data centers. OpenNebula is designed to be simple. Simple to install, update and operate by the admins, and simple to use by end users. Being focused on simplicity, we integrate with existing technologies whenever possible. You’ll see that OpenNebula works with MySQL, Ceph, LVM, GlusterFS, Open vSwitch, LDAP... This allows us to deliver a light, flexible and robust cloud manager.

# Usage

This project is under beta stage. Please use it carefully. 

If installation goes success, you can login your machine via ssh console with our *cloud.pem* file.

Step 1 :- SetUp GlusterFS for OpenNebula

  Before setting up gluster , we need to add both hosts name in /etc/hosts file and also run *hostnamectl set-hostname "your FQDN"* .
  
  If we need to mount perticular harddisk to use glusterfs , then format it using linux filesystem and create a directory and mount it.
  
  eg : mkdir /data
  
       mount /dev/sdc1 /data
       
  After that we need to create a directory inside the mount point . Glusterfs will not work with mount point itself.
  
  eg : mkdir -p /data/dr0
  
  After this we all set to go with installer. 
  
  # ./cloud-install.sh gluster
  
  Run this command on both servers.
  
Step 2 :- Configuring GlusterFS  

  # ./cloud-install.sh glusterconf
  
Step 3 :- Installing OpenNebula With KVM

  # ./cloud-install.sh setup
  
# Requirement

* Virtualization supported machine
* DHCP network
* Internet
* Atleast 4GB RAM and 100GB storage.

# Limitation

* Currently support enp3s0 interface only (You can change your network setting manually)

