#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Starting Docker and Dockge installation..."

# 1. Install Docker using the official convenience script
echo "📦 Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# 2. Manage Docker as non-root user
echo "👤 Adding current user to the Docker group..."
sudo usermod -aG docker $USER

# 3. Create Dockge directories and set permissions
echo "📁 Creating directories at /opt/stacks and /opt/dockge..."
sudo mkdir -p /opt/stacks /opt/dockge
sudo chown -R $USER:$USER /opt/stacks /opt/dockge 

# 4. Move to dockge directory
cd /opt/dockge

# 5. Write the optimized compose.yaml file directly
echo "⚙️ Creating compose.yaml configuration..."
cat << 'EOF' > compose.yaml
services:
  dockge:
    image: louislam/dockge:1
    restart: unless-stopped
    ports:
      - 5001:5001
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /opt/dockge/data:/app/data
      - /opt/stacks:/opt/stacks
    environment:
      - DOCKGE_STACKS_DIR=/opt/stacks
EOF

# 6. Start Dockge using 'sg' to bypass the need for a reboot/re-log right now
echo "🐳 Spinning up Dockge container..."
sg docker -c "docker compose up -d"

# 7. Verify the installation
echo "🔍 Verifying running containers..."
sg docker -c "docker ps -a"

echo "--------------------------------------------------------"
echo "🎉 Installation Complete!"
echo "🌐 You can now access Dockge at http://$(hostname -I | awk '{print $1}'):5001"
echo "⚠️  CRITICAL STEP: Please close this terminal or log out/in"
echo "   so your user group changes take effect permanently."
echo "--------------------------------------------------------"
