extends Control

const PLANT_IDS := [
	"seed_bloom", "thorn_fern", "baobab_guardian",
	"ginkgo_cannon", "horsetail", "sticky_moss", "blast_cone"
]

const PLANT_TEXTURES := {
	"seed_bloom": "res://assets/Plants/SeedBloomNBG.PNG",
	"thorn_fern": "res://assets/Plants/ThornFernNBG.png",
	"baobab_guardian": "res://assets/Plants/BaobabGuardianNBG.png",
	"ginkgo_cannon": "res://assets/Plants/GinkgoCannonNBG.png",
	"horsetail": "res://assets/Plants/HorsetailNBG.png",
	"sticky_moss": "res://assets/Plants/StickyMossNBG.png",
	"blast_cone": "res://assets/Plants/BlastConeNBG.png",
}

## Cosmetic display labels for PlantProgression's generic stat keys — not plant-specific logic.
const STAT_DISPLAY_NAMES := {
	"hp": "HP",
	"attack": "ATK",
	"placement_cooldown": "Cooldown",
	"placement_cost": "Cost",
}

@onready var back_button: Button = %BackButton
@onready var dna_label: Label = %DNALabel
@onready var plant_grid: GridContainer = %PlantGrid
@onready var plant_card_template: Button = %PlantCardTemplate
@onready var left_panel: PanelContainer = %LeftPanel
@onready var left_placeholder: PanelContainer = %LeftBackground
@onready var plant_preview: TextureRect = %PlantPreview
@onready var plant_name_label: Label = %PlantName
@onready var atk_label: Label = %ATK
@onready var hp_label: Label = %HP
@onready var dps_label: Label = %DPS
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var next_upgrade_label: Label = %NextUpgradeLabel
@onready var dna_cost_label: Label = %DNACostValue
@onready var upgrade_button: Button = %UpgradeButton

var _plant_buttons: Dictionary = {}
var _selected_id: String = ""

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	_build_plant_grid()
	_refresh_dna_label()
	_select_plant("")
	
	# --- 1. สร้างดีไซน์ปุ่มตอนกด (สีดำ + มุมมน) ---
	var custom_pressed = StyleBoxFlat.new()
	custom_pressed.bg_color = Color(0, 0, 0, 1) # สีดำทึบ
	
	# ตั้งค่าความมน (สมมติว่าใช้ความมนระดับ 15 ถ้าของเดิมมนกว่านี้ก็แก้เลขได้เลย)
	var corner = 15 
	custom_pressed.corner_radius_top_left = corner
	custom_pressed.corner_radius_top_right = corner
	custom_pressed.corner_radius_bottom_left = corner
	custom_pressed.corner_radius_bottom_right = corner
	
	# --- 2. จับมัดรวมทุกปุ่มในหน้าต่างนี้ ---
	var all_buttons: Array[Button] = [
		back_button, 
		upgrade_button, 
		back_button, 
	]
	
	# --- 3. สั่งวนลูปใส่สไตล์ให้ทุกปุ่ม ---
	for btn in all_buttons:
		if btn: # เช็คกันเหนียวเผื่อหาปุ่มไม่เจอ
			btn.add_theme_stylebox_override("pressed", custom_pressed)

func _build_plant_grid() -> void:
	for child in plant_grid.get_children():
		child.queue_free()
	_plant_buttons.clear()

	for plant_id in PLANT_IDS:
		var button: Button = plant_card_template.duplicate()
		button.visible = true
		button.name = "PlantCard_%s" % plant_id
		button.toggle_mode = true

		var texture_path: String = PLANT_TEXTURES.get(plant_id, "")
		if texture_path != "":
			button.icon = load(texture_path)

		var has_data: bool = PlantProgression.get_plant_data(plant_id) != null
		button.disabled = not has_data
		button.modulate = Color(1, 1, 1, 1) if has_data else Color(1, 1, 1, 0.45)

		if has_data:
			button.pressed.connect(_on_plant_button_pressed.bind(plant_id))
		else:
			var locked_label := Label.new()
			locked_label.text = "Locked"
			locked_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			locked_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			locked_label.set_anchors_preset(Control.PRESET_FULL_RECT)
			locked_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(locked_label)

		plant_grid.add_child(button)
		_plant_buttons[plant_id] = button

func _on_plant_button_pressed(plant_id: String) -> void:
	if _selected_id == plant_id:
		_select_plant("")
	else:
		_select_plant(plant_id)

func _select_plant(plant_id: String) -> void:
	_selected_id = plant_id
	for id in _plant_buttons.keys():
		_plant_buttons[id].button_pressed = (id == plant_id)

	left_panel.visible = plant_id != ""
	left_placeholder.visible = plant_id == ""

	if plant_id != "":
		_refresh_left_panel(plant_id)

func _refresh_left_panel(plant_id: String) -> void:
	var base: PlantData = PlantProgression.get_plant_data(plant_id)
	if base == null:
		plant_name_label.text = "No Data"
		plant_preview.texture = null
		atk_label.text = "ATK: -"
		hp_label.text = "HP: -"
		dps_label.text = "DPS: -"
		progress_bar.value = 0.0
		next_upgrade_label.text = "Next Upgrade: No data"
		dna_cost_label.text = "-"
		upgrade_button.disabled = true
		return

	var stats: Dictionary = PlantProgression.get_final_stats(plant_id)
	plant_name_label.text = base.display_name
	plant_preview.texture = base.visual_reference
	atk_label.text = "ATK: %s" % (str(stats.attack) if stats.attack > 0 else "-")
	hp_label.text = "HP: %s" % str(stats.hp)

	var dps: float = 0.0
	if base.attack_interval > 0:
		dps = stats.attack / base.attack_interval
	dps_label.text = "DPS: %s" % ("%.1f" % dps if dps > 0 else "-")

	var level: int = SaveManager.get_plant_level(plant_id)
	progress_bar.value = (float(level) / float(PlantProgression.MAX_LEVEL)) * 100.0

	next_upgrade_label.text = _format_next_upgrade(plant_id, level)

	var cost: int = PlantProgression.get_upgrade_cost(level)
	dna_cost_label.text = str(cost) if cost >= 0 else "-"

	upgrade_button.disabled = not PlantProgression.can_upgrade(plant_id)

func _format_next_upgrade(plant_id: String, level: int) -> String:
	if level >= PlantProgression.MAX_LEVEL:
		return "Next Upgrade: MAX LEVEL"

	var deltas: Array = PlantProgression.get_next_level_deltas(plant_id)
	if deltas.is_empty():
		return "Next Upgrade: No data"

	var parts: Array[String] = []
	for delta in deltas:
		var stat_label: String = STAT_DISPLAY_NAMES.get(delta.stat, delta.stat)
		var value = delta.value
		parts.append("%s %s%s" % [stat_label, "+" if value > 0 else "", str(value)])
	return "Next Upgrade: %s" % ", ".join(parts)

func _on_upgrade_pressed() -> void:
	if _selected_id == "":
		return
	if not PlantProgression.try_upgrade(_selected_id):
		return
	_refresh_dna_label()
	_refresh_left_panel(_selected_id)

func _refresh_dna_label() -> void:
	dna_label.text = str(SaveManager.dna)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/select_stage_scene.tscn")
