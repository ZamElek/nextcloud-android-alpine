#!/system/bin/sh
# AlpineDroid Nextcloud Magisk Service Installer
# This script installs the service script to Magisk's service.d directory

echo "=== AlpineDroid Nextcloud Magisk Service Installer ==="

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script must be run as root"
    echo "Please run: su"
    exit 1
fi

# Check if Magisk service.d directory exists
if [ ! -d "/data/adb/service.d" ]; then
    echo "❌ Magisk service.d directory not found at /data/adb/service.d"
    echo "Please ensure Magisk is properly installed"
    exit 1
fi

# Check if AlpineDroid is installed
if [ ! -f "/data/alpinedroid/chroot.sh" ]; then
    echo "❌ AlpineDroid not found at /data/alpinedroid"
    echo "Please install AlpineDroid first"
    exit 1
fi

echo "✅ Magisk service.d directory found"
echo "✅ AlpineDroid found, proceeding with installation..."

# Install the service script
echo "Installing Magisk service script..."
cp start_nextcloud_service.sh /data/adb/service.d/
chmod 755 /data/adb/service.d/start_nextcloud_service.sh

# Copy cloudflare.env to the same directory
echo "Copying cloudflare.env to service directory..."
if [ -f "/sdcard/scripts/cloudflare.env" ]; then
    cp /sdcard/scripts/cloudflare.env /data/adb/service.d/
    chmod 644 /data/adb/service.d/cloudflare.env
    echo "✅ cloudflare.env copied to service directory"
else
    echo "⚠️  Warning: cloudflare.env not found in /sdcard/scripts/"
    echo "   The Cloudflare tunnel will not start automatically"
fi

if [ $? -eq 0 ]; then
    echo "✅ Service script installed successfully"
    echo ""
    echo "📁 Files installed to /data/adb/service.d/:"
    echo "   - start_nextcloud_service.sh (service script)"
    echo "   - cloudflare.env (Cloudflare token)"
    echo ""
    echo "🎯 The script will now run automatically on every boot!"
    echo ""
    echo "📋 To test immediately (optional):"
    echo "   sh /data/adb/service.d/start_nextcloud_service.sh"
    echo ""
    echo "📋 To uninstall:"
    echo "   rm /data/adb/service.d/start_nextcloud_service.sh"
    echo "   rm /data/adb/service.d/cloudflare.env"
    echo ""
    echo "💡 Reboot to test auto-start"
else
    echo "❌ Failed to install service script"
    exit 1
fi
