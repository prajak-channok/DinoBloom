# M3 Godot 4.7 Integration Fix

## Scope

This build keeps the current M3 vertical-slice gameplay and fixes the Data/Scene integration issues without adding M4 systems.

## Implemented

- One active gameplay scene: `res://scenes/gameplay_scene.tscn`
- Gameplay scene uses `res://scripts/m3_gameplay_scene.gd`
- Stage 1, 2 and 3 are playable stage configurations.
- Removed the obsolete `StageData.is_story` field.
- `StageData` now owns:
  - background
  - checkerboard tile A/B
  - normalized gameplay area
  - HP multiplier
  - unlock requirement
- M3 reads StageData instead of hard-coding stage asset paths.
- Stage 3 uses `FieldBG3.png` and Stage 1 checkerboard tiles.
- Full-screen UI layout remains:
  - left Plant Panel
  - top status bar
  - remaining area is the Play Area
- Plant cost remains on each Plant Card.
- Placement cooldown is implemented per Plant and shown on the card.
- Insufficient Seed does not disable the card; clicking it shows the existing insufficient-seed status.
- Plant placement remains 5x8 and 1 Plant = 1 Cell.
- Dryosaurus and Velociraptor use `DinosaurData`.
- Dryosaurus and Velociraptor have `walk` and `eat` animations.
- Dryosaurus walk animation now contains all 6 sprite-sheet frames.
- Dinosaur eat animation access is null-safe.
- Thorn Fern only targets enemy dinosaurs in front of it on the same lane.
- Test spawn remains Dryosaurus + Velociraptor on separate lanes.
- No `.godot` cache is included in the ZIP; Godot 4.7 should regenerate editor/import cache.

## Static verification performed

- All `res://` references found in `.gd`, `.tscn`, and `.tres` files resolve to existing project files.
- No duplicate `class_name` declarations were found.
- Stage resources contain no obsolete `is_story` property.
- `gameplay_scene.tscn` points to the M3 gameplay script.
- Both dinosaur scenes contain `walk` and `eat` SpriteFrames animations.
- Both dinosaur scenes contain 6 frames for each animation.
- No `.godot` cache is shipped.

## Godot 4.7 compatibility review

The project is configured with `config/features=PackedStringArray("4.7", "GL Compatibility")`.

The following APIs/syntax used by this build are supported by Godot 4.x/4.7:
- `class_name`
- `extends Resource`
- typed `@export` Resource properties
- `preload()`
- `AnimatedSprite2D.animation`
- `AnimatedSprite2D.is_playing()`
- `AnimatedSprite2D.play()`
- `TextureRect` stretch mode `5` (`STRETCH_KEEP_ASPECT_CENTERED`)
- `Button.disabled`
- `StyleBoxFlat`
- `Vector2i`
- `Rect2`

A Godot executable is not available in the build environment, so this is a static compatibility/structure check, not a successful runtime launch test.

## Known intentional scope

WaveController, SpawnController, Win/Lose, DNA rewards, Pause, 2x simulation, Surrender, advanced Plants/Dinosaurs, Armor, Ginko conversion, Trap, Boss and Persistent Progress are not added here because they belong to later milestones.
