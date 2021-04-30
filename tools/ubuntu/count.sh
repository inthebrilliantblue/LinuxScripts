#!/bin/bash
#First determine location
if [ "$1" != "" ]; then
        LOC="$1"
else
        echo "Using current working location: $PWD"
        LOC="$PWD"
fi
#Count files
FILES=$(find "$LOC" -type f | wc -l)
echo "Files:            $FILES"
#Count Directories
DIR=$(find "$LOC" -type d | wc -l)
echo "Directories:      $DIR"
