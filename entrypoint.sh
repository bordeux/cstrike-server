#!/bin/bash

# Copy cstrike_base to cstrike only if not already installed
if [ ! -f /hlds/cstrike/.installed ]; then
    echo "First run detected. Copying cstrike_base to cstrike..."
    mkdir -p /hlds/cstrike
    cp -r /hlds/cstrike_base/* /hlds/cstrike/
    touch /hlds/cstrike/.installed
    echo "Installation complete."
else
    echo "Installation already exists. Skipping copy."
fi

# Run the server
./hlds_run -game cstrike -strictportbind -ip 0.0.0.0 -port $PORT +sv_lan $SV_LAN +map $MAP -maxplayers $MAXPLAYERS