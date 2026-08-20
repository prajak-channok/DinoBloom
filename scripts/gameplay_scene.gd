extends Node2D
## Milestone 2: background + 5x8 board foundation.
## Combat, spawning, economy and plant placement are intentionally not implemented.

# Normalized coordinates are relative to the displayed, aspect-preserved background image,
# not the whole viewport. This keeps the logical board aligned when the window changes size.
const BOARD_NORMALIZED := {
	"stage_01": Rect2(0.114, 0.155, 0.754, 0.723),
	"stage_02": Rect2(0.114, 0.151, 0.754, 0.727),
	"stage_03": Rect2(0.214, 0.145, 0.620, 0.710)
}

const STAGE_ASSETS := {
	"stage_01": {
		"background": "res://assets/BackGround/FieldBG1.png",
		"tile_a": "res://assets/BackGround/TileField1A.png",
		"tile_b": "res://assets/BackGround/TileField1B.png"
	},
	"stage_02": {
		"background": "res://assets/BackGround/FieldBG2.png",
		"tile_a": "res://assets/BackGround/TileField2A.png",
		"tile_b": "res://assets/BackGround/TileField2B.png"
	},
	"stage_03": {
		"background": "res://assets/BackGround/FieldBG3.png",
		"tile_a": "res://assets/BackGround/TileField1A.png",
		"tile_b": "res://assets/BackGround/TileField1B.png"
	}
}

@onready var background: TextureRect = $BackgroundLayer/Background
@onready var placeholder: ColorRect = $BackgroundLayer/Stage3Placeholder
@onready var board_visual: StageBoardVisual = $BoardVisual
@onready var board: StageBoard = $Board
@onready var debug_label: Label = $DebugOverlay/DebugLabel
@onready var debug_panel: PanelContainer = $DebugOverlay/Panel

var selected_stage_id: String = "stage_01"
var debug_grid_enabled: bool = false

func _ready() -> void:
	selected_stage_id = GameManager.selected_stage_id
	_apply_stage(selected_stage_id)
	_update_debug_label()

func _apply_stage(stage_id: String) -> void:
	var assets: Dictionary = STAGE_ASSETS.get(stage_id, {})
	if assets.is_empty():
		background.texture = null
		placeholder.visible = true
		board_visual.setup(Rect2(), null, null)
		board.configure(Rect2(), debug_grid_enabled)
		return

	placeholder.visible = false
	var bg: Texture2D = load(assets["background"])
	var tile_a: Texture2D = load(assets["tile_a"])
	var tile_b: Texture2D = load(assets["tile_b"])
	background.texture = bg

	var displayed_background := _get_displayed_background_rect(bg)
	var normalized: Rect2 = BOARD_NORMALIZED.get(stage_id, BOARD_NORMALIZED["stage_01"])
	var board_rect := Rect2(
		displayed_background.position + normalized.position * displayed_background.size,
		normalized.size * displayed_background.size
	)

	board_visual.setup(board_rect, tile_a, tile_b)
	board.configure(board_rect, debug_grid_enabled)

func _get_displayed_background_rect(texture: Texture2D) -> Rect2:
	if texture == null:
		return Rect2()
	var viewport_size := get_viewport_rect().size
	var source_size := texture.get_size()
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		return Rect2()
	var scale := minf(viewport_size.x / source_size.x, viewport_size.y / source_size.y)
	var displayed_size := source_size * scale
	return Rect2((viewport_size - displayed_size) * 0.5, displayed_size)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		debug_grid_enabled = not debug_grid_enabled
		board.configure(board.board_rect, debug_grid_enabled)
		_update_debug_label()

	if event is InputEventMouseMotion:
		var grid := board.world_to_grid(event.position)
		if grid.x >= 0:
			debug_label.text = "Grid Debug: %s | Row %d | Column %d" % [
				"ON" if debug_grid_enabled else "OFF",
				grid.x,
				grid.y
			]

func _update_debug_label() -> void:
	debug_label.visible = debug_grid_enabled
	debug_panel.visible = debug_grid_enabled
	debug_label.text = "Grid Debug: ON | F3 = Toggle"
