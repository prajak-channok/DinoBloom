extends Control

@onready var play_button: Button = %PlayButton
@onready var exit_button: Button = %ExitButton
@onready var exit_dialog: ConfirmationDialog = %ExitDialog

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	exit_dialog.confirmed.connect(_on_exit_confirmed)
	print(OS.get_user_data_dir())

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/select_stage_scene.tscn")

func _on_exit_pressed() -> void:
	exit_dialog.popup_centered()

func _on_exit_confirmed() -> void:
	# Browsers do not permit a page to close its own tab. Desktop builds can quit normally.
	if not OS.has_feature("web"):
		get_tree().quit()
