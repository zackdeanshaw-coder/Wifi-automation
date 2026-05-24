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

# Wake the Mac daily at 16:55 so the Fri 5pm OFF event fires on time even if
# the lid is closed. launchd's StartCalendarInterval otherwise waits until the
# Mac wakes on its own. pmset repeat allows only one repeat per event type, so
# one daily wake is the best a single command can do; the README explains how
# to use one-shot pmset schedules if you also need to hit the Sun 7am OFF
# precisely while asleep.
echo "==> Setting daily wake at 16:55 (covers the Fri 5pm OFF event)"
echo "    NOTE: this replaces any existing 'pmset repeat' schedule on this Mac."
sudo pmset repeat wakeorpoweron MTWRFSU 16:55:00

echo
echo "Done."
echo "Log:              /tmp/wifi-schedule.log"
echo "Verify agents:    launchctl list | grep com.user.wifi"
echo "Verify wake:      pmset -g sched"
echo "Test toggle now:  $script_dest off   (then 'on')"
