# DinoBloom — Milestone 2 Extension: Thorn Fern Visual Foundation

## Purpose
This extension keeps Milestone 2's gameplay foundation intact while adding the reusable Thorn Fern visual/animation asset needed before the M3 combat slice.

## Corrected asset interpretation
The supplied `SPThornFern.png` sprite sheet is **attack animation only**.

- `assets/Plants/SPThornFern.png` is 1536×1024 and is treated as a 3×2 sprite sheet with 512×512 frames.
- All six frames belong to the Thorn Fern attack animation.
- There is no idle animation in this sprite sheet.
- Idle uses the separate `assets/Plants/ThornFernNBG.png` artwork.

## Idle
Idle uses the dedicated Thorn Fern normal artwork (`ThornFernNBG.png`) and a code-driven visual bounce:
- vertical bob
- very small squash/stretch
- very small tilt

The animation is applied to the `Visual` child only. The `ThornFern` root remains the gameplay anchor, so future grid placement and collision are not displaced by the idle motion.

## Attack
`attack` uses all six frames from `SPThornFern.png`, in sheet order:

```text
Frame 0 | Frame 1 | Frame 2
Frame 3 | Frame 4 | Frame 5
```

The six frames are played at 7.5 FPS and return to the dedicated idle artwork after the animation completes.

`play_attack()` only controls the visual animation. Targeting, damage, projectile spawning, cooldowns, and combat rules remain M3 responsibilities.

## Added/updated files
- `assets/Plants/SPThornFern.png`
- `assets/Plants/ThornFernNBG.png`
- `scripts/thorn_fern.gd`
- `scenes/plants/thorn_fern.tscn`
- `scripts/thorn_fern_animation_test.gd`
- `scenes/plants/thorn_fern_animation_test.tscn`

The animation test scene is a development-only preview and is not connected to the normal gameplay scene.
