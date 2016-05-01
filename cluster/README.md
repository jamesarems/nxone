# Opennebula Cluster
After the opennebula installation , we can think about clustering. Please install 2 opennebula front end server and create a password less authentication using ssh server.

# Requirements

* Already Installed Opennebula servers. 
* Both servers need password less authentication using ssh
* 3 reserved IP's. (2 IP's for both machines and 1 for heratbeat )

#Usage



1. On master server ,


 cloud sync

2. On Both servers,

 cloud setup               (Give informations what ever that asking from the installer )

3. After these steps on both machines, run below command on master server.

 cloud master              (Give informations what ever that asking from the installer )

#Disaster recovery

Consider this scenario : Because of some reason or power failer master server is down . From our cluster setup slave server will run nebula services and heartbeat IP as well. Ok thats great. But when our master server is ready to live we need to re attach master to the cluster. For that we need to run below commad on the failed server.

 /usr/bin/cloud attach-pcs
 
 This command will attach your failed server to the existing cluster.

#Other Usefull commands

 /usr/bin/cloud mount-gluster        ( Attaching glusterfs to your system)

 /usr/bin/cloud mount-lizard       (Attaching LIzardfs to your system )

 /usr/bin/cloud attach-lizard      (Refreshing lost services , after power failer )

# Limitation

 Nothing yet...lol
