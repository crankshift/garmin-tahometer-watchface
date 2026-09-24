# Tachometer Watch Face

A Garmin Connect IQ watch face that reads like a car instrument cluster. The minutes are a tachometer, the hour is the gear, the seconds are a rev bar, and the battery is a fuel gauge.

<p align="center">
  <img src="docs/images/face.png" width="400" alt="The watch face at 10:06: gear 10, the amber sweep just past 0 on the tachometer, steps, date and heart rate in the middle row, weather at the bottom, and the fuel gauge at 8 of 10 segments">
</p>

<p align="center"><sub>10:06, shown at 3× in the <a href="prototype/index.html">HTML prototype</a>. On the watch the numerals are Barlow Condensed, so the digits look slightly different.</sub></p>

Built for the fenix 7 Pro (47mm, 260×260 round MIP display). The same build also targets the other watches with a round MIP screen of 240, 260 or 280 px, and the round AMOLED watches with a screen of 360 to 466 px:

- **260×260 MIP**: fenix 6, fenix 6 Pro, fenix 7, the fenix 7 Pro without Wi-Fi, fenix 8 Solar 47mm, fenix 9 Pro Solar 47mm, Forerunner 255, 255 Music and 955, vívoactive 4, and the Legacy First Avenger and Darth Vader editions.
- **240×240 MIP**: Descent Mk2 S, fenix 5 Plus, 5S Plus and 5X Plus, fenix 6S and 6S Pro, fenix 7S and 7S Pro, Forerunner 245, 245 Music, 745, 945 and 945 LTE, and the MARQ Adventurer, Athlete, Aviator, Captain, Commander, Driver, Expedition and Golfer.
- **280×280 MIP**: Descent Mk2, Enduro, Enduro 3, fenix 6X Pro, fenix 7X, fenix 7X Pro (with and without Wi-Fi), fenix 8 Solar 51mm and fenix 9 Pro Solar 51mm.
- **360×360 AMOLED**: Forerunner 265S and Venu 2S.
- **390×390 AMOLED**: Approach S50 and S70 42mm, Descent G2 and Mk3 43mm, epix Pro (Gen 2) 42mm, Forerunner 165, 165 Music, 170, 170 Music, 570 42mm and 70, Instinct 3 AMOLED 45mm, Instinct Crossover AMOLED, MARQ (Gen 2) and MARQ (Gen 2) Aviator, Venu 3S, Venu 4 41mm, and vívoactive 5 and 6.
- **416×416 AMOLED**: D2 Air X10, D2 Mach 1, epix (Gen 2), epix Pro (Gen 2) 47mm, fenix 8 43mm, fenix 9 43mm, fenix 9 Pro 43mm, fenix E, Forerunner 265, Instinct 3 AMOLED 50mm, Venu 2 and Venu 2 Plus.
- **454×454 AMOLED**: Approach S70 47mm, D2 Mach 2 and Mach 2 Pro, Descent Mk3i 51mm, epix Pro (Gen 2) 51mm, fenix 8 47mm, fenix 8 Pro 47mm, fenix 9 47mm, fenix 9 Pro 47mm, Forerunner 570 47mm, 965 and 970, Venu 3, and Venu 4 45mm.
- **466×466 AMOLED**: fenix 9 Pro 51mm.

`manifest.xml` has the device ids. The fenix 5 Plus watches need firmware with Connect IQ 3.3 or newer, and the build skips the older firmware.

All geometry scales with the screen radius, and the bitmap fonts are generated for every screen size from 240 to 466 px, so adding other round devices is cheap.

## Status

The face runs on a real fenix 7 Pro, and its unit tests pass. Support for more round watches, MIP and AMOLED, is in progress ([spec](docs/specs/multi-device.md)); the AMOLED look has been checked in the simulator only. It isn't in the Connect IQ Store yet, so to use it you build it and sideload it yourself.

## The face

- **Tachometer**: a half-circle scale across the top, numbered 0 to 6. Each unit is ten minutes of the current hour, and minutes 50 to 60 are the red Redline.
- **Minute Style**: the current minute as a Needle, a Sweep (filled arc), or a Sweep + Tip. The default is Sweep + Tip.
- **Gear**: the current hour as a large number inside the Tachometer. It follows the watch's 12/24-hour setting.
- **Rev Bar**: a thin arc that fills across the current minute, one segment per second.
- **Fuel Gauge**: battery level as ten segments at the bottom of the face. The pump icon turns amber at 20% and red at 10%.
- **Slots**: four places (Left, Center, Right and Bottom) that each show one Readout: date, steps, weather, heart rate, Body Battery, sunrise/sunset, notifications, battery %, or nothing.

