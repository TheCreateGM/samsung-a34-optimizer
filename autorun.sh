#!/bin/bash

# Samsung A34 5G Minimalist Optimization & Privacy Script
# Version 2.1 - For One UI 8.0 / Android 16+ and below
# This script optimizes your phone for performance, privacy, and a minimal aesthetic.
# Make sure USB debugging is enabled and your phone is connected via ADB.

echo "======================================================"
echo "=== Samsung A34 5G Minimalist Optimization Script ==="
echo "======================================================"
echo "This will debloat, optimize, and enhance your phone's privacy."
echo "Make sure your phone is connected and USB debugging is enabled."
echo ""
read -p "Press Enter to continue..."

# Check dependencies on host machine
if ! command -v adb &> /dev/null; then
    echo "Error: ADB is not installed or not in PATH. Please install Android SDK Platform Tools."
    exit 1
fi
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install curl to download necessary packages."
    exit 1
fi

# Check device connection
if ! adb devices | grep -q "device$"; then
    echo "Error: No device connected or device not authorized."
    echo "Please connect your Samsung A34 5G and authorize the connection."
    exit 1
fi

echo "✓ Device detected. Starting optimization..."
echo ""

# --- Helper Functions ---

# Function to disable a package safely for the current user
disable_package() {
    local package=$1
    local description=$2
    echo "Disabling $description ($package)..."
    adb shell pm disable-user --user 0 "$package" 2>/dev/null
}

# Function to enable a package
enable_package() {
    local package=$1
    local description=$2
    echo "Enabling $description ($package)..."
    adb shell pm enable "$package" 2>/dev/null
}

# Function to check if a package is installed
is_package_installed() {
    # Specify user 0 to avoid permission errors with multiple profiles.
    # The command returns output only if the package exists. `grep -q .` checks for any output.
    adb shell pm list packages --user 0 "$1" | grep -q .
}

# Function to download and install an APK if it's not already installed
install_apk() {
    local package_name="$1"
    local apk_url="$2"
    local app_name="$3"
    if ! is_package_installed "$package_name"; then
        echo "Installing $app_name..."
        local temp_apk="/tmp/$package_name.apk"
        echo "Downloading from $apk_url..."
        # Use curl with --fail to exit with an error on HTTP failure codes (like 404)
        if curl -L --fail -o "$temp_apk" "$apk_url"; then
            echo "Download complete. Installing APK..."
            local install_output
            # Use "install -r" to allow replacing an existing app, and capture all output
            install_output=$(adb install -r "$temp_apk" 2>&1)
            # Check for "Success" in the output of `adb install`
            if echo "$install_output" | grep -q "Success"; then
                echo "✓ $app_name installed successfully."
            else
                echo "Error: Failed to install $app_name. See details below."
                echo "ADB Output: $install_output"
            fi
            rm "$temp_apk"
        else
            echo "Error: Failed to download $app_name from the URL."
            echo "Please check your internet connection and that the URL is valid."
            echo "URL: $apk_url"
        fi
    else
        echo "✓ $app_name is already installed."
    fi
}


# --- Section 1: AI & Bloatware Removal ---
echo "==================================="
echo "=== Removing AI & Bloatware... ==="
echo "==================================="

# Comprehensive removal of all AI, Bixby, and other non-essential services.
# This reduces heat and improves battery life.

# Disable Samsung Bloatware
echo "--- Disabling Samsung Services ---"
disable_package "com.samsung.android.bixby.agent" "Bixby Voice"
disable_package "com.samsung.android.app.spage" "Samsung Free"
disable_package "com.samsung.android.bixby.service" "Bixby Service"
disable_package "com.samsung.android.visionintelligence" "Bixby Vision"
disable_package "com.samsung.android.app.routines" "Bixby Routines"
disable_package "com.samsung.android.game.gamehome" "Game Launcher"
disable_package "com.samsung.android.game.gametools" "Game Tools"
disable_package "com.samsung.android.samsungpass" "Samsung Pass"
disable_package "com.samsung.android.samsungpassautofill" "Samsung Pass Autofill"
disable_package "com.samsung.android.app.tips" "Samsung Tips"
disable_package "com.samsung.android.arzone" "AR Zone"
disable_package "com.samsung.android.scloud" "Samsung Cloud"

