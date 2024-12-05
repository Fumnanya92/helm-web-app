#!/bin/bash

# Log user data execution
sudo bash -c 'exec > >(tee /var/log/userdata.log | logger -t user-data) 2>&1'
set -e  # Exit immediately if any command fails

# Marker to indicate successful setup
if [ -f /etc/instance-setup-complete ]; then
    echo "Setup already complete. Skipping."
    exit 0
fi

# Create marker immediately (requires root)
sudo touch /etc/instance-setup-complete

# Update the system
sudo yum update -y

# Jenkins installation
if ! command -v java &> /dev/null; then
    sudo dnf install java-17-amazon-corretto -y
fi

if ! command -v jenkins &> /dev/null; then
    sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    sudo yum upgrade
    sudo yum install jenkins -y
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
fi

# Docker installation
if ! command -v docker &> /dev/null; then
    sudo yum install -y docker
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker ec2-user  # Add user to the docker group
fi

# Ensure the docker group takes effect
newgrp docker <<EOF
    echo "Docker group applied. You can now use Docker without root."
EOF

if ! command -v kubectl &> /dev/null; then
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.27.4/bin/linux/amd64/kubectl
    sudo install kubectl /usr/local/bin/kubectl
fi

if ! command -v minikube &> /dev/null; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    minikube start
fi

# Validate Jenkins installation
if ! systemctl is-active --quiet jenkins; then
    echo "Jenkins installation failed."
    exit 1
fi

echo "Setup complete!"