### On AMOLED watches

The face is the same, with five extras while the watch is awake: anti-aliased text, a gradient on the Redline (dark to bright red across minutes 50 to 60), and a soft Glow behind the Minute Style, the Rev Bar and the Gear.

While the watch sleeps, it shows a dimmed always-on view that lights under 10% of the screen, as Garmin requires: light-grey ticks and numerals, the Gear as an outline, a thin needle for the minute, the Slots with dimmed values, and a thin Fuel Gauge. It has no Rev Bar, because AMOLED watch faces get no partial updates.

The full design is in [`docs/design.md`](docs/design.md), and the vocabulary is in [`CONTEXT.md`](CONTEXT.md).

## Settings

Change these in the Garmin Connect phone app, under the watch face's settings:

| Setting | Options | Default |
|---|---|---|
| Minute Style | Needle, Sweep, Sweep + Tip | Sweep + Tip |
| Always-on Rev Bar (MIP only) | on, off | off |
| Left / Center / Right / Bottom Slot | any Readout | Steps / Date / Heart rate / Weather |
| Weather temperature | Feels like, Actual | Feels like |

The watch's system settings control the 12/24-hour format and units.

## Building

You need:

- The [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/), installed through the SDK Manager, with the `fenix7pro` device profile.
- A Java runtime, which `monkeyc` needs (for example `brew install openjdk`).
- A developer key. You can generate one with OpenSSL:

  ```sh
  openssl genrsa -out developer_key.pem 4096
  openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt
  ```

  Keep the key outside the repo. `.gitignore` blocks `*.der` and `*.pem` in case one ends up inside it.

Put the SDK's `bin/` directory on your `PATH`, then run these from the repo root:

```sh
# Build and run in the simulator
monkeyc -d fenix7pro -f monkey.jungle -o bin/tachometer.prg -y /path/to/developer_key.der
monkeydo bin/tachometer.prg fenix7pro

# Run the unit tests
monkeyc -d fenix7pro -f monkey.jungle -o bin/tachometer-test.prg -y /path/to/developer_key.der -t
monkeydo bin/tachometer-test.prg fenix7pro -t
```

The Monkey C extension for VS Code works too.

### Sideloading

Connect the watch over USB and copy `bin/tachometer.prg` into `GARMIN/APPS`. On macOS the fenix 7 connects over MTP, so you'll need a tool such as [OpenMTP](https://github.com/ganeshrvel/openmtp).

The app id in `manifest.xml` is fine for sideloading. If you publish your own build to the Connect IQ Store, give it a new id.

## Project layout

```
source/             Monkey C code, one module per part of the face (Tachometer.mc, Gear.mc, ...)
                    Unit tests sit next to their module (*Test.mc)
resources/          Settings, strings, drawables and the generated bitmap fonts (the 260 px set)
resources-round-*/  The bitmap fonts for the other screen sizes, and the AMOLED launcher icon, picked by the build per watch
assets/fonts/       Source TTF for the bitmap fonts
tools/              gen_bitmap_font.py, which regenerates every font set from assets/fonts,
                    and gen_launcher_icon.py, which draws the 70 px launcher icon of the AMOLED watches
prototype/          HTML prototype of the face, used as the geometry reference for the port
docs/               Design notes and the implementation tickets
```

To regenerate the bitmap fonts after changing sizes or glyphs, install Pillow (`pip install Pillow`) and run `tools/gen_bitmap_font.py`. It writes one set per screen size: the 260 px set to `resources/fonts/`, and the others to `resources-round-WxH/fonts/`.

## License

The code is under the [MIT License](LICENSE).

The numeral font is [Barlow Condensed](https://github.com/jpt/barlow) Bold, under the [SIL Open Font License 1.1](assets/fonts/OFL.txt). The OFL also covers the bitmap fonts in `resources/fonts/` and `resources-round-*/fonts/`, which are generated from it.
