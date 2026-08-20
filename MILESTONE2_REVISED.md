# DinoBloom — Milestone 2 Revised

## Scope
Milestone 2 establishes the Stage field foundation: background presentation, 5×8 logical board, stage-specific checkerboard tiles, coordinate conversion, and debug alignment. Combat, spawning, economy, plant placement, waves, win/lose, and advanced abilities remain outside this milestone.

## Corrections
- Added `FieldBG3.png` as the Stage 3 background asset.
- Stage 3 uses the same checkerboard tiles as Stage 1.
- Backgrounds use aspect-preserved centered display; they are not cropped.
- Board coordinates are calculated inside the displayed background image rather than directly against the viewport.
- Logical board remains exactly 5 rows × 8 columns.
- Checkerboard rendering is presentation-only; the logical board is independent.
- Tile rebuilding removes previous nodes immediately to prevent duplicate tile nodes during setup/reconfiguration.
- F3 toggles the debug grid and its debug panel.

## Asset mapping
- Stage 1 → `FieldBG1.png` + `TileField1A.png` / `TileField1B.png`
- Stage 2 → `FieldBG2.png` + `TileField2A.png` / `TileField2B.png`
- Stage 3 → `FieldBG3.png` + Stage 1 tile pair

## Alignment principle
The artwork is not expected to contain a machine-readable grid. Godot creates the 5×8 logical grid independently and places it over the visually identified gameplay area using per-stage normalized calibration values. The calibration values are editable data and are expected to be visually verified in the Godot editor.

## Background rule
The complete source image must remain visible. The game must never use a cover/crop mode to make the image fill the viewport. If the aspect ratios differ, the image is fitted proportionally and centered.

## Stage 3 note
The supplied Stage 3 image is now included. Its use as a gameplay background does not by itself change the previously agreed story/gameplay status of Tree of Evolution; Stage 3 story/playability rules remain controlled by the Stage design and later gameplay milestones.
