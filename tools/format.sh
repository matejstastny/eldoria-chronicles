#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# format.sh — Formats all .gd files in the project.
# Removes semicolons and normalizes indentation (tabs -> 4 spaces).
# Run from any directory; the script always operates on the project root.
# ------------------------------------------------------------------------------


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo ""
echo "Formatting .gd files in: $PROJECT_ROOT"
echo ""

while IFS= read -r file; do
    echo "  Processing $file"
    if ! sed -i '' 's/;//g' "$file"; then
        echo "Error: Failed to remove semicolons in '$file'."
        exit 1
    fi
    if ! sed -i '' 's/\t/    /g' "$file"; then
        echo "Error: Failed to replace tabs in '$file'."
        exit 1
    fi
done < <(find "$PROJECT_ROOT" -type f -name "*.gd")

echo ""
echo "Done."
