extends Node2D
class_name GameplayScene
## Main gameplay scene: board, plant placement, and the M4 Match/Wave/Spawn loop.
##
## Layout architecture:
## - Logical canvas: 1500 x 844.
## - PlayArea: 1280 x 720 (16:9), positioned at (220, 124).
## - UI is outside PlayArea: PlantPanel on the left, TopBar above.
## - World entities use PlayArea-local coordinates only.
## - Background fills the PlayArea when the source asset is 16:9.
## - Non-16:9 source assets are aspect-preserved and letterboxed inside PlayArea;
##   the board is calculated from the actually displayed background rect, so it
##   never spills into the letterbox or decoration outside the background.

const ROWS := 5
const COLUMNS := 8
const PLAY_AREA_SIZE := Vector2(1280.0, 720.0)
const LEFT_PANEL_WIDTH := 220.0
const TOP_BAR_HEIGHT := 124.0
const DESIGN_CANVAS_SIZE := Vector2(1500.0, 844.0)
const MAX_SEED := 1000
const TARGET_ASPECT := 16.0 / 9.0

const STAGE_DATA := {
	"stage_01": preload("res://data/stages/stage_01.tres"),
	"stage_02": preload("res://data/stages/stage_02.tres"),
	"stage_03": preload("res://data/stages/stage_03.tres")
}

const PLANT_DATA := {
	"Seed Bloom": preload("res://data/plants/seed_bloom.tres"),
	"Thorn Fern": preload("res://data/plants/thorn_fern.tres"),
	"Baobab Guardian": preload("res://data/plants/baobab_guardian.tres"),
	"Ginkgo Cannon": preload("res://data/plants/ginkgo_cannon.tres"),
	"Horsetail": preload("res://data/plants/horsetail.tres"),
	"Sticky Moss": preload("res://data/plants/sticky_moss.tres"),
	"Blast Cone": preload("res://data/plants/blast_cone.tres")
}

const PLANT_SCENES := {
	"Seed Bloom": "res://scenes/plants/seed_bloom.tscn",
	"Thorn Fern": "res://scenes/plants/thorn_fern.tscn",
	"Baobab Guardian": "res://scenes/plants/baobab_guardian.tscn",
	"Ginkgo Cannon": "res://scenes/plants/ginkgo_cannon.tscn",
	"Horsetail": "res://scenes/plants/horsetail.tscn",
	"Sticky Moss": "res://scenes/plants/sticky_moss.tscn",
	"Blast Cone": "res://scenes/plants/blast_cone.tscn"
}

const PLANT_TEXTURES := {
	"Seed Bloom": "res://assets/Plants/SeedBloomNBG.PNG",
	"Thorn Fern": "res://assets/Plants/ThornFernNBG.png",
	"Baobab Guardian": "res://assets/Plants/BaobabGuardianNBG.png",
	"Ginkgo Cannon": "res://assets/Plants/GinkgoCannonNBG.png",
	"Horsetail": "res://assets/Plants/HorsetailNBG.png",
	"Sticky Moss": "res://assets/Plants/StickyMossNBG.png",
	"Blast Cone": "res://assets/Plants/BlastConeNBG.png"
}

@onready var place_sound: AudioStreamPlayer = $PlantPlaceSound
@onready var play_area: Control = $PlayArea
@onready var world: Node2D = $PlayArea/World
@onready var background: TextureRect = $PlayArea/Background
@onready var board_visual: StageBoardVisual = $PlayArea/World/BoardVisual
@onready var board: StageBoard = $PlayArea/World/Board
@onready var placement_preview: ColorRect = $PlayArea/World/PlacementPreview
@onready var plant_cards: VBoxContainer = $UI/PlantPanel/Margin/VBox/Cards
@onready var seed_label: Label = $UI/TopBar/Content/HBox/SeedLabel
@onready var status_label: Label = $UI/TopBar/Content/HBox/StatusLabel
@onready var debug_label: Label = $DebugOverlay/DebugLabel
@onready var debug_panel: PanelContainer = $DebugOverlay/Panel

