#!/bin/bash
# Process template files using gomplate

if [ "${PROCESS_TEMPLATES:-1}" = "1" ]; then
    # Use the helper script to process templates
    "${HELPERS_PATH}/process-templates.sh" "${CSTRIKE_PATH}"
else
    echo "Template processing disabled (PROCESS_TEMPLATES=${PROCESS_TEMPLATES})"
fi
