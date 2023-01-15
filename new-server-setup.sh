#!/usr/bin/env bash

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run the script as root"
    exit
fi

# Check if the script is being run on Debian-based distro
if [ ! -f /etc/debian_version ]
then
    echo "This script is only for Debian-based distros"
    exit
fi

# Check the file /etc/resolv.conf, if there is not a line "nameserver 8.8.8.8", add it to the file and save it
echo "[+] Checking /etc/resolv.conf"
if ! grep -q "nameserver 8.8.8.8" /etc/resolv.conf
then
    echo "nameserver 8.8.8.8 is not in /etc/resolv.conf"
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
else
    echo "nameserver 8.8.8.8 is already in /etc/resolv.conf"
fi

### Make the file /etc/resolv.conf immutable so that it cannot be modified automatically by the system or services
# First Install the package "resolvconf"
echo "Installing resolvconf..."
apt install resolvconf -y > /dev/null 2>&1
# Edit the file /etc/resolvconf/resolv.conf.d/base and put lines of nameservers in it
echo "" > /etc/resolvconf/resolv.conf.d/base
echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/base
echo "nameserver 8.8.4.4" >> /etc/resolvconf/resolv.conf.d/base
echo "nameserver 1.1.1.1" >> /etc/resolvconf/resolv.conf.d/base
echo "nameserver 84.200.69.80" >> /etc/resolvconf/resolv.conf.d/base
echo "nameserver 84.200.70.40" >> /etc/resolvconf/resolv.conf.d/base
echo "nameserver 208.67.222.222" >> /etc/resolvconf/resolv.conf.d/base
echo "nameserver 208.67.220.220" >> /etc/resolvconf/resolv.conf.d/base
# Edit the file /etc/resolvconf/resolv.conf.d/head and put lines of nameservers in it
echo "" > /etc/resolvconf/resolv.conf.d/head
echo "" > /etc/resolvconf/resolv.conf.d/head
echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/head
echo "nameserver 8.8.4.4" >> /etc/resolvconf/resolv.conf.d/head
echo "nameserver 1.1.1.1" >> /etc/resolvconf/resolv.conf.d/head
echo "nameserver 84.200.69.80" >> /etc/resolvconf/resolv.conf.d/head
echo "nameserver 84.200.70.40" >> /etc/resolvconf/resolv.conf.d/head
echo "nameserver 208.67.222.222" >> /etc/resolvconf/resolv.conf.d/head
echo "nameserver 208.67.220.220" >> /etc/resolvconf/resolv.conf.d/head
# Update the resolvconf
resolvconf -u
# restart the resolvconf service
systemctl restart resolvconf
# Update the resolvconf
resolvconf -u

# ### Procedure: Check if the option/package is already installed or configured, and report the status, if not installed, install/configure it + add it to the list of installed packages + echo every step to the terminal with [+] , [-], [OK] or [FAIL] or [INFO] ###

# Create a temporary file to store the list of installed/configured packages
touch /tmp/installed-packages.txt

# Update and upgrade the system
echo "[+] Updating and upgrading the system (This may take a while)..."
apt update > /dev/null 2>&1 
apt full-upgrade -y > /dev/null 2>&1
echo "[OK] System updated and upgraded"
# echo a blank line, followed by a seperator
echo
echo "----------------------------------------"

