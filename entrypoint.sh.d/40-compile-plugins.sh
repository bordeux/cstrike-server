#!/bin/bash
# Auto-compile AMXMODX plugins if enabled

if [ "${AMXMODX_AUTOCOMPILE:-1}" = "1" ]; then
    AMXMODX_PATH="${CSTRIKE_PATH}/addons/amxmodx"

    # Use the helper script to compile plugins
    "${HELPERS_PATH}/amxmodx-compile.sh" "$AMXMODX_PATH"
else
    echo "AMXMODX auto-compile disabled (AMXMODX_AUTOCOMPILE=${AMXMODX_AUTOCOMPILE})"
fi
