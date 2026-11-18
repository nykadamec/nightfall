extends SceneTree
## Headless CI test for T1.4: verifies EnemyBat moves closer to a stationary Player.


func _initialize() -> void:
	var player_scene: PackedScene = load("res://scenes/actors/player.tscn")
	var bat_scene: PackedScene = load("res://scenes/actors/enemy_bat.tscn")
	if player_scene == null or bat_scene == null:
		push_error("Failed to load player or enemy_bat scene")
		quit(1)
		return

	var player: Player = player_scene.instantiate() as Player
	player.position = Vector2.ZERO
	root.add_child(player)

	var bat: EnemyBase = bat_scene.instantiate() as EnemyBase
	bat.position = Vector2(200.0, 0.0)
	root.add_child(bat)

	await physics_frame
	var start_dist: float = bat.global_position.distance_to(player.global_position)

	for _i: int in range(20):
		await physics_frame

	var end_dist: float = bat.global_position.distance_to(player.global_position)
	if end_dist >= start_dist:
		push_error("EnemyBat did not move closer: start=%f end=%f" % [start_dist, end_dist])
		quit(1)
		return

	print("TEST ENEMY CHASE PASSED (start=%.2f end=%.2f)" % [start_dist, end_dist])
	quit(0)
