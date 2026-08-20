extends Node2D
class_name StageBoard
## Logical 5x8 board. World positions are independent from the background asset.

const ROWS: int = 5
const COLUMNS: int = 8

@export var board_rect: Rect2 = Rect2(0, 0, 960, 520)
@export var show_debug_grid: bool = false

var cells: Array[Node2D] = []
var _cell_size: Vector2 = Vector2.ZERO

func _ready() -> void:
	_rebuild()

func configure(rect: Rect2, debug_enabled: bool) -> void:
	board_rect = rect
	show_debug_grid = debug_enabled
	_rebuild()

func _rebuild() -> void:
	_clear_cells()
	_cell_size = Vector2(board_rect.size.x / COLUMNS, board_rect.size.y / ROWS)

	for row in range(ROWS):
		for column in range(COLUMNS):
			var cell := Node2D.new()
			cell.name = "Cell_%d_%d" % [row, column]
			cell.position = grid_to_world(row, column)
			cell.set_meta("row", row)
			cell.set_meta("column", column)
			cell.set_meta("occupied", false)
			add_child(cell)
			cells.append(cell)

	queue_redraw()

func _clear_cells() -> void:
	for child in get_children():
		child.free()
	cells.clear()

func get_cell(row: int, column: int) -> Node2D:
	if row < 0 or row >= ROWS or column < 0 or column >= COLUMNS:
		return null
	return cells[row * COLUMNS + column]

func world_to_grid(world_position: Vector2) -> Vector2i:
	if not board_rect.has_point(world_position):
		return Vector2i(-1, -1)
	var local := world_position - board_rect.position
	return Vector2i(
		clampi(floori(local.y / _cell_size.y), 0, ROWS - 1),
		clampi(floori(local.x / _cell_size.x), 0, COLUMNS - 1)
	)

func grid_to_world(row: int, column: int) -> Vector2:
	return Vector2(
		board_rect.position.x + (column + 0.5) * _cell_size.x,
		board_rect.position.y + (row + 0.5) * _cell_size.y
	)

func is_inside_board(world_position: Vector2) -> bool:
	return board_rect.has_point(world_position)

func get_cell_size() -> Vector2:
	return _cell_size

func _draw() -> void:
	if not show_debug_grid:
		return

	for row in range(ROWS + 1):
		var y := board_rect.position.y + row * _cell_size.y
		draw_line(
			Vector2(board_rect.position.x, y),
			Vector2(board_rect.end.x, y),
			Color(1.0, 1.0, 1.0, 0.75),
			2.0
		)

	for column in range(COLUMNS + 1):
		var x := board_rect.position.x + column * _cell_size.x
		draw_line(
			Vector2(x, board_rect.position.y),
			Vector2(x, board_rect.end.y),
			Color(1.0, 1.0, 1.0, 0.75),
			2.0
		)
