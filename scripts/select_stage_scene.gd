extends Control

const STAGE_IDS := ["stage_01", "stage_02", "stage_03"]

@onready var stage_buttons: Array[Button] = [%Stage01Button, %Stage02Button, %Stage03Button]
@onready var start_button: Button = %StartButton
@onready var upgrade_button: Button = %UpgradeButton
@onready var back_button: Button = %BackButton
@onready var dna_label: Label = %DNALabel
@onready var locked_overlay: ColorRect = %LockedOverlay

# 1. เปลี่ยนชนิดของตัวแปรให้ตรงกับ Node หลักของ Popup ใหม่ (สมมติว่าใช้ CanvasLayer และใช้ชื่อเดิม %LockedPopup)
@onready var locked_popup: CanvasLayer = %LockedPopup 
# 2. เพิ่มตัวแปรสำหรับปุ่ม OK ในหน้าต่าง Popup
@onready var popup_ok_button: Button = %PopupOkButton 

var selected_stage_id := ""

func _ready() -> void:
	selected_stage_id = ""
	
	# 3. สั่งซ่อน Popup ไว้ก่อนตอนเริ่ม Scene
	locked_popup.hide() 
	
	back_button.pressed.connect(_on_back_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	start_button.pressed.connect(_on_start_pressed)
	
	# 4. เชื่อมสัญญาณ (Signal) ของปุ่ม OK ให้ทำงานฟังก์ชันปิดหน้าต่าง
	popup_ok_button.pressed.connect(_on_popup_ok_pressed) 
	
	for i in stage_buttons.size():
		stage_buttons[i].pressed.connect(_on_stage_pressed.bind(STAGE_IDS[i]))
	_refresh()

func _on_stage_pressed(stage_id: String) -> void:
	selected_stage_id = stage_id
	if not SaveManager.is_stage_unlocked(stage_id):
		# 5. เปลี่ยนจาก popup_centered() เป็น show() เพราะเราจัดกึ่งกลางด้วย UI ไว้แล้ว
		locked_popup.show() 
	_refresh()

# 6. เพิ่มฟังก์ชันสำหรับปุ่ม OK เมื่อกดแล้วให้ปิดหน้าต่าง
func _on_popup_ok_pressed() -> void:
	locked_popup.hide()

func _on_start_pressed() -> void:
	if selected_stage_id == "":
		return
	if not SaveManager.is_stage_unlocked(selected_stage_id):
		return
	GameManager.selected_stage_id = selected_stage_id
	GameManager.start_selected_stage()

func _on_upgrade_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/upgrade_scene.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_scene.tscn")

func _refresh() -> void:
	dna_label.text = str(SaveManager.dna)
	for i in stage_buttons.size():
		var stage_id: String = STAGE_IDS[i]
		var unlocked: bool = SaveManager.is_stage_unlocked(stage_id)
		stage_buttons[i].disabled = false
		stage_buttons[i].modulate = Color.WHITE if unlocked else Color(0.42, 0.42, 0.42, 1.0)
		stage_buttons[i].pivot_offset = stage_buttons[i].size / 2.0
		stage_buttons[i].scale = Vector2(1.25, 1.25) if stage_id == selected_stage_id else Vector2.ONE
		if not unlocked:
			stage_buttons[i].tooltip_text = "Locked — complete the previous stage"
		else:
			stage_buttons[i].tooltip_text = "Select this stage"
	start_button.disabled = selected_stage_id == "" or not SaveManager.is_stage_unlocked(selected_stage_id)
	start_button.text = "START" if selected_stage_id != "" and not start_button.disabled else "SELECT STAGE" if selected_stage_id == "" else "LOCKED"
