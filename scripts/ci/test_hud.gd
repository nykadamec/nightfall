extends SceneTree
## Headless CI test for T2.6: Run timer advances only while unpaused, and HUD updates HP/XP/Level/Timer.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_state: Node = root.get_node_or_null("RunState")
	var bus: Node = root.get_node_or_null("EventBus")
	assert(run_state != null and bus != null, "Autoloads missing")
	run_state.call("reset")

	var main_packed: PackedScene = load("res://scenes/world/main.tscn") as PackedScene
	var main: Node = main_packed.instantiate()
	root.add_child(main)
	await process_frame

	var hud: Control = main.get_node_or_null("UILayer/Hud") as Control
	var hp_label: Label = main.get_node_or_null("UILayer/Hud/TopBar/HpBox/HpLabel") as Label
	var lvl_label: Label = main.get_node_or_null("UILayer/Hud/TopBar/XpBox/LevelLabel") as Label
	var timer_label: Label = main.get_node_or_null("UILayer/Hud/TopBar/TimerLabel") as Label
	assert(hud != null and hp_label != null and lvl_label != null and timer_label != null, "HUD nodes missing")

	# Advance unpaused frames -> time_sec increases
	for _i: int in range(6):
		await process_frame
	var t_unpaused_v: Variant = run_state.get("time_sec")
	var t_unpaused: float = t_unpaused_v if t_unpaused_v is float else 0.0
	assert(t_unpaused > 0.0, "Expected RunState.time_sec > 0 while unpaused")

	# Pause tree -> time_sec freezes
	paused = true
	for _i: int in range(6):
		await process_frame
	var t_paused_v: Variant = run_state.get("time_sec")
	var t_paused: float = t_paused_v if t_paused_v is float else -1.0
	assert(is_equal_approx(t_paused, t_unpaused), "Expected RunState.time_sec to freeze while paused")
	paused = false

	# Check HUD updates on signals and timer formatting
	run_state.set("time_sec", 65.0)
	await process_frame
	assert(timer_label.text == "01:05", "Expected timer text 01:05, got %s" % timer_label.text)

	bus.emit_signal("player_hurt", 70, 120)
	assert(hp_label.text == "HP 70 / 120", "Expected HP 70 / 120, got %s" % hp_label.text)

	run_state.call("add_xp", 10)
	assert(lvl_label.text == "LV 2", "Expected LV 2, got %s" % lvl_label.text)

	# T4.6: check boss bar visibility on boss_spawned / boss_died and gold chip
	var boss_box: Control = main.get_node_or_null("UILayer/Hud/BossBox") as Control
	var gold_label: Label = main.get_node_or_null("UILayer/Hud/TopBar/GoldChip/GoldLabel") as Label
	assert(boss_box != null and not boss_box.visible, "BossBox should start hidden")
	bus.emit_signal("boss_spawned", "Vampire Lord", 600)
	assert(boss_box.visible, "BossBox should show on boss_spawned")
	bus.emit_signal("boss_died")
	assert(not boss_box.visible, "BossBox should hide on boss_died")
	bus.emit_signal("gold_collected", 5, 5)
	assert(gold_label != null and gold_label.text == "5", "GoldLabel should update to 5")

	print("TEST HUD PASSED")
	quit(0)
