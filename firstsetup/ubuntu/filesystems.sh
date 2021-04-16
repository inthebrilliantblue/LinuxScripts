#!/bin/bash
#Install some filesystems
sudo apt-get install xfsprogs squashfs-tools f2fs-tools btrfs-progs -y
#Check if we want to install ZFS, and if so from github source or dist release
read -p "Install ZFS? (y/n)" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
  sudo apt install zfsutils-linux -y
fi
