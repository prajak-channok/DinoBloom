extends Node2D
class_name TRex

## M4: see Dryosaurus.died / Dryosaurus.reached_boundary for contract.
signal died
signal reached_boundary
## M4: drives the dedicated Boss HP Bar in the gameplay UI (requirement #17).
## MatchManager listens to this instead of relying on the small per-unit bar
## other dinosaurs use.
signal hp_changed(current: float, max_hp: float)

const DATA: DinosaurData = preload("res://data/dinosaurs/trex.tres")

## T-Rex is a Boss: bigger gameplay footprint than normal dinosaurs.
@export var body_half_width: float = 84.0
@export var contact_padding: float = 2.0
@export var attack_flash_color: Color = Color(0.85, 0.15, 0.15, 1.0)
@export var idle_color: Color = Color(0.42, 0.08, 0.08, 1.0)

@onready var visual: ColorRect = $Visual/ColorRect

var grid_row: int = 0
var hp: float = 0.0
var max_hp: float = 0.0
var _attack_timer: float = 0.0
var _board_rect := Rect2()
var _target: Node2D = null
var _flash_timer: float = 0.0

func setup(row: int, board_rect: Rect2 = Rect2(), _cell_size: Vector2 = Vector2(120.0, 100.0), hp_multiplier: float = 1.0) -> void:
	grid_row = row
	hp = DATA.base_hp * hp_multiplier
	max_hp = hp
	_board_rect = board_rect
	_attack_timer = 0.0
	_target = null
	add_to_group("enemies")
	add_to_group("bosses")
	if is_instance_valid(visual):
		visual.color = idle_color
	hp_changed.emit(hp, max_hp)

func _ready() -> void:
	if hp <= 0.0:
		hp = DATA.base_hp
		max_hp = DATA.base_hp

func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0 and is_instance_valid(visual):
			visual.color = idle_color

	var plant := _find_next_plant_ahead()
	if plant != null:
		var plant_rect: Rect2 = plant.get_interaction_rect() if plant.has_method("get_interaction_rect") else Rect2(plant.position, Vector2.ZERO)
		var stop_x := plant_rect.end.x + body_half_width + contact_padding

		if position.x > stop_x:
			_target = null
			position.x = maxf(position.x - DATA.movement_speed * delta, stop_x)
		else:
			if position.x < stop_x:
				position.x = stop_x
			_target = plant
			_attack_timer += delta
			if _attack_timer >= DATA.attack_interval:
				_attack_timer -= DATA.attack_interval
				_flash_attack()
				if is_instance_valid(plant) and plant.has_method("take_damage"):
					plant.take_damage(DATA.attack)
	else:
		_target = null
		_attack_timer = 0.0
		position.x -= DATA.movement_speed * delta

	if _board_rect.size.x > 0.0 and position.x < _board_rect.position.x - body_half_width:
		reached_boundary.emit()
		queue_free()

func _flash_attack() -> void:
	if is_instance_valid(visual):
		visual.color = attack_flash_color
	_flash_timer = 0.15

func _find_next_plant_ahead() -> Node2D:
	var best: Node2D = null
	var best_distance: float = INF
	for node: Node in get_tree().get_nodes_in_group("plants"):
		if not is_instance_valid(node) or node is not Node2D:
			continue
		if int(node.get("grid_row")) != grid_row:
			continue
		var plant := node as Node2D
		var plant_rect: Rect2 = plant.get_interaction_rect() if plant.has_method("get_interaction_rect") else Rect2(plant.position, Vector2.ZERO)
		if position.x < plant_rect.position.x - body_half_width:
			continue
		var distance_ahead := position.x - plant_rect.end.x
		if distance_ahead < best_distance:
			best = plant
			best_distance = distance_ahead
	return best

func take_damage(amount: float) -> void:
	hp -= amount
	hp_changed.emit(maxf(hp, 0.0), max_hp)
	if hp <= 0.0:
		died.emit()
		queue_free()

func get_hp() -> float:
	return hp
