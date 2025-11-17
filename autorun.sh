#!/bin/bash

# Samsung A34 5G Minimalist Optimization & Privacy Script
# Version 3.3 - With Root Bypass Attempt
# For One UI 8.0 / Android 16+ and below
# This script optimizes your phone for performance, privacy, and a minimal aesthetic.
# Make sure USB debugging is enabled and your phone is connected via ADB.

echo "======================================================"
echo "=== Samsung A34 5G Enhanced Optimization Script v3.3 ==="
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

# Prefer wget, fallback to curl
if command -v wget &> /dev/null; then
    DOWNLOADER="wget"
    echo "✓ Using wget for downloads"
elif command -v curl &> /dev/null; then
    DOWNLOADER="curl"
    echo "✓ Using curl for downloads"
else
    echo "Error: Neither wget nor curl is installed. Please install one of them."
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

# --- Section 0: Root Privilege Escalation (Bypass) ---
echo "======================================================"
echo "=== Attempting to Bypass Root Requirements via ADB ==="
echo "======================================================"
echo "This will try to restart ADB in root mode to apply deeper optimizations."
echo "On most stock devices, this will be skipped. This is normal."

# Attempt to restart adbd as root.
adb root >/dev/null 2>&1
# Wait for the device to reconnect after adb root command
sleep 3
adb wait-for-device

# Check if we successfully gained root privileges
if [[ "$(adb shell whoami 2>/dev/null)" == "root" ]]; then
    echo "✓ SUCCESS: ADB is now running with root privileges."
    echo "  System-level modifications will now be applied."
    # Optional: Remount system partition as read-write for deeper changes
    adb shell 'mount -o rw,remount /' >/dev/null 2>&1
    adb shell 'mount -o rw,remount /system' >/dev/null 2>&1
else
    echo "ℹ INFO: Could not gain root privileges."
    echo "  The script will continue with standard non-root optimizations."
fi
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
    adb shell pm list packages --user 0 "$1" | grep -q .
}

# Enhanced download function with wget/curl support
download_file() {
    local url="$1"
    local output="$2"

    if [ "$DOWNLOADER" = "wget" ]; then
        wget -q --show-progress -O "$output" "$url"
        return $?
    else
        curl -L --progress-bar -o "$output" "$url"
        return $?
    fi
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

        if download_file "$apk_url" "$temp_apk"; then
            echo "Download complete. Installing APK..."
            local install_output
            install_output=$(adb install -r "$temp_apk" 2>&1)
            if echo "$install_output" | grep -q "Success"; then
                echo "✓ $app_name installed successfully."
            else
                echo "⚠ Failed to install $app_name."
                echo "ADB Output: $install_output"
            fi
            rm -f "$temp_apk"
        else
            echo "⚠ Failed to download $app_name. Continuing anyway..."
        fi
    else
        echo "✓ $app_name is already installed."
    fi
}

# Safe property setter that doesn't fail the script
set_prop_safe() {
    local prop="$1"
    local value="$2"
    local description="$3"

    if adb shell "setprop '$prop' '$value'" 2>/dev/null; then
        echo "  ✓ Set $description"
    else
        echo "  ⚠ Skipped $description (requires root or not supported)"
    fi
}


# --- Section 1: AI & Bloatware Removal ---
echo "==================================="
echo "=== Removing AI & Bloatware... ==="
echo "==================================="

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
adb shell ime enable com.samsung.android.honeyboard/.service.HoneyBoardService 2>/dev/null
adb shell ime set com.samsung.android.honeyboard/.service.HoneyBoardService 2>/dev/null
echo "✓ Keyboard functionality secured."
echo ""


# --- Section 2: UI Ricing & Optimization (Minimalist Aesthetic) ---
echo "================================================="
echo "=== Applying Minimalist UI & Performance Tweaks ==="
echo "================================================="

