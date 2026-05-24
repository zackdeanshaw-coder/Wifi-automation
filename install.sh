#!/bin/bash
# Install the Wi-Fi schedule on this Mac.
# Run from the repo root: ./install.sh

set -euo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd)"
script_dest="/usr/local/bin/toggle-wifi.sh"
agents_dir="$HOME/Library/LaunchAgents"
plists=(com.user.wifi.off.plist com.user.wifi.on.plist)

echo "==> Installing toggle script to $script_dest"
sudo mkdir -p /usr/local/bin
sudo cp "$repo_dir/toggle-wifi.sh" "$script_dest"
sudo chmod 755 "$script_dest"

echo "==> Installing LaunchAgents to $agents_dir"
mkdir -p "$agents_dir"
for p in "${plists[@]}"; do
    cp "$repo_dir/$p" "$agents_dir/$p"
done

echo "==> Loading LaunchAgents"
for p in "${plists[@]}"; do
    # Unload first in case an older version is already loaded.
    launchctl unload "$agents_dir/$p" 2>/dev/null || true
    launchctl load -w "$agents_dir/$p"
done

echo
echo "Done. Log: /tmp/wifi-schedule.log"
echo "Verify with:  launchctl list | grep com.user.wifi"
echo "Test now:     $script_dest off   (then 'on')"
