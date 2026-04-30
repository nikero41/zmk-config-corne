# ZMK Corne Config

Personal ZMK user-config repo for a wireless Corne built with `nice_nano_v2` controllers and `nice_view` displays.

## Hardware Targets

- Board: `nice_nano_v2`
- Left shield: `corne_left nice_view_adapter nice_view`
- Right shield: `corne_right nice_view_adapter nice_view`
- ZMK Studio over USB is enabled on the left build via the `studio-rpc-usb-uart` snippet.

## Features

- 5 layers: `BASE`, `SYMBOLS`, `MISC`, `FUNCTIONS`, and `LOL`
- Timeless home row mods on `S`, `D`, `G`, `H`, `L`, and `'`
- `Ctrl` mod-taps kept on `Z` and `/` for easier same-hand shortcuts
- `Caps Word` on tap and `Caps Lock` on double-tap via the right thumb `captap`
- Base-layer symbol combos for braces, parentheses, ampersand, and underscore
- Left-hand symbols with right-hand numpad on the `SYMBOLS` layer
- Bluetooth profile controls, output switching, media keys, arrows, and mouse keys
- Battery reporting, pointing support, smooth scrolling, split battery fetching, and ZMK Studio support
- Nice!View display targets for both halves

## Layer Summary

| Layer | Purpose |
| --- | --- |
| `BASE` | Main typing layer with timeless home row mods |
| `SYMBOLS` | Left-hand symbols and right-hand numpad |
| `MISC` | Bluetooth controls, output toggle, media, and arrows |
| `FUNCTIONS` | Mouse movement, scrolling, clicks, and function keys |
| `LOL` | Toggle layer with left-hand number row and preserved right-hand mods |

`FUNCTIONS` is a tri-layer that activates when `SYMBOLS` and `MISC` are both active.

## Base-Layer Combos

- `E + D` -> `{`
- `R + F` -> `}`
- `D + C` -> `(`
- `F + V` -> `)`
- `H + N` or `E + R` -> `&`
- `H + J` or `M + ,` -> `_`

## Repository Layout

- `build.yaml`: active firmware targets for CI builds
- `config/corne.conf`: Kconfig options such as BLE, battery, pointing, split, and Studio
- `config/corne.keymap`: layers, behaviors, combos, and bindings
- `config/west.yml`: upstream ZMK manifest, currently tracking `main`
- `zephyr/module.yml`: makes this repo load as an extra Zephyr module during builds

## Building Firmware

### GitHub Actions

This repo uses the upstream reusable workflow in `.github/workflows/build.yml`.

- Push to the repo
- Open a pull request
- Or run the workflow manually with `workflow_dispatch`

The workflow builds both halves and uploads the firmware artifacts.

### Local Build

This repo does not vendor the ZMK/Zephyr toolchain. Install the toolchain first, then build in a temporary workspace so you do not create a full `west` workspace inside the repo root.

```sh
REPO=/path/to/zmk-config-corne
tmpdir="$(mktemp -d)"
mkdir -p "$tmpdir/config"
cp -R "$REPO/config/." "$tmpdir/config/"

# Run the remaining commands with workdir=$tmpdir
west init -l config
west update --fetch-opt=--filter=tree:0
west zephyr-export
west build -s zmk/app -d build-left -b nice_nano_v2 -S studio-rpc-usb-uart -- -DZMK_CONFIG="$tmpdir/config" -DSHIELD="corne_left nice_view_adapter nice_view" -DZMK_EXTRA_MODULES="$REPO"
west build -s zmk/app -d build-right -b nice_nano_v2 -- -DZMK_CONFIG="$tmpdir/config" -DSHIELD="corne_right nice_view_adapter nice_view" -DZMK_EXTRA_MODULES="$REPO"
```

Notes:

- `config/west.yml` tracks ZMK `main`, so a new build failure can be caused by upstream changes.
- `zephyr/module.yml` and `-DZMK_EXTRA_MODULES="$REPO"` are required so the repo is loaded as an extra Zephyr module.
- Quote `-DSHIELD="..."` because the shield values contain spaces.

## Flashing

- Flash the left UF2 to the left `nice_nano_v2`
- Flash the right UF2 to the right `nice_nano_v2`
- Use the left build if you want ZMK Studio over USB

## Customization

- Edit `config/corne.keymap` to change layers, home row mods, combos, or thumb keys
- Edit `config/corne.conf` to change BLE, power, pointing, or Studio settings
- Edit `build.yaml` if you change boards, shields, or snippets

If you change Studio support, keep `build.yaml` and `config/corne.conf` aligned: the config enables Studio globally, while the left build currently adds the USB RPC snippet.
