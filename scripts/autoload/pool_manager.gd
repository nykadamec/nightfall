extends Node
## Object pool manager for enemies, projectiles, and pickups.
## Pool keys: enemy_bat, enemy_skeleton, enemy_zombie, enemy_ghost, holy_bolt, xp_gem, chicken, coin.

const POOL_CONFIGS: Dictionary = {
	"enemy_bat": {"path": "res://scenes/actors/enemy_bat.tscn", "prefill": 20},
	"enemy_skeleton": {"path": "res://scenes/actors/enemy_skeleton.tscn", "prefill": 12},
	"enemy_zombie": {"path": "res://scenes/actors/enemy_zombie.tscn", "prefill": 10},
	"enemy_ghost": {"path": "res://scenes/actors/enemy_ghost.tscn", "prefill": 10},
	"holy_bolt": {"path": "res://scenes/weapons/holy_bolt_projectile.tscn", "prefill": 20},
	"xp_gem": {"path": "res://scenes/world/xp_gem.tscn", "prefill": 40},
	"chicken": {"path": "res://scenes/world/chicken.tscn", "prefill": 6},
	"coin": {"path": "res://scenes/world/coin.tscn", "prefill": 16},
	"damage_number": {"path": "res://scenes/vfx/damage_number.tscn", "prefill": 30},
}

var _scenes: Dictionary = {}
var _free_pools: Dictionary = {}
var _all_instances: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var bus: Node = get_tree().root.get_node_or_null("EventBus")
	if bus != null:
		bus.connect("run_started", prefill_all)


func prefill_all() -> void:
	for key_v: Variant in POOL_CONFIGS.keys():
		var key: String = str(key_v)
		var cfg: Dictionary = POOL_CONFIGS[key]
		var target_v: Variant = cfg.get("prefill", 0)
		var target_count: int = target_v if target_v is int else 0
		_ensure_prefill(key, str(cfg.get("path", "")), target_count)


func _ensure_prefill(key: String, scene_path: String, target_count: int) -> void:
	if not _scenes.has(key) and not scene_path.is_empty():
		if ResourceLoader.exists(scene_path):
			_scenes[key] = load(scene_path)
	var scene_v: Variant = _scenes.get(key, null)
	var scene: PackedScene = scene_v if scene_v is PackedScene else null
	if scene == null:
		return
	if not _free_pools.has(key):
		_free_pools[key] = []
	if not _all_instances.has(key):
		_all_instances[key] = []

	var all_arr: Array = _all_instances[key]
	# Clean invalid refs after scene reload
	var valid_all: Array = []
	for item: Variant in all_arr:
		if item is Node and is_instance_valid(item):
			valid_all.append(item)
	_all_instances[key] = valid_all

	var free_arr: Array = _free_pools[key]
	var valid_free: Array = []
	for item: Variant in free_arr:
		if item is Node and is_instance_valid(item):
			valid_free.append(item)
	_free_pools[key] = valid_free

	while valid_all.size() < target_count:
		var inst: Node = _create_instance(key, scene)
		if inst == null:
			break
		valid_free.append(inst)


func _create_instance(key: String, scene: PackedScene) -> Node:
	var inst: Node = scene.instantiate()
	if inst == null:
		return null
	if "pool_key" in inst:
		inst.set("pool_key", key)
	inst.process_mode = Node.PROCESS_MODE_DISABLED
	if inst is CanvasItem:
		(inst as CanvasItem).visible = false
	add_child(inst)
	if inst.has_method("on_release"):
		inst.call("on_release")
	if not _all_instances.has(key):
		_all_instances[key] = []
	var all_arr: Array = _all_instances[key]
	all_arr.append(inst)
	return inst


func acquire(key: String, target_parent: Node = null) -> Node:
	if not _free_pools.has(key):
		_free_pools[key] = []
	if not _scenes.has(key) and POOL_CONFIGS.has(key):
		var cfg: Dictionary = POOL_CONFIGS[key]
		var path: String = str(cfg.get("path", ""))
		if not path.is_empty() and ResourceLoader.exists(path):
			_scenes[key] = load(path)

	var free_arr: Array = _free_pools[key]
	var inst: Node = null
	while not free_arr.is_empty():
		var candidate_v: Variant = free_arr.pop_back()
		if candidate_v is Node and is_instance_valid(candidate_v):
			inst = candidate_v
			break

	if inst == null:
		var scene_v: Variant = _scenes.get(key, null)
		var scene: PackedScene = scene_v if scene_v is PackedScene else null
		if scene == null:
			return null
		inst = _create_instance(key, scene)
		if inst == null:
			return null

	var dest_parent: Node = target_parent
	if dest_parent == null and get_tree().current_scene != null:
		dest_parent = get_tree().current_scene.get_node_or_null("World")
		if dest_parent == null:
			dest_parent = get_tree().current_scene
	if dest_parent != null and inst.get_parent() != dest_parent:
		if inst.get_parent() != null:
			inst.reparent(dest_parent, false)
		else:
			dest_parent.add_child(inst)

	inst.process_mode = Node.PROCESS_MODE_INHERIT
	if inst is CanvasItem:
		(inst as CanvasItem).visible = true
	if inst.has_method("on_acquire"):
		inst.call("on_acquire")
	return inst


func release(inst: Node) -> void:
	if inst == null or not is_instance_valid(inst):
		return
	var key_v: Variant = inst.get("pool_key") if "pool_key" in inst else ""
	var key: String = str(key_v)
	if key.is_empty():
		inst.queue_free()
		return
	if inst.has_method("on_release"):
		inst.call("on_release")
	inst.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	if inst is CanvasItem:
		(inst as CanvasItem).visible = false
	if inst.get_parent() != self:
		inst.call_deferred("reparent", self, false)
	if not _free_pools.has(key):
		_free_pools[key] = []
	var free_arr: Array = _free_pools[key]
	if not free_arr.has(inst):
		free_arr.append(inst)


func get_total_count(key: String) -> int:
	if not _all_instances.has(key):
		return 0
	var count: int = 0
	var all_arr: Array = _all_instances[key]
	for item: Variant in all_arr:
		if item is Node and is_instance_valid(item):
			count += 1
	return count


func get_free_count(key: String) -> int:
	if not _free_pools.has(key):
		return 0
	var free_arr: Array = _free_pools[key]
	var count: int = 0
	for item: Variant in free_arr:
		if item is Node and is_instance_valid(item):
			count += 1
	return count
	return count
