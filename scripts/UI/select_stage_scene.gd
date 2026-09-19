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
@onready var setting_button: Button = %SettingButton

var selected_stage_id := ""

func _ready() -> void:
	selected_stage_id = ""
	
	# 3. สั่งซ่อน Popup ไว้ก่อนตอนเริ่ม Scene
	locked_popup.hide() 
	
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
		start_button, 
		upgrade_button,
		back_button,
		popup_ok_button, # ถ้าสร้างตัวแปรปุ่ม OK ไว้แล้วก็ใส่มาด้วย
		setting_button
	]
	all_buttons.append_array(stage_buttons) # เอาปุ่มด่าน 1, 2, 3 มารวมด้วย
	
	# --- 3. สั่งวนลูปใส่สไตล์ให้ทุกปุ่ม ---
	for btn in all_buttons:
		if btn: # เช็คกันเหนียวเผื่อหาปุ่มไม่เจอ
			btn.add_theme_stylebox_override("pressed", custom_pressed)
	
	back_button.pressed.connect(_on_back_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	start_button.pressed.connect(_on_start_pressed)
	
	# 4. เชื่อมสัญญาณ (Signal) ของปุ่ม OK ให้ทำงานฟังก์ชันปิดหน้าต่าง
	popup_ok_button.pressed.connect(_on_popup_ok_pressed)
	setting_button.pressed.connect(_on_setting_pressed)
	
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

func _on_setting_pressed() -> void:
	var popup := preload("res://scenes/settings_popup.tscn").instantiate()
	add_child(popup)

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
