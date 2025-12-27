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

# Generate env_cvar.cfg from CVAR_* environment variables
ENV_CVAR_FILE="${HLDS_PATH}/cstrike/env_cvar.cfg"
echo "// Auto-generated from CVAR_* environment variables" > "$ENV_CVAR_FILE"
echo "// This file is regenerated on every container start" >> "$ENV_CVAR_FILE"
echo "" >> "$ENV_CVAR_FILE"

CVAR_COUNT=0
while IFS='=' read -r name value; do
    if [[ $name == CVAR_* ]]; then
        # Extract the part after CVAR_ and convert to lowercase
        CVAR_NAME="${name#CVAR_}"
        CVAR_NAME_LOWER=$(echo "$CVAR_NAME" | tr '[:upper:]' '[:lower:]')

        echo "${CVAR_NAME_LOWER} ${value}" >> "$ENV_CVAR_FILE"
        echo "Generated CVAR: ${CVAR_NAME_LOWER} ${value}"
        ((CVAR_COUNT++))
    fi
done < <(env)

if [ $CVAR_COUNT -eq 0 ]; then
    echo "No CVAR_* environment variables found."
else
    echo "Generated ${CVAR_COUNT} CVARs in env_cvar.cfg"
fi

# Execute the provided command (or default CMD from Dockerfile)
exec "$@"