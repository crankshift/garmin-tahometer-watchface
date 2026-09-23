# 08: Remaining Readouts

Status: open
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

## Acceptance

- [ ] With feels-like 15 °C and actual 18 °C, the Readout shows `15°` by default and `18°` with the setting on Actual. In Fahrenheit, Actual shows `64°`.
- [ ] No weather data shows a grey cloud and `--`.
- [ ] At 08:24 the sun Readout shows the sunset time with a down arrow. At 21:00 it shows tomorrow's sunrise.
- [ ] Zero notifications shows a dimmed bell and `0`.
- [ ] Unit tests cover the next-sun-event choice and temperature formatting, if ticket 01 chose unit tests.
