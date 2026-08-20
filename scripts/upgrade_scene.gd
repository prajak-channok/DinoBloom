extends Control

@onready var back_button: Button = %BackButton
@onready var dna_label: Label = %DNALabel

func _ready() -> void:
	dna_label.text = "DNA: %d" % SaveManager.dna
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/select_stage_scene.tscn")
