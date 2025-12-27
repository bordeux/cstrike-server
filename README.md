# Counter-Strike 1.6 Server (Docker)

A containerized Counter-Strike 1.6 dedicated server based on HLDS (Half-Life Dedicated Server) with AMX Mod X support.

## Features

- Based on Ubuntu 24.04
- Includes AMX Mod X and [amx-base-pack](https://github.com/bordeux/amxx-base-pack)
- Dynamic CVAR configuration via environment variables
- HTTP server for fast content downloads (enabled by default)
- Persistent configuration and game data
- Easy deployment with Docker Compose
- Automated builds via GitHub Actions
- Pre-built images available on GitHub Container Registry

## Packages

### Main
This server is using latest packages based on https://github.com/bordeux/amxx-base-pack repository. Check there, what is instaleld.
For sure:
### Main
- [AMX Mod X](https://www.amxmodx.org/downloads-new.php?branch=master&all=1)
- [ReHLDS](https://github.com/rehlds/ReHLDS/)
- [ReGameDLL](https://github.com/rehlds/ReGameDLL_CS) 
- [Reunion](https://github.com/rehlds/ReUnion) 
- [Metamod-r](https://github.com/rehlds/Metamod-R/) 
- [VoiceTranscoder](https://github.com/WPMGPRoSToTeMa/VoiceTranscoder)
- [ReVoice](https://github.com/rehlds/ReVoice/)
- [Reapi](https://github.com/rehlds/ReAPI) 
- [WHBlocker](https://dev-cs.ru/resources/76/)

### Optional (disabled by default)

If you want to enabled those modules check **cstrike/addons/metamod/plugins.ini**.

- [ReAuthChecker](https://dev-cs.ru/resources/63/)
- [ReChecker](https://dev-cs.ru/resources/72/)
- [ReSemiclip](https://dev-cs.ru/resources/71/) 

## Quick Start

### Using Pre-built Image

```bash
# Create the data directory with proper permissions
mkdir -p cstrike && chmod 777 cstrike

# Start the server
docker-compose up -d
```

This will pull the latest image from GitHub Container Registry and start the server.

### Building Locally

```bash
# Create the data directory with proper permissions
mkdir -p cstrike && chmod 777 cstrike

# Build and start the server
docker-compose -f docker-compose.build.yml up -d --build
```

## Configuration

### Environment Variables

Configure the server by modifying the environment variables in `docker-compose.yml`:

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_PORT` | `27015` | Server port |
| `SERVER_MAP` | `de_dust2` | Starting map |
| `SERVER_LAN` | `0` | LAN mode (0=internet, 1=LAN) |
| `SERVER_MAX_PLAYERS` | `20` | Maximum number of players |
| `SERVER_GAME` | `cstrike` | Game type |
| `SERVER_PASSWORD` | `change-me` | Server password (change this!) |
| `ENABLE_HTTP_SERVER` | `1` | Enable HTTP server for fast downloads (0=disabled, 1=enabled) |
| `HTTP_SERVER_PORT` | `8080` | HTTP server port |

### Ports

The server exposes the following ports:
- **27015/udp** - Game server (primary)
- **27015/tcp** - Game server
- **8080/tcp** - HTTP server (if enabled, configurable via HTTP_SERVER_PORT)

### Dynamic CVAR Configuration

You can configure server CVARs (console variables) dynamically using environment variables with the `CVAR_` prefix. These will be automatically written to `env_cvar.cfg` on container start.

**Usage:**
```yaml
environment:
  - CVAR_SV_GRAVITY=600
  - CVAR_MP_ROUNDTIME=3
  - CVAR_SV_ALLTALK=1
```

This generates `cstrike/env_cvar.cfg`:
```
sv_gravity 600
mp_roundtime 3
sv_alltalk 1
```

**Important:**
- CVAR names are automatically converted to lowercase
- Use underscores in environment variable names (e.g., `CVAR_SV_GRAVITY`)
- The file is regenerated on every container start
- CVARs are automatically loaded via `exec env_cvar.cfg` in `server.cfg`

### HTTP Server (Fast Downloads)

The HTTP server is enabled by default and serves game content (maps, models, sounds, sprites, gfx) via nginx. This allows players to download custom content much faster than the built-in game server downloads.

**Features:**
- Fast HTTP downloads for custom content
- Serves only specific directories: `sound`, `sprites`, `gfx`, `maps`, `models`
- Directory listing enabled for easy browsing
- Configurable port (default: 8080)

**Access the HTTP server:**
```bash
# List available maps
curl http://your-server-ip:8080/maps/

# Download a custom map
curl http://your-server-ip:8080/maps/de_custom.bsp
```

**Disable HTTP server:**
To disable the HTTP server, set the environment variable in your `docker-compose.yml`:
```yaml
environment:
  - ENABLE_HTTP_SERVER=0
```

**Change HTTP server port:**
```yaml
environment:
  - HTTP_SERVER_PORT=80
```

**Configure in-game downloads:**
Add to your `server.cfg`:
```
sv_downloadurl "http://your-server-ip:8080"
sv_allowdownload 1
sv_allowupload 1
```

## Data Persistence

Server data (configurations, maps, plugins) is stored in the `./cstrike` directory on your host machine. This directory is automatically created on first run and mounted to the container.

To customize your server:
1. Edit files in the `./cstrike` directory
2. Restart the container: `docker-compose restart`

### Configuration Overwrites

If you need to apply custom configurations that should be copied on every container start, you can use the `cstrike_overwrites` directory:

1. Create a directory inside the container at `${HLDS_PATH}/cstrike_overwrites`
2. Place your custom configuration files with the same directory structure as the `cstrike` folder
3. On every container start, files from `cstrike_overwrites` will be copied to `cstrike`, overwriting existing files

This is useful for:
- Maintaining custom server configurations
- Version controlling your server settings
- Ensuring specific files are always applied on restart

**Example:**
```bash
# Mount a local directory with your custom configs
# Add to docker-compose.yml volumes:
- ./my-custom-configs:/opt/hlds/cstrike_overwrites
```

## Commands

### Start the server
```bash
docker-compose up -d
```

### Stop the server
```bash
docker-compose down
```

### View logs
```bash
docker-compose logs -f
```

### Restart the server
```bash
docker-compose restart
```

### Access server console
```bash
docker-compose attach cstrike-server
```

Press `Ctrl+P` then `Ctrl+Q` to detach without stopping the server.

## Development

### Building Locally

Use the `docker-compose.build.yml` file for local development:

```bash
docker-compose -f docker-compose.build.yml up -d --build
```

### Project Structure

```
.
├── Dockerfile              # Container image definition
├── docker-compose.yml      # Production deployment (pre-built image)
├── docker-compose.build.yml # Development (local build)
├── entrypoint.sh          # Container entrypoint script
├── start.sh               # Server startup script
├── hlds.txt               # SteamCMD installation script
└── cstrike/               # Server data directory (created on first run)
```

## GitHub Actions

This repository includes automated Docker image builds:
- **Main branch**: Builds and pushes image with `latest` tag
- **Other branches**: Builds and pushes image with branch name as tag (e.g., `feature-test`)

Images are published to: `ghcr.io/bordeux/cstrike-server`

## Connecting to the Server

1. Launch Counter-Strike 1.6
2. Open the console (`)
3. Type: `connect <your-server-ip>:27015`
4. Enter the password if required

## Troubleshooting

### Server won't start
- Check logs: `docker-compose logs -f`
- Ensure ports 27015 (UDP/TCP) are not in use
- Verify volume permissions on the `./cstrike` directory

### Can't connect to server
- Check firewall settings
- Ensure port 27015/UDP is open
- Verify `SERVER_LAN` is set to `0` for internet play

### Configuration changes not applied
- Restart the server: `docker-compose restart`
- For major changes, rebuild: `docker-compose up -d --build`

## License

This project uses software from various sources. Please ensure compliance with:
- Valve's terms of service for HLDS
- AMX Mod X license
- Any other included plugins and modifications

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `docker-compose.build.yml`
5. Submit a pull request

## Support

For issues and questions, please open an issue on the GitHub repository.
