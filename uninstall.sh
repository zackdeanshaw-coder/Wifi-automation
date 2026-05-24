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

# install.sh sets a pmset repeat wake. Cancel it here, but warn first since
# `pmset repeat cancel` clears ALL pmset repeat schedules, not just ours.
echo
echo "==> About to cancel the pmset repeat wake schedule."
echo "    WARNING: this clears ALL 'pmset repeat' entries on this Mac, not"
echo "    just the one this installer created. Current schedule:"
pmset -g sched | sed 's/^/      /'
read -r -p "    Cancel pmset repeat? [y/N] " reply
if [[ "$reply" =~ ^[Yy]$ ]]; then
    sudo pmset repeat cancel
    echo "    Cancelled."
else
    echo "    Skipped. Run 'sudo pmset repeat cancel' manually if you want it gone."
fi

echo
echo "Done."
