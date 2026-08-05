# dinosaur.gd - โค้ดพฤติกรรมของไดโนเสาร์ (เคลื่อนที่, โจมตีพืช/ฐาน)
extends Node2D

var lane: int = 0
var speed: float = 40.0
var hp: int = 80
var attack_power: int = 20
var dino_name: String = "Dodo"

var attack_timer: float = 0.0
var is_attacking: bool = false
var target_plant: Node2D = null

func setup(p_lane: int, type_name: String) -> void:
	lane = p_lane
	dino_name = type_name
	
	if dino_name == "Velociraptor":
		speed = 70.0
		hp = 60
		attack_power = 15
	else:
		speed = 35.0
		hp = 100
		attack_power = 25
		
	var visual = ColorRect.new()
	visual.size = Vector2(50, 50)
	visual.position = Vector2(-25, -25)
	visual.color = Color(0.8, 0.3, 0.2) if dino_name == "Velociraptor" else Color(0.6, 0.4, 0.2)
	add_child(visual)

func _process(delta: float) -> void:
	if is_attacking:
		attack_timer += delta
		if attack_timer >= 1.0:
			attack_timer = 0.0
			if is_instance_valid(target_plant):
				target_plant.take_damage(attack_power)
			else:
				is_attacking = false
				target_plant = null
	else:
		position.x -= speed * delta
		_check_collisions()

func _check_collisions() -> void:
	# ตรวจสอบการเดินไปถึงฐาน Tree of Evolution
	if position.x <= 140:
		GameManager.base_health -= attack_power
		queue_free()
		return

	# ตรวจสอบว่ามีพืชขวางทางในเลนเดียวกันหรือไม่
	var plants_holder = get_parent().get_node("../PlantsHolder")
	for plant in plants_holder.get_children():
		if plant.lane == lane and abs(plant.global_position.x - global_position.x) < 35:
			is_attacking = true
			target_plant = plant
			break

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()
