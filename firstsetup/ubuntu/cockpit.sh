#!/bin/bash
#Install cockpit and packages
sudo apt install cockpit cockpit-dashboard cockpit-machines cockpit-networkmanager cockpit-packagekit cockpit-podman cockpit-storaged cockpit-system cockpit-pcp
#ZFS beta package
git clone https://github.com/optimans/cockpit-zfs-manager.git
sudo cp -r cockpit-zfs-manager/zfs /usr/share/cockpit
rm -rf cockpit-zfs-manager
