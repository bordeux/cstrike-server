#!/bin/bash

if [ ! -f ${HLDS_PATH}/cstrike/.installed ]; then
    echo "First run detected. Copying cstrike_base to cstrike..."
    mkdir -p ${HLDS_PATH}/cstrike
    cp -r ${HLDS_PATH}/cstrike_base/* ${HLDS_PATH}/cstrike/
    touch ${HLDS_PATH}/.installed
    echo "Installation complete."
else
    echo "Installation already exists. Skipping copy."
fi

# Run the server
start.sh