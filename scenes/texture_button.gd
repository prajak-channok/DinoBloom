extends TextureButton

@export var icon_sound_on: Texture2D
@export var icon_sound_off: Texture2D

var target_bus_index: int

func _ready():
	# เปลี่ยนเป้าหมายจาก Master มาเป็นช่อง GameSound ที่เพิ่งสร้างใหม่
	target_bus_index = AudioServer.get_bus_index("GameSound")
	_update_button_icon()

func _on_pressed():
	var is_muted = AudioServer.is_bus_mute(target_bus_index)
	AudioServer.set_bus_mute(target_bus_index, not is_muted)
	_update_button_icon()

func _update_button_icon():
	if AudioServer.is_bus_mute(target_bus_index):
		texture_normal = icon_sound_off
	else:
		texture_normal = icon_sound_on
