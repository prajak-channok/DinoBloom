extends Node2D
class_name ThornProjectile

const SPEED: float = 520.0
const HIT_RADIUS: float = 28.0
const MAX_LIFETIME: float = 2.5

var damage: float = 0.0
var grid_row: int = -1
var _direction := Vector2.RIGHT
var _lifetime: float = 0.0
var _target: Node2D = null

func setup(target: Node2D, amount: float, row: int) -> void:
	_target = target
	damage = amount
	grid_row = row

	if is_instance_valid(target):
		var delta: Vector2 = target.global_position - global_position

		if delta.length_squared() > 0.01:
			_direction = delta.normalized()

	rotation = _direction.angle()

func _process(delta: float) -> void:
	_lifetime += delta

	var previous_position: Vector2 = global_position
	global_position += _direction * SPEED * delta

	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(node) or node is not Node2D:
			continue

		if int(node.get("grid_row")) != grid_row:
			continue

		var enemy: Node2D = node as Node2D

		if _segment_hits_point(
			previous_position,
			global_position,
			enemy.global_position,
			HIT_RADIUS
		):
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)

			queue_free()
			return

	if _lifetime >= MAX_LIFETIME:
		queue_free()

func _segment_hits_point(
	a: Vector2,
	b: Vector2,
	point: Vector2,
	radius: float
) -> bool:
	var segment: Vector2 = b - a
	var length_sq: float = segment.length_squared()

	if length_sq <= 0.001:
		return a.distance_to(point) <= radius

	var t := clampf(
		(point - a).dot(segment) / length_sq,
		0.0,
		1.0
	)

	var closest: Vector2 = a + segment * t

	return closest.distance_to(point) <= radius
