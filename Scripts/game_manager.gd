# GameManager.gd - Singleton (Autoload) สำหรับจัดการสถานะหลักของเกม
extends Node

signal seeds_changed(new_amount: int)
signal base_health_changed(new_health: int)
signal game_over
signal game_won

# สถิติและทรัพยากรหลักตามสไลด์ (Ancient Seeds & Tree of Evolution HP)
var ancient_seeds: int = 100:
	set(value):
		ancient_seeds = value
		seeds_changed.emit(ancient_seeds)

var base_health: int = 100:
	set(value):
		base_health = clamp(value, 0, 100)
		base_health_changed.emit(base_health)
		if base_health <= 0:
			game_over.emit()

func reset_game() -> void:
	ancient_seeds = 100
	base_health = 100
