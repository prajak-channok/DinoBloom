extends Control

@onready var melody_icon: TextureButton = %MelodyIcon
@onready var melody_slider: HSlider = %MelodySlider
@onready var melody_minus_button: Button = %MelodyMinusButton
@onready var melody_plus_button: Button = %MelodyPlusButton
@onready var melody_percent_label: Label = %MelodyPercentLabel

@onready var effect_icon: TextureButton = %EffectIcon
@onready var effect_slider: HSlider = %EffectSlider
@onready var effect_minus_button: Button = %EffectMinusButton
@onready var effect_plus_button: Button = %EffectPlusButton
@onready var effect_percent_label: Label = %EffectPercentLabel

@onready var reset_button: Button = %ResetButton
@onready var save_close_button: Button = %SaveCloseButton

var _icon_open := {
	"Melody": preload("res://assets/Component/SoundMelodyOpen.png"),
	"Effect": preload("res://assets/Component/SoundEffectOpen.png"),
}
var _icon_close := {
	"Melody": preload("res://assets/Component/SoundMelodyClose.png"),
	"Effect": preload("res://assets/Component/SoundEffectClose.png"),
}

func _ready() -> void:
	melody_slider.value = 0 if SettingsManager.is_muted("Melody") else SettingsManager.get_volume("Melody")
	effect_slider.value = 0 if SettingsManager.is_muted("Effect") else SettingsManager.get_volume("Effect")
	_update_row_visual("Melody")
	_update_row_visual("Effect")

	melody_slider.value_changed.connect(_on_slider_changed.bind("Melody"))
	melody_minus_button.pressed.connect(_on_step_pressed.bind("Melody", -10))
	melody_plus_button.pressed.connect(_on_step_pressed.bind("Melody", 10))
	melody_icon.pressed.connect(_on_icon_pressed.bind("Melody"))

	effect_slider.value_changed.connect(_on_slider_changed.bind("Effect"))
	effect_minus_button.pressed.connect(_on_step_pressed.bind("Effect", -10))
	effect_plus_button.pressed.connect(_on_step_pressed.bind("Effect", 10))
	effect_icon.pressed.connect(_on_icon_pressed.bind("Effect"))

	reset_button.pressed.connect(_on_reset_pressed)
	save_close_button.pressed.connect(_on_save_close_pressed)

func _get_slider(bus_name: String) -> HSlider:
	return melody_slider if bus_name == "Melody" else effect_slider

func _on_slider_changed(value: float, bus_name: String) -> void:
	SettingsManager.set_volume(bus_name, int(value))
	_update_row_visual(bus_name)

func _on_step_pressed(bus_name: String, step: int) -> void:
	var slider := _get_slider(bus_name)
	slider.value = clampf(slider.value + step, 0, 100)

func _on_icon_pressed(bus_name: String) -> void:
	var new_muted := not SettingsManager.is_muted(bus_name)
	SettingsManager.set_muted(bus_name, new_muted)
	var slider := _get_slider(bus_name)
	var display_value := 0 if new_muted else SettingsManager.get_volume(bus_name)
	slider.set_value_no_signal(display_value)
	_update_row_visual(bus_name)

func _update_row_visual(bus_name: String) -> void:
	var slider := _get_slider(bus_name)
	var icon := melody_icon if bus_name == "Melody" else effect_icon
	var percent_label := melody_percent_label if bus_name == "Melody" else effect_percent_label
	var muted := SettingsManager.is_muted(bus_name) or slider.value <= 0
	icon.texture_normal = _icon_close[bus_name] if muted else _icon_open[bus_name]
	percent_label.text = "%d%%" % int(slider.value)

func _on_reset_pressed() -> void:
	SaveManager.reset_save()

func _on_save_close_pressed() -> void:
	SettingsManager.save_settings()
	queue_free()
