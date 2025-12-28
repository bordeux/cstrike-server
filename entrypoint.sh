#!/bin/bash
# Main entrypoint that executes modular scripts from entrypoint.sh.d/

ENTRYPOINT_DIR="/usr/bin/entrypoint.sh.d"

if [ -d "$ENTRYPOINT_DIR" ]; then
    echo "Running entrypoint scripts from $ENTRYPOINT_DIR..."

    # Execute scripts in order based on filename
    for script in "$ENTRYPOINT_DIR"/*.sh; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            echo "=========================================="
            echo "Executing: $(basename "$script")"
            echo "=========================================="

            # Execute the script and capture exit code
            bash "$script"
            EXIT_CODE=$?

            # Check result
            if [ $EXIT_CODE -eq 0 ]; then
                echo "✓ $(basename "$script") completed successfully"
            else
                echo "✗ $(basename "$script") failed with exit code $EXIT_CODE"
                # Continue with other scripts even if one fails
            fi
            echo ""
        fi
    done

    echo "All entrypoint scripts completed."
else
    echo "WARNING: Entrypoint directory not found: $ENTRYPOINT_DIR"
fi

# Execute the provided command (or default CMD from Dockerfile)
exec "$@"