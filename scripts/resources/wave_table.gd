class_name WaveTable
extends Resource
## Data-driven wave pacing parameters for Spawner.

@export var base_interval_sec: float = 1.6
@export var min_interval_sec: float = 0.45
@export var interval_decay_per_min: float = 0.35
@export var max_live_enemies: int = 35
@export var ring_min_radius: float = 340.0
@export var ring_max_radius: float = 480.0
@export var arena_half_extents: Vector2 = Vector2(1150.0, 560.0)
@export var enemy_types: Array[EnemyData] = []
@export var unlock_times_sec: Array[float] = [0.0, 20.0, 45.0, 75.0]


func get_interval_for_time(time_sec: float) -> float:
	var minutes: float = maxf(0.0, time_sec / 60.0)
	return maxf(min_interval_sec, base_interval_sec - minutes * interval_decay_per_min)


func get_batch_size_for_time(time_sec: float) -> int:
	if time_sec >= 120.0:
		return 3
	if time_sec >= 45.0:
		return 2
	return 1


func pick_enemy_for_time(time_sec: float, rng: RandomNumberGenerator) -> EnemyData:
	if enemy_types.is_empty():
		return null
	var unlocked: Array[EnemyData] = []
	for i: int in range(enemy_types.size()):
		var ed: EnemyData = enemy_types[i]
		if ed == null:
			continue
		var unlock_t: float = unlock_times_sec[i] if i < unlock_times_sec.size() else 0.0
		if time_sec >= unlock_t:
			unlocked.append(ed)
	if unlocked.is_empty():
		return enemy_types[0]
	return unlocked[rng.randi_range(0, unlocked.size() - 1)]
