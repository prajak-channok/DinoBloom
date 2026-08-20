# DinoBloom M3 — Responsive Gameplay Architecture

## Final layout contract

The gameplay screen uses one logical design canvas and one independent gameplay field:

- Logical canvas: **1500 × 844**
- Play Area: **1280 × 720 (16:9)**
- Left Plant UI: **220 px** outside Play Area
- Top UI: **124 px** outside Play Area

Therefore:

`220 + 1280 = 1500`

`124 + 720 = 844`

The Play Area never shrinks because of UI. UI is an outer shell around the game field.

## Coordinate spaces

### 1. Logical Canvas

All UI and gameplay are designed in the 1500 × 844 logical space.

Godot Project Settings use:

- viewport = 1500 × 844
- stretch mode = canvas_items
- stretch aspect = keep
- window mode = fullscreen

On a different monitor resolution, Godot scales the complete logical canvas uniformly. Non-16:9 monitors may show letterbox bars; the game's internal proportions remain unchanged.

### 2. Play Area

`PlayArea` is always 1280 × 720 and starts at `(220, 124)` in logical canvas space.

Gameplay entities use **PlayArea-local coordinates** only.

This prevents UI offsets from leaking into gameplay calculations.

### 3. Background

Background is a TextureRect that fills the complete 1280 × 720 Play Area.

The intended production background asset is 16:9, e.g. 2560 × 1440. A 16:9 source therefore fills the Play Area without crop or distortion.

Current ZIP assets are not all 16:9. They are stretched to the Play Area intentionally so the field has no empty area. The runtime emits a warning for non-16:9 assets. Replace those assets with the final 16:9 versions to remove visual distortion.

### 4. Board / Gameplay Area

The 5 × 8 board is **not** the full Play Area.

Each StageData resource stores `gameplay_area_normalized`, which identifies the actual brown playable ground inside the background image.

Board calculation:

`BoardRect = BackgroundRect.position + NormalizedRect.position * BackgroundRect.size`

`BoardSize = NormalizedRect.size * BackgroundRect.size`

This means:

- Stage 1 can have a different brown-area size from Stage 2.
- Stage 3 can have its own playable area.
- The board never extends into decoration/path areas.
- Grid logic remains 5 × 8 regardless of visual size.

## Scene hierarchy

```text
M3GameplayScene
├── PlayArea (1280 × 720, clip_contents)
│   ├── Base
│   ├── Background
│   └── World
│       ├── BoardVisual
│       ├── Board
│       ├── PlacementPreview
│       ├── Plants
│       ├── Dinosaurs
│       └── Projectiles
│
├── UI (CanvasLayer)
│   ├── PlantPanel (220 × 720, below TopBar)
│   └── TopBar (1500 × 124)
│
└── DebugOverlay
```

## Why this architecture is used

1. UI can be redesigned without moving the gameplay field.
2. Background, grid, plants, dinosaurs and projectiles share one gameplay coordinate space.
3. Fullscreen resolution changes scale the complete logical canvas rather than recalculating gameplay positions from monitor pixels.
4. Stage-specific brown gameplay regions remain data-driven.
5. The 5 × 8 board is independent from the raw asset resolution.
6. Debug Grid remains a presentation/debug layer and does not become part of the background asset.

## Important asset constraint

It is mathematically impossible to simultaneously:

- preserve a non-16:9 source image's original aspect ratio,
- show the entire image without crop,
- and fill a fixed 16:9 Play Area.

The production contract therefore expects the gameplay backgrounds to be 16:9. The current project files contain legacy backgrounds with different aspect ratios, so they are stretched until the final 16:9 assets are supplied.
