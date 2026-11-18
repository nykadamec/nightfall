extends SceneTree


func _init() -> void:
	await process_frame

	var save_mgr: Node = root.get_node_or_null("SaveManager")
	if save_mgr == null:
		push_error("SaveManager autoload missing")
		quit(1)
		return

	var orig_path_v: Variant = save_mgr.get("save_path")
	var orig_path: String = orig_path_v if orig_path_v is String else "user://save_data.cfg"
	var test_path: String = "/tmp/nightfall_test_options.cfg"
	if FileAccess.file_exists(test_path):
		DirAccess.remove_absolute(test_path)
	save_mgr.set("save_path", test_path)
	save_mgr.set("fullscreen", false)
	save_mgr.set("master_volume", 1.0)

	var packed: PackedScene = load("res://ui/main_menu/main_menu.tscn") as PackedScene
	if packed == null:
		push_error("Could not load main_menu.tscn")
		quit(1)
		return

	var menu: Control = packed.instantiate() as Control
	root.add_child(menu)
	await process_frame

	var opt_btn: Button = menu.get_node_or_null("CenterContainer/Panel/Margin/VBox/OptionsButton") as Button
	if opt_btn == null or opt_btn.disabled:
		push_error("OptionsButton missing or still disabled")
		quit(1)
		return

	var opt_menu: Control = menu.get_node_or_null("OptionsMenu") as Control
	if opt_menu == null:
		push_error("OptionsMenu node missing on MainMenu")
		quit(1)
		return
	if opt_menu.visible:
		push_error("OptionsMenu should start hidden")
		quit(1)
		return

	menu.call("open_options")
	await process_frame
	if not opt_menu.visible:
		push_error("OptionsMenu did not open")
		quit(1)
		return

	opt_menu.call("set_master_volume", 1.8)
	var vol_high_v: Variant = save_mgr.get("master_volume")
	var vol_high: float = vol_high_v if vol_high_v is float else -1.0
	if not is_equal_approx(vol_high, 1.0):
		push_error("Expected volume clamped to 1.0, got %s" % str(vol_high))
		quit(1)
		return

	opt_menu.call("set_master_volume", -0.5)
	var vol_low_v: Variant = save_mgr.get("master_volume")
	var vol_low: float = vol_low_v if vol_low_v is float else -1.0
	if not is_equal_approx(vol_low, 0.0):
		push_error("Expected volume clamped to 0.0, got %s" % str(vol_low))
		quit(1)
		return

	opt_menu.call("set_master_volume", 0.45)
	opt_menu.call("set_fullscreen", true)
	await process_frame

	# Reload from disk into clean state
	save_mgr.set("fullscreen", false)
	save_mgr.set("master_volume", 1.0)
	var loaded_ok: Variant = save_mgr.call("load_data", test_path)
	if not (loaded_ok is bool and loaded_ok == true):
		push_error("SaveManager.load_data failed for options test")
		quit(1)
		return

	var reloaded_fs_v: Variant = save_mgr.get("fullscreen")
	var reloaded_fs: bool = reloaded_fs_v if reloaded_fs_v is bool else false
	var reloaded_vol_v: Variant = save_mgr.get("master_volume")
	var reloaded_vol: float = reloaded_vol_v if reloaded_vol_v is float else -1.0
	if not reloaded_fs:
		push_error("Expected persisted fullscreen=true")
		quit(1)
		return
	if not is_equal_approx(reloaded_vol, 0.45):
		push_error("Expected persisted master_volume=0.45, got %s" % str(reloaded_vol))
		quit(1)
		return

	opt_menu.call("close_menu")
	await process_frame
	if opt_menu.visible:
		push_error("OptionsMenu did not close")
		quit(1)
		return

	# Clean up
	save_mgr.set("fullscreen", false)
	save_mgr.set("master_volume", 1.0)
	save_mgr.call("apply_settings")
	save_mgr.set("save_path", orig_path)
	if FileAccess.file_exists(test_path):
		DirAccess.remove_absolute(test_path)

	print("TEST OPTIONS PASSED")
	quit(0)