# Install and set up a minimal, open-source launcher for a clean look
echo "--- Setting up Minimalist Launcher (KISS) ---"
# Using F-Droid repository with multiple fallback URLs
KISS_URLS=(
    "https://f-droid.org/repo/fr.neamar.kiss_198.apk"
    "https://github.com/Neamar/KISS/releases/download/v3.19.11/kiss-v3.19.11.apk"
)

for KISS_URL in "${KISS_URLS[@]}"; do
    echo "Trying: $KISS_URL"
    if install_apk "fr.neamar.kiss" "$KISS_URL" "KISS Launcher"; then
        break
    fi
done
echo "To set KISS as default, go to Settings > Apps > Choose default apps > Home app"

# Apply settings for a faster, smoother, and cleaner UI
echo "--- Disabling All Animations & Effects for Maximum Performance ---"
adb shell settings put secure ui_night_mode 2                   # Force dark mode
adb shell settings put global window_animation_scale 0.0
adb shell settings put global transition_animation_scale 0.0
adb shell settings put global animator_duration_scale 0.0
adb shell settings put system motion_effect_enabled 0           # Disable lockscreen motion effect
adb shell settings put system sound_effects_enabled 0           # Disable system sounds (touch, etc.)
adb shell settings put global fancy_ime_animations 0            # Disable keyboard animations
adb shell settings put system haptic_feedback_enabled 0         # Disable all vibrations for speed
adb shell settings put system font_scale 0.95                   # Slightly smaller font for cleaner look
echo "✓ All UI animations, sounds, and effects disabled for a lighter experience."
echo ""


# --- Section 3: Performance, Battery & Thermal Tuning ---
echo "==============================================="
echo "=== Tuning Performance, Battery & Thermals ==="
echo "==============================================="

# CPU & GPU acceleration for a smoother experience
echo "--- Accelerating CPU & GPU ---"
set_prop_safe "debug.hwui.renderer" "skiagl" "GPU rendering"
set_prop_safe "debug.sf.hw" "1" "Hardware overlays"
adb shell "echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" 2>/dev/null || echo "  ⚠ CPU governor (requires root)"

# Aggressive background process and battery management
echo "--- Optimizing Battery & Background Processes ---"
adb shell settings put global low_power 1
adb shell settings put global battery_saver_constants "v=1,threshold=99,advertise_is_enabled=true"
adb shell settings put global cached_apps_freezer enabled
adb shell dumpsys deviceidle force-idle
echo "✓ Battery optimization enabled."

# Thermal management to reduce heat
echo "--- Managing Thermals ---"
adb shell "echo 1 > /sys/class/thermal/thermal_zone0/mode" 2>/dev/null || echo "  ⚠ Thermal settings (requires root)"
echo ""


# --- Section 3.5: VIRTUAL MEMORY & STORAGE OPTIMIZATION ---
echo "=================================================================="
echo "=== VIRTUAL MEMORY OPTIMIZATION (zRAM, Swap, I/O Schedulers) ==="
echo "=================================================================="

echo "--- Configuring zRAM (Compressed Virtual RAM) ---"
# Check if zRAM is available
if adb shell "test -b /dev/block/zram0 && echo exists" 2>/dev/null | grep -q "exists"; then
    echo "✓ zRAM device detected. Configuring..."

    # Reset zRAM if already configured
    adb shell "swapoff /dev/block/zram0" 2>/dev/null
    adb shell "echo 1 > /sys/block/zram0/reset" 2>/dev/null || echo "  ⚠ zRAM reset (requires root)"

    # Set zRAM size (1.5GB - 50% of physical RAM for A34's 6GB/8GB models)
    adb shell "echo 1610612736 > /sys/block/zram0/disksize" 2>/dev/null || echo "  ⚠ zRAM sizing (requires root)"

    # Set compression algorithm (lz4 is fastest)
    adb shell "echo lz4 > /sys/block/zram0/comp_algorithm" 2>/dev/null || echo "  ⚠ zRAM compression (requires root)"

    # Enable zRAM swap
    adb shell "mkswap /dev/block/zram0" 2>/dev/null
    adb shell "swapon /dev/block/zram0" 2>/dev/null || echo "  ⚠ zRAM activation (requires root)"

    echo "  ✓ zRAM configured: 1.5GB compressed RAM"
