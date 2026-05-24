# macOS Wi-Fi Scheduler

Turn the Mac's Wi-Fi on and off automatically on a weekly schedule, so you can
keep remote access available most of the time and force it offline during a
specific window.

Built with **`launchd`** (macOS's native scheduler) plus the built-in
`networksetup` command. No Shortcuts app, no Calendar tricks, no third-party
software.

## Schedule

| Day        | Time     | Wi-Fi |
|------------|----------|-------|
| Friday     | 5:00 PM  | OFF   |
| Friday     | 10:00 PM | ON    |
| Sunday     | 7:00 AM  | OFF   |
| Monday     | 12:00 AM | ON    |

So Wi-Fi is **ON** from Monday 12am through Friday 5pm, **OFF** Friday evening
5pm–10pm, **ON** Friday 10pm through Sunday 7am, **OFF** Sunday 7am to midnight.

## Install

On the MacBook Pro:

```bash
git clone https://github.com/zackdeanshaw-coder/wifi-automation.git
cd wifi-automation
chmod +x install.sh toggle-wifi.sh uninstall.sh
./install.sh
```

You'll be prompted for your password once (the toggle script is copied into
`/usr/local/bin`, which needs `sudo`).

## Verify it's loaded

```bash
launchctl list | grep com.user.wifi
```

You should see `com.user.wifi.on` and `com.user.wifi.off`.

Test the toggle manually:

```bash
/usr/local/bin/toggle-wifi.sh off
/usr/local/bin/toggle-wifi.sh on
```

Each run appends a line to `/tmp/wifi-schedule.log`.

## Change the schedule

Edit the two plists, then re-run `./install.sh`:

- `com.user.wifi.off.plist` — when Wi-Fi turns OFF
- `com.user.wifi.on.plist` — when Wi-Fi turns ON

Each `<dict>` inside `StartCalendarInterval` is one trigger. Fields:

| Key      | Meaning                                          |
|----------|--------------------------------------------------|
| Weekday  | 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat |
| Hour     | 0–23                                             |
| Minute   | 0–59                                             |

Add more `<dict>` blocks to add more trigger times.

## Uninstall

```bash
./uninstall.sh
```

## Caveats

- **Sleep.** `launchd` fires `StartCalendarInterval` jobs as soon as the Mac
  wakes if the scheduled time passed while it was asleep. If you want the Mac
  to wake *at* the scheduled time (e.g. so the OFF event fires precisely at
  5pm even if the lid is closed), add a power schedule:

  ```bash
  sudo pmset repeat wakeorpoweron MTWRFSU 16:55:00
  ```

  That wakes the Mac at 4:55pm every day, 5 minutes before the earliest OFF
  event. `pmset -g sched` shows what's set, `sudo pmset repeat cancel` removes it.

- **Shutdown.** If the Mac is fully powered off, scheduled events do not run.
  Use `wakeorpoweron` above to power it on.

- **Wi-Fi interface name.** The script auto-detects the Wi-Fi interface
  (usually `en0`), so it works on any Mac.
