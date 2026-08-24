extends Node2D
class_name Velociraptor

## M4: see Dryosaurus.died / Dryosaurus.reached_boundary for contract.
signal died
signal reached_boundary

const DATA: DinosaurData = preload("res://data/dinosaurs/velociraptor.tres")

## Runtime footprint used for the stop point at the right edge of a Plant cell.
## This is gameplay-space, not the sprite's visual size.
@export var body_half_width: float = 50.0
@export var contact_padding: float = 2.0

@onready var sprite: AnimatedSprite2D = $Visual/AnimatedSprite2D
@onready var hp_bar: ProgressBar = $HPBar

var grid_row: int = 0
var hp: float = 0.0
var max_hp: float = 0.0
var _attack_timer: float = 0.0
var _board_rect := Rect2()
var _target: Node2D = null
var _state := "walking"

func setup(row: int, board_rect: Rect2 = Rect2(), _cell_size: Vector2 = Vector2(120.0, 100.0), hp_multiplier: float = 1.0) -> void:
	grid_row = row
	hp = DATA.base_hp * hp_multiplier
	max_hp = hp
	_board_rect = board_rect
	_attack_timer = 0.0
	_update_hp_bar()
	_play_walk()
	add_to_group("enemies")

func _ready() -> void:
	if hp <= 0.0:
		hp = DATA.base_hp
		max_hp = DATA.base_hp
	_update_hp_bar()
	_play_walk()

func _process(delta: float) -> void:
	var plant := _find_next_plant_ahead()
	if plant != null:
		var plant_rect: Rect2 = plant.get_interaction_rect() if plant.has_method("get_interaction_rect") else Rect2(plant.position, Vector2.ZERO)
		var stop_x := plant_rect.end.x + body_half_width + contact_padding

		if position.x > stop_x:
			_state = "walking"
			_target = null
			_play_walk()
			position.x = maxf(position.x - DATA.movement_speed * delta, stop_x)
		else:
			_state = "eating"
			_target = plant
			_play_eat()
			_attack_timer += delta
			if _attack_timer >= DATA.attack_interval:
				_attack_timer -= DATA.attack_interval
				if is_instance_valid(plant) and plant.has_method("take_damage"):
					plant.take_damage(DATA.attack)
	else:
		_state = "walking"
		_target = null
		_attack_timer = 0.0
		_play_walk()
		position.x -= DATA.movement_speed * delta

	if _board_rect.size.x > 0.0 and position.x < _board_rect.position.x - body_half_width:
		reached_boundary.emit()
		queue_free()

func _play_walk() -> void:
	if sprite == null:
		return
	if sprite.animation != &"walk" or not sprite.is_playing():
		sprite.play("walk")

func _play_eat() -> void:
	if sprite == null:
		return
	if sprite.animation != &"eat" or not sprite.is_playing():
		sprite.play("eat")

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
	_update_hp_bar()
	if hp <= 0.0:
		died.emit()
		queue_free()

func _update_hp_bar() -> void:
	if is_instance_valid(hp_bar):
		hp_bar.max_value = max_hp if max_hp > 0.0 else DATA.base_hp
		hp_bar.value = maxf(hp, 0.0)

func get_hp() -> float:
	return hp
