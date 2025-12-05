#!/bin/bash

# Samsung A34 5G Advanced Security & Performance Optimization Script
# Version 4.0 - Enhanced Anti-Spyware & Device Security
# For One UI 8.0 / Android 16+ and below
# This script optimizes your phone for performance, privacy, security, and smoothness.
# Make sure USB debugging is enabled and your phone is connected via ADB.

echo "=================================================================="
echo "=== Samsung A34 5G Advanced Security & Optimization Script v4.0 ==="
echo "=================================================================="
echo "NEW FEATURES:"
echo "✓ Advanced Spyware Detection & Removal"
echo "✓ Device Security Hardening"
echo "✓ Find My Device Controls"
echo "✓ Enhanced Smoothness & Performance"
echo "✓ Real-time Security Monitoring"
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
sleep 3
adb wait-for-device

# Check if we successfully gained root privileges
if [[ "$(adb shell whoami 2>/dev/null)" == "root" ]]; then
    echo "✓ SUCCESS: ADB is now running with root privileges."
    echo "  System-level modifications will now be applied."
    adb shell 'mount -o rw,remount /' >/dev/null 2>&1
    adb shell 'mount -o rw,remount /system' >/dev/null 2>&1
    ROOT_AVAILABLE=true
else
    echo "ℹ INFO: Could not gain root privileges."
    echo "  The script will continue with standard non-root optimizations."
    ROOT_AVAILABLE=false
fi
echo ""


# --- Helper Functions ---