# --- M4: Match/Wave/Spawn systems ---
@onready var wave_manager: WaveManager = $Systems/WaveManager
@onready var spawn_manager: SpawnManager = $Systems/SpawnManager
@onready var match_manager: MatchManager = $Systems/MatchManager

@onready var wave_label: Label = $UI/TopBar/Content/HBox/WaveLabel
@onready var pause_button: Button = $UI/TopBar/Content/HBox/PauseButton
@onready var speed_button: Button = $UI/TopBar/Content/HBox/SpeedButton
@onready var remove_plant_button: Button = $UI/TopBar/Content/HBox/RemovePlantButton
@onready var boss_hp_bar_container: PanelContainer = $UI/BossHPBar
@onready var boss_hp_bar: ProgressBar = $UI/BossHPBar/Margin/HBox/BossBar

@onready var wave_start_popup: Control = $Popups/WaveStartPopup
@onready var wave_start_label: Label = $Popups/WaveStartPopup/Label
@onready var wave_clear_popup: Control = $Popups/WaveClearPopup
@onready var wave_clear_title: Label = $Popups/WaveClearPopup/Panel/VBox/Title
@onready var wave_clear_dna: Label = $Popups/WaveClearPopup/Panel/VBox/DnaLabel
@onready var wave_clear_countdown: Label = $Popups/WaveClearPopup/Panel/VBox/CountdownLabel
@onready var win_popup: Control = $Popups/WinPopup
@onready var win_button: Button = $Popups/WinPopup/Panel/VBox/Hbox/BackButton
@onready var win_next_button: Button = $Popups/WinPopup/Panel/VBox/Hbox/NextButton
@onready var lose_popup: Control = $Popups/LosePopup
@onready var lose_button: Button = $Popups/LosePopup/Panel/VBox/BackButton
@onready var surrender_popup: Control = $Popups/SurrenderPopup
@onready var surrender_confirm_button: Button = $Popups/SurrenderPopup/Panel/VBox/ButtonRow/ConfirmButton
@onready var surrender_cancel_button: Button = $Popups/SurrenderPopup/Panel/VBox/ButtonRow/CancelButton
@onready var paused_overlay: Control = $Popups/PausedOverlay
@onready var resume_button: Button = $Popups/PausedOverlay/Panel/VBox/ButtonRow/ResumeButton
@onready var abandon_button: Button = $Popups/PausedOverlay/Panel/VBox/ButtonRow/AbandonButton

var selected_stage_id := "stage_01"
var selected_plant := ""
var remove_mode := false
var ancient_seed := 100
var _card_buttons: Dictionary = {}
var _card_cost_labels: Dictionary = {}
var _plant_cooldowns: Dictionary = {}
## M4: each entry is {"node": Node2D, "cost": int} so a right-click can
## refund floor(cost * 0.5) Ancient Seed (requirement #25) without adding a
## second lookup table.
var _occupied: Dictionary = {}
var _preview_grid := Vector2i(-1, -1)
var debug_grid_enabled := false
var _warned_background_aspect: Dictionary = {}

