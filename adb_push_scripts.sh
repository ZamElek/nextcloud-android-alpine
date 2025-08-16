#!/bin/bash
# ADB Push Scripts to Android Device
# This script pushes all the auto-start scripts to your Android device

echo "=== ADB Push Scripts to Android Device ==="
echo ""

# Check if ADB is available
if ! command -v adb &> /dev/null; then
    echo "❌ ADB not found. Please install Android SDK or platform-tools"
    echo "Download from: https://developer.android.com/studio/releases/platform-tools"
    exit 1
fi

# Check if device is connected
echo "🔍 Checking for connected devices..."
adb devices

# Check if any device is connected
if ! adb devices | grep -q "device$"; then
    echo ""
    echo "❌ No Android device connected or authorized"
    echo "Please:"
    echo "1. Enable USB debugging on your device"
    echo "2. Connect via USB or WiFi"
    echo "3. Authorize the connection on your device"
    echo ""
    echo "For WiFi connection:"
    echo "  adb connect <device-ip>:5555"
    exit 1
fi

echo ""
echo "✅ Device connected successfully"
echo ""

# Create scripts directory on device
echo "📁 Creating scripts directory on device..."
adb shell "mkdir -p /sdcard/scripts"

# Push all script files
echo "📤 Pushing scripts to device..."
echo ""

# List of scripts to push
SCRIPTS=(
    "cloudflare.env"
    "start_nextcloud_service.sh"
    "install_magisk_service.sh"
)

# Push each script
for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "  📤 Pushing $script..."
        adb push "$script" /sdcard/scripts/
        if [ $? -eq 0 ]; then
            echo "    ✅ Success"
        else
            echo "    ❌ Failed"
        fi
    else
        echo "  ⚠️  $script not found, skipping"
    fi
done

echo ""
echo "📋 Installation Instructions:"
echo ""
echo "1. Connect to your Android device:"
echo "   adb shell"
echo ""
echo "2. Get root access:"
echo "   su"
echo ""
echo "3. Choose installation method:"
echo ""
echo "   Option A: Magisk Service (Recommended - Simple)"
echo "   sh /sdcard/scripts/install_magisk_service.sh"
echo ""
echo "   Option B: Traditional Init Scripts"
echo "   sh /sdcard/scripts/install_autostart.sh"
echo ""
echo "4. Configure Cloudflare tunnel:"
echo "   # Edit cloudflare.env with your token first:"
echo "   nano /sdcard/scripts/cloudflare.env"
echo "   # Then test the configuration:"
echo "   sh /sdcard/scripts/configure_cloudflared.sh"
echo ""
echo "5. Reboot to test auto-start"
echo ""
echo "=== Scripts pushed successfully! ==="
echo ""
echo "Files are now available at: /sdcard/scripts/"
echo "You can now run the installation script on your device"
