extends Node
## Milestone 1 persistent progression foundation.
## The save is deliberately limited to meta-progression; current gameplay/wave state is never saved.

const SAVE_PATH := "user://dinobloom_save.json"
const SAVE_VERSION := 1

var dna: int = 0
var completed_stages: Array[String] = []
var unlocked_plants: Array[String] = ["seed_bloom", "thorn_fern", "baobab_guardian"]
const PLANT_UNLOCK_COSTS: Dictionary = {
	"horsetail": 50,
	"sticky_moss": 50,
	"blast_cone": 50,
}
var plant_levels: Dictionary = {
	"seed_bloom": 0,
	"thorn_fern": 0,
	"baobab_guardian": 0,
	"ginkgo_cannon": 0,
	"horsetail": 0,
	"sticky_moss": 0,
	"blast_cone": 0
}

func _ready() -> void:
	load_game()

func is_stage_unlocked(stage_id: String) -> bool:
	match stage_id:
		"stage_01":
			return true
		"stage_02":
			return "stage_01" in completed_stages
		"stage_03":
			return "stage_02" in completed_stages
	return false

## M4: grants DNA earned during a Match (Wave Clear / Win reward) and persists
## it immediately, matching the existing SaveManager persistence pattern.
func add_dna(amount: int) -> void:
	if amount <= 0:
		return
	dna += amount
	save_game()

## M5: deducts DNA spent on plant upgrades and persists it, mirroring add_dna.
func spend_dna(amount: int) -> bool:
	if amount <= 0 or amount > dna:
		return false
	dna -= amount
	save_game()
	return true

func get_plant_level(plant_id: String) -> int:
	return plant_levels.get(plant_id, 0)

## Atomic upgrade transaction: spend DNA + bump level in a single save. Rolls back
## the in-memory mutation if the save itself fails, so state and disk never diverge.
func apply_plant_upgrade(plant_id: String, cost: int) -> bool:
	if cost <= 0 or cost > dna:
		return false
	dna -= cost
	plant_levels[plant_id] = plant_levels.get(plant_id, 0) + 1
	if not save_game():
		dna += cost
		plant_levels[plant_id] -= 1
		return false
	return true

func mark_stage_completed(stage_id: String) -> void:
	if stage_id == "stage_01" or stage_id == "stage_02" or stage_id == "stage_03":
		if not stage_id in completed_stages:
			completed_stages.append(stage_id)

		if stage_id == "stage_01" and not is_plant_unlocked("ginkgo_cannon"):
			unlocked_plants.append("ginkgo_cannon")

		save_game()

func save_game() -> bool:
	var payload := {
		"version": SAVE_VERSION,
		"dna": dna,
		"completed_stages": completed_stages,
		"unlocked_plants": unlocked_plants,
		"plant_levels": plant_levels
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("DinoBloom: unable to write save file.")
		return false
	file.store_string(JSON.stringify(payload))
	file.close()
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return save_game()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY or int(parsed.get("version", 0)) != SAVE_VERSION:
		return reset_save()
	dna = int(parsed.get("dna", 0))
	var saved_completed_stages: Array = parsed.get("completed_stages", [])
	completed_stages.clear()
	for stage_id in saved_completed_stages:
		if stage_id is String:
			completed_stages.append(stage_id)

	var saved_unlocked_plants: Array = parsed.get("unlocked_plants", unlocked_plants)
	unlocked_plants.clear()
	for plant_id in saved_unlocked_plants:
		if plant_id is String:
			unlocked_plants.append(plant_id)
	var saved_levels: Dictionary = parsed.get("plant_levels", {})
	for plant_id in plant_levels.keys():
		plant_levels[plant_id] = int(saved_levels.get(plant_id, 0))
	return true

func reset_save() -> bool:
	dna = 0
	completed_stages.clear()
	unlocked_plants = ["seed_bloom", "thorn_fern", "baobab_guardian"]
	for plant_id in plant_levels.keys():
		plant_levels[plant_id] = 0
	return save_game()
	
func is_plant_unlocked(plant_id: String) -> bool:
	return plant_id in unlocked_plants

## Atomic unlock transaction: spend DNA + add to unlocked_plants in a single save.
## Mirrors apply_plant_upgrade's rollback-on-failure pattern. Only works for plants
## listed in PLANT_UNLOCK_COSTS — stage-gated plants (ginkgo_cannon) go through
## mark_stage_completed instead, never this function.
func purchase_plant(plant_id: String) -> bool:
	if is_plant_unlocked(plant_id):
		return false
	if not PLANT_UNLOCK_COSTS.has(plant_id):
		return false

	var cost: int = PLANT_UNLOCK_COSTS[plant_id]
	if cost > dna:
		return false

	dna -= cost
	unlocked_plants.append(plant_id)

	if not save_game():
		dna += cost
		unlocked_plants.erase(plant_id)
		return false

	return true
