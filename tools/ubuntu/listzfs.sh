#!/bin/bash

#Get options
while [ True ]; do
	if [ "$1" = "--dataset" -o "$1" = "-d" ]; then
		DATASET="$2"
		shift 2
	elif [ "$1" = "--snapshotcounts" -o "$1" = "-sc" ]; then
		SNAPSHOTCOUNTS=1
		shift 1
	else
		DATASET="$1"
		break
	fi
done

#Determine what to display
if [ $SNAPSHOTCOUNTS ]; then
	#Display counts of snapshots
	zfs list  -t snapshot -o name -s name -r -H $DATASET | sed 's/@.*//' | uniq -c | head
else
	#Show default data
 	#List reservations and quotas
        printf "ZFS Dataset Info\n"
        zfs list -r -t filesystem -o name,sync,mountpoint,primarycache,secondarycache,dedup,sharenfs $DATASET
        printf "\n"
	
	#List datasets
	printf "ZFS Dataset Storage Info\n"
	zfs list -r -t filesystem -o name,quota,reservation,used,refer,avail,recordsize,compressratio,compression $DATASET
	printf "\n"

	#List encrypted dataset values
	printf "ZFS Encrypted Datasets\n"
	zfs list -r -t filesystem -o name,keystatus,keylocation,keyformat,encryption,mounted $DATASET | grep -v " - "
	printf "\n"

	#List ZVOLs
	printf "ZFS ZVOLs\n"
	zfs list -r -t volume -o name,used,refer,avail,volsize,volblocksize,compressratio,compression,logbias,sync,primarycache,secondarycache,dedup $DATASET
	printf "\n"

	#List pools
	printf "ZPOOLs\n"
	zpool list
fi
