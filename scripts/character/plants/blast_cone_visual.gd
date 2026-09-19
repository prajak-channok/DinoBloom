extends Node2D
class_name BlastConeVisual

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const ANIMATION_NAME: String = "blast"
const DESIGN_DIAMETER: float = 104.0

func _ready() -> void:
	animated_sprite.play(ANIMATION_NAME)

func setup(effect_range: float, cell_size: Vector2) -> void:
	var diameter: float = minf(cell_size.x, cell_size.y) * effect_range
	var target_scale_x: float = diameter / DESIGN_DIAMETER
	var target_scale_y: float = 1.3

	scale = Vector2(target_scale_x, target_scale_y)

	animated_sprite.position.y = -(DESIGN_DIAMETER * 0.5) * (target_scale_y - 1.0)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == ANIMATION_NAME:
		queue_free()
