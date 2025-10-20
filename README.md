# Claude Voice Web

Web interface for Claude Code voice conversations - access from your phone or laptop browser.

This project extends [claude-voice](https://github.com/masterbainter/claude-voice) with a web-based interface using LiveKit.

## Features

- **Web Browser Access**: Use voice from phone, tablet, or laptop browser
- **Remote Access**: Access Claude Code from anywhere on your network
- **Same Local Backend**: Uses the same Whisper + Kokoro setup
- **Real-time Communication**: LiveKit WebRTC for low-latency audio
- **Multiple Devices**: Connect from multiple devices simultaneously

## Prerequisites

All prerequisites from [claude-voice](https://github.com/masterbainter/claude-voice) plus:

- **Node.js** (for frontend build)
- **sudo access** (for LiveKit installation)
- **Network access** (for remote device connections)

## Quick Start

```bash
# Clone and run setup
git clone https://github.com/masterbainter/claude-voice-web.git
cd claude-voice-web
./setup.sh
```

Then access from your browser:
- **Local**: http://localhost:3000
- **Network**: http://YOUR_IP:3000 (from phone/tablet)

## Manual Installation

### 1. Install Base Voice System

First, install the base voice system:

```bash
# Install claude-voice
git clone https://github.com/masterbainter/claude-voice.git
cd claude-voice
./setup.sh
cd ..
```

### 2. Install LiveKit Server

```bash
sudo voicemode livekit install
```

This installs the LiveKit server for WebRTC communication.

### 3. Install LiveKit Frontend

```bash
voicemode livekit frontend install
```

This installs the web interface with:
- React-based UI
- WebRTC audio handling
- Mobile-responsive design

### 4. Start Services

**Start all voice services:**
```bash
# Start Whisper (if not running)
voicemode whisper start

# Start Kokoro (if not running)
cd ~/.voicemode/services/kokoro
bash start-cpu.sh &

# Start LiveKit server
voicemode livekit start

# Start web frontend
voicemode livekit frontend start
```

### 5. Access Web Interface

**From local machine:**
```
http://localhost:3000
```

**From phone/tablet on same network:**
```
http://YOUR_LOCAL_IP:3000
```

Find your local IP:
```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

## Usage

### Connect from Browser

1. Open browser and navigate to the web interface
2. Allow microphone permissions when prompted
3. Click "Connect" to join voice room
4. Start speaking - Claude will respond with voice!

### Access from Phone

1. Connect phone to same WiFi network as your computer
2. Open browser on phone (Safari, Chrome, etc.)
3. Navigate to `http://YOUR_COMPUTER_IP:3000`
4. Allow microphone access
5. Tap "Connect" and start talking

### Access from Laptop

1. Connect laptop to same network
2. Open browser
3. Navigate to the web interface URL
4. Start voice conversation

## Architecture

```
┌─────────────────┐
│  Phone Browser  │
│   Tablet/Laptop │
└────────┬────────┘
         │ WebRTC
         ↓
┌─────────────────┐
│ LiveKit Server  │ (Port 7880)
│   WebRTC Room   │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Voice Backend  │
│  Whisper + TTS  │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│   Claude Code   │
│  (via MCP)      │
└─────────────────┘
```

## Configuration

### Frontend Port

Default: `3000`

Change in `~/.voicemode/config.yaml`:
```yaml
livekit:
  frontend:
    port: 3000
```

### LiveKit Server

Default: `localhost:7880`

For remote access, configure in `~/.voicemode/services/livekit/config.yaml`:
```yaml
port: 7880
bind_addresses:
  - "0.0.0.0"  # Listen on all interfaces
```

### Network Access

**Allow through firewall:**
```bash
# Frontend
sudo ufw allow 3000/tcp

# LiveKit server
sudo ufw allow 7880/tcp
```

## Commands

```bash
# Check LiveKit status
voicemode livekit status

# Start/stop LiveKit
voicemode livekit start
voicemode livekit stop

# Frontend commands
voicemode livekit frontend start
voicemode livekit frontend stop
voicemode livekit frontend status

# View logs
voicemode livekit logs
voicemode livekit frontend logs

# Open in browser
voicemode livekit frontend open
```

## Troubleshooting

### Can't Connect from Phone

1. **Check same network**: Ensure phone is on same WiFi
2. **Check firewall**: Allow port 3000
3. **Check IP address**: Use correct local IP, not 127.0.0.1
4. **Try HTTPS**: Some browsers require HTTPS for microphone

### Microphone Not Working

1. **Allow permissions**: Check browser settings
2. **Check device**: Test microphone in other apps
3. **HTTPS required**: Some browsers need HTTPS for mic access

### LiveKit Not Starting

```bash
# Check if port is in use
sudo lsof -i :7880

# View detailed logs
journalctl --user -u voicemode-livekit -n 50
```

### Frontend Won't Load

```bash
# Check Node.js installed
node --version

# Reinstall frontend
voicemode livekit frontend install

# Check logs
voicemode livekit frontend logs
```

## Performance

**Local Network:**
- Latency: ~50-200ms (excellent)
- Audio quality: High (48kHz supported)

**Performance same as CLI:**
- STT (Whisper): ~11-14 seconds (CPU)
- TTS (Kokoro): ~3-5 seconds
- Network overhead: Minimal

## Security Notes

**⚠️ Important:**

- Web interface has **NO authentication** by default
- Anyone on your network can access it
- Do NOT expose to the internet without authentication
- Use VPN for remote access outside your network

**To secure:**

1. Use firewall to restrict access
2. Run behind reverse proxy with auth (nginx, caddy)
3. Use VPN for remote access
4. Consider LiveKit Cloud for production use

## Development

### Build Frontend

```bash
cd ~/.voicemode/services/livekit-frontend
npm install
npm run build
```

### Run in Dev Mode

```bash
npm run dev
```

## Cloud Option

For internet access without self-hosting:

1. Sign up for [LiveKit Cloud](https://livekit.io)
2. Get API credentials
3. Configure:
   ```bash
   voicemode config set LIVEKIT_URL "wss://your-project.livekit.cloud"
   voicemode config set LIVEKIT_API_KEY "your-key"
   voicemode config set LIVEKIT_API_SECRET "your-secret"
   ```

## Comparison with CLI

| Feature | CLI (`claude converse`) | Web Interface |
|---------|------------------------|---------------|
| **Access** | Terminal only | Any browser |
| **Devices** | Computer only | Phone, tablet, laptop |
| **Remote** | No | Yes (network) |
| **Setup** | Simple | Requires LiveKit |
| **Performance** | Same | Same |
| **Auth** | N/A | None (add your own) |

## Links

- **Base Project**: https://github.com/masterbainter/claude-voice
- **VoiceMode**: https://github.com/mbailey/voicemode
- **LiveKit**: https://livekit.io
- **Claude Code**: https://github.com/anthropics/claude-code

## License

MIT

## Contributing

Issues and PRs welcome!
