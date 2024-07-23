#!/bin/bash

# install.sh

# Check if script is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Update package lists
sudo apt update

# Install necessary dependencies
sudo apt install -y jq lsof net-tools nginx docker.io

# Create directory for DevOpsFetch
mkdir -p /opt/devopsfetch

# Copy the main script
cp devopsfetch.sh /opt/devopsfetch/devopsfetch.sh
echo "copied devopsfetch.sh to /opt/devopsfetch/devopsfetch.sh"
echo

# Make the script executable
chmod +x /opt/devopsfetch/devopsfetch.sh

# Create a symlink to make the script accessible system-wide
ln -s /opt/devopsfetch/devopsfetch.sh /usr/local/bin/devopsfetch
echo

# Copy systemd service file
cp devopsfetch.service /etc/systemd/system/devopsfetch.service
echo "devopsfetch.service copied to  /etc/systemd/system/devopsfetch.service"
echo

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
echo "daemon reloaded"

sudo systemctl enable devopsfetch.service
echo "devopsfetch.service enabled"

sudo systemctl start devopsfetch.service
echo "devopsfetch.service started"
echo

echo "devopsfetch has been installed successfully!"
echo "You can now use it by running 'devopsfetch' followed by the appropriate flags."
echo "The monitoring service has also been set up and started."