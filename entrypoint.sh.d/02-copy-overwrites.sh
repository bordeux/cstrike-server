#!/bin/bash
# Copy overwrite files if directory exists

if [ -d "${HLDS_PATH}/cstrike_overwrites" ]; then
    echo "cstrike_overwrites directory found. Copying files to cstrike..."
    cp -r ${HLDS_PATH}/cstrike_overwrites/* ${HLDS_PATH}/cstrike/
    echo "Overwrites copied successfully."
else
    echo "No cstrike_overwrites directory found. Skipping."
fi
