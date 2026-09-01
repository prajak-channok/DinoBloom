extends Node2D
class_name Dryosaurus

## M4: emitted once, right before this dinosaur is removed for dying to
## Plant/Trap damage. Used by MatchManager for kill-based Ancient Seed drops
## and by SpawnManager for wave "all cleared" bookkeeping.
signal died
## M4: emitted once, right before this dinosaur is removed for reaching the
## Gameplay Area left boundary. Distinct from `died` because it triggers an
## immediate Match LOSE, not a kill reward.
signal reached_boundary

const DATA: DinosaurData = preload("res://data/dinosaurs/dryosaurus.tres")

## Runtime footprint used for the stop point at the right edge of a Plant cell.
## This is gameplay-space, not the sprite's visual size.
@export var body_half_width: float = 56.0
@export var feet_visual_offset: float = -42.0
@export var contact_padding: float = 2.0

@onready var visual: Node2D = $Visual
@onready var sprite: AnimatedSprite2D = $Visual/AnimatedSprite2D
@onready var hp_bar: ProgressBar = $HPBar

var grid_row: int = 0
var hp: float = 0.0
var max_hp: float = 0.0
var _attack_timer: float = 0.0
var _board_rect := Rect2()
var _state := "walking"
var _target: Node2D = null
## Ginkgo Cannon Conversion owns this instance's Faction, not a new type/scene.
## "Enemy" or "Friendly"; starts from DATA.faction like every other base stat.
var faction: String = "Enemy"
var _stunned: bool = false
var _stun_timer: float = 0.0

## M4: hp_multiplier is Runtime-computed (stage_multiplier x wave_multiplier)
## by WaveManager/MatchManager. Base Data (.tres) is never modified.
func setup(row: int, board_rect: Rect2 = Rect2(), _cell_size: Vector2 = Vector2(120.0, 100.0), hp_multiplier: float = 1.0) -> void:
	grid_row = row
	hp = DATA.base_hp * hp_multiplier
	max_hp = hp
	_board_rect = board_rect
	_attack_timer = 0.0
	_state = "walking"
	_target = null
	faction = DATA.faction
	_update_hp_bar()
	_play_walk()
	add_to_group("enemies")

func _ready() -> void:
	# The scene can be previewed without gameplay setup.
	if hp <= 0.0:
		hp = DATA.base_hp
		max_hp = DATA.base_hp
	_update_hp_bar()
	_play_walk()

func _process(delta: float) -> void:
	if _stunned:
		_stun_timer -= delta

		if _stun_timer <= 0.0:
			_stunned = false
			_stun_timer = 0.0
			_state = "walking"
			_play_walk()

		return

	_clear_freeze_tint()
	# Friendly (Converted) walks right, back toward the Enemy spawn edge, and
	# only fights Enemy Dinosaurs; still-Enemy walks left and can eat a Plant
	# or fight a Friendly Dinosaur, exactly like before Conversion existed.
	var move_dir: float = 1.0 if faction == "Friendly" else -1.0
	var target := _find_target_ahead(move_dir)
	if target != null:
		var target_rect: Rect2 = target.get_interaction_rect() if target.has_method("get_interaction_rect") else Rect2(target.position, Vector2.ZERO)
		var stop_x: float = target_rect.end.x + body_half_width + contact_padding if move_dir < 0.0 else target_rect.position.x - body_half_width - contact_padding
		var reached: bool = position.x <= stop_x if move_dir < 0.0 else position.x >= stop_x

		# Move continuously until the dinosaur's gameplay footprint reaches the
		# target's edge. Snap only when crossing the exact contact point; never
		# reset to a cell edge each frame.
		if not reached:
			_state = "walking"
			_target = null
			_play_walk()
			position.x = maxf(position.x - DATA.movement_speed * delta, stop_x) if move_dir < 0.0 else minf(position.x + DATA.movement_speed * delta, stop_x)
		else:
			_state = "eating"
			_target = target
			_play_eat()
			_attack_timer += delta
			if _attack_timer >= DATA.attack_interval:
				_attack_timer -= DATA.attack_interval
				if is_instance_valid(target) and target.has_method("take_damage"):
					target.take_damage(DATA.attack)
	else:
		_state = "walking"
		_target = null
		_attack_timer = 0.0
		_play_walk()
		position.x += move_dir * DATA.movement_speed * delta

	if _board_rect.size.x <= 0.0:
		return
	if move_dir < 0.0 and position.x < _board_rect.position.x - body_half_width:
		reached_boundary.emit()
		queue_free()
	elif move_dir > 0.0 and position.x > _board_rect.end.x + body_half_width:
		# Friendly with nothing left to fight walks off the spawn edge; freeing
		# it here (no signal) still fires tree_exiting so SpawnManager's alive
		# count clears normally, without counting as a Lose or an Enemy kill.
		queue_free()

func _play_walk() -> void:
	if sprite == null:
		return
	if sprite.animation != &"walk" or not sprite.is_playing():
		sprite.play("walk")

func _play_eat() -> void:
	if sprite == null:
		return
	if sprite.animation != &"eat" or not sprite.is_playing():
		sprite.play("eat")

## move_dir < 0 (still Enemy): targets are Plants + Friendly Dinosaurs ahead
## to the left. move_dir > 0 (Converted to Friendly): targets are Enemy
## Dinosaurs ahead to the right. Mirrors the Faction rules 1:1:
## Enemy -> Plant/Friendly allowed, Friendly -> Enemy allowed, nothing else.
func _find_target_ahead(move_dir: float) -> Node2D:
	var groups: Array = ["enemies"] if move_dir > 0.0 else ["plants", "friendly_dinosaurs"]
	var best: Node2D = null
	var best_distance: float = INF
	for group_name in groups:
		for node: Node in get_tree().get_nodes_in_group(group_name):
			if not is_instance_valid(node) or node is not Node2D or node == self:
				continue
			if int(node.get("grid_row")) != grid_row:
				continue
			var other := node as Node2D
			var other_rect: Rect2 = other.get_interaction_rect() if other.has_method("get_interaction_rect") else Rect2(other.position, Vector2.ZERO)
			# A target remains valid while this dinosaur is anywhere past its
			# far edge in the direction of travel — same "still eating after
			# reaching the stop point" contract as the original Plant check.
			var distance_ahead: float
			if move_dir < 0.0:
				if position.x < other_rect.position.x - body_half_width:
					continue
				distance_ahead = position.x - other_rect.end.x
			else:
				if position.x > other_rect.end.x + body_half_width:
					continue
				distance_ahead = other_rect.position.x - position.x
			if distance_ahead < best_distance:
				best = other
				best_distance = distance_ahead
	return best

func take_damage(amount: float) -> void:
	hp -= amount
	_update_hp_bar()
	if hp <= 0.0:
		died.emit()
		queue_free()

func _update_hp_bar() -> void:
	if is_instance_valid(hp_bar):
		hp_bar.max_value = max_hp if max_hp > 0.0 else DATA.base_hp
		hp_bar.value = maxf(hp, 0.0)

func get_hp() -> float:
	return hp

func get_interaction_rect() -> Rect2:
	return Rect2(Vector2(position.x - body_half_width, position.y), Vector2(body_half_width * 2.0, 0.0))

## Species-level gate (DATA.can_be_converted, false only for T-Rex) plus the
## instance's own current Faction — already-Friendly or already-non-Enemy
## can't be re-converted. Ginkgo Projectile calls this before converting.
func can_be_converted() -> bool:
	return faction == "Enemy" and DATA.can_be_converted

## Owns its own state transition: Faction -> Friendly, HP -> Max HP, Armor
## untouched (DATA is never modified), Movement direction flips because
## _process() reads `faction` every frame. No new Dinosaur type/scene.
func convert_to_friendly() -> void:
	if not can_be_converted():
		return
	faction = "Friendly"
	hp = max_hp
	sprite.flip_h = true
	_update_hp_bar()
	remove_from_group("enemies")
	add_to_group("friendly_dinosaurs")
	_target = null
	_attack_timer = 0.0

func apply_stun(duration: float) -> void:
	_stunned = true
	_stun_timer = maxf(_stun_timer, duration)
	_state = "stunned"
	_target = null
	_attack_timer = 0.0

	if sprite != null:
		sprite.stop()
		sprite.animation = &"walk"
		sprite.frame = 0
		
func _clear_freeze_tint() -> void:
	if modulate != Color.WHITE:
		modulate = Color.WHITE
