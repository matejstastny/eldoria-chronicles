#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# build-dmg.sh -- Packages the Godot macOS export into a distributable DMG.
#
# Takes the raw DMG produced by Godot, extracts the .app bundle, then
# repackages it with a custom background using create-dmg.
#
# Usage: ./tools/build-dmg.sh
# Run from any directory; the script always operates relative to tools/.
# ------------------------------------------------------------------------------

# -- Logging -------------------------------------------------------------------

log_inf() { echo "[INF] $*"; }
log_wrn() { echo "[WRN] $*"; }
log_err() { echo "[ERR] $*" >&2; }

die() { log_err "$*"; exit 1; }


# -- Script location -----------------------------------------------------------

# Always run relative to the tools/ directory, regardless of where the script
# is called from.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"


# -- Configuration -------------------------------------------------------------

# App identity
APP_NAME="Eldoria Chronicles"          # Must match the .app name inside the Godot DMG

# Input files (relative to tools/)
SOURCE_DIR="source"                    # Directory holding the Godot-exported DMG and assets
DMG_NAME="eldoria-chronicles-raw.dmg"  # Raw DMG produced by Godot export
BACKGROUND_IMG="dmg-background.png"   # Background image shown in the installer window

# Output
OUTPUT_DIR="build"                     # Final DMG is written here
NEW_DMG_NAME="eldoria-chronicles-1.1.0-mac.dmg"

# Internals
TEMP_DIR="temp"                        # Scratch space for the extracted .app (deleted after)
MOUNT_POINT="/Volumes/$APP_NAME"       # macOS mount point for the Godot DMG


# -- Dependency check ----------------------------------------------------------

if ! command -v create-dmg &>/dev/null; then
    if ! command -v brew &>/dev/null; then
        die "'create-dmg' is not installed and Homebrew was not found. Install Homebrew first."
    fi
    read -r -p "[WRN] 'create-dmg' is not installed. Install it via Homebrew now? (y/n) " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        die "'create-dmg' is required. Exiting."
    fi
    log_inf "Installing 'create-dmg'..."
    if ! brew install create-dmg; then
        die "Failed to install 'create-dmg'."
    fi
fi


# -- Setup ---------------------------------------------------------------------

for file in "$SOURCE_DIR/$DMG_NAME" "$SOURCE_DIR/$BACKGROUND_IMG"; do
    [ -f "$file" ] || die "Required file not found: $file"
done

mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"
rm -f "$OUTPUT_DIR/$NEW_DMG_NAME"
rm -rf "$TEMP_DIR/$APP_NAME.app"


# -- Mount DMG -----------------------------------------------------------------

cleanup() {
    if mount | grep -q "$MOUNT_POINT"; then
        log_inf "Unmounting $MOUNT_POINT..."
        hdiutil detach "$MOUNT_POINT" -quiet
    fi
}
trap cleanup EXIT

log_inf "Mounting '$DMG_NAME'..."
if ! hdiutil attach "$SOURCE_DIR/$DMG_NAME" -nobrowse -quiet; then
    die "Failed to mount DMG."
fi

attempts=5
while [ ! -d "$MOUNT_POINT" ] && [ "$attempts" -gt 0 ]; do
    sleep 1
    ((attempts--))
done

[ -d "$MOUNT_POINT" ] || die "Mount point did not appear at '$MOUNT_POINT'."
[ -d "$MOUNT_POINT/$APP_NAME.app" ] || die "'$APP_NAME.app' not found inside the mounted DMG."


# -- Extract app ---------------------------------------------------------------

log_inf "Copying '$APP_NAME.app' to temp directory..."
cp -R "$MOUNT_POINT/$APP_NAME.app" "$TEMP_DIR/"
cleanup
log_inf "Application extracted successfully."


# -- Package DMG ---------------------------------------------------------------

log_inf "Creating new DMG..."
if ! create-dmg \
    --volname "$APP_NAME Installer" \
    --background "$SOURCE_DIR/$BACKGROUND_IMG" \
    --window-pos 200 120 \
    --window-size 600 420 \
    --icon-size 100 \
    --icon "$APP_NAME.app" 150 190 \
    --app-drop-link 450 190 \
    --format UDBZ \
    "$OUTPUT_DIR/$NEW_DMG_NAME" \
    "$TEMP_DIR" >/dev/null; then
    die "Failed to create DMG."
fi


# -- Cleanup -------------------------------------------------------------------

rm -rf "$TEMP_DIR"
log_inf "Done. Output: $SCRIPT_DIR/$OUTPUT_DIR/$NEW_DMG_NAME"
