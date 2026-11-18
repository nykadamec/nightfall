extends SceneTree
## Headless CI test for T5.2: Meta unlocks purchase, persist across reload,
## cannot buy twice, and fail when gold is insufficient.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_mgr: Node = root.get_node_or_null("SaveManager")
	assert(save_mgr != null, "SaveManager missing")

	var test_path: String = "/tmp/nightfall_test_unlocks.cfg"
	save_mgr.set("save_path", test_path)
	save_mgr.call("reset_to_defaults")
	save_mgr.set("meta_gold", 30)

	# Insufficient gold for 40-gold unlock
	assert(save_mgr.call("try_purchase_unlock", "spirit_aura", 40) == false, "Should not buy with insufficient gold")
	assert(save_mgr.get("meta_gold") == 30, "Gold should be unchanged on failed purchase")

	# Purchase holy_bolt for 25 gold -> 5 gold left
	assert(save_mgr.call("try_purchase_unlock", "holy_bolt", 25) == true, "Should purchase holy_bolt")
	assert(save_mgr.get("meta_gold") == 5, "Expected 5 gold left")
	assert(save_mgr.call("is_unlocked", "holy_bolt") == true, "holy_bolt should be unlocked")

	# Cannot buy twice
	assert(save_mgr.call("try_purchase_unlock", "holy_bolt", 0) == false, "Cannot buy holy_bolt twice")

	# Reload from disk -> still owned and gold is 5
	save_mgr.call("reset_to_defaults")
	assert(save_mgr.call("is_unlocked", "holy_bolt") == false, "reset_to_defaults should clear in-memory")
	assert(save_mgr.call("load_data", test_path) == true, "load_data should succeed")
	assert(save_mgr.call("is_unlocked", "holy_bolt") == true, "holy_bolt unlock must persist")
	assert(save_mgr.get("meta_gold") == 5, "Persisted gold should be 5")

	DirAccess.remove_absolute(test_path)
	print("TEST UNLOCKS PASSED")
	quit(0)
