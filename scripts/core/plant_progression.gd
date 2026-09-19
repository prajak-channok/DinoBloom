extends RefCounted
class_name PlantProgression
## Mediates between PlantData (base stats), PlantUpgradeData (per-level deltas) and
## SaveManager (persisted level/DNA) to produce a runtime Final Stat and an Upgrade
## Transaction. Not a pure-function module: every call here reads SaveManager state,
## and try_upgrade mutates it (via SaveManager.apply_plant_upgrade). Final Stat itself
## is always computed here, never saved.

const MAX_LEVEL := 5
const UPGRADE_COST_PATH := "res://data/upgrade/upgrade_cost.tres"

## stat key -> PlantData field name. Add a row here + a matching "<key>_modifier"
## export on UpgradeLevelData to support a new stat without touching the math below.
const STAT_FIELD_MAP := {
	"hp": "base_hp",
	"attack": "base_attack",
	"placement_cooldown": "placement_cooldown",
	"placement_cost": "placement_cost",
}

## Path convention matches how data/plants/*.tres and data/upgrade/*_upgrade.tres are
## actually named, so this stays the single source of truth instead of a second
## plant_id -> path dictionary alongside UpgradeScene's.
static func get_plant_data(plant_id: String) -> PlantData:
	var path := "res://data/plants/%s.tres" % plant_id
	if not ResourceLoader.exists(path):
		return null
	return load(path)

static func get_upgrade_data(plant_id: String) -> PlantUpgradeData:
	var path := "res://data/upgrade/%s_upgrade.tres" % plant_id
	if not ResourceLoader.exists(path):
		return null
	return load(path)

## Final Stat = Plant Base Data + sum of Upgrade Level deltas up to the plant's current level.
## Returns null (not {}) when the plant has no base PlantData yet — callers must check for it
## rather than treating an empty-but-valid stat block as real data.
static func get_final_stats(plant_id: String) -> Variant:
	var base: PlantData = get_plant_data(plant_id)
	if base == null:
		push_warning("PlantProgression: no PlantData for '%s', cannot compute Final Stat." % plant_id)
		return null

	var stats := {}
	for stat_key in STAT_FIELD_MAP:
		stats[stat_key] = base.get(STAT_FIELD_MAP[stat_key])

	var ability_stats: Dictionary = base.ability_data.duplicate()

	var level: int = SaveManager.get_plant_level(plant_id)
	var upgrade: PlantUpgradeData = get_upgrade_data(plant_id)
	if upgrade != null:
		for level_data in upgrade.levels:
			if level_data.level > level:
				continue
			for stat_key in STAT_FIELD_MAP:
				stats[stat_key] += level_data.get("%s_modifier" % stat_key)
			for ability_key in level_data.ability_modifiers:
				var delta = level_data.ability_modifiers[ability_key]
				if ability_stats.has(ability_key):
					ability_stats[ability_key] += delta
				else:
					ability_stats[ability_key] = delta

	stats["ability_data"] = ability_stats
	return stats

## Cost to go from `level` to `level + 1`. -1 if already at MAX_LEVEL / no cost defined.
static func get_upgrade_cost(level: int) -> int:
	if level < 0 or level >= MAX_LEVEL:
		return -1
	var cost_data: UpgradeCostData = load(UPGRADE_COST_PATH)
	if level >= cost_data.costs.size():
		return -1
	return cost_data.costs[level]

## The non-zero stat deltas the plant would gain by going from its current level to
## current + 1, as [{"stat": stat_key, "value": delta}, ...]. Empty if maxed or if the
## plant has no PlantUpgradeData yet — callers must not invent an effect in that case.
static func get_next_level_deltas(plant_id: String) -> Array:
	var level: int = SaveManager.get_plant_level(plant_id)
	if level >= MAX_LEVEL:
		return []
	var upgrade: PlantUpgradeData = get_upgrade_data(plant_id)
	if upgrade == null:
		return []
	for level_data in upgrade.levels:
		if level_data.level != level + 1:
			continue
		var deltas := []
		for stat_key in STAT_FIELD_MAP:
			var value = level_data.get("%s_modifier" % stat_key)
			if value != 0:
				deltas.append({"stat": stat_key, "value": value})
		for ability_key in level_data.ability_modifiers:
			var ability_value = level_data.ability_modifiers[ability_key]
			if ability_value != 0:
				deltas.append({"stat": ability_key, "value": ability_value})
		return deltas
	return []

## False whenever the plant has no PlantUpgradeData yet — a plant with no defined
## upgrade effect cannot be upgraded, regardless of DNA or level.
static func can_upgrade(plant_id: String) -> bool:
	if not SaveManager.is_plant_unlocked(plant_id):
		return false
	if get_upgrade_data(plant_id) == null:
		return false
	var level: int = SaveManager.get_plant_level(plant_id)
	var cost: int = get_upgrade_cost(level)
	return cost >= 0 and SaveManager.dna >= cost

## Validates upgrade-data existence + level cap + DNA, then delegates the deduct-and-bump
## to a single atomic, single-save SaveManager transaction. Returns false and changes
## nothing if any check fails.
static func try_upgrade(plant_id: String) -> bool:
	if not SaveManager.is_plant_unlocked(plant_id):
		return false
	if get_upgrade_data(plant_id) == null:
		return false
	var level: int = SaveManager.get_plant_level(plant_id)
	var cost: int = get_upgrade_cost(level)
	if cost < 0:
		return false
	return SaveManager.apply_plant_upgrade(plant_id, cost)
