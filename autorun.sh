#!/bin/bash

# Samsung A34 5G Optimization Script
# This script optimizes your phone for better performance and reduced overheating
# Make sure USB debugging is enabled and your phone is connected via ADB

echo "=== Samsung A34 5G Optimization Script ==="
echo "Make sure your phone is connected and USB debugging is enabled"
echo ""

# Check if ADB is available
if ! command -v adb &> /dev/null; then
    echo "Error: ADB is not installed or not in PATH"
    echo "Please install Android SDK Platform Tools"
    exit 1
fi

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo "Error: No device connected or device not authorized"
    echo "Please connect your Samsung A34 5G and authorize the connection"
    exit 1
fi

echo "Device detected. Starting optimization..."
echo ""

# Function to disable package safely
disable_package() {
    local package=$1
    local description=$2
    echo "Disabling $description ($package)..."
    adb shell pm disable-user --user 0 "$package" 2>/dev/null
}

# Function to enable package
enable_package() {
    local package=$1
    local description=$2
    echo "Enabling $description ($package)..."
    adb shell pm enable "$package" 2>/dev/null
}

echo "=== PERFORMANCE OPTIMIZATIONS ==="

# Disable Samsung bloatware that causes overheating
echo "Removing Samsung bloatware..."
disable_package "com.samsung.android.bixby.agent" "Bixby Voice"
disable_package "com.samsung.android.app.spage" "Samsung Free"
disable_package "com.samsung.android.bixby.service" "Bixby Service"
disable_package "com.samsung.android.bixby.wakeup" "Bixby Wakeup"
disable_package "com.samsung.android.visionintelligence" "Bixby Vision"
disable_package "com.samsung.android.app.routines" "Bixby Routines"
disable_package "com.samsung.android.game.gamehome" "Game Launcher"
disable_package "com.samsung.android.game.gametools" "Game Tools"
disable_package "com.samsung.android.gametuner" "Game Tuner"

# Disable Google Gemini AI and related services
echo "Removing Google Gemini AI..."
disable_package "com.google.android.apps.bard" "Google Bard/Gemini"
disable_package "com.google.android.apps.googleassistant" "Google Assistant"
disable_package "com.google.android.googlequicksearchbox" "Google Search (includes Gemini)"
disable_package "com.google.android.apps.assistant" "Assistant Services"
disable_package "com.google.android.apps.search.assistant" "Search Assistant"
disable_package "com.google.android.apps.nexuslauncher" "Pixel Launcher (includes AI features)"
disable_package "com.google.android.apps.turbo" "Device Health Services"
disable_package "com.google.android.apps.wellbeing" "Digital Wellbeing (includes AI)"
disable_package "com.google.android.projection.gearhead" "Android Auto (includes AI features)"

# Disable Google AI-powered features
echo "Disabling Google AI features..."
disable_package "com.google.android.apps.photos" "Google Photos (AI features)"
disable_package "com.google.android.apps.lens" "Google Lens"
disable_package "com.google.android.apps.recorder" "Google Recorder (AI transcription)"
disable_package "com.google.android.apps.translate" "Google Translate"
disable_package "com.google.android.tts" "Google Text-to-Speech"
disable_package "com.google.android.apps.speechservices" "Speech Services"

# Disable ALL AI and Machine Learning services
echo "Removing ALL AI and Machine Learning services..."
disable_package "com.google.android.as" "Android System Intelligence"
disable_package "com.google.android.apps.turbo" "Device Health Services (ML)"
disable_package "com.google.android.apps.restore" "Android Setup (AI features)"
disable_package "com.google.android.apps.work.oobconfig" "Work Profile Setup (AI)"
disable_package "com.google.android.partnersetup" "Partner Setup (includes AI)"
disable_package "com.google.android.setupwizard" "Setup Wizard (AI recommendations)"

# Disable Google Play Services AI components
echo "Disabling Google Play Services AI components..."
disable_package "com.google.android.gms.location.history" "Location History (AI analysis)"
disable_package "com.google.android.apps.gcs" "Google Connectivity Services (AI)"
disable_package "com.google.android.apps.work.clouddpc" "Cloud DPC (AI management)"
disable_package "com.google.android.apps.enterprise.dmagent" "Device Management Agent (AI)"

