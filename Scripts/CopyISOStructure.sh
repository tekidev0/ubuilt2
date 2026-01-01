#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../work.conf"

# Copy ISO files structure
echo "Copying ISO files structure..."
cp -r "$(dirname "${BASH_SOURCE[0]}")/../ISOFiles/"* "$ISO_FILES/"

# Substitute GRUB_DISTRIBUTION_NAME variable in grub.cfg
if [ -f "$ISO_FILES/boot/grub/grub.cfg" ]; then
    echo "Substituting GRUB_DISTRIBUTION_NAME in grub.cfg..."
    sed -i "s/\$GRUB_DISTRIBUTION_NAME/$GRUB_DISTRIBUTION_NAME/g" "$ISO_FILES/boot/grub/grub.cfg"
fi

# Add custom menuentries if they exist
MENUENTRIES_DIR="$(dirname "${BASH_SOURCE[0]}")/../Menuentries"
MENUENTRIES_JSON="$MENUENTRIES_DIR/menuentries.json"

if [ -f "$MENUENTRIES_JSON" ] && [ -f "$ISO_FILES/boot/grub/grub.cfg" ]; then
    echo "Adding custom menuentries to grub.cfg..."
    
    # Read menuentries from JSON and append to grub.cfg
    if command -v jq &> /dev/null; then
        # Use jq if available for proper JSON parsing
        menuentries=$(jq -r '.menuentries[]' "$MENUENTRIES_JSON" 2>/dev/null || echo "")
    else
        # Fallback to simple parsing if jq is not available
        menuentries=$(grep -o '"[^"]*\.menuentry"' "$MENUENTRIES_JSON" | sed 's/"//g' | sed 's/^"//' | sed 's/"$//' || echo "")
    fi
    
    if [ -n "$menuentries" ]; then
        # Append custom menuentries to grub.cfg
        echo "" >> "$ISO_FILES/boot/grub/grub.cfg"
        echo "# Custom menuentries" >> "$ISO_FILES/boot/grub/grub.cfg"
        
        for entry in $menuentries; do
            entry_file="$MENUENTRIES_DIR/$entry"
            if [ -f "$entry_file" ]; then
                echo "Adding menuentry: $entry"
                cat "$entry_file" >> "$ISO_FILES/boot/grub/grub.cfg"
                echo "" >> "$ISO_FILES/boot/grub/grub.cfg"
            else
                echo "Warning: Menuentry file not found: $entry_file"
            fi
        done
    else
        echo "No menuentries found or JSON parsing failed."
    fi
fi

echo "ISO structure copied successfully."
