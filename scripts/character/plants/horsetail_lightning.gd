extends Node2D
class_name HorsetailLightning

var _chain_count: int = 0
var _chain_range: float = 0.0
var _chain_damage_multiplier: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var _source_position: Vector2
var _target: Node2D
var _damage: float = 0.0
var _grid_row: int = 0
var _chain_index: int = 0
var _direction: Vector2 = Vector2.RIGHT
var used_targets: Array[Node2D] = []

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)

func setup(
	target: Node2D,
	amount: float,
	row: int,
	count: int,
	range_value: float,
	damage_multiplier: float,
	source_position: Vector2,
	chain_index: int = 0,
	previous_targets: Array[Node2D] = []
) -> void:
	_target = target
	_damage = amount
	_grid_row = row
	_chain_count = count
	_chain_range = range_value
	_chain_damage_multiplier = damage_multiplier
	_source_position = source_position + Vector2(50.0, -20.0)
	_chain_index = chain_index

	used_targets.clear()

	for previous_target: Node2D in previous_targets:
		if is_instance_valid(previous_target):
			used_targets.append(previous_target)

	if is_instance_valid(target) and target not in used_targets:
		used_targets.append(target)

	if is_instance_valid(target):
		var delta: Vector2 = target.global_position - _source_position
		if delta.length_squared() > 0.01:
			_direction = delta.normalized()

	rotation = _direction.angle()

	_update_visual()
	_apply_damage()
	
	animated_sprite.flip_h = true
	animated_sprite.play("default")

func _update_visual() -> void:
	if not is_instance_valid(_target):
		return

	var start: Vector2 = _source_position
	var end: Vector2 = _target.global_position + Vector2(-60.0, -20.0)
	var direction: Vector2 = end - start
	var distance: float = direction.length()

	global_position = (start + end) * 0.5
	rotation = direction.angle()

	if animated_sprite.sprite_frames == null:
		return

	var texture: Texture2D = animated_sprite.sprite_frames.get_frame_texture(
		"default",
		0
	)

	if texture == null:
		return

	var texture_size: Vector2 = texture.get_size()

	if texture_size.x > 0.0:
		animated_sprite.scale.x = distance / texture_size.x

func _apply_damage() -> void:
	if not is_instance_valid(_target):
		return

	if _target.has_method("take_damage"):
		_target.take_damage(_damage)
		
	if _chain_index + 1 < _chain_count:
		_spawn_next_chain()

func _on_animation_finished() -> void:
	queue_free()

func _spawn_next_chain() -> void:
	var next_target: Node2D = _find_next_target()

	if next_target == null:
		return

	var next_lightning_scene: PackedScene = load(
		"res://scenes/plants/horsetail_lightning.tscn"
	)

	if next_lightning_scene == null:
		return

	var next_lightning: HorsetailLightning = (
		next_lightning_scene.instantiate() as HorsetailLightning
	)

	if next_lightning == null:
		return

	get_parent().add_child(next_lightning)
	
	var chain_position: Vector2 = _target.global_position + Vector2(-100.0, 0.0)
	next_lightning.global_position = chain_position

	next_lightning.setup(
		next_target,
		_damage * _chain_damage_multiplier,
		_grid_row,
		_chain_count,
		_chain_range,
		_chain_damage_multiplier,
		chain_position,
		_chain_index + 1,
		used_targets
	)

func _find_next_target() -> Node2D:
	if not is_instance_valid(_target):
		return null

	var best: Node2D = null
	var best_distance: float = INF

	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(node) or node is not Node2D:
			continue

		var enemy: Node2D = node as Node2D

		if enemy in used_targets:
			continue

		var distance: float = _target.global_position.distance_to(
			enemy.global_position
		)

		if distance > _chain_range:
			continue

		if distance < best_distance:
			best = enemy
			best_distance = distance

	return best
