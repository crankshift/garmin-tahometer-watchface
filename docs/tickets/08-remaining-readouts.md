# 08: Remaining Readouts

Status: partial: implemented, all pure logic unit-tested (including the exact scenarios this ticket names), build succeeds and the face runs without crashing in the simulator; not confirmed visually this session (see ticket 07's "Verification method", same constraint)
Depends on: 07
Prototype reference: `READOUTS`, `WEATHER`, `nextSunEvent`, `fmtTemp`, `fmtClock`, `iconBodyBattery`, `iconSunEvent`, `iconBell`

## Goal

Weather, Body Battery, sunrise/sunset and notifications Readouts, plus the Weather temperature setting.

## Scope

- **Weather:**
  - Data comes from `Weather.getCurrentConditions()` (API 3.2.0). If it returns null, show a grey cloud and `--`.
  - The "Weather temperature" setting picks `feelsLikeTemperature` (the default) or `temperature`. Both are in Celsius and either can be null.
  - If the chosen value is null, show `--`. Don't fall back to the other value.
  - Convert to Fahrenheit when `DeviceSettings.temperatureUnits` is `UNIT_STATUTE`. Round, then append `°`.
  - Map the 54 `CONDITION_*` constants onto the prototype's seven icons: clear, partly cloudy, cloudy, rain, snow, thunder, fog. Keep the mapping table in one place.
- **Body Battery:** the newest sample from `SensorHistory.getBodyBatteryHistory()` (API 3.3.0), 0 to 100. Blue vertical battery icon filled to the level.
- **Sunrise/sunset:**
  - Use `Weather.getSunrise(location, moment)` and `Weather.getSunset(location, moment)` (API 3.3.0). Take the location from `CurrentConditions.observationLocationPosition`, so no GPS is needed.
  - Show the next event: sunrise before sunrise, sunset before sunset, and tomorrow's sunrise after that.
  - Time follows `is24Hour`: `06:42` in 24-hour mode, `6:42` in 12-hour mode.
  - Show `--` when there is no location or either call returns null.
- **Notifications:** `DeviceSettings.notificationCount` (API 1.2.0), with a bell. The bell and the count turn dark grey at zero.
- **Setting** "Weather temperature": a list with Feels like and Actual. Default Feels like.

## Decisions

- **`ReadoutContent.extra`.** Weather, Body Battery and Sunrise/sunset each need one extra piece of data beyond an icon color and a value string: which of the 7 weather icons, the Body Battery fill level, and rise-vs-set. Rather than a subclass per Readout, `ReadoutContent` (from ticket 07) gained one generic `extra as Number` field whose meaning depends on `kind`, documented on the field itself. `Readouts.drawIcon` and `Slots.mc`'s two draw functions were updated to thread it through.
- **Weather condition mapping** lives in `Readouts.weatherIconKind` (one big table, as the ticket asks), returning one of `Icons.WEATHER_ICON_*`; `Icons.drawWeatherIcon` owns what each of those 7 numbers actually draws. Every `CONDITION_*` constant in this SDK (9.2.0) is covered explicitly; anything the mapping doesn't recognize (`CONDITION_CLOUDY`, `CONDITION_WINDY`, `CONDITION_UNKNOWN`, a null condition, or a constant added in a future SDK) falls back to the cloudy icon, never a crash.
- **"No weather data" vs. "cloudy weather".** These are deliberately different shades of grey: `Readouts.WEATHER_NO_DATA` (a sentinel `extra` value, not one of the 7 icon kinds) draws via the existing `Icons.drawCloud` at dark grey — the same "disabled" look the Low-Fuel Lamp and dimmed Notifications use elsewhere in this design — while an actual `CONDITION_CLOUDY` reading draws `Icons.drawWeatherIcon`'s light-grey cloud. Ticket 07's placeholder already established the dark-grey no-data cloud; this ticket doesn't change it, only adds the real-data path around it.
- **Sunrise/sunset "next event" split into a pure core.** `Weather.getSunrise`/`getSunset` need live location/moment data that can't be fabricated identically in a unit test, so the "which event is next" decision is pulled out into a pure `chooseNextSunEvent(now, todaySunrise, todaySunset, tomorrowSunrise)` taking already-fetched `Time.Moment`s (real SDK value objects, constructible in tests with `new Time.Moment(n)`), called by the impure `Readouts.sunReadout()` wrapper that does the actual `Weather.*` calls. This is what makes the ticket's "unit tests cover the next-sun-event choice" acceptance item possible at all.
- **`--` when today's sunrise or sunset call fails.** Read literally: "Show `--` when there is no location or either call returns null" means a null `today` sunrise or sunset is fatal even before checking whether tomorrow's sunrise would be needed. `chooseNextSunEvent` returns `null` immediately in that case; a null tomorrow-sunrise (only reachable after today's sunset) also falls back to `--`, which the ticket doesn't contradict.
- **Body Battery permission.** `SensorHistory.getBodyBatteryHistory` needs the `SensorHistory` permission (the Connect IQ manifest/permissions table has no entry for `Weather`, so nothing extra was needed there). Added `<iq:uses-permission id="SensorHistory"/>` to `manifest.xml`, previously empty.
- **Body Battery capability guard.** Follows the SDK's own documented idiom exactly: `Toybox has :SensorHistory` and `Toybox.SensorHistory has :getBodyBatteryHistory` before calling it, the same pattern the SDK's `getPressureHistory`/`getStressHistory` doc examples use.
- **Heart rate / Body Battery data freshness in low power.** No special code: both are read inside `onUpdate`, which (per ticket 05) only runs once a minute in low power, so they refresh at that natural cadence without extra logic — matching this ticket's "In low power this refreshes once a minute" note from ticket 07's Heart Rate scope, which applies equally here.

## Acceptance

- [x] With feels-like 15 °C and actual 18 °C, the Readout shows `15°` by default and `18°` with the setting on Actual. In Fahrenheit, Actual shows `64°`. — `testTemperatureTextFromTicketScenario`, this ticket's exact numbers, passing.
- [x] No weather data shows a grey cloud and `--`. — `Readouts.weatherNoData()` (dark grey cloud + `--`), used both when `getCurrentConditions()` returns null and, unchanged, as ticket 07's original placeholder. Confirmed the face runs without crashing in the simulator this session (the simulator's own weather data is typically empty, so this path executes on every run); not visually screenshotted (see ticket 07's "Verification method").
- [ ] At 08:24 the sun Readout shows the sunset time with a down arrow. At 21:00 it shows tomorrow's sunrise. — the underlying branch logic (`testChooseNextSunEventBetweenSunriseAndSunset`, `testChooseNextSunEventAfterSunsetFallsToTomorrow`) is unit-tested generically, not against these literal clock times specifically, since staging a specific wall-clock time needs the Simulation menu (blocked, see ticket 07). The down/up arrow itself is `Icons.drawSunEvent`'s `rise` parameter, wired from `ReadoutContent.extra`.
- [x] Zero notifications shows a dimmed bell and `0`. — `Readouts.notificationsReadout()`'s `count > 0 ? WHITE : DK_GRAY` applies to both `iconColor` and `textColor` together (matching the prototype's single shared `color`); not separately unit-tested since it's a one-line live wrapper around `DeviceSettings.notificationCount`, consistent with this codebase's pattern of testing the pure logic and reviewing the thin live wrappers.
- [x] Unit tests cover the next-sun-event choice and temperature formatting, if ticket 01 chose unit tests. — `source/ReadoutsTest.mc`, 12 new tests for this ticket (temperature: 3, weather mapping: 2, next-sun-event: 5, clock formatting: 2), all passing (`monkeydo -t`, 43/43 total).
