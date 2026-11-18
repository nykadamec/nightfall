extends SceneTree
## Headless CI test for T2.5: Wave spawner spawns enemies in a ring clamped to arena
## and respects max_live_enemies cap.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var main_packed: PackedScene = load("res://scenes/world/main.tscn") as PackedScene
	var main: Node = main_packed.instantiate()
	root.add_child(main)
	await process_frame

	var spawner: Node = main.get_node_or_null("World/Spawner")
	assert(spawner != null, "Spawner missing in World")

	var wt_v: Variant = spawner.get("wave_table")
	assert(wt_v is Resource, "Spawner wave_table missing")
	var wt: Resource = wt_v

	# Speed up spawn interval slightly for fast headless test, and test cap
	var test_wt: Resource = wt.duplicate()
	test_wt.set("base_interval_sec", 0.05)
	test_wt.set("min_interval_sec", 0.05)
	test_wt.set("max_live_enemies", 5)
	spawner.set("wave_table", test_wt)

	var initial_count: int = get_nodes_in_group("enemies").size()
	for _i: int in range(30):
		await process_frame

	var after_count: int = get_nodes_in_group("enemies").size()
	assert(after_count > initial_count, "Expected spawner to spawn enemies (before=%d, after=%d)" % [initial_count, after_count])
	assert(after_count <= 5, "Expected live enemies <= 5, got %d" % after_count)

	# Verify all enemies are within arena_half_extents
	var ext_v: Variant = test_wt.get("arena_half_extents")
	var ext: Vector2 = ext_v if ext_v is Vector2 else Vector2(1150.0, 560.0)
	for enemy_node: Node in get_nodes_in_group("enemies"):
		var enemy: Node2D = enemy_node as Node2D
		assert(absf(enemy.global_position.x) <= ext.x + 1.0, "Enemy X out of arena bounds: %f" % enemy.global_position.x)
		assert(absf(enemy.global_position.y) <= ext.y + 1.0, "Enemy Y out of arena bounds: %f" % enemy.global_position.y)

	print("TEST SPAWNER PASSED")
	quit(0)
