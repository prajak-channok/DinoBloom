extends Node
## Application-level state for scene flow.
## Gameplay state itself remains owned by the Gameplay scene.

var selected_stage_id: String = "stage_01"

func start_selected_stage() -> void:
	get_tree().change_scene_to_file("res://scenes/gameplay_scene.tscn")

func go_to_stage_select() -> void:
	get_tree().change_scene_to_file("res://scenes/select_stage_scene.tscn")
