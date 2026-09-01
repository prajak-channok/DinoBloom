extends Node2D
class_name Horsetail

const DATA: PlantData = preload("res://data/plants/horsetail.tres")
const DESIGN_CELL_HEIGHT: float = 104.0
const ATTACK_ANIMATION := "attack"
const ATTACK_FRAME: int = 6

@export var bounce_speed: float = 0.7
@export var bounce_scale: float = 0.025
@export var bob_amount: float = 3.0

@onready var visual: Node2D = $Visual
@onready var animated_sprite: AnimatedSprite2D = $Visual/AttackSprite
@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_shape: CollisionShape2D = $InteractionArea/CollisionShape2D
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound

var _base_position: Vector2
var _base_scale: Vector2
var _base_rotation: float
var bounce_time: float = 0.0
var _attacking: bool = false
var _combat_enabled: bool = false
var _gameplay: Node = null
var grid_row: int = -1
var grid_column: int = -1
var _hp: float = 0.0
var _attack: float = 0.0
var _attack_timer: float = 0.0
var _cell_size: Vector2 = Vector2.ZERO
var _current_target: Node2D = null
var _attack_frame_triggered: bool = false

func _ready() -> void:
	add_to_group("plants")
	_base_position = visual.position
	_base_scale = visual.scale
	_base_rotation = visual.rotation
	animated_sprite.frame_changed.connect(_on_attack_frame_changed)
	animated_sprite.animation_finished.connect(_on_attack_animation_finished)
	_show_idle()

func set_grid_cell(row: int, column: int, cell_size: Vector2) -> void:
	grid_row = row
	grid_column = column
	_cell_size = cell_size
	visual.scale = Vector2.ONE * (cell_size.y / DESIGN_CELL_HEIGHT)
	_base_scale = visual.scale
	interaction_shape.shape = _make_cell_shape(cell_size)

func _make_cell_shape(cell_size: Vector2) -> RectangleShape2D:
	var shape := RectangleShape2D.new()
	shape.size = cell_size
	return shape

func _process(delta: float) -> void:
	if _combat_enabled:
		_combat_process(delta)

	if _attacking:
		return

	bounce_time += delta * bounce_speed * TAU * 0.3
	var wobble: float = sin(bounce_time)
	var squash_x: float = 1.0 + wobble * bounce_scale
	var squash_y: float = 1.0 - wobble * bounce_scale * 0.8

	visual.scale = _base_scale * Vector2(squash_x, squash_y)

	var bob: float = -abs(wobble) * bob_amount
	visual.position = _base_position + Vector2(0.0, bob)

func play_attack() -> void:
	if _attacking:
		return

	_attacking = true
	_attack_frame_triggered = false

	visual.position = _base_position
	visual.scale = _base_scale
	visual.rotation = _base_rotation
	bounce_time = 0.0

	animated_sprite.animation = ATTACK_ANIMATION
	animated_sprite.frame = 0
	animated_sprite.play(ATTACK_ANIMATION)

func _on_attack_frame_changed() -> void:
	if not _attacking:
		return

	if animated_sprite.animation != ATTACK_ANIMATION:
		return

	if animated_sprite.frame != ATTACK_FRAME:
		return

	if _attack_frame_triggered:
		return

	_attack_frame_triggered = true
	_spawn_projectile()
	
	if attack_sound:
		attack_sound.play()

func _on_attack_animation_finished() -> void:
	if animated_sprite.animation == ATTACK_ANIMATION:
		_show_idle()

func _show_idle() -> void:
	_attacking = false
	_attack_frame_triggered = false

	animated_sprite.stop()
	animated_sprite.animation = ATTACK_ANIMATION
	animated_sprite.frame = 0

	bounce_time = 0.0
	visual.position = _base_position
	visual.scale = _base_scale
	visual.rotation = _base_rotation

func setup_combat(gameplay: Node, row: int) -> void:
	_gameplay = gameplay
	grid_row = row
	_hp = DATA.base_hp

	var final_stats: Variant = PlantProgression.get_final_stats(DATA.id)
	_attack = final_stats.attack if final_stats != null else DATA.base_attack

	_attack_timer = DATA.attack_interval
	_combat_enabled = true

func _combat_process(delta: float) -> void:
	_attack_timer += delta

	if _attack_timer < DATA.attack_interval:
		return

	var target: Node2D = _find_nearest_enemy()

	if target == null:
		return

	_attack_timer = 0.0
	_current_target = target
	play_attack()

func _find_nearest_enemy() -> Node2D:
	var best: Node2D = null
	var attack_range: float = float(DATA.ability_data.get("attack_range", 0.0))

	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(node) or node is not Node2D:
			continue

		var enemy := node as Node2D
		var distance: float = global_position.distance_to(enemy.global_position)

		if distance < attack_range:
			best = enemy
			attack_range = distance

	return best

func _spawn_projectile() -> void:
	var chain_count: int = int(DATA.ability_data.get("chain_count", 0))
	var chain_range: float = float(DATA.ability_data.get("chain_range", 0.0))
	var chain_damage_multiplier: float = float(DATA.ability_data.get("chain_damage_multiplier", 1.0))
	if _current_target == null or not is_instance_valid(_current_target):
		return

	if _gameplay == null:
		return

	var lightning_scene: PackedScene = load(
		"res://scenes/plants/horsetail_lightning.tscn"
	)

	if lightning_scene == null:
		return

	var lightning: HorsetailLightning = lightning_scene.instantiate() as HorsetailLightning

	if lightning == null:
		return

	_gameplay.add_child(lightning)
	lightning.setup(
		_current_target,
		_attack,
		grid_row,
		chain_count,
		chain_range,
		chain_damage_multiplier,
		global_position
	)

func get_interaction_rect() -> Rect2:
	return Rect2(position - _cell_size * 0.5, _cell_size)

func take_damage(amount: float) -> void:
	_hp -= amount

	if _hp <= 0.0:
		queue_free()

func get_hp() -> float:
	return _hp
