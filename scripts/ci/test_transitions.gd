extends SceneTree


func _fail(msg: String) -> void:
	push_error(msg)
	quit(1)


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_state: Node = root.get_node_or_null("RunState")
	var bus: Node = root.get_node_or_null("EventBus")
	var audio: Node = root.get_node_or_null("AudioManager")
	if run_state == null or bus == null or audio == null:
		_fail("Required autoloads missing")
		return

	# 1. Boot MainMenu
	var err: Error = change_scene_to_file("res://ui/main_menu/main_menu.tscn")
	if err != OK:
		_fail("Failed to load main_menu.tscn")
		return
	await process_frame
	await process_frame
	if paused:
		_fail("MainMenu should not start paused")
		return
	if not (current_scene is MainMenu):
		_fail("Expected MainMenu")
		return

	# 2. Play -> Main arena
	current_scene.call("play")
	await process_frame
	await process_frame
	if current_scene == null or current_scene.name != "Main":
		_fail("Expected Main scene after play()")
		return
	if paused:
		_fail("Main should start unpaused")
		return

	# 3. Level-up -> pause -> skip -> unpause
	run_state.call("add_xp", 10)
	await process_frame
	if not paused:
		_fail("Tree should pause on level_up")
		return
	var lvl_ui: Control = current_scene.get_node_or_null("UILayer/LevelUpScreen") as Control
	if lvl_ui == null or not lvl_ui.visible:
		_fail("LevelUpScreen should be visible")
		return
	lvl_ui.call("skip")
	await process_frame
	if paused or lvl_ui.visible:
		_fail("Tree should unpause and LevelUpScreen hide after skip")
		return

	# 4. Boss bar visibility -> Death -> Retry resets BossBox and unpauses
	var boss_box: Control = current_scene.get_node_or_null("UILayer/Hud/BossBox") as Control
	if boss_box == null or boss_box.visible:
		_fail("BossBox should start hidden")
		return
	bus.emit_signal("boss_spawned", "Vampire Lord", 500)
	await process_frame
	if not boss_box.visible:
		_fail("BossBox should become visible on boss_spawned")
		return

	bus.emit_signal("player_died")
	await process_frame
	var death_ui: Control = current_scene.get_node_or_null("UILayer/DeathScreen") as Control
	if death_ui == null or not death_ui.visible or not paused:
		_fail("DeathScreen should pause and show on player_died")
		return

	death_ui.call("retry")
	await process_frame
	await process_frame
	if paused:
		_fail("Tree should be unpaused after retry")
		return
	var boss_after: Control = current_scene.get_node_or_null("UILayer/Hud/BossBox") as Control
	if boss_after == null or boss_after.visible:
		_fail("BossBox should be hidden after retry")
		return

	# 5. Die again -> Menu -> MainMenu unpaused with menu music
	bus.emit_signal("player_died")
	await process_frame
	var death_after: Control = current_scene.get_node_or_null("UILayer/DeathScreen") as Control
	if death_after == null or not death_after.visible:
		_fail("DeathScreen should show on second death")
		return
	death_after.call("go_to_menu")
	await process_frame
	await process_frame
	if paused:
		_fail("Tree should not be paused at MainMenu")
		return
	if not (current_scene is MainMenu):
		_fail("Expected MainMenu after go_to_menu()")
		return
	if str(audio.call("get_current_music")) != "menu":
		_fail("Expected menu music back on MainMenu")
		return

	print("TEST TRANSITIONS PASSED")
	quit(0)