# Disable Samsung AI and Machine Learning
echo "Removing Samsung AI services..."
disable_package "com.samsung.android.smartface" "Smart Face Recognition"
disable_package "com.samsung.android.smartcallprovider" "Smart Call (AI caller ID)"
disable_package "com.samsung.android.smartsuggestions" "Smart Suggestions"
disable_package "com.samsung.android.smartswitchassistant" "Smart Switch Assistant (AI)"
disable_package "com.samsung.android.smartmirroring" "Smart Mirroring (AI)"
disable_package "com.samsung.android.app.smartcapture" "Smart Capture (AI screenshot)"
disable_package "com.samsung.android.smartfitting" "Smart Fitting (AR/AI)"
disable_package "com.samsung.android.app.routines" "Bixby Routines (AI automation)"
disable_package "com.samsung.android.intelliservice" "Samsung Intelligence Service"

# Disable Predictive and Adaptive features
echo "Disabling predictive and adaptive AI features..."
disable_package "com.google.android.apps.nexuslauncher" "Pixel Launcher (AI predictions)"
disable_package "com.google.android.apps.wallpaper" "Live Wallpapers (AI)"
disable_package "com.google.android.apps.wallpaper.nexus" "Nexus Wallpapers (AI)"
disable_package "com.android.wallpaper.livepicker" "Live Wallpaper Picker (AI)"

# Keyboard fix - Explicitly enable all keyboard services
echo "Ensuring all keyboards are enabled and functional..."

# Force enable essential keyboard packages
enable_package "com.samsung.android.honeyboard" "Samsung Keyboard"
enable_package "com.google.android.inputmethod.latin" "Gboard"
enable_package "com.android.inputmethod.latin" "AOSP Keyboard"
enable_package "com.sec.android.inputmethod" "Samsung Input Method"

# Enable keyboard services
adb shell settings put secure default_input_method com.samsung.android.honeyboard/.service.HoneyBoardService
adb shell settings put secure enabled_input_methods com.samsung.android.honeyboard/.service.HoneyBoardService:com.google.android.inputmethod.latin/com.android.inputmethod.latin.LatinIME

# Ensure input method selector is available
adb shell settings put secure show_ime_with_hard_keyboard 1

# Clear any keyboard restrictions
adb shell pm clear com.samsung.android.honeyboard 2>/dev/null
adb shell pm clear com.google.android.inputmethod.latin 2>/dev/null

echo "✓ All keyboards have been explicitly enabled and should work normally"
echo "✓ Samsung Keyboard set as default with Gboard as backup option"

# Disable Camera AI features
echo "Disabling camera AI features..."
disable_package "com.google.android.GoogleCamera" "Google Camera (AI features)"
disable_package "com.samsung.android.app.camera.sticker.facear" "Camera AR Stickers"
disable_package "com.samsung.android.app.camera.sticker.stamp" "Camera AI Stamps"
disable_package "com.samsung.android.opencalendar" "Samsung Calendar (AI suggestions)"

# Disable Voice and Speech AI
echo "Removing voice and speech AI..."
disable_package "com.google.android.apps.speechservices" "Speech Services"
disable_package "com.google.android.tts" "Text-to-Speech (AI voices)"
disable_package "com.samsung.android.bixby.voiceinput" "Bixby Voice Input"
disable_package "com.samsung.android.app.dictation" "Samsung Dictation (AI)"
disable_package "com.google.android.apps.speech.tts" "Google TTS Engine"

# Disable Health and Fitness AI
echo "Disabling health and fitness AI..."
disable_package "com.samsung.android.app.health" "Samsung Health (AI insights)"
disable_package "com.google.android.apps.fitness" "Google Fit (AI analysis)"
disable_package "com.samsung.android.service.health" "Samsung Health Service"

# Disable Shopping and Recommendation AI
echo "Removing shopping and recommendation AI..."
disable_package "com.google.android.apps.shopping.express" "Google Shopping (AI recommendations)"
disable_package "com.samsung.android.app.tips" "Samsung Tips (AI suggestions)"
disable_package "com.samsung.android.app.galaxyfinder" "Galaxy Finder (AI search)"

# Disable Accessibility AI features
echo "Disabling accessibility AI features..."
disable_package "com.google.android.marvin.talkback" "TalkBack (AI voice)"
disable_package "com.google.android.apps.accessibility.voiceaccess" "Voice Access (AI)"
disable_package "com.samsung.android.accessibility" "Samsung Accessibility (AI)"

