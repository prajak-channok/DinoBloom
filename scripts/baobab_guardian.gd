extends Node2D
class_name BaobabGuardian

const DATA: PlantData = preload("res://data/plants/baobab_guardian.tres")
const DESIGN_CELL_HEIGHT: float = 104.0

# Number of damage-stage frames baked into BaobabGuardianDamage.png (1 row x 4 columns).
# The guardian steps to the next frame every time it loses another 25% of its HP.
const STAGE_COUNT: int = 4
# How long a hit's frame-to-frame crossfade takes, so the change reads as a
# gradual transition instead of a hard cut.
const STAGE_FADE_TIME: float = 0.3
# How long to hold on the final (mostly-gone) frame before the node is freed.
const DEATH_LINGER_TIME: float = 0.45

@export var idle_bob_height: float = 2.0
@export var idle_bob_speed: float = 0.5

@onready var visual: Node2D = $Visual
@onready var sprite: AnimatedSprite2D = $Visual/Sprite2D
@onready var sprite_next: AnimatedSprite2D = $Visual/SpriteNext
@onready var interaction_shape: CollisionShape2D = $InteractionArea/CollisionShape2D

var grid_row: int = -1
var grid_column: int = -1
var _hp: float = 0.0
var _base_position: Vector2
var _base_scale: Vector2
var _sprite_base_scale: Vector2
var _time: float = 0.0
var _stage: int = 0
var _dying: bool = false
var _stage_tween: Tween

func _ready() -> void:
	add_to_group("plants")
	_base_position = visual.position
	_base_scale = visual.scale
	_sprite_base_scale = sprite.scale
	_hp = _get_hp()
	sprite.animation = &"damage"
	sprite_next.animation = &"damage"
	sprite.frame = 0
	sprite_next.frame = 0
	sprite_next.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_stage = 0

func setup(gameplay: Node, row: int) -> void:
	grid_row = row
	_hp = _get_hp()
	add_to_group("plants")

func _get_hp() -> float:
	var final_stats: Variant = PlantProgression.get_final_stats(DATA.id)
	return final_stats.hp if final_stats != null else DATA.base_hp

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

func get_interaction_rect() -> Rect2:
	return Rect2(position - interaction_shape.shape.size * 0.5, interaction_shape.shape.size)

func take_damage(amount: float) -> void:
	if _dying:
		return
	_hp -= amount
	_play_hit_flash()

	# Advance one frame every full 25% chunk of HP lost (100-76% = stage 0,
	# 75-51% = stage 1, 50-26% = stage 2, 25-0% = stage 3).
	var ratio: float = clamp(_hp / DATA.base_hp, 0.0, 1.0)
	var target_stage: int = int(floor((1.0 - ratio) * float(STAGE_COUNT)))
	target_stage = clamp(target_stage, 0, STAGE_COUNT - 1)
	if target_stage != _stage:
		_transition_to_stage(target_stage)

	if _hp <= 0.0:
		_die()

func get_hp() -> float:
	return _hp

# Crossfades from the currently shown damage frame to `stage`, so repeated
# hits read as the guardian gradually withering rather than snapping between
# looks.
func _transition_to_stage(stage: int) -> void:
	_stage = stage
	sprite_next.frame = stage
	sprite_next.modulate = Color(1.0, 1.0, 1.0, 0.0)
	sprite_next.visible = true

	if _stage_tween and _stage_tween.is_valid():
		_stage_tween.kill()

	_stage_tween = create_tween()
	_stage_tween.tween_property(sprite_next, "modulate:a", 1.0, STAGE_FADE_TIME) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_stage_tween.finished.connect(_on_stage_transition_finished.bind(stage))

func _on_stage_transition_finished(stage: int) -> void:
	sprite.frame = stage
	sprite.modulate.a = 1.0
	sprite_next.modulate.a = 0.0

# Quick punch/flash so every hit feels responsive even when it doesn't cross
# into a new damage stage.
func _play_hit_flash() -> void:
	var flash := create_tween()
	flash.tween_property(sprite, "scale", _sprite_base_scale * 1.06, 0.05) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	flash.parallel().tween_property(sprite, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.05)
	flash.tween_property(sprite, "scale", _sprite_base_scale, 0.15) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	flash.parallel().tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, sprite.modulate.a), 0.15)

func _die() -> void:
	if _dying:
		return
	_dying = true
	_transition_to_stage(STAGE_COUNT - 1)
	await get_tree().create_timer(STAGE_FADE_TIME + DEATH_LINGER_TIME).timeout
	queue_free()
