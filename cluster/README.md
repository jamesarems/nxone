# Opennebula Cluster
After the opennebula installation , we can think about clustering. Please install 2 opennebula front end server and create a password less authentication using ssh server.

# Requirements

* Already Installed Opennebula servers. 
* Both servers need password less authentication using ssh
* 3 reserved IP's. (2 IP's for both machines and 1 for heratbeat )

#Usage

On master server & slave server

 # cd /opennebula-distro/cluster

 # ./cluster.sh sync
 
 # ./cluster.sh setup               (Give informations what ever that asking from the installer )

After these steps on both machines, run below command on master server.

 # ./cluster.sh master              (Give informations what ever that asking from the installer )

# Limitation

 Nothing yet...lol
