# plant.gd - โค้ดพฤติกรรมพืช (Seed Bloom & Thorn Fern)
extends Node2D

var lane: int = 0
var col: int = 0
var plant_type: int = 1
var hp: int = 100

var action_timer: float = 0.0
var action_cooldown: float = 3.0

func setup(p_lane: int, p_col: int, p_type: int) -> void:
	lane = p_lane
	col = p_col
	plant_type = p_type

func _process(delta: float) -> void:
	action_timer += delta
	if action_timer >= action_cooldown:
		action_timer = 0.0
		_perform_action()

func _perform_action() -> void:
	if plant_type == 1: # Seed Bloom - เพิ่มทรัพยากร
		GameManager.ancient_seeds += 25
	elif plant_type == 2: # Thorn Fern - ยิงกระสุนหนามไปข้างหน้า
		_shoot_projectile()

func _shoot_projectile() -> void:
	var proj_script = load("res://Scripts/projectile.gd")
	var proj_node = Node2D.new()
	proj_node.set_script(proj_script)
	proj_node.position = global_position
	proj_node.lane = lane
	get_parent().get_node("../ProjectilesHolder").add_child(proj_node)

func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		# เคลียร์ข้อมูลตำแหน่งในตารางเมื่อถูกทำลาย
		var game_level = get_tree().current_scene
		if game_level and "grid_matrix" in game_level:
			game_level.grid_matrix[lane][col] = null
		queue_free()