func _ready() -> void:
	selected_stage_id = GameManager.selected_stage_id
	if not STAGE_DATA.has(selected_stage_id):
		selected_stage_id = "stage_01"

	# --- 1. สร้างดีไซน์ปุ่มตอนกด (สีดำ + มุมมน) ---
	var custom_pressed = StyleBoxFlat.new()
	custom_pressed.bg_color = Color(0, 0, 0, 1) # สีดำทึบ
	
	# ตั้งค่าความมน (ปรับเลข 15 ให้เข้ากับปุ่มในหน้านี้)
	var corner = 15 
	custom_pressed.corner_radius_top_left = corner
	custom_pressed.corner_radius_top_right = corner
	custom_pressed.corner_radius_bottom_left = corner
	custom_pressed.corner_radius_bottom_right = corner
	
	# --- 2. นำปุ่มทั้งหมดในหน้านี้มาใส่ใน Array ---
	# ข้อควรระวัง: ถ้าคุณมีปุ่ม Pause หรือ 1x ให้เพิ่มตัวแปรปุ่มเหล่านั้นเข้ามาในนี้ด้วย (คั่นด้วยลูกน้ำ)
	var all_buttons: Array[Button] = [
		remove_plant_button,
		pause_button, 
		speed_button,
		win_button,
		lose_button,
		surrender_confirm_button,
		surrender_cancel_button,
		resume_button,
		abandon_button
	]
	
	# --- 3. วนลูปยัดสไตล์ตอนกดลงไปให้ทุกปุ่ม ---
	for btn in all_buttons:
		if btn:
			btn.add_theme_stylebox_override("pressed", custom_pressed)

	# --- โค้ดเดิมของคุณ ---
	_build_plant_cards()
	_update_seed_label()
	_update_status("เลือก Plant แล้วคลิกช่องบนสนามเพื่อวาง")
	placement_preview.visible = false
	_layout_gameplay()
	remove_plant_button.pressed.connect(_on_toggle_remove_mode)
	_update_remove_button_visual()
	_start_match()

func _start_match() -> void:
	var stage: StageData = STAGE_DATA[selected_stage_id]
	spawn_manager.setup(world, board)

	var ui := {
		"wave_label": wave_label,
		"boss_bar_container": boss_hp_bar_container,
		"boss_bar": boss_hp_bar,
		"pause_button": pause_button,
		"speed_button": speed_button,
		"surrender_button": abandon_button,
		"resume_button": resume_button,
		"wave_start_popup": wave_start_popup,
		"wave_start_label": wave_start_label,
		"wave_clear_popup": wave_clear_popup,
		"wave_clear_title": wave_clear_title,
		"wave_clear_dna": wave_clear_dna,
		"wave_clear_countdown": wave_clear_countdown,
		"win_popup": win_popup,
		"win_button": win_button,
		"win_next_button": win_next_button,
		"lose_popup": lose_popup,
		"lose_button": lose_button,
		"surrender_popup": surrender_popup,
		"surrender_confirm_button": surrender_confirm_button,
		"surrender_cancel_button": surrender_cancel_button,
		"paused_overlay": paused_overlay,
	}

	match_manager.setup(self, wave_manager, spawn_manager, stage, selected_stage_id, ui)
	match_manager.start_match()

func _process(delta: float) -> void:
	_update_plant_cooldowns(delta)

	var stale_cells: Array[Vector2i] = []
	for grid in _occupied.keys():
		var entry: Dictionary = _occupied[grid]
		if not is_instance_valid(entry.get("node")):
			stale_cells.append(grid)
	for grid in stale_cells:
		_occupied.erase(grid)

func _update_plant_cooldowns(delta: float) -> void:
	var changed := false
	for plant_name in _plant_cooldowns.keys():
		_plant_cooldowns[plant_name] = maxf(0.0, float(_plant_cooldowns[plant_name]) - delta)
		changed = true
		if _plant_cooldowns[plant_name] <= 0.0:
			_plant_cooldowns.erase(plant_name)
	if changed:
		_update_card_states()

func _layout_gameplay() -> void:
	# PlayArea is the stable 16:9 gameplay coordinate space. It does not shrink
	# when UI changes; UI is an outer shell around it.
	play_area.position = Vector2(LEFT_PANEL_WIDTH, TOP_BAR_HEIGHT)
	play_area.size = PLAY_AREA_SIZE

	background.position = Vector2.ZERO
	background.size = PLAY_AREA_SIZE

	var stage: StageData = STAGE_DATA[selected_stage_id]
	background.texture = stage.background

	var displayed_background := _get_displayed_background_rect(stage.background)
	var board_rect := Rect2(
		displayed_background.position + stage.gameplay_area_normalized.position * displayed_background.size,
		stage.gameplay_area_normalized.size * displayed_background.size
	)

	board_visual.setup(board_rect, stage.tile_a, stage.tile_b)
	board.configure(board_rect, debug_grid_enabled)

	if stage.background != null:
		var aspect := float(stage.background.get_width()) / float(stage.background.get_height())
		if absf(aspect - TARGET_ASPECT) > 0.01 and not _warned_background_aspect.has(stage.stage_id):
			_warned_background_aspect[stage.stage_id] = true
			push_warning("%s background is %.3f:1, not 16:9. It is currently stretched to fill the 1280x720 PlayArea; replace it with a 16:9 asset for undistorted presentation." % [stage.stage_id, aspect])

