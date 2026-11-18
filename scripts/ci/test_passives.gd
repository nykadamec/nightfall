extends SceneTree
## Headless CI test for T3.3: PassiveData resources apply expected stat changes.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_state: Node = root.get_node_or_null("RunState")
	assert(run_state != null, "RunState missing")
	run_state.call("reset")

	var player_scene: PackedScene = load("res://scenes/actors/player.tscn") as PackedScene
	var player: Node = player_scene.instantiate()
	root.add_child(player)
	await process_frame

	var ctrl: Node = player.get_node_or_null("WeaponController")
	assert(ctrl != null, "WeaponController missing")

	var hp_p: Resource = load("res://resources/upgrades/max_hp.tres")
	var spd_p: Resource = load("res://resources/upgrades/move_speed.tres")
	var cd_p: Resource = load("res://resources/upgrades/cooldown_reduction.tres")
	var dmg_p: Resource = load("res://resources/upgrades/damage.tres")

	var max_hp_before: Variant = run_state.get("max_hp")
	var spd_before: Variant = player.get("move_speed")
	var cd_before: Variant = ctrl.get("cooldown_multiplier")
	var dmg_before: Variant = ctrl.get("damage_multiplier")

	assert(run_state.call("apply_passive", hp_p, player) == true, "Failed max_hp passive")
	assert(run_state.call("apply_passive", spd_p, player) == true, "Failed move_speed passive")
	assert(run_state.call("apply_passive", cd_p, player) == true, "Failed cooldown passive")
	assert(run_state.call("apply_passive", dmg_p, player) == true, "Failed damage passive")

	assert(run_state.get("max_hp") > max_hp_before, "Max HP did not increase")
	assert(player.get("move_speed") > spd_before, "Move speed did not increase")
	assert(ctrl.get("cooldown_multiplier") < cd_before, "Cooldown multiplier did not decrease")
	assert(ctrl.get("damage_multiplier") > dmg_before, "Damage multiplier did not increase")

	print("TEST PASSIVES PASSED")
	quit(0)
