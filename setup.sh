#!/bin/bash

set -e

echo "============================================"
echo "Claude Voice Web Setup Script"
echo "============================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if base claude-voice is installed
echo -e "${YELLOW}Checking for base voice system...${NC}"
if ! voicemode whisper status &>/dev/null; then
    echo -e "${RED}Base voice system not found!${NC}"
    echo ""
    echo "Please install claude-voice first:"
    echo "  git clone https://github.com/masterbainter/claude-voice.git"
    echo "  cd claude-voice"
    echo "  ./setup.sh"
    echo ""
    exit 1
fi
echo -e "${GREEN}✓ Base voice system found${NC}"

# Check for Node.js
echo -e "${YELLOW}Checking for Node.js...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}Node.js not found. Please install Node.js first:${NC}"
    echo "  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"
    echo "  sudo apt install -y nodejs"
    echo ""
    echo "  Or visit: https://nodejs.org"
    exit 1
fi
echo -e "${GREEN}✓ Node.js found: $(node --version)${NC}"

# Check if services are running
echo -e "${YELLOW}Checking voice services...${NC}"
if ! curl -s http://127.0.0.1:2022/health &>/dev/null; then
    echo -e "${YELLOW}⚠ Whisper not running, starting...${NC}"
    voicemode whisper start
fi

if ! curl -s http://127.0.0.1:8880/health &>/dev/null; then
    echo -e "${YELLOW}⚠ Kokoro not running, starting...${NC}"
    cd ~/.voicemode/services/kokoro && bash start-cpu.sh &
    sleep 5
fi

echo -e "${GREEN}✓ Voice services ready${NC}"

# Install LiveKit server
echo ""
echo -e "${YELLOW}Installing LiveKit server...${NC}"
echo -e "${YELLOW}This requires sudo access${NC}"

if ! sudo -n true 2>/dev/null; then
    echo ""
    echo "Please enter your password for sudo access:"
fi

# Use full path to voicemode for sudo
VOICEMODE_PATH=$(which voicemode)
sudo -E env "PATH=$PATH" "$VOICEMODE_PATH" livekit install

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ LiveKit installation failed${NC}"
    echo ""
    echo "Try manual installation:"
    echo "  sudo voicemode livekit install"
    echo ""
    exit 1
fi

echo -e "${GREEN}✓ LiveKit server installed${NC}"

# Install LiveKit frontend
echo ""
echo -e "${YELLOW}Installing LiveKit frontend...${NC}"
echo -e "${YELLOW}This may take a few minutes...${NC}"

voicemode livekit frontend install

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Frontend installation failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Frontend installed${NC}"

# Configure firewall (optional)
echo ""
echo -e "${YELLOW}Do you want to configure firewall for network access? (y/N)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}Configuring firewall...${NC}"
    sudo ufw allow 3030/tcp
    sudo ufw allow 7880/tcp
    echo -e "${GREEN}✓ Firewall configured${NC}"
fi

# Start services
echo ""
echo -e "${YELLOW}Starting LiveKit services...${NC}"

voicemode livekit start
sleep 3

# Set PORT environment variable for frontend
export PORT=3030
voicemode livekit frontend start
sleep 3

# Get local IP
LOCAL_IP=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -1)

# Verify services
echo ""
echo -e "${YELLOW}Verifying services...${NC}"

if curl -s http://127.0.0.1:3030 &>/dev/null; then
    echo -e "${GREEN}✓ Frontend is running on port 3030${NC}"
else
    echo -e "${RED}✗ Frontend health check failed${NC}"
fi

if voicemode livekit status | grep -q "running"; then
    echo -e "${GREEN}✓ LiveKit server is running${NC}"
else
    echo -e "${RED}✗ LiveKit server check failed${NC}"
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "Access the web interface:"
echo -e "  ${YELLOW}Local:${NC}   http://localhost:3030"
if [ -n "$LOCAL_IP" ]; then
    echo -e "  ${YELLOW}Network:${NC} http://$LOCAL_IP:3030"
fi
echo ""
echo -e "Or open in browser automatically:"
echo -e "  ${YELLOW}xdg-open http://localhost:3030${NC}"
echo ""
echo -e "Access from phone/tablet:"
echo -e "  1. Connect to same WiFi network"
echo -e "  2. Open browser to http://$LOCAL_IP:3030"
echo -e "  3. Allow microphone access"
echo -e "  4. Start talking!"
echo ""
echo -e "Manage services:"
echo -e "  ${YELLOW}voicemode livekit status${NC}"
echo -e "  ${YELLOW}voicemode livekit frontend status${NC}"
echo -e "  ${YELLOW}voicemode livekit logs${NC}"
echo ""
