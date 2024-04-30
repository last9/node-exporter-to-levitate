#!/bin/bash

set -e

# Define variables
levitate_username=${LEVITATE_USERNAME:-}
levitate_password=${LEVITATE_PASSWORD:-}
levitate_cluster_url=${LEVITATE_CLUSTER_URL:-}

# Verify Node Exporter is installed and running
echo "Verifying Node Exporter installation..."
if ! node_exporter --version &>/dev/null; then
    echo "Node Exporter is not installed or not working correctly. Please check the installation."
    exit 1
fi
echo "Node Exporter is verified."

# Check if necessary variables are set
if [ -z "$levitate_username" ] || [ -z "$levitate_password" ] || [ -z "$levitate_cluster_url" ]; then
    echo "Error: Necessary variables (LEVITATE_USERNAME or LEVITATE_PASSWORD or LEVITATE_CLUSTER_URL) are not set."
    exit 1
fi

# Replace variables in docker-compose file
echo "Setting up Docker Compose configuration..."
sed -i "s/\${levitate_username}/$levitate_username/g" docker-compose.yaml
sed -i "s/\${levitate_password}/$levitate_password/g" docker-compose.yaml
sed -i "s/\${levitate_cluster_url}/$levitate_cluster_url/g" docker-compose.yaml

# Verify replacements
if grep -q '${levitate_username}' docker-compose.yaml || grep -q '${levitate_password}' docker-compose.yaml || grep -q '${levitate_cluster_url}' docker-compose.yaml; then
    echo "Error: Failed to replace one or more variables in docker-compose.yaml."
    echo "Info: Manually replace the variables with actual values in docker-compose.yaml."
    exit 1
fi

# Run Docker Compose
echo "Running Docker Compose..."
docker-compose up -d
echo "Docker Compose is up and running."

