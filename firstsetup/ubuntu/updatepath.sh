#!/bin/bash

#Create the custom bin folder
sudo mkdir /cusbin

#Update system wide PATH to include custom scripts and bins
echo "" | sudo tee -a /etc/profile
echo "#Add custom scripts and bins" | sudo tee -a /etc/profile
echo "export PATH=$PATH:/cusbin" | sudo tee -a /etc/profile

#Copy github scripts to /cusbin
cd /cusbin
sudo wget https://raw.githubusercontent.com/inthebrilliantblue/LinuxScripts/main/tools/ubuntu/listzfs.sh
sudo wget https://raw.githubusercontent.com/inthebrilliantblue/LinuxScripts/main/tools/ubuntu/sshkeygen.sh
sudo wget https://raw.githubusercontent.com/inthebrilliantblue/LinuxScripts/main/tools/ubuntu/count.sh

#Set permissions
sudo chmod -R 755 /cusbin
