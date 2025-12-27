#!/bin/bash
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
