extends Node2D
class_name BlastCone

const DATA: PlantData = preload("res://data/plants/blast_cone.tres")
const DESIGN_CELL_HEIGHT: float = 104.0
const ATTACK_ANIMATION := "attack"
const ATTACK_FRAME := 10

var _effect_range: float = float(DATA.ability_data.get("effect_range", 3.0))

@export var bounce_speed: float = 0.7
@export var bounce_scale: float = 0.025
@export var bob_amount: float = 3.0

@onready var visual: Node2D = $Visual
@onready var animated_sprite: AnimatedSprite2D = $Visual/AttackSprite
@onready var interaction_shape: CollisionShape2D = $InteractionArea/CollisionShape2D

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
var _cell_size: Vector2 = Vector2.ZERO
var _triggered: bool = false
var _blast_frame_triggered: bool = false


func _ready() -> void:
	add_to_group("plants")

	_base_position = visual.position
	_base_scale = visual.scale
	_base_rotation = visual.rotation

	animated_sprite.frame_changed.connect(_on_attack_sprite_animation_changed)
	animated_sprite.animation_finished.connect(_on_animation_finished)

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
	if _combat_enabled and not _triggered:
		_check_trap()

	if _attacking:
		return

	bounce_time += delta * bounce_speed * TAU * 0.3

	var wobble: float = sin(bounce_time)
	var squash_x: float = 1.0 + wobble * bounce_scale
	var squash_y: float = 1.0 - wobble * bounce_scale * 0.8

	visual.scale = _base_scale * Vector2(squash_x, squash_y)

	var bob: float = -abs(wobble) * bob_amount
	visual.position = _base_position + Vector2(0.0, bob)


func _check_trap() -> void:
	var target: Node2D = _find_enemy_in_trap()

	if target == null:
		return

	_trigger_trap(target)


func _find_enemy_in_trap() -> Node2D:
	var cone_rect: Rect2 = get_interaction_rect().grow(10)

	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(node) or node is not Node2D:
			continue

		if int(node.get("grid_row")) != grid_row:
			continue

		var enemy := node as Node2D

		if enemy.has_method("get_interaction_rect"):
			if cone_rect.intersects(enemy.get_interaction_rect()):
				return enemy
		else:
			if cone_rect.has_point(enemy.global_position):
				return enemy

	return null


func _trigger_trap(target: Node2D) -> void:
	if target == null or not is_instance_valid(target):
		return

	_triggered = true
	_blast_frame_triggered = false

	for enemy: Node2D in _find_enemies_in_effect_range():
		if enemy.has_method("take_damage"):
			enemy.take_damage(_attack)

	play_attack()


func _spawn_blast_visual() -> void:
	if _gameplay == null:
		return

	var visual_scene: PackedScene = load(
		"res://scenes/plants/blast_cone_visual.tscn"
	)

	if visual_scene == null:
		return

	var blast_visual: Node2D = visual_scene.instantiate() as Node2D
	_gameplay.add_child(blast_visual)
	blast_visual.global_position = global_position

	if blast_visual.has_method("setup"):
		blast_visual.call("setup", _effect_range, _cell_size)


func play_attack() -> void:
	if _attacking:
		return

	_attacking = true

	visual.position = _base_position
	visual.scale = _base_scale
	visual.rotation = _base_rotation
	bounce_time = 0.0

	animated_sprite.animation = "attack"
	animated_sprite.frame = 0
	animated_sprite.play()


func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		queue_free()


func _show_idle() -> void:
	_attacking = false
	animated_sprite.stop()
	animated_sprite.animation = "attack"
	animated_sprite.frame = 0

	bounce_time = 0.0
	visual.position = _base_position
	visual.scale = _base_scale
	visual.rotation = _base_rotation


func setup_combat(gameplay: Node, row: int) -> void:
	_gameplay = gameplay
	grid_row = row
	_hp = DATA.base_hp
	_combat_enabled = true

	var final_stats: Variant = PlantProgression.get_final_stats(DATA.id)
	var base_attack: float = final_stats.attack if final_stats != null else DATA.base_attack
	_attack = base_attack * 5

func get_interaction_rect() -> Rect2:
	var rect := Rect2(
		position - _cell_size * 0.5,
		_cell_size
	)
	return rect


func get_trap_rect() -> Rect2:
	return get_interaction_rect()


func take_damage(amount: float) -> void:
	_hp -= amount

	if _hp <= 0.0:
		queue_free()


func get_hp() -> float:
	return _hp


func _find_enemies_in_effect_range() -> Array[Node2D]:
	var targets: Array[Node2D] = []

	var effect_radius: float = minf(
		_cell_size.x,
		_cell_size.y
	) * _effect_range * 0.5

	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(node) or node is not Node2D:
			continue

		if int(node.get("grid_row")) != grid_row:
			continue

		var enemy := node as Node2D

		if global_position.distance_to(enemy.global_position) <= effect_radius:
			targets.append(enemy)

	return targets

func _on_attack_sprite_animation_changed() -> void:
	if _blast_frame_triggered:
		return

	if animated_sprite.animation == ATTACK_ANIMATION \
			and animated_sprite.frame == ATTACK_FRAME:
		_blast_frame_triggered = true
		_spawn_blast_visual()
