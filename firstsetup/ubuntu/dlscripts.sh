#!/bin/bash

#Set bin folder to download to that is in PATH
DL="/usr/local/bin"

#Copy github scripts to $DL
cd "${DL}"
rm "${DL}/listzfs.sh"
sudo wget -O "${DL}/listzfs.sh" https://raw.githubusercontent.com/inthebrilliantblue/LinuxScripts/main/tools/ubuntu/listzfs.sh
rm "${DL}/sshkeygen.sh"
sudo wget -O "${DL}/sshkeygen.sh" https://raw.githubusercontent.com/inthebrilliantblue/LinuxScripts/main/tools/ubuntu/sshkeygen.sh
rm "${DL}/count.sh"
sudo wget -O "${DL}/count.sh" https://raw.githubusercontent.com/inthebrilliantblue/LinuxScripts/main/tools/ubuntu/count.sh

#Set permissions
sudo chmod -R +x "${DL}"

#Download self to update
rm "${DL}/dlscripts.sh"
sudo wget -O "${DL}/dlscripts.sh" https://github.com/inthebrilliantblue/LinuxScripts/raw/main/firstsetup/ubuntu/dlscripts.sh
sudo chmod +x "${DL}/dlscripts.sh"
