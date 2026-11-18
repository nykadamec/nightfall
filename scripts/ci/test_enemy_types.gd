extends SceneTree
## Headless CI test for T3.5: Spawner & WaveTable support all four MVP enemy types
## (bat, skeleton, zombie, ghost) without werewolf or mushroom.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_state: Node = root.get_node_or_null("RunState")
	assert(run_state != null, "RunState missing")
	run_state.call("reset")

	var wt: WaveTable = load("res://resources/waves/early_waves.tres") as WaveTable
	assert(wt != null, "Failed to load early_waves.tres")
	assert(wt.enemy_types.size() == 4, "Expected 4 enemy types in wave table, got %d" % wt.enemy_types.size())

	var ids: Array[String] = []
	for ed: EnemyData in wt.enemy_types:
		assert(ed != null and ed.enemy_scene != null, "EnemyData or enemy_scene missing")
		ids.append(ed.id)
		var inst: Node = ed.enemy_scene.instantiate()
		root.add_child(inst)
		await process_frame
		assert(inst is EnemyBase, "Spawned %s is not EnemyBase" % ed.id)
		inst.queue_free()

	assert(ids.has("bat") and ids.has("skeleton") and ids.has("zombie") and ids.has("ghost"),
		"Expected bat/skeleton/zombie/ghost in wave table, got %s" % str(ids))

	# Verify wave table unlocks all 4 by 80s
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42
	var seen: Dictionary = {}
	for _i: int in range(80):
		var picked: EnemyData = wt.pick_enemy_for_time(80.0, rng)
		if picked != null:
			seen[picked.id] = true
	assert(seen.size() == 4, "Expected all 4 enemy types to be pickable at t=80s, saw %s" % str(seen.keys()))

	print("TEST ENEMY TYPES PASSED")
	quit(0)
