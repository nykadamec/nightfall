class_name Spawner
extends Node2D
## Spawns enemies in a ring around the player clamped inside arena bounds.

const DEFAULT_BOSS_SCENE: PackedScene = preload("res://scenes/actors/boss_vampire_lord.tscn")

@export var wave_table: WaveTable
@export var enemy_scene: PackedScene
@export var boss_scene: PackedScene = DEFAULT_BOSS_SCENE
@export var boss_spawn_time_sec: float = 600.0

var _timer: float = 0.0
var _boss_spawned: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func _process(delta: float) -> void:
	if wave_table == null or enemy_scene == null:
		return
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var run_time: float = 0.0
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	if run_state != null:
		var t_val: Variant = run_state.get("time_sec")
		run_time = t_val if t_val is float else 0.0

	if not _boss_spawned and run_time >= boss_spawn_time_sec and boss_scene != null:
		_spawn_boss(player.global_position)

	_timer += delta
	var interval: float = wave_table.get_interval_for_time(run_time)
	if _timer < interval:
		return
	_timer -= interval

	var live_count: int = get_tree().get_nodes_in_group("enemies").size()
	if live_count >= wave_table.max_live_enemies:
		return

	var batch: int = mini(
		wave_table.get_batch_size_for_time(run_time),
		wave_table.max_live_enemies - live_count
	)
	var parent_node: Node = get_parent() if get_parent() != null else self
	for _i: int in range(batch):
		var spawn_pos: Vector2 = _pick_spawn_position(player.global_position)
		var ed: EnemyData = wave_table.pick_enemy_for_time(run_time, _rng)
		var enemy: Node2D = _acquire_enemy(ed)
		if enemy != null:
			enemy.global_position = spawn_pos
			if enemy.get_parent() == null:
				parent_node.add_child(enemy)
			if ed != null and enemy.has_method("apply_data"):
				enemy.call("apply_data", ed)


func _spawn_boss(player_pos: Vector2) -> void:
	_boss_spawned = true
	var boss: Node2D = boss_scene.instantiate() as Node2D
	if boss == null:
		return
	boss.global_position = _pick_spawn_position(player_pos)
	var parent_node: Node = get_parent() if get_parent() != null else self
	parent_node.add_child(boss)


func _acquire_enemy(ed: EnemyData) -> Node2D:
	var pool: Node = get_tree().root.get_node_or_null("PoolManager") if get_tree() != null else null
	if pool != null and ed != null and not ed.id.is_empty() and pool.has_method("acquire"):
		var key: String = "enemy_" + ed.id
		var pooled_v: Variant = pool.call("acquire", key)
		if pooled_v is Node2D:
			var n2d: Node2D = pooled_v
			return n2d
	var scene: PackedScene = ed.enemy_scene if ed != null and ed.enemy_scene != null else enemy_scene
	if scene == null:
		return null
	return scene.instantiate() as Node2D


func _pick_spawn_position(center: Vector2) -> Vector2:
	var angle: float = _rng.randf_range(0.0, TAU)
	var radius: float = _rng.randf_range(wave_table.ring_min_radius, wave_table.ring_max_radius)
	var offset: Vector2 = Vector2(cos(angle) * radius, sin(angle) * radius * 0.65)
	var pos: Vector2 = center + offset
	var ext: Vector2 = wave_table.arena_half_extents
	pos.x = clampf(pos.x, -ext.x, ext.x)
	pos.y = clampf(pos.y, -ext.y, ext.y)
	return pos