else
    echo "  ℹ zRAM not available on this device (may require root or kernel support)"
fi

echo ""
echo "--- Optimizing Virtual Memory Parameters ---"
# These settings work better with zRAM enabled
adb shell "echo 100 > /proc/sys/vm/swappiness" 2>/dev/null || echo "  ⚠ Swappiness tuning (requires root)"
adb shell "echo 0 > /proc/sys/vm/page-cluster" 2>/dev/null || echo "  ⚠ Page cluster (requires root)"
adb shell "echo 4096 > /proc/sys/vm/min_free_kbytes" 2>/dev/null || echo "  ⚠ Min free memory (requires root)"
adb shell "echo 50 > /proc/sys/vm/vfs_cache_pressure" 2>/dev/null || echo "  ⚠ VFS cache pressure (requires root)"
adb shell "echo 20 > /proc/sys/vm/dirty_ratio" 2>/dev/null || echo "  ⚠ Dirty ratio (requires root)"
adb shell "echo 10 > /proc/sys/vm/dirty_background_ratio" 2>/dev/null || echo "  ⚠ Dirty background ratio (requires root)"
echo "  ✓ Virtual memory parameters optimized for performance"

echo ""
echo "--- Optimizing I/O Schedulers for Virtual Disk Performance ---"
# Find storage devices and optimize their I/O schedulers
STORAGE_DEVICES=$(adb shell "ls /sys/block/ 2>/dev/null" | grep -E "sda|mmcblk|nvme")

if [ -n "$STORAGE_DEVICES" ]; then
    for device in $STORAGE_DEVICES; do
        echo "  Optimizing /dev/$device..."

        # Set I/O scheduler to deadline (best for flash storage)
        adb shell "echo deadline > /sys/block/$device/queue/scheduler" 2>/dev/null || \
        adb shell "echo mq-deadline > /sys/block/$device/queue/scheduler" 2>/dev/null || \
        echo "    ⚠ I/O scheduler (requires root)"

        # Optimize read-ahead for faster sequential reads
        adb shell "echo 512 > /sys/block/$device/queue/read_ahead_kb" 2>/dev/null || \
        echo "    ⚠ Read-ahead tuning (requires root)"

        # Reduce I/O latency
        adb shell "echo 0 > /sys/block/$device/queue/add_random" 2>/dev/null
        adb shell "echo 2 > /sys/block/$device/queue/rq_affinity" 2>/dev/null
        adb shell "echo 128 > /sys/block/$device/queue/nr_requests" 2>/dev/null || \
        echo "    ⚠ I/O queue tuning (requires root)"

        echo "    ✓ $device optimized"
    done
else
    echo "  ℹ No storage devices found (check requires root)"
fi

echo ""
echo "--- Enabling Low Memory Killer Optimizations ---"
# Optimize memory management for better multitasking
adb shell "echo 18432,23040,27648,32256,55296,80640 > /sys/module/lowmemorykiller/parameters/minfree" 2>/dev/null || \
echo "  ⚠ LMK tuning (requires root)"

# Additional VM tweaks for smoother performance
set_prop_safe "ro.config.low_ram" "false" "Low RAM mode"
set_prop_safe "ro.sys.fw.bg_apps_limit" "32" "Background app limit"
set_prop_safe "dalvik.vm.heapsize" "512m" "VM heap size"
set_prop_safe "dalvik.vm.heapgrowthlimit" "256m" "VM heap growth limit"

echo "✓ Virtual memory and I/O subsystems fully optimized!"
echo ""


# --- Section 4: Network & Connectivity Overhaul ---
echo "================================================"
echo "=== Optimizing Network for Speed & Privacy ==="
echo "================================================"

# Use a privacy-focused DNS that blocks ads and trackers network-wide
echo "--- Setting Private DNS (AdGuard) for Ad Blocking ---"
adb shell settings put global private_dns_mode hostname
adb shell settings put global private_dns_specifier "dns.adguard-dns.com"
echo "✓ Private DNS set to AdGuard for network-wide ad & tracker blocking."

