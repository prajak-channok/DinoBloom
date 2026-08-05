# game_level.gd - จัดการระบบกระดาน 5 เลน, การวางพืช, และการเกิดของไดโนเสาร์
extends Node2D

const LANES: int = 5
const COLS: int = 8
const CELL_WIDTH: float = 130.0
const CELL_HEIGHT: float = 110.0

enum PlantType { NONE, SEED_BLOOM, THORN_FERN }
var selected_plant_type: PlantType = PlantType.NONE

# บันทึกสถานะพืชบนตาราง [lane][col]
var grid_matrix: Array = []

@onready var grid_container: Node2D = $GridContainer
@onready var plants_holder: Node2D = $PlantsHolder
@onready var dinos_holder: Node2D = $DinosHolder
@onready var projectiles_holder: Node2D = $ProjectilesHolder

@onready var seed_label: Label = $CanvasLayer/HUD/TopPanel/HBoxContainer/SeedLabel
@onready var base_hp_label: Label = $CanvasLayer/HUD/TopPanel/HBoxContainer/BaseHPLabel
@onready var seed_bloom_btn: Button = $CanvasLayer/HUD/TopPanel/HBoxContainer/PlantSelector/SeedBloomBtn
@onready var thorn_fern_btn: Button = $CanvasLayer/HUD/TopPanel/HBoxContainer/PlantSelector/ThornFernBtn
@onready var back_btn: Button = $CanvasLayer/HUD/TopPanel/HBoxContainer/BackButton
@onready var game_over_panel: Panel = $CanvasLayer/HUD/GameOverPanel
@onready var status_label: Label = $CanvasLayer/HUD/GameOverPanel/VBox/StatusLabel
@onready var restart_btn: Button = $CanvasLayer/HUD/GameOverPanel/VBox/RestartBtn
@onready var menu_btn: Button = $CanvasLayer/HUD/GameOverPanel/VBox/MenuBtn
@onready var dino_spawn_timer: Timer = $DinoSpawnTimer

func _ready() -> void:
	_init_grid()
	
	GameManager.seeds_changed.connect(_on_seeds_changed)
	GameManager.base_health_changed.connect(_on_base_hp_changed)
	GameManager.game_over.connect(_on_game_over)
	
	seed_bloom_btn.pressed.connect(func(): selected_plant_type = PlantType.SEED_BLOOM)
	thorn_fern_btn.pressed.connect(func(): selected_plant_type = PlantType.THORN_FERN)
	back_btn.pressed.connect(_go_to_menu)
	restart_btn.pressed.connect(_restart_game)
	menu_btn.pressed.connect(_go_to_menu)
	dino_spawn_timer.timeout.connect(_spawn_dinosaur)
	
	_update_ui()

func _init_grid() -> void:
	grid_matrix.clear()
	for lane in range(LANES):
		var row: Array = []
		for col in range(COLS):
			row.append(null)
			# สร้างช่องสี่เหลี่ยมแสดงตำแหน่งเลน
			var cell_rect := ColorRect.new()
			cell_rect.size = Vector2(CELL_WIDTH - 6, CELL_HEIGHT - 6)
			cell_rect.position = Vector2(col * CELL_WIDTH, lane * CELL_HEIGHT)
			cell_rect.color = Color(0.25, 0.42, 0.3, 0.6) if (lane + col) % 2 == 0 else Color(0.2, 0.38, 0.25, 0.6)
			cell_rect.gui_input.connect(_on_cell_clicked.bind(lane, col))
			grid_container.add_child(cell_rect)
		grid_matrix.append(row)

func _on_cell_clicked(event: InputEvent, lane: int, col: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_plant_type == PlantType.NONE or grid_matrix[lane][col] != null:
			return
			
		var cost: int = 50 if selected_plant_type == PlantType.SEED_BLOOM else 100
		if GameManager.ancient_seeds >= cost:
			GameManager.ancient_seeds -= cost
			_place_plant(lane, col, selected_plant_type)
			selected_plant_type = PlantType.NONE

func _place_plant(lane: int, col: int, p_type: PlantType) -> void:
	var plant_script = load("res://scripts/plant.gd")
	var plant_node = Node2D.new()
	plant_node.set_script(plant_script)
	
	var pos_x = grid_container.position.x + col * CELL_WIDTH + (CELL_WIDTH / 2)
	var pos_y = grid_container.position.y + lane * CELL_HEIGHT + (CELL_HEIGHT / 2)
	plant_node.position = Vector2(pos_x, pos_y)
	
	plant_node.setup(lane, col, p_type)
	plants_holder.add_child(plant_node)
	grid_matrix[lane][col] = plant_node

func _spawn_dinosaur() -> void:
	var lane = randi() % LANES
	var dino_script = load("res://scripts/dinosaur.gd")
	var dino_node = Node2D.new()
	dino_node.set_script(dino_script)
	
	var pos_x = grid_container.position.x + COLS * CELL_WIDTH + 40
	var pos_y = grid_container.position.y + lane * CELL_HEIGHT + (CELL_HEIGHT / 2)
	dino_node.position = Vector2(pos_x, pos_y)
	
	# สุ่มชนิดไดโนเสาร์ (Dodo หรือ Velociraptor)
	var dino_type = "Dodo" if randf() > 0.4 else "Velociraptor"
	dino_node.setup(lane, dino_type)
	dinos_holder.add_child(dino_node)

func _on_seeds_changed(amount: int) -> void:
	seed_label.text = "Ancient Seeds: " + str(amount)

func _on_base_hp_changed(hp: int) -> void:
	base_hp_label.text = "Base HP: " + str(hp) + "/100"

func _update_ui() -> void:
	_on_seeds_changed(GameManager.ancient_seeds)
	_on_base_hp_changed(GameManager.base_health)

func _on_game_over() -> void:
	dino_spawn_timer.stop()
	status_label.text = "GAME OVER"
	game_over_panel.visible = true

func _restart_game() -> void:
	GameManager.reset_game()
	get_tree().reload_current_scene()

func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
