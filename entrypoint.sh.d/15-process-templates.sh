#!/bin/bash
# Process template files using gomplate

TEMPLATE_DIR="${CSTRIKE_PATH}"

if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Template directory not found: $TEMPLATE_DIR"
    exit 0
fi

echo "Processing template files in: $TEMPLATE_DIR"

PROCESSED_COUNT=0

# Find all .tmpl files recursively
while IFS= read -r -d '' tmpl_file; do
    # Get the output filename (remove .tmpl extension)
    output_file="${tmpl_file%.tmpl}"

    echo -n "Processing: $(basename "$tmpl_file") -> $(basename "$output_file") ... "

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
else
    echo "Processed ${PROCESSED_COUNT} template file(s) successfully."
fi

exit 0
