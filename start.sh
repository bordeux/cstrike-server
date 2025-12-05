#!/usr/bin/env bash

# Flag for graceful shutdown
SHUTDOWN=0

# Trap signals for graceful shutdown
trap 'echo "Received shutdown signal..."; SHUTDOWN=1; killall hlds_linux 2>/dev/null || true' SIGTERM SIGINT

echo "Starting Counter-Strike server..."

# Restart loop
while [ $SHUTDOWN -eq 0 ]; do
    echo "Launching hlds_run..."

    /opt/steam/hlds/hlds_run \
        -game ${SERVER_GAME} \
        +port ${SERVER_PORT} \
        +sv_lan ${SERVER_LAN} \
        +maxplayers ${SERVER_MAX_PLAYERS} \
        +log on \
        +rcon_password "${SERVER_PASSWORD}" \
        +map ${SERVER_MAP}

    EXIT_CODE=$?

    if [ $SHUTDOWN -eq 1 ]; then
        echo "Server shutdown requested. Exiting..."
        break
    fi

    echo "Server crashed with exit code $EXIT_CODE. Restarting in 5 seconds..."
    sleep 5
done

echo "Server stopped."
exit 0