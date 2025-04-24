#!/bin/bash

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "🚀 Usage: $0 <SERVER_IP_ADDRESS> <NODE_TOKEN>"
  exit 1
fi

SERVER_IP_ADDRESS="$1"
NODE_TOKEN="$2"

echo "📥 Downloading and running the agent installer..."
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sudo sh -

echo "✨ Enabling rke2-agent service..."
sudo systemctl enable rke2-agent.service

echo "📝 Writing config.yaml..."
sudo mkdir -p /etc/rancher/rke2/
sudo tee /etc/rancher/rke2/config.yaml > /dev/null <<EOF
server: "https://${SERVER_IP_ADDRESS}:9345"
token: ${NODE_TOKEN}
EOF

echo "🚀 Starting rke2-agent service..."
sudo systemctl start rke2-agent.service

echo "✅ RKE2 Agent setup complete!"