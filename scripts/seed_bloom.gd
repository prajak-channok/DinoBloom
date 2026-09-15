extends Node2D
class_name SeedBloom

signal seed_generated(amount: int)

const DATA: PlantData = preload("res://data/plants/seed_bloom.tres")
const DESIGN_CELL_HEIGHT: float = 104.0

@export var idle_bob_height: float = 3.0
@export var idle_bob_speed: float = 0.8

@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite2D
@onready var interaction_shape: CollisionShape2D = $InteractionArea/CollisionShape2D

var grid_row: int = -1
var grid_column: int = -1
var _gameplay: Node = null
var _hp: float = 0.0
var _production_timer: float = 0.0
var _base_position: Vector2
var _base_scale: Vector2
var _time: float = 0.0

func _ready() -> void:
	add_to_group("plants")
	_base_position = visual.position
	_base_scale = visual.scale

func setup(gameplay: Node, row: int) -> void:
	_gameplay = gameplay
	grid_row = row
	var final_stats: Variant = PlantProgression.get_final_stats(DATA.id)
	_hp = final_stats.hp if final_stats != null else DATA.base_hp
	add_to_group("plants")

func set_grid_cell(row: int, column: int, cell_size: Vector2) -> void:
	grid_row = row
	grid_column = column
	visual.scale = Vector2.ONE * (cell_size.y / DESIGN_CELL_HEIGHT)
	_base_scale = visual.scale
	var shape := RectangleShape2D.new()
	shape.size = cell_size
	interaction_shape.shape = shape

func _process(delta: float) -> void:
	_time += delta
	var wave: float = sin(_time * TAU * idle_bob_speed * 0.3)
	visual.position = _base_position + Vector2(0.0, -abs(wave) * idle_bob_height)
	visual.scale = _base_scale * Vector2(1.0 + wave * 0.015, 1.0 - wave * 0.015)

	if _gameplay == null:
		return

	var group: Array = _get_shared_group()
	# Only the group leader (lowest column/row along the formation's axis)
	# ticks the shared timer; followers stay frozen so their own accumulated
	# progress is preserved, not lost, if the group later breaks up.
	if not group.is_empty() and group[0] != self:
		return

	_production_timer += delta
	if _production_timer >= DATA.production_interval:
		_production_timer -= DATA.production_interval
		if group.is_empty():
			_produce()
		else:
			for member in group:
				if is_instance_valid(member):
					member._produce()

## Horizontal run (same row) takes priority over vertical (same column) so a
## SeedBloom at a cross intersection is never claimed by two groups at once:
## if it qualifies horizontally, _vertical_run() below excludes it from any
## column it sits in, so that column can't reach 3 "through" it either.
func _get_shared_group() -> Array:
	var horizontal := _horizontal_run(self)
	if horizontal.size() >= 3:
		return horizontal
	var vertical := _vertical_run(self)
	if vertical.size() >= 3:
		return vertical
	return []

## Contiguous run (same row, consecutive columns) of SeedBloom instances that
## includes seed.
func _horizontal_run(seed_bloom: SeedBloom) -> Array:
	var same_row: Array = []
	for node in get_tree().get_nodes_in_group("plants"):
		if node is SeedBloom and is_instance_valid(node) and node.grid_row == seed_bloom.grid_row:
			same_row.append(node)
	return _contiguous_run(same_row, seed_bloom, func(n: SeedBloom) -> int: return n.grid_column)

## Contiguous run (same column, consecutive rows) of SeedBloom instances that
## includes seed. Members already claimed by a horizontal run of their own
## are excluded, breaking the column at that point.
func _vertical_run(seed_bloom: SeedBloom) -> Array:
	var same_column: Array = []
	for node in get_tree().get_nodes_in_group("plants"):
		if node is SeedBloom and is_instance_valid(node) and node.grid_column == seed_bloom.grid_column:
			if node == seed_bloom or _horizontal_run(node).size() < 3:
				same_column.append(node)
	return _contiguous_run(same_column, seed_bloom, func(n: SeedBloom) -> int: return n.grid_row)

func _contiguous_run(candidates: Array, _seed_bloom: SeedBloom, position_of: Callable) -> Array:
	candidates.sort_custom(func(a: SeedBloom, b: SeedBloom) -> bool: return position_of.call(a) < position_of.call(b))

	var seed_index := candidates.find(seed)
	if seed_index == -1:
		return []

	var start := seed_index
	while start > 0 and int(position_of.call(candidates[start - 1])) == int(position_of.call(candidates[start])) - 1:
		start -= 1
	var end := seed_index
	while end < candidates.size() - 1 and int(position_of.call(candidates[end + 1])) == int(position_of.call(candidates[end])) + 1:
		end += 1

	var run: Array = candidates.slice(start, end + 1)
	return run if run.size() >= 3 else []

func _produce() -> void:
	seed_generated.emit(DATA.production_amount)
	if _gameplay != null and _gameplay.has_method("add_seed"):
		_gameplay.add_seed(DATA.production_amount)

func get_interaction_rect() -> Rect2:
	return Rect2(position - interaction_shape.shape.size * 0.5, interaction_shape.shape.size)

func take_damage(amount: float) -> void:
	_hp -= amount
	if _hp <= 0.0:
		queue_free()

func get_hp() -> float:
	return _hp
