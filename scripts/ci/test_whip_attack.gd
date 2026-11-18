extends SceneTree
## Headless CI test for T1.6: verifies WhipWeapon auto-swings on cooldown and hits a hurtbox.


class DummyHurtbox extends Area2D:
	var hits_received: int = 0
	var last_damage: int = 0

	func take_damage(amount: int) -> void:
		hits_received += 1
		last_damage = amount


func _initialize() -> void:
	var player_scene: PackedScene = load("res://scenes/actors/player.tscn")
	var player: Player = player_scene.instantiate() as Player
	player.position = Vector2.ZERO
	root.add_child(player)

	var whip: WhipWeapon = player.get_node_or_null("WhipWeapon") as WhipWeapon
	if whip == null:
		push_error("WhipWeapon child not found on Player")
		quit(1)
		return
	whip.cooldown = 0.1

	var dummy := DummyHurtbox.new()
	dummy.collision_layer = 4
	dummy.collision_mask = 8
	dummy.position = Vector2(60.0, -28.0)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	dummy.add_child(shape)
	root.add_child(dummy)

	for _i: int in range(15):
		await physics_frame

	if dummy.hits_received < 1 or dummy.last_damage != whip.damage:
		push_error("DummyHurtbox did not receive expected whip hit: hits=%d dmg=%d" % [
			dummy.hits_received, dummy.last_damage
		])
		quit(1)
		return

	print("TEST WHIP ATTACK PASSED (hits=%d dmg=%d)" % [dummy.hits_received, dummy.last_damage])
	quit(0)
