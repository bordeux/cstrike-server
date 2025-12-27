#!/bin/bash

if [ ! -f ${HLDS_PATH}/cstrike/.installed ]; then
    echo "First run detected. Copying cstrike_base to cstrike..."
    mkdir -p ${HLDS_PATH}/cstrike
    cp -rn ${HLDS_PATH}/cstrike_base/* ${HLDS_PATH}/cstrike/
    touch ${HLDS_PATH}/.installed
    echo "Installation complete."
else
    echo "Installation already exists. Skipping copy."
fi

# Check for overwrites directory and copy files if it exists
if [ -d "${HLDS_PATH}/cstrike_overwrites" ]; then
    echo "cstrike_overwrites directory found. Copying files to cstrike..."
    cp -r ${HLDS_PATH}/cstrike_overwrites/* ${HLDS_PATH}/cstrike/
    echo "Overwrites copied successfully."
else
    echo "No cstrike_overwrites directory found. Skipping."
fi

# Execute the provided command (or default CMD from Dockerfile)
exec "$@"