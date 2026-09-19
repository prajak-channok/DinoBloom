extends Node2D
class_name StageBoardVisual
## Presentation-only checkerboard layer. It does not own gameplay rules.

const ROWS: int = 5
const COLUMNS: int = 8

var board_rect: Rect2 = Rect2()
var tile_a: Texture2D
var tile_b: Texture2D

func setup(rect: Rect2, texture_a: Texture2D, texture_b: Texture2D) -> void:
	board_rect = rect
	tile_a = texture_a
	tile_b = texture_b
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		child.free()

	if tile_a == null or tile_b == null:
		queue_redraw()
		return

	var cell_size := Vector2(board_rect.size.x / COLUMNS, board_rect.size.y / ROWS)
	for row in range(ROWS):
		for column in range(COLUMNS):
			var rect := Rect2(
				board_rect.position + Vector2(column * cell_size.x, row * cell_size.y),
				cell_size
			)
			var tile := TextureRect.new()
			tile.name = "Tile_%d_%d" % [row, column]
			tile.position = rect.position
			tile.size = rect.size
			tile.texture = tile_a if (row + column) % 2 == 0 else tile_b
			tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tile.stretch_mode = TextureRect.STRETCH_SCALE
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(tile)
