extends Node2D
class_name BaobabGuardian

const DATA: PlantData = preload("res://data/plants/baobab_guardian.tres")
const DESIGN_CELL_HEIGHT: float = 104.0

@export var idle_bob_height: float = 2.0
@export var idle_bob_speed: float = 0.5

@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite2D
@onready var interaction_shape: CollisionShape2D = $InteractionArea/CollisionShape2D

var grid_row: int = -1
var grid_column: int = -1
var _hp: float = 0.0
var _base_position: Vector2
var _base_scale: Vector2
var _time: float = 0.0

func _ready() -> void:
	add_to_group("plants")
	_base_position = visual.position
	_base_scale = visual.scale
	_hp = DATA.base_hp

func setup(gameplay: Node, row: int) -> void:
	grid_row = row
	_hp = DATA.base_hp
	add_to_group("plants")

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
	_hp -= amount
	if _hp <= 0.0:
		queue_free()

func get_hp() -> float:
	return _hp
