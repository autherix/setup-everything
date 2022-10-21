#!/usr//bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Make sure the srcipt is not root, if it is, exit with error
if [[ $EUID -eq 0 ]]; then
   echo "This script must not be run as root, please run as your common user" 1>&2
   exit 1
fi

# Check whether git is installed, if not, show error and exit
if ! command -v git &> /dev/null
then
    echo "git could not be found, please install git and try again"
    exit 1
fi

# Check whether ssh is installed, if not, install it
if  dpkg --get-selections | grep -q '^ssh[[:space:]]*install$' 
then echo "[INFO] SSH is already installed!"
else
    echo  "[INFO] SSH is not installed, Installing it now..."
    apt update
    apt install -y ssh
    echo "[+] SSH is installed!"
fi

# Configure Git
git config --global user.name "autherix"
git config --global user.email "105848507+Autherix@users.noreply.github.com" 
git config --global core.editor "vim"
git config --global init.defaultBranch main

# Ask the user for the address of private key file, or the content of private key file itself
echo  -e "[...] Please enter the address of private key file,\n\tOr the content of private key file itself,\n\tOr just enter %key% to create a new key pair,\n\tOr just 0 to ignore this step: "
read -r private_key
echo
echo "----------------------------------------"
# Set variable ssh_pvt_key_done to 0
ssh_pvt_key_done=0
# While ssh_pvt_key_done is 0, do the following:
while [ $ssh_pvt_key_done -eq 0 ]
do
    # Check whether the private key is a file or not, if it is a file, then copy it to ~/.ssh/git_autherix_rsa, if not, then create a file and write the content of private key to it on ~/.ssh/git_autherix_rsa
    if [ -f "$private_key" ]
    then
        echo "[INFO] The private key is a file, validating it..."
        # Check if the content of the file starts with "-----BEGIN OPENSSH PRIVATE KEY-----" on first line, and ends with "-----END OPENSSH PRIVATE KEY-----" on last line, if not, echo error
        if [[ $(head -n 1 "$private_key") == "-----BEGIN OPENSSH PRIVATE KEY-----" ]] && [[ $(tail -n 1 "$private_key") == "-----END OPENSSH PRIVATE KEY-----" ]]
        then
            echo "[+] The private key file validated, copying it to ~/.ssh/git_autherix_rsa"
            echo "[INFO] Creating ~/.ssh directory if it does not exist..."
            mkdir -p ~/.ssh
            echo "[INFO] Copying the private key file to ~/.ssh/git_autherix_rsa if not already there ..."
            cp -n "$private_key" ~/.ssh/git_autherix_rsa
            echo "[+] The private key is copied to ~/.ssh/git_autherix_rsa"
            # Set 600 permission to the private key file
            echo "[INFO] Setting 600 permission to the private key file..."
            chmod 600 ~/.ssh/git_autherix_rsa
            echo "[+] 600 permission is set to the private key file"
            # Set ssh_pvt_key_done to 1
            ssh_pvt_key_done=1
        else
            echo "[ERROR] The content of the file is not a valid private key!"
        fi
    else
        # If the private key is not a file,check if it is 0, break the while, else if check if it is %key%, if it is, then create a new key pair in ~/.ssh/git_autherix_rsa, if not, then create a file and write the content of private key to it on ~/.ssh/git_autherix_rsa
        if [ "$private_key" == "0" ]
        then
            echo "[INFO] Private key input ignored, breaking the loop..."
            break
        elif [ "$private_key" = "%key%" ]
        then
            echo "[INFO] Generating a new key pair in ~/.ssh/git_autherix_rsa"
            ssh-keygen -t rsa -C "github.com/autherix" -f "$HOME/.ssh/git_autherix_rsa" -P ""
            echo
            echo "----------------------------------------"
            # echo the content of public key file
            echo "[+] The content of public key file is:"
            echo "----------------------------------------"
            cat ~/.ssh/git_autherix_rsa.pub
            echo "----------------------------------------"
            echo
            # Set 755 permission to the Public Key file and 600 permission to the Private Key file
            chmod 755 ~/.ssh/git_autherix_rsa.pub
            chmod 600 ~/.ssh/git_autherix_rsa
            # Set ssh_pvt_key_done to 1
            ssh_pvt_key_done=1
        else
            echo "[INFO] The private key is not a file, creating a file and writing the content of private key to it on ~/.ssh/git_autherix_rsa"
            # Validate if the private key begins with "-----BEGIN OPENSSH PRIVATE KEY-----" on first line, and ends with "-----END OPENSSH PRIVATE KEY-----" on last line, if not, echo error
            if [[ $(head -n 1 <<< "$private_key") == "-----BEGIN OPENSSH PRIVATE KEY-----" ]] && [[ $(tail -n 1 <<< "$private_key") == "-----END OPENSSH PRIVATE KEY-----" ]]
            then
                echo "[+] The private key content is validated, creating a file and writing the content of private key to it on ~/.ssh/git_autherix_rsa"
                echo "[INFO] Creating ~/.ssh directory if it does not exist..."
                mkdir -p ~/.ssh
                echo "[INFO] Creating a file and writing the content of private key to it on ~/.ssh/git_autherix_rsa if not already there ..."
                echo "$private_key" > ~/.ssh/git_autherix_rsa
                # Set 600 permission to the Private Key file
                chmod 600 ~/.ssh/git_autherix_rsa
                echo "[+] The private key is written to ~/.ssh/git_autherix_rsa"
                # Set ssh_pvt_key_done to 1
                ssh_pvt_key_done=1
            else
                echo "[ERROR] The content of the file is not a valid private key!"
            fi
        fi
    fi
