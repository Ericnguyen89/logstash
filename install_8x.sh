#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Detect the Linux distribution
if command -v apt-get &>/dev/null; then
    # Debian/Ubuntu
    package_manager="apt-get"
    install_command="install -y"
elif command -v yum &>/dev/null; then
    # CentOS
    package_manager="yum"
    install_command="install -y"
else
    echo "Unsupported Linux distribution."
    exit 1
fi

# Install Java (if not already installed)
$package_manager $install_command default-jre

# Download and install Logstash
if [[ $package_manager == "apt-get" ]]; then
    wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
    sh -c 'echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" > /etc/apt/sources.list.d/logstash-8.x.list'
elif [[ $package_manager == "yum" ]]; then
    rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
    echo "[logstash-8.x]" > /etc/yum.repos.d/logstash.repo
    echo "name=Elastic repository for 8.x packages" >> /etc/yum.repos.d/logstash.repo
    echo "baseurl=https://artifacts.elastic.co/packages/8.x/yum" >> /etc/yum.repos.d/logstash.repo
    echo "gpgcheck=1" >> /etc/yum.repos.d/logstash.repo
    echo "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch" >> /etc/yum.repos.d/logstash.repo
    echo "enabled=1" >> /etc/yum.repos.d/logstash.repo
    echo "autorefresh=1" >> /etc/yum.repos.d/logstash.repo
    echo "type=rpm-md" >> /etc/yum.repos.d/logstash.repo
fi

$package_manager update -y
$package_manager $install_command logstash

# Start Logstash as a service
systemctl start logstash
systemctl enable logstash

echo "Logstash has been installed and started as a service."
