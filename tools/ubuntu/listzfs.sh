#!/bin/bash

#Get options
while [ $# -gt 0 ]; do
	if [ "$1" = "--dataset" -o "$1" = "-d" ]; then
		DATASET="$2"
		shift 2
	elif [ "$1" = "--snapshotcounts" -o "$1" = "-sc" ]; then
		SNAPSHOTCOUNTS=1
		shift 1
	elif [ "$1" = "--more" -o "$1" = "-m" ]; then
		MORE=1
		shift 1
	elif [ "$1" = "--help" -o "$1" = "-h" ]; then
		printf "listzfs.sh [ARGUMENTS]\n"
		printf "\t--dataset -d\t\tSpecify dataset to show information about.\n"
		printf "\t--snapshotcounts -sc\tShow a count of snapshots per dataset.\n"
		printf "\t--more -m\t\tShow more information about datasets.\n"
		printf "\t--help -h\t\tShow this help text.\n"
		exit
	else
		printf "\tUnknown argument: $1\n\n"
	fi
done

#Determine what to display
if [ $SNAPSHOTCOUNTS ]; then
	#Display counts of snapshots
	zfs list  -t snapshot -o name -s name -r -H $DATASET | sed 's/@.*//' | uniq -c | head
else
	#Show more information about dataset
	if [ $MORE ]; then
	        printf "ZFS Dataset Info\n"
	        zfs list -r -t filesystem -o name,sync,primarycache,secondarycache,sharenfs $DATASET
	        printf "\n"
	fi
	
	#Show default data
	printf "ZFS Dataset Storage Info\n"
	zfs list -r -t filesystem -o name,mountpoint,quota,reservation,used,refer,avail,recordsize,compressratio,compression $DATASET
	printf "\n"

	#List encrypted dataset values
	printf "ZFS Encrypted Datasets\n"
	zfs list -r -t filesystem -o name,keystatus,keylocation,keyformat,encryption,mounted $DATASET | grep -v " - "
	printf "\n"

	#List ZVOLs
	printf "ZFS ZVOLs\n"
	zfs list -r -t volume -o name,used,refer,avail,volsize,volblocksize,compressratio,compression,logbias,sync,primarycache,secondarycache $DATASET
	printf "\n"

	#Show dedup status
	printf "Dedup Status\n"
	for i in $(zpool list -H -o name); do
		dedupstatus=$(zfs get dedup -H $i | cut -f 3)
		printf "$dedupstatus\t$i\n"
	done
	printf "\n"

	#List pools
	printf "ZPOOLs\n"
	zpool list
fi