done
echo 
echo "----------------------------------------"
# Add these lines to /ptv/add_to_bashrc.sh if not already there: "eval $(ssh-agent -s)", "ssh-add ~/.ssh/git_autherix_rsa", "ssh-add -l", "ssh -T git@github.com"
echo -e "[+] Adding these lines to /ptv/add_to_bashrc.sh if not already there:\n\t'eval \$(ssh-agent -s)',\n\t'ssh-add ~/.ssh/git_autherix_rsa',\n\t'ssh-add -l',\n\t'ssh -T git@github.com'"
echo
if ! grep -q "eval \$(ssh-agent -s)" /ptv/add_to_bashrc.sh
then
    echo "eval \$(ssh-agent -s)" >> /ptv/add_to_bashrc.sh
    echo -e "[+] Added 'eval \$(ssh-agent -s)'\t\tto /ptv/add_to_bashrc.sh"
else 
    echo -e "[INFO] 'eval \$(ssh-agent -s)'\t\t\tis already in /ptv/add_to_bashrc.sh"
fi
if ! grep -q "ssh-add ~/.ssh/git_autherix_rsa" /ptv/add_to_bashrc.sh
then
    echo "ssh-add ~/.ssh/git_autherix_rsa" >> /ptv/add_to_bashrc.sh
    echo -e "[+] Added 'ssh-add ~/.ssh/git_autherix_rsa'\tto /ptv/add_to_bashrc.sh"
else
    echo -e "[INFO] 'ssh-add ~/.ssh/git_autherix_rsa'\tis already in /ptv/add_to_bashrc.sh"
fi
if ! grep -q "ssh-add -l" /ptv/add_to_bashrc.sh
then
    echo "ssh-add -l" >> /ptv/add_to_bashrc.sh
    echo -e "[+] Added 'ssh-add -l'\t\t\t\tto /ptv/add_to_bashrc.sh"
else
    echo -e "[INFO] 'ssh-add -l'\t\t\t\tis already in /ptv/add_to_bashrc.sh"
fi
if ! grep -q "ssh -T git@github.com" /ptv/add_to_bashrc.sh
then
    echo "ssh -T git@github.com" >> /ptv/add_to_bashrc.sh
    echo -e "[+] Added 'ssh -T git@github.com'\t\tto /ptv/add_to_bashrc.sh"
else
    echo -e "[INFO] 'ssh -T git@github.com'\t\t\tis already in /ptv/add_to_bashrc.sh"
fi

echo "Close the terminal and open a new one after adding the public key to your GitHub account"
echo
echo "----------------------------------------"
echo 
echo "done"
echo 
echo "----------------------------------------"
