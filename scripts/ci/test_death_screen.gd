extends SceneTree
## Headless CI test for T2.7: Death screen opens and pauses on player_died,
## and Retry resets RunState and reloads the scene cleanly.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_state: Node = root.get_node_or_null("RunState")
	var bus: Node = root.get_node_or_null("EventBus")
	assert(run_state != null and bus != null, "Autoloads missing")
	run_state.call("reset")

	var err: Error = change_scene_to_file("res://scenes/world/main.tscn")
	assert(err == OK, "Failed to change_scene_to_file main.tscn")
	await process_frame
	await process_frame

	var death_ui: Control = current_scene.get_node_or_null("UILayer/DeathScreen") as Control
	assert(death_ui != null, "DeathScreen missing in UILayer")
	assert(not death_ui.visible, "DeathScreen should start hidden")
	assert(not paused, "Tree should start unpaused")

	# Simulate some progress then player death
	run_state.set("time_sec", 42.0)
	run_state.set("gold", 33)
	run_state.call("add_xp", 10) # level -> 2
	# Dismiss level-up if it opened
	var lvl_ui: Control = current_scene.get_node_or_null("UILayer/LevelUpScreen") as Control
	if lvl_ui != null and lvl_ui.visible:
		lvl_ui.call("skip")
		await process_frame

	bus.emit_signal("player_died")
	await process_frame

	assert(paused, "Tree should pause on player_died")
	assert(death_ui.visible, "DeathScreen should become visible on player_died")
	var summary_lbl: Label = death_ui.get_node_or_null("CenterContainer/Panel/Margin/VBox/SummaryLabel") as Label
	assert(summary_lbl != null, "SummaryLabel missing")
	assert(summary_lbl.text.contains("00:42"), "Summary missing survived time")
	assert(summary_lbl.text.contains("Level 2"), "Summary missing level")
	assert(summary_lbl.text.contains("33"), "Summary missing gold earned")
	assert(summary_lbl.text.contains("death"), "Summary missing death cause")

	# Retry should unpause, reset RunState, and reload main.tscn
	death_ui.call("retry")
	await process_frame
	await process_frame

	assert(not paused, "Tree should unpause after retry")
	assert(current_scene != null, "current_scene should exist after reload")
	var death_after: Control = current_scene.get_node_or_null("UILayer/DeathScreen") as Control
	assert(death_after != null and not death_after.visible, "DeathScreen should be hidden after reload")
	assert(run_state.get("level") == 1, "RunState.level should reset to 1")
	assert(run_state.get("xp") == 0, "RunState.xp should reset to 0")
	assert(run_state.get("hp") == run_state.get("max_hp"), "RunState.hp should reset to max_hp")

	# Victory summary + Menu button
	run_state.set("time_sec", 125.0)
	run_state.set("gold", 99)
	bus.emit_signal("boss_died")
	await process_frame
	assert(paused, "Tree should pause on boss_died")
	assert(death_after.visible, "DeathScreen should become visible on boss_died")
	var summary_vic: Label = death_after.get_node_or_null("CenterContainer/Panel/Margin/VBox/SummaryLabel") as Label
	assert(summary_vic != null and summary_vic.text.contains("victory"), "Victory summary missing cause")
	assert(summary_vic.text.contains("02:05"), "Victory summary missing time")
	assert(summary_vic.text.contains("99"), "Victory summary missing gold")

	death_after.call("go_to_menu")
	await process_frame
	await process_frame
	assert(not paused, "Tree should unpause after Menu button")
	assert(current_scene is MainMenu, "Expected MainMenu after Menu button")

	print("TEST DEATH SCREEN PASSED")
	quit(0)
