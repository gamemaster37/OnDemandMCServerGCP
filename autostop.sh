#!/bin/bash

# Define the port number to check
PORT_NUMBER=32400

# Trap signals to avoid premature exit
trap '' HUP INT TERM

# Main function to check port and shutdown
check_and_shutdown() {
  # Check if netstat is available
  if ! command -v netstat &> /dev/null
  then
    echo "Error: netstat command not found. Please install netstat or use ss command (if available)."
    exit 1
  fi

  # Check for open connections on the port
  if netstat -atn | grep -q :$PORT_NUMBER; then
    echo "Port $PORT_NUMBER is in use."
  else
    echo "Port $PORT_NUMBER is not in use. Shutting down in 60 seconds..."
    # Shutdown command with 60 seconds timer
    systemctl poweroff
    exit 0
  fi
}

# Infinite loop to keep the daemon running (optional)
while true; do
    echo "Starting Watch"
    sleep 300 
    check_and_shutdown
done
