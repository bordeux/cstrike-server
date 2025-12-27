#!/bin/bash
# Auto-compile AMXMODX plugins if enabled

if [ "${AMXMODX_AUTOCOMPILE:-1}" = "1" ]; then
    SCRIPTING_DIR="${HLDS_PATH}/cstrike/addons/amxmodx/scripting"
    PLUGINS_DIR="${HLDS_PATH}/cstrike/addons/amxmodx/plugins"

    if [ -d "$SCRIPTING_DIR" ]; then
        echo "Auto-compiling AMXMODX plugins..."
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
        else
            echo "Compiled ${COMPILE_COUNT} plugin(s) successfully."
            if [ $FAILED_COUNT -gt 0 ]; then
                echo "WARNING: ${FAILED_COUNT} plugin(s) failed to compile."
            fi
        fi

        cd - > /dev/null
    else
        echo "Scripting directory not found: $SCRIPTING_DIR"
    fi
else
    echo "AMXMODX auto-compile disabled (AMXMODX_AUTOCOMPILE=${AMXMODX_AUTOCOMPILE})"
fi
