#!/bin/bash
#First determine location
if [ "$1" != "" ]; then
        LOC="$1"
else
        echo "Using current working location: $PWD"
        LOC="$PWD"
fi
#CD into directory
cd "$LOC"
#Now get all .zips and rename them to .cbz
for i in "$LOC"/*.zip; do
        OLDNAME=`basename "$i"`
        echo "$OLDNAME"
        NAME=`basename "$i" ".zip"`
        NEWNAME="$NAME.cbz"
        echo " -> $NEWNAME"
        mv "$OLDNAME" "$NEWNAME"
done
