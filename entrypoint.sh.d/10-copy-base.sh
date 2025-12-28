#!/bin/bash
# Copy base cstrike files on first run

if [ ! -f ${CSTRIKE_PATH}/.installed ]; then
    echo "First run detected. Copying cstrike_base to cstrike..."
    mkdir -p ${CSTRIKE_PATH}
    cp -rn ${CSTRIKE_BASE_PATH}/* ${CSTRIKE_PATH}/
    touch ${CSTRIKE_PATH}/.installed
    echo "Installation complete."
else
    echo "Installation already exists. Skipping copy."
fi
