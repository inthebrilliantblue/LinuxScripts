#!/bin/bash

#Set bin folder to download to that is in PATH
DL="/usr/local/bin"

#Copy github scripts to $DL
cd "${DL}"
sudo wget https://raw.githubusercontent.com/inthebrilliantblue/LinuxScripts/main/tools/ubuntu/listzfs.sh
sudo wget https://raw.githubusercontent.com/inthebrilliantblue/LinuxScripts/main/tools/ubuntu/sshkeygen.sh
sudo wget https://raw.githubusercontent.com/inthebrilliantblue/LinuxScripts/main/tools/ubuntu/count.sh

#Set permissions
sudo chmod -R 755 "${DL}"
