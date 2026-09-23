# Design: Tachometer Watch Face (v1)

Agreed on 2026-09-23 in a design grilling session. The vocabulary lives in [`CONTEXT.md`](../CONTEXT.md). This file records the decisions. The throwaway HTML prototype that rendered them is [`prototype/index.html`](../prototype/index.html) (`open prototype/index.html`). It stays on main as the geometry reference for the port and is deleted once the port is done (ticket 09).

## Target

- Garmin fenix 7 Pro Sapphire Solar, 47mm (device id `fenix7pro`): 260×260 round MIP display, 64 colors, Connect IQ API 5.2.
- Personal sideload. A Connect IQ Store release is out of scope for now.
- All geometry derives from the screen radius, so other round MIP devices (for example the fenix 7X Pro at 280×280) are cheap to add later.

## Tachometer

- Half circle across the top of the face: 0 at 9 o'clock, 3 at 12 o'clock, 6 at 3 o'clock, running clockwise.
- Numerals 0 to 6 with no unit label.
- Ticks every 10 minutes (major, numbered), every 5 minutes (mid) and every minute (minor).
- The Redline covers minutes 50 to 60 in red.
- Rings from the rim inward: Sweep band (about 8 px), ticks, numerals, Rev Bar (about 3 px).

## Minute Style

- A user setting with three options: Needle, Sweep (filled arc), and Sweep + Tip (filled arc plus a short white line at its end). The default is Sweep + Tip.
- The Needle is a short pointer that runs from just outside the Rev Bar to the rim, with no center hub, so it never crosses the Gear.
- The Sweep and the Needle are amber (`0xFFAA00`, Garmin's `COLOR_YELLOW`) and turn red past minute 50. Amber won over orange (`0xFF5500`), which was too close to the Redline red for the change at minute 50 to stand out.
- The minute display always moves in whole-minute steps.

## Gear

- A large number (about 64 px tall on the 260 px screen) inside the Tachometer, above the center of the face, ringed by the Rev Bar. This reads like the gear indicator in a car's rev counter, and puts the hour and minutes together in the top half.
- Follows the watch's 12/24-hour system setting, with no leading zero. 12-hour mode adds a small AM/PM below the Gear. Midnight in 24-hour mode shows `0`.
- Chosen over an earlier layout with the Gear below center (prototype variant A), where a hub Needle crossed the Top Slot and the bottom half was more crowded.

## Rev Bar

- A thin arc inside the numerals, spanning the same 180° as the Tachometer, with 60 segments (one per second). Seconds 50 to 59 are red.
- Shown only while the watch is awake by default. The "Always-on Rev Bar" setting (default off) keeps it running in low-power mode through partial updates.
- If the watch reports that the partial-update power budget was exceeded, the Rev Bar hides until the next wake rather than freezing on a stale second.

## Fuel Gauge

- An arc of about 70° centered at 6 o'clock, with 10 segments of 10% each, filling from left (empty) to right (full). The lit segment count rounds to nearest: 9% shows one segment, 4% shows none.
- No E/F letters. A pump icon at the empty end is the Low-Fuel Lamp: grey normally, amber at 20% or below, red at 10% or below.
- At the full end, a bolt icon shows while cable charging; otherwise a sun icon shows while solar intensity is above zero.
- The battery percentage is not printed on the gauge; it is available as a Readout.

## Slots and Readouts

- Four Slots below the Tachometer, like a car's trip computer: Left, Center and Right in one row just below the center of the face, and Bottom underneath, above the Fuel Gauge. Left, Center and Right stack the icon above the value; Bottom puts them side by side.
- Defaults: Center shows the date, Left shows steps, Right shows heart rate, Bottom shows weather.
- Available Readouts: date, steps, weather, heart rate, Body Battery, sunrise/sunset, notifications, battery %, and empty.
- Each Readout is an icon plus a value, with no text labels. Missing data shows `--`.
  - Date: `WED 23`.
  - Steps: the raw count; the icon turns green once the step goal is reached.
  - Weather: a condition icon plus the temperature, in the units the watch is set to. A setting picks feels-like (the default) or actual temperature. Nothing on the face marks which one is shown, and if the chosen value is missing the Readout shows `--` rather than falling back to the other.
  - Heart rate: the latest bpm.
  - Body Battery: 0 to 100.
  - Sunrise/sunset: an icon and the time of the next event.
  - Notifications: a bell and the count, dimmed at zero.
  - Battery: the percentage, for example `76%`.

## Look

- Black background, white ticks and numerals, red Redline, amber Minute Style.
- Numeral font for the Gear and the Tachometer: condensed DIN style, shipped to the watch as a custom bitmap font. A 7-segment font was tried and rejected because `1` becomes two thin bars and hours like `11` read poorly.

## Settings

Seven settings in v1, edited in the Garmin Connect phone app: Minute Style, one Readout per Slot (four settings), Weather temperature (feels like or actual, default feels like), and Always-on Rev Bar. The 12/24-hour format and units follow the watch's system settings.

## Out of scope for v1

- An accent color setting.
- Tapping a Slot to open the matching widget (touch through the Complications API).
- An on-watch settings menu.
- A Connect IQ Store release.

## Next

The design is locked. The Monkey C port is split into tickets in [`docs/tickets/`](tickets/README.md); the port questions the design session skipped (source layout, testing approach, memory limit) are settled in ticket 01.
