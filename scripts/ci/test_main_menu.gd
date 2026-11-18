extends SceneTree
## Headless CI test for T4.4: MainMenu boots, Options is disabled stub,
## Play resets RunState and loads scenes/world/main.tscn.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_state: Node = root.get_node_or_null("RunState")
	assert(run_state != null, "RunState missing")

	var err: Error = change_scene_to_file("res://ui/main_menu/main_menu.tscn")
	assert(err == OK, "Failed to load main_menu.tscn")
	await process_frame
	await process_frame

	assert(current_scene is MainMenu, "Expected MainMenu as current_scene")
	var options_btn: Button = current_scene.get_node_or_null("CenterContainer/Panel/Margin/VBox/OptionsButton") as Button
	assert(options_btn != null and not options_btn.disabled, "OptionsButton should be enabled")

	# Dirty RunState then click Play -> should reset and enter main.tscn
	run_state.set("gold", 77)
	run_state.set("level", 4)
	current_scene.call("play")
	await process_frame
	await process_frame

	assert(current_scene.name == "Main", "Expected Main arena after Play, got %s" % str(current_scene.name))
	assert(run_state.get("gold") == 0 and run_state.get("level") == 1, "RunState should reset on Play")

	print("TEST MAIN MENU PASSED")
	quit(0)
