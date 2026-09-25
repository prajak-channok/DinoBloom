extends Node

const SAVE_PATH := "user://dinobloom_save.json"
# V2: one-time wipe for the full-release deploy — existing saves get reset once
# On next load (version mismatch below), then locked to v2 so it never repeats
# (เพราะว่าต้องการรีเซ็ตข้อมูลสำหรับคนที่เคยเล่นตอนเวอร์ชันที่ยังไม่สมบูรณ์ที่เสก DNA ไป จึงเปลี่ยนเลขเวอร์ชัน ทำให้บังคับรีเซ็ตข้อมูล)
const SAVE_VERSION := 2

var dna: int = 0
var completed_stages: Array[String] = []
var unlocked_plants: Array[String] = ["seed_bloom", "thorn_fern", "baobab_guardian"] # Starter plants
const PLANT_UNLOCK_COSTS: Dictionary = {"horsetail": 15,} # Plants unlockable via purchase
var plant_levels: Dictionary = {
	"seed_bloom": 0,
	"thorn_fern": 0,
	"baobab_guardian": 0,
	"ginkgo_cannon": 0,
	"horsetail": 0,
	"sticky_moss": 0,
	"blast_cone": 0}
const MAX_SEED_LEVELS: Array[int] = [400, 500, 600, 700] #  Because this data no structure / small system
const MAX_SEED_UPGRADE_COSTS: Array[int] = [15, 40, 80] #  Because this data no structure / small system
var max_seed_level: int = 0

func _ready() -> void:
	# Because of this script was auto load, so this function active first when start run
	load_game()

# For stage select scene to check lock or unlock
func is_stage_unlocked(stage_id: String) -> bool:
	match stage_id:
		"stage_01":
			return true
		"stage_02":
			return "stage_01" in completed_stages
		"stage_03":
			return "stage_02" in completed_stages
	return false

# Cal when wave or stage clear and save game for correct display
func add_dna(amount: int) -> void:
	if amount <= 0:
		return
	dna += amount
	save_game()

# For upgrade scene and plant progression
func get_plant_level(plant_id: String) -> int:
	return plant_levels.get(plant_id, 0)

# Upgrade plant is a transaction that spend DNA, add a level and save game, if save fail, rollback DNA and level
# (มองการอัปเกรดเลเวลพืชเป็นธุรกรรม แล้วให้มีการย้อนกลับข้อมูลที่เกี่ยวข้องเพื่อให้ข้อมูลตรงกันเมื่อเซฟเกมไม่ผ่าน)
func apply_plant_upgrade(plant_id: String, cost: int) -> bool:
	if cost <= 0 or cost > dna:
		return false
	dna -= cost
	plant_levels[plant_id] = plant_levels.get(plant_id, 0) + 1
	if not save_game(): # if not succeed, rollback
		dna += cost
		plant_levels[plant_id] -= 1
		return false
	return true

# For max seed label at upgrade scene
func get_max_seed() -> int:
	return MAX_SEED_LEVELS[max_seed_level]

# For max seed upgrade function
func get_max_seed_upgrade_cost() -> int:
	if max_seed_level >= MAX_SEED_UPGRADE_COSTS.size():
		return -1 # To make condition for can't upgrade
	return MAX_SEED_UPGRADE_COSTS[max_seed_level]

# Atomic transaction and rollback
func apply_max_seed_upgrade() -> bool:
	var cost := get_max_seed_upgrade_cost()
	if cost < 0 or cost > dna:
		return false
	dna -= cost
	max_seed_level += 1
	if not save_game(): # if not succeed, rollback
		dna += cost
		max_seed_level -= 1
		return false
	return true

# For match manager when clear stage
func mark_stage_completed(stage_id: String) -> void:
	if stage_id == "stage_01" or stage_id == "stage_02" or stage_id == "stage_03":
		if not stage_id in completed_stages: # Condition: check id in array and return boolean
			completed_stages.append(stage_id)

		save_game()

# For match manager when clear wave or stage
func unlock_plant_free(plant_id: String) -> void:
	if is_plant_unlocked(plant_id):
		return
	unlocked_plants.append(plant_id)
	save_game()

func save_game() -> bool:
	var payload := {
		"version": SAVE_VERSION,
		"dna": dna,
		"completed_stages": completed_stages,
		"unlocked_plants": unlocked_plants,
		"plant_levels": plant_levels,
		"max_seed_level": max_seed_level
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
	max_seed_level = clampi(int(parsed.get("max_seed_level", 0)), 0, MAX_SEED_LEVELS.size() - 1)
	return true

func reset_save() -> bool:
	dna = 0
	completed_stages.clear()
	unlocked_plants = ["seed_bloom", "thorn_fern", "baobab_guardian"]
	for plant_id in plant_levels.keys():
		plant_levels[plant_id] = 0
	max_seed_level = 0
	return save_game()

# For upgrade scene and plant progression
func is_plant_unlocked(plant_id: String) -> bool:
	return plant_id in unlocked_plants

# Atomic transaction and rollback
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
