#!/bin/bash
#Install some filesystems
sudo apt-get install xfsprogs squashfs-tools f2fs-tools btrfs-progs -y
#Check if we want to install ZFS, and if so from github source or dist release
read -p "Install ZFS? (y/n)" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]
then
  read -p "Build ZFS from source? (y/n)" -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    sudo apt install gdebi build-essential autoconf automake libtool gawk alien fakeroot dkms libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev linux-headers-$(uname -r) python3 python3-dev python3-setuptools python3-cffi libffi-dev dkms
    #Remove zfs dir
    rm -rf ./zfs
    #Get latest zfs github
    #git clone https://github.com/zfsonlinux/zfs.git
    git clone https://github.com/openzfs/zfs.git
    cd zfs
    ./autogen.sh
    ./configure --enable-systemd
    #Make kmod
    make -j1 deb-utils deb-kmod
    for file in *.deb; do sudo gdebi -q --non-interactive $file; done
    #Make DKMS
    make -j1 deb-utils deb-dkms
    for file in *.deb; do sudo gdebi -q --non-interactive $file; done
    echo "Be sure to enable the ZFS modules!"
    cd ../
  else
    sudo apt install zfsutils-linux -y
  fi
fi