func _get_displayed_background_rect(texture: Texture2D) -> Rect2:
	if texture == null:
		return Rect2()
	# Background is intentionally stretched to the PlayArea bounds. The game
	# design requires the field to occupy every pixel left after the UI. The
	# intended production assets are 16:9 (for example 2560x1440), so there is
	# no distortion when the correct aspect-ratio assets are used.
	return Rect2(Vector2.ZERO, PLAY_AREA_SIZE)

func _build_plant_cards() -> void:
	for child in plant_cards.get_children():
		child.queue_free()

	_card_buttons.clear()
	_card_cost_labels.clear()

	for plant_name in ["Seed Bloom", "Thorn Fern", "Baobab Guardian", "Ginkgo Cannon", "Horsetail", "Sticky Moss", "Blast Cone"]:
		var data: PlantData = PLANT_DATA[plant_name]

		if not SaveManager.is_plant_unlocked(data.id):
			continue

		var card := PanelContainer.new()
		card.name = plant_name.replace(" ", "") + "Card"
		card.custom_minimum_size = Vector2(0, 60)
		card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", _make_card_style(false))

		var button := Button.new()
		button.name = "SelectButton"
		button.flat = true
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(_on_plant_card_pressed.bind(plant_name))
		card.add_child(button)

		var icon := TextureRect.new()
		icon.name = "Icon"
		icon.texture = load(PLANT_TEXTURES[plant_name])
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 12.0
		icon.offset_top = 8.0
		icon.offset_right = -12.0
		icon.offset_bottom = -8.0
		button.add_child(icon)

		# Cost/cooldown label is kept (hidden) so _update_card_states() can keep
		# writing cooldown text/color without needing a separate code path;
		# only the icon is shown per the card's icon-only presentation.
		var cost_label := Label.new()
		cost_label.name = "CostLabel"
		
		# 1. กางพื้นที่ Label ให้คลุมเต็มปุ่ม
		cost_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		# 2. จัดให้ตัวอักษรไปชิดมุมขวาล่าง
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		cost_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		
		# 3. หดขอบขวาและขอบล่างเข้ามานิดนึง เพื่อไม่ให้ตัวเลขเบียดเส้นขอบเกินไป
		cost_label.offset_right = -12.0
		cost_label.offset_bottom = -2.0
		
		# ตกแต่งตัวอักษรให้อ่านง่าย
		cost_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		cost_label.add_theme_constant_override("outline_size", 4)
		cost_label.add_theme_font_size_override("font_size", 14) 
		
		button.add_child(cost_label)

		plant_cards.add_child(card)
		_card_buttons[plant_name] = card
		_card_cost_labels[plant_name] = cost_label

	_update_card_states()

func _make_card_style(selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.13, 0.08, 0.96) if not selected else Color(0.20, 0.25, 0.10, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.48, 0.50, 0.28, 1.0) if not selected else Color(0.95, 0.84, 0.42, 1.0)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	return style

## Placement Cost/Cooldown reflect the plant's current Upgrade level; PlantData
## stays the fallback only if PlantProgression has no Final Stat for it.
func _get_placement_stats(plant_name: String) -> Dictionary:
	var data: PlantData = PLANT_DATA[plant_name]
	var final_stats: Variant = PlantProgression.get_final_stats(data.id)
	if final_stats == null:
		return {"cost": data.placement_cost, "cooldown": data.placement_cooldown}
	return {"cost": final_stats.placement_cost, "cooldown": final_stats.placement_cooldown}

