#!/system/bin/sh
# ================================================================
#  Siyas Game Boost - customize.sh
#  Sourced automatically by install_module() after extraction.
#
#  IMPORTANT: Since SKIPUNZIP=0 in update-binary, the framework
#  has already extracted ALL files from the zip into $MODPATH
#  before this script runs. We must NOT call unzip here again.
#  We only need to: print messages, check device, set permissions.
#
#  Variables available (provided by util_functions.sh):
#    $MODPATH   — where module files were extracted to
#    $ZIPFILE   — path to the zip being installed
#    $ARCH      — device architecture (arm64, arm, x86_64, x86)
#    $API       — Android SDK level
#    $KSU       — true if running under KernelSU / ResuKISU
# ================================================================

ui_print "**********************************************"
ui_print "        SIYAS GAME BOOST v2.0.0"
ui_print "          by Siyas - Module Dev"
ui_print "**********************************************"
ui_print "  Device  : Infinix Note 30 5G"
ui_print "  Chipset : Helio G91 Ultra"
ui_print "  GPU     : Mali-G57 MC2"
ui_print "**********************************************"
ui_print " "

# ── Root manager detection ──────────────────────────────────
ui_print "- Detecting root manager..."
if [ "$KSU" = "true" ] || [ -f /data/adb/ksud ]; then
    ui_print "  ✓ KernelSU / ResuKISU"
else
    ui_print "  ✓ Magisk"
fi

# ── Architecture check ──────────────────────────────────────
# The device must be 64-bit ARM; abort cleanly if not.
ui_print "- Checking architecture..."
if [ "$ARCH" != "arm64" ]; then
    abort "! This module requires arm64. Found: $ARCH"
fi
ui_print "  ✓ arm64-v8a"

# ── Android API check ───────────────────────────────────────
# Require Android 11 (API 30) or higher.
ui_print "- Checking Android version..."
if [ "$API" -lt 30 ]; then
    abort "! Android 11+ (API 30) required. Found API: $API"
fi
ui_print "  ✓ Android API $API"

# ── Verify key files were extracted correctly ───────────────
# If the framework extraction worked, these must exist.
ui_print "- Verifying extracted files..."
for _file in service.sh action.sh webroot/index.html; do
    if [ ! -f "$MODPATH/$_file" ]; then
        abort "! Missing file after extraction: $_file"
    fi
done
ui_print "  ✓ All files present"

# ── Set executable permissions on shell scripts ─────────────
# set_perm <file> <owner> <group> <octal-perms>
ui_print "- Setting permissions..."
set_perm "$MODPATH/service.sh" root root 0755
set_perm "$MODPATH/action.sh"  root root 0755
# webroot files: dirs=0755, files=0644
set_perm_recursive "$MODPATH/webroot" root root 0755 0644
ui_print "  ✓ Permissions set"

# ── Print device info (informational only) ──────────────────
ui_print " "
ui_print "- Device info:"
ui_print "  Model   : $(getprop ro.product.model)"
ui_print "  Android : $(getprop ro.build.version.release)"
ui_print "  SOC     : $(getprop ro.board.platform)"
ui_print " "
ui_print "**********************************************"
ui_print "  ✓ Installation successful!"
ui_print "  → Reboot your device"
ui_print "  → Tap Action button in KSU / Magisk"
ui_print "  → WebUI opens at http://localhost:8080"
ui_print "  Developed by Siyas | Infinix Note 30 5G"
ui_print "**********************************************"
ui_print " "
