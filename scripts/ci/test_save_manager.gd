extends SceneTree
## Headless CI test for T5.1: SaveManager save/load, corrupted fallback,
## and RunState.reset() preserving meta_gold.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var save_mgr: Node = root.get_node_or_null("SaveManager")
	var run_state: Node = root.get_node_or_null("RunState")
	assert(save_mgr != null and run_state != null, "Autoloads missing")

	var test_path: String = "/tmp/nightfall_test_save.cfg"
	save_mgr.call("reset_to_defaults")
	save_mgr.set("meta_gold", 125)
	save_mgr.set("fullscreen", true)
	save_mgr.set("master_volume", 0.65)
	var err: Variant = save_mgr.call("save_data", test_path)
	assert(err == OK, "Failed to save test config")

	save_mgr.call("reset_to_defaults")
	assert(save_mgr.get("meta_gold") == 0, "reset_to_defaults failed")

	var ok: Variant = save_mgr.call("load_data", test_path)
	assert(ok == true, "Failed to load test config")
	assert(save_mgr.get("meta_gold") == 125, "meta_gold mismatch after reload")
	assert(save_mgr.get("fullscreen") == true, "fullscreen mismatch after reload")
	var vol_v: Variant = save_mgr.get("master_volume")
	var vol_f: float = vol_v if vol_v is float else -1.0
	assert(is_equal_approx(vol_f, 0.65), "master_volume mismatch")

	# RunState.reset() must NOT wipe meta_gold
	run_state.call("reset")
	assert(save_mgr.get("meta_gold") == 125, "RunState.reset() must not wipe meta_gold")

	# Corrupted file falls back safely to defaults
	var f: FileAccess = FileAccess.open(test_path, FileAccess.WRITE)
	f.store_string("[unclosed_section\ngold = [broken")
	f.close()
	var bad_ok: Variant = save_mgr.call("load_data", test_path)
	assert(bad_ok == false, "Corrupted config should return false")
	assert(save_mgr.get("meta_gold") == 0, "Corrupted config should fall back to default meta_gold")

	DirAccess.remove_absolute(test_path)
	print("TEST SAVE MANAGER PASSED")
	quit(0)
