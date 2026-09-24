# 05: Rev Bar

Status: done: confirmed working on the real fenix 7 Pro on 2026-09-24, which covers the checks this ticket couldn't do in the simulator. Before that it was partial: implemented and verified against the simulator for the awake path and the build; the low-power/budget-exceeded paths are only verified by code review, not by observing the simulator in low power (see "Verification method")
Depends on: 03
Prototype reference: `drawRevBar`, `revBarVisible`

## Goal

Analog seconds as a thin arc around the Gear. It shows while the watch is awake, and optionally in low power.

## Scope

- **Shape:** an arc at radius `R - 50`, pen 3, with 60 segments. Segment `i` runs clockwise from `deg(i) - 0.6` to `deg(i + 1) + 0.6`.
- **Filling:** at second `s`, segments 0 to `s` are lit, which is `s + 1` segments. Segments 50 to 59 are red, the rest white.
- **Awake** (between `onExitSleep` and `onEnterSleep`): the full redraw every second draws the Rev Bar.
- **Low power:**
  - The Rev Bar is hidden unless the "Always-on Rev Bar" setting is on.
  - When it's on, `onPartialUpdate` draws only the newest segment each second, with `dc.setClip` set to that segment's bounding box.
- **Budget exceeded:** when `WatchFaceDelegate.onPowerBudgetExceeded` fires, set a flag that hides the Rev Bar until the next `onExitSleep`.
- **Setting** "Always-on Rev Bar": boolean, default off.

## Known limitation

After the budget is exceeded the watch stops calling `onPartialUpdate`. The segments already drawn stay on screen until the next full `onUpdate` at the top of the minute, which then leaves the Rev Bar out. So the bar can look frozen for up to about a minute. Ticket 09 decides whether that's acceptable.

## Decisions

- **Power state tracking.** `TachometerWatchFaceView` tracks `_awake` (set in `onEnterSleep`/`onExitSleep`) and `_budgetExceeded` (set by `onPowerBudgetExceeded`, cleared on `onExitSleep`), matching the idiom in the SDK's own `Analog` sample (`AnalogView`/`AnalogDelegate`) rather than inventing a different pattern. `_awake` defaults to `true`, since a watch face only starts rendering after the wrist is raised (awake); the sample leaves its equivalent flag unset (`Boolean?`, effectively false until the first `onExitSleep`), which would wrongly hide the Rev Bar on the very first frame.
- **Delegate.** `onPowerBudgetExceeded` only exists on `WatchFaceDelegate`, not `WatchFace`, so `TachometerWatchFaceDelegate` (new) holds a reference to the view and relays the call. `TachometerWatchFaceApp.getInitialView` now returns `[view, delegate]` instead of `[view]`.
- **Setting.** `AlwaysOnRevBar` is a `boolean` property with a `settingConfig type="boolean"` setting — this combination doesn't have the string/list problem `MinuteStyle` had (see ticket 03's "Decisions"), since `boolean` properties only ever pair with `boolean` settings.

## Verification method

Same constraint as ticket 04: no Accessibility permission means the simulator's Simulation menu (raise wrist, force low power, exceed power budget) can't be driven non-interactively from here. Confirmed with the build: `monkeyc`/`monkeydo -t` (20 tests passing, including the 2 new Rev Bar tests) and one simulator screenshot of the awake path (real wall-clock time, real simulator default state — awake, since that's the simulator's default). The low-power and budget-exceeded paths are verified by code review against the SDK's own `Analog` sample idiom (same `onEnterSleep`/`onExitSleep`/`onPartialUpdate`/`onPowerBudgetExceeded` shape) rather than by observation.

## Acceptance

- [x] Awake: the Rev Bar fills once per minute and turns red for the last 10 seconds. — confirmed live in the simulator (screenshot: white arc filling from 9 o'clock to the current second); the once-per-minute reset and the last-10-seconds red are `RevBar.draw`'s per-second full redraw from segment 0, colored by `RevBar.segmentColor` (unit-tested: `testRevBarSegmentColorRedlineIsLastTenSeconds`).
- [ ] Low power with the setting off: no Rev Bar. — not observed live (see "Verification method"); by code review, `revBarVisible()` is `_awake || (alwaysOnRevBar() && !_budgetExceeded)`, so with `_awake = false` and the setting off this is `false`, and neither `onUpdate` nor `onPartialUpdate` draws anything.
- [ ] Low power with the setting on: the Rev Bar keeps filling, and the simulator's watch face diagnostics show the partial update inside the power budget. — not observed live. `onPartialUpdate` draws only `RevBar.drawPartial(dc, sec)`, clipped to `RevBar.segmentClipBounds(sec)` (unit-tested to be a small box, not a wide redraw), which is the standard low-cost pattern the SDK's own sample uses for its second hand.
- [ ] A simulated budget overrun hides the Rev Bar until the next wake. — not observed live. By code review: `onPowerBudgetExceeded` sets `_budgetExceeded = true`, which `revBarVisible()` checks; it's only cleared in `onExitSleep`, matching the ticket's "Known limitation" (segments already drawn stay until the next full `onUpdate`, which then leaves the Rev Bar out because `revBarVisible()` is false).