func _update_card_states() -> void:
	for plant_name in _card_buttons:
		var card: PanelContainer = _card_buttons[plant_name]
		var button := card.get_node("SelectButton") as Button
		var stats: Dictionary = _get_placement_stats(plant_name)
		var cooldown := float(_plant_cooldowns.get(plant_name, 0.0))
		var ready := cooldown <= 0.0
		button.disabled = not ready

		if cooldown > 0.0:
			# ตอนติดคูลดาวน์ โชว์เป็นตัวเลขวินาที
			_card_cost_labels[plant_name].text = "%.1fs" % cooldown 
			_card_cost_labels[plant_name].add_theme_color_override("font_color", Color(0.75, 0.75, 0.75, 1.0))
		else:
			# ตอนพร้อมใช้ โชว์แค่ตัวเลขราคาเพียวๆ (ถ้าอยากได้ไอคอนต้องใช้ HBoxContainer แทน แต่แบบนี้จะง่ายและคลีนกว่า)
			_card_cost_labels[plant_name].text = str(stats.cost) 
			_card_cost_labels[plant_name].add_theme_color_override("font_color", Color(0.94, 0.84, 0.45, 1.0))

		card.add_theme_stylebox_override("panel", _make_card_style(plant_name == selected_plant))

func _on_plant_card_pressed(plant_name: String) -> void:
	if selected_plant == plant_name:
		selected_plant = ""
		placement_preview.visible = false
		_update_status("เลือก Plant แล้วคลิกช่องบนสนามเพื่อวาง")
		_update_card_states()
		return
	
	var stats: Dictionary = _get_placement_stats(plant_name)
	if float(_plant_cooldowns.get(plant_name, 0.0)) > 0.0:
		return
	if ancient_seed < stats.cost:
		_update_status("Ancient Seed ไม่พอ")
		return

	if remove_mode:
		_set_remove_mode(false)
	selected_plant = plant_name
	_update_status("กำลังวาง %s — เลือกช่องบนสนาม" % plant_name)
	_update_card_states()

func _on_toggle_remove_mode() -> void:
	_set_remove_mode(not remove_mode)

func _set_remove_mode(enabled: bool) -> void:
	remove_mode = enabled
	if remove_mode:
		selected_plant = ""
		placement_preview.visible = false
		_update_card_states()
		_update_status("โหมดถอนพืช: คลิกพืชที่ต้องการถอน")
	else:
		_update_status("เลือก Plant แล้วคลิกช่องบนสนามเพื่อวาง")
	_update_remove_button_visual()

func _update_remove_button_visual() -> void:
	if remove_plant_button == null:
		return
	remove_plant_button.text = "ถอนพืช: ON" if remove_mode else "ถอนพืช"
	remove_plant_button.add_theme_color_override("font_color", Color(0.95, 0.35, 0.3, 1.0) if remove_mode else Color(1, 1, 1, 1))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_preview(play_area.get_local_mouse_position())
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if remove_mode:
			_try_remove_plant(play_area.get_local_mouse_position())
		elif selected_plant != "":
			_try_place(play_area.get_local_mouse_position())
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_try_remove_plant(play_area.get_local_mouse_position())
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			debug_grid_enabled = not debug_grid_enabled
			board.configure(board.board_rect, debug_grid_enabled)
			debug_label.visible = debug_grid_enabled
			debug_panel.visible = debug_grid_enabled

