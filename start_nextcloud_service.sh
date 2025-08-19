#!/system/bin/sh
# AlpineDroid Nextcloud Magisk Service Script
# This script runs automatically on boot via Magisk /data/adb/service.d/

# Wait for system to be fully booted
sleep 30

# Check if Alpine chroot exists
if [ ! -f "/data/alpinedroid/chroot.sh" ]; then
    echo "AlpineDroid not found, skipping Nextcloud startup"
    exit 0
fi

# Chroot helpers
ALPINE_ROOT="/data/alpinedroid"
CHROOT_CMD="busybox chroot $ALPINE_ROOT /bin/sh -lc"

# Mount Alpine chroot environment
echo "Mounting Alpine chroot environment..."
if [ -f "/data/alpinedroid/up.sh" ]; then
    sh /data/alpinedroid/up.sh
    if [ $? -eq 0 ]; then
        echo "✅ Alpine chroot mounted successfully"
        sleep 2
    else
        echo "❌ Failed to mount Alpine chroot"
        exit 1
    fi
else
    echo "❌ Alpine chroot mount script not found"
    exit 1
fi

# Start Nextcloud services in chroot (non-interactive)
echo "Starting Nextcloud services..."
$CHROOT_CMD "php-fpm83 -D"
$CHROOT_CMD "nginx"

# Start Cloudflare tunnel (read token from cloudflare.env)
SCRIPT_DIR="$(dirname "$0")"
if [ -f "$SCRIPT_DIR/cloudflare.env" ]; then
    . "$SCRIPT_DIR/cloudflare.env"
    if [ -n "$CLOUDFLARE_TUNNEL_TOKEN" ]; then
        echo "Starting Cloudflare tunnel..."
        $CHROOT_CMD "/usr/bin/cloudflared --no-autoupdate tunnel run --token $CLOUDFLARE_TUNNEL_TOKEN > /dev/null 2>&1 &"
        echo "✅ Cloudflare tunnel started"
    else
        echo "❌ ERROR: CLOUDFLARE_TUNNEL_TOKEN not set in cloudflare.env"
        exit 1
    fi
else
    echo "❌ ERROR: cloudflare.env not found in $SCRIPT_DIR"
    exit 1
fi

echo "✅ AlpineDroid Nextcloud services started successfully"
