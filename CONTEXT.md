# Tachometer Watch Face

A Garmin watch face that reads like a car instrument cluster: minutes shown on a tachometer, the hour as the gear, and battery as fuel.

## Language

### Time

**Tachometer**:
A half-circle minute scale numbered 0 to 6, where each unit is ten minutes of the current hour.
_Avoid_: dial, clock, rev counter

**Minute Style**:
The user's choice of how the current minute is drawn on the Tachometer: Needle, Sweep, or Sweep + Tip.

**Needle**:
A short pointer on the outer part of the Tachometer that marks the current minute. It has no center hub, so it never crosses the Gear.

**Sweep**:
A filled arc on the Tachometer from 0 to the current minute.

**Tip**:
A short line across the scale that marks the end of the Sweep.

**Redline**:
The red zone at the end of the Tachometer, covering minutes 50 to 60.

**Gear**:
The current hour, shown as a large number inside the Tachometer. The Gear shifts up each time the Tachometer passes 6 and restarts at 0.
_Avoid_: hour digit

**Rev Bar**:
The analog seconds indicator: a thin arc that fills across the current minute.
_Avoid_: seconds hand

**Glow**:
A soft halo behind the Minute Style, the Rev Bar and the Gear. Only AMOLED watches draw it.
_Avoid_: shadow, bloom

**Always-on View**:
The dimmed face an AMOLED watch shows while it sleeps. It has the major ticks and numerals, the Gear as an outline, a thin needle, the Slots and a thin Fuel Gauge, and no Rev Bar.
_Avoid_: sleep face, AOD

### Battery

**Fuel Gauge**:
The battery level indicator, styled as a car fuel gauge.
_Avoid_: fuel meter, battery meter

**Low-Fuel Lamp**:
The warning light that comes on when battery is low.

### Customization

**Slot**:
A place on the face where the user chooses which data appears. There are four: Center, Left, Right and Bottom.
_Avoid_: field, position

**Center Slot**:
The Slot in the middle of the face, just below the Gear, between the Left and Right Slots.
_Avoid_: Top Slot

**Readout**:
A kind of data a Slot can show, such as steps, weather or date.
_Avoid_: field, complication (Garmin uses "complication" for a specific platform feature)
