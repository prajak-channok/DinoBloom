# DinoBloom — Milestone 3 Vertical Slice

## Goal
Make the first playable combat loop work using the existing Milestone 2 board and the user's finalized Thorn Fern visual setup.

## Included
- 5x8 Grid placement
- Plant selection cards for Seed Bloom and Thorn Fern
- Ancient Seed starts at 100 and caps at 1000
- Seed Bloom cost 50, HP 50, produces +50 Ancient Seed every 5 seconds
- Thorn Fern cost 100, HP 75, ATK 25, attack interval 2 seconds
- Thorn Fern uses the user's current M2 scene/visual setup, including all six attack frames
- Dryosaurus ColorRect placeholder: 200 HP, 10 ATK, 1 second attack interval, 50 px/s
- Dryosaurus stops at a Plant, attacks it, and resumes movement when the Plant is removed
- Thorn Fern targets the nearest enemy in its lane
- Thorn Projectile moves in a straight line and applies damage on contact
- Development Spawn button / F6 for Dryosaurus; the first enemy also auto-spawns after a short setup window

## Intentionally not included yet
- Full Wave system
- Lose/Win popup
- Pause / 2x speed
- DNA
- Upgrade / unlock
- Save integration
- Other Plants / Dinosaurs
- Full combat VFX

## Important visual rule
The current Thorn Fern idle/attack setup from the user-provided M2 test project is preserved. The six frames in SPThornFern.png are all attack frames. ThornFernNBG.png is the idle artwork. The user's current scale/position tuning is not overwritten.

## Test scene
Run:
`scenes/m3_gameplay_scene.tscn`

Use:
1. Click a Plant card.
2. Click a Grid cell to place it.
3. Seed Bloom produces Seed every 5 seconds.
4. Place Thorn Fern.
5. Wait for Dryosaurus or press F6 / Spawn Dryosaurus.
6. Observe Plant targeting, Thorn attack animation, projectile, damage, Plant death, enemy continuation, and enemy death.

## Balance source
Values are taken from DinoBloom Game Logic & Design Specification v0.1 only where they are required by the current M3 requirement. Balance v0.1 remains subject to playtest.


## Gameplay fixes
- Dryosaurus spawns outside the board and walks into the field instead of appearing on the board edge.
- Dryosaurus only targets plants ahead in the same lane and starts attacking only when its body reaches the plant's grid area.
- Plant visuals are scaled from the current Grid cell size, while the Plant root remains anchored at the cell center.
- Thorn Fern preserves the authored Idle/Attack proportions while fitting both states to the same visible height.
