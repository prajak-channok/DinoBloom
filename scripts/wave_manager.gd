extends Node
class_name WaveManager
## M4: Responsible for Wave *data* and *rules* only — composition, counts,
## HP scaling and DNA reward formulas. It does not spawn nodes (SpawnManager)
## and does not decide Win/Lose (MatchManager).
##
## Stage Modifier already exists as StageData.hp_multiplier (Stage 1 = x1,
## Stage 2 = x2, Stage 3 = x4 — see data/stages/stage_0X.tres). WaveManager
## reuses that field instead of re-declaring stage_multiplier anywhere, so the
## Stage Modifier stays a single source of truth.
##
## Wave balance below is intentionally kept as one readable const config
## block (matching the STAGE_DATA / PLANT_DATA constant pattern already used
## by GameplayScene) rather than a nested custom Resource array, so stage 2
## and 3 can be added later by appending entries — no script changes needed.

const TOTAL_WAVES := 3

## wave_hp_multiplier follows requirement #10: every wave multiplies HP by
## x1.5 versus the previous wave (W1=1.0, W2=1.5, W3=2.25).
const WAVE_CONFIG := {
	"stage_01": {
		1: {
			"dinosaur_count": 15,
			"allowed_ids": ["dryosaurus"],
			"wave_hp_multiplier": 1.0,
			"has_boss": false,
			"boss_id": "",
			"dna_guaranteed": 1,
			"dna_bonus_min": 1,
			"dna_bonus_max": 3,
		},
		2: {
			"dinosaur_count": 25,
			"allowed_ids": ["dryosaurus", "velociraptor"],
			"wave_hp_multiplier": 1.5,
			"has_boss": false,
			"boss_id": "",
			"dna_guaranteed": 1,
			"dna_bonus_min": 1,
			"dna_bonus_max": 3,
		},
		3: {
			"dinosaur_count": 30,
			"allowed_ids": ["dryosaurus", "velociraptor", "triceratops"],
			"wave_hp_multiplier": 2.25,
			"has_boss": true,
			"boss_id": "trex",
			"dna_guaranteed": 3,
			"dna_bonus_min": 1,
			"dna_bonus_max": 3,
		},
	},
	"stage_02": {
		1: {
			"dinosaur_count": 15,
			"allowed_ids": ["dryosaurus"],
			"wave_hp_multiplier": 2.0,
			"has_boss": false,
			"boss_id": "",
			"dna_guaranteed": 1,
			"dna_bonus_min": 1,
			"dna_bonus_max": 3,
		},
		2: {
			"dinosaur_count": 25,
			"allowed_ids": ["dryosaurus", "velociraptor"],
			"wave_hp_multiplier": 2.5,
			"has_boss": false,
			"boss_id": "",
			"dna_guaranteed": 1,
			"dna_bonus_min": 1,
			"dna_bonus_max": 3,
		},
		3: {
			"dinosaur_count": 30,
			"allowed_ids": ["dryosaurus", "velociraptor", "triceratops"],
			"wave_hp_multiplier": 3.25,
			"has_boss": true,
			"boss_id": "trex",
			"dna_guaranteed": 3,
			"dna_bonus_min": 1,
			"dna_bonus_max": 3,
		}
	},
	"stage_03": {
		1: {
			"dinosaur_count": 15,
			"allowed_ids": ["dryosaurus"],
			"wave_hp_multiplier": 3.0,
			"has_boss": false,
			"boss_id": "",
			"dna_guaranteed": 1,
			"dna_bonus_min": 1,
			"dna_bonus_max": 3,
		},
		2: {
			"dinosaur_count": 25,
			"allowed_ids": ["dryosaurus", "velociraptor"],
			"wave_hp_multiplier": 3.5,
			"has_boss": false,
			"boss_id": "",
			"dna_guaranteed": 1,
			"dna_bonus_min": 1,
			"dna_bonus_max": 3,
		},
		3: {
			"dinosaur_count": 30,
			"allowed_ids": ["dryosaurus", "velociraptor", "triceratops"],
			"wave_hp_multiplier": 4.25,
			"has_boss": true,
			"boss_id": "trex",
			"dna_guaranteed": 3,
			"dna_bonus_min": 1,
			"dna_bonus_max": 3,
		}
	}
}

func is_stage_supported(stage_id: String) -> bool:
	return WAVE_CONFIG.has(stage_id)

func get_wave_data(stage_id: String, wave_number: int) -> Dictionary:
	if not WAVE_CONFIG.has(stage_id):
		return {}
	var stage_waves: Dictionary = WAVE_CONFIG[stage_id]
	if not stage_waves.has(wave_number):
		return {}
	return stage_waves[wave_number]

## Final HP = Base HP x Stage Multiplier x Wave Multiplier (requirement #12/#35).
## stage_multiplier is read from StageData.hp_multiplier — never hardcoded here.
func compute_hp_multiplier(stage: StageData, wave_data: Dictionary) -> float:
	var stage_multiplier := 1.0
	if stage != null:
		stage_multiplier = stage.hp_multiplier
	return stage_multiplier * float(wave_data.get("wave_hp_multiplier", 1.0))

## DNA Reward Formula (requirement #21). Uses Godot's RNG, never hardcoded.
func compute_dna_reward(wave_data: Dictionary) -> int:
	var guaranteed := int(wave_data.get("dna_guaranteed", 0))
	var bonus_min := int(wave_data.get("dna_bonus_min", 0))
	var bonus_max := int(wave_data.get("dna_bonus_max", 0))
	var bonus := randi_range(bonus_min, bonus_max)
	return guaranteed + bonus
