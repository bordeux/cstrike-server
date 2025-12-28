#!/bin/bash
# Helper script to process template files using gomplate
# Usage: process-templates.sh <directory_path>

if [ $# -eq 0 ]; then
    echo "ERROR: No directory path provided"
    echo "Usage: $0 <directory_path>"
    echo "Example: $0 /opt/steam/hlds/cstrike"
    exit 1
fi

TEMPLATE_DIR="$1"

if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "ERROR: Directory not found: $TEMPLATE_DIR"
    exit 1
fi

echo "Processing template files in: $TEMPLATE_DIR"

PROCESSED_COUNT=0

# Find all .tmpl files recursively
while IFS= read -r -d '' tmpl_file; do
    # Get the output filename (remove .tmpl extension)
    output_file="${tmpl_file%.tmpl}"

    # Get relative path for cleaner output
    relative_path="${tmpl_file#$TEMPLATE_DIR/}"

    echo -n "Processing: $relative_path -> $(basename "$output_file") ... "

    # Process template with gomplate
    if gomplate -f "$tmpl_file" -o "$output_file"; then
        echo "✓"
        ((PROCESSED_COUNT++))
    else
        echo "✗ FAILED"
        echo "ERROR: Failed to process template: $tmpl_file"
    fi
done < <(find "$TEMPLATE_DIR" -type f -name "*.tmpl" -print0)

if [ $PROCESSED_COUNT -eq 0 ]; then
    echo "No template files found."
    exit 0
else
    echo "Processed ${PROCESSED_COUNT} template file(s) successfully."
fi

exit 0
