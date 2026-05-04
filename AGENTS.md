# AGENTS.md

## Scope
- This is a minimal ZMK user-config repo. Most changes belong in `build.yaml`, `config/corne.conf`, or `config/corne.keymap`.
- Verification is firmware build only; the repo has no repo-local test/lint/typecheck/formatter or task-runner config.

## Build Truth
- `.github/workflows/build.yml` delegates to `zmkfirmware/zmk/.github/workflows/build-user-config.yml@v0.3`. Change `build.yaml`, not the workflow file, when you need different firmware outputs.
- `config/west.yml` pins `zmk` to `revision: v0.3`, which follows the latest patch release within the v0.3 minor line.
- On `v0.3`, this repo uses the stable board ID `nice_nano_v2` for nice!nano v2 targets. The versioned ZMK board ID `nice_nano@2.0.0//zmk` applies to newer ZMK versions, not this pinned release.
- `build.yaml` is the source of truth for active targets. The repo currently builds:
- left: `nice_nano_v2` + `corne_left nice_view_adapter nice_view` + `studio-rpc-usb-uart`
- right: `nice_nano_v2` + `corne_right nice_view_adapter nice_view`
- In `build.yaml`, `shield:` is one space-delimited string consumed by `-DSHIELD="..."`; do not convert it to a YAML list.
- `config/corne.conf` enables `CONFIG_ZMK_STUDIO=y`, but only the left target adds the `studio-rpc-usb-uart` snippet. Keep both files aligned when changing Studio support.
- `zephyr/module.yml` is required. It makes the repo load as an extra Zephyr module with `board_root: .`; removing it breaks manual/CI builds that rely on `-DZMK_EXTRA_MODULES=<repo-root>`.

## Local Build
- Do not run `west init` in the repo root unless you want `zmk/`, `zephyr/`, `modules/`, and related workspace state created inside this repo. CI avoids that by copying `config/` into a temporary workspace first.
- CI-style local repro after installing the ZMK/Zephyr toolchain:

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

- Quote `-DSHIELD="..."`; both shield values contain spaces.

## Keymap
- `config/corne.keymap` layer constants are `BASE=0`, `SYMBOLS=1`, `MISC=2`, `FUNCTIONS=3`, `LOL=4`.
- The `SYMBOLS` constant points to the node named `numpad`; search by `SYMBOLS` or `&mo SYMBOLS`, not for a `symbols {}` node.
- `FUNCTIONS` is a conditional tri-layer enabled by `SYMBOLS + MISC`.
- `hml` and `hmr` are the timeless HRM behaviors used on `S`, `D`, `G`, `H`, `L`, and `'`. `Z` intentionally stays `&ht LCTRL Z`, and `/` intentionally stays `&mt RCTRL SLASH`, to preserve same-hand Ctrl shortcuts.
- `KEYS_L`, `KEYS_R`, and `THUMBS` drive the positional HRM logic, and the combo `key-positions` assume the current 42-key ordering. If you move alpha or thumb bindings, update those positions too.
- The `combos` block is `layers = <BASE>` only; brace/paren/ampersand/underscore combos do not fire on `LOL` unless you extend them intentionally.
- Custom behaviors `ht`, `hml`, `hmr`, and `captap` are defined inline near the top of `config/corne.keymap`; update those definitions in place instead of replacing them with guessed stock behavior names.
- Pointing support is intentional: `config/corne.conf` enables `CONFIG_ZMK_POINTING*`, and the `functions` layer uses `&mmv`, `&msc`, and `&mkp` bindings.
