extends SceneTree
## Headless CI test for T2.1: enemy_died spawns XpGem, overlapping Player adds XP and frees gem.

var _collected_count: int = 0


func _initialize() -> void:
	var event_bus: Node = root.get_node_or_null("EventBus")
	var run_state: Node = root.get_node_or_null("RunState")
	if event_bus == null or run_state == null:
		push_error("Autoloads missing")
		quit(1)
		return

	run_state.call("reset")
	event_bus.connect("xp_collected", _on_xp_collected)

	var main_scene: PackedScene = load("res://scenes/world/main.tscn")
	var main: Node = main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var player: Player = main.get_node_or_null("World/Player") as Player
	if player == null:
		push_error("Player not found")
		quit(1)
		return

	# Simulate enemy death at player's position
	event_bus.emit_signal("enemy_died", player.global_position, 7)
	for _i: int in range(4):
		await physics_frame

	var xp_val: Variant = run_state.get("xp")
	if not (xp_val is int) or xp_val != 7:
		push_error("Expected RunState.xp == 7, got: %s" % str(xp_val))
		quit(1)
		return

	if _collected_count != 1:
		push_error("Expected 1 xp_collected signal, got: %d" % _collected_count)
		quit(1)
		return

	if get_nodes_in_group("pickups").size() != 0:
		push_error("XpGem was not freed after collection")
		quit(1)
		return

	print("TEST XP GEM PASSED")
	quit(0)


func _on_xp_collected(_amount: int, _total_xp: int) -> void:
	_collected_count += 1
