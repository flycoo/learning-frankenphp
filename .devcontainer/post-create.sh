#!/bin/bash
set -e

echo "Starting post-create setup..."

git config --global user.name "flycoo"
git config --global user.email "phpflycoo@gmail.com"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Customize bash prompt to show short directory name instead of full path
log_message "Setting up shortened bash prompt"
echo 'export PS1="\u@\h:\W\$ "' >> ~/.bashrc
log_message "Bash prompt customized to show short directory names"

# Ensure log directory is writable
# log_message "Setting up log directory permissions"
# sudo chmod 777 /var/log

# Fix Python symlink for VS Code compatibility
log_message "Ensuring Python symlink exists for VS Code compatibility"
if [ ! -L "/usr/bin/python" ] || [ "$(readlink /usr/bin/python)" != "/usr/bin/python3" ]; then
    log_message "Creating/updating Python symlink: /usr/bin/python -> /usr/bin/python3"
    sudo ln -sf /usr/bin/python3 /usr/bin/python
    log_message "Python symlink created successfully"
else
    log_message "Python symlink already exists and points to correct target"
fi

# Check if proxy is available by testing connectivity to multiple reliable sites
log_message "Checking proxy availability..."
# Function to check connectivity to a specific URL
check_connectivity() {
    local url=$1
    local timeout=$2
    local max_retries=$3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        if curl -s --connect-timeout $timeout -o /dev/null -w "%{http_code}" "$url" | grep -q "^[23]"; then
            return 0  # Connection successful
        fi
        retry_count=$((retry_count + 1))
        [ $retry_count -lt $max_retries ] && sleep 1
    done
    
    return 1  # Connection failed after all retries
}

check_connectivity "https://www.google.com" 5 3
check_connectivity "https://www.microsoft.com" 5 3
check_connectivity "https://www.github.com" 5 3

# Install dig (dnsutils) for DNS troubleshooting
log_message "Installing dnsutils for dig command"
sudo apt-get update && sudo apt-get install -y dnsutils
log_message "dnsutils installed successfully"

# Ensure Git ignores file mode (permission) changes
log_message "Configuring git to ignore file mode changes"
git config --global core.fileMode false || true
git config core.fileMode false || true
log_message "Git configured: core.fileMode=false"