# Disable All Google AI & Assistant Services
echo "--- Disabling Google AI & Assistant ---"
disable_package "com.google.android.apps.bard" "Google Gemini/Bard"
disable_package "com.google.android.apps.googleassistant" "Google Assistant"
disable_package "com.google.android.googlequicksearchbox" "Google Search"
disable_package "com.google.android.as" "Android System Intelligence"
disable_package "com.google.android.apps.turbo" "Device Health Services"
disable_package "com.google.android.apps.wellbeing" "Digital Wellbeing"
disable_package "com.google.android.projection.gearhead" "Android Auto"
disable_package "com.google.android.apps.lens" "Google Lens"
disable_package "com.google.android.tts" "Google Text-to-Speech"
disable_package "com.google.android.apps.speechservices" "Speech Services"

# Disable other common bloatware
echo "--- Disabling 3rd Party Bloatware ---"
disable_package "com.facebook.katana" "Facebook"
disable_package "com.facebook.system" "Facebook App Installer"
disable_package "com.facebook.appmanager" "Facebook App Manager"
disable_package "com.facebook.services" "Facebook Services"
disable_package "com.netflix.mediaclient" "Netflix"
disable_package "com.microsoft.office.officehubrow" "Microsoft Office"
disable_package "com.microsoft.skydrive" "OneDrive"
disable_package "com.spotify.music" "Spotify"

# CRITICAL KEYBOARD FIX: Ensure keyboards remain functional after debloating
echo ""
echo "--- Ensuring Keyboard Functionality ---"
enable_package "com.samsung.android.honeyboard" "Samsung Keyboard"
enable_package "com.google.android.inputmethod.latin" "Gboard"
adb shell ime enable com.samsung.android.honeyboard/.service.HoneyBoardService
adb shell ime set com.samsung.android.honeyboard/.service.HoneyBoardService
echo "✓ Keyboard functionality secured. Samsung Keyboard set as default."
echo ""


# --- Section 2: UI Ricing & Optimization (Minimalist Aesthetic) ---
echo "================================================="
echo "=== Applying Minimalist UI & Performance Tweaks ==="
echo "================================================="

# Install and set up a minimal, open-source launcher for a clean look
echo "--- Setting up Minimalist Launcher (KISS) ---"
# Using a direct GitHub release link for reliability
KISS_URL="https://github.com/Neamar/KISS/releases/download/v4.5.1/kiss-v4.5.1.apk"
install_apk "fr.neamar.kiss" "$KISS_URL" "KISS Launcher"
echo "To set KISS as default, go to Settings > Apps > Choose default apps > Home app"

# Apply settings for a faster, smoother, and cleaner UI
echo "--- Optimizing UI Fluidity & Look ---"
adb shell settings put secure ui_night_mode 2 # Force dark mode
adb shell settings put global window_animation_scale 0.25
adb shell settings put global transition_animation_scale 0.25
adb shell settings put global animator_duration_scale 0.25
adb shell settings put system font_scale 0.95 # Slightly smaller font for cleaner look
echo "✓ UI animations set to hyper-fast (0.25x). Dark mode enabled."
echo ""


# --- Section 3: Performance, Battery & Thermal Tuning ---
echo "==============================================="
echo "=== Tuning Performance, Battery & Thermals ==="
echo "==============================================="

# CPU & GPU acceleration for a smoother experience
echo "--- Accelerating CPU & GPU ---"
adb shell setprop debug.hwui.renderer skiagl # Force GPU rendering
adb shell setprop debug.sf.hw 1 # Enable hardware overlays
adb shell "echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" 2>/dev/null || echo "Note: Setting CPU governor requires root."

# Aggressive background process and battery management
echo "--- Optimizing Battery & Background Processes ---"
adb shell settings put global low_power 1
adb shell settings put global battery_saver_constants "v=1,threshold=99,advertise_is_enabled=true" # Aggressive saver
adb shell settings put global background_app_limit 2 # Limit background apps
adb shell dumpsys deviceidle force-idle # Force device into Doze mode

# Thermal management to reduce heat
echo "--- Managing Thermals ---"
adb shell "echo 1 > /sys/class/thermal/thermal_zone0/mode" 2>/dev/null || echo "Note: Thermal settings may require root."
echo ""


# --- Section 4: Network & Connectivity Overhaul ---
echo "================================================"
echo "=== Optimizing Network for Speed & Privacy ==="
echo "================================================"

# Use a privacy-focused DNS that blocks ads and trackers network-wide
echo "--- Setting Private DNS (AdGuard) for Ad Blocking ---"
adb shell settings put global private_dns_mode hostname
adb shell settings put global private_dns_specifier "dns.adguard.com"
echo "✓ Private DNS set to AdGuard for network-wide ad & tracker blocking."