# Install primary packages (echo each step to the terminal with [+] , [-], [OK] or [FAIL] or [INFO])
echo "[+] Installing primary packages"
echo "ssh git net-tools curl wget htop vim tmux nano ufw screen p7zip-full p7zip-rar rar unrar zip unzip bzip2 gzip tar python3 php python3-pip python3-venv jq" | xargs echo | xargs apt install -y > /dev/null 2>&1 && echo "[OK] Primary packages installed" || echo "[FAIL] Primary packages installation failed"
touch ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
echo ".venv" >> ~/.gitignore_global
echo ".venv/*" >> ~/.gitignore_global
echo "test/" >> ~/.gitignore_global
echo "temp/" >> ~/.gitignore_global
echo "tmp/" >> ~/.gitignore_global
echo "log" >> ~/.gitignore_global
echo "log/*" >> ~/.gitignore_global
echo "logs" >> ~/.gitignore_global
echo "logs/*" >> ~/.gitignore_global
echo "log.txt" >> ~/.gitignore_global
echo "logs.txt" >> ~/.gitignore_global
echo "log.log" >> ~/.gitignore_global
echo "logs.log" >> ~/.gitignore_global
echo "*.session" >> ~/.gitignore_global
echo "*.session-journal" >> ~/.gitignore_global
ecjho "*.bak" >> ~/.gitignore_global
# echo "ssh git net-tools curl wget htop vim tmux nano ufw screen p7zip-full p7zip-rar rar unrar zip unzip bzip2 gzip tar python3 php python3-pip python3-venv jq" | xargs apt install -y > /dev/null 2>&1 && echo "[OK] Primary packages installed" || echo "[-] Primary packages not installed"
echo 
echo "----------------------------------------"

### Install and/or configure secondary packages, which need to be configured and accepted bu user to install/configure
echo "[INFO] Installing and/or configuring secondary packages"
# Configure SSH
echo "[+] Checking SSH configuration"
# Check if the SSH is in /tmp/installed-packages.txt
if grep -Fxq "ssh" /tmp/installed-packages.txt
then
    echo "[INFO] SSH Status: Already installed/configured"
    read -p "Do you want to reconfigure SSH? [y/N] " -n 1 -r
    echo
    configure_ssh=$REPLY
else
    echo "[INFO] SSH Status: Not installed/configured"
    read -p "Do you want to configure SSH? [Y/n] " -n 1 -r 
    echo
    configure_ssh=$REPLY
fi
# If configure_ssh is empty, set it to "n"
if [ -z "$configure_ssh" ]
then
    configure_ssh="n"
fi
# If configure_ssh is "y" or "Y", configure SSH
if [[ $configure_ssh =~ ^[Yy]$ ]]
then
    # Read current SSH port from /etc/ssh/sshd_config
    current_ssh_port=$(cat /etc/ssh/sshd_config | grep -E '^Port' | grep -Eo '[0-9]+')
    # If current SSH port is empty, find a line starting with #Port
    if [ "$current_ssh_port" == "" ]
    then
        current_ssh_port=$(cat /etc/ssh/sshd_config | grep -E '^#Port' | grep -Eo '[0-9]+')
        if [ -z "$current_ssh_port" ]
        then
            # Add the line "Port 22" to /etc/ssh/sshd_config if it is not there
            echo "Port 22" >> /etc/ssh/sshd_config 
        else
            # Remove "#" from the line starting with #Port and set the port to 22 in /etc/ssh/sshd_config
            sed -i "s/#Port /Port /g" /etc/ssh/sshd_config 
        fi
    fi
    echo
    port_set=0 
    # While the port_set is not equal to 1, keep asking the user for a port number
    while [ $port_set -ne 1 ]; do
        # Ask the user which port they want to use for the ssh 
        echo -e "[+] What port do you want to use for ssh?\n\tNew port number between 1024 and 65535\n\tEnter 0 to keep the current port: $current_ssh_port]\n\tor 22 to use the default SSH port"
        read -p "Enter SSH port number: " ssh_port
        # If the user entered 0, keep the current port
        if [ $ssh_port -eq 0 ]
        then
            echo "[+] Keeping the current port : $current_ssh_port"
            port_set=1
        # else if user entered 22, set the port to 22
        elif [ $ssh_port -eq 22 ]
        then
            echo "[+] Setting the port to 22"
            ssh_port=22
            current_ssh_port=$ssh_port
            echo "Port $ssh_port" | sudo tee -a /etc/ssh/sshd_config
            port_set=1
        # If the user input is not a valid port number, show error and continue loop
        elif ! [[ "$ssh_port" =~ ^[0-9]+$ ]] || [ "$ssh_port" -lt 1025 ] || [ "$ssh_port" -gt 65535 ]
        then
            echo "[-] Error: Invalid port number, please enter a valid port number"
        # Check if the port is already in use
        elif [ $(sudo lsof -i -P -n | grep LISTEN | grep -c "$ssh_port") -eq 0 ]
        then
            # If the port is not in use, set Port in /etc/ssh/sshd_config to the port the user entered and set port_set to 1
            echo "Port $ssh_port" | sudo tee -a /etc/ssh/sshd_config
            current_ssh_port=$ssh_port
            port_set=1
        else
            # If the port is in use, ask the user for a different port number
            echo "[+] The port you entered is already in use, please enter a different port number"
        fi
    done
    echo "[+] SSH Port is set to $current_ssh_port"
    # Restart ssh
    systemctl restart ssh
    systemctl restart sshd
    echo "[OK] SSH is successfully configured"
    # Add ssh to /tmp/installed-packages.txt if it is not already in it
    if ! grep -Fxq "ssh" /tmp/installed-packages.txt
    then
        echo "ssh" >> /tmp/installed-packages.txt
    fi
