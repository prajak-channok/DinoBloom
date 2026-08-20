# Milestone 3 Cleanup Implementation

Implemented from the current DinoBloom requirements and Architecture Context.

## Visual
- Thorn Fern Idle uses the user-requested slow bounce pattern.
- Idle uses `ThornFernNBG.png`; the full 6-frame `SPThornFern.png` sheet remains Attack only.
- Artist-authored Idle/Attack child scales are preserved. The common Visual anchor scales proportionally to the logical Grid cell instead of overwriting the tuned child scales.
- Idle animation only moves/scales the Visual anchor; the Plant root remains the gameplay/grid anchor.

## Data
- Added `PlantData` Resource for Seed Bloom and Thorn Fern.
- Added `DinosaurData` Resource for Dryosaurus.
- Runtime entities read base stats from Resources rather than hard-coding balance values.

## Grid / Collision
- Plants receive an interaction Area sized to their logical 1-Grid footprint.
- Dryosaurus stops when its body reaches the Plant interaction Area, rather than using a fixed magic attack range.
- Plant/Dinosaur targeting still uses Lane coordinate (`grid_row`) separate from world position.

## Combat
- Thorn Fern targets the nearest valid enemy in its Lane.
- Projectile remains a separate runtime entity and applies damage on path collision.
- Dryosaurus attacks every 1 second from `DinosaurData` and resumes movement immediately after the Plant is removed.

## Remaining test
Run the M3 scene in Godot and verify: Plant visual scale across Stage 1/2/3, slow Idle bounce, Attack transition, Dryosaurus physical approach/stop, Projectile hit, Plant death, and Dryosaurus continuation.
