extends SceneTree
## Headless CI test for T2.2: XP curve, surplus carryover, and EventBus.level_up.

var _levels_emitted: Array[int] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	var run_state: Node = root.get_node_or_null("RunState")
	var event_bus: Node = root.get_node_or_null("EventBus")
	assert(run_state != null, "RunState autoload missing")
	assert(event_bus != null, "EventBus autoload missing")

	run_state.call("reset")
	event_bus.connect("level_up", _on_level_up)

	var need_1_val: Variant = run_state.call("xp_needed_for", 1)
	var need_1: int = need_1_val if need_1_val is int else 0
	var need_2_val: Variant = run_state.call("xp_needed_for", 2)
	var need_2: int = need_2_val if need_2_val is int else 0
	assert(need_1 == 10, "Expected level 1 XP threshold == 10, got %d" % need_1)
	assert(need_2 == 20, "Expected level 2 XP threshold == 20, got %d" % need_2)

	# Partial XP should not level up
	run_state.call("add_xp", 6)
	var lvl_val: Variant = run_state.get("level")
	var xp_val: Variant = run_state.get("xp")
	assert(lvl_val is int and lvl_val == 1, "Expected level 1 after 6 XP")
	assert(xp_val is int and xp_val == 6, "Expected 6 XP stored")
	assert(_levels_emitted.is_empty(), "Did not expect level_up yet")

	# Exact threshold + surplus carryover across multiple levels: 6 + 29 = 35 -> 10 + 20 = 30 used, 5 left, level 3
	run_state.call("add_xp", 29)
	lvl_val = run_state.get("level")
	xp_val = run_state.get("xp")
	assert(lvl_val is int and lvl_val == 3, "Expected level 3 after 35 total XP, got %s" % str(lvl_val))
	assert(xp_val is int and xp_val == 5, "Expected 5 surplus XP, got %s" % str(xp_val))
	assert(_levels_emitted == [2, 3], "Expected level_up [2, 3], got %s" % str(_levels_emitted))

	print("TEST XP CURVE PASSED")
	quit(0)


func _on_level_up(new_level: int) -> void:
	_levels_emitted.append(new_level)
