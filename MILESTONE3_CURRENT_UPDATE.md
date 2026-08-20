# DinoBloom — Current Milestone 3 Update

## Changes

- Dryosaurus now uses `SPDryosaurusWalk.png` and `SPDryosaurusEat.png` as 6-frame sprite-sheet animations.
- No idle animation is used.
- Walk animation loops while moving.
- Eat animation loops while stopped at a Plant.
- Dryosaurus target detection is based on the Plant interaction cell, not the Plant center. This prevents the previous stop-at-edge -> target-lost -> walk-again warp behavior.
- Dryosaurus gameplay root represents its foot/contact anchor. Visual sprite is offset upward.
- Dryosaurus stops at the right edge of the occupied Plant grid cell and applies damage while eating.
- Thorn Fern visual scales were reduced so the Plant stays within one logical cell.
- Gameplay background fills the entire viewport.
- Gameplay UI now uses a full-height left Plant Panel and a full-width top status/action bar.
- Remaining area is treated as the Play Area and contains the 5x8 board.
- Plant cards now show Plant name and Seed cost inside the card.
- `GameManager` now enters `scenes/gameplay_scene.tscn`, which is the current playable vertical slice.

## Test Controls

- `F3` — toggle Debug Grid
- `F6` — spawn the Dryosaurus + Velociraptor test enemies on separate lanes
- `SPAWN TEST` — same two-enemy test spawn from the top bar

## Velociraptor test data

- Base HP: 150
- ATK: 10
- Attack Interval: 1 second
- Speed: 80 px/s
- Walk and Eat use the provided 3x2 sprite sheets; no Idle animation is used.

## Deliberate scope

Pause, 2x Speed, Abandon, Wave Flow, and persistent rewards are UI/architecture placeholders at this stage and are not implemented as complete systems here. They should later connect to the central gameplay controllers defined by the Architecture Context.
