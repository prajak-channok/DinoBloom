# projectile.gd - กระสุนหนามที่พืชยิงออกมาทำความเสียหายแก่ไดโนเสาร์
extends Node2D

var lane: int = 0
var speed: float = 300.0
var damage: int = 25

func _ready() -> void:
	var visual = ColorRect.new()
	visual.size = Vector2(16, 8)
	visual.position = Vector2(-8, -4)
	visual.color = Color(0.9, 0.9, 0.1)
	add_child(visual)

func _process(delta: float) -> void:
	position.x += speed * delta
	
	# ทำลายเมื่อลอยออกนอกหน้าจอ
	if position.x > 1300:
		queue_free()
		return
		
	_check_hit()

func _check_hit() -> void:
	var dinos_holder = get_parent().get_node("../DinosHolder")
	for dino in dinos_holder.get_children():
		if dino.lane == lane and abs(dino.global_position.x - global_position.x) < 25:
			dino.take_damage(damage)
			queue_free()
			break
