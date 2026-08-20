extends Node
class_name MatchManager
## M4: Responsible for Match *state* and Win/Lose decisions only. It reads
## Wave data from WaveManager, tells SpawnManager when to spawn, and reacts to
## its signals. UI never decides gameplay outcomes — it only calls into this
## node (toggle_pause / toggle_speed / request_surrender / ...).
##
## Runs with PROCESS_MODE_ALWAYS (set in gameplay_scene.tscn) so its own
## popup countdown timers keep advancing even while get_tree().paused is true
## for gameplay (Wave Start / Wave Clear / Pause / Win / Lose all pause the
## rest of the game — see set_state()).

enum State {
	PREPARING,
	WAVE_START,
	PLAYING,
	WAVE_CLEAR,
	PAUSED,
	WIN,
	LOSE,
	SURRENDER_CONFIRM,
}

## Design/UX timing choices (not specified exactly by the design doc, which
## only mandates the 5s Wave Clear break). Kept as named consts so they are
## easy to tune without touching logic.
const WAVE_START_POPUP_SECONDS := 2.0
const WAVE_CLEAR_BREAK_SECONDS := 5.0
const SEED_DROP_CHANCE := 0.10
const SEED_DROP_AMOUNT := 25

signal state_changed(new_state: int)

var state: int = State.PREPARING

var gameplay: Node = null
var wave_manager: WaveManager = null
var spawn_manager: SpawnManager = null
var stage: StageData = null
var stage_id: String = ""

var current_wave: int = 1
var _pre_pause_state: int = State.PLAYING
var _pre_surrender_state: int = State.PLAYING
var _popup_timer: float = 0.0
var _match_ended: bool = false

# --- UI references (all provided via setup()) ---
var ui_wave_label: Label
var ui_boss_bar_container: Control
var ui_boss_bar: ProgressBar
var ui_pause_button: Button
var ui_speed_button: Button
var ui_surrender_button: Button

var ui_wave_start_popup: Control
var ui_wave_start_label: Label

var ui_wave_clear_popup: Control
var ui_wave_clear_title: Label
var ui_wave_clear_dna: Label
var ui_wave_clear_countdown: Label

var ui_win_popup: Control
var ui_win_button: Button

var ui_lose_popup: Control
var ui_lose_button: Button

var ui_surrender_popup: Control
var ui_surrender_confirm_button: Button
var ui_surrender_cancel_button: Button

var ui_paused_overlay: Control

var _boss_node: Node2D = null

func setup(p_gameplay: Node, p_wave_manager: WaveManager, p_spawn_manager: SpawnManager, p_stage: StageData, p_stage_id: String, ui: Dictionary) -> void:
	gameplay = p_gameplay
	wave_manager = p_wave_manager
	spawn_manager = p_spawn_manager
	stage = p_stage
	stage_id = p_stage_id

	ui_wave_label = ui.get("wave_label")
	ui_boss_bar_container = ui.get("boss_bar_container")
	ui_boss_bar = ui.get("boss_bar")
	ui_pause_button = ui.get("pause_button")
	ui_speed_button = ui.get("speed_button")
	ui_surrender_button = ui.get("surrender_button")

	ui_wave_start_popup = ui.get("wave_start_popup")
	ui_wave_start_label = ui.get("wave_start_label")

	ui_wave_clear_popup = ui.get("wave_clear_popup")
	ui_wave_clear_title = ui.get("wave_clear_title")
	ui_wave_clear_dna = ui.get("wave_clear_dna")
	ui_wave_clear_countdown = ui.get("wave_clear_countdown")

	ui_win_popup = ui.get("win_popup")
	ui_win_button = ui.get("win_button")

	ui_lose_popup = ui.get("lose_popup")
	ui_lose_button = ui.get("lose_button")

	ui_surrender_popup = ui.get("surrender_popup")
	ui_surrender_confirm_button = ui.get("surrender_confirm_button")
	ui_surrender_cancel_button = ui.get("surrender_cancel_button")

	ui_paused_overlay = ui.get("paused_overlay")

	if ui_pause_button:
		ui_pause_button.pressed.connect(toggle_pause)
	if ui_speed_button:
		ui_speed_button.pressed.connect(toggle_speed)
	if ui_surrender_button:
		ui_surrender_button.pressed.connect(request_surrender)
	if ui_surrender_confirm_button:
		ui_surrender_confirm_button.pressed.connect(confirm_surrender)
	if ui_surrender_cancel_button:
		ui_surrender_cancel_button.pressed.connect(cancel_surrender)
	if ui_win_button:
		ui_win_button.pressed.connect(_return_to_stage_select)
	if ui_lose_button:
		ui_lose_button.pressed.connect(_return_to_stage_select)

	spawn_manager.enemy_died.connect(_on_enemy_died)
	spawn_manager.enemy_reached_boundary.connect(_on_enemy_reached_boundary)
	spawn_manager.wave_finished.connect(_on_wave_finished)
	spawn_manager.boss_spawned.connect(_on_boss_spawned)

func start_match() -> void:
	Engine.time_scale = 1.0
	_match_ended = false
	if not wave_manager.is_stage_supported(stage_id):
		# Requirement #2/#39: only Stage 1 is implemented in M4. Fail safely
		# instead of crashing if a later stage is somehow reached.
		push_warning("MatchManager: '%s' has no Wave data yet (M4 only implements Stage 1). Returning to Select Stage." % stage_id)
		_return_to_stage_select()
		return
	current_wave = 1
	_begin_wave_start()

func _begin_wave_start() -> void:
	if ui_wave_label:
		ui_wave_label.text = "Wave %d / %d" % [current_wave, wave_manager.TOTAL_WAVES]
	if ui_wave_start_label:
		ui_wave_start_label.text = "WAVE %d" % current_wave
	_popup_timer = WAVE_START_POPUP_SECONDS
	set_state(State.WAVE_START)

func _begin_playing() -> void:
	set_state(State.PLAYING)
	var wave_data := wave_manager.get_wave_data(stage_id, current_wave)
	var hp_multiplier := wave_manager.compute_hp_multiplier(stage, wave_data)
	spawn_manager.start_wave(wave_data, hp_multiplier)

func _process(delta: float) -> void:
	match state:
		State.WAVE_START:
			_popup_timer -= delta
			if _popup_timer <= 0.0:
				_begin_playing()
		State.WAVE_CLEAR:
			_popup_timer -= delta
			if ui_wave_clear_countdown:
				ui_wave_clear_countdown.text = "Next wave in %ds..." % maxi(0, ceili(_popup_timer))
			if _popup_timer <= 0.0:
				current_wave += 1
				_begin_wave_start()

# ---------------------------------------------------------------------------
# Wave lifecycle
# ---------------------------------------------------------------------------

func _on_wave_finished() -> void:
	if _match_ended:
		return
	var wave_data := wave_manager.get_wave_data(stage_id, current_wave)
	var dna_reward := wave_manager.compute_dna_reward(wave_data)
	SaveManager.add_dna(dna_reward)

	if current_wave >= wave_manager.TOTAL_WAVES:
		_trigger_win(dna_reward)
	else:
		if ui_wave_clear_title:
			ui_wave_clear_title.text = "Wave %d Complete" % current_wave
		if ui_wave_clear_dna:
			ui_wave_clear_dna.text = "+%d DNA" % dna_reward
		_popup_timer = WAVE_CLEAR_BREAK_SECONDS
		set_state(State.WAVE_CLEAR)

func _on_enemy_died(_dino_id: String) -> void:
	# Requirement #24: 10% chance to gain +25 Ancient Seed per kill, capped
	# by add_seed()'s own MAX_SEED clamp on the gameplay scene.
	if randf() < SEED_DROP_CHANCE:
		if gameplay and gameplay.has_method("add_seed"):
			gameplay.add_seed(SEED_DROP_AMOUNT)

func _on_enemy_reached_boundary() -> void:
	if state != State.PLAYING:
		return
	_trigger_lose()

func _on_boss_spawned(enemy: Node2D) -> void:
	_boss_node = enemy
	if enemy.has_signal("hp_changed"):
		enemy.hp_changed.connect(_on_boss_hp_changed)
	enemy.tree_exiting.connect(_on_boss_removed)
	if ui_boss_bar_container:
		ui_boss_bar_container.visible = true
	# The first hp_changed emit happens inside setup(), before this connection
	# exists, so sync the bar's initial Max/Current HP here explicitly.
	_on_boss_hp_changed(float(enemy.get("hp")), float(enemy.get("max_hp")))

func _on_boss_hp_changed(current: float, max_hp: float) -> void:
	if ui_boss_bar:
		ui_boss_bar.max_value = max_hp
		ui_boss_bar.value = current

func _on_boss_removed() -> void:
	_boss_node = null
	if ui_boss_bar_container:
		ui_boss_bar_container.visible = false

# ---------------------------------------------------------------------------
# Win / Lose / Surrender
# ---------------------------------------------------------------------------

func _trigger_win(_last_wave_dna: int) -> void:
	_match_ended = true
	spawn_manager.stop()
	SaveManager.mark_stage_completed(stage_id)
	set_state(State.WIN)

func _trigger_lose() -> void:
	_match_ended = true
	spawn_manager.stop()
	set_state(State.LOSE)

func request_surrender() -> void:
	if state in [State.WIN, State.LOSE, State.SURRENDER_CONFIRM, State.PREPARING]:
		return
	_pre_surrender_state = state
	set_state(State.SURRENDER_CONFIRM)

func confirm_surrender() -> void:
	_match_ended = true
	spawn_manager.stop()
	# Requirement #30: Surrender grants no reward for the in-progress wave;
	# DNA already banked from previously cleared waves this match is not undone.
	Engine.time_scale = 1.0
	get_tree().paused = false
	_return_to_stage_select()

func cancel_surrender() -> void:
	set_state(_pre_surrender_state)

func _return_to_stage_select() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/select_stage_scene.tscn")

# ---------------------------------------------------------------------------
# Pause / Speed
# ---------------------------------------------------------------------------

func toggle_pause() -> void:
	if state == State.PLAYING:
		_pre_pause_state = state
		set_state(State.PAUSED)
	elif state == State.PAUSED:
		set_state(_pre_pause_state)

func toggle_speed() -> void:
	if Engine.time_scale < 1.5:
		Engine.time_scale = 2.0
	else:
		Engine.time_scale = 1.0
	if ui_speed_button:
		ui_speed_button.text = "1×" if Engine.time_scale >= 1.5 else "2×"

# ---------------------------------------------------------------------------
# State machine
# ---------------------------------------------------------------------------

func set_state(new_state: int) -> void:
	state = new_state
	# Everything except PLAYING pauses the SceneTree. Nodes that must keep
	# working while paused (this Manager, the Popups layer, UI buttons) are
	# set to PROCESS_MODE_ALWAYS in the scene.
	get_tree().paused = state != State.PLAYING

	_update_popup_visibility()
	_update_button_states()
	state_changed.emit(state)

func _update_popup_visibility() -> void:
	if ui_wave_start_popup:
		ui_wave_start_popup.visible = state == State.WAVE_START
	if ui_wave_clear_popup:
		ui_wave_clear_popup.visible = state == State.WAVE_CLEAR
	if ui_win_popup:
		ui_win_popup.visible = state == State.WIN
	if ui_lose_popup:
		ui_lose_popup.visible = state == State.LOSE
	if ui_surrender_popup:
		ui_surrender_popup.visible = state == State.SURRENDER_CONFIRM
	if ui_paused_overlay:
		ui_paused_overlay.visible = state == State.PAUSED

func _update_button_states() -> void:
	if ui_pause_button:
		ui_pause_button.disabled = state not in [State.PLAYING, State.PAUSED]
		ui_pause_button.text = "RESUME" if state == State.PAUSED else "PAUSE"
	if ui_surrender_button:
		ui_surrender_button.disabled = state in [State.WIN, State.LOSE, State.SURRENDER_CONFIRM, State.PREPARING]
