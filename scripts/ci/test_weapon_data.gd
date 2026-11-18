extends SceneTree
## Headless CI test for T3.1: WeaponData resource (whip.tres) and WeaponController.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var whip_res: Resource = load("res://resources/weapons/whip.tres")
	assert(whip_res != null, "Failed to load whip.tres")
	assert(whip_res.get("id") == "whip", "Expected whip id")
	assert(str(whip_res.get("display_name")).length() > 0, "Expected display_name")
	var dmg_v: Variant = whip_res.get("damage")
	var cd_v: Variant = whip_res.get("cooldown")
	var max_v: Variant = whip_res.get("max_level")
	assert(dmg_v is int and dmg_v > 0, "Expected positive damage")
	assert(cd_v is float and cd_v > 0.0, "Expected positive cooldown")
	assert(max_v is int and max_v >= 1, "Expected max_level >= 1")

	var main_packed: PackedScene = load("res://scenes/world/main.tscn") as PackedScene
	var main: Node = main_packed.instantiate()
	root.add_child(main)
	await process_frame

	var player: Node = get_first_node_in_group("player")
	var ctrl: Node = player.get_node_or_null("WeaponController")
	assert(ctrl != null, "WeaponController missing on Player")
	assert(ctrl.call("has_weapon", "whip") == true, "WeaponController should register WhipWeapon")
	assert(ctrl.call("get_weapon_level", "whip") == 1, "Whip should start at level 1")

	var whip: Node = player.get_node_or_null("WhipWeapon")
	assert(whip.get("damage") == dmg_v, "WhipWeapon damage should match whip.tres")
	ctrl.call("upgrade_weapon", "whip")
	assert(ctrl.call("get_weapon_level", "whip") == 2, "Whip should be level 2 after upgrade")
	var upgraded_dmg: Variant = whip.get("damage")
	assert(upgraded_dmg is int and dmg_v is int and upgraded_dmg > dmg_v, "Whip damage should increase on upgrade")

	print("TEST WEAPON DATA PASSED")
	quit(0)
