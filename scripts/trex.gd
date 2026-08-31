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
const COLUMNS := 8

## T-Rex is a Boss: bigger gameplay footprint than normal dinosaurs.
@export var body_half_width: float = 84.0
@export var contact_padding: float = 2.0
@export var attack_flash_color: Color = Color(0.85, 0.15, 0.15, 1.0)

@onready var visual: Node2D = $Visual
@onready var sprite: AnimatedSprite2D = $Visual/AnimatedSprite2D

var grid_row: int = 0
var hp: float = 0.0
var max_hp: float = 0.0
var _attack_timer: float = 0.0
var _board_rect := Rect2()
var _cell_size := Vector2(120.0, 100.0)
var _target: Node2D = null
var _flash_timer: float = 0.0
## Boss entrance roar: triggers once, when the T-Rex first reaches the
## second grid column from the right, freezing movement/attack until the
## one-shot "rumbling" animation finishes.
var _rumble_triggered: bool = false
var _is_rumbling: bool = false
## Ginkgo Cannon Conversion state, same contract as every other dinosaur.
## DATA.can_be_converted is false on trex.tres, so can_be_converted() always
## returns false here — T-Rex simply never flips to "Friendly".
var faction: String = "Enemy"

func setup(row: int, board_rect: Rect2 = Rect2(), cell_size: Vector2 = Vector2(120.0, 100.0), hp_multiplier: float = 1.0) -> void:
	grid_row = row
	hp = DATA.base_hp * hp_multiplier
	max_hp = hp
	_board_rect = board_rect
	_cell_size = cell_size
	_attack_timer = 0.0
	_target = null
	faction = DATA.faction
	add_to_group("enemies")
	add_to_group("bosses")
	_play_walk()
	hp_changed.emit(hp, max_hp)

func _ready() -> void:
	if hp <= 0.0:
		hp = DATA.base_hp
		max_hp = DATA.base_hp
	_play_walk()
	if is_instance_valid(sprite):
		sprite.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0 and is_instance_valid(sprite):
			sprite.modulate = Color.WHITE

	if _is_rumbling:
		return

	if not _rumble_triggered and _board_rect.size.x > 0.0 and _cell_size.x > 0.0:
		var rumble_trigger_x := _board_rect.position.x + (float(COLUMNS) - 1.5) * _cell_size.x
		if position.x <= rumble_trigger_x:
			_start_rumble()
			return

	var plant := _find_target_ahead()
	if plant != null:
		var plant_rect: Rect2 = plant.get_interaction_rect() if plant.has_method("get_interaction_rect") else Rect2(plant.position, Vector2.ZERO)
		var stop_x := plant_rect.end.x + body_half_width + contact_padding

		if position.x > stop_x:
			_target = null
			_play_walk()
			position.x = maxf(position.x - DATA.movement_speed * delta, stop_x)
		else:
			_target = plant
			_play_eat()
			_attack_timer += delta
			if _attack_timer >= DATA.attack_interval:
				_attack_timer -= DATA.attack_interval
				_flash_attack()
				if is_instance_valid(plant) and plant.has_method("take_damage"):
					plant.take_damage(DATA.attack)
	else:
		_target = null
		_attack_timer = 0.0
		_play_walk()
		position.x -= DATA.movement_speed * delta

	if _board_rect.size.x > 0.0 and position.x < _board_rect.position.x - body_half_width:
		reached_boundary.emit()
		queue_free()

func _start_rumble() -> void:
	_rumble_triggered = true
	_is_rumbling = true
	_target = null
	_attack_timer = 0.0
	if is_instance_valid(sprite):
		sprite.play("rumbling")

func _on_animation_finished() -> void:
	if is_instance_valid(sprite) and sprite.animation == &"rumbling":
		_is_rumbling = false

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

func _flash_attack() -> void:
	if is_instance_valid(sprite):
		sprite.modulate = attack_flash_color
	_flash_timer = 0.15

## T-Rex is always Enemy faction (never converts), so it always fights
## Plants + Friendly Dinosaurs ahead — same rule as every other Enemy.
func _find_target_ahead() -> Node2D:
	var best: Node2D = null
	var best_distance: float = INF
	for group_name in ["plants", "friendly_dinosaurs"]:
		for node: Node in get_tree().get_nodes_in_group(group_name):
			if not is_instance_valid(node) or node is not Node2D:
				continue
			if int(node.get("grid_row")) != grid_row:
				continue
			var other := node as Node2D
			var other_rect: Rect2 = other.get_interaction_rect() if other.has_method("get_interaction_rect") else Rect2(other.position, Vector2.ZERO)
			if position.x < other_rect.position.x - body_half_width:
				continue
			var distance_ahead := position.x - other_rect.end.x
			if distance_ahead < best_distance:
				best = other
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

func get_interaction_rect() -> Rect2:
	return Rect2(Vector2(position.x - body_half_width, position.y), Vector2(body_half_width * 2.0, 0.0))

func can_be_converted() -> bool:
	return faction == "Enemy" and DATA.can_be_converted

func convert_to_friendly() -> void:
	if not can_be_converted():
		return
	faction = "Friendly"
	hp = max_hp
	hp_changed.emit(hp, max_hp)
	remove_from_group("enemies")
	add_to_group("friendly_dinosaurs")
	_target = null
	_attack_timer = 0.0