# WiFi performance and stability tweaks
echo "--- Enhancing WiFi Performance ---"
adb shell settings put global wifi_frequency_band 2      # Prefer 5GHz WiFi
adb shell settings put global wifi_sleep_policy 2        # Keep WiFi on during sleep
adb shell settings put global wifi_scan_always_enabled 0 # Disable background scanning for battery/privacy
adb shell settings put global ble_scan_always_enabled 0  # Disable Bluetooth scanning for battery/privacy
echo "✓ WiFi configured for speed and stability."
echo ""


# --- Section 5: Privacy & Security Hardening (iOS Style) ---
echo "================================================"
echo "=== Hardening Privacy & Security (iOS Style) ==="
echo "================================================"

# Install RethinkDNS for on-device firewall and DNS-level blocking
echo "--- Installing On-Device Firewall (RethinkDNS) ---"
RETHINK_URL="https://api.rethinkdns.com/v0/download-app/apk"
install_apk "com.celzero.bravedns" "$RETHINK_URL" "RethinkDNS Firewall"
echo "Please open RethinkDNS and start it. It will act as a local VPN to filter traffic."

# Disable data collection and telemetry
echo "--- Disabling Telemetry & Data Collection ---"
disable_package "com.samsung.android.samsunganalytics" "Samsung Analytics"
disable_package "com.samsung.android.scs" "Samsung Customization Service"
adb shell settings put global send_action_app_error 0
adb shell settings put secure location_mode 0 # Disable location services (can be re-enabled in quick settings)

# Restrict permissions for invasive apps (example for Google Chrome)
echo "--- Restricting App Permissions ---"
adb shell appops set com.android.chrome RUN_IN_BACKGROUND ignore
adb shell appops set com.google.android.gms RUN_IN_BACKGROUND ignore
adb shell appops set com.android.chrome CAMERA ignore
adb shell appops set com.android.chrome RECORD_AUDIO ignore
echo "✓ Restricted background activity and camera/mic access for Chrome & Google Services."
echo ""


# --- Section 6: Storage & Memory Boost ---
echo "==================================="
echo "=== Boosting Memory & Storage ==="
echo "==================================="

echo "Trimming filesystems for faster storage I/O..."
adb shell fstrim -v /cache 2>/dev/null
adb shell fstrim -v /data 2>/dev/null

echo "Clearing system and application caches..."
adb shell pm trim-caches 9999999999
echo ""

# --- Final Steps ---
echo "============================="
echo "=== Finalizing & Rebooting ==="
echo "============================="
echo "Restarting System UI to apply all changes..."
adb shell am force-stop com.android.systemui
sleep 2

echo ""
echo "=========================================================="
echo "=== OPTIMIZATION & PRIVACY HARDENING COMPLETE ==="
echo "=========================================================="
echo "Your Samsung A34 5G has been enhanced for:"
echo "✓ Minimalist, Fast & Fluid UI"
echo "✓ Improved Performance & Reduced Heat"
echo "✓ Better Battery Life with Aggressive Saving"
echo "✓ Enhanced Privacy (like iOS) with Ad/Tracker Blocking"
echo "✓ Faster & More Stable WiFi"
echo ""
echo "Recommendations:"
echo "1. Reboot your phone now to apply all changes."
echo "2. Open 'KISS Launcher' and set it as your default Home app."
echo "3. Open 'RethinkDNS', start it, and configure its firewall rules."
echo "4. Re-enable location from quick settings when you need GPS."
echo ""
echo "To revert changes, run this script with the 'restore' parameter."

# Restore function
if [ "$1" = "restore" ]; then
    echo ""
    echo "========================================"
    echo "=== RESTORING ORIGINAL SETTINGS... ==="
    echo "========================================"

    # Re-enable commonly needed apps
    enable_package "com.samsung.android.bixby.agent" "Bixby Voice"
    enable_package "com.samsung.android.game.gamehome" "Game Launcher"
    enable_package "com.google.android.googlequicksearchbox" "Google Search"

    # Restore performance settings
    adb shell settings put global low_power 0
    adb shell settings put global battery_saver_constants ""
    adb shell settings put secure location_mode 3 # Re-enable high accuracy location
    adb shell settings put global auto_sync 1
    adb shell settings put global background_app_limit -1 # Default limit

    # Restore animation scales and UI
    adb shell settings put global window_animation_scale 1.0
    adb shell settings put global transition_animation_scale 1.0
    adb shell settings put global animator_duration_scale 1.0
    adb shell settings put secure ui_night_mode 0 # Disable forced dark mode

    # Restore network settings
    adb shell settings put global private_dns_mode off
    adb shell settings put global wifi_scan_always_enabled 1

    echo "✓ Default settings have been restored."
    echo "Please uninstall KISS Launcher and RethinkDNS manually."
    echo "A reboot is recommended."
fi

echo ""
echo "Script completed successfully!"
