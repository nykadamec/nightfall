extends SceneTree
## Headless CI test for T1.1: verifies Player movement via apply_move_for_test.


func _initialize() -> void:
	var player_scene: PackedScene = load("res://scenes/actors/player.tscn")
	if player_scene == null:
		push_error("Failed to load player.tscn")
		quit(1)
		return

	var player: Player = player_scene.instantiate() as Player
	if player == null:
		push_error("Instantiated player is not Player")
		quit(1)
		return

	root.add_child(player)
	await physics_frame

	if not player.is_in_group("player"):
		push_error("Player is not in group 'player'")
		quit(1)
		return

	var start_pos: Vector2 = player.global_position
	player.apply_move_for_test(Vector2.RIGHT, 0.1)
	if player.global_position.x <= start_pos.x:
		push_error("Player did not move right: start=%s end=%s" % [start_pos, player.global_position])
		quit(1)
		return

	var mid_pos: Vector2 = player.global_position
	player.apply_move_for_test(Vector2.UP, 0.1)
	if player.global_position.y >= mid_pos.y:
		push_error("Player did not move up: mid=%s end=%s" % [mid_pos, player.global_position])
		quit(1)
		return

	print("TEST PLAYER MOVE PASSED")
	quit(0)