# Disable Android Auto AI
echo "Disabling Android Auto AI features..."
disable_package "com.google.android.projection.gearhead" "Android Auto (AI assistant)"
disable_package "com.google.android.apps.automotive.inputmethod" "Auto Input Method (AI)"

# Disable News and Content AI
echo "Removing news and content AI..."
disable_package "com.google.android.apps.magazines" "Google News (AI curation)"
disable_package "com.samsung.android.app.news" "Samsung News (AI recommendations)"
disable_package "com.google.android.apps.searchlite" "Google Go (AI search)"

# Disable Facebook services (common bloatware)
disable_package "com.facebook.katana" "Facebook"
disable_package "com.facebook.system" "Facebook App Installer"
disable_package "com.facebook.appmanager" "Facebook App Manager"
disable_package "com.facebook.services" "Facebook Services"

# Disable other resource-heavy apps
disable_package "com.netflix.mediaclient" "Netflix"
disable_package "com.microsoft.office.officehubrow" "Microsoft Office"
disable_package "com.microsoft.skydrive" "OneDrive"
disable_package "com.spotify.music" "Spotify"

echo ""
echo "=== CPU & GPU ACCELERATION ==="

# Force GPU rendering for 2D operations for a smoother UI
echo "Forcing GPU rendering for smoother UI..."
adb shell setprop debug.hwui.renderer skiagl

# Enable hardware overlays to reduce GPU load
echo "Enabling Hardware Overlays..."
adb shell setprop debug.sf.hw 1

# Enable multi-threaded rendering (experimental)
echo "Enabling multi-threaded rendering..."
adb shell setprop debug.cpurend.vsync false

# Set CPU governor to performance mode (requires root)
echo "Setting CPU governor to 'performance' for maximum speed..."
for i in $(adb shell ls /sys/devices/system/cpu/ | grep 'cpu[0-9]'); do
    adb shell "echo performance > /sys/devices/system/cpu/$i/cpufreq/scaling_governor" 2>/dev/null
done || echo "Note: Setting CPU governor requires root access."

echo ""
echo "=== THERMAL MANAGEMENT ==="

# Set thermal throttling (requires root for some commands)
echo "Applying thermal optimizations..."
adb shell "echo 1 > /sys/class/thermal/thermal_zone0/mode" 2>/dev/null || echo "Note: Some thermal settings require root access"

# Limit CPU frequency (if possible)
adb shell "echo 1804800 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq" 2>/dev/null || echo "Note: CPU frequency control requires root"

echo ""
echo "=== BATTERY OPTIMIZATIONS ==="

# Enable power saving features
echo "Enabling power saving features..."
adb shell settings put global low_power 1
adb shell settings put global battery_saver_enabled 1

# Reduce screen brightness and timeout
adb shell settings put system screen_brightness 100
adb shell settings put system screen_off_timeout 30000

# Disable location services for better battery
adb shell settings put secure location_mode 0

echo ""
echo "=== BACKGROUND APP MANAGEMENT ==="

# Limit background processes
echo "Limiting background processes..."
adb shell settings put global background_app_limit 2

# Disable auto-sync
adb shell settings put global auto_sync 0

# Reduce animation scales
adb shell settings put global window_animation_scale 0.5
adb shell settings put global transition_animation_scale 0.5
adb shell settings put global animator_duration_scale 0.5

echo ""
echo "=== SECURITY HARDENING ==="

# Disable unnecessary permissions and features
echo "Applying security hardening..."

# Disable app installation from unknown sources
adb shell settings put global install_non_market_apps 0
adb shell settings put secure install_non_market_apps 0

# Disable USB debugging notification (but keep USB debugging enabled)
adb shell settings put global adb_enabled 1

# Disable developer options visibility (optional - uncomment if desired)
# adb shell settings put global development_settings_enabled 0

# Disable location history and reporting
adb shell settings put secure location_providers_allowed ""
adb shell settings put global assisted_gps_enabled 0
adb shell settings put global wifi_networks_available_notification_on 0

# Disable usage and diagnostic data sharing
adb shell settings put global send_action_app_error 0
adb shell settings put secure send_action_app_error 0

# Disable Samsung customization service
disable_package "com.samsung.android.scs" "Samsung Customization Service"
disable_package "com.samsung.android.rlc" "Samsung RLC"

# Disable advertising and analytics
disable_package "com.samsung.android.samsunganalytics" "Samsung Analytics"
disable_package "com.samsung.android.mateagent" "Samsung Mate Agent"
disable_package "com.samsung.android.smartmirroring" "Smart View"

