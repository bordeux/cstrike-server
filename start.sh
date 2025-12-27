#!/usr/bin/env bash

# Flag for graceful shutdown
SHUTDOWN=0
HLTV_PID=0
NGINX_PID=0

# Default environment variables if not set
ENABLE_HLTV=${ENABLE_HLTV:-1}
ENABLE_HTTP_SERVER=${ENABLE_HTTP_SERVER:-1}
HTTP_SERVER_PORT=${HTTP_SERVER_PORT:-8080}

# Trap signals for graceful shutdown
trap 'echo "Received shutdown signal..."; SHUTDOWN=1; killall hlds_linux hltv nginx 2>/dev/null || true; [ $HLTV_PID -ne 0 ] && kill $HLTV_PID 2>/dev/null || true; [ $NGINX_PID -ne 0 ] && kill $NGINX_PID 2>/dev/null || true' SIGTERM SIGINT

echo "Starting Counter-Strike server..."

# Kill any existing nginx processes (safety check)
killall nginx 2>/dev/null || true

# Start HTTP server (nginx) in the background if enabled
if [ "$ENABLE_HTTP_SERVER" = "1" ]; then
    echo "Starting HTTP server on port ${HTTP_SERVER_PORT}..."
    # Create temporary nginx config with substituted port
    export HTTP_SERVER_PORT
    envsubst '${HTTP_SERVER_PORT}' < /etc/nginx/nginx.conf > /tmp/nginx.conf
    nginx -c /tmp/nginx.conf &
    NGINX_PID=$!
    echo "HTTP server started with PID $NGINX_PID on port ${HTTP_SERVER_PORT}"
else
    echo "HTTP server disabled (ENABLE_HTTP_SERVER=${ENABLE_HTTP_SERVER})"
fi

# Start HLTV in the background if enabled
if [ "$ENABLE_HLTV" = "1" ]; then
    echo "Starting HLTV..."
    /opt/steam/hlds/hltv +port $((SERVER_PORT + 10)) +connect "127.0.0.1:${SERVER_PORT}" +record auto &
    HLTV_PID=$!
    echo "HLTV started with PID $HLTV_PID"
else
    echo "HLTV disabled (ENABLE_HLTV=${ENABLE_HLTV})"
fi

# Restart loop for game server
while [ $SHUTDOWN -eq 0 ]; do
    echo "Launching hlds_run..."

    /opt/steam/hlds/hlds_run \
        -game "${SERVER_GAME}" \
        +port "${SERVER_PORT}" \
        +sv_lan "${SERVER_LAN}" \
        +maxplayers "${SERVER_MAX_PLAYERS}" \
        +log on \
        +rcon_password "${SERVER_PASSWORD}" \
        +map "${SERVER_MAP}"

    EXIT_CODE=$?

    if [ $SHUTDOWN -eq 1 ]; then
        echo "Server shutdown requested. Exiting..."
        break
    fi

    echo "Server crashed with exit code $EXIT_CODE. Restarting in 5 seconds..."
    sleep 5

    # Restart HTTP server if needed and enabled
    if [ "$ENABLE_HTTP_SERVER" = "1" ] && ! kill -0 $NGINX_PID 2>/dev/null; then
        echo "HTTP server not running, restarting..."
        nginx -c /tmp/nginx.conf &
        NGINX_PID=$!
        echo "HTTP server restarted with PID $NGINX_PID"
    fi

    # Restart HLTV if needed and enabled
    if [ "$ENABLE_HLTV" = "1" ] && ! kill -0 $HLTV_PID 2>/dev/null; then
        echo "HLTV not running, restarting..."
        /opt/steam/hlds/hltv +port $((SERVER_PORT + 10)) +connect "127.0.0.1:${SERVER_PORT}" +record auto &
        HLTV_PID=$!
        echo "HLTV restarted with PID $HLTV_PID"
    fi
done

# Cleanup processes
if [ $NGINX_PID -ne 0 ]; then
    echo "Stopping HTTP server..."
    kill $NGINX_PID 2>/dev/null || true
    wait $NGINX_PID 2>/dev/null || true
fi

if [ $HLTV_PID -ne 0 ]; then
    echo "Stopping HLTV..."
    kill $HLTV_PID 2>/dev/null || true
    wait $HLTV_PID 2>/dev/null || true
fi

echo "Server stopped."
exit 0