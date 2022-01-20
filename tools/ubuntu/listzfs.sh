#!/bin/bash
zfs list -r -o name,used,refer,avail,recordsize,compressratio,compression,sync,mountpoint,primarycache,secondarycache,volsize,volblocksize,dedup
printf "\n"
zpool list