else
    echo
    echo "[-] Ignoring SSH configuration"
fi
echo
echo "----------------------------------------"


# Install and configure docker
echo "[+] Checking docker configuration"
# Check if docker is in /tmp/installed-packages.txt
if grep -Fxq "docker" /tmp/installed-packages.txt
then
    echo "[INFO] Docker Status: Already installed/configured"
    read -p "Do you want to reconfigure docker? [y/N] " -n 1 -r
    echo
    configure_docker=$REPLY
else
    echo "[INFO] Docker Status: Not installed/configured"
    read -p "Do you want to configure docker? [Y/n] " -n 1 -r 
    echo
    configure_docker=$REPLY
fi
# If configure_docker is empty, set it to "n"
if [ -z "$configure_docker" ]
then
    configure_docker="n"
fi
# If configure_docker is "y" or "Y", configure docker
if [[ $configure_docker =~ ^[Yy]$ ]]
then
    ## Docker Installation
    echo "[+] Installing docker..."
    # Update the apt package index and install packages to allow apt to use a repository over HTTPS:
    apt update > /dev/null 2>&1
    apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release > /dev/null 2>&1
    # Add Docker’s official GPG key:
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    # Use the following command to set up the repository:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    # Update the apt package index, and install the latest version of Docker Engine, containerd, and Docker Compose, or go to the next step to install a specific version:
    apt update > /dev/null 2>&1
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin > /dev/null 2>&1
    # wait for docker to start
    echo "[+] Docker is installed, waiting for it to start..."
    sleep 3
    # Verify that Docker Engine is installed correctly by running the hello-world image.
    echo "[+] Verifying that Docker Engine is installed correctly by running the hello-world image..."
    docker run hello-world
    # wait 3 seconds
    sleep 3
    echo "[OK] Docker is successfully configured"
    # Add docker to /tmp/installed-packages.txt if it is not already there
    if ! grep -Fxq "docker" /tmp/installed-packages.txt
    then
        echo "docker" >> /tmp/installed-packages.txt
    fi
else
    echo
    echo "[-] Ignoring docker configuration"
fi
echo
echo "----------------------------------------"

# Install and configure docker-compose
echo "[+] Checking docker-compose configuration"
# Check if docker-compose is in /tmp/installed-packages.txt
if grep -Fxq "docker-compose" /tmp/installed-packages.txt
then
    echo "[INFO] Docker-compose Status: Already installed/configured"
    read -p "Do you want to reconfigure docker-compose? [y/N] " -n 1 -r
    echo
    configure_docker_compose=$REPLY
else
    echo "[INFO] Docker-compose Status: Not installed/configured"
    read -p "Do you want to configure docker-compose? [Y/n] " -n 1 -r 
    echo
    configure_docker_compose=$REPLY
fi
# If configure_docker_compose is empty, set it to "n"
if [ -z "$configure_docker_compose" ]
then
    configure_docker_compose="n"
