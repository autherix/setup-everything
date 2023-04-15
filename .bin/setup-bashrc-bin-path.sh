#!/usr/bin/env bash
# Iterate over all files and folders in /ptv directory recursively, if any folder's name is equal to ".bin" append it to PATH, if not already in path
for i in $(find /ptv -type d -name ".bin"); do
    if [[ ":$PATH:" != *":$i:"* ]]; then
        # If not ending with */node_modules/.bin then append it to PATH
        if [[ ! $i =~ .*node_modules/.bin$ ]]; then 
            # the dot before * is important to match the last part of the string
            echo "Appending $i to PATH"
            # sleep 2
            export PATH="$PATH:$i"
        fi
    fi
done