extends SceneTree
## Headless CI test for T1.3: verifies Player cannot pass through arena wall/prop colliders.


func _initialize() -> void:
	var main_scene: PackedScene = load("res://scenes/world/main.tscn")
	if main_scene == null:
		push_error("Failed to load main.tscn")
		quit(1)
		return

	var main: Node = main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var player: Player = main.get_node_or_null("World/Player") as Player
	if player == null:
		push_error("Player not found at World/Player")
		quit(1)
		return

	var prop: StaticBody2D = main.get_node_or_null("World/PropBlock1") as StaticBody2D
	if prop == null:
		push_error("PropBlock1 not found at World/PropBlock1")
		quit(1)
		return

	# Place player just left of PropBlock1 and push right into it.
	player.global_position = prop.global_position + Vector2(-48.0, 0.0)
	for _i: int in range(30):
		player.apply_move_for_test(Vector2.RIGHT, 1.0 / 60.0)
		await physics_frame

	# PropBlock1 half-width=28 + player radius=14 => player stops ~42px left.
	if player.global_position.x >= prop.global_position.x - 20.0:
		push_error("Player walked through PropBlock1: player_x=%f prop_x=%f" % [
			player.global_position.x, prop.global_position.x
		])
		quit(1)
		return

	print("TEST ARENA COLLISION PASSED")
	quit(0)
