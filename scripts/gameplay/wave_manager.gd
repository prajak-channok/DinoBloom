extends Node
class_name WaveManager

const TOTAL_WAVES := 3
const WAVE_CONFIG := {
	"stage_01": {
		1: {
			"dinosaur_count": 10,
			"allowed_ids": ["dryosaurus"],
			"wave_hp_multiplier": 1.0,
			"has_boss": false,
			"boss_id": "",
			"dna_guaranteed": 2,
			"dna_bonus_min": 1,
			"dna_bonus_max": 3,
		},
		2: {
			"dinosaur_count": 25,
			"allowed_ids": ["dryosaurus", "velociraptor"],
			"wave_hp_multiplier": 1.5,
			"has_boss": false,
			"boss_id": "",
			"dna_guaranteed": 2,
			"dna_bonus_min": 1,
			"dna_bonus_max": 3,
		},
		3: {
			"dinosaur_count": 35,
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
			"dinosaur_count": 12,
			"allowed_ids": ["dryosaurus"],
			"wave_hp_multiplier": 2.0,
			"has_boss": false,
			"boss_id": "",
			"dna_guaranteed": 1,
			"dna_bonus_min": 3,
			"dna_bonus_max": 5,
		},
		2: {
			"dinosaur_count": 22,
			"allowed_ids": ["dryosaurus", "velociraptor"],
			"wave_hp_multiplier": 2.5,
			"has_boss": false,
			"boss_id": "",
			"dna_guaranteed": 2,
			"dna_bonus_min": 3,
			"dna_bonus_max": 5,
		},
		3: {
			"dinosaur_count": 30,
			"allowed_ids": ["dryosaurus", "velociraptor", "triceratops"],
			"wave_hp_multiplier": 3.25,
			"has_boss": true,
			"boss_id": "trex",
			"dna_guaranteed": 3,
			"dna_bonus_min": 3,
			"dna_bonus_max": 5,
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
			"dna_bonus_min": 5,
			"dna_bonus_max": 7,
		},
		2: {
			"dinosaur_count": 30,
			"allowed_ids": ["dryosaurus", "velociraptor"],
			"wave_hp_multiplier": 4,
			"has_boss": false,
			"boss_id": "",
			"dna_guaranteed": 3,
			"dna_bonus_min": 5,
			"dna_bonus_max": 7,
		},
		3: {
			"dinosaur_count": 40,
			"allowed_ids": ["dryosaurus", "velociraptor", "triceratops"],
			"wave_hp_multiplier": 5,
			"has_boss": true,
			"boss_id": "trex",
			"dna_guaranteed": 7,
			"dna_bonus_min": 5,
			"dna_bonus_max": 7,
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

## Seed Overflow Additional Dino (System 5): returns a *copy* of wave_data
## with dinosaur_count bumped by additional_dinos. WAVE_CONFIG — the Stage's
## base Wave Configuration — is never mutated.
func apply_additional_dinos(wave_data: Dictionary, additional_dinos: int) -> Dictionary:
	if additional_dinos <= 0 or wave_data.is_empty():
		return wave_data
	var adjusted := wave_data.duplicate()
	adjusted["dinosaur_count"] = int(adjusted.get("dinosaur_count", 0)) + additional_dinos
	return adjusted

func compute_dna_reward(wave_data: Dictionary) -> int:
	var guaranteed := int(wave_data.get("dna_guaranteed", 0))
	var bonus_min := int(wave_data.get("dna_bonus_min", 0))
	var bonus_max := int(wave_data.get("dna_bonus_max", 0))
	var bonus := randi_range(bonus_min, bonus_max)
	return guaranteed + bonus
