# Counter-Strike 1.6 Server (Docker)

A containerized Counter-Strike 1.6 dedicated server based on HLDS (Half-Life Dedicated Server) with AMX Mod X support.

## Features

- Based on Ubuntu 24.04
- Includes AMX Mod X and [amx-base-pack](https://github.com/bordeux/amxx-base-pack)
- HLTV (Half-Life TV) support for spectating and broadcasting matches (enabled by default)
- Template processing with gomplate for dynamic configuration
- Auto-compile AMX Mod X plugins on startup (enabled by default)
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
| `HLDS_ARGS` | `""` | Additional custom arguments for hlds_run |
| `HLTV_ENABLE` | `1` | Enable HLTV for spectating and broadcasting (0=disabled, 1=enabled) |
| `HLTV_PORT` | `27020` | HLTV port |
| `HLTV_ARGS` | `""` | Additional custom arguments for HLTV |
| `ENABLE_HTTP_SERVER` | `1` | Enable HTTP server for fast downloads (0=disabled, 1=enabled) |
| `HTTP_SERVER_PORT` | `8080` | HTTP server port |
| `PROCESS_TEMPLATES` | `1` | Process .tmpl files with gomplate on startup (0=disabled, 1=enabled) |
| `AMXMODX_AUTOCOMPILE` | `1` | Auto-compile .sma plugins on startup (0=disabled, 1=enabled) |

**Custom Server Arguments:**

You can pass additional arguments to `hlds_run` using the `HLDS_ARGS` environment variable:

```yaml
environment:
  - HLDS_ARGS="+sv_cheats 1 +mp_timelimit 45 +mp_friendlyfire 1"
```

This is useful for:
- Enabling debug mode
- Setting custom game rules
- Passing additional console commands
- Configuring advanced server settings

**Custom HLTV Arguments:**

You can pass additional arguments to HLTV using the `HLTV_ARGS` environment variable:

```yaml
environment:
  - HLTV_ARGS="+name 'My HLTV' +rate 10000 +maxclients 10"
```

This is useful for:
- Setting HLTV server name
- Configuring bandwidth/rate settings
- Setting maximum spectator slots
- Adjusting delay and other HLTV-specific settings

### Ports

The server exposes the following ports:
- **27015/udp** - Game server (primary)
- **27015/tcp** - Game server
- **27020/udp** - HLTV (if enabled, configurable via HLTV_PORT)
- **27020/tcp** - HLTV (if enabled, configurable via HLTV_PORT)
- **8080/tcp** - HTTP server (if enabled, configurable via HTTP_SERVER_PORT)

### AMX Mod X Auto-Compile

The server automatically compiles all `.sma` source files from `cstrike/addons/amxmodx/scripting/` on container startup. Compiled `.amxx` plugins are placed in `cstrike/addons/amxmodx/plugins/`.

**Features:**
- Automatically compiles all `.sma` files on every container start
- Reports compilation results (success/failures)
- Allows you to develop plugins without manual compilation

**Disable auto-compile:**
```yaml
environment:
  - AMXMODX_AUTOCOMPILE=0
```

**Workflow:**
1. Place your `.sma` files in `cstrike/addons/amxmodx/scripting/`
2. Restart the container
3. Compiled `.amxx` files will be in `cstrike/addons/amxmodx/plugins/`

### Template Processing with Gomplate

The server automatically processes template files (`.tmpl`) using [gomplate](https://docs.gomplate.ca/) on startup. This allows you to create dynamic configuration files using environment variables and gomplate's built-in functions.

**How it works:**
1. Create a file with `.tmpl` extension (e.g., `config.cfg.tmpl`)
2. Use gomplate syntax to reference environment variables
3. On container start, the template is processed and output to `config.cfg`

**Example - `custom.cfg.tmpl`:**
```
// Custom server configuration
hostname "{{ getenv "SERVER_HOSTNAME" "My CS Server" }}"
sv_contact "{{ getenv "SERVER_CONTACT" "admin@example.com" }}"
rcon_password "{{ getenv "SERVER_PASSWORD" }}"

{{ if eq (getenv "SERVER_MODE") "competitive" }}
mp_startmoney 800
mp_roundtime 1.92
mp_freezetime 15
{{ else }}
mp_startmoney 16000
mp_roundtime 5
mp_freezetime 6
{{ end }}
```

**Usage:**
```yaml
environment:
  - SERVER_HOSTNAME=My Awesome Server
  - SERVER_CONTACT=admin@myserver.com
  - SERVER_MODE=competitive
```

Place template files in your mounted `cstrike` directory and they'll be processed automatically on startup.

**Disable template processing:**
```yaml
environment:
  - PROCESS_TEMPLATES=0
```

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
- Serves only specific directories: `sound`, `sprites`, `gfx`, `maps`, `models`, `overviews`
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

### HLTV (Half-Life TV)

HLTV is enabled by default and allows spectators to watch live matches without affecting server performance. HLTV acts as a proxy that connects to the game server and relays the game to spectators with a configurable delay.

**Features:**
- Live match spectating and broadcasting
- Configurable delay to prevent cheating
- No impact on server performance
- Automatic reconnection to the game server
- Supports multiple spectators
- Automatically connects to the local game server (127.0.0.1)

**How to connect as a spectator:**
1. Launch Counter-Strike 1.6
2. Open the console (`)
3. Type: `connect <your-server-ip>:27020` (use your HLTV port)

**Disable HLTV:**
To disable HLTV, set the environment variable in your `docker-compose.yml`:
```yaml
environment:
  - HLTV_ENABLE=0
```

**Change HLTV port:**
```yaml
environment:
  - HLTV_PORT=27030
```

**Configure HLTV settings:**
You can customize HLTV behavior using `HLTV_ARGS`:
```yaml
environment:
  - HLTV_ARGS="+name 'Official HLTV' +rate 10000 +maxclients 10 +delay 30"
```

Common HLTV settings:
- `+name "Server Name"` - HLTV server name shown to spectators
- `+rate <value>` - Maximum bandwidth rate (default: 10000)
- `+maxclients <number>` - Maximum number of spectators (default: depends on HLTV version)
- `+delay <seconds>` - Spectator delay in seconds (helps prevent cheating)

**Important Notes:**
- HLTV automatically reconnects to the game server if disconnected
- HLTV restarts automatically if it crashes
- Spectators connect to the HLTV port, not the game server port
- The HLTV server connects to 127.0.0.1 (localhost) to watch the game

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
├── entrypoint.sh          # Main entrypoint script
├── entrypoint.sh.d/       # Modular entrypoint scripts
│   ├── 10-copy-base.sh    # Copy base files on first run
│   ├── 15-process-templates.sh # Process .tmpl files with gomplate
│   ├── 20-copy-overwrites.sh # Copy overwrite files
│   ├── 30-generate-cvars.sh  # Generate env_cvar.cfg
│   └── 40-compile-plugins.sh # Auto-compile AMXMODX plugins
├── helpers/               # Helper utility scripts
│   ├── amxmodx-compile.sh # Compile AMXMODX plugins
│   └── process-templates.sh # Process gomplate templates
├── start.sh               # Server startup script
├── nginx.conf             # HTTP server configuration
├── hlds.txt               # SteamCMD installation script
└── cstrike/               # Server data directory (created on first run)
```

### Custom Entrypoint Scripts

The entrypoint is modular and executes scripts from `entrypoint.sh.d/` in alphabetical order. You can add custom scripts by:

1. Creating a new script in `entrypoint.sh.d/` with a numbered prefix (e.g., `50-custom.sh`)
2. Making it executable: `chmod +x entrypoint.sh.d/50-custom.sh`
3. Rebuilding the Docker image

Scripts are executed in order: `10-*.sh`, `20-*.sh`, etc. Each script has access to all environment variables.

### Helper Scripts

The image includes utility helper scripts in `${HELPERS_PATH}` (`/usr/bin/helpers/`) that can be called from entrypoint scripts, runtime, or manually:

**`amxmodx-compile.sh`**
Compile AMXMODX plugins from `.sma` source files.

Usage:
```bash
# Inside container (using HELPERS_PATH env variable)
${HELPERS_PATH}/amxmodx-compile.sh /opt/steam/hlds/cstrike/addons/amxmodx

# From host (via docker exec)
docker exec cstrike-server ${HELPERS_PATH}/amxmodx-compile.sh /opt/steam/hlds/cstrike/addons/amxmodx

# Or with full path
docker exec cstrike-server /usr/bin/helpers/amxmodx-compile.sh /opt/steam/hlds/cstrike/addons/amxmodx
```

**`process-templates.sh`**
Process template files (`.tmpl`) using gomplate.

Usage:
```bash
# Inside container
${HELPERS_PATH}/process-templates.sh /opt/steam/hlds/cstrike

# From host (via docker exec)
docker exec cstrike-server ${HELPERS_PATH}/process-templates.sh /opt/steam/hlds/cstrike

# Process templates in a specific directory
docker exec cstrike-server ${HELPERS_PATH}/process-templates.sh /opt/steam/hlds/cstrike/cfg
```

You can create additional helper scripts by:
1. Adding them to the `helpers/` directory
2. Making them executable (`chmod +x helpers/your-script.sh`)
3. Rebuilding the image
4. Access them via `${HELPERS_PATH}/your-script.sh`

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
- Ensure ports 27015 (UDP/TCP) and 27020 (UDP/TCP, if HLTV enabled) are not in use
- Verify volume permissions on the `./cstrike` directory

### Can't connect to server
- Check firewall settings
- Ensure port 27015/UDP is open
- Verify `SERVER_LAN` is set to `0` for internet play

### Configuration changes not applied
- Restart the server: `docker-compose restart`
- For major changes, rebuild: `docker-compose up -d --build`

### Can't connect to HLTV
- Ensure HLTV is enabled: `HLTV_ENABLE=1`
- Check HLTV port is exposed in docker-compose.yml (default: 27020)
- Verify port 27020/UDP and 27020/TCP are open in firewall
- Check logs to confirm HLTV started: `docker-compose logs -f`
- Ensure you're connecting to the HLTV port (27020), not the game server port (27015)

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
