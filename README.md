# Eldoria Chronicles

A 2D platformer built with [Godot 4](https://godotengine.org/). Play as a knight, collect all the coins in the level, and step through the portal to complete the run — as fast as you can.

![Gameplay Video](https://github.com/matejstastny/eldoria-chronicles/raw/main/assets/video/gameplay.mp4)

## Gameplay

- Collect every coin in the level to unlock the portal
- Step through the portal to restart the level and beat your time
- Fall into a killzone and you respawn from scratch
- A jump boost pad temporarily doubles your jump height

## Controls

| Action     | Keyboard        | Gamepad         |
|------------|-----------------|-----------------|
| Move left  | `A` / `←`       | Left stick left |
| Move right | `D` / `→`       | Left stick right|
| Jump       | `Space` / `↑`   | `A` button      |

## Project structure

```
eldoria-chronicles/
├── assets/          # Fonts, icons, music, sounds, sprites, textures
├── scenes/          # Godot scene files (.tscn)
├── scripts/         # GDScript source files (.gd)
├── ui/              # HUD scene
├── tools/           # Build and dev scripts (excluded from Godot import)
│   ├── build-dmg.sh     # Packages the macOS export into a distributable DMG
│   ├── format.sh        # Formats all .gd files (removes semicolons, normalises indentation)
│   └── source/          # Assets used by build-dmg.sh (background image, rcedit)
├── project.godot
└── export_presets.cfg
```

## Export

The project has two export presets configured in `export_presets.cfg`:

| Preset        | Platform         | Output path                       |
|---------------|------------------|-----------------------------------|
| MacOS         | macOS (universal)| `tools/source/eldoria-chronicles-raw.dmg` |
| Windows       | Windows x86-64   | `tools/source/eldoria-chronicles-raw.exe` |

### macOS distributable DMG

After exporting the macOS preset from Godot, run:

```bash
./tools/build-dmg.sh
```

This mounts the raw Godot DMG, extracts the `.app`, and repackages it with a custom background into `tools/build/eldoria-chronicles-1.0.0-mac.dmg`. Requires [`create-dmg`](https://github.com/create-dmg/create-dmg) (the script will offer to install it via Homebrew if missing).

### GDScript formatting

```bash
./tools/format.sh
```

Strips semicolons and converts tabs to 4-space indentation across all `.gd` files. Safe to run from any directory.
