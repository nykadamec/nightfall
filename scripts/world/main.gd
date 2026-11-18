extends Node2D
## Root coordinator for the main arena scene (spawns XP gems on enemy_died, tracks run time).

const XP_GEM_SCENE: PackedScene = preload("res://scenes/world/xp_gem.tscn")
const CHICKEN_DROP_CHANCE: float = 0.03
const COIN_DROP_CHANCE: float = 0.12

@export var world_seed: int = 0
@export var arena_half_extents: Vector2 = Vector2(1150.0, 560.0)

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var _world: Node2D = $World
@onready var _floor_layer: TileMapLayer = $World/FloorLayer
@onready var _wall_layer: TileMapLayer = $World/WallLayer


func _ready() -> void:
	_rng.randomize()
	WorldGenerator.generate(_world, _floor_layer, _wall_layer, arena_half_extents, 30, 8, 135.0, 175.0, world_seed)
	var event_bus: Node = get_tree().root.get_node_or_null("EventBus")
	if event_bus != null:
		event_bus.connect("enemy_died", _on_enemy_died)
		event_bus.emit_signal("run_started")


func _process(delta: float) -> void:
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	if run_state != null:
		var t_val: Variant = run_state.get("time_sec")
		var cur_t: float = t_val if t_val is float else 0.0
		run_state.set("time_sec", cur_t + delta)


func _on_enemy_died(death_position: Vector2, xp_value: int) -> void:
	if _world == null:
		return
	call_deferred("_spawn_xp_gem", death_position, xp_value)


func _spawn_xp_gem(death_position: Vector2, xp_value: int) -> void:
	if _world == null:
		return
	var gem: XpGem = null
	var pool: Node = get_tree().root.get_node_or_null("PoolManager")
	if pool != null and pool.has_method("acquire"):
		var gem_v: Variant = pool.call("acquire", "xp_gem", _world)
		gem = gem_v if gem_v is XpGem else null
	if gem == null:
		gem = XP_GEM_SCENE.instantiate() as XpGem
		_world.add_child(gem)
	gem.position = death_position
	gem.xp_value = xp_value

	var roll: float = _rng.randf()
	if roll < CHICKEN_DROP_CHANCE:
		_spawn_pooled_pickup("chicken", death_position + Vector2(14.0, 6.0))
	elif roll < CHICKEN_DROP_CHANCE + COIN_DROP_CHANCE:
		_spawn_pooled_pickup("coin", death_position + Vector2(14.0, 6.0))


func _spawn_pooled_pickup(key: String, pos: Vector2) -> void:
	if _world == null:
		return
	var pool: Node = get_tree().root.get_node_or_null("PoolManager")
	if pool != null and pool.has_method("acquire"):
		var node_v: Variant = pool.call("acquire", key, _world)
		if node_v is Node2D:
			var n2d: Node2D = node_v
			n2d.position = pos