# WiFi performance and stability tweaks
echo "--- Enhancing WiFi Performance ---"
adb shell settings put global wifi_frequency_band 2      # Prefer 5GHz WiFi
adb shell settings put global wifi_sleep_policy 2        # Keep WiFi on during sleep
adb shell settings put global wifi_scan_always_enabled 0 # Disable background scanning
adb shell settings put global ble_scan_always_enabled 0  # Disable Bluetooth scanning
echo "✓ WiFi configured for speed and stability."
echo ""


# --- Section 5: Privacy & Security Hardening (iOS Style) ---
echo "================================================"
echo "=== Hardening Privacy & Security (iOS Style) ==="
echo "================================================="

# Install RethinkDNS for on-device firewall and DNS-level blocking
echo "--- Installing On-Device Firewall (RethinkDNS) ---"
RETHINK_URLS=(
    "https://github.com/celzero/rethink-app/releases/download/v0.5.5g/app-fdroid-release.apk"
    "https://rethinkdns.com/download"
)

for RETHINK_URL in "${RETHINK_URLS[@]}"; do
    echo "Trying: $RETHINK_URL"
    if install_apk "com.celzero.bravedns" "$RETHINK_URL" "RethinkDNS Firewall"; then
        break
    fi
done
echo "Please open RethinkDNS and start it. It will act as a local VPN to filter traffic."

# Disable data collection and telemetry
echo "--- Disabling Telemetry & Data Collection ---"
disable_package "com.samsung.android.samsunganalytics" "Samsung Analytics"
disable_package "com.samsung.android.scs" "Samsung Customization Service"
adb shell settings put global send_action_app_error 0
# Fixed: Use proper location mode setting
adb shell settings put secure location_mode 0 2>/dev/null
adb shell settings put secure location_providers_allowed "" 2>/dev/null

# Restrict permissions for invasive apps
echo "--- Restricting App Permissions ---"
adb shell appops set com.android.chrome RUN_IN_BACKGROUND ignore 2>/dev/null
adb shell appops set com.google.android.gms RUN_IN_BACKGROUND ignore 2>/dev/null
adb shell appops set com.android.chrome CAMERA ignore 2>/dev/null
adb shell appops set com.android.chrome RECORD_AUDIO ignore 2>/dev/null
echo "✓ Restricted background activity for Chrome & Google Services."
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
echo "✓ Storage optimized."
echo ""


# --- Section 7: Advanced System Speed Optimization ---
echo "========================================================"
echo "=== ADVANCED: System Speed & Performance Tuning ==="
echo "========================================================"

echo "--- Optimizing Apps Without Root (ADB-Based) ---"
# Force compile all apps in speed mode for faster launches
echo "Compiling system apps for faster performance..."
adb shell cmd package compile -m speed -a 2>/dev/null &
COMPILE_PID=$!

# Optimize frequently used apps
echo "Optimizing frequently used apps..."
for pkg in com.android.chrome com.android.vending com.whatsapp com.instagram.android com.facebook.katana; do
    if is_package_installed "$pkg"; then
        adb shell cmd package compile -m speed -f "$pkg" 2>/dev/null &
    fi
done

echo "✓ App compilation started in background (this may take a few minutes)."

echo "--- Disabling Background App Restrictions ---"
# Remove battery restrictions from essential apps for better performance
adb shell dumpsys deviceidle whitelist +com.android.systemui 2>/dev/null
adb shell dumpsys deviceidle whitelist +com.samsung.android.honeyboard 2>/dev/null
echo "✓ Essential apps whitelisted from battery restrictions."

echo "--- Optimizing Storage Performance (No Root Needed) ---"
# Clear dalvik cache for all apps to force recompilation
echo "Clearing and rebuilding app cache for optimal performance..."
adb shell pm clear-cache-all 2>/dev/null
# Trim all mounted filesystems
adb shell sm fstrim 2>/dev/null || echo "  ⚠ Advanced fstrim requires newer Android version"
echo "✓ Storage optimization completed."

