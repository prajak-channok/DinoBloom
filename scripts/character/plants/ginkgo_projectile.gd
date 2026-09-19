extends Node2D
class_name GinkgoProjectile

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED: float = 320.0
const HIT_RADIUS: float = 28.0
const MAX_LIFETIME: float = 2.5

var damage: float = 0.0
var grid_row: int = -1
var _direction := Vector2.RIGHT
var _lifetime: float = 0.0
var _target: Node2D = null
var _exploding: bool = false
## true = this shot is the Conversion Ability (no damage). false = a normal
## damage shot (no Conversion attempt). Decided once per shot by Ginkgo
## Cannon based on its 40s cooldown; effect and damage never both happen.
var _apply_conversion: bool = false

func _ready() -> void:
	animated_sprite.play("fly")

func setup(target: Node2D, amount: float, row: int, apply_conversion: bool = false) -> void:
	_target = target
	damage = amount
	grid_row = row
	_apply_conversion = apply_conversion
	if is_instance_valid(target):
		var delta: Vector2 = target.position - position
		if delta.length_squared() > 0.01:
			_direction = delta.normalized()
	rotation = _direction.angle()

func _process(delta: float) -> void:
	if _exploding:
		return
	_lifetime += delta
	var previous_position: Vector2 = position
	position += _direction * SPEED * delta

	# Conversion is intentionally isolated here so the projectile can later
	# apply the Ginkgo effect without coupling Plant code to Dinosaur code.
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(node) or node is not Node2D:
			continue
		if int(node.get("grid_row")) != grid_row:
			continue

		var enemy: Node2D = node as Node2D
		if _segment_hits_point(previous_position, position, enemy.position, HIT_RADIUS):
			if _apply_conversion:
				# T-Rex (can_be_converted() == false) rejects Conversion and
				# also takes no damage from this shot — nothing happens to it.
				if enemy.has_method("can_be_converted") and enemy.has_method("convert_to_friendly") and enemy.can_be_converted():
					enemy.convert_to_friendly()
			elif enemy.has_method("take_damage"):
				enemy.take_damage(damage)
			_start_explosion()
			return

	if _lifetime >= MAX_LIFETIME:
		queue_free()

func _segment_hits_point(a: Vector2, b: Vector2, point: Vector2, radius: float) -> bool:
	var segment: Vector2 = b - a
	var length_sq: float = segment.length_squared()
	if length_sq <= 0.001:
		return a.distance_to(point) <= radius
	var t = clampf((point - a).dot(segment) / length_sq, 0.0, 1.0)
	var closest: Vector2 = a + segment * t
	return closest.distance_to(point) <= radius

func _start_explosion() -> void:
	if _exploding:
		return
	_exploding = true
	animated_sprite.play("explode")

func _on_sprite_2d_animation_finished() -> void:
	if _exploding and animated_sprite.animation == "explode":
		queue_free()