func _update_preview(play_position: Vector2) -> void:
	if remove_mode:
		var remove_grid := board.world_to_grid(play_position)
		if remove_grid.x < 0 or not _occupied.has(remove_grid):
			placement_preview.visible = false
			return
		var remove_cell_size := board.get_cell_size()
		placement_preview.position = board.grid_to_world(remove_grid.x, remove_grid.y) - remove_cell_size * 0.5
		placement_preview.size = remove_cell_size
		placement_preview.color = Color(0.95, 0.25, 0.2, 0.28)
		placement_preview.visible = true
		return

	if selected_plant == "":
		placement_preview.visible = false
		return

	var grid := board.world_to_grid(play_position)
	if grid.x < 0:
		placement_preview.visible = false
		return

	_preview_grid = grid
	var cell_size := board.get_cell_size()
	placement_preview.position = board.grid_to_world(grid.x, grid.y) - cell_size * 0.5
	placement_preview.size = cell_size
	placement_preview.visible = true
	placement_preview.color = Color(0.2, 0.95, 0.35, 0.22) if _is_cell_available(grid) else Color(0.95, 0.2, 0.2, 0.22)

func _try_place(play_position: Vector2) -> void:
	var grid := board.world_to_grid(play_position)
	if grid.x < 0:
		return
	if not _is_cell_available(grid):
		_update_status("ช่องนี้ถูกใช้งานแล้ว")
		return

	var stats: Dictionary = _get_placement_stats(selected_plant)
	if ancient_seed < stats.cost:
		_update_status("Ancient Seed ไม่พอ")
		return
	if float(_plant_cooldowns.get(selected_plant, 0.0)) > 0.0:
		return

	var scene: PackedScene = load(PLANT_SCENES[selected_plant])
	if scene == null:
		push_error("Unable to load plant scene: %s" % PLANT_SCENES[selected_plant])
		return

	var plant: Node2D = scene.instantiate() as Node2D
	if plant == null:
		push_error("Plant scene root is not Node2D: %s" % PLANT_SCENES[selected_plant])
		return

	plant.position = board.grid_to_world(grid.x, grid.y)
	world.add_child(plant)

	if plant.has_method("set_grid_cell"):
		plant.set_grid_cell(grid.x, grid.y, board.get_cell_size())

	if plant.has_method("setup_combat"):
		plant.setup_combat(world, grid.x)
	elif plant.has_method("setup"):
		plant.setup(self, grid.x)

	if plant.has_signal("seed_generated"):
		plant.seed_generated.connect(_on_seed_generated)

	ancient_seed -= stats.cost
	_occupied[grid] = {"node": plant, "cost": stats.cost}
	_plant_cooldowns[selected_plant] = stats.cooldown
	_update_seed_label()
	_update_status("%s วางแล้ว" % selected_plant)
	selected_plant = ""
	placement_preview.visible = false
	_update_card_states()
	
	if place_sound:
		place_sound.play()

## M4: Ancient Seed Refund (requirement #25). Right-click a placed plant to
## withdraw it for floor(cost * 0.5) Ancient Seed back, rounded down.
func _try_remove_plant(play_position: Vector2) -> void:
	var grid := board.world_to_grid(play_position)
	if grid.x < 0 or not _occupied.has(grid):
		return

	var entry: Dictionary = _occupied[grid]
	var plant_node: Node2D = entry.get("node")
	_occupied.erase(grid)
	if not is_instance_valid(plant_node):
		return

	var cost := int(entry.get("cost", 0))
	var refund := floori(cost * 0.5)
	plant_node.queue_free()
	add_seed(refund)
	_update_status("ถอน Plant คืน %d Ancient Seed" % refund)
	
	if place_sound:
		place_sound.play()

func _is_cell_available(grid: Vector2i) -> bool:
	return not _occupied.has(grid)

func add_seed(amount: int) -> void:
	ancient_seed = mini(MAX_SEED, ancient_seed + amount)
	_update_seed_label()

func _on_seed_generated(amount: int) -> void:
	_update_status("Seed Bloom ผลิต +%d Ancient Seed" % amount)

func _update_seed_label() -> void:
	seed_label.text = "Ancient Seed  %d / %d" % [ancient_seed, MAX_SEED]
	_update_card_states()

func _update_status(message: String) -> void:
	status_label.text = message
