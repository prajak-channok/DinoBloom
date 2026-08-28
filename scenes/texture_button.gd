extends TextureButton

# สร้างช่องใน Inspector สำหรับใส่รูป
@export var icon_sound_on: Texture2D
@export var icon_sound_off: Texture2D

var master_bus_index: int

func _ready():
	master_bus_index = AudioServer.get_bus_index("Master")
	_update_button_icon()

func _on_pressed():
	var is_muted = AudioServer.is_bus_mute(master_bus_index)
	AudioServer.set_bus_mute(master_bus_index, not is_muted)
	_update_button_icon()

func _update_button_icon():
	# สลับรูปภาพตามสถานะเสียง
	if AudioServer.is_bus_mute(master_bus_index):
		texture_normal = icon_sound_off
	else:
		texture_normal = icon_sound_on
