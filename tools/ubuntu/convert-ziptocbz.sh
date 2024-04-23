#!/bin/bash

DIR="$(pwd)"

for i in "$DIR"/*.zip; do
        OLDNAME=`basename "$i"`
        echo "$OLDNAME"
        NAME=`basename "$i" ".zip"`
        NEWNAME="$NAME.cbz"
        echo " -> $NEWNAME"
        mv "$OLDNAME" "$NEWNAME"
done
