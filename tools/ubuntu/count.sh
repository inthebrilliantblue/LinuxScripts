#!/bin/bash
#Count files
FILES=$(find "$1" -type f | wc -l)
echo "Files:            $FILES"
#Count Directories
DIR=$(find "$1" -type d | wc -l)
echo "Directories:      $DIR"
