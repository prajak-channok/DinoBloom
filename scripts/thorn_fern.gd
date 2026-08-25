extends Node2D
class_name ThornFern

const DATA: PlantData = preload("res://data/plants/thorn_fern.tres")
const DESIGN_CELL_HEIGHT: float = 104.0

@export var bounce_speed: float = 0.7
@export var bounce_scale: float = 0.025
@export var bob_amount: float = 3.0

@onready var visual: Node2D = $Visual
@onready var idle_sprite: Sprite2D = $Visual/IdleSprite
@onready var attack_sprite: AnimatedSprite2D = $Visual/AttackSprite
@onready var interaction_area: Area2D = $InteractionArea
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
var _attack_timer: float = 0.0
var _cell_size: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("plants")
	_base_position = visual.position
	_base_scale = visual.scale
	_base_rotation = visual.rotation
	attack_sprite.animation_finished.connect(_on_animation_finished)
	_show_idle()

func set_grid_cell(row: int, column: int, cell_size: Vector2) -> void:
	grid_row = row
	grid_column = column
	_cell_size = cell_size
	# Preserve the artist-authored Idle/Attack child scales and only scale the
	# common visual anchor with the logical Cell size. At the current 1280x720
	# design resolution the reference cell is 104 px high, so existing tuning is
	# unchanged while other field sizes scale proportionally.
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
	visual.position = _base_position
	visual.scale = _base_scale
	visual.rotation = _base_rotation
	bounce_time = 0.0
	idle_sprite.visible = false
	attack_sprite.visible = true
	attack_sprite.frame = 0
	attack_sprite.play("attack")

func _on_animation_finished() -> void:
	if attack_sprite.animation == "attack":
		_show_idle()

func _show_idle() -> void:
	_attacking = false
	attack_sprite.stop()
	attack_sprite.visible = false
	idle_sprite.visible = true
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
	play_attack()
	var projectile_scene: PackedScene = load("res://scenes/plants/thorn_projectile.tscn")
	if projectile_scene == null or _gameplay == null:
		return
	var projectile: Node2D = projectile_scene.instantiate() as Node2D
	projectile.position = position + Vector2(_cell_size.x * 0.25, -_cell_size.y * 0.08)
	projectile.setup(target, _attack, grid_row)
	_gameplay.add_child(projectile)

func _find_nearest_enemy() -> Node2D:
	var best: Node2D = null
	var best_distance: float = INF
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(node) or node is not Node2D:
			continue
		if int(node.get("grid_row")) != grid_row:
			continue
		var enemy := node as Node2D
		if enemy.position.x < position.x:
			continue
		var distance: float = enemy.position.x - position.x
		if distance < best_distance:
			best = node as Node2D
			best_distance = distance
	return best

func get_interaction_rect() -> Rect2:
	return Rect2(position - _cell_size * 0.5, _cell_size)

func take_damage(amount: float) -> void:
	_hp -= amount
	if _hp <= 0.0:
		queue_free()

func get_hp() -> float:
	return _hp
