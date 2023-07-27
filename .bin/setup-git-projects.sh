#!/usr/bin/env bash

GIT_USERNAME="StoicTopG"

# Define a list of strings to search for my repository names
declare -a rootarr=("setup-everything" "notifio" "server-management" "code-templates" "components-setup" "materials" "minicodes")
declare -a healerarr=("healerdb" "healerdb-py" "healerenum" "healerex" "bbplats" "healerweb")

# Loop through the rootarr and git clone the repositories
mkdir -p /ptv
for i in "${rootarr[@]}"
do
    cd /ptv
    # Also include submodules 
    git clone git@github.com:$GIT_USERNAME/$i.git --recurse-submodules
    # If the command fails, then go to the next iteration
    if [ $? -ne 0 ]; then
        continue
    fi
    # Then in each of them globally switch to the main branch
    cd $i && git checkout main --recurse-submodules
done

# Loop through the healerarr and git clone the repositories
mkdir -p /ptv/healer
for i in "${healerarr[@]}"
do
    cd /ptv/healer
    # Also include submodules 
    git clone git@github.com:$GIT_USERNAME/$i.git --recurse-submodules
    # If the command fails, then go to the next iteration
    if [ $? -ne 0 ]; then
        continue
    fi
    # Then in each of them globally switch to the main branch
    cd $i && git checkout main --recurse-submodules 
done

echo "Done!"