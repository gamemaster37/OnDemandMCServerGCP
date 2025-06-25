#!/bin/bash

# Simple VM Autostop Setup
# Usage: sudo ./setup-vm-autostop.sh <container_name>

if [[ $EUID -ne 0 ]]; then
   echo "Run as root: sudo $0 <container_name>"
   exit 1
fi

if [[ -z "$1" ]]; then
    echo "Usage: sudo $0 <container_name>"
    exit 1
fi

CONTAINER_NAME="$1"

# Create monitoring script
cat > /opt/vm-autostop.sh << EOF
#!/bin/bash
CONTAINER_NAME="$CONTAINER_NAME"

while true; do
    sleep 180
    if ! docker ps --format "{{.Names}}" | grep -q "^\$CONTAINER_NAME\$"; then
        echo "Container \$CONTAINER_NAME stopped. Shutting down..."
        systemctl poweroff
    fi
done
EOF

chmod +x /opt/vm-autostop.sh

# Create service
cat > /etc/systemd/system/vm-autostop.service << EOF
[Unit]
Description=Autostop vm when container exits
After=docker.service

[Service]
ExecStart=/opt/vm-autostop.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
systemctl daemon-reload
systemctl enable vm-autostop
systemctl start vm-autostop

echo "Setup complete. Container '$CONTAINER_NAME' will trigger shutdown when it exits."
echo "Check status: systemctl status vm-autostop"