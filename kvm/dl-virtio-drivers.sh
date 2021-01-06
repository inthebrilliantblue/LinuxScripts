#!/bin/bash
#This script requires wget and curl to work. Be sure to install based on your distro.

#First check if we have directory locations for stable and latest downloads

#Stable downloads
if [ "$1" != "" ]; then
    echo "Downloading STABLE to $1"
else
    echo "Please provide a download directory for the stable virtio drivers."
	exit 1
fi

#Latest downloads
if [ "$2" != "" ]; then
    echo "Downloading LATEST to $2"
else
    echo "Please provide a download directory for the latest virtio drivers."
	exit 1
fi

#Set vars
dldirstable="$1"
dldirlatest="$2"

#Clear out old downloads
rm -rf "$dldirstable"
rm -rf "$dldirlatest"

#Remake folders
mkdir -p "$dldirstable"
mkdir -p "$dldirlatest"

#Get actual stable and latest 301 redirect link from fedorapeople.org
STABLE=$(curl -Ls -o /dev/null -w %{url_effective} https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/)
LATEST=$(curl -Ls -o /dev/null -w %{url_effective} https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/)

#Get Stable
echo $STABLE
wget -P "$dldirstable" -R "index.html*" -nd -c -m -np "$STABLE"

#Get Latest
echo $LATEST
wget -P "$dldirlatest" -R "index.html*" -nd -c -m -np "$LATEST"
