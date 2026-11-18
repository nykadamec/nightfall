extends SceneTree
## Headless CI test for T1.5: verifies contact damage, i-frames, and player_died.

var _hurt_count: int = 0
var _died_count: int = 0


func _initialize() -> void:
	var event_bus: Node = root.get_node_or_null("EventBus")
	var run_state: Node = root.get_node_or_null("RunState")
	if event_bus == null or run_state == null:
		push_error("Autoloads missing")
		quit(1)
		return

	run_state.call("reset")
	event_bus.connect("player_hurt", _on_player_hurt)
	event_bus.connect("player_died", _on_player_died)

	var player_scene: PackedScene = load("res://scenes/actors/player.tscn")
	var bat_scene: PackedScene = load("res://scenes/actors/enemy_bat.tscn")
	var player: Player = player_scene.instantiate() as Player
	var bat: EnemyBase = bat_scene.instantiate() as EnemyBase
	player.position = Vector2.ZERO
	bat.position = Vector2.ZERO
	root.add_child(player)
	root.add_child(bat)

	# Wait a couple of physics frames for Area2D overlap detection.
	for _i: int in range(3):
		await physics_frame

	var hp_after_hit: Variant = run_state.get("hp")
	if not (hp_after_hit is int) or hp_after_hit != 90:
		push_error("Expected HP 90 after first contact hit, got: %s" % str(hp_after_hit))
		quit(1)
		return

	if _hurt_count != 1:
		push_error("Expected 1 player_hurt signal (i-frames should block instant repeat), got: %d" % _hurt_count)
		quit(1)
		return

	# Immediate second damage call during i-frames must be ignored.
	player.take_damage(50)
	var hp_during_iframes: Variant = run_state.get("hp")
	if not (hp_during_iframes is int) or hp_during_iframes != 90:
		push_error("I-frames did not block immediate damage")
		quit(1)
		return

	# Wait for i-frames to expire (invuln_duration = 0.6s -> ~40 frames at 60fps),
	# with hp=10 so periodic overlap tick kills the player.
	run_state.set("hp", 10)
	for _i: int in range(45):
		await physics_frame

	var hp_after_death: Variant = run_state.get("hp")
	if not (hp_after_death is int) or hp_after_death != 0:
		push_error("Expected HP 0 after i-frames expired while overlapping, got: %s" % str(hp_after_death))
		quit(1)
		return

	if _died_count != 1:
		push_error("Expected player_died to emit once, got: %d" % _died_count)
		quit(1)
		return

	print("TEST CONTACT DAMAGE PASSED")
	quit(0)


func _on_player_hurt(_current_hp: int, _max_hp: int) -> void:
	_hurt_count += 1


func _on_player_died() -> void:
	_died_count += 1
