#!/bin/bash
#Install cockpit and packages
#cockpit-dashboard no longer a thing in Ubuntu 21.04
sudo apt install git cockpit cockpit-machines cockpit-networkmanager cockpit-packagekit cockpit-podman cockpit-storaged cockpit-system cockpit-pcp cockpit-ws cockpit-bridge
#ZFS beta package
git clone https://github.com/optimans/cockpit-zfs-manager.git
sudo cp -r cockpit-zfs-manager/zfs /usr/share/cockpit
rm -rf cockpit-zfs-manager
