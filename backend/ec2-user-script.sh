#!/bin/bash
set -e
# Update packages
yum update -y
# Enable Docker and install necessary packages
amazon-linux-extras enable docker
yum install -y docker git
# Start Docker and enable on boot
systemctl start docker
systemctl enable docker
# Add ec2-user to the docker group
usermod -aG docker ec2-user
# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
# Run app setup as ec2-user
cd /home/ec2-user
if [ ! -d app ]; then
    git clone https://github.com/Siva-2707/DalFitBot.git app
fi
cd app/backend
docker-compose up -d