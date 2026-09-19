extends Node
## Persists audio settings (Melody/Effect volume + mute) separately from
## SaveManager, which is scoped to meta-progression only.

const SETTINGS_PATH := "user://dinobloom_settings.cfg"

var melody_volume: int = 100
var melody_muted: bool = false
var effect_volume: int = 100
var effect_muted: bool = false

func _ready() -> void:
	load_settings()
	_apply_bus("Melody", melody_volume, melody_muted)
	_apply_bus("Effect", effect_volume, effect_muted)

func get_volume(bus_name: String) -> int:
	return melody_volume if bus_name == "Melody" else effect_volume

func is_muted(bus_name: String) -> bool:
	return melody_muted if bus_name == "Melody" else effect_muted

## Sets the remembered volume and auto-unmutes (raising the slider implies
## the player wants to hear it again), then applies the effective dB.
func set_volume(bus_name: String, value: int) -> void:
	value = clampi(value, 0, 100)
	if bus_name == "Melody":
		melody_volume = value
		if value > 0:
			melody_muted = false
		_apply_bus(bus_name, melody_volume, melody_muted)
	else:
		effect_volume = value
		if value > 0:
			effect_muted = false
		_apply_bus(bus_name, effect_volume, effect_muted)

## Toggles mute without touching the remembered volume, so unmuting restores
## the exact level the player had before.
func set_muted(bus_name: String, muted: bool) -> void:
	if bus_name == "Melody":
		melody_muted = muted
		_apply_bus(bus_name, melody_volume, melody_muted)
	else:
		effect_muted = muted
		_apply_bus(bus_name, effect_volume, effect_muted)

func _apply_bus(bus_name: String, volume: int, muted: bool) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	var effective_volume := 0 if muted else volume
	AudioServer.set_bus_volume_db(idx, -80.0 if effective_volume <= 0 else linear_to_db(effective_volume / 100.0))

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "melody_volume", melody_volume)
	config.set_value("audio", "melody_muted", melody_muted)
	config.set_value("audio", "effect_volume", effect_volume)
	config.set_value("audio", "effect_muted", effect_muted)
	config.save(SETTINGS_PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	melody_volume = int(config.get_value("audio", "melody_volume", melody_volume))
	melody_muted = bool(config.get_value("audio", "melody_muted", melody_muted))
	effect_volume = int(config.get_value("audio", "effect_volume", effect_volume))
	effect_muted = bool(config.get_value("audio", "effect_muted", effect_muted))
