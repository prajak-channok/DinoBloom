# DinoBloom — Milestone 2 (Revised: Real Field Assets)

## Scope

Milestone 2 now uses the actual Stage 1/2 field assets and keeps gameplay coordinates separate from the background image.

### Locked requirements

- Stage 1 → `FieldBG1.png`
- Stage 2 → `FieldBG2.png` (renamed from the supplied `FiledBG2.png`)
- Stage 3 → placeholder / no gameplay background yet
- All field backgrounds are 1402 × 1122 px.
- Background is displayed as a full image with no crop.
- Gameplay area is a separate 5 × 8 board layer.
- Tile A/B are checkerboard presentation tiles only; they have no different gameplay meaning.
- Stage 1 and Stage 2 may have different board pixel dimensions while remaining logically 5 × 8.
- Debug Grid is OFF by default and can be toggled with F3.
- Grid coordinates are separate from background pixels / UI pixels.
- Plants will occupy one logical grid cell when placement is implemented.
- Dinosaur movement will use world positions; grid coordinates are reserved for placement/gameplay rules.

## Implemented in this checkpoint

- Stage 1/2 background switching through `GameManager.selected_stage_id`.
- Full-image background layer.
- Stage-specific 5 × 8 checkerboard visual layer.
- Stage-specific normalized gameplay-area definitions.
- Logical `world_to_grid()` / `grid_to_world()` conversion.
- Debug grid rendering.
- Mouse hover debug row/column readout.
- Stage Select now starts the selected stage instead of the old placeholder.

## Not implemented yet

- Plant placement/removal.
- Ancient Seed economy.
- Seed Bloom production.
- Dinosaur spawning/movement/combat.
- Projectile combat.
- Wave system.
- Win/Lose/Abandon.
- Pause / 2× simulation.
- Full Plant/Dinosaur data resources.

This remains a Gameplay Foundation milestone, not the full combat vertical slice.
