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
| Thursday   | 5:00 PM  | OFF   |
| Thursday   | 11:00 PM | ON    |
| Friday     | 5:00 PM  | OFF   |
| Friday     | 10:00 PM | ON    |
| Sunday     | 7:00 AM  | OFF   |
| Monday     | 12:00 AM | ON    |

So Wi-Fi is **ON** Mon 12am → Thu 5pm, **OFF** Thu 5pm–11pm, **ON** Thu 11pm →
Fri 5pm, **OFF** Fri 5pm–10pm, **ON** Fri 10pm → Sun 7am, **OFF** Sun 7am →
Mon 12am.

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

- **Sleep / lid closed.** `launchd` fires `StartCalendarInterval` jobs as
  soon as the Mac wakes if the scheduled time passed while it was asleep —
  meaning the OFF could be hours late. `install.sh` therefore adds a daily
  wake at **16:55** so the Fri 5pm OFF fires on time:

  ```bash
  sudo pmset repeat wakeorpoweron MTWRFSU 16:55:00
  ```

  `pmset -g sched` shows the current schedule. `sudo pmset repeat cancel`
  removes it (this is what `uninstall.sh` offers to do).

  **Limitation:** `pmset repeat` only supports one repeating entry per event
  type, so a single daily wake can't precisely cover both Fri 5pm and Sun
  7am. The installer prioritises Fri 5pm (shorter OFF window, less margin for
  error). If you also need the Sun 7am OFF to fire to the minute while the
  Mac is asleep, schedule a one-shot wake each week with:

  ```bash
  sudo pmset schedule wakeorpoweron "MM/DD/YY 06:55:00"
  ```

- **Shutdown.** `wakeorpoweron` powers the Mac on from a full shutdown too,
  not just sleep — but only if it's plugged in.

- **Existing pmset schedules.** `pmset repeat` replaces any prior repeat
  schedule. If you already had one set up for something else, you'll need to
  combine them (`pmset repeat` accepts a second event of a *different* type
  after the first, e.g. a `sleep` entry).

- **Wi-Fi interface name.** The script auto-detects the Wi-Fi interface
  (usually `en0`), so it works on any Mac.
