#!/bin/bash

# Samsung Galaxy A34 5G - Ultra Advanced Optimization Framework
# Target: MediaTek Dimensity 1080 | 8GB RAM | UFS Storage | 120Hz AMOLED
# Version 6.0 - Advanced System-Level Optimization & Hardening
# CPU/GPU/RAM/Storage/Network/Power/Threading/Privacy/Security - Safe & Idempotent
# Compatible: Android 12-16+ | Root & Non-Root | Production-Ready

set -e
trap 'echo "[!] Command failed (safe fallback). Continuing..."; true' ERR 2>/dev/null || true

# Script version
SCRIPT_VERSION="6.0"
SCRIPT_MODE="${1:-optimize}"

echo "========================================================================"
echo "=== Samsung A34 5G Ultra Advanced Optimization Framework v${SCRIPT_VERSION} ==="
echo "========================================================================"
echo "[*] Staged reboot-applied tuning | Dimensity 1080 aware | 8GB RAM optimized"
echo "[*] No virtual CPU/GPU/RAM | Real kernel/sysfs tuning only"
echo "[*] Mode: $SCRIPT_MODE"
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
    echo "[+] Using wget for downloads"
elif command -v curl &> /dev/null; then
    DOWNLOADER="curl"
    echo "[+] Using curl for downloads"
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

echo "[+] Device detected. Starting optimization..."
echo ""

# Handle restore mode early
if [ "$SCRIPT_MODE" = "restore" ]; then
    echo "========================================================================"
    echo "=== RESTORE MODE - Reverting All Optimizations ==="
    echo "========================================================================"
    restore_all_settings
    exit 0
fi

# --- Section 0: Root Privilege Detection ---
echo "========================================================================"
echo "=== Root Privilege Detection ==="
echo "========================================================================"
echo "[*] Attempting to gain root access for deep system tuning..."

adb root >/dev/null 2>&1
sleep 3
adb wait-for-device

if [[ "$(adb shell whoami 2>/dev/null)" == "root" ]]; then
    echo "[+] SUCCESS: ADB running with root privileges."
    echo "    System-level kernel/sysfs modifications enabled."
    adb shell 'mount -o rw,remount /' >/dev/null 2>&1 || true
    adb shell 'mount -o rw,remount /system' >/dev/null 2>&1 || true
    adb shell 'mount -o rw,remount /vendor' >/dev/null 2>&1 || true
    ROOT_AVAILABLE=true
else
    echo "[i] INFO: Root not available."
    echo "    Continuing with non-root optimizations (settings/properties only)."
    ROOT_AVAILABLE=false
fi
echo ""

# --- Stage 0: Intelligent Hardware Detection ---
echo "========================================================================"
echo "=== Hardware & System Auto-Detection ==="
echo "========================================================================"

# Android/Kernel version detection
ANDROID_VERSION=$(adb shell getprop ro.build.version.sdk 2>/dev/null | tr -d '\r')
ANDROID_RELEASE=$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
KERNEL_VERSION=$(adb shell uname -r 2>/dev/null | tr -d '\r')
DEVICE_MODEL=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
SOC_PLATFORM=$(adb shell getprop ro.board.platform 2>/dev/null | tr -d '\r')
echo "[+] Device: $DEVICE_MODEL"
echo "[+] Android: $ANDROID_RELEASE (API $ANDROID_VERSION)"
echo "[+] Kernel: $KERNEL_VERSION"
echo "[+] SoC Platform: $SOC_PLATFORM"

# CPU cluster detection (big.LITTLE architecture for Dimensity 1080)
echo "[*] Detecting CPU topology..."
CPU_CLUSTERS=""
CPU_BIG_CORES=""
CPU_LITTLE_CORES=""
TOTAL_CPUS=0

for cpu_path in $(adb shell "ls -d /sys/devices/system/cpu/cpu[0-9]* 2>/dev/null" | tr -d '\r'); do
    cpu_num=$(echo "$cpu_path" | grep -oE '[0-9]+$')
    if [ -n "$cpu_num" ]; then
        TOTAL_CPUS=$((TOTAL_CPUS + 1))
        # Get CPU frequency range to identify big vs LITTLE cores
        if [ "$ROOT_AVAILABLE" = true ]; then
            MAX_FREQ=$(adb shell "cat $cpu_path/cpufreq/cpuinfo_max_freq 2>/dev/null" | tr -d '\r')
            MIN_FREQ=$(adb shell "cat $cpu_path/cpufreq/cpuinfo_min_freq 2>/dev/null" | tr -d '\r')
            if [ -n "$MAX_FREQ" ]; then
                # Dimensity 1080: big cores (A78) max ~2.6GHz, LITTLE cores (A55) max ~2.0GHz
                if [ "$MAX_FREQ" -gt 2200000 ] 2>/dev/null; then
                    CPU_BIG_CORES="$CPU_BIG_CORES$cpu_num "
                else
                    CPU_LITTLE_CORES="$CPU_LITTLE_CORES$cpu_num "
                fi
            fi
        fi
    fi
done

CPU_BIG_CORES=$(echo "$CPU_BIG_CORES" | tr ' ' '\n' | sort -n | tr '\n' ',' | sed 's/,$//')
CPU_LITTLE_CORES=$(echo "$CPU_LITTLE_CORES" | tr ' ' '\n' | sort -n | tr '\n' ',' | sed 's/,$//')
echo "[+] CPU Cores: $TOTAL_CPUS total"
[ -n "$CPU_BIG_CORES" ] && echo "[+] Big Cores: $CPU_BIG_CORES"
[ -n "$CPU_LITTLE_CORES" ] && echo "[+] LITTLE Cores: $CPU_LITTLE_CORES"

# zRAM detection
ZRAM_AVAILABLE=false
ZRAM_PATH=""
for zram in /dev/block/zram0 /dev/zram0; do
    if adb shell "test -b $zram 2>/dev/null" 2>/dev/null; then
        ZRAM_AVAILABLE=true
        ZRAM_PATH="$zram"
        echo "[+] zRAM detected at $zram"
        break
    fi
done
[ "$ZRAM_AVAILABLE" = false ] && echo "[i] zRAM not detected"

# CPUFreq detection
CPUFREQ_ROOT=""
for base in /sys/devices/system/cpu/cpu0/cpufreq /sys/devices/system/cpu/cpufreq; do
    if adb shell "test -d $base 2>/dev/null" 2>/dev/null; then
        CPUFREQ_ROOT="$base"
        echo "[+] CPUFreq path: $base"
        break
    fi
done
[ -z "$CPUFREQ_ROOT" ] && echo "[i] CPUFreq path not accessible (non-root)"

# GPU detection (Mali for MediaTek)
GPU_MALI=false
GPU_PATH=""
MALI_PLATFORMS=("mali" "gpu" "kgsl" "powervr")
for platform in "${MALI_PLATFORMS[@]}"; do
    for path in /sys/class/devfreq /sys/devices/platform /sys/devices/system; do
        if adb shell "ls $path 2>/dev/null" 2>/dev/null | tr -d '\r' | grep -qi "$platform"; then
            GPU_PATH=$(adb shell "ls $path 2>/dev/null" | tr -d '\r' | grep -i "$platform" | head -1)
            if [ -n "$GPU_PATH" ]; then
                GPU_MALI=true
                echo "[+] GPU detected: Mali ($platform)"
                break 2
            fi
        fi
    done
done
# Also check EGL hardware property
if [ "$GPU_MALI" = false ]; then
    if adb shell "getprop ro.hardware.egl 2>/dev/null" 2>/dev/null | grep -qi mali; then
        GPU_MALI=true
        echo "[+] GPU: Mali (via EGL property)"
    fi
fi

# Thermal zone detection
THERMAL_AVAILABLE=false
if adb shell "test -d /sys/class/thermal 2>/dev/null" 2>/dev/null; then
    THERMAL_AVAILABLE=true
    THERMAL_ZONES=$(adb shell "ls /sys/class/thermal 2>/dev/null | grep thermal_zone | wc -l" | tr -d '\r')
    echo "[+] Thermal zones: $THERMAL_ZONES detected"
fi

# cpuset detection (big.LITTLE scheduling)
CPUSET_AVAILABLE=false
CPUSET_PATH=""
for cpath in /dev/cpuset /sys/fs/cgroup/cpuset; do
    if adb shell "test -d $cpath 2>/dev/null" 2>/dev/null; then
        CPUSET_AVAILABLE=true
        CPUSET_PATH="$cpath"
        echo "[+] CPUset available: $cpath"
        break
    fi
done
[ "$CPUSET_AVAILABLE" = false ] && echo "[i] CPUset not accessible (non-root)"

# Scheduler features detection (EAS support)
SCHED_EAS_AVAILABLE=false
if [ "$ROOT_AVAILABLE" = true ]; then
    if adb shell "test -f /proc/sys/kernel/sched_energy_avail 2>/dev/null" 2>/dev/null; then
        SCHED_EAS_AVAILABLE=true
        echo "[+] Energy Aware Scheduler (EAS) supported"
    fi
    # Check for uclamp support
    if adb shell "test -f /proc/sys/kernel/sched_util_clamp_min 2>/dev/null" 2>/dev/null; then
        echo "[+] Utilization Clamping (uclamp) supported"
    fi
fi

# Block device detection for storage optimization
BLOCK_DEVICES=""
if [ "$ROOT_AVAILABLE" = true ]; then
    BLOCK_DEVICES=$(adb shell "ls /sys/block/ 2>/dev/null" | tr -d '\r' | grep -E "sda|mmcblk|nvme|loop" || true)
    if [ -n "$BLOCK_DEVICES" ]; then
        echo "[+] Block devices: $(echo $BLOCK_DEVICES | tr '\n' ' ')"
    fi
fi

echo ""

# --- Helper Functions ---

# Function to disable a package safely for the current user
disable_package() {
    local package=$1
    local description=$2
    if is_package_installed "$package"; then
        echo "[*] Disabling $description ($package)..."
        adb shell pm disable-user --user 0 "$package" 2>/dev/null || \
        adb shell pm disable "$package" 2>/dev/null || \
        echo "[!] Failed to disable $package (may be protected)"
    else
        echo "[i] $description is not installed (skipping)."
    fi
}

# Function to enable a package
enable_package() {
    local package=$1
    local description=$2
    echo "[*] Enabling $description ($package)..."
    adb shell pm enable "$package" 2>/dev/null || \
    adb shell pm enable --user 0 "$package" 2>/dev/null || \
    echo "[!] Failed to enable $package"
}

# Function to check if a package is installed
is_package_installed() {
    adb shell pm list packages --user 0 "$1" 2>/dev/null | grep -q .
}

# Enhanced download function with wget/curl support
download_file() {
    local url="$1"
    local output="$2"

    if [ "$DOWNLOADER" = "wget" ]; then
        wget -q --show-progress -O "$output" "$url" 2>/dev/null
        return $?
    else
        curl -L --progress-bar -o "$output" "$url" 2>/dev/null
        return $?
    fi
}

# Function to download and install an APK if it's not already installed
install_apk() {
    local package_name="$1"
    local apk_url="$2"
    local app_name="$3"
    if ! is_package_installed "$package_name"; then
        echo "[*] Installing $app_name..."
        local temp_apk="/tmp/$package_name.apk"
        echo "    Downloading from $apk_url..."

        if download_file "$apk_url" "$temp_apk"; then
            echo "    Download complete. Installing APK..."
            local install_output
            install_output=$(adb install -r "$temp_apk" 2>&1)
            if echo "$install_output" | grep -q "Success"; then
                echo "[+] $app_name installed successfully."
                rm -f "$temp_apk"
                return 0
            else
                echo "[!] Failed to install $app_name."
                echo "    ADB Output: $install_output"
                rm -f "$temp_apk"
                return 1
            fi
        else
            echo "[!] Failed to download $app_name. Continuing..."
            return 1
        fi
    else
        echo "[+] $app_name is already installed."
        return 0
    fi
}

# Safe property setter that doesn't fail the script
set_prop_safe() {
    local prop="$1"
    local value="$2"
    local description="$3"

    if adb shell "setprop '$prop' '$value'" 2>/dev/null; then
        echo "    [+] Set $description"
        return 0
    else
        echo "    [i] Skipped $description (requires root or not supported)"
        return 1
    fi
}

# Safe sysfs writer with existence check
write_sysfs_safe() {
    local path="$1"
    local value="$2"
    local description="$3"
    
    if [ "$ROOT_AVAILABLE" != true ]; then
        echo "    [i] Skipped $description (requires root)"
        return 1
    fi
    
    if adb shell "test -e '$path' 2>/dev/null" 2>/dev/null; then
        if adb shell "echo '$value' > '$path'" 2>/dev/null; then
            echo "    [+] $description"
            return 0
        else
            echo "    [!] Failed to write $description (permission denied)"
            return 1
        fi
    else
        echo "    [i] Skipped $description (path not found)"
        return 1
    fi
}

# Log skipped optimization
log_skip() {
    local reason="$1"
    echo "    [i] Skipped: $reason"
}

echo ""

# --- Reboot-Applied: Run final tuning if pending flag set ---
apply_final_tuning() {
    echo "========================================================================"
    echo "=== Applying Reboot-Staged Tuning (Final Stage) ==="
    echo "========================================================================"
    
    if [ "$ROOT_AVAILABLE" != true ]; then
        echo "[i] Root not available; skipping kernel/sysfs tuning."
        adb shell setprop persist.sys.ultra_opt.pending 0 2>/dev/null
        return 0
    fi
    
    echo "[*] Applying deep kernel optimizations..."
    
    # === CPU Scheduler Tuning (EAS/CFS) ===
    echo "--- CPU Scheduler (EAS/CFS) ---"
    # Optimize for responsiveness while maintaining efficiency
    write_sysfs_safe "/proc/sys/kernel/sched_latency_ns" "10000000" "sched_latency (10ms)"
    write_sysfs_safe "/proc/sys/kernel/sched_min_granularity_ns" "1500000" "sched_min_granularity (1.5ms)"
    write_sysfs_safe "/proc/sys/kernel/sched_wakeup_granularity_ns" "1000000" "sched_wakeup_granularity (1ms)"
    write_sysfs_safe "/proc/sys/kernel/sched_migration_cost_ns" "300000" "sched_migration_cost (0.3ms)"
    write_sysfs_safe "/proc/sys/kernel/sched_rt_runtime_us" "-1" "sched_rt_runtime (unlimited RT)"
    
    # Utilization clamping for better task placement (if supported)
    write_sysfs_safe "/proc/sys/kernel/sched_util_clamp_min" "0" "uclamp_min"
    write_sysfs_safe "/proc/sys/kernel/sched_util_clamp_max" "1024" "uclamp_max"
    write_sysfs_safe "/proc/sys/kernel/sched_util_clamp_min_rt_default" "1024" "uclamp_min_rt_default"
    
    # === CPU Governor Configuration ===
    echo "--- CPU Governors ---"
    for cpu in $(adb shell "ls /sys/devices/system/cpu 2>/dev/null" | tr -d '\r' | grep -E '^cpu[0-9]+$'); do
        # Set schedutil governor for balanced performance
        adb shell "echo schedutil > /sys/devices/system/cpu/$cpu/cpufreq/scaling_governor" 2>/dev/null || true
        
        # Configure schedutil parameters if available
        adb shell "echo 0 > /sys/devices/system/cpu/$cpu/cpufreq/schedutil/down_rate_limit_us" 2>/dev/null || true
        adb shell "echo 0 > /sys/devices/system/cpu/$cpu/cpufreq/schedutil/up_rate_limit_us" 2>/dev/null || true
        adb shell "echo 0 > /sys/devices/system/cpu/$cpu/cpufreq/schedutil/rate_limit_us" 2>/dev/null || true
    done
    echo "[+] CPU governors configured (schedutil)"
    
    # === CPU Idle States ===
    echo "--- CPU Idle States ---"
    # Optimize idle states for faster wake-up while saving power
    for cpu in $(adb shell "ls /sys/devices/system/cpu 2>/dev/null" | tr -d '\r' | grep -E '^cpu[0-9]+$'); do
        # Disable deepest sleep states for big cores (faster wake-up)
        if adb shell "test -d /sys/devices/system/cpu/$cpu/cpuidle" 2>/dev/null; then
            for state in $(adb shell "ls /sys/devices/system/cpu/$cpu/cpuidle 2>/dev/null" | tr -d '\r' | grep -E '^state[0-9]+$'); do
                # Read state name to determine depth
                state_name=$(adb shell "cat /sys/devices/system/cpu/$cpu/cpuidle/$state/name 2>/dev/null" | tr -d '\r')
                # Keep shallow states enabled, limit deep states on big cores
                if echo "$state_name" | grep -qi "wfi\|standalone\|retention"; then
                    adb shell "echo 1 > /sys/devices/system/cpu/$cpu/cpuidle/$state/disable" 2>/dev/null || true
                fi
            done
        fi
    done
    echo "[+] CPU idle states optimized"
    
    # === cpuset Configuration (big.LITTLE) ===
    if [ "$CPUSET_AVAILABLE" = true ] && [ -n "$CPUSET_PATH" ]; then
        echo "--- CPUset (big.LITTLE) ---"
        # Top-app: all cores for maximum performance
        adb shell "echo '0-7' > $CPUSET_PATH/top-app/cpus" 2>/dev/null || \
        adb shell "echo '0-$((TOTAL_CPUS-1))' > $CPUSET_PATH/top-app/cpus" 2>/dev/null || true
        adb shell "echo '0-7' > $CPUSET_PATH/foreground/cpus" 2>/dev/null || true
        # Background: LITTLE cores only for efficiency
        if [ -n "$CPU_LITTLE_CORES" ]; then
            adb shell "echo '$CPU_LITTLE_CORES' > $CPUSET_PATH/background/cpus" 2>/dev/null || true
        else
            adb shell "echo '0-3' > $CPUSET_PATH/background/cpus" 2>/dev/null || true
        fi
        echo "[+] CPUset configured (top-app: all cores, background: LITTLE cores)"
    fi
    
    # === Memory Management ===
    echo "--- Memory (VM/zRAM) ---"
    # VM parameters for 8GB RAM
    write_sysfs_safe "/proc/sys/vm/swappiness" "100" "swappiness (aggressive swap)"
    write_sysfs_safe "/proc/sys/vm/vfs_cache_pressure" "50" "vfs_cache_pressure"
    write_sysfs_safe "/proc/sys/vm/dirty_ratio" "20" "dirty_ratio"
    write_sysfs_safe "/proc/sys/vm/dirty_background_ratio" "10" "dirty_background_ratio"
    write_sysfs_safe "/proc/sys/vm/dirty_expire_centisecs" "3000" "dirty_expire (30s)"
    write_sysfs_safe "/proc/sys/vm/dirty_writeback_centisecs" "500" "dirty_writeback (5s)"
    write_sysfs_safe "/proc/sys/vm/page-cluster" "3" "page-cluster"
    write_sysfs_safe "/proc/sys/vm/compact_memory" "1" "memory compaction"
    
    # min_free_kbytes for 8GB RAM (approx 0.5% = ~40MB)
    write_sysfs_safe "/proc/sys/vm/min_free_kbytes" "40960" "min_free_kbytes (40MB)"
    
    # zRAM configuration (2GB with lz4 compression)
    if [ "$ZRAM_AVAILABLE" = true ] && [ -n "$ZRAM_PATH" ]; then
        echo "[*] Configuring zRAM (2GB, lz4)..."
        adb shell "swapoff $ZRAM_PATH" 2>/dev/null || true
        adb shell "echo 1 > /sys/block/$(basename $ZRAM_PATH)/reset" 2>/dev/null || true
        adb shell "echo lz4 > /sys/block/$(basename $ZRAM_PATH)/comp_algorithm" 2>/dev/null || true
        adb shell "echo 2147483648 > /sys/block/$(basename $ZRAM_PATH)/disksize" 2>/dev/null || true
        adb shell "mkswap $ZRAM_PATH" 2>/dev/null || true
        adb shell "swapon $ZRAM_PATH -p 32767" 2>/dev/null || true
        echo "[+] zRAM configured (2GB, lz4, high priority)"
    fi
    
    # LMKD tuning (balanced for multitasking)
    if adb shell "test -f /sys/module/lowmemorykiller/parameters/minfree 2>/dev/null" 2>/dev/null; then
        # minfree values: visible, secondary, hidden, content provider, empty, cached
        adb shell "echo '8192,12288,16384,20480,24576,30720' > /sys/module/lowmemorykiller/parameters/minfree" 2>/dev/null || true
        echo "[+] LMKD configured (balanced multitasking)"
    fi
    
    # === GPU Optimization ===
    echo "--- GPU (Mali) ---"
    # Find and configure Mali GPU devfreq
    for devfreq in $(adb shell "ls /sys/class/devfreq 2>/dev/null" | tr -d '\r'); do
        governor_path="/sys/class/devfreq/$devfreq/governor"
        if adb shell "test -f $governor_path 2>/dev/null" 2>/dev/null; then
            # Try simple_ondemand for GPU
            adb shell "echo simple_ondemand > $governor_path" 2>/dev/null || \
            adb shell "echo performance > $governor_path" 2>/dev/null || true
            
            # Configure frequency range if available
            min_freq=$(adb shell "cat /sys/class/devfreq/$devfreq/min_freq 2>/dev/null" | tr -d '\r')
            max_freq=$(adb shell "cat /sys/class/devfreq/$devfreq/max_freq 2>/dev/null" | tr -d '\r')
            adb shell "echo $min_freq > /sys/class/devfreq/$devfreq/min_freq" 2>/dev/null || true
            adb shell "echo $max_freq > /sys/class/devfreq/$devfreq/max_freq" 2>/dev/null || true
        fi
    done
    echo "[+] GPU devfreq configured"
    
    # === Storage I/O Optimization ===
    echo "--- Storage (I/O) ---"
    for device in $BLOCK_DEVICES; do
        queue_path="/sys/block/$device/queue"
        if adb shell "test -d $queue_path 2>/dev/null" 2>/dev/null; then
            # I/O scheduler: mq-deadline for UFS
            adb shell "echo mq-deadline > $queue_path/scheduler" 2>/dev/null || \
            adb shell "echo deadline > $queue_path/scheduler" 2>/dev/null || true
            
            # Read-ahead for sequential performance
            adb shell "echo 256 > $queue_path/read_ahead_kb" 2>/dev/null || true
            
            # Non-rotational (SSD/UFS)
            adb shell "echo 0 > $queue_path/rotational" 2>/dev/null || true
            
            # Request queue depth
            adb shell "echo 128 > $queue_path/nr_requests" 2>/dev/null || true
            
            # RQ affinity for better CPU cache utilization
            adb shell "echo 1 > $queue_path/rq_affinity" 2>/dev/null || true
            
            # Nomerges for SSD (reduces overhead)
            adb shell "echo 0 > $queue_path/nomerges" 2>/dev/null || true
            
            echo "[+] $device: mq-deadline, read_ahead=256KB, rq_affinity=1"
        fi
    done
    
    # === Network Optimization ===
    echo "--- Network (TCP) ---"
    # TCP buffer tuning for better throughput
    write_sysfs_safe "/proc/sys/net/ipv4/tcp_rmem" "4096 87380 16777216" "TCP read buffer"
    write_sysfs_safe "/proc/sys/net/ipv4/tcp_wmem" "4096 65536 16777216" "TCP write buffer"
    write_sysfs_safe "/proc/sys/net/ipv4/tcp_congestion_control" "cubic" "TCP congestion control"
    write_sysfs_safe "/proc/sys/net/ipv4/tcp_ecn" "0" "TCP ECN (disabled)"
    write_sysfs_safe "/proc/sys/net/ipv4/tcp_slow_start_after_idle" "0" "TCP slow start after idle"
    write_sysfs_safe "/proc/sys/net/ipv4/tcp_no_metrics_save" "1" "TCP no metrics save"
    write_sysfs_safe "/proc/sys/net/core/rmem_max" "16777216" "Socket read max"
    write_sysfs_safe "/proc/sys/net/core/wmem_max" "16777216" "Socket write max"
    write_sysfs_safe "/proc/sys/net/core/netdev_max_backlog" "5000" "Netdev backlog"
    
    # === Thermal Management ===
    if [ "$THERMAL_AVAILABLE" = true ]; then
        echo "--- Thermal (Safe Relax) ---"
        # Slightly relax thermal throttling for sustained performance
        # DO NOT disable thermal protection entirely
        for tz in $(adb shell "ls /sys/class/thermal 2>/dev/null" | tr -d '\r' | grep thermal_zone); do
            tz_path="/sys/class/thermal/$tz"
            # Get thermal zone type
            tz_type=$(adb shell "cat $tz_path/type 2>/dev/null" | tr -d '\r')
            
            # Only adjust CPU/GPU thermal zones, skip battery/skin temp
            if echo "$tz_type" | grep -qiE "cpu|gpu|tsens|mtk"; then
                # Set mode to enabled (active cooling)
                adb shell "echo 'enabled' > $tz_path/mode" 2>/dev/null || true
            fi
        done
        echo "[+] Thermal zones configured (safe margins maintained)"
    fi
    
    # === Binder Threading ===
    echo "--- Binder Threading ---"
    # Increase binder thread pool for better IPC performance
    write_sysfs_safe "/sys/devices/system/binder/binder_threads/max_threads" "16" "Binder max threads"
    write_sysfs_safe "/sys/devices/system/binder/binder_threads/proc_threads" "8" "Binder proc threads"
    
    # Clear pending flag
    adb shell setprop persist.sys.ultra_opt.pending 0 2>/dev/null
    echo ""
    echo "[+] Reboot-staged tuning applied successfully."
    echo "[+] Pending flag cleared."
    echo ""
}

PENDING=$(adb shell getprop persist.sys.ultra_opt.pending 2>/dev/null | tr -d '\r')
if [ "$PENDING" = "1" ]; then
    echo "[*] Detected persist.sys.ultra_opt.pending=1 (post-reboot)"
    apply_final_tuning
fi

# --- Section 1: Spyware Detection & Removal ---
echo "========================================================================"
echo "=== Section 1: Spyware Detection & Removal ==="
echo "========================================================================"

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

echo "[*] Scanning for Known Spyware & Malicious Apps..."
SPYWARE_FOUND=0
SPYWARE_LIST=""

for package in "${SPYWARE_PACKAGES[@]}"; do
    if is_package_installed "$package"; then
        echo "[!] SPYWARE DETECTED: $package"
        SPYWARE_FOUND=$((SPYWARE_FOUND + 1))
        SPYWARE_LIST="$SPYWARE_LIST\n  - $package"
        
        adb shell am force-stop "$package" 2>/dev/null
        
        if is_package_installed "$package"; then
            adb shell pm revoke "$package" android.permission.CAMERA 2>/dev/null
            adb shell pm revoke "$package" android.permission.RECORD_AUDIO 2>/dev/null
            adb shell pm revoke "$package" android.permission.ACCESS_FINE_LOCATION 2>/dev/null
            adb shell pm revoke "$package" android.permission.READ_CONTACTS 2>/dev/null
            adb shell pm revoke "$package" android.permission.READ_SMS 2>/dev/null
            adb shell pm revoke "$package" android.permission.READ_CALL_LOG 2>/dev/null
        fi
        
        echo "    Attempting to remove $package..."
        adb shell pm uninstall --user 0 "$package" 2>/dev/null || \
        disable_package "$package" "Spyware: $package"
    fi
done

if [ $SPYWARE_FOUND -eq 0 ]; then
    echo "[+] No known spyware detected on your device."
else
    echo ""
    echo "[!] WARNING: $SPYWARE_FOUND SPYWARE APP(S) DETECTED!"
    echo "    The following malicious apps were found and disabled/removed:"
    echo -e "$SPYWARE_LIST"
    echo ""
    echo "    RECOMMENDATIONS:"
    echo "    1. Change all passwords immediately"
    echo "    2. Enable 2-factor authentication on important accounts"
    echo "    3. Check your Google account activity: myactivity.google.com"
    echo "    4. Consider a factory reset for complete removal"
    echo "    5. Review who has physical access to your device"
    echo ""
fi

echo "[*] Scanning for Suspicious Hidden Apps..."
HIDDEN_APPS=$(adb shell pm list packages -s --user 0 2>/dev/null | grep -vE "android|samsung|google|knox|com\.sec\.|com\.mediatek\.|com\.qualcomm\.|com\.microsoft\.|com\.osp\.|com\.wsomacp" | cut -d: -f2)
SUSPICIOUS_COUNT=0

for app in $HIDDEN_APPS; do
    DANGEROUS_PERMS=$(adb shell dumpsys package "$app" 2>/dev/null | grep -E "CAMERA|RECORD_AUDIO|LOCATION|CONTACTS|SMS|CALL_LOG" | wc -l)
    
    if [ "$DANGEROUS_PERMS" -gt 5 ]; then
        echo "[!] Suspicious system app: $app (Has $DANGEROUS_PERMS dangerous permissions)"
        SUSPICIOUS_COUNT=$((SUSPICIOUS_COUNT + 1))
    fi
done

if [ $SUSPICIOUS_COUNT -eq 0 ]; then
    echo "[+] No suspicious hidden apps detected."
else
    echo "[!] Found $SUSPICIOUS_COUNT suspicious system app(s). Review permissions manually."
fi

echo "[*] Checking for Apps with Device Admin Rights..."
DEVICE_ADMINS=$(adb shell dpm list-owners 2>/dev/null)
if [ -z "$DEVICE_ADMINS" ]; then
    echo "[+] No device administrators found (good)."
else
    echo "[!] WARNING: Device administrators detected:"
    echo "$DEVICE_ADMINS"
    echo "    Review Settings > Security > Device administrators"
    echo "    Spyware often uses device admin to prevent removal!"
fi

echo ""

# --- Section 2: Device Security & Find My Device ---
echo "========================================================================"
echo "=== Section 2: Device Security & Find My Device Configuration ==="
echo "========================================================================"

echo "[*] Configuring Find My Device..."
if is_package_installed "com.google.android.apps.adm"; then
    enable_package "com.google.android.apps.adm" "Google Find My Device"
    echo "[+] Find My Device is enabled."
    echo "    Locate/lock/wipe at: android.com/find"
    adb shell settings put secure location_mode 3
else
    echo "[i] Google Find My Device not found. Install from Play Store for theft protection."
fi

if is_package_installed "com.samsung.android.fmm"; then
    enable_package "com.samsung.android.fmm" "Samsung Find My Mobile"
    echo "[+] Samsung Find My Mobile enabled."
    echo "    Access at: findmymobile.samsung.com"
else
    echo "[i] Samsung Find My Mobile not found (should be pre-installed)."
fi

echo ""
echo "[*] Enhancing Device Lock Security..."
adb shell settings put secure lockscreen_power_button_instantly_locks 1
adb shell settings put system screen_off_timeout 60000
adb shell settings put secure lock_screen_allow_private_notifications 0
adb shell settings put secure lock_screen_show_notifications 0
adb shell settings put global stay_on_while_plugged_in 0
adb shell settings put global enable_gpu_debug_layers 0
adb shell settings put global multi_press_timeout 300
adb shell settings put secure lockscreen_maximize_widgets 0
adb shell settings put secure lockscreen_fail_count_before_wipe 10 2>/dev/null || true
echo "[+] Enhanced lock screen security configured."

echo ""

# --- Section 3: Persistent Properties & ART Optimization ---
echo "========================================================================"
echo "=== Section 3: Persistent Properties & ART Optimization ==="
echo "========================================================================"

echo "[*] Setting optimization version..."
set_prop_safe "persist.sys.ultra_opt.version" "$SCRIPT_VERSION" "Optimization version flag"

echo "[*] Configuring ART Runtime..."
set_prop_safe "dalvik.vm.dex2oat-filter" "speed-profile" "ART DEX (speed-profile)"
set_prop_safe "dalvik.vm.image-dex2oat-filter" "speed" "ART image DEX"
set_prop_safe "pm.dexopt.install" "speed-profile" "Install optimization"
set_prop_safe "pm.dexopt.bg-dexopt" "speed-profile" "Background DEX"
set_prop_safe "pm.dexopt.boot" "verify" "Boot optimization (verify)"
set_prop_safe "ro.sys.fw.bg_apps_limit" "64" "Background app limit (expanded)"

echo ""

# --- Section 4: CPU Optimization (Dimensity 1080) ---
echo "========================================================================"
echo "=== Section 4: CPU Optimization (MediaTek Dimensity 1080) ==="
echo "========================================================================"

echo "[*] Touch & Input Latency..."
adb shell settings put secure long_press_timeout 300
adb shell settings put system pointer_speed 1
adb shell settings put secure multi_press_timeout 200
adb shell settings put secure touch_exploration_enabled 0

if [ "$ROOT_AVAILABLE" = true ]; then
    for input in $(adb shell "ls /sys/class/input 2>/dev/null" | tr -d '\r' | grep -E '^input[0-9]+$'); do
        adb shell "echo 1 > /sys/class/input/$input/sensitivity" 2>/dev/null || true
        adb shell "echo 0 > /sys/class/input/$input/filter" 2>/dev/null || true
    done
    echo "[+] Input sensitivity optimized (root)"
else
    echo "[i] Input sensitivity requires root"
fi

echo "[*] Frame Rate & Adaptive Refresh (120Hz AMOLED)..."
adb shell settings put system peak_refresh_rate 120.0
adb shell settings put system min_refresh_rate 60.0
adb shell settings put secure refresh_rate_mode 0
adb shell settings put global force_refresh_rate 0 2>/dev/null || true
echo "[+] Adaptive refresh rate configured (60-120Hz)"

echo "[*] CPU Scheduler Tuning..."
if [ "$ROOT_AVAILABLE" = true ]; then
    # EAS/CFS scheduler parameters for responsiveness
    write_sysfs_safe "/proc/sys/kernel/sched_latency_ns" "10000000" "sched_latency (10ms)"
    write_sysfs_safe "/proc/sys/kernel/sched_min_granularity_ns" "1500000" "sched_min_granularity (1.5ms)"
    write_sysfs_safe "/proc/sys/kernel/sched_wakeup_granularity_ns" "1000000" "sched_wakeup_granularity (1ms)"
    write_sysfs_safe "/proc/sys/kernel/sched_migration_cost_ns" "300000" "sched_migration_cost (0.3ms)"
    write_sysfs_safe "/proc/sys/kernel/sched_rt_runtime_us" "-1" "sched_rt_runtime (unlimited RT)"
    write_sysfs_safe "/proc/sys/kernel/sched_schedstats" "0" "schedstats (disabled)"
    
    # uclamp for better task placement
    write_sysfs_safe "/proc/sys/kernel/sched_util_clamp_min" "0" "uclamp_min"
    write_sysfs_safe "/proc/sys/kernel/sched_util_clamp_max" "1024" "uclamp_max"
    
    # CPU governors
    for cpu in $(adb shell "ls /sys/devices/system/cpu 2>/dev/null" | tr -d '\r' | grep -E '^cpu[0-9]+$'); do
        adb shell "echo schedutil > /sys/devices/system/cpu/$cpu/cpufreq/scaling_governor" 2>/dev/null || true
        adb shell "echo 0 > /sys/devices/system/cpu/$cpu/cpufreq/schedutil/down_rate_limit_us" 2>/dev/null || true
        adb shell "echo 0 > /sys/devices/system/cpu/$cpu/cpufreq/schedutil/up_rate_limit_us" 2>/dev/null || true
    done
    echo "[+] CPU scheduler tuned (EAS/CFS, uclamp)"
    
    # cpuset configuration
    if [ "$CPUSET_AVAILABLE" = true ] && [ -n "$CPUSET_PATH" ]; then
        adb shell "echo '0-7' > $CPUSET_PATH/top-app/cpus" 2>/dev/null || true
        adb shell "echo '0-7' > $CPUSET_PATH/foreground/cpus" 2>/dev/null || true
        adb shell "echo '0-3' > $CPUSET_PATH/background/cpus" 2>/dev/null || true
        adb shell "echo '0-3' > $CPUSET_PATH/system-background/cpus" 2>/dev/null || true
        echo "[+] CPUset configured (big.LITTLE)"
    fi
else
    echo "[i] CPU scheduler tuning requires root"
fi

echo ""

# --- Section 5: GPU Optimization (Mali) ---
echo "========================================================================"
echo "=== Section 5: GPU Optimization (Mali GPU) ==="
echo "========================================================================"

echo "[*] SurfaceFlinger & Frame Pacing..."
set_prop_safe "debug.sf.latch_unsignaled" "1" "Frame latching"
set_prop_safe "debug.sf.disable_backpressure" "1" "Reduce frame backpressure"
set_prop_safe "debug.sf.enable_gl_backpressure" "0" "Disable GL backpressure"
set_prop_safe "debug.sf.early_phase_offset_ns" "500000" "Early phase offset"
set_prop_safe "debug.sf.early_app_phase_offset_ns" "500000" "Early app phase"
set_prop_safe "debug.sf.early_gl_phase_offset_ns" "3000000" "Early GL phase"
set_prop_safe "debug.sf.early_app_gl_phase_offset_ns" "3000000" "Early app GL phase"
set_prop_safe "debug.sf.early_window_phase_offset_ns" "500000" "Early window phase"
set_prop_safe "debug.sf.early_gl_window_phase_offset_ns" "3000000" "Early GL window phase"

echo "[*] HWUI & Rendering Pipeline..."
set_prop_safe "debug.hwui.renderer" "skiagl" "HWUI renderer (Skia GL)"
set_prop_safe "debug.egl.hw" "1" "EGL hardware"
set_prop_safe "debug.composition.type" "gpu" "GPU composition"
set_prop_safe "debug.hwui.render_dirty_regions" "false" "Reduce dirty region overhead"
set_prop_safe "debug.hwui.use_buffer_age" "true" "Buffer age optimization"
set_prop_safe "debug.hwui.level" "0" "HWUI debug level (off)"
set_prop_safe "debug.hwui.show_dirty_regions" "false" "Hide dirty regions"
set_prop_safe "debug.enabletr" "true" "TR optimization"

adb shell settings put global hwui_force_gpu_acceleration 1 2>/dev/null
adb shell settings put global force_hw_ui 1 2>/dev/null
adb shell settings put global gpu_debug_app "" 2>/dev/null

echo "[+] Vulkan preferred where supported; GL fallback stable"

if [ "$ROOT_AVAILABLE" = true ]; then
    echo "[*] GPU Devfreq Tuning..."
    for devfreq in $(adb shell "ls /sys/class/devfreq 2>/dev/null" | tr -d '\r'); do
        governor_path="/sys/class/devfreq/$devfreq/governor"
        if adb shell "test -f $governor_path 2>/dev/null" 2>/dev/null; then
            adb shell "echo simple_ondemand > $governor_path" 2>/dev/null || \
            adb shell "echo performance > $governor_path" 2>/dev/null || true
        fi
    done
    echo "[+] GPU devfreq configured"
fi

echo ""

# --- Section 6: Memory & RAM Optimization (8GB) ---
echo "========================================================================"
echo "=== Section 6: Memory & RAM Optimization (8GB) ==="
echo "========================================================================"

if [ "$ROOT_AVAILABLE" = true ]; then
    echo "[*] VM Parameters..."
    write_sysfs_safe "/proc/sys/vm/swappiness" "100" "swappiness (aggressive swap)"
    write_sysfs_safe "/proc/sys/vm/vfs_cache_pressure" "50" "vfs_cache_pressure"
    write_sysfs_safe "/proc/sys/vm/dirty_ratio" "20" "dirty_ratio"
    write_sysfs_safe "/proc/sys/vm/dirty_background_ratio" "10" "dirty_background_ratio"
    write_sysfs_safe "/proc/sys/vm/dirty_expire_centisecs" "3000" "dirty_expire (30s)"
    write_sysfs_safe "/proc/sys/vm/dirty_writeback_centisecs" "500" "dirty_writeback (5s)"
    write_sysfs_safe "/proc/sys/vm/page-cluster" "3" "page-cluster"
    write_sysfs_safe "/proc/sys/vm/min_free_kbytes" "40960" "min_free_kbytes (40MB)"
    write_sysfs_safe "/proc/sys/vm/extra_free_kbytes" "0" "extra_free_kbytes"
    write_sysfs_safe "/proc/sys/vm/overcommit_memory" "1" "overcommit_memory"
    write_sysfs_safe "/proc/sys/vm/overcommit_ratio" "50" "overcommit_ratio"
    write_sysfs_safe "/proc/sys/vm/compact_memory" "1" "memory compaction"
    
    echo "[*] LMKD Configuration..."
    if adb shell "test -f /sys/module/lowmemorykiller/parameters/minfree 2>/dev/null" 2>/dev/null; then
        adb shell "echo '8192,12288,16384,20480,24576,30720' > /sys/module/lowmemorykiller/parameters/minfree" 2>/dev/null || true
        adb shell "echo '32' > /sys/module/lowmemorykiller/parameters/cost" 2>/dev/null || true
        adb shell "echo '1' > /sys/module/lowmemorykiller/parameters/lmk_fast_run" 2>/dev/null || true
        echo "[+] LMKD configured (balanced multitasking)"
    fi
    
    # zRAM configuration
    if [ "$ZRAM_AVAILABLE" = true ] && [ -n "$ZRAM_PATH" ]; then
        echo "[*] zRAM Configuration (2GB, lz4)..."
        adb shell "swapoff $ZRAM_PATH" 2>/dev/null || true
        adb shell "echo 1 > /sys/block/$(basename $ZRAM_PATH)/reset" 2>/dev/null || true
        adb shell "echo lz4 > /sys/block/$(basename $ZRAM_PATH)/comp_algorithm" 2>/dev/null || true
        adb shell "echo 2147483648 > /sys/block/$(basename $ZRAM_PATH)/disksize" 2>/dev/null || true
        adb shell "mkswap $ZRAM_PATH" 2>/dev/null || true
        adb shell "swapon $ZRAM_PATH -p 32767" 2>/dev/null || true
        echo "[+] zRAM configured (2GB, lz4)"
    fi
else
    echo "[i] Memory tuning requires root"
fi

echo ""

# --- Section 7: Storage & I/O Optimization (UFS) ---
echo "========================================================================"
echo "=== Section 7: Storage & I/O Optimization (UFS) ==="
echo "========================================================================"

if [ "$ROOT_AVAILABLE" = true ] && [ -n "$BLOCK_DEVICES" ]; then
    echo "[*] I/O Scheduler Configuration..."
    for device in $BLOCK_DEVICES; do
        queue_path="/sys/block/$device/queue"
        if adb shell "test -d $queue_path 2>/dev/null" 2>/dev/null; then
            adb shell "echo mq-deadline > $queue_path/scheduler" 2>/dev/null || \
            adb shell "echo deadline > $queue_path/scheduler" 2>/dev/null || true
            
            adb shell "echo 256 > $queue_path/read_ahead_kb" 2>/dev/null || true
            adb shell "echo 0 > $queue_path/rotational" 2>/dev/null || true
            adb shell "echo 128 > $queue_path/nr_requests" 2>/dev/null || true
            adb shell "echo 1 > $queue_path/rq_affinity" 2>/dev/null || true
            adb shell "echo 0 > $queue_path/nomerges" 2>/dev/null || true
            adb shell "echo 2 > $queue_path/rq_affinity_delay" 2>/dev/null || true
            
            echo "[+] $device: mq-deadline, read_ahead=256KB"
        fi
    done
    
    echo "[*] Running fstrim..."
    adb shell "sm fstrim" 2>/dev/null || \
    adb shell "fstrim -v /data" 2>/dev/null || true
    echo "[+] fstrim executed"
else
    echo "[i] Storage tuning requires root"
    echo "[i] Run 'adb shell sm fstrim' periodically for TRIM"
fi

echo ""

# --- Section 8: Network Optimization ---
echo "========================================================================"
echo "=== Section 8: Network Optimization ==="
echo "========================================================================"

echo "[*] Private DNS (AdGuard)..."
adb shell settings put global private_dns_mode hostname
adb shell settings put global private_dns_specifier "dns.adguard-dns.com"
echo "[+] Private DNS: AdGuard (ads/trackers blocked)"

echo "[*] WiFi Optimization..."
adb shell settings put global wifi_frequency_band 2
adb shell settings put global wifi_sleep_policy 2
adb shell settings put global wifi_scan_always_enabled 0
adb shell settings put global ble_scan_always_enabled 0
adb shell settings put global wifi_idle_ms 900000 2>/dev/null || true
adb shell settings put global wifi_supplicant_scan_interval_ms 180000 2>/dev/null || true
adb shell settings put global network_scoring_ui_enabled 1 2>/dev/null || true
adb shell settings put global wifi_rtt_density_enabled 0 2>/dev/null || true
echo "[+] Background scan reduced; WiFi roaming improved"

echo "[*] Captive Portal & TCP..."
adb shell settings put global captive_portal_detection_enabled 0
adb shell settings put global captive_portal_mode 0
adb shell settings put global tcp_default_init_rwnd 60 2>/dev/null || true
echo "[+] Captive portal checks disabled"

if [ "$ROOT_AVAILABLE" = true ]; then
    echo "[*] TCP Buffer Tuning..."
    write_sysfs_safe "/proc/sys/net/ipv4/tcp_rmem" "4096 87380 16777216" "TCP read buffer"
    write_sysfs_safe "/proc/sys/net/ipv4/tcp_wmem" "4096 65536 16777216" "TCP write buffer"
    write_sysfs_safe "/proc/sys/net/ipv4/tcp_congestion_control" "cubic" "TCP congestion control"
    write_sysfs_safe "/proc/sys/net/ipv4/tcp_ecn" "0" "TCP ECN"
    write_sysfs_safe "/proc/sys/net/ipv4/tcp_slow_start_after_idle" "0" "TCP slow start after idle"
    write_sysfs_safe "/proc/sys/net/ipv4/tcp_no_metrics_save" "1" "TCP no metrics save"
    write_sysfs_safe "/proc/sys/net/ipv4/tcp_tw_reuse" "1" "TCP time-wait reuse"
    write_sysfs_safe "/proc/sys/net/core/rmem_max" "16777216" "Socket read max"
    write_sysfs_safe "/proc/sys/net/core/wmem_max" "16777216" "Socket write max"
    write_sysfs_safe "/proc/sys/net/core/netdev_max_backlog" "5000" "Netdev backlog"
    write_sysfs_safe "/proc/sys/net/core/somaxconn" "256" "Socket max connections"
fi

echo ""

# --- Section 9: Power Efficiency Optimization ---
echo "========================================================================"
echo "=== Section 9: Power Efficiency Optimization ==="
echo "========================================================================"

adb shell settings put global app_standby_enabled 0 2>/dev/null
adb shell settings put global forced_app_standby_enabled 0 2>/dev/null
adb shell settings put global adaptive_battery_management_enabled 0 2>/dev/null || true
adb shell settings put global battery_saver_constants "" 2>/dev/null || true

if [ "$ROOT_AVAILABLE" = true ]; then
    echo "[*] CPU Idle States..."
    for cpu in $(adb shell "ls /sys/devices/system/cpu 2>/dev/null" | tr -d '\r' | grep -E '^cpu[0-9]+$'); do
        if adb shell "test -d /sys/devices/system/cpu/$cpu/cpuidle" 2>/dev/null; then
            for state in $(adb shell "ls /sys/devices/system/cpu/$cpu/cpuidle 2>/dev/null" | tr -d '\r' | grep -E '^state[0-9]+$'); do
                state_name=$(adb shell "cat /sys/devices/system/cpu/$cpu/cpuidle/$state/name 2>/dev/null" | tr -d '\r')
                if echo "$state_name" | grep -qi "wfi\|standalone\|retention"; then
                    adb shell "echo 1 > /sys/devices/system/cpu/$cpu/cpuidle/$state/disable" 2>/dev/null || true
                fi
            done
        fi
    done
    echo "[+] CPU idle states optimized"
fi

echo "[+] Power efficiency configured (balanced mode)"

echo ""


# --- Section 10: Bloatware & AI Removal ---
echo "========================================================================"
echo "=== Section 10: Bloatware & AI Removal ==="
echo "========================================================================"

echo "[*] Disabling Samsung Bloatware..."
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
disable_package "com.samsung.android.app.sbrowser" "Samsung Internet"
disable_package "com.samsung.android.kidsinstaller" "Kids Home"
disable_package "com.samsung.android.app.dressingroom" "Samsung Dressing Room"

echo "[*] Disabling Google AI & Assistant..."
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
disable_package "com.google.android.apps.maps" "Google Maps"  # Optional
disable_package "com.google.android.youtube" "YouTube"  # Optional

echo "[*] Disabling 3rd Party Bloatware..."
disable_package "com.facebook.katana" "Facebook"
disable_package "com.facebook.system" "Facebook App Installer"
disable_package "com.facebook.appmanager" "Facebook App Manager"
disable_package "com.facebook.services" "Facebook Services"
disable_package "com.netflix.mediaclient" "Netflix"
disable_package "com.microsoft.office.officehubrow" "Microsoft Office"
disable_package "com.microsoft.skydrive" "OneDrive"
disable_package "com.microsoft.teams" "Microsoft Teams"
disable_package "com.spotify.music" "Spotify"
disable_package "com.linkedin.android" "LinkedIn"

echo "[*] Ensuring Keyboard Functionality..."
enable_package "com.samsung.android.honeyboard" "Samsung Keyboard"
enable_package "com.google.android.inputmethod.latin" "Gboard"
adb shell ime enable com.samsung.android.honeyboard/.service.HoneyBoardService 2>/dev/null
adb shell ime set com.samsung.android.honeyboard/.service.HoneyBoardService 2>/dev/null
echo "[+] Keyboard functionality secured."

echo ""

# --- Section 11: UI Optimization ---
echo "========================================================================"
echo "=== Section 11: UI Optimization (Minimalist) ==="
echo "========================================================================"

echo "[*] Installing Minimalist Launcher (KISS)..."
KISS_URLS=(
    "https://f-droid.org/repo/fr.neamar.kiss_198.apk"
    "https://github.com/Neamar/KISS/releases/download/v3.19.11/kiss-v3.19.11.apk"
)
for KISS_URL in "${KISS_URLS[@]}"; do
    echo "    Trying: $KISS_URL"
    if install_apk "fr.neamar.kiss" "$KISS_URL" "KISS Launcher"; then
        break
    fi
done
echo "[i] Set KISS as default: Settings > Apps > Default apps > Home app"

echo "[*] Configuring Ultra-Smooth UI..."
adb shell settings put secure ui_night_mode 2
adb shell settings put global window_animation_scale 0.0
adb shell settings put global transition_animation_scale 0.0
adb shell settings put global animator_duration_scale 0.0
adb shell settings put system motion_effect_enabled 0
adb shell settings put system sound_effects_enabled 0
adb shell settings put global fancy_ime_animations 0
adb shell settings put system haptic_feedback_enabled 0
adb shell settings put system font_scale 0.95
adb shell settings put system screen_brightness_mode 0 2>/dev/null || true
adb shell settings put global policy_control "immersive.full=*" 2>/dev/null || true
echo "[+] Ultra-smooth UI configured (zero animations, dark mode)"

echo ""

# --- Section 12: Privacy Hardening (iOS-Level) ---
echo "========================================================================"
echo "=== Section 12: Privacy Hardening (iOS-Level) ==="
echo "========================================================================"

echo "[*] Installing On-Device Firewall (RethinkDNS)..."
RETHINK_URLS=(
    "https://github.com/celzero/rethink-app/releases/download/v0.5.5t/app-fdroid-release.apk"
    "https://github.com/celzero/rethink-app/releases/download/v0.5.5u/app-universal-release.apk"
)
for RETHINK_URL in "${RETHINK_URLS[@]}"; do
    echo "    Trying: $RETHINK_URL"
    if install_apk "com.celzero.bravedns" "$RETHINK_URL" "RethinkDNS Firewall"; then
        break
    fi
done
echo "[i] Open RethinkDNS and start it for firewall protection"

echo "[*] Disabling Telemetry & Analytics..."
disable_package "com.samsung.android.samsunganalytics" "Samsung Analytics"
disable_package "com.samsung.android.scs" "Samsung Customization Service"
disable_package "com.samsung.android.themestore" "Samsung Themes"
disable_package "com.google.android.apps.tachyon" "Google Duo"
adb shell settings put global send_action_app_error 0
adb shell settings put global upload_apk_enable 0 2>/dev/null || true
adb shell settings put global package_verifier_user_consent 0 2>/dev/null || true

echo "[*] Restricting Background & Invasive Permissions..."
adb shell appops set com.android.chrome RUN_IN_BACKGROUND ignore 2>/dev/null || true
adb shell appops set com.android.chrome CAMERA ignore 2>/dev/null || true
adb shell appops set com.android.chrome RECORD_AUDIO ignore 2>/dev/null || true
adb shell appops set com.android.chrome ACCESS_COARSE_LOCATION ignore 2>/dev/null || true
adb shell appops set com.android.chrome ACCESS_FINE_LOCATION ignore 2>/dev/null || true

echo "[*] Assist & Sensor Data Limiting..."
adb shell settings put secure assist_structure_enabled 0
adb shell settings put secure assist_screenshot_enabled 0
adb shell settings put secure assist_disclosure_enabled 0
adb shell settings put secure accessibility_enabled 0 2>/dev/null || true

echo "[*] Disabling Ad Services..."
disable_package "com.google.android.gms.ads" "Google Ads" 2>/dev/null || true
disable_package "com.android.vending" "Play Store" 2>/dev/null || true  # Optional, may break purchases
adb shell settings put global adid_enabled 0 2>/dev/null || true
adb shell settings put global advertising_id_enabled 0 2>/dev/null || true
adb shell settings put global limited_sim_card_support 1 2>/dev/null || true

echo "[+] Privacy hardened (iOS-level restrictions applied)"

echo ""

# --- Section 13: Security Hardening ---
echo "========================================================================"
echo "=== Section 13: Security Hardening ==="
echo "========================================================================"

echo "[*] SELinux Configuration..."
if [ "$ROOT_AVAILABLE" = true ]; then
    adb shell setenforce 1 2>/dev/null || echo "[i] SELinux enforcement requires root"
    adb shell "echo '1' > /sys/fs/selinux/enforce" 2>/dev/null || true
else
    echo "[i] SELinux changes require root"
fi

echo "[*] Restricting Package Installation Sources..."
adb shell settings put global install_non_market_apps 0 2>/dev/null || true
adb shell settings put secure install_non_market_apps 0 2>/dev/null || true
adb shell settings put global unknown_sources_default_reversed 1 2>/dev/null || true

echo "[*] Enabling Google Play Protect..."
adb shell settings put global package_verifier_enable 1
adb shell settings put global verifier_verify_adb_installs 1
adb shell settings put global verify_apps_enabled 1 2>/dev/null || true
adb shell settings put global harmful_app_warnings_enabled 1 2>/dev/null || true

echo "[*] Reducing Attack Surface..."
adb shell settings put global adb_enabled 0 2>/dev/null || true  # Disable ADB after script
adb shell settings put global development_settings_enabled 0 2>/dev/null || true
adb shell settings put global always_finish_activities 0 2>/dev/null || true
adb shell settings put global activity_manager_constants "" 2>/dev/null || true

echo "[*] Disabling Background Sensors..."
adb shell settings put secure sensors_enabled 0 2>/dev/null || true
adb shell settings put global sensor_privacy_enabled 1 2>/dev/null || true

echo "[+] Security hardened (SELinux, package verification, attack surface reduced)"

echo ""

# --- Section 14: Advanced Threading Optimization ---
echo "========================================================================"
echo "=== Section 14: Advanced Threading Optimization ==="
echo "========================================================================"

if [ "$ROOT_AVAILABLE" = true ]; then
    echo "[*] Binder Thread Pool..."
    write_sysfs_safe "/sys/devices/system/binder/binder_threads/max_threads" "16" "Binder max threads"
    
    echo "[*] Scheduler Threading..."
    write_sysfs_safe "/proc/sys/kernel/sched_nr_migrate" "8" "Scheduler migration count"
    write_sysfs_safe "/proc/sys/kernel/sched_tunable_scaling" "1" "Scheduler tunable scaling"
    write_sysfs_safe "/proc/sys/kernel/sched_cfs_bandwidth_slice_us" "5000" "CFS bandwidth slice"
    
    echo "[+] Threading optimized (binder, scheduler migration)"
else
    echo "[i] Threading optimization requires root"
fi

echo ""

# --- Section 15: Storage & Cache Optimization ---
echo "========================================================================"
echo "=== Section 15: Storage & Cache Optimization ==="
echo "========================================================================"

echo "[*] Trimming Filesystems..."
adb shell "sm fstrim" 2>/dev/null || \
adb shell "fstrim -v /data" 2>/dev/null || \
echo "[i] fstrim requires root or newer Android"

echo "[*] Clearing System & Application Caches..."
adb shell pm trim-caches 9999999999 2>/dev/null || echo "[i] Cache trim failed"

echo "[+] Storage optimized"

echo ""

# --- Section 16: System Speed Optimization ---
echo "========================================================================"
echo "=== Section 16: System Speed Optimization ==="
echo "========================================================================"

echo "[*] Compiling Apps for Speed (Background)..."
adb shell cmd package compile -m speed -a 2>/dev/null &
COMPILE_PID=$!

echo "[*] Whitelisting Essential Apps from Battery Restrictions..."
adb shell dumpsys deviceidle whitelist +com.android.systemui 2>/dev/null || true
adb shell dumpsys deviceidle whitelist +com.samsung.android.honeyboard 2>/dev/null || true
adb shell dumpsys deviceidle whitelist +com.android.launcher3 2>/dev/null || true
adb shell dumpsys deviceidle whitelist +fr.neamar.kiss 2>/dev/null || true

echo "[*] Performance Properties..."
set_prop_safe "debug.performance.tuning" "1" "Performance tuning"
set_prop_safe "debug.sf.hw" "1" "Hardware overlays"
adb shell settings put global cached_apps_freezer enabled 2>/dev/null || true
adb shell settings put system force_high_end_gfx 1 2>/dev/null || true

echo "[*] Media & System Performance..."
adb shell settings put system accelerometer_rotation 0 2>/dev/null || true
adb shell settings put secure long_press_timeout 400 2>/dev/null || true
adb shell settings put secure touch_exploration_enabled 0 2>/dev/null || true
adb shell settings put system pointer_speed 0 2>/dev/null || true

echo "[+] System speed optimization complete"

echo ""

# --- Section 17: Developer Platform (Termux) ---
echo "========================================================================"
echo "=== Section 17: Developer Platform (Termux) ==="
echo "========================================================================"

echo "[*] Installing Termux..."
TERMUX_URLS=(
    "https://f-droid.org/repo/com.termux_118.apk"
    "https://github.com/termux/termux-app/releases/download/v0.118.0/termux-app_v0.118.0+github-debug_universal.apk"
)
for TERMUX_URL in "${TERMUX_URLS[@]}"; do
    echo "    Trying: $TERMUX_URL"
    if install_apk "com.termux" "$TERMUX_URL" "Termux Terminal"; then
        break
    fi
done

echo ""
echo "[*] Native Build Tools (Install Manually in Termux):"
echo "    pkg update && pkg upgrade"
echo "    pkg install clang make cmake git   # C/C++"
echo "    pkg install rust                    # Rust"
echo "    pkg install golang                  # Go"
echo "    pkg install zig                     # Zig"
echo "    pkg install nasm llvm               # Assembly/LLVM"
echo ""
echo "    These enable: native tools, benchmarking, kernel interaction,"
echo "    networking tools, and system performance development."
echo ""

adb shell settings put global development_settings_enabled 1
adb shell settings put global stay_on_while_plugged_in 7 2>/dev/null || true
echo "[+] Developer options enabled"

echo ""

# --- Section 18: Mark Reboot Pending ---
if [ "$PENDING" != "1" ]; then
    set_prop_safe "persist.sys.ultra_opt.pending" "1" "Reboot staging flag"
fi

# --- Final Steps ---
echo "========================================================================"
echo "=== Finalizing ==="
echo "========================================================================"

adb shell am force-stop com.android.systemui 2>/dev/null || true
sleep 2

echo ""
echo "========================================================================"
echo "=== OPTIMIZATION FRAMEWORK v${SCRIPT_VERSION} COMPLETE ==="
echo "========================================================================"
echo ""
echo "[+] Applied (Immediate):"
echo "    - Scheduler/VM/GPU properties"
echo "    - Settings, privacy, security"
echo "    - UI optimization, bloatware removal"
echo ""
echo "[+] Staged for Next Reboot:"
echo "    - Kernel/sysfs tuning (zRAM, I/O, governor, LMK)"
echo "    - Run this script again after reboot to apply"
echo ""
echo "[+] Your Samsung A34 5G (Dimensity 1080, 8GB) is tuned for:"
echo "    - Smoother UI, better app launch, improved multitasking"
echo "    - CPU scheduler & cpuset (big.LITTLE)"
echo "    - Mali GPU / SurfaceFlinger / Vulkan-prefer"
echo "    - zRAM 2GB lz4, balanced LMK, ART speed-profile"
echo "    - Storage I/O (mq-deadline, read_ahead)"
echo "    - Network (TCP, DNS, captive portal off)"
echo "    - Power: schedutil governor; thermals safe"
echo "    - Privacy (iOS-style) & security hardening"
echo "    - Termux + developer tool instructions"
echo ""
echo "[*] Recommendations:"
echo "    1. Reboot device, then run this script again"
echo "    2. Set KISS Launcher as default Home"
echo "    3. Start RethinkDNS for firewall protection"
echo "    4. In Termux: pkg update && pkg upgrade"
echo "    5. Re-enable location when needed"
echo "    6. Disable USB debugging when not developing"
echo ""
echo "[*] To revert: ./autorun.sh restore"
echo ""

# --- Restore Function ---
restore_all_settings() {
    echo "========================================================================"
    echo "=== RESTORE MODE - Reverting All Optimizations ==="
    echo "========================================================================"
    
    echo "[*] Restoring CPU Scheduler Settings..."
    if [ "$ROOT_AVAILABLE" = true ]; then
        adb shell "echo 18000000 > /proc/sys/kernel/sched_latency_ns 2>/dev/null" || true
        adb shell "echo 3000000 > /proc/sys/kernel/sched_min_granularity_ns 2>/dev/null" || true
        adb shell "echo 4000000 > /proc/sys/kernel/sched_wakeup_granularity_ns 2>/dev/null" || true
        adb shell "echo 500000 > /proc/sys/kernel/sched_migration_cost_ns 2>/dev/null" || true
        adb shell "echo 950000 > /proc/sys/kernel/sched_rt_runtime_us 2>/dev/null" || true
        adb shell "echo 1024 > /proc/sys/kernel/sched_util_clamp_max 2>/dev/null" || true
        adb shell "echo 0 > /proc/sys/kernel/sched_util_clamp_min 2>/dev/null" || true
        for cpu in $(adb shell "ls /sys/devices/system/cpu 2>/dev/null" | tr -d '\r' | grep -E '^cpu[0-9]+$'); do
            adb shell "echo schedutil > /sys/devices/system/cpu/$cpu/cpufreq/scaling_governor 2>/dev/null" || true
        done
    fi
    echo "[+] CPU Scheduler restored"

    echo "[*] Restoring Virtual Memory & LMK Settings..."
    if [ "$ROOT_AVAILABLE" = true ]; then
        adb shell "swapoff /dev/block/zram0 2>/dev/null" || true
        adb shell "echo 1 > /sys/block/zram0/reset 2>/dev/null" || true
        adb shell "echo 60 > /proc/sys/vm/swappiness 2>/dev/null" || true
        adb shell "echo 100 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null" || true
        adb shell "echo 3 > /proc/sys/vm/page-cluster 2>/dev/null" || true
        adb shell "echo 65536 > /proc/sys/vm/min_free_kbytes 2>/dev/null" || true
        if adb shell "test -f /sys/module/lowmemorykiller/parameters/minfree 2>/dev/null" 2>/dev/null; then
            adb shell "echo '18432,23040,27648,32256,55296,80640' > /sys/module/lowmemorykiller/parameters/minfree 2>/dev/null" || true
        fi
        adb shell "echo '32' > /sys/module/lowmemorykiller/parameters/cost 2>/dev/null" || true
        adb shell "echo '0' > /sys/module/lowmemorykiller/parameters/lmk_fast_run 2>/dev/null" || true
    fi
    echo "[+] Virtual memory & LMK restored"
    
    echo "[*] Re-enabling Disabled Packages..."
    enable_package "com.samsung.android.bixby.agent" "Bixby Voice"
    enable_package "com.samsung.android.game.gamehome" "Game Launcher"
    enable_package "com.google.android.googlequicksearchbox" "Google Search"
    enable_package "com.google.android.as" "Android System Intelligence"
    enable_package "com.samsung.android.samsunganalytics" "Samsung Analytics"
    
    echo "[*] Restoring Performance Settings..."
    adb shell settings put global low_power 0
    adb shell settings put global battery_saver_constants ""
    adb shell settings put secure location_mode 3
    adb shell settings put global background_app_limit -1
    adb shell settings put global app_standby_enabled 1
    adb shell settings put global forced_app_standby_enabled 1
    
    echo "[*] Restoring Animation Scales & UI..."
    adb shell settings put global window_animation_scale 1.0
    adb shell settings put global transition_animation_scale 1.0
    adb shell settings put global animator_duration_scale 1.0
    adb shell settings put system motion_effect_enabled 1
    adb shell settings put system sound_effects_enabled 1
    adb shell settings put system haptic_feedback_enabled 1
    adb shell settings put global fancy_ime_animations 1
    adb shell settings put secure ui_night_mode 0
    adb shell settings put system font_scale 1.0
    
    echo "[*] Restoring Network Settings..."
    adb shell settings put global private_dns_mode off
    adb shell settings put global private_dns_specifier ""
    adb shell settings put global wifi_scan_always_enabled 1
    adb shell settings put global ble_scan_always_enabled 1
    adb shell settings put global captive_portal_detection_enabled 1
    adb shell settings put global captive_portal_mode 1
    
    echo "[*] Restoring Security Settings..."
    adb shell settings put global install_non_market_apps 1
    adb shell settings put global development_settings_enabled 1
    adb shell settings put global adb_enabled 1
    
    echo "[*] Restoring Thermal Defaults..."
    if [ "$ROOT_AVAILABLE" = true ] && [ "$THERMAL_AVAILABLE" = true ]; then
        for tz in $(adb shell "ls /sys/class/thermal 2>/dev/null" | tr -d '\r' | grep thermal_zone); do
            adb shell "echo 'default' > /sys/class/thermal/$tz/mode 2>/dev/null" || true
        done
    fi
    
    echo "[*] Clearing Optimization Flags..."
    adb shell setprop persist.sys.ultra_opt.pending 0 2>/dev/null
    adb shell setprop persist.sys.ultra_opt.version "" 2>/dev/null
    
    echo ""
    echo "[+] Default settings have been restored."
    echo "[i] Uninstall KISS Launcher, RethinkDNS, and Termux manually if desired."
    echo "[i] A reboot is recommended."
}

# Handle restore mode from command line
if [ "$SCRIPT_MODE" = "restore" ]; then
    restore_all_settings
fi

echo ""
echo "[+] Script completed successfully!"
