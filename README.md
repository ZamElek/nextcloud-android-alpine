## Overview
AlpineDroid lets you run an Alpine Linux chroot on your Android device to host Nextcloud with Nginx, PHP-FPM, and an optional Cloudflare Tunnel. Auto-start on boot is handled via [Magisk boot scripts](https://github.com/topjohnwu/Magisk/blob/master/docs/guides.md#boot-scripts) at `/data/adb/service.d`.

## Project Structure
This project uses [AlpineDroid](https://github.com/stnby/AlpineDroid.git) as a git submodule to manage the Alpine Linux chroot setup. The AlpineDroid repository contains the core scripts for setting up and managing the Alpine Linux environment on your Android device.

### Working with the Submodule
```bash
# Clone this repository with submodules
git clone --recursive https://github.com/zamelek/nextcloud-android-alpine.git

# Or if you already cloned without --recursive
git submodule update --init --recursive

# Update the AlpineDroid submodule to latest
git submodule update --remote alpinedroid

# Pull latest changes for this project and submodules
git pull && git submodule update --recursive
```

## Prerequisites
- Unlocked bootloader and root access
- Magisk installed with root
- BusyBox available on the device (a collection of common Unix utilities in a single binary, often required for advanced shell scripts)
- USB debugging enabled and ADB installed on your computer

## Install AlpineDroid (chroot)
```bash
# Plug in your device and enable USB debugging)
adb push alpinedroid/setup.sh /sdcard
adb shell
su
sh /sdcard/setup.sh
```

### Chroot helpers (on device)
- Mount required partitions:
```bash
sh /data/alpinedroid/up.sh
```
- Enter the Alpine chroot:
```bash
sh /data/alpinedroid/chroot.sh
```
- Unmount (IMPORTANT: `/sdcard` is bind-mounted to `/data/alpinedroid/mnt/sdcard`):
```bash
sh /data/alpinedroid/down.sh
```

## Install Nextcloud (inside chroot)
Follow the official Alpine wiki for a lightweight SQLite-based setup:
- Alpine wiki: https://wiki.alpinelinux.org/wiki/Nextcloud

### Configure Nginx
Begin with the provided Nginx configuration template and modify it to suit your specific paths and domain names. You can find an example in the official Nextcloud documentation: https://github.com/nextcloud/documentation/blob/master/admin_manual/installation/nginx.rst Copy it into Alpine and place it, for example, at `/etc/nginx/http.d/nextcloud.conf`, then reload Nginx inside chroot.

### Start/Restart services (inside chroot)
```bash
# Start
php-fpm83 -D
nginx

# Restart PHP-FPM and Nginx
pkill -f php-fpm83
nginx -s quit
php-fpm83 -D
nginx
```

## Cloudflare Tunnel (optional, inside chroot)
```bash
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 \
  -o /usr/bin/cloudflared
chmod +x /usr/bin/cloudflared
```

## Install OCC (Nextcloud CLI)
The OCC command in Nextcloud is a command-line tool used by administrators to manage and maintain the Nextcloud server, allowing tasks like user management, app control, and system maintenance. It is run via PHP from the Nextcloud installation directory with appropriate user permissions.

```bash
apk add nextcloud-occ
# run occ
php83 /usr/share/webapps/nextcloud/occ
```

## Auto-start on device restart (Magisk service.d)
This project uses Magisk boot scripts to start services automatically at boot. See Magisk docs: https://github.com/topjohnwu/Magisk/blob/master/docs/guides.md#boot-scripts

### Files
- `start_nextcloud_service.sh` – Magisk service script that:
  - Mounts the chroot
  - Starts PHP-FPM and Nginx
  - Starts Cloudflare Tunnel using the token from `cloudflare.env`
- `cloudflare.env` – stores `CLOUDFLARE_TUNNEL_TOKEN="..."`

### Push scripts to the device (from your computer)
```bash
chmod +x *.sh
sh adb_push_scripts.sh
```

### Install the Magisk boot script (on device)
```bash
adb shell
su
sh /sdcard/scripts/install_magisk_boot_script.sh
```
This installs the following to `/data/adb/service.d/`:
```
/data/adb/service.d/
├── start_nextcloud_service.sh    # Service script (executable)
└── cloudflare.env                # Cloudflare token (readable)
```

### Configure your Cloudflare token
Edit `cloudflare.env` before pushing, or edit it on the device after installation:
```bash
adb shell
su
sed -i 's#<your_actual_token>#PASTE_YOUR_TOKEN_HERE#' /data/adb/service.d/cloudflare.env
```

### Test immediately (optional)
```bash
adb shell
su
sh /data/adb/service.d/start_nextcloud_service.sh
```

## Manual control (inside chroot)
```bash
# Start
php-fpm83 -D
nginx

# Stop
pkill -f 'cloudflared.*tunnel run' || true
pkill -f php-fpm83 || true
nginx -s quit || true
```

## Troubleshooting
- Ensure chroot is mounted: `sh /data/alpinedroid/up.sh`
- To access the chroot environment, run as root on your device (su): `sh /data/alpinedroid/chroot.sh`
- Ensure Cloudflare token is configured in `/data/adb/service.d/cloudflare.env`
- Check processes inside chroot: `pgrep -f php-fpm83`, `pgrep nginx`, `pgrep -f 'cloudflared.*tunnel run'`
- Nginx logs (inside chroot): `/var/log/nginx/error.log`
- Nextcloud log (inside chroot): `/usr/share/webapps/nextcloud/data/nextcloud.log`, `/var/log/nextcloud/php-fpm.log`

## References
- Nextcloud Alpine guide: https://wiki.alpinelinux.org/wiki/Nextcloud
- Nextcloud Admin Manual: https://docs.nextcloud.com/server/latest/admin_manual/
- Magisk boot scripts: https://github.com/topjohnwu/Magisk/blob/master/docs/guides.md#boot-scripts
- Setup Cloudflare Tunnel: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/create-remote-tunnel/
- Restore visitor IPs (Cloudflare): https://developers.cloudflare.com/support/troubleshooting/restoring-visitor-ips/restoring-original-visitor-ips/
