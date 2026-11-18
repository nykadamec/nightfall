extends SceneTree
## Headless CI test for T3.2: HolyBoltWeapon and SpiritAuraWeapon can be equipped
## via WeaponController and hit enemies on their own.


class DummyHurtbox extends Area2D:
	var hits_received: int = 0
	var last_damage: int = 0

	func take_damage(amount: int) -> void:
		hits_received += 1
		last_damage = amount


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var bolt_res: Resource = load("res://resources/weapons/holy_bolt.tres")
	var aura_res: Resource = load("res://resources/weapons/spirit_aura.tres")
	assert(bolt_res != null and aura_res != null, "Missing weapon .tres resources")

	var player_scene: PackedScene = load("res://scenes/actors/player.tscn") as PackedScene
	var player: Node2D = player_scene.instantiate() as Node2D
	player.position = Vector2.ZERO
	root.add_child(player)
	await process_frame

	var ctrl: Node = player.get_node_or_null("WeaponController")
	assert(ctrl != null, "WeaponController missing")

	var bolt_v: Variant = ctrl.call("equip_weapon", bolt_res)
	var aura_v: Variant = ctrl.call("equip_weapon", aura_res)
	var bolt_weapon: Node = bolt_v if bolt_v is Node else null
	var aura_weapon: Node = aura_v if aura_v is Node else null
	assert(bolt_weapon != null and aura_weapon != null, "Failed to equip new weapons")
	bolt_weapon.set("cooldown", 0.08)
	aura_weapon.set("cooldown", 0.08)

	# Target 1 for Holy Bolt (in enemies group so bolt aims at it)
	var bolt_target := DummyHurtbox.new()
	bolt_target.add_to_group("enemies")
	bolt_target.collision_layer = 4
	bolt_target.collision_mask = 8
	bolt_target.position = Vector2(120.0, -24.0)
	var bolt_shape := CollisionShape2D.new()
	var bolt_circle := CircleShape2D.new()
	bolt_circle.radius = 20.0
	bolt_shape.shape = bolt_circle
	bolt_target.add_child(bolt_shape)
	root.add_child(bolt_target)

	# Target 2 inside Spirit Aura radius
	var aura_target := DummyHurtbox.new()
	aura_target.collision_layer = 4
	aura_target.collision_mask = 8
	aura_target.position = Vector2(-40.0, 0.0)
	var aura_shape := CollisionShape2D.new()
	var aura_circle := CircleShape2D.new()
	aura_circle.radius = 16.0
	aura_shape.shape = aura_circle
	aura_target.add_child(aura_shape)
	root.add_child(aura_target)

	for _i: int in range(30):
		await physics_frame

	assert(bolt_target.hits_received >= 1, "HolyBolt did not hit target")
	assert(aura_target.hits_received >= 1, "SpiritAura did not hit target")

	print("TEST ADDITIONAL WEAPONS PASSED (bolt_hits=%d aura_hits=%d)" % [
		bolt_target.hits_received, aura_target.hits_received
	])
	quit(0)
