extends Control

@onready var play_button: Button = %PlayButton
@onready var exit_button: Button = %ExitButton
@onready var exit_popup: CanvasLayer = %ExitPopup 
@onready var confirm_exit_button: Button = %ConfirmExitButton
@onready var cancel_exit_button: Button = %CancelExitButton

func _ready() -> void:
	exit_popup.hide()
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	confirm_exit_button.pressed.connect(_on_exit_confirmed)
	cancel_exit_button.pressed.connect(_on_exit_cancelled)
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
		play_button, 
		exit_button, 
		confirm_exit_button,
		cancel_exit_button
	]
	
	# --- 3. สั่งวนลูปใส่สไตล์ให้ทุกปุ่ม ---
	for btn in all_buttons:
		if btn: # เช็คกันเหนียวเผื่อหาปุ่มไม่เจอ
			btn.add_theme_stylebox_override("pressed", custom_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/select_stage_scene.tscn")

func _on_exit_pressed() -> void:
	# เปลี่ยนคำสั่งให้โชว์ Popup ตัวใหม่
	exit_popup.show()

func _on_exit_confirmed() -> void:
	# Browsers do not permit a page to close its own tab. Desktop builds can quit normally.
	if not OS.has_feature("web"):
		get_tree().quit()

func _on_exit_cancelled() -> void:
	exit_popup.hide()


func _on_dev_button_pressed() -> void:
	SaveManager.add_dna(800)
