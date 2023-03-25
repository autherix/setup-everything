#!/usr/bin/env bash

# Create git global gitignore file if it does not exist
if [ ! -f ~/.gitignore_global ]
then
    echo "[+] Creating ~/.gitignore_global"
    touch ~/.gitignore_global
    # Set 777 permissions on ~/.gitignore_global
    chmod 777 ~/.gitignore_global
    # Add the following lines to ~/.gitignore_global
    echo ".venv/" >> ~/.gitignore_global
    echo "test/" >> ~/.gitignore_global
    echo "temp/" >> ~/.gitignore_global
    echo "tmp/" >> ~/.gitignore_global
    echo "venv/" >> ~/.gitignore_global
    echo "log/" >> ~/.gitignore_global
    echo "logs/" >> ~/.gitignore_global
    echo "log.txt" >> ~/.gitignore_global
    echo "logs.txt" >> ~/.gitignore_global
    echo "log.log" >> ~/.gitignore_global
    echo "logs.log" >> ~/.gitignore_global
    echo "*.session" >> ~/.gitignore_global
    echo "*.session-journal" >> ~/.gitignore_global
    echo "*.bak" >> ~/.gitignore_global
    echo "*/.venv/" >> ~/.gitignore_global
    echo "*/.venv/*" >> ~/.gitignore_global
    # Remove duplicate lines from ~/.gitignore_global
    awk '!a[$0]++' ~/.gitignore_global > /tmp/gitignore_global && mv /tmp/gitignore_global~/.gitignore_global
    git config --global core.excludesfile ~/.gitignore_global
fi