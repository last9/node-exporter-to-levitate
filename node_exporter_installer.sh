#!/bin/bash

set -e 

# Define Node Exporter version
NODE_EXPORTER_VERSION="1.8.0"
NODE_EXPORTER_USER="node_exporter"

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Execute the Docker installer script
echo "Executing Docker installation script..."
./docker_installer.sh

# Verify Docker installation
echo "Verifying Docker installation..."
if ! command -v docker >/dev/null 2>&1; then
    echo "Docker installation failed. Exiting."
    exit 1
fi

# Verify Docker Compose installation
echo "Verifying Docker Compose installation..."
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "Docker Compose installation failed. Exiting."
    exit 1
fi

# Create user for node exporter if it doesn't exist
if ! id "$NODE_EXPORTER_USER" &>/dev/null; then
    useradd --no-create-home --shell /bin/false $NODE_EXPORTER_USER
fi

# Download and install Node Exporter
echo "Downloading Node Exporter v$NODE_EXPORTER_VERSION..."
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

echo "Extracting Node Exporter..."
tar xvfz node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

echo "Moving Node Exporter to /usr/local/bin..."
cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin

echo "Setting ownership..."
chown $NODE_EXPORTER_USER:$NODE_EXPORTER_USER /usr/local/bin/node_exporter

echo "Cleaning up..."
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64

# Setup systemd service
cat << EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$NODE_EXPORTER_USER
Group=$NODE_EXPORTER_USER
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the Node Exporter service
echo "Reloading systemd manager configuration..."
systemctl daemon-reload
echo "Enabling Node Exporter service..."
systemctl enable node_exporter
echo "Starting Node Exporter service..."
systemctl start node_exporter

echo "Node Exporter installation is complete."
