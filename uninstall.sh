#!/bin/bash
# Remove the Wi-Fi schedule from this Mac.

set -euo pipefail

agents_dir="$HOME/Library/LaunchAgents"
plists=(com.user.wifi.off.plist com.user.wifi.on.plist)

echo "==> Unloading and removing LaunchAgents"
for p in "${plists[@]}"; do
    if [[ -f "$agents_dir/$p" ]]; then
        launchctl unload "$agents_dir/$p" 2>/dev/null || true
        rm "$agents_dir/$p"
    fi
done

echo "==> Removing toggle script"
sudo rm -f /usr/local/bin/toggle-wifi.sh

echo "Done."