fi
# If configure_docker_compose is "y" or "Y", configure docker-compose
if [[ $configure_docker_compose =~ ^[Yy]$ ]]
then
    echo "[+] Installing docker-compose..."
    # Install docker-compose
    apt install docker-compose -y > /dev/null 2>&1
    # wait for docker-compose to start
    echo "[+] Docker-compose is installed, waiting for it to start..."
    sleep 3
    # Verify that Docker Compose is installed correctly by running the version command.
    echo "[+] Verifying that Docker Compose is installed correctly by running the version command..."
    docker-compose --version
    # wait 3 seconds
    sleep 3
    echo "[OK] Docker-compose is successfully configured"
    # Add docker-compose to /tmp/installed-packages.txt if it is not already there
    if ! grep -Fxq "docker-compose" /tmp/installed-packages.txt
    then
        echo "docker-compose" >> /tmp/installed-packages.txt
    fi
else
    echo
    echo "[-] Ignoring docker-compose configuration"
fi
echo
echo "----------------------------------------"

# Install and setup ocserv 
echo "[+] Checking ocserv configuration"
# Check if ocserv is in /tmp/installed-packages.txt
if grep -Fxq "ocserv" /tmp/installed-packages.txt
then
    echo "[INFO] Ocserv Status: Already installed/configured"
    read -p "Do you want to reconfigure ocserv? [y/N] " -n 1 -r
    echo
    configure_ocserv=$REPLY
else
    echo "[INFO] Ocserv Status: Not installed/configured"
    read -p "Do you want to configure ocserv? [Y/n] " -n 1 -r 
    echo
    configure_ocserv=$REPLY
fi
# If configure_ocserv is empty, set it to "n"
if [ -z "$configure_ocserv" ]
then
    configure_ocserv="n"
fi
# If configure_ocserv is "y" or "Y", configure ocserv
if [[ $configure_ocserv =~ ^[Yy]$ ]]
then
    # Install ocserv
    echo "[+] Installing ocserv..."
    # Create directory for ocserv
    mkdir -p ~/.ocserv
    # Go to directory ~/.ocserv
    cd ~/.ocserv
    # Get the script from github using curl
    curl -O https://raw.githubusercontent.com/Autherix/ocserv-install-onekey/master/ocserv-install.sh
    # Make the script executable
    chmod +x ocserv-install.sh
    # Run the script and wait for it to finish
    ./ocserv-install.sh --auto
    # Go back to /ptv directory
    cd /ptv
    # Add ocserv to /tmp/installed-packages.txt if it is not already there
    if ! grep -Fxq "ocserv" /tmp/installed-packages.txt
    then
        echo "ocserv" >> /tmp/installed-packages.txt
    fi
else
    echo
    echo "[-] Ignoring ocserv configuration"
fi
echo
echo "----------------------------------------"

# Install and setup openvpn
echo "[+] Checking openvpn configuration"
# Check if openvpn is in /tmp/installed-packages.txt
if grep -Fxq "openvpn" /tmp/installed-packages.txt
then
    echo "[INFO] Openvpn Status: Already installed/configured"
    read -p "Do you want to reconfigure openvpn? [y/N] " -n 1 -r
    echo
    configure_openvpn=$REPLY
else
    echo "[INFO] Openvpn Status: Not installed/configured"
    read -p "Do you want to configure openvpn? [Y/n] " -n 1 -r 
    echo
    configure_openvpn=$REPLY
fi
# If configure_openvpn is empty, set it to "n"
if [ -z "$configure_openvpn" ]
then
    configure_openvpn="n"
fi
# If configure_openvpn is "y" or "Y", configure openvpn
if [[ $configure_openvpn =~ ^[Yy]$ ]]
then
    # Install openvpn
    apt install openvpn -y > /dev/null 2>&1
    # Create directory for openvpn
    mkdir -p ~/.openvpn
    # Go to directory ~/.openvpn
    cd ~/.openvpn
    # Get this script from github using curl
    curl -O https://raw.githubusercontent.com/Autherix/openvpn-install/master/openvpn-install.sh
    chmod +x openvpn-install.sh
    # Run the script and wait for it to finish
    ./openvpn-install.sh --auto
    # Add openvpn to /tmp/installed-packages.txt if it is not already there
    if ! grep -Fxq "openvpn" /tmp/installed-packages.txt
    then
        echo "openvpn" >> /tmp/installed-packages.txt
    fi
    # Go back to /ptv directory
    cd /ptv
else
    echo
    echo "[-] Ignoring openvpn configuration"
fi
echo
echo "----------------------------------------"

# Install and configure go
echo "[+] Checking go configuration"
# Check if go is in /tmp/installed-packages.txt
if grep -Fxq "go" /tmp/installed-packages.txt
then
    echo "[INFO] Go Status: Already installed/configured"
    read -p "Do you want to reconfigure go? [y/N] " -n 1 -r
    echo
    configure_go=$REPLY
else
    echo "[INFO] Go Status: Not installed/configured"
    read -p "Do you want to configure go? [Y/n] " -n 1 -r 
    echo
    configure_go=$REPLY
fi
# If configure_go is empty, set it to "n"
if [ -z "$configure_go" ]
then
    configure_go="n"
fi
# If configure_go is "y" or "Y", configure go
if [[ $configure_go =~ ^[Yy]$ ]]
then
    # Install go
    echo "[+] Installing go..."
    # wget this page : https://go.dev/dl/ and save to variable called go_dl_page
    go_dl_page=$(wget -qO- https://go.dev/dl/)
    # <a class="download downloadBox" href="/dl/go1.19.2.linux-amd64.tar.gz">
    # find a line that starts with <a class="download downloadBox" href="/dl/go and ends with linux-amd64.tar.gz"> and save to variable called go_dl_link_line
    go_dl_link_line=$(echo "$go_dl_page" | grep -E '^<a class="download downloadBox" href="/dl/go.*linux-amd64.tar.gz">')
    # get the link from the line 
    go_dl_link=$(echo "$go_dl_link_line" | grep -Eo 'href=".*"' | grep -Eo '/dl/go.*linux-amd64.tar.gz')
    # echo result link
    echo "go_dl_link: $go_dl_link"
    rm -rf index.html
    # Download go
    wget -O go.tar.gz https://go.dev"$go_dl_link" -q --show-progress
    # Clean installation, remove old go installation, command template : rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.2.linux-amd64.tar.gz
    rm -rf /usr/local/go && tar -C /usr/local -xzf go.tar.gz
    # Add go to path by adding the following line to /ptv/add_to_path.sh : export PATH=$PATH:/usr/local/go/bin, escape the $ with \$ , check if the line is already there, if not, add it
    if ! grep -q "export PATH=\$PATH:/usr/local/go/bin" /ptv/add_to_path.sh
    then
        echo "export PATH=\$PATH:/usr/local/go/bin" >> /ptv/add_to_path.sh
    fi
    # Add export PATH=$PATH:$HOME/go/bin to /ptv/add_to_path.sh if it is not already there
    if ! grep -q "export PATH=\$PATH:/ptv/go/bin" /ptv/add_to_path.sh
    then
        echo "export PATH=\$PATH:/ptv/go/bin" >> /ptv/add_to_path.sh
    fi
    # export GOROOT=/usr/local/go
    if ! grep -q "export GOROOT=/usr/local/go" /ptv/add_to_path.sh
    then
        echo "export GOROOT=/usr/local/go" >> /ptv/add_to_path.sh
    fi
    # Define GOPATH, GOROOT, GOBIN -> Add export GOPATH=$HOME/go to /ptv/add_to_path.sh
    if ! grep -q "export GOPATH=/ptv/go" /ptv/add_to_path.sh
    then
        echo "export GOPATH=/ptv/go" >> /ptv/add_to_path.sh
    fi
    # export GOPATH=$HOME/go
    if ! grep -q "export GOPATH=/ptv/go" /ptv/add_to_path.sh
    then
        echo "export GOPATH=/ptv/go" >> /ptv/add_to_path.sh
    fi
    # export GOBIN=$GOPATH/bin
    if ! grep -q "export GOBIN=/ptv/go/bin" /ptv/add_to_path.sh
    then
        echo "export GOBIN=/ptv/go/bin" >> /ptv/add_to_path.sh
    fi
    # Remove duplicate lines from /ptv/add_to_path.sh
    awk '!x[$0]++' /ptv/add_to_path.sh > /tmp/add_to_path.sh && mv /tmp/add_to_path.sh /ptv/add_to_path.sh
    # Source the file to add go to path
    source /ptv/add_to_path.sh
    # Clean up
    rm go.tar.gz
    # Get current go version 
    go version
    # Wait 3 seconds to make sure to add parent to path
    sleep 3
    # Add go to /tmp/installed-packages.txt if it is not already there
    if ! grep -Fxq "go" /tmp/installed-packages.txt
    then
        echo "go" >> /tmp/installed-packages.txt
    fi
else
    echo
    echo "[-] Ignoring go configuration"
fi
echo
echo "----------------------------------------"

# Install tools from github or go
echo "[+] Installing tools from github or go"
# Check if tools are in /tmp/installed-packages.txt
if grep -Fxq "tools" /tmp/installed-packages.txt
then
    echo "[INFO] Tools Status: Already installed/configured"
    read -p "Do you want to reconfigure tools? [y/N] " -n 1 -r
    echo
    configure_tools=$REPLY
else
    echo "[INFO] Tools Status: Not installed/configured"
    read -p "Do you want to configure tools? [Y/n] " -n 1 -r 
    echo
    configure_tools=$REPLY
fi
# If configure_tools is empty, set it to "n"
if [ -z "$configure_tools" ]
then
    configure_tools="n"
fi
# If configure_tools is "y" or "Y", configure tools
if [[ $configure_tools =~ ^[Yy]$ ]]
then
    # Install tools
    echo "[+] Installing tools from github or go tools..."
    # Install yq
    echo "[+] Installing yq..."
    go install github.com/mikefarah/yq/v4@latest > /dev/null 2>&1
    echo "[INFO] Installed yq"
    echo "-----"
    # Install amass
    echo "[+] Installing amass..."
    go install -v github.com/OWASP/Amass/v3/...@master > /dev/null 2>&1
    echo "[INFO] Installed amass"
    echo "-----"
    # Install nuclei
    echo "[+] Installing nuclei..."
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest > /dev/null 2>&1
    echo "[INFO] Installed nuclei"
    echo "-----"
    # Install subfinder
    echo "[+] Installing subfinder..."
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest > /dev/null 2>&1
    echo "[INFO] Installed subfinder"
    echo "-----"
    # Install httpx
    echo "[+] Installing httpx..."
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest > /dev/null 2>&1
    echo "[INFO] Installed httpx"
    echo "-----"

    # Add tools to /tmp/installed-packages.txt if it is not already there
    if ! grep -Fxq "tools" /tmp/installed-packages.txt
    then
        echo "tools" >> /tmp/installed-packages.txt
    fi
else
    echo
    echo "[-] Ignoring tools configuration"
fi
echo
echo "----------------------------------------"

# Configure bashrc, aliases, path
echo "[INFO] Configuring bashrc, aliases, path"
# Check if bashrc, aliases, path are in /tmp/installed-packages.txt
if grep -Fxq "bashrc, aliases, path" /tmp/installed-packages.txt
then
    echo "[INFO] Bashrc, aliases, path Status: Already installed/configured"
    read -p "Do you want to reconfigure bashrc, aliases, path? [y/N] " -n 1 -r
    echo
    configure_bashrc_aliases_path=$REPLY
else
    echo "[INFO] Bashrc, aliases, path Status: Not installed/configured"
    read -p "Do you want to configure bashrc, aliases, path? [Y/n] " -n 1 -r 
    echo
    configure_bashrc_aliases_path=$REPLY
fi
# If configure_bashrc_aliases_path is empty, set it to "n"
if [ -z "$configure_bashrc_aliases_path" ]
then
    configure_bashrc_aliases_path="n"
fi
# If configure_bashrc_aliases_path is "y" or "Y", configure bashrc, aliases, path
if [[ $configure_bashrc_aliases_path =~ ^[Yy]$ ]]
then

    # Configure bashrc, aliases, path
    echo "[+] Configuring bashrc, aliases, path..."


    # Create the file /ptv/add_to_bashrc.sh if it does not exist
    touch /ptv/add_to_bashrc.sh
    # If /ptv/add_to_bashrc.sh is empty, add the following lines to it: "#!/usr/bin/env bash\n\n"
    if [ ! -s /ptv/add_to_bashrc.sh ]
    then
        echo "#!/usr/bin/env bash" > /ptv/add_to_bashrc.sh
        echo "" >> /ptv/add_to_bashrc.sh
        echo "[+] Created /ptv/add_to_bashrc.sh and initialized it"
    fi
    # Add /ptv/add_to_bashrc.sh to ~/.bashrc if it is not already there
    if ! grep -q "source /ptv/add_to_bashrc.sh" ~/.bashrc
    then
        echo "source /ptv/add_to_bashrc.sh" >> ~/.bashrc
        echo "c" >> ~/.bashrc
    fi
    # Create the file /ptv/add_to_aliases.sh if it does not exist
    touch /ptv/add_to_aliases.sh
    # If /ptv/add_to_aliases.sh is empty, add this to it "#!/usr/bin/env bash\n\n"
    if [ ! -s /ptv/add_to_aliases.sh ]
    then
        echo "#!/usr/bin/env bash" > /ptv/add_to_aliases.sh
        echo "" >> /ptv/add_to_aliases.sh
        echo "[+] Created /ptv/add_to_aliases.sh and initialized it"
    fi
    # Add /ptv/add_to_aliases.sh to /ptv/add_to_bashrc.sh if it is not already there
    if ! grep -q "source /ptv/add_to_aliases.sh" /ptv/add_to_bashrc.sh
    then
        echo "source /ptv/add_to_aliases.sh" >> /ptv/add_to_bashrc.sh
    fi
    
    # Create the file /ptv/add_to_path.sh if it does not exist
    touch /ptv/add_to_path.sh
    # If /ptv/add_to_path.sh is empty, add this to it "#!/usr/bin/env bash\n\n"
    if [ ! -s /ptv/add_to_path.sh ]
    then
        echo "#!/usr/bin/env bash" > /ptv/add_to_path.sh
        echo "" >> /ptv/add_to_path.sh
        echo "[+] Created /ptv/add_to_path.sh and initialized it"
    fi
    # Add /ptv/add_to_path.sh to /ptv/add_to_bashrc.sh if it is not already there
    if ! grep -q "source /ptv/add_to_path.sh" /ptv/add_to_bashrc.sh
    then
        echo "source /ptv/add_to_path.sh" >> /ptv/add_to_bashrc.sh
    fi




    # Add these lines to /ptv/add_to_aliases.sh, use a for loop and just add each if not already there
    # Define a list of aliases
    aliases=(
        "alias ll='ls -l'"
        "alias ll='ls -l'"
        "alias la='ls -A'"
        "alias l='ls -CF'"
        "alias grep='grep --color=auto'"
        "alias egrep='egrep --color=auto'"
        "alias fgrep='fgrep --color=auto'"
        "alias subfinder='subfinder -silent'"
        "alias lll='ls -la'"
        "alias c='printf \"\\033c\" && ls'"
        "alias cl='printf \"\\033c\" && ls'"
        "alias cls='printf \"\\033c\" && ls'"
        "alias clearl='printf \"\\033c\" && ls'"
        "alias pysource='source ./.venv/bin/activate'"
        "alias pyfreeze='python3 -m pip freeze'"
    )
    # Loop through the aliases
    for alias in "${aliases[@]}"
    do
        # If the alias is not already in /ptv/add_to_aliases.sh, add it
        if ! grep -q "$(echo $alias)" /ptv/add_to_aliases.sh
        then
            echo "$alias" >> /ptv/add_to_aliases.sh
        fi
        # Remove the duplicated lines in /ptv/add_to_aliases.sh
        awk '!a[$0]++' /ptv/add_to_aliases.sh > /tmp/add_to_aliases.sh && mv /tmp/add_to_aliases.sh /ptv/add_to_aliases.sh
    done

    echo "[+] bashrc, aliases, and path setup complete"
    # Add "bashrc, aliases, path" to /tmp/installed-packages.txt if it is not already there
    if ! grep -q "bashrc, aliases, path" /tmp/installed-packages.txt
    then
        echo "bashrc, aliases, path" >> /tmp/installed-packages.txt
    fi
fi
echo
echo "----------------------------------------"


echo "done"
echo "----------------------------------------"
