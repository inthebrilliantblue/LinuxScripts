#!/bin/bash

#List datasets
zfs list -r -t filesystem -o name,used,refer,avail,recordsize,compressratio,compression,sync,mountpoint,primarycache,secondarycache,dedup
printf "\n"

#List ZVOLs
zfs list -r -t volume -o name,used,refer,avail,volsize,volblocksize,compressratio,compression,sync,primarycache,secondarycache,dedup
printf "\n"

#List pools
zpool list
