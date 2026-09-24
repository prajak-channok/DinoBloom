class_name PressedBtnStyle
extends RefCounted

# Only set botton style script (becuase all buttons don't have pressed style, so need quick solving)
# Setting pressed-state style for selected-botton (ตั้งสีตอน pressed ให้กับปุ่มที่ต้องการ)
static func apply_pressed_style(buttons: Array[Button]) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 1)
	
	var corner := 16
	style.corner_radius_top_left = corner
	style.corner_radius_top_right = corner
	style.corner_radius_bottom_left = corner
	style.corner_radius_bottom_right = corner
	
	for btn in buttons:
		if btn:
			btn.add_theme_stylebox_override("pressed", style)
