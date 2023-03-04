#!/usr/bin/env bash

# Iterate over all files and folders in /ptv directory recursively, if any folder's name is equal to ".bin" append it to PATH, if not already in path
for i in $(find /ptv -type d -name ".bin"); do
    if [[ ":$PATH:" != *":$i:"* ]]; then
        echo "Appending $i to PATH"
        export PATH="$PATH:$i"
    fi
done