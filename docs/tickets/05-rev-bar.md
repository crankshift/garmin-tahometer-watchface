# 05: Rev Bar

Status: open
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

## Acceptance

- [ ] Awake: the Rev Bar fills once per minute and turns red for the last 10 seconds.
- [ ] Low power with the setting off: no Rev Bar.
- [ ] Low power with the setting on: the Rev Bar keeps filling, and the simulator's watch face diagnostics show the partial update inside the power budget.
- [ ] A simulated budget overrun hides the Rev Bar until the next wake.
