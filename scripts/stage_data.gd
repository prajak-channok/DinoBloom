extends Resource
class_name StageData

## Static configuration for a playable stage.
## Gameplay code reads this resource instead of knowing stage asset paths.

@export var stage_id: String = ""
@export var display_name: String = ""
@export var background: Texture2D
@export var tile_a: Texture2D
@export var tile_b: Texture2D
## Normalized logical board area inside the ACTUALLY DISPLAYED background (0..1).
## This is stage-specific because the brown playable ground differs by asset.
@export var gameplay_area_normalized: Rect2 = Rect2(0.05, 0.08, 0.90, 0.84)
@export var hp_multiplier: float = 1.0
@export var unlock_after_stage_id: String = ""