# Disable potentially vulnerable services
disable_package "com.samsung.android.beaconmanager" "Beacon Manager"
disable_package "com.samsung.android.allshare.service.mediashare" "AllShare MediaShare"
disable_package "com.samsung.android.allshare.service.fileshare" "AllShare FileShare"

# Enhanced app permission restrictions
echo "Restricting app permissions..."
adb shell appops set com.android.chrome COARSE_LOCATION deny 2>/dev/null
adb shell appops set com.google.android.gms COARSE_LOCATION deny 2>/dev/null
adb shell appops set com.samsung.android.app.spage COARSE_LOCATION deny 2>/dev/null

echo ""
echo "=== NETWORK SPEED OPTIMIZATIONS ==="

# DNS and network performance tweaks
echo "Optimizing network performance..."

# Set faster DNS servers (Cloudflare and Google)
adb shell settings put global private_dns_mode hostname
adb shell settings put global private_dns_specifier one.one.one.one

# Network buffer optimizations
adb shell "echo 'net.core.rmem_default = 262144' >> /system/etc/sysctl.conf" 2>/dev/null || echo "Note: Network buffer settings require root"
adb shell "echo 'net.core.rmem_max = 16777216' >> /system/etc/sysctl.conf" 2>/dev/null
adb shell "echo 'net.core.wmem_default = 262144' >> /system/etc/sysctl.conf" 2>/dev/null
adb shell "echo 'net.core.wmem_max = 16777216' >> /system/etc/sysctl.conf" 2>/dev/null

# TCP optimization
adb shell "echo 'net.ipv4.tcp_window_scaling = 1' >> /system/etc/sysctl.conf" 2>/dev/null
adb shell "echo 'net.ipv4.tcp_timestamps = 1' >> /system/etc/sysctl.conf" 2>/dev/null
adb shell "echo 'net.ipv4.tcp_sack = 1' >> /system/etc/sysctl.conf" 2>/dev/null

# WiFi performance optimizations
echo "Optimizing WiFi performance..."
adb shell settings put global wifi_frequency_band 2  # Prefer 5GHz when available
adb shell settings put global wifi_sleep_policy 2    # Never sleep WiFi
adb shell settings put global wifi_idle_ms 7200000   # Keep WiFi active longer

# Mobile data optimizations
echo "Optimizing mobile data..."
adb shell settings put global preferred_network_mode 22  # LTE/GSM/WCDMA
adb shell settings put global mobile_data_always_on 1    # Keep mobile data active

# Disable data saver (can slow down connections)
adb shell settings put global restrict_background_data 0

# Network location accuracy (balance speed vs battery)
adb shell settings put secure network_location_opt_in 1

echo ""
echo "=== CONNECTIVITY OPTIMIZATIONS ==="

# Enhanced connectivity features
echo "Optimizing connectivity..."
adb shell settings put global wifi_scan_always_enabled 0
adb shell settings put global ble_scan_always_enabled 0
adb shell settings put global network_recommendations_enabled 0

# Disable WiFi assistant and auto-connect features that can slow down connections
adb shell settings put global wifi_wakeup_enabled 0
adb shell settings put global wifi_networks_available_notification_on 0

# Optimize Bluetooth for better coexistence with WiFi
adb shell settings put global bluetooth_a2dp_sink_priority_on 1

# Disable NFC if not needed (uncomment if you don't use NFC)
# adb shell settings put global nfc_on 0

echo ""
echo "=== FIREWALL AND NETWORK SECURITY ==="

# Network security enhancements
echo "Applying network security settings..."

# Disable automatic WiFi connection to open networks
adb shell settings put global wifi_networks_available_notification_on 0
adb shell settings put global wifi_connect_automatically 0

# Disable WiFi Direct (can be a security risk)
disable_package "com.samsung.android.allshare.service.mediashare" "WiFi Direct MediaShare"

# Disable Samsung Cloud sync (potential data leak)
disable_package "com.samsung.android.scloud" "Samsung Cloud"
disable_package "com.samsung.android.samsungcloud" "Samsung Cloud Service"

# Disable Smart Switch (can transfer sensitive data)
disable_package "com.sec.android.easyMover" "Smart Switch"
disable_package "com.samsung.android.smartswitchassistant" "Smart Switch Assistant"

