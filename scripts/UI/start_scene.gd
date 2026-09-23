extends Control

@onready var play_button: Button = %PlayButton
@onready var exit_button: Button = %ExitButton
@onready var exit_popup: CanvasLayer = %ExitPopup 
@onready var confirm_exit_button: Button = %ConfirmExitButton
@onready var cancel_exit_button: Button = %CancelExitButton
@onready var setting_button: Button = %SettingButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	confirm_exit_button.pressed.connect(_on_exit_confirmed)
	cancel_exit_button.pressed.connect(_on_exit_cancelled)
	setting_button.pressed.connect(_on_setting_pressed)
	
	var all_buttons: Array[Button] = [
		play_button,
		exit_button,
		confirm_exit_button,
		cancel_exit_button,
		setting_button]
	PressedBtnStyle.apply_pressed_style(all_buttons)

func _on_play_pressed() -> void:
	GameManager.go_to_stage_select()

func _on_exit_pressed() -> void:
	exit_popup.show()

func _on_exit_confirmed() -> void:
	# Browsers do not permit a page to close its own tab. Desktop builds can quit normally.
	if not OS.has_feature("web"):
		get_tree().quit()

func _on_exit_cancelled() -> void:
	exit_popup.hide()

func _on_setting_pressed() -> void:
	var popup := preload("res://scenes/settings_popup.tscn").instantiate()
	add_child(popup)
