#!/bin/bash
# Helper script to compile AMXMODX plugins
# Usage: amxmodx-compile.sh <path_to_amxmodx_folder>

set -e

if [ $# -eq 0 ]; then
    echo "ERROR: No path provided"
    echo "Usage: $0 <path_to_amxmodx_folder>"
    echo "Example: $0 /opt/steam/hlds/cstrike/addons/amxmodx"
    exit 1
fi

AMXMODX_PATH="$1"
SCRIPTING_DIR="${AMXMODX_PATH}/scripting"
PLUGINS_DIR="${AMXMODX_PATH}/plugins"

if [ ! -d "$SCRIPTING_DIR" ]; then
    echo "ERROR: Scripting directory not found: $SCRIPTING_DIR"
    exit 1
fi

if [ ! -f "${SCRIPTING_DIR}/amxxpc" ]; then
    echo "ERROR: amxxpc compiler not found: ${SCRIPTING_DIR}/amxxpc"
    exit 1
fi

if [ ! -d "$PLUGINS_DIR" ]; then
    echo "WARNING: Plugins directory not found, creating: $PLUGINS_DIR"
    mkdir -p "$PLUGINS_DIR"
fi

echo "Auto-compiling AMXMODX plugins from: $SCRIPTING_DIR"
cd "$SCRIPTING_DIR"

COMPILE_COUNT=0
FAILED_COUNT=0

for sma_file in *.sma; do
    if [ -f "$sma_file" ]; then
        plugin_name="${sma_file%.sma}"
        echo -n "Compiling: $sma_file ... "

        # Capture output and error
        COMPILE_OUTPUT=$(./amxxpc "$sma_file" -o"../plugins/${plugin_name}.amxx" 2>&1)
        COMPILE_EXIT_CODE=$?

        if [ $COMPILE_EXIT_CODE -eq 0 ]; then
            echo "✓"
            ((COMPILE_COUNT++))
        else
            echo "✗ FAILED"
            echo "--- Compilation output ---"
            echo "$COMPILE_OUTPUT"
            echo "-------------------------"
            ((FAILED_COUNT++))
        fi
    fi
done

if [ $COMPILE_COUNT -eq 0 ] && [ $FAILED_COUNT -eq 0 ]; then
    echo "No .sma files found to compile."
    exit 0
else
    echo "Compiled ${COMPILE_COUNT} plugin(s) successfully."
    if [ $FAILED_COUNT -gt 0 ]; then
        echo "WARNING: ${FAILED_COUNT} plugin(s) failed to compile."
        exit 1
    fi
fi

exit 0
