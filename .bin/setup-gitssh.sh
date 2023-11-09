#!/usr/bin/env bash

gitssh() {
    # if $1 is provided, save it to variable git_user, else return 1
    if [ -z "$1" ]; then
        echo "[-] No git user provided"
        return 1
    else
        git_user=$1
    fi

    echo "Adding SSH key for '$git_user'"
    
    ssh-add ~/.ssh/git_${git_user}_rsa > /dev/null 2>&1 && echo "[+] SSH key added" || echo "[-] SSH key NOT added" && return 1
    ssh -T git@github.com
}