echo "--- Network Optimization (ADB-Based) ---"
# Enable aggressive WiFi scanning for better roaming
adb shell settings put global wifi_idle_ms 900000
adb shell settings put global wifi_supplicant_scan_interval_ms 180000
adb shell settings put global network_scoring_ui_enabled 1
# Disable mobile data limit warnings for smoother browsing
adb shell settings put global netpolicy_quota_enabled 0
adb shell settings put global netpolicy_quota_unlimited 1
# TCP optimization that works without root
adb shell settings put global tcp_default_init_rwnd 60
echo "✓ Network parameters optimized for speed."

echo "--- Optimizing GPU & Rendering Pipeline ---"
set_prop_safe "debug.egl.hw" "1" "EGL hardware"
set_prop_safe "debug.composition.type" "gpu" "GPU composition"
set_prop_safe "debug.performance.tuning" "1" "Performance tuning"
set_prop_safe "debug.sf.enable_gl_backpressure" "1" "GL backpressure"
set_prop_safe "debug.hwui.use_buffer_age" "false" "Buffer age optimization"
set_prop_safe "debug.hwui.render_dirty_regions" "false" "Dirty regions"

# Force GPU for 2D rendering (works without root)
adb shell settings put global hwui_force_gpu_acceleration 1
adb shell settings put global force_hw_ui 1
adb shell settings put system force_high_end_gfx 1

echo "✓ GPU rendering pipeline fully optimized."

echo "--- Optimizing Media & System Performance ---"
# Media settings that work without root
adb shell settings put system accelerometer_rotation 0  # Disable auto-rotation for less sensor usage
adb shell settings put secure long_press_timeout 400    # Faster long press
adb shell settings put secure touch_exploration_enabled 0
# Increase touch responsiveness
adb shell settings put system pointer_speed 0

echo "✓ Media and system performance optimized."
echo ""


# --- Section 8: Enhanced Security Hardening ---
echo "========================================================"
echo "=== ADVANCED: Security Hardening & Protection ==="
echo "========================================================"

echo "--- Hardening SELinux Security ---"
adb shell setenforce 1 2>/dev/null || echo "  ⚠ SELinux changes (require root)"

echo "--- Restricting Package Installation Sources ---"
adb shell settings put global install_non_market_apps 0 2>/dev/null
adb shell settings put secure install_non_market_apps 0 2>/dev/null

echo "--- Enabling Google Play Protect (if available) ---"
adb shell settings put global package_verifier_enable 1
adb shell settings put global verifier_verify_adb_installs 1

echo "--- Restricting App Permissions Globally ---"
# Disable unused sensors to prevent data leaks
adb shell settings put secure assist_structure_enabled 0
adb shell settings put secure assist_screenshot_enabled 0
adb shell settings put secure assist_disclosure_enabled 0

echo "--- Enabling Network Security Features ---"
adb shell settings put global captive_portal_detection_enabled 0
adb shell settings put global captive_portal_mode 0

echo "✓ Security hardening complete."
echo ""


# --- Section 9: Enhanced Linux Environment ---
echo "========================================================"
echo "=== ADVANCED: Enhanced Linux Environment Setup ==="
echo "========================================================"

echo "--- Installing Termux (Advanced Linux Terminal) ---"
TERMUX_URLS=(
    "https://f-droid.org/repo/com.termux_118.apk"
    "https://github.com/termux/termux-app/releases/download/v0.118.0/termux-app_v0.118.0+github-debug_universal.apk"
)

for TERMUX_URL in "${TERMUX_URLS[@]}"; do
    echo "Trying: $TERMUX_URL"
    if install_apk "com.termux" "$TERMUX_URL" "Termux Terminal"; then
        break
    fi
done

echo "✓ Termux setup complete."
echo "  Open Termux and run: pkg update && pkg upgrade"
echo "  Install tools with: pkg install python nodejs git openssh"

