extends SceneTree
## Headless CI test for T1.7: verifies enemy HP, death, queue_free, and enemy_died signal.

var _died_count: int = 0
var _last_xp: int = 0


func _initialize() -> void:
	var event_bus: Node = root.get_node_or_null("EventBus")
	if event_bus == null:
		push_error("EventBus autoload missing")
		quit(1)
		return
	event_bus.connect("enemy_died", _on_enemy_died)

	var bat_scene: PackedScene = load("res://scenes/actors/enemy_bat.tscn")
	var bat: EnemyBase = bat_scene.instantiate() as EnemyBase
	bat.position = Vector2(50.0, 0.0)
	root.add_child(bat)
	await physics_frame

	bat.take_damage(10)
	# Second hit after death must not emit enemy_died again.
	bat.take_damage(10)

	if not bat.is_dead:
		push_error("EnemyBat.is_dead should be true after taking lethal damage")
		quit(1)
		return

	if not bat.is_queued_for_deletion():
		push_error("EnemyBat should be queued for deletion on death")
		quit(1)
		return

	if _died_count != 1 or _last_xp != bat.xp_value:
		push_error("Expected 1 enemy_died with xp=%d, got count=%d xp=%d" % [
			bat.xp_value, _died_count, _last_xp
		])
		quit(1)
		return

	await process_frame
	if is_instance_valid(bat):
		push_error("EnemyBat was not freed after process_frame")
		quit(1)
		return

	# Live whip kill check: Player's WhipWeapon kills a second EnemyBat in range.
	var player_scene: PackedScene = load("res://scenes/actors/player.tscn")
	var player: Player = player_scene.instantiate() as Player
	player.position = Vector2.ZERO
	root.add_child(player)
	var whip: WhipWeapon = player.get_node_or_null("WhipWeapon") as WhipWeapon
	whip.cooldown = 0.1

	var bat2: EnemyBase = bat_scene.instantiate() as EnemyBase
	bat2.position = Vector2(65.0, 0.0)
	root.add_child(bat2)

	for _i: int in range(15):
		await physics_frame

	if _died_count != 2 or is_instance_valid(bat2):
		push_error("Whip did not kill EnemyBat in live check: died_count=%d valid=%s" % [
			_died_count, str(is_instance_valid(bat2))
		])
		quit(1)
		return

	print("TEST ENEMY DEATH PASSED")
	quit(0)


func _on_enemy_died(_pos: Vector2, xp_value: int) -> void:
	_died_count += 1
	_last_xp = xp_value
