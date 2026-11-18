extends SceneTree


func _init() -> void:
	await process_frame

	var audio: Node = root.get_node_or_null("AudioManager")
	var bus: Node = root.get_node_or_null("EventBus")
	if audio == null or bus == null:
		push_error("AudioManager or EventBus autoload missing")
		quit(1)
		return

	var keys: Array[String] = ["hit", "death", "gem", "level_up", "click", "hurt", "boss"]
	for k: String in keys:
		var has_v: Variant = audio.call("has_sfx", k)
		if not (has_v is bool and has_v == true):
			push_error("Missing SFX key: %s" % k)
			quit(1)
			return
		audio.call("play_sfx", k)

	bus.emit_signal("xp_collected", 5, 5)
	bus.emit_signal("level_up", 2)
	await process_frame

	audio.call("play_music", "menu")
	var cur_menu: Variant = audio.call("get_current_music")
	if not (cur_menu is String and str(cur_menu) == "menu"):
		push_error("Expected current music 'menu', got %s" % str(cur_menu))
		quit(1)
		return

	bus.emit_signal("run_started")
	var cur_run: Variant = audio.call("get_current_music")
	if not (cur_run is String and str(cur_run) == "run"):
		push_error("Expected current music 'run' after run_started, got %s" % str(cur_run))
		quit(1)
		return

	audio.call("stop_music")
	var cur_stop: Variant = audio.call("get_current_music")
	if not (cur_stop is String and str(cur_stop) == ""):
		push_error("Expected empty current music after stop_music")
		quit(1)
		return

	print("TEST AUDIO PASSED")
	quit(0)
