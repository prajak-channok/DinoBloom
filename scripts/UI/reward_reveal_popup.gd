extends Control
class_name RewardRevealPopup

signal finished

@onready var unlock_timer: Timer = $UnlockTimer
@onready var auto_close_timer: Timer = $AutoCloseTimer
@onready var continue_button: Button = $ContinueButton
@onready var plant_image: TextureRect = $PlantImage

var _finished := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	continue_button.pressed.connect(_on_continue_pressed)
	unlock_timer.timeout.connect(_on_unlock_timer_timeout)
	auto_close_timer.timeout.connect(_on_auto_close_timer_timeout)
	
	unlock_timer.ignore_time_scale = true
	auto_close_timer.ignore_time_scale = true

	visible = false


func show_reward(plant_texture: Texture2D) -> void:
	_finished = false

	plant_image.texture = plant_texture
	continue_button.disabled = true

	visible = true

	unlock_timer.start()
	auto_close_timer.start()


func _on_unlock_timer_timeout() -> void:
	continue_button.disabled = false


func _on_continue_pressed() -> void:
	_finish()


func _on_auto_close_timer_timeout() -> void:
	_finish()


func _finish() -> void:
	if _finished:
		return

	_finished = true

	unlock_timer.stop()
	auto_close_timer.stop()

	visible = false

	finished.emit()
