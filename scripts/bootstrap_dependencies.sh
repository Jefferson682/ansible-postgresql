#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <environment>"
  exit 1
fi

ENVIRONMENT=$1

# Determine inventory file based on environment
INVENTORY_FILE="inventories/$ENVIRONMENT/inventory.ini"
if [ ! -f "$INVENTORY_FILE" ]; then
  echo "Inventory file for environment '$ENVIRONMENT' not found."
  exit 1
fi

# Extract the first host and user from the inventory file
HOST=$(grep -Eo 'ansible_host=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$INVENTORY_FILE" | cut -d '=' -f 2 | head -n 1)
USER=$(grep -Eo 'ansible_user=\w+' "$INVENTORY_FILE" | cut -d '=' -f 2 | head -n 1)

if [ -z "$HOST" ] || [ -z "$USER" ]; then
  echo "Could not determine host or user from inventory file."
  exit 1
fi

# Prompt for sudo password
read -sp "Enter sudo password for $USER@$HOST: " SUDO_PASSWORD
echo

# Copy SSH key to the remote host
if ! ssh -o PasswordAuthentication=no "$USER@$HOST" exit 2>/dev/null; then
  echo "Copying SSH key to $HOST..."
  ssh-copy-id "$USER@$HOST"
else
  echo "SSH key already exists on $HOST."
fi

# Install Python and dependencies on the remote host
ssh "$USER@$HOST" <<EOF
  echo "$SUDO_PASSWORD" > /tmp/sudo_pass
  chmod 600 /tmp/sudo_pass

  echo "Updating package manager and installing Python dependencies..."

  if [ -f /etc/redhat-release ]; then
    sudo -S -k -p "" -u root -S < /tmp/sudo_pass yum install -y python3 python3-pip
  elif [ -f /etc/debian_version ]; then
    sudo -S -k -p "" -u root -S < /tmp/sudo_pass apt update && sudo -S -k -p "" -u root -S < /tmp/sudo_pass apt install -y python3 python3-pip
  else
    echo "Unsupported OS. Exiting."
    exit 1
  fi

  echo "Installing Python module 'six'..."
  sudo -S -k -p "" -u root -S < /tmp/sudo_pass pip3 install six

  rm -f /tmp/sudo_pass
EOF

echo "Dependencies installed successfully on $HOST."