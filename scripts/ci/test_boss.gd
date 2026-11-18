extends SceneTree
## Headless CI test for T3.6: Boss spawns at boss_spawn_time_sec, emits boss_spawned,
## boss_hp_changed on damage, and boss_died once at 0 HP.

var _spawned_count: int = 0
var _hp_changed_count: int = 0
var _died_count: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_state: Node = root.get_node_or_null("RunState")
	var bus: Node = root.get_node_or_null("EventBus")
	assert(run_state != null and bus != null, "Autoloads missing")
	run_state.call("reset")

	bus.connect("boss_spawned", func(_n: String, _m: int) -> void: _spawned_count += 1)
	bus.connect("boss_hp_changed", func(_c: int, _m: int) -> void: _hp_changed_count += 1)
	bus.connect("boss_died", func() -> void: _died_count += 1)

	var main_packed: PackedScene = load("res://scenes/world/main.tscn") as PackedScene
	var main: Node = main_packed.instantiate()
	root.add_child(main)
	await process_frame

	var spawner: Node = main.get_node_or_null("World/Spawner")
	assert(spawner != null, "Spawner missing")
	var threshold_v: Variant = spawner.get("boss_spawn_time_sec")
	var threshold: float = threshold_v if threshold_v is float else 600.0

	# Just below threshold -> no boss yet
	run_state.set("time_sec", threshold - 0.5)
	await process_frame
	assert(_spawned_count == 0, "Boss should not spawn before threshold")

	# Advance past threshold -> spawns exactly once
	run_state.set("time_sec", threshold + 0.1)
	for _i: int in range(5):
		await process_frame
	assert(_spawned_count == 1, "Expected 1 boss_spawned, got %d" % _spawned_count)
	var bosses: Array[Node] = get_nodes_in_group("bosses")
	assert(bosses.size() == 1, "Expected 1 boss in tree, got %d" % bosses.size())

	var boss: EnemyBase = bosses[0] as EnemyBase
	boss.take_damage(50)
	assert(_hp_changed_count == 1, "Expected boss_hp_changed on damage")

	# Kill boss + extra damage -> boss_died fires only once
	boss.take_damage(10000)
	boss.take_damage(100)
	await process_frame
	assert(_died_count == 1, "Expected boss_died once, got %d" % _died_count)

	print("TEST BOSS PASSED")
	quit(0)
