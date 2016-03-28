# Opennebula Cluster
After the opennebula installation , we can think about clustering. Please install 2 opennebula front end server and create a password less authentication using ssh server.

# Requirements

* Already Installed Opennebula servers. 
* Both servers need password less authentication using ssh
* 3 reserved IP's. (2 IP's for both machines and 1 for heratbeat )

#Usage

1. On master server ,


 cd /opennebula-distro/cluster

 bash cluster.sh sync

2. On Both servers,

 bash cluster.sh setup               (Give informations what ever that asking from the installer )

3. After these steps on both machines, run below command on master server.

 bash cluster.sh master              (Give informations what ever that asking from the installer )

# Limitation

 Nothing yet...lol
