#!/bin/bash

# Function to check the package manager
get_package_manager() {
  if command -v apt &>/dev/null; then
    echo "apt"
  elif command -v yum &>/dev/null; then
    echo "yum"
  else
    echo "Unsupported package manager. Exiting."
    exit 1
  fi
}

# Get the package manager
package_manager=$(get_package_manager)

# Update the package list
if [ "$package_manager" = "apt" ]; then
  sudo apt update -y
elif [ "$package_manager" = "yum" ]; then
  sudo yum update -y
fi

# Install Python3 and Pip
if [ "$package_manager" = "apt" ]; then
  sudo apt install -y python3 python3-pip
elif [ "$package_manager" = "yum" ]; then
  sudo yum install -y python3 python3-pip
fi

# Upgrade Pip to the latest version
sudo -H pip3 install --upgrade pip

# Install some common Python packages (optional)
sudo -H pip3 install virtualenv virtualenvwrapper

echo "Python3 and Pip installation completed."
