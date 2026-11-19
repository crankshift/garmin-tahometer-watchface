# 16: Sunrise/sunset without phone weather, release 0.3.3

Status: done: the maintainer uploads 0.3.3 and replies to the reporter
Depends on: none
Spec: [`docs/design.md`](../design.md) "Readouts", ticket [08](08-remaining-readouts.md) "Sunrise/sunset"

## Background

A Connect IQ Store user on a fenix 6S Pro ASIA (firmware 27.00, Connect IQ 3.4.5) reported on 2026-11-19 that the sunrise/sunset Readout never shows a time. They got a GPS fix outdoors and it still showed nothing.

Triaged on 2026-11-19. The cause was found in the code: the sunrise/sunset Readout takes its location only from `Weather.getCurrentConditions().observationLocationPosition`, as ticket 08 specified ("so no GPS is needed"). That is the location of the weather the phone syncs to the watch. A GPS fix on the watch never reaches it, so with no synced weather, or synced weather without a location, the Readout shows `--` forever. It isn't a missing API: `Weather.getSunrise` is API 3.3.0, and the reporter's firmware has 3.4.5.

It couldn't be reproduced in the simulator: setting the simulator's weather or position takes the Simulation menu, which an agent session can't drive. The same flaw is in the Elvish Ring face (`garmin-lotr-all-watches`), which copied this Readout.

## Agent Brief

**Category:** bug
**Summary:** The sunrise/sunset Readout falls back to the watch's own last GPS location, then to a saved last known location, when the phone weather has none.

**Current behavior:**
`Readouts.sunReadout()` shows `--` whenever `CurrentConditions.observationLocationPosition` is null, even if the watch has a GPS fix.

**Desired behavior:**
The Readout uses the first location available, in this order:

1. The weather observation location, as now.
2. `Activity.getActivityInfo().currentLocation`, the watch's last GPS fix. It is always null unless the manifest declares the `Positioning` permission.
3. The last known location saved in `Application.Storage`, so the Readout survives a reboot, a stale weather sync, or `currentLocation` going null.

When 1 or 2 gives a location, it is saved, but only when it is more than 0.01° (about 1 km) from the saved one, so flash isn't written every minute. `--` shows only when all three are null, or when a sun call returns null, as now.

**Key interfaces:**
- A pure function that picks the first non-null of the three locations, unit-tested.
- A pure function that decides whether a live location has moved far enough from the saved one to save it, unit-tested.
- The saved location is a `[latitude, longitude]` Array of Floats in degrees, under one `Application.Storage` key.
- `manifest.xml`: `<iq:uses-permission id="Positioning"/>`.

**Acceptance criteria:**
- [x] Unit tests cover the fallback order (each source missing in turn, all missing) and the save threshold (no saved location, under, and over 0.01° in latitude and longitude).
- [x] `manifest.xml` declares `Positioning`, and its version is 0.3.3.
- [x] Clean build and unit tests pass on `fenix6spro` (API 3.4) and `fenix7pro`.
- [x] A throwaway build on `fenix6spro` logs which source the Readout used and what it shows. The source is put back afterwards.
- [x] `DEVELOPER_KEY=~/.ciq/developer_key.der tools/export_iq.sh prod` builds `bin/tachometer-prod.iq`.
- [x] Ticket 08's sunrise/sunset scope points to this ticket for the location.

**Out of scope:**
- Turning on GPS from the face (`Position.enableLocationEvents`). A watch face can't keep a GPS session, and the battery cost isn't wanted.
- Background location or weather fetches.
- The Weather Readout, which still needs phone weather.
- The Elvish Ring face. It gets the same fix in its own ticket.

## Decisions

Made during triage on 2026-11-19, which the maintainer asked the agent to run unattended:

- **Weather location first.** It already works for most users, and changing the order would move their times by the distance between the phone's weather station and the watch, which is at most a minute or so. GPS only fills the gap.
- **Save the last known location.** `currentLocation` can go null after a reboot or a long time without a fix, and the weather sync drops when the phone is away. Without a saved fallback the Readout would flicker back to `--`.
- **0.01° threshold.** Sunrise moves about 4 minutes per degree of longitude, so 0.01° is under 3 seconds. It keeps flash writes to when the wearer really moves.
- **New permission.** Existing users see the Positioning permission when they update. That's the cost of reading the watch's location at all.
- **0.3.3.** A bug fix, no new feature.

Added in code review on 2026-11-19:

- **Impossible coordinates count as no location.** Some watches report a missing GPS fix as 180°, 180° instead of null. `usableSunLocation` drops any location with latitude past ±90° or longitude past ±180°, so such a value is neither used nor saved over a good one.
- **A live location is saved when weather or GPS gave one**, not by comparing the picked Location object with the saved one.

## Results

Done on 2026-11-19.

- **Code.** `Readouts.sunLocation()` reads the three sources and saves a live one. The pure parts are `pickSunLocation`, `usableSunLocation` and `shouldSaveSunLocation`, under the `SunLocation` Storage key. `manifest.xml` declares `Positioning` and says 0.3.3.
- **Tests.** 106 of 106 unit tests pass on `fenix6spro` and on `fenix7pro`. The 7 new ones cover the order, the reporter's case (GPS only, nothing saved), impossible coordinates and the threshold. Release builds pass on `fenix6spro`, `fenix7pro` and `venu3`.
- **Throwaway logs on `fenix6spro`** (source put back afterwards, no `DEBUG` lines left):
  - The simulator's own weather has a location (Olathe, Kansas). It was picked, saved on the first update and not rewritten after that.
  - Weather forced to null and no GPS: the saved location was picked, with the same time.
  - Weather null and a made-up GPS fix in Kyiv: GPS was picked and replaced the saved Kansas location. The Readout showed `6:18`, Kyiv's sunrise in the Mac's time zone.
  - GPS forced to 180°, 180°: dropped, and the saved Kyiv location was used and kept.
- **Not checked:** what a real fenix 6 returns for `currentLocation` after a GPS activity. Only the reporter's watch can show that.
- **Release.** `DEVELOPER_KEY=~/.ciq/developer_key.der tools/export_iq.sh prod` built all 146 products into `bin/tachometer-prod.iq`. Left for the maintainer: upload 0.3.3 to the Connect IQ Store, then reply to the reporter.

## Comments
