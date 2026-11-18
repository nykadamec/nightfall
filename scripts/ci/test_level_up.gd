extends SceneTree
## Headless CI test for T2.3: level-up screen pauses tree, offers 3 distinct upgrades,
## applies chosen upgrade to real stats, and unpauses.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_state: Node = root.get_node_or_null("RunState")
	assert(run_state != null, "RunState missing")
	run_state.call("reset")

	var main_packed: PackedScene = load("res://scenes/world/main.tscn") as PackedScene
	var main: Node = main_packed.instantiate()
	root.add_child(main)
	await process_frame

	var player: Node = get_first_node_in_group("player")
	var whip: Node = player.get_node_or_null("WhipWeapon")
	var lvl_ui: Control = main.get_node_or_null("UILayer/LevelUpScreen") as Control
	assert(player != null and whip != null, "Player or WhipWeapon missing")
	assert(lvl_ui != null, "LevelUpScreen missing in UILayer")
	assert(not lvl_ui.visible, "LevelUpScreen should start hidden")
	assert(not paused, "Tree should start unpaused")

	var dmg_before_v: Variant = whip.get("damage")
	var spd_before_v: Variant = player.get("move_speed")
	var max_hp_before_v: Variant = run_state.get("max_hp")
	var cd_before_v: Variant = whip.get("cooldown")

	# Trigger level up via RunState.add_xp(10)
	run_state.call("add_xp", 10)
	await process_frame

	assert(paused, "Tree should pause on level_up")
	assert(lvl_ui.visible, "LevelUpScreen should become visible on level_up")

	var choices_v: Variant = lvl_ui.call("get_current_choice_ids")
	var choices: Array = choices_v if choices_v is Array else []
	assert(choices.size() == 3, "Expected 3 upgrade choices, got %d" % choices.size())
	assert(choices[0] != choices[1] and choices[1] != choices[2] and choices[0] != choices[2],
		"Expected 3 distinct upgrade choices, got %s" % str(choices))

	# Choose card 0
	var chosen_id: String = str(choices[0])
	lvl_ui.call("choose_card", 0)
	await process_frame

	assert(not paused, "Tree should unpause after choosing upgrade")
	assert(not lvl_ui.visible, "LevelUpScreen should hide after choosing upgrade")

	match chosen_id:
		"whip_damage":
			var dmg_after: Variant = whip.get("damage")
			assert(dmg_after is int and dmg_before_v is int and dmg_after > dmg_before_v, "Whip damage did not increase")
		"move_speed":
			var spd_after: Variant = player.get("move_speed")
			assert(spd_after is float and spd_before_v is float and spd_after > spd_before_v, "Move speed did not increase")
		"max_hp":
			var max_hp_after: Variant = run_state.get("max_hp")
			assert(max_hp_after is int and max_hp_before_v is int and max_hp_after > max_hp_before_v, "Max HP did not increase")
		"whip_speed":
			var cd_after: Variant = whip.get("cooldown")
			assert(cd_after is float and cd_before_v is float and cd_after < cd_before_v, "Whip cooldown did not decrease")

	# T2.4: test reroll and skip
	run_state.call("add_xp", 20)
	await process_frame
	assert(paused and lvl_ui.visible, "Should open for level 3")

	var reroll_btn: Button = lvl_ui.get_node_or_null("CenterContainer/Panel/Margin/VBox/ActionsRow/RerollButton") as Button
	assert(reroll_btn != null, "RerollButton missing")
	assert(not reroll_btn.disabled, "RerollButton should start enabled")

	# Use all 3 rerolls
	lvl_ui.call("reroll")
	lvl_ui.call("reroll")
	lvl_ui.call("reroll")
	var left_v: Variant = run_state.get("rerolls_left")
	assert(left_v is int and left_v == 0, "Expected 0 rerolls_left, got %s" % str(left_v))
	assert(reroll_btn.disabled, "RerollButton should disable when rerolls_left == 0")

	# Extra reroll at 0 should be a no-op
	lvl_ui.call("reroll")
	assert(run_state.get("rerolls_left") == 0, "rerolls_left must stay 0")

	# Skip should grant nothing and unpause
	var dmg_pre_skip: Variant = whip.get("damage")
	var spd_pre_skip: Variant = player.get("move_speed")
	var hp_pre_skip: Variant = run_state.get("max_hp")
	var cd_pre_skip: Variant = whip.get("cooldown")
	lvl_ui.call("skip")
	await process_frame

	assert(not paused, "Tree should unpause after skip")
	assert(not lvl_ui.visible, "LevelUpScreen should hide after skip")
	assert(whip.get("damage") == dmg_pre_skip, "Skip must not change whip damage")
	assert(player.get("move_speed") == spd_pre_skip, "Skip must not change move speed")
	assert(run_state.get("max_hp") == hp_pre_skip, "Skip must not change max HP")
	assert(whip.get("cooldown") == cd_pre_skip, "Skip must not change whip cooldown")

	print("TEST LEVEL UP PASSED")
	quit(0)
