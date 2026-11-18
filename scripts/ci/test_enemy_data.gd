extends SceneTree
## Headless CI test for T3.4: Changing HP in EnemyData changes hits required to kill enemy.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var bat_res: Resource = load("res://resources/enemies/bat.tres")
	assert(bat_res != null, "Failed to load bat.tres")
	var tough_res: Resource = bat_res.duplicate()
	tough_res.set("max_hp", 25)

	var scn_v: Variant = bat_res.get("enemy_scene")
	var bat_scene: PackedScene = scn_v if scn_v is PackedScene else null
	assert(bat_scene != null, "bat.tres missing enemy_scene")

	var enemy: EnemyBase = bat_scene.instantiate() as EnemyBase
	enemy.set("data", tough_res)
	root.add_child(enemy)
	await process_frame

	assert(enemy.max_hp == 25 and enemy.hp == 25, "Expected HP 25 from test EnemyData, got %d" % enemy.hp)

	# 2 whip hits (10 dmg each) should leave enemy alive at 5 HP
	enemy.take_damage(10)
	enemy.take_damage(10)
	assert(not enemy.is_dead, "Enemy should survive 20 damage when max_hp=25")
	assert(enemy.hp == 5, "Expected 5 HP remaining, got %d" % enemy.hp)

	# 3rd hit kills it
	enemy.take_damage(10)
	assert(enemy.is_dead, "Enemy should die on 3rd hit")

	print("TEST ENEMY DATA PASSED")
	quit(0)
