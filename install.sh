#!/bin/bash
#
######
##This installer file is using
## Because of your easy pupose
## This will clone all script file to your PC
############
## And you can excecute commands from anywhere.
##
rm -rf /usr/bin/cloud-install
rm -rf /usr/bin/cloud
find / -iname cloud-install.sh -exec mv {} /usr/bin/cloud-install \;
find / -iname cluster.sh -exec mv {} /usr/bin/cloud \;
chmod 775 /usr/bin/cloud-install
chmod 775 /usr/bin/cloud
cd /tmp
find / -iname cloud-install.sh -exec rm -rf {} \;
find / -iname cluster.sh -exec rm -rf {} \;
clear
echo "cloud-install.sh and cluster.sh files are depreciated , Now you can use with $(tput setaf 3)cloud$(tput sgr0) and $(tput setaf 3)cloud-install$(tput sgr0) command from anyware "