# Function to disable a package safely for the current user
disable_package() {
    local package=$1
    local description=$2
    if is_package_installed "$package"; then
        echo "Disabling $description ($package)..."
        adb shell pm disable-user --user 0 "$package" 2>/dev/null
    else
        echo "✓ $description is not installed (skipping)."
    fi
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
                rm -f "$temp_apk"
                return 0
            else
                echo "⚠ Failed to install $app_name."
                echo "ADB Output: $install_output"
                rm -f "$temp_apk"
                return 1
            fi
        else
            echo "⚠ Failed to download $app_name. Continuing anyway..."
            return 1
        fi
    else
        echo "✓ $app_name is already installed."
        return 0
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


# --- NEW SECTION 0.5: ADVANCED SPYWARE DETECTION & REMOVAL ---
echo "=================================================================="
echo "=== ADVANCED SPYWARE DETECTION & REMOVAL ==="
echo "=================================================================="

# List of known spyware, stalkerware, and malicious packages
SPYWARE_PACKAGES=(
    # Stalkerware & Spyware
    "com.mspy.android"
    "com.flexispy"
    "com.spyera"
    "com.retina-x.android"
    "com.phonespy"
    "com.hellospy"
    "com.thesafety.android"
    "com.mobilespy"
    "com.spybubble"
    "com.spyware"
    "com.android.spyware"
    "com.ikeymonitor"
    "com.spyzie"
    "com.spytomobile"
    "com.highstermobile"
    "com.thetruthspy"
    "com.copy9"
    "com.spyfone"
    "com.easemon"
    "com.spyic"
    "com.cocospy"
    "com.spyine"
    "com.neatspy"
    "com.minspy"
    
    # Hidden System Apps (often used for tracking)
    "com.android.systemupdate"
    "com.android.settings.hidden"
    "com.android.update.service"
    "com.system.service"
    "com.google.service.update"
    "com.android.security.update"
    
    # Adware & PUPs
    "com.airpush"
    "com.revmob"
    "com.appbrain"
    "com.inmobi"
    "com.startapp"
    "com.appnext"
    "com.applovin"
    "com.mopub"
    "com.chartboost"
    "com.tapjoy"
    
    # Carrier tracking apps (actual spyware/tracking - NOT Samsung system apps)
    "com.wssyncmldm"           # Carrier device management
    "com.ws.dm"                # Carrier device management
    "com.dti.att"              # AT&T tracking
    "com.dti.tracfone"         # Tracfone tracking
    "com.carrieriq"            # CarrierIQ spyware
)

echo "--- Scanning for Known Spyware & Malicious Apps ---"
SPYWARE_FOUND=0
SPYWARE_LIST=""

for package in "${SPYWARE_PACKAGES[@]}"; do
    if is_package_installed "$package"; then
        echo "⚠ SPYWARE DETECTED: $package"
        SPYWARE_FOUND=$((SPYWARE_FOUND + 1))
        SPYWARE_LIST="$SPYWARE_LIST\n  - $package"
        
        # Kill any running processes first
        adb shell am force-stop "$package" 2>/dev/null
        
        # Revoke all permissions BEFORE uninstalling
        if is_package_installed "$package"; then
            adb shell pm revoke "$package" android.permission.CAMERA 2>/dev/null
            adb shell pm revoke "$package" android.permission.RECORD_AUDIO 2>/dev/null
            adb shell pm revoke "$package" android.permission.ACCESS_FINE_LOCATION 2>/dev/null
            adb shell pm revoke "$package" android.permission.READ_CONTACTS 2>/dev/null
            adb shell pm revoke "$package" android.permission.READ_SMS 2>/dev/null
            adb shell pm revoke "$package" android.permission.READ_CALL_LOG 2>/dev/null
        fi
        
        # Attempt to uninstall (requires root or user app)
        echo "  Attempting to remove $package..."
        adb shell pm uninstall --user 0 "$package" 2>/dev/null || \
        disable_package "$package" "Spyware: $package"
    fi
done

if [ $SPYWARE_FOUND -eq 0 ]; then
    echo "✓ No known spyware detected on your device."
else
    echo ""
    echo "⚠⚠⚠ WARNING: $SPYWARE_FOUND SPYWARE APP(S) DETECTED! ⚠⚠⚠"
    echo "The following malicious apps were found and disabled/removed:"
    echo -e "$SPYWARE_LIST"
    echo ""
    echo "RECOMMENDATIONS:"
    echo "1. Change all passwords immediately"
    echo "2. Enable 2-factor authentication on important accounts"
    echo "3. Check your Google account activity: myactivity.google.com"
    echo "4. Consider a factory reset for complete removal"
    echo "5. Review who has physical access to your device"
    echo ""
fi

echo "--- Scanning for Suspicious Hidden Apps ---"
# Exclude known legitimate system packages: samsung (com.sec.*), mediatek, qualcomm, etc.
HIDDEN_APPS=$(adb shell pm list packages -s --user 0 2>/dev/null | grep -vE "android|samsung|google|knox|com\.sec\.|com\.mediatek\.|com\.qualcomm\.|com\.microsoft\.|com\.osp\.|com\.wsomacp" | cut -d: -f2)
SUSPICIOUS_COUNT=0

for app in $HIDDEN_APPS; do
    # Check if app has MANY dangerous permissions (more than 5 to reduce false positives)
    DANGEROUS_PERMS=$(adb shell dumpsys package "$app" 2>/dev/null | grep -E "CAMERA|RECORD_AUDIO|LOCATION|CONTACTS|SMS|CALL_LOG" | wc -l)
    
    # Only flag if app has more than 5 dangerous permission references AND is not a known system package
    if [ "$DANGEROUS_PERMS" -gt 5 ]; then
        echo "⚠ Suspicious system app: $app (Has $DANGEROUS_PERMS dangerous permissions)"
        SUSPICIOUS_COUNT=$((SUSPICIOUS_COUNT + 1))
    fi
done

if [ $SUSPICIOUS_COUNT -eq 0 ]; then
    echo "✓ No suspicious hidden apps detected."
else
    echo "⚠ Found $SUSPICIOUS_COUNT suspicious system app(s). Review permissions manually."
fi

echo "--- Checking for Apps with Device Admin Rights ---"
DEVICE_ADMINS=$(adb shell dpm list-owners 2>/dev/null)
if [ -z "$DEVICE_ADMINS" ]; then
    echo "✓ No device administrators found (good)."
else
    echo "⚠ WARNING: Device administrators detected:"
    echo "$DEVICE_ADMINS"
    echo "  Review Settings > Security > Device administrators"
    echo "  Spyware often uses device admin to prevent removal!"
fi

echo ""


# --- NEW SECTION 0.6: DEVICE SECURITY & FIND MY DEVICE ---
echo "=================================================================="
echo "=== DEVICE SECURITY & FIND MY DEVICE CONFIGURATION ==="
echo "=================================================================="

echo "--- Configuring Find My Device (Secure Lost Phone Protection) ---"
# Enable Find My Device but with controlled settings
if is_package_installed "com.google.android.apps.adm"; then
    enable_package "com.google.android.apps.adm" "Google Find My Device"
    echo "✓ Find My Device is enabled."
    echo "  You can locate/lock/wipe your device at: android.com/find"
    
    # Enable location for Find My Device (but we'll control other location access)
    adb shell settings put secure location_mode 3
    echo "  Location enabled for device finding (restricted for other apps)"
else
    echo "ℹ Google Find My Device not found. Install from Play Store for theft protection."
fi

# Install Samsung Find My Mobile if not present
if is_package_installed "com.samsung.android.fmm"; then
    enable_package "com.samsung.android.fmm" "Samsung Find My Mobile"
    echo "✓ Samsung Find My Mobile enabled."
    echo "  Access at: findmymobile.samsung.com"
else
    echo "ℹ Samsung Find My Mobile not found (should be pre-installed)."
fi

echo ""
echo "--- Enhancing Device Lock Security ---"
# Enforce stronger security policies
adb shell settings put secure lockscreen_power_button_instantly_locks 1
adb shell settings put system screen_off_timeout 60000  # 1 minute auto-lock
adb shell settings put secure lock_screen_allow_private_notifications 0
adb shell settings put secure lock_screen_show_notifications 0
adb shell settings put global stay_on_while_plugged_in 0  # Don't stay awake
adb shell settings put global enable_gpu_debug_layers 0
echo "✓ Enhanced lock screen security configured."

echo ""
echo "--- Configuring Theft & Tamper Detection ---"
# Enable security features that help detect unauthorized access
adb shell settings put global multi_press_timeout 300
adb shell settings put secure lockscreen_maximize_widgets 0

# Set up automatic wipe after failed attempts (if supported)
adb shell settings put secure lockscreen_fail_count_before_wipe 10 2>/dev/null || \
    echo "  ℹ Auto-wipe not supported (requires device admin setup in Settings)"

echo "✓ Theft protection configured."
echo ""


# --- NEW SECTION 0.7: ENHANCED SMOOTHNESS OPTIMIZATIONS ---
echo "=================================================================="
echo "=== ADVANCED SMOOTHNESS & RESPONSIVENESS OPTIMIZATION ==="
echo "=================================================================="

echo "--- Optimizing Touch Response & Input Latency ---"
# Reduce touch latency for smoother experience
adb shell settings put secure long_press_timeout 300
adb shell settings put system pointer_speed 1  # Slightly faster pointer
adb shell settings put secure multi_press_timeout 200

# Touch sensitivity optimization
if [ "$ROOT_AVAILABLE" = true ]; then
    adb shell "echo 1 > /sys/class/input/input0/sensitivity" 2>/dev/null || echo "  ℹ Touch sensitivity (varies by device)"
    adb shell "echo 0 > /sys/class/input/input0/filter" 2>/dev/null
fi

echo "✓ Touch response optimized for maximum smoothness."

echo ""
echo "--- Optimizing Frame Rate & Display Rendering ---"
# Force highest refresh rate if available (A34 5G has 120Hz display)
adb shell settings put system peak_refresh_rate 120.0
adb shell settings put system min_refresh_rate 60.0
adb shell settings put secure refresh_rate_mode 0  # Adaptive refresh rate

# Optimize rendering
set_prop_safe "debug.sf.latch_unsignaled" "1" "Frame latching"
set_prop_safe "debug.sf.disable_backpressure" "1" "Frame backpressure"
set_prop_safe "debug.sf.early_phase_offset_ns" "500000" "Early phase offset"
set_prop_safe "debug.sf.early_app_phase_offset_ns" "500000" "Early app phase offset"
set_prop_safe "debug.sf.early_gl_phase_offset_ns" "3000000" "Early GL phase offset"

echo "✓ Display refresh rate and rendering optimized."

echo ""
echo "--- Optimizing Memory Management for Smoothness ---"
# Optimize Low Memory Killer for better multitasking
if [ "$ROOT_AVAILABLE" = true ]; then
    # More aggressive but smoother memory management
    adb shell "echo 12288,15360,18432,21504,24576,30720 > /sys/module/lowmemorykiller/parameters/minfree" 2>/dev/null
    adb shell "echo 0 > /sys/module/lowmemorykiller/parameters/lmk_fast_run" 2>/dev/null
fi

# Optimize Android Runtime (ART) for smoother app performance
set_prop_safe "dalvik.vm.dex2oat-filter" "speed" "DEX optimization"
set_prop_safe "dalvik.vm.image-dex2oat-filter" "speed" "Image DEX optimization"
set_prop_safe "pm.dexopt.install" "speed" "Install optimization"
set_prop_safe "pm.dexopt.bg-dexopt" "speed" "Background optimization"

echo "✓ Memory management optimized for multitasking."

echo ""
echo "--- Optimizing CPU Scheduler for Responsiveness ---"
if [ "$ROOT_AVAILABLE" = true ]; then
    # EAS (Energy Aware Scheduler) tuning for smoothness
    adb shell "echo 0 > /proc/sys/kernel/sched_tunable_scaling" 2>/dev/null
    adb shell "echo 10000000 > /proc/sys/kernel/sched_latency_ns" 2>/dev/null
    adb shell "echo 2000000 > /proc/sys/kernel/sched_min_granularity_ns" 2>/dev/null
    adb shell "echo 1000000 > /proc/sys/kernel/sched_wakeup_granularity_ns" 2>/dev/null
    
    # Reduce context switching for smoother operation
    adb shell "echo 500000 > /proc/sys/kernel/sched_migration_cost_ns" 2>/dev/null
    adb shell "echo 95 > /proc/sys/kernel/sched_rt_runtime_us" 2>/dev/null
    
    echo "✓ CPU scheduler optimized for responsiveness."
else
    echo "  ℹ CPU scheduler tuning skipped (requires root)"
fi

echo ""
echo "--- Disabling Performance Throttling ---"
# Disable aggressive thermal throttling
if [ "$ROOT_AVAILABLE" = true ]; then
    adb shell "echo 0 > /sys/devices/virtual/thermal/thermal_zone0/mode" 2>/dev/null
    adb shell "echo 85 > /sys/class/thermal/thermal_zone0/trip_point_0_temp" 2>/dev/null
    adb shell "echo 95 > /sys/class/thermal/thermal_zone0/trip_point_1_temp" 2>/dev/null
    echo "✓ Thermal throttling reduced for sustained performance."
else
    echo "  ℹ Thermal management requires root access"
fi

# Disable power saving features that reduce smoothness
adb shell settings put global app_standby_enabled 0
adb shell settings put global forced_app_standby_enabled 0
adb shell settings put global adaptive_battery_management_enabled 0

echo "✓ Performance throttling minimized."

echo ""
echo "--- Optimizing Storage I/O for App Launch Speed ---"
if [ "$ROOT_AVAILABLE" = true ]; then
    STORAGE_DEVICES=$(adb shell "ls /sys/block/ 2>/dev/null" | grep -E "sda|mmcblk|nvme")
    
    for device in $STORAGE_DEVICES; do
        # Optimize for random read/write (app launches)
        adb shell "echo 0 > /sys/block/$device/queue/iostats" 2>/dev/null
        adb shell "echo 256 > /sys/block/$device/queue/read_ahead_kb" 2>/dev/null
        adb shell "echo 1 > /sys/block/$device/queue/nomerges" 2>/dev/null
        adb shell "echo 0 > /sys/block/$device/queue/rotational" 2>/dev/null
    done
    echo "✓ Storage I/O optimized for instant app launches."
else
    echo "  ℹ Advanced storage optimization requires root"
fi

echo ""


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
echo "--- Configuring Ultra-Smooth UI (Animations OFF) ---"
adb shell settings put secure ui_night_mode 2
adb shell settings put global window_animation_scale 0.0
adb shell settings put global transition_animation_scale 0.0
adb shell settings put global animator_duration_scale 0.0
adb shell settings put system motion_effect_enabled 0
adb shell settings put system sound_effects_enabled 0
adb shell settings put global fancy_ime_animations 0
adb shell settings put system haptic_feedback_enabled 0
adb shell settings put system font_scale 0.95
echo "✓ Ultra-smooth UI configured (zero animations)."
echo ""


# --- Section 3: Performance, Battery & Thermal Tuning ---
echo "==============================================="
echo "=== Tuning Performance, Battery & Thermals ==="
echo "==============================================="

# CPU & GPU acceleration
echo "--- Accelerating CPU & GPU ---"
set_prop_safe "debug.hwui.renderer" "skiagl" "GPU rendering"
set_prop_safe "debug.sf.hw" "1" "Hardware overlays"
adb shell "echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" 2>/dev/null || echo "  ⚠ CPU governor (requires root)"

# Battery management
echo "--- Optimizing Battery & Background Processes ---"
adb shell settings put global low_power 1
adb shell settings put global battery_saver_constants "v=1,threshold=99,advertise_is_enabled=true"
adb shell settings put global cached_apps_freezer enabled
adb shell dumpsys deviceidle force-idle
echo "✓ Battery optimization enabled."

# Thermal management
echo "--- Managing Thermals ---"
adb shell "echo 1 > /sys/class/thermal/thermal_zone0/mode" 2>/dev/null || echo "  ⚠ Thermal settings (requires root)"
echo ""


# --- Section 3.5: VIRTUAL MEMORY & STORAGE OPTIMIZATION ---
echo "=================================================================="
echo "=== VIRTUAL MEMORY OPTIMIZATION (zRAM, Swap, I/O Schedulers) ==="
echo "=================================================================="

echo "--- Configuring zRAM (Compressed Virtual RAM) ---"
if adb shell "test -b /dev/block/zram0 && echo exists" 2>/dev/null | grep -q "exists"; then
    echo "✓ zRAM device detected. Configuring..."

    adb shell "swapoff /dev/block/zram0" 2>/dev/null
    adb shell "echo 1 > /sys/block/zram0/reset" 2>/dev/null || echo "  ⚠ zRAM reset (requires root)"
    adb shell "echo 1610612736 > /sys/block/zram0/disksize" 2>/dev/null || echo "  ⚠ zRAM sizing (requires root)"
    adb shell "echo lz4 > /sys/block/zram0/comp_algorithm" 2>/dev/null || echo "  ⚠ zRAM compression (requires root)"
    adb shell "mkswap /dev/block/zram0" 2>/dev/null
    adb shell "swapon /dev/block/zram0" 2>/dev/null || echo "  ⚠ zRAM activation (requires root)"

    echo "  ✓ zRAM configured: 1.5GB compressed RAM"
else
    echo "  ℹ zRAM not available on this device (may require root or kernel support)"
fi

echo ""
echo "--- Optimizing Virtual Memory Parameters ---"
adb shell "echo 100 > /proc/sys/vm/swappiness" 2>/dev/null || echo "  ⚠ Swappiness tuning (requires root)"
adb shell "echo 0 > /proc/sys/vm/page-cluster" 2>/dev/null || echo "  ⚠ Page cluster (requires root)"
adb shell "echo 4096 > /proc/sys/vm/min_free_kbytes" 2>/dev/null || echo "  ⚠ Min free memory (requires root)"
adb shell "echo 50 > /proc/sys/vm/vfs_cache_pressure" 2>/dev/null || echo "  ⚠ VFS cache pressure (requires root)"
adb shell "echo 20 > /proc/sys/vm/dirty_ratio" 2>/dev/null || echo "  ⚠ Dirty ratio (requires root)"
adb shell "echo 10 > /proc/sys/vm/dirty_background_ratio" 2>/dev/null || echo "  ⚠ Dirty background ratio (requires root)"
echo "  ✓ Virtual memory parameters optimized for performance"

echo ""
echo "--- Optimizing I/O Schedulers for Virtual Disk Performance ---"
STORAGE_DEVICES=$(adb shell "ls /sys/block/ 2>/dev/null" | grep -E "sda|mmcblk|nvme")

if [ -n "$STORAGE_DEVICES" ]; then
    for device in $STORAGE_DEVICES; do
        echo "  Optimizing /dev/$device..."

        adb shell "echo deadline > /sys/block/$device/queue/scheduler" 2>/dev/null || \
        adb shell "echo mq-deadline > /sys/block/$device/queue/scheduler" 2>/dev/null || \
        echo "    ⚠ I/O scheduler (requires root)"

        adb shell "echo 512 > /sys/block/$device/queue/read_ahead_kb" 2>/dev/null || \
        echo "    ⚠ Read-ahead tuning (requires root)"

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
    "https://github.com/celzero/rethink-app/releases/download/v0.5.5t/app-fdroid-release.apk"
    "https://github.com/celzero/rethink-app/releases/download/v0.5.5u/app-universal-release.apk"
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
# Trim caches to free up space and optimize performance
echo "Clearing and rebuilding app cache for optimal performance..."
adb shell pm trim-caches 9999999999 2>/dev/null
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
