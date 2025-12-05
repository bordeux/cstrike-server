#!/usr/bin/env bash

set -e

/opt/steam/hlds/hlds_run -game ${SERVER_GAME} +port ${SERVER_PORT} +sv_lan ${SERVER_LAN} +maxplayers ${SERVER_MAX_PLAYERS} +log on +rcon_password "${SERVER_PASSWORD}" +map ${SERVER_MAP}