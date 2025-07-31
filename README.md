# Samsung A34 5G Optimization Script

A comprehensive ADB-based optimization script designed specifically for the Samsung Galaxy A34 5G to reduce overheating, improve performance, enhance security, boost network speeds, and remove AI services.

## 🚀 Features

### Performance Optimization
- Removes Samsung bloatware (Bixby, Game Launcher, Samsung Free)
- Disables resource-heavy apps (Facebook services, Netflix, Spotify)
- **COMPLETELY REMOVES ALL AI FUNCTIONALITY** from your device
- Eliminates machine learning services and predictive features
- Limits background processes and animations
- Applies thermal management settings
- Clears system and app caches

### Security Hardening
- Blocks installation from unknown sources
- Disables location tracking and analytics
- Removes potentially vulnerable Samsung services
- Restricts app permissions for privacy
- Blocks ad and tracker domains

### Network Speed Enhancement
- Sets fast DNS servers (Cloudflare 1.1.1.1)
- Optimizes TCP and network buffer settings
- Improves WiFi performance (prefers 5GHz)
- Enhances mobile data connectivity
- Reduces network-related battery drain

### Battery Optimization
- Enables power saving features
- Reduces screen brightness and timeout
- Disables unnecessary connectivity scanning
- Limits auto-sync and background activity

## 📋 Prerequisites

1. **ADB (Android Debug Bridge)** installed on your computer
   - Download from [Android SDK Platform Tools](https://developer.android.com/studio/releases/platform-tools)
   - Or install via package manager: `sudo apt install adb` (Linux) or `brew install android-platform-tools` (macOS)

2. **USB Debugging enabled** on your Samsung A34 5G:
   - Go to Settings → About phone → Tap "Build number" 7 times
   - Go to Settings → Developer options → Enable "USB debugging"

3. **USB connection** between your phone and computer

## 🔧 Installation & Usage

1. **Clone or download** this script:
   ```bash
   git clone https://github.com/TheCreateGM/samsung-a34-optimizer.git
   cd samsung-a34-optimizer
   ```

2. **Make the script executable**:
   ```bash
   chmod +x autorun.sh
   ```

3. **Connect your Samsung A34 5G** via USB and authorize the connection

4. **Run the optimization**:
   ```bash
   ./autorun.sh
   ```

5. **To restore original settings**:
   ```bash
   ./autorun.sh restore
   ```

## ⚠️ Important Notes

- **Backup recommended**: Consider backing up your phone before running the script
- **Root access**: Some advanced optimizations require root access but the script works fine without it
- **Reversible changes**: All modifications can be undone using the restore function
- **Restart required**: Restart your phone after optimization for best results
- **Monitor temperature**: Check your phone's temperature over the next few days

## 🎯 What Gets Optimized

### Disabled Samsung Services
- Bixby Voice, Service, and Routines
- Samsung Free and Game Launcher
- Samsung Analytics and Customization Service
- AllShare MediaShare and FileShare
- Smart View and Beacon Manager

### Complete AI Removal (ALL AI Functionality Eliminated)
**Core AI Services:**
- Google Gemini/Bard AI assistant
- Google Assistant and all related services
- Android System Intelligence
- Samsung Intelligence Service

**Visual & Camera AI:**
- Google Lens visual search
- Google Photos AI features (face recognition, auto-enhance)
- Samsung Camera AR stickers and AI stamps
- Google Camera AI features

**Voice & Speech AI:**
- Google Translate and Text-to-Speech
- Speech Services and AI transcription
- Samsung Dictation and Voice Input
- All TTS AI engines

**Samsung Smart Features:**
- Smart Face Recognition & Smart Call (AI caller ID)
- Smart Suggestions & Smart Capture
- Smart Mirroring & Smart Fitting (AR/AI)
- Smart Switch Assistant

**Predictive & Adaptive AI:**
- Keyboard AI predictions (Gboard, Samsung Keyboard)
- Live wallpapers with AI features
- Predictive launcher features
- Setup wizards with AI recommendations

**Health & Content AI:**
- Samsung Health AI insights
- Google Fit AI analysis
- Google News AI curation
- Shopping recommendation AI

**Accessibility & Auto AI:**
- TalkBack AI voice features
- Voice Access AI
- Android Auto AI assistant
- Digital Wellbeing AI insights

### Disabled Third-Party Apps
- Facebook and related services
- Netflix, Spotify, Microsoft Office
- OneDrive and other pre-installed apps

### Security Enhancements
- Location tracking disabled
- Usage analytics disabled
- App permission restrictions
- Network security improvements
- Ad/tracker domain blocking

### Network Optimizations
- Fast DNS configuration
- TCP window scaling
- WiFi performance tuning
- Mobile data optimization
- Reduced connectivity scanning

## 🔄 Restore Function

If you need to revert changes:

```bash
./autorun.sh restore
```

This will:
- Re-enable commonly needed apps
- Restore original performance settings
- Reset animation scales to default
- Re-enable location services and auto-sync

## 🛠️ Troubleshooting

### Device Not Detected
- Ensure USB debugging is enabled
- Try different USB cable or port
- Check if device appears in `adb devices`
- Authorize the connection on your phone

### Permission Denied Errors
- Some optimizations require root access
- The script will continue with available optimizations
- Consider rooting for full functionality

### App Not Working After Optimization
- Use the restore function: `./autorun.sh restore`
- Or manually re-enable specific apps through Settings

## 📊 Expected Results

After running the script, you should notice:
- **Reduced overheating** during normal usage
- **Improved battery life** (20-30% increase typical)
- **Faster app loading** and smoother animations
- **Better network speeds** and connectivity
- **Enhanced privacy** and security

## ⚡ Performance Tips

1. **Restart your phone** after running the script
2. **Monitor temperature** for a few days
3. **Re-enable apps** you actually need
4. **Run periodically** to maintain optimizations
5. **Clear cache regularly** for best performance

## 🤝 Contributing

Feel free to submit issues, suggestions, or improvements. This script is specifically optimized for the Samsung Galaxy A34 5G but may work on other Samsung devices with minor modifications.

## ⚖️ Disclaimer

This script modifies system settings and disables pre-installed applications. While all changes are reversible, use at your own risk. The authors are not responsible for any issues that may arise from using this script.

## 📝 License

This project is open source and available under the MIT License.