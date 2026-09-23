extends Node
var selected_stage_id: String = "stage_01"

func go_to_start() -> void:
	get_tree().change_scene_to_file("res://scenes/start_scene.tscn")

func go_to_stage_select() -> void:
	get_tree().change_scene_to_file("res://scenes/select_stage_scene.tscn")

func go_to_upgrade() -> void:
	get_tree().change_scene_to_file("res://scenes/upgrade_scene.tscn")

func go_to_gameplay() -> void:
	get_tree().change_scene_to_file("res://scenes/gameplay_scene.tscn")
