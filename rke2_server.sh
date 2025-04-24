#!/bin/bash

set -euo pipefail

echo "📥 Downloading and running the installer..."
curl -sfL https://get.rke2.io | sudo sh -

echo "✨ Enabling rke2-server.service..."
sudo systemctl enable rke2-server.service

echo "🚀 Starting rke2-server.service..."
sudo systemctl start rke2-server.service

echo "✅ RKE2 Server setup complete!"
echo "/etc/rancher/rke2/rke2.yaml"
sudo cat "/etc/rancher/rke2/rke2.yaml"
echo "/var/lib/rancher/rke2/server/node-token"
sudo cat "/var/lib/rancher/rke2/server/node-token"
