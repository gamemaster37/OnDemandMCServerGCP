#!/bin/bash

# GCP Compute Engine startup script to start a Docker container by name
# Usage: Set CONTAINER_NAME below or override with /etc/default/container_name

CONTAINER_NAME="paper-mc"  # Change this to your container name

# Optionally override from instance metadata file
if [[ -f /etc/default/container_name ]]; then
    CONTAINER_NAME=$(cat /etc/default/container_name)
fi

# Wait for Docker daemon to be ready
until docker info >/dev/null 2>&1; do
    sleep 1
done

# Check if the container exists
if ! docker ps -a --format '{{.Names}}' | grep -wq "$CONTAINER_NAME"; then
    echo "Container '$CONTAINER_NAME' does not exist."
    exit 1
fi

# Start the container if not running
if ! docker ps --format '{{.Names}}' | grep -wq "$CONTAINER_NAME"; then
    echo "Starting container: $CONTAINER_NAME"
    docker start "$CONTAINER_NAME"
else
    echo "Container '$CONTAINER_NAME' is already running."
fi