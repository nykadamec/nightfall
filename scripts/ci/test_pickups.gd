extends SceneTree
## Headless CI test for T3.8: Chicken heals and clamps to max_hp; Coin increments gold;
## neither crashes when acquired/released via PoolManager.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_state: Node = root.get_node_or_null("RunState")
	var pool: Node = root.get_node_or_null("PoolManager")
	assert(run_state != null and pool != null, "Autoloads missing")
	run_state.call("reset")

	var world_host := Node2D.new()
	root.add_child(world_host)
	pool.call("prefill_all")
	await process_frame

	# Missing HP -> chicken heals +30 and clamps at max_hp
	run_state.set("max_hp", 100)
	run_state.set("hp", 85)
	var chk_v: Variant = pool.call("acquire", "chicken", world_host)
	assert(chk_v is ChickenPickup, "Failed to acquire pooled chicken")
	var chk: ChickenPickup = chk_v
	chk.collect()
	await process_frame
	assert(run_state.get("hp") == 100, "Expected HP clamped at 100, got %s" % str(run_state.get("hp")))

	# Coin increments gold when pooled
	var gold_before_v: Variant = run_state.get("gold")
	var gold_before: int = gold_before_v if gold_before_v is int else 0
	var coin_v: Variant = pool.call("acquire", "coin", world_host)
	assert(coin_v is CoinPickup, "Failed to acquire pooled coin")
	var coin: CoinPickup = coin_v
	coin.collect()
	await process_frame
	assert(run_state.get("gold") == gold_before + 1, "Expected gold +1")

	print("TEST PICKUPS PASSED")
	quit(0)
