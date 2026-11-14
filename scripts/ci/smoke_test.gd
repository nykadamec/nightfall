extends SceneTree
## Headless CI smoke test verifying autoloads and RunState defaults.


func _initialize() -> void:
	var event_bus: Node = root.get_node_or_null("EventBus")
	if event_bus == null:
		push_error("Smoke test failed: EventBus autoload missing.")
		quit(1)
		return

	var run_state: Node = root.get_node_or_null("RunState")
	if run_state == null:
		push_error("Smoke test failed: RunState autoload missing.")
		quit(1)
		return

	if not _check_run_state(run_state):
		quit(1)
		return

	print("SMOKE TEST PASSED")
	quit(0)


func _check_run_state(run_state: Node) -> bool:
	run_state.set("xp", 42)
	run_state.set("level", 5)
	run_state.set("hp", 10)
	run_state.set("gold", 99)
	run_state.set("time_sec", 12.5)
	run_state.call("reset")

	var time_val: Variant = run_state.get("time_sec")
	var xp_val: Variant = run_state.get("xp")
	var level_val: Variant = run_state.get("level")
	var hp_val: Variant = run_state.get("hp")
	var max_hp_val: Variant = run_state.get("max_hp")
	var gold_val: Variant = run_state.get("gold")

	var checks: Array[bool] = [
		time_val is float and time_val == 0.0,
		xp_val is int and xp_val == 0,
		level_val is int and level_val == 1,
		hp_val is int and hp_val == 100,
		max_hp_val is int and max_hp_val == 100,
		gold_val is int and gold_val == 0,
	]
	for ok: bool in checks:
		if not ok:
			push_error("Smoke test failed: RunState.reset() did not restore defaults.")
			return false
	return true
