extends SceneTree
## Headless CI test for T3.7: PoolManager pre-fills pools and reuses instances
## across more acquire/release cycles than prefill size without unbounded growth.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var pool: Node = root.get_node_or_null("PoolManager")
	var bus: Node = root.get_node_or_null("EventBus")
	assert(pool != null and bus != null, "PoolManager or EventBus missing")

	var world_host := Node2D.new()
	root.add_child(world_host)

	pool.call("prefill_all")
	await process_frame

	var prefill_v: Variant = pool.call("get_total_count", "enemy_bat")
	var prefill_count: int = prefill_v if prefill_v is int else 0
	assert(prefill_count >= 20, "Expected at least 20 prefilled enemy_bat, got %d" % prefill_count)

	# Acquire and kill/release 35 bats (more than prefill=20), one batch at a time
	for _i: int in range(35):
		var bat_v: Variant = pool.call("acquire", "enemy_bat", world_host)
		assert(bat_v is EnemyBase, "Failed to acquire enemy_bat from PoolManager")
		var bat: EnemyBase = bat_v
		bat.take_damage(999)
		await process_frame

	var after_v: Variant = pool.call("get_total_count", "enemy_bat")
	var after_count: int = after_v if after_v is int else 0
	assert(after_count == prefill_count, "Pool grew unexpectedly: prefill=%d after=%d" % [prefill_count, after_count])

	# Also test xp_gem acquire/collect loop (55 > prefill=40)
	var gem_prefill_v: Variant = pool.call("get_total_count", "xp_gem")
	var gem_prefill: int = gem_prefill_v if gem_prefill_v is int else 0
	assert(gem_prefill >= 40, "Expected at least 40 prefilled xp_gem")
	for _i: int in range(55):
		var gem_v: Variant = pool.call("acquire", "xp_gem", world_host)
		assert(gem_v is XpGem, "Failed to acquire xp_gem")
		var gem: XpGem = gem_v
		gem.collect()
		await process_frame
	var gem_after_v: Variant = pool.call("get_total_count", "xp_gem")
	assert(gem_after_v is int and gem_after_v == gem_prefill, "xp_gem pool grew unexpectedly")

	print("TEST POOLING PASSED")
	quit(0)
