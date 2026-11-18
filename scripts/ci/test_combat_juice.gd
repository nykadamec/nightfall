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
		_fail("Autoloads missing")
		return
	run_state.call("reset")

	var err: Error = change_scene_to_file("res://scenes/world/main.tscn")
	if err != OK:
		_fail("Failed to load main.tscn")
		return
	await process_frame
	await process_frame

	var player: Player = get_first_node_in_group("player") as Player
	if player == null:
		_fail("Player missing")
		return
	var cam: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if cam == null:
		_fail("Camera2D missing on Player")
		return

	var enemy_scene: PackedScene = load("res://scenes/actors/enemy_bat.tscn") as PackedScene
	if enemy_scene == null:
		_fail("enemy_bat.tscn missing")
		return
	var enemy: EnemyBase = enemy_scene.instantiate() as EnemyBase
	enemy.global_position = player.global_position + Vector2(180.0, 0.0)
	current_scene.get_node("World").add_child(enemy)
	await process_frame

	var pool_before_v: Variant = pool_mgr.call("get_free_count", "damage_number")
	var pool_before: int = pool_before_v if pool_before_v is int else 0
	if pool_before < 1:
		_fail("Expected prefilled damage_number pool, got %d" % pool_before)
		return

	enemy.take_damage(7)
	await process_frame

	var pool_after_hit_v: Variant = pool_mgr.call("get_free_count", "damage_number")
	var pool_after_hit: int = pool_after_hit_v if pool_after_hit_v is int else 0
	if pool_after_hit != pool_before - 1:
		_fail("Expected 1 damage_number acquired from pool (%d -> %d)" % [pool_before, pool_after_hit])
		return

	# Player hit -> camera shake + red damage number
	player.set("_invuln_timer", 0.0)
	player.take_damage(5)
	await physics_frame
	await physics_frame
	if cam.offset.length() <= 0.01:
		_fail("Expected non-zero camera shake offset on player hit, got %s" % str(cam.offset))
		return

	# Wait ~0.75s for damage numbers to expire back to pool and camera shake to decay
	for i: int in range(48):
		await physics_frame
		await process_frame

	var pool_end_v: Variant = pool_mgr.call("get_free_count", "damage_number")
	var pool_end: int = pool_end_v if pool_end_v is int else 0
	if pool_end != pool_before:
		_fail("Expected damage_numbers returned to pool (%d != %d)" % [pool_end, pool_before])
		return
	if cam.offset.length() >= 0.25:
		_fail("Expected camera offset to decay back to zero, got %s" % str(cam.offset))
		return

	print("TEST COMBAT JUICE PASSED")
	quit(0)
