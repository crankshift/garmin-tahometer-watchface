# 01: Project skeleton and sideload

Status: blocked: SDK install needs an interactive Garmin account login in the SdkManager GUI (see "Waiting on user")
Depends on: none
Blocks: every other ticket

## Goal

An empty watch face for the fenix 7 Pro that builds, runs in the Connect IQ simulator, and installs on the real watch.

## Scope

- Install the Connect IQ SDK Manager, the latest SDK, and the `fenix7pro` device profile. The Sapphire Solar has Wi-Fi, so it is `fenix7pro`, not `fenix7pronowifi`.
- Install VS Code with the Monkey C extension and generate a developer key.
- Create a watch face project: manifest type `watchface`, product `fenix7pro`, and a minimum API level that covers what later tickets use (3.3.0 is enough for everything in the design).
- The view clears the screen to black and draws a small debug text so it's obvious the face is running.
- Build a `.prg` and sideload it over USB into `GARMIN/APPS` on the watch. On macOS the fenix 7 connects over MTP, so you need a tool such as OpenMTP.
- Find the watch face memory limit for `fenix7pro` in the SDK's device files (the `compiler.json` in the device folder) and write it down in this ticket. Garmin doesn't publish the number, so it has to come from the SDK.

## Decisions to make here

These are the port questions the design session left open:

- **Source layout.** Suggested: one module or class per glossary term (Tachometer, Gear, Rev Bar, Fuel Gauge, Slots, Readouts), so the code reads like `CONTEXT.md`.
- **Testing.** Suggested: Monkey C `(:test)` unit tests for the pure logic (Fuel Gauge segment rounding, Gear text, next sun event, temperature formatting), plus visual checks in the simulator for drawing.
- **Geometry helpers.** Suggested: port the prototype's `minuteDeg` and `polar` helpers as they are, so constants from the prototype can be copied across.

Record the choices in this ticket. Add an ADR under `docs/adr/` only if a choice is hard to reverse and would surprise a later reader.

## Decisions

- **Source layout.** Went with the suggestion: one module or class per glossary term. This slice adds `source/TachometerWatchFaceApp.mc` (the `Application.AppBase`), `source/TachometerWatchFaceView.mc` (the `WatchUi.WatchFace`), `source/Constants.mc` (screen geometry shared by every module, plus the one theme color that isn't already a `Toybox.Graphics` built-in), `source/Geometry.mc` (`minuteDeg`, `polar`) and `source/Tachometer.mc`. Gear, RevBar, FuelGauge, Slots and Readouts modules are not created yet — tickets 04-08 add them.
- **Testing.** Went with the suggestion: `(:test)` unit tests for pure logic, alongside the module they test (e.g. `source/GeometryTest.mc`, `source/TachometerTest.mc`), run with the SDK's `monkeydo -t` test runner; plus a simulator screenshot for visual checks. No separate test source directory — Connect IQ test functions are ordinary `(:test)`-annotated functions the compiler strips from release builds, so keeping them next to the module they cover (Test suffix) reads better than a parallel tree.
- **Geometry helpers.** Ported `minuteDeg` and `polar` from the prototype as-is, into `Geometry.mc`, so the constants from `prototype/index.html` (`CX`, `CY`, `R`) carry across unchanged (now in `Constants.mc`).
- **Manifest / build.** `minSdkVersion` 3.3.0 as the tickets specify. App type `watchface`, single product `fenix7pro`, `monkey.jungle` uses the default `base.sourcePath = source` / `base.resourcePath = resources` layout so no per-file jungle entries are needed as the project grows.
- **App id.** Generated with `uuidgen`: `F0E8E679-D907-40F3-9A19-6397A3BECF60`. This is a personal-sideload id, not a Connect IQ Store submission id, so it doesn't need to come from the developer portal.
- **Developer key.** Generated with `openssl genrsa` / `openssl pkcs8` (no SDK or Garmin account needed for this part) and kept outside the repo at `~/.garmin/tachometer-watchface/developer_key.der` (`.pem` alongside it). `.gitignore` also blocks `*.der` / `*.pem` / `developer_key.*` as a second layer in case a key is ever generated inside the repo by mistake.
- **Launcher icon.** The manifest requires a `launcherIcon` drawable. No icon design exists yet, so `resources/drawables/launcher_icon.png` is a small generated placeholder (40x40, amber arc + white tick on black, via Pillow) rather than blocking the skeleton on real icon art. Revisit when the face's look is otherwise finished.

## Waiting on user

The Connect IQ SDK itself could not be installed non-interactively:

- The Connect IQ SDK Manager (`connectiq-sdk-manager` Homebrew cask) installs fine without a login — that part is done, see below.
- Downloading an actual SDK version inside the SDK Manager app requires accepting a license and signing in with a Garmin Connect Developer account in its GUI window. This environment has no Screen Recording / Accessibility access to drive that GUI (`screencapture` fails with "could not create image from display"), so it can't be done from here.

What's already done for you:

1. `SdkManager.app` is installed at `/Applications/SdkManager.app` (via `brew install --cask connectiq-sdk-manager`).
2. The developer key exists at `~/.garmin/tachometer-watchface/developer_key.der` — you won't need to generate one.
3. Every project file (manifest, source, resources, fonts, tests) is written and should build as soon as the SDK is present.

What you need to do:

1. Open `/Applications/SdkManager.app`.
2. Accept the license agreement if prompted.
3. Sign in with your Garmin Connect account when asked.
4. In the SDK list, install the latest Connect IQ SDK.
5. In the Devices tab, install the `fenix7pro` device profile (confirm it's the Wi-Fi variant, not `fenix7pronowifi` — the Sapphire Solar has Wi-Fi).
6. Note the SDK install path it reports (normally `~/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-<version>`) and either add its `bin/` to your `PATH` or point VS Code's Monkey C extension at it.
7. Once installed, from the repo root you (or I, in a follow-up session) can run:
   ```
   monkeyc -d fenix7pro -f monkey.jungle -o bin/tachometer.prg -y ~/.garmin/tachometer-watchface/developer_key.der
   monkeydo bin/tachometer.prg fenix7pro
   monkeyc -d fenix7pro -f monkey.jungle -y ~/.garmin/tachometer-watchface/developer_key.der -t -o bin/tachometer-test.prg
   monkeydo bin/tachometer-test.prg fenix7pro -t
   ```
   to build, run in the simulator, and run the unit tests — completing the unticked acceptance items below.
8. For sideloading over USB on macOS: the fenix 7 Pro connects over MTP, so install a tool such as [OpenMTP](https://github.com/ganeshrvel/openmtp), mount the watch, and copy the built `.prg` into `GARMIN/APPS`.
9. The `fenix7pro` memory limit (needed below) is in the SDK's `devices/fenix7pro/compiler.json` once the SDK is installed — I couldn't read it without the SDK.

## Acceptance

- [ ] The project builds without warnings for `fenix7pro`. — blocked: no `monkeyc` available (SDK not installed, see "Waiting on user"). All XML resource files were checked with `xmllint --noout` and are well-formed, which is the only verification possible without the SDK.
- [ ] The face runs in the simulator on the `fenix7pro` profile. — blocked: same reason.
- [ ] After sideloading, the face appears on the watch and can be selected. — blocked: needs a built `.prg` and physical watch access.
- [ ] The memory limit is recorded in this ticket. — blocked: needs the SDK's `compiler.json`, not published anywhere else.
- [x] The source layout and testing approach are recorded in this ticket. — see "Decisions" above.