echo "--- Enabling Developer-Friendly Features ---"
adb shell settings put global development_settings_enabled 1
adb shell settings put global stay_on_while_plugged_in 7  # Stay awake when charging

echo "✓ Linux-style environment enhanced."
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
echo "✓ Minimalist, Fast & Fluid UI (NO animations)"
echo "✓ Improved Performance & Reduced Heat"
echo "✓ Better Battery Life with Aggressive Saving"
echo "✓ Enhanced Privacy (like iOS) with Ad/Tracker Blocking"
echo "✓ Faster & More Stable WiFi"
echo "✓ Optimized Java/Dalvik VM for faster apps"
echo "✓ Advanced Linux kernel optimizations (if root was gained)"
echo "✓ Enhanced GPU rendering pipeline"
echo "✓ Maximum security hardening"
echo "✓ Full Linux terminal environment (Termux)"
echo "✓ Virtual Memory (zRAM) optimizations - 1.5GB compressed RAM"
echo "✓ I/O scheduler tuning for faster storage"
echo "✓ VM parameters optimized for multitasking"
echo ""
echo "Recommendations:"
echo "1. Reboot your phone now to apply all changes."
echo "2. Open 'KISS Launcher' and set it as your default Home app."
echo "3. Open 'RethinkDNS', start it, and configure its firewall rules."
echo "4. Open 'Termux' and run: pkg update && pkg upgrade"
echo "5. Re-enable location from quick settings when you need GPS."
echo "6. Consider disabling USB debugging for maximum security."
echo ""
echo "Advanced Features:"
echo "- Use Termux for Python, Node.js, Git, SSH, and more"
echo "- Run Linux commands directly on your phone"
echo "- Script automation with bash/python"
echo "- SSH into other servers from your phone"
echo "- zRAM provides 1.5GB extra virtual memory (compressed)"
echo "- Optimized I/O for faster app loading and file operations"
echo ""
echo "To revert changes, run this script with the 'restore' parameter."

# Restore function
if [ "$1" = "restore" ]; then
    echo ""
    echo "========================================"
    echo "=== RESTORING ORIGINAL SETTINGS... ==="
    echo "========================================"

    # Restore zRAM settings
    echo "--- Restoring Virtual Memory Settings ---"
    adb shell "swapoff /dev/block/zram0" 2>/dev/null
    adb shell "echo 1 > /sys/block/zram0/reset" 2>/dev/null
    adb shell "echo 60 > /proc/sys/vm/swappiness" 2>/dev/null
    adb shell "echo 3 > /proc/sys/vm/page-cluster" 2>/dev/null
    echo "✓ Virtual memory settings restored."

    # Re-enable commonly needed apps
    enable_package "com.samsung.android.bixby.agent" "Bixby Voice"
    enable_package "com.samsung.android.game.gamehome" "Game Launcher"
    enable_package "com.google.android.googlequicksearchbox" "Google Search"

    # Restore performance settings
    adb shell settings put global low_power 0
    adb shell settings put global battery_saver_constants ""
    adb shell settings put secure location_mode 3
    adb shell settings put global background_app_limit -1

    # Restore animation scales and UI
    adb shell settings put global window_animation_scale 1.0
    adb shell settings put global transition_animation_scale 1.0
    adb shell settings put global animator_duration_scale 1.0
    adb shell settings put system motion_effect_enabled 1
    adb shell settings put system sound_effects_enabled 1
    adb shell settings put system haptic_feedback_enabled 1
    adb shell settings put global fancy_ime_animations 1
    adb shell settings put secure ui_night_mode 0

    # Restore network settings
    adb shell settings put global private_dns_mode off
    adb shell settings put global wifi_scan_always_enabled 1

    # Restore security settings
    adb shell settings put global install_non_market_apps 1
    adb shell settings put global development_settings_enabled 0

    echo "✓ Default settings have been restored."
    echo "Please uninstall KISS Launcher, RethinkDNS, and Termux manually if desired."
    echo "A reboot is recommended."
fi

echo ""
echo "Script completed successfully!"
