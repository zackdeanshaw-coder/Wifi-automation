#!/bin/bash
# Turn the Mac's Wi-Fi on or off.
# Usage: toggle-wifi.sh on|off

set -euo pipefail

action="${1:-}"
if [[ "$action" != "on" && "$action" != "off" ]]; then
    echo "Usage: $0 on|off" >&2
    exit 1
fi

# Discover the Wi-Fi interface (usually en0, but not always).
interface=$(networksetup -listallhardwareports \
    | awk '/Hardware Port: Wi-Fi/{getline; print $2}')

if [[ -z "$interface" ]]; then
    echo "Could not find a Wi-Fi interface." >&2
    exit 1
fi

networksetup -setairportpower "$interface" "$action"
echo "$(date '+%Y-%m-%d %H:%M:%S')  Wi-Fi ($interface) turned $action"
