extends Node
class_name SpawnManager
## M4: Responsible for Spawn *mechanics* only — timing, lane selection and
## instancing dinosaur scenes into the World. Wave *data* (composition,
## counts, DNA) lives in WaveManager; Win/Lose decisions live in MatchManager.
##
## Runs as a normal (PAUSABLE) Node so pausing the SceneTree automatically
## halts spawning, exactly like every other gameplay timer.

signal enemy_died(dino_id: String)
signal enemy_reached_boundary
signal wave_finished
## Emitted right after a T-Rex instance is added to the World, so MatchManager
## can wire up the dedicated Boss HP Bar (requirement #17).
signal boss_spawned(enemy: Node2D)

const LANE_CAPACITY := 10
const ROWS := 5

const DINOSAUR_SCENES := {
	"dryosaurus": "res://scenes/enemies/dryosaurus.tscn",
	"velociraptor": "res://scenes/enemies/velociraptor.tscn",
	"triceratops": "res://scenes/enemies/triceratops.tscn",
	"trex": "res://scenes/enemies/trex.tscn",
}

var world: Node2D
var board: StageBoard

var _queue: Array[String] = []
var _spawn_index: int = 0
var _lane_counts: Dictionary = {}
var _alive_count: int = 0
var _active: bool = false
var _elapsed: float = 0.0
var _next_spawn_time: float = 0.0
var _hp_multiplier: float = 1.0
var _finished_emitted: bool = false
## Requirement (2026-08-21): only Wave 1 of every stage uses the original
## slow-start pacing below; Wave 2 onward uses a flat 0.5-3s random cadence.
var _is_first_wave: bool = true

func setup(p_world: Node2D, p_board: StageBoard) -> void:
	world = p_world
	board = p_board

## Starts spawning dinosaurs for one wave. wave_data comes from
## WaveManager.get_wave_data(); hp_multiplier from WaveManager.compute_hp_multiplier().
func start_wave(wave_data: Dictionary, hp_multiplier: float, is_first_wave: bool = true) -> void:
	_queue = _build_queue(wave_data)
	_spawn_index = 0
	_alive_count = 0
	_lane_counts.clear()
	for lane in ROWS:
		_lane_counts[lane] = 0
	_elapsed = 0.0
	_hp_multiplier = hp_multiplier
	_finished_emitted = false
	_is_first_wave = is_first_wave
	_next_spawn_time = randf_range(3.0, 5.0) if _is_first_wave else randf_range(0.5, 3.0)
	_active = true

## Immediately halts further spawning (used on Lose / Surrender).
func stop() -> void:
	_active = false

func _build_queue(wave_data: Dictionary) -> Array[String]:
	var queue: Array[String] = []
	var allowed: Array = wave_data.get("allowed_ids", [])
	var count := int(wave_data.get("dinosaur_count", 0))
	for i in count:
		if allowed.is_empty():
			break
		queue.append(String(allowed[randi() % allowed.size()]))
	if bool(wave_data.get("has_boss", false)):
		var boss_id := String(wave_data.get("boss_id", ""))
		if boss_id != "":
			queue.append(boss_id)
	return queue

func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed += delta

	if _spawn_index < _queue.size():
		if _elapsed >= _next_spawn_time:
			_attempt_spawn()
	else:
		_check_finished()

func _attempt_spawn() -> void:
	var lane := _pick_available_lane()
	if lane == -1:
		# Requirement #8: never spawn an 11th dinosaur into a full lane, and
		# never spin forever — just try again shortly on a later _process tick.
		_next_spawn_time = _elapsed + 1.0
		return

	var dino_id: String = _queue[_spawn_index]
	_spawn_index += 1
	_spawn_one(dino_id, lane)
	_schedule_next_spawn()

func _schedule_next_spawn() -> void:
	if not _is_first_wave:
		if _elapsed <= 20.0:
			_next_spawn_time = _elapsed + randf_range(3, 5)
		else:
			_next_spawn_time = _elapsed + randf_range(0.5, 3)
		return

	if _elapsed <= 50.0:
		_next_spawn_time = _elapsed + randf_range(15, 17)
	elif _elapsed <= 70.0:
		_next_spawn_time = _elapsed + randf_range(6, 8)
	elif _elapsed <= 80.0:
		_next_spawn_time = _elapsed + randf_range(1.0, 3)

func _pick_available_lane() -> int:
	var lanes: Array = range(ROWS)
	lanes.shuffle()
	for lane in lanes:
		if int(_lane_counts.get(lane, 0)) < LANE_CAPACITY:
			return lane
	return -1

func _spawn_one(dino_id: String, lane: int) -> void:
	if not DINOSAUR_SCENES.has(dino_id):
		push_error("SpawnManager: unknown dinosaur id '%s'" % dino_id)
		return
	var scene: PackedScene = load(DINOSAUR_SCENES[dino_id])
	if scene == null or world == null or board == null:
		push_error("SpawnManager: unable to spawn '%s' — missing scene/world/board." % dino_id)
		return

	var enemy := scene.instantiate() as Node2D
	if enemy == null:
		push_error("SpawnManager: dinosaur scene root is not Node2D: %s" % dino_id)
		return

	var cell_size := board.get_cell_size()
	enemy.position = Vector2(board.board_rect.end.x + cell_size.x * 0.5, board.grid_to_world(lane, 0).y)
	world.add_child(enemy)

	if enemy.has_method("setup"):
		enemy.setup(lane, board.board_rect, cell_size, _hp_multiplier)

	_lane_counts[lane] = int(_lane_counts.get(lane, 0)) + 1
	_alive_count += 1

	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died.bind(dino_id))
	if enemy.has_signal("reached_boundary"):
		enemy.reached_boundary.connect(_on_enemy_reached_boundary)
	enemy.tree_exiting.connect(_on_enemy_removed.bind(lane))

	if dino_id == "trex":
		boss_spawned.emit(enemy)

func _on_enemy_died(dino_id: String) -> void:
	enemy_died.emit(dino_id)

func _on_enemy_reached_boundary() -> void:
	enemy_reached_boundary.emit()

func _on_enemy_removed(lane: int) -> void:
	_lane_counts[lane] = maxi(0, int(_lane_counts.get(lane, 0)) - 1)
	_alive_count = maxi(0, _alive_count - 1)
	_check_finished()

func _check_finished() -> void:
	if _finished_emitted:
		return
	# Requirement #9: Wave Clear only when ALL dinosaurs are spawned AND none
	# remain alive — spawning the full count is not sufficient on its own.
	if _spawn_index >= _queue.size() and _alive_count <= 0:
		_finished_emitted = true
		_active = false
		wave_finished.emit()
