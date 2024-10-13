#!/bin/bash

# Variables
DOMAIN_NAME=$(hostname -f)  # Get the fully qualified domain name (FQDN) of the server
DB_NAME=$(hostname | sed 's/\./_/g')  # Database name based on FQDN, replace dots with underscores
DB_USER=$(hostname | sed 's/\./_/g')  # Database user based on FQDN
DB_PASSWORD=$(openssl rand -base64 24)  # Generate random password for the database
DB_ROOT_PASSWORD=$(openssl rand -base64 24)  # Generate random root password for the database
ADMIN_USER=$(hostname)  # Admin user based on short hostname
ADMIN_PASSWORD=$(openssl rand -base64 24)  # Generate random password for admin user
RECIPIENT_EMAIL="your-email@example.com"  # Email to send server details

# Update the system
sudo apt update

# Install Docker
sudo apt install -y docker.io git

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install mailutils to send emails
sudo apt install -y mailutils

# Add admin user and set password
sudo useradd -m $ADMIN_USER
echo "$ADMIN_USER:$ADMIN_PASSWORD" | sudo chpasswd

# Add admin user to the docker group for permission to run Docker commands
sudo usermod -aG docker $ADMIN_USER

# Switch to admin user's home directory
cd /home/$ADMIN_USER

# Clone the Docker Compose template from GitHub
git clone https://github.com/favoritemuse/server-template.git

# Change directory to the cloned repository
cd server-template

# Create required directories for website and logs
mkdir -p ./website ./logs/nginx ./logs/php

# Save passwords and database information into .env file
echo "DB_NAME=${DB_NAME}" >> .env
echo "DB_USER=${DB_USER}" >> .env
echo "DB_PASSWORD=${DB_PASSWORD}" >> .env
echo "DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}" >> .env

# Replace placeholder domain name in Nginx configuration with the actual domain name
sed -i "s/your-domain.com/$DOMAIN_NAME/g" nginx.conf

# Change ownership of the template files to the admin user
sudo chown -R $ADMIN_USER:$ADMIN_USER /home/$ADMIN_USER/server-template

# Navigate to the directory where docker-compose.yml is located
cd /home/$ADMIN_USER/server-template

# Bring up the Docker containers using Docker Compose
docker-compose up -d

# Create a message with server details
MESSAGE="Server setup is complete.\n\nDomain: $DOMAIN_NAME\nDatabase Name: $DB_NAME\nDatabase User: $DB_USER\nDatabase Password: $DB_PASSWORD\nRoot Password: $DB_ROOT_PASSWORD\n\nAdmin User: $ADMIN_USER\nAdmin Password: $ADMIN_PASSWORD"

# Send the message to the specified email
echo -e "$MESSAGE" | mail -s "New Server Setup Details" $RECIPIENT_EMAIL

# Print out important information such as domain, DB user, and DB password
echo "Installation complete. Domain: $DOMAIN_NAME, Database User: $DB_USER, Database Password: $DB_PASSWORD, Admin User: $ADMIN_USER"
