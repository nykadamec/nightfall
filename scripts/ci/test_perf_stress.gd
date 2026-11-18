extends SceneTree


func _fail(msg: String) -> void:
	push_error(msg)
	quit(1)


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_state: Node = root.get_node_or_null("RunState")
	var pool_mgr: Node = root.get_node_or_null("PoolManager")
	if run_state == null or pool_mgr == null:
		_fail("Required autoloads missing")
		return
	run_state.call("reset")

	var err: Error = change_scene_to_file("res://scenes/world/main.tscn")
	if err != OK:
		_fail("Failed to load main.tscn")
		return
	await process_frame
	await process_frame

	var player: Player = get_first_node_in_group("player") as Player
	var spawner: Spawner = current_scene.get_node_or_null("World/Spawner") as Spawner
	var world: Node = current_scene.get_node_or_null("World")
	if player == null or spawner == null or world == null:
		_fail("Player, Spawner, or World missing")
		return

	# Keep player alive during stress pass
	player.set("invuln_duration", 999.0)
	player.set("_invuln_timer", 999.0)
	run_state.set("time_sec", 90.0) # all 4 enemy types unlocked

	var t_start_ms: int = Time.get_ticks_msec()
	var pool_keys: Array[String] = ["enemy_bat", "enemy_skeleton", "enemy_zombie", "enemy_ghost"]

	# Spawn up to max_live_enemies (35)
	for i: int in range(35):
		var key: String = pool_keys[i % pool_keys.size()]
		var enemy_v: Variant = pool_mgr.call("acquire", key, world)
		if enemy_v is EnemyBase:
			var enemy: EnemyBase = enemy_v
			var angle: float = (TAU / 35.0) * float(i)
			enemy.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * 180.0

	# Simulate 180 physics frames at cap
	for f: int in range(180):
		await physics_frame
		await process_frame
		var live_count: int = get_nodes_in_group("enemies").size()
		if live_count > 36: # 35 cap + 1 tolerance if spawner tick landed
			_fail("Live enemies exceeded cap: %d" % live_count)
			return

	# Kill half of the enemies to exercise death -> xp_gem -> damage_number -> pool release
	var enemies: Array[Node] = get_nodes_in_group("enemies")
	var kill_target: int = mini(15, enemies.size())
	for k: int in range(kill_target):
		if enemies[k] is EnemyBase:
			var eb: EnemyBase = enemies[k] as EnemyBase
			eb.take_damage(9999)

	for f2: int in range(60):
		await physics_frame
		await process_frame

	var elapsed_ms: int = Time.get_ticks_msec() - t_start_ms
	var dmg_total_v: Variant = pool_mgr.call("get_total_count", "damage_number")
	var dmg_total: int = dmg_total_v if dmg_total_v is int else 0
	if dmg_total > 60:
		_fail("Unbounded damage_number pool growth: %d" % dmg_total)
		return

	print("PERF STRESS: 240 frames at 35-enemy cap in %d ms (damage_number pool=%d)" % [elapsed_ms, dmg_total])
	print("TEST PERF STRESS PASSED")
	quit(0)
