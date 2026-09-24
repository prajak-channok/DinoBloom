extends Resource
class_name DinosaurData

@export var id: String = ""
@export var display_name: String = ""
@export var base_hp: float = 0.0
@export var attack: float = 0.0
@export var attack_interval: float = 1.0
@export var movement_speed: float = 0.0
@export var faction: String = "Enemy"
# True for Boss-class dinosaurs and drives Boss HP Bar display
@export var is_boss: bool = false
# For Gingko Cannon passive ability and some dinosuar can never be converted
@export var can_be_converted: bool = true
