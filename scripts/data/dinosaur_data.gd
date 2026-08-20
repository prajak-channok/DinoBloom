extends Resource
class_name DinosaurData

@export var id: String = ""
@export var display_name: String = ""
@export var base_hp: float = 0.0
@export var attack: float = 0.0
@export var attack_interval: float = 1.0
@export var movement_speed: float = 0.0
@export var armor: float = 0.0
@export var faction: String = "Enemy"
@export var visual_reference: Texture2D
## M4: true for Boss-class dinosaurs (e.g. T-Rex). Drives Boss HP Bar display.
@export var is_boss: bool = false
## M4: whether Ginkgo Cannon (future milestone) will be able to convert this
## dinosaur to the player's side. T-Rex can never be converted.
@export var can_be_converted: bool = true
