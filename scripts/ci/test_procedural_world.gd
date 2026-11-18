extends SceneTree
## Headless CI test: verifies procedural world generation (tiles, boundary walls,
## safe spawn clearing, varied props/torches, and seed determinism).


func _initialize() -> void:
	var main_scene: PackedScene = load("res://scenes/world/main.tscn")
	if main_scene == null:
		push_error("Failed to load main.tscn")
		quit(1)
		return

	var main: Node = main_scene.instantiate()
	root.add_child(main)
	await physics_frame

	var world: Node2D = main.get_node_or_null("World") as Node2D
	var floor_layer: TileMapLayer = main.get_node_or_null("World/FloorLayer") as TileMapLayer
	var wall_layer: TileMapLayer = main.get_node_or_null("World/WallLayer") as TileMapLayer
	if world == null or floor_layer == null or wall_layer == null:
		push_error("Missing World / FloorLayer / WallLayer")
		quit(1)
		return

	var floor_count: int = floor_layer.get_used_cells().size()
	var wall_count: int = wall_layer.get_used_cells().size()
	if floor_count < 100 or wall_count < 20:
		push_error("Insufficient generated tiles: floor=%d wall=%d" % [floor_count, wall_count])
		quit(1)
		return

	var prop_count: int = 0
	var torch_count: int = 0
	for child: Node in world.get_children():
		if child.is_in_group("generated_props") and child is StaticBody2D:
			prop_count += 1
			var prop_node: StaticBody2D = child as StaticBody2D
			if prop_node.position.length() < 170.0:
				push_error("Generated prop too close to spawn: %s at %s" % [prop_node.name, prop_node.position])
				quit(1)
				return
			if prop_node.get_node_or_null("TorchLight") != null:
				torch_count += 1

	if prop_count < 15 or torch_count < 4:
		push_error("Insufficient generated props/torches: props=%d torches=%d" % [prop_count, torch_count])
		quit(1)
		return

	# Verify seed determinism vs variation.
	WorldGenerator.generate(world, floor_layer, wall_layer, Vector2(1150.0, 560.0), 20, 4, 135.0, 175.0, 4242)
	await process_frame
	var p1_a: StaticBody2D = world.get_node_or_null("PropBlock1") as StaticBody2D
	var pos_a: Vector2 = p1_a.position if p1_a != null else Vector2.ZERO

	WorldGenerator.generate(world, floor_layer, wall_layer, Vector2(1150.0, 560.0), 20, 4, 135.0, 175.0, 4242)
	await process_frame
	var p1_b: StaticBody2D = world.get_node_or_null("PropBlock1") as StaticBody2D
	var pos_b: Vector2 = p1_b.position if p1_b != null else Vector2.ZERO

	if pos_a == Vector2.ZERO or pos_a.distance_to(pos_b) > 0.01:
		push_error("Same seed did not reproduce PropBlock1 position: %s vs %s" % [pos_a, pos_b])
		quit(1)
		return

	WorldGenerator.generate(world, floor_layer, wall_layer, Vector2(1150.0, 560.0), 20, 4, 135.0, 175.0, 9999)
	await process_frame
	var p1_c: StaticBody2D = world.get_node_or_null("PropBlock1") as StaticBody2D
	var pos_c: Vector2 = p1_c.position if p1_c != null else Vector2.ZERO

	if pos_a.distance_to(pos_c) < 1.0:
		push_error("Different seeds produced identical PropBlock1 position: %s" % pos_a)
		quit(1)
		return

	print("TEST PROCEDURAL WORLD PASSED (floor=%d wall=%d props=%d torches=%d)" % [
		floor_count, wall_count, prop_count, torch_count
	])
	quit(0)