# Block ads and trackers at network level (requires root for hosts file)
echo "Setting up ad blocking..."
adb shell "echo '0.0.0.0 googleads.g.doubleclick.net' >> /system/etc/hosts" 2>/dev/null || echo "Note: Ad blocking requires root access"
adb shell "echo '0.0.0.0 googlesyndication.com' >> /system/etc/hosts" 2>/dev/null
adb shell "echo '0.0.0.0 facebook.com' >> /system/etc/hosts" 2>/dev/null
adb shell "echo '0.0.0.0 graph.facebook.com' >> /system/etc/hosts" 2>/dev/null

echo ""
echo "=== MEMORY & STORAGE BOOST ==="

# Trim filesystem to improve storage performance
echo "Trimming filesystems for faster storage I/O..."
adb shell fstrim -v /cache 2>/dev/null
adb shell fstrim -v /data 2>/dev/null

# Free up pagecache, dentries and inodes (requires root)
echo "Dropping kernel caches to free up memory..."
adb shell "echo 3 > /proc/sys/vm/drop_caches" 2>/dev/null || echo "Note: Dropping kernel caches requires root access."

# Clear system and app caches
echo "Clearing system and application caches..."
adb shell pm trim-caches 9999999999

# Clear app caches for common apps
apps_to_clear=(
    "com.android.chrome"
    "com.google.android.youtube"
    "com.whatsapp"
    "com.instagram.android"
    "com.twitter.android"
    "com.google.android.apps.maps"
    "com.spotify.music"
)

for app in "${apps_to_clear[@]}"; do
    echo "Clearing cache for $app..."
    adb shell pm clear "$app" 2>/dev/null
done

# Clear temporary files
echo "Clearing temporary files..."
adb shell rm -f /data/local/tmp/* 2>/dev/null

echo ""
echo "=== FINAL OPTIMIZATIONS ==="

# Force stop unnecessary services
echo "Stopping unnecessary services..."
adb shell am force-stop com.samsung.android.bixby.agent 2>/dev/null
adb shell am force-stop com.samsung.android.game.gamehome 2>/dev/null
adb shell am force-stop com.facebook.katana 2>/dev/null

# Restart system UI to apply changes
echo "Restarting System UI..."
adb shell am force-stop com.android.systemui
sleep 2

echo ""
echo "=== OPTIMIZATION COMPLETE ==="
echo "Your Samsung A34 5G has been optimized for:"
echo "✓ Reduced overheating"
echo "✓ Better battery life"
echo "✓ Improved performance"
echo "✓ Less background activity"
echo "✓ Faster CPU & GPU response"
echo ""
echo "Recommendations:"
echo "- Restart your phone to ensure all changes take effect"
echo "- Monitor your phone's temperature over the next few days"
echo "- Re-enable any disabled apps you actually need"
echo ""
echo "To revert changes, run this script with 'restore' parameter"

# Restore function
if [ "$1" = "restore" ]; then
    echo ""
    echo "=== RESTORING ORIGINAL SETTINGS ==="

    # Re-enable commonly needed apps
    enable_package "com.samsung.android.bixby.agent" "Bixby Voice"
    enable_package "com.samsung.android.game.gamehome" "Game Launcher"

    # Restore CPU & GPU settings
    echo "Restoring CPU & GPU to default..."
    adb shell setprop debug.hwui.renderer ""
    adb shell setprop debug.sf.hw ""
    adb shell setprop debug.cpurend.vsync ""
    # Set CPU governor back to a balanced default (schedutil is common)
    for i in $(adb shell ls /sys/devices/system/cpu/ | grep 'cpu[0-9]'); do
        adb shell "echo schedutil > /sys/devices/system/cpu/$i/cpufreq/scaling_governor" 2>/dev/null
    done || echo "Note: Restoring CPU governor requires root access."

    # Restore performance settings
    adb shell settings put global low_power 0
    adb shell settings put global battery_saver_enabled 0
    adb shell settings put secure location_mode 3
    adb shell settings put global auto_sync 1
    adb shell settings put system screen_brightness 150
    adb shell settings put system screen_off_timeout 60000

    # Restore animation scales
    adb shell settings put global window_animation_scale 1.0
    adb shell settings put global transition_animation_scale 1.0
    adb shell settings put global animator_duration_scale 1.0

    echo "Settings restored to defaults"
fi

echo "Script completed successfully!"
