class_name WorldGenerator
extends RefCounted
## Procedurally generates the isometric graveyard arena: terrain tiles, boundary walls,
## varied gothic props, and flickering braziers.

const PROP_BLOCK_SCENE: PackedScene = preload("res://scenes/world/prop_block.tscn")
const LIGHT_TEXTURE: Texture2D = preload("res://resources/vfx/light_radial.tres")
const BRAZIER_LIGHT_SCRIPT: Script = preload("res://scripts/world/brazier_light.gd")

const TILE_GRASS: Vector2i = Vector2i(0, 0)
const TILE_COBBLESTONE: Vector2i = Vector2i(1, 0)
const TILE_DIRT: Vector2i = Vector2i(2, 0)
const TILE_GRAVEYARD_SOIL: Vector2i = Vector2i(3, 0)
const TILE_WATER: Vector2i = Vector2i(4, 0)

const PROP_TEXTURES: Array[Texture2D] = [
	preload("res://assets/props/gravestones_group.png"),
	preload("res://assets/props/gravestone_cross.png"),
	preload("res://assets/props/gravestone_right.png"),
	preload("res://assets/props/gravestones_left_front.png"),
	preload("res://assets/props/tree_dead.png"),
	preload("res://assets/props/pillar.png"),
	preload("res://assets/props/skull_pile.png"),
	preload("res://assets/props/barrel.png"),
	preload("res://assets/props/crate.png"),
]
const BRAZIER_TEXTURE: Texture2D = preload("res://assets/props/brazier.png")


## Generates floor tiles, boundary wall tiles, and props inside `world`.
## Returns the RNG seed used for generation.
static func generate(
	world: Node2D,
	floor_layer: TileMapLayer,
	wall_layer: TileMapLayer,
	arena_half_extents: Vector2 = Vector2(1150.0, 560.0),
	prop_count: int = 30,
	brazier_count: int = 8,
	min_prop_spacing: float = 135.0,
	spawn_safe_radius: float = 175.0,
	seed_override: int = 0
) -> int:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	if seed_override != 0:
		rng.seed = seed_override
	else:
		rng.randomize()
	var used_seed: int = rng.seed

	_clear_existing_props(world)
	_generate_tile_layers(floor_layer, wall_layer, arena_half_extents, used_seed)
	_generate_props(
		world,
		rng,
		arena_half_extents,
		prop_count,
		brazier_count,
		min_prop_spacing,
		spawn_safe_radius
	)
	return used_seed


static func _clear_existing_props(world: Node2D) -> void:
	if world == null:
		return
	for child: Node in world.get_children():
		if child.is_in_group("generated_props") or child.name.begins_with("PropBlock"):
			world.remove_child(child)
			child.queue_free()


static func _generate_tile_layers(
	floor_layer: TileMapLayer,
	wall_layer: TileMapLayer,
	arena_half_extents: Vector2,
	noise_seed: int
) -> void:
	if floor_layer == null:
		return
	floor_layer.clear()
	if wall_layer != null:
		wall_layer.clear()

	var biome_noise: FastNoiseLite = FastNoiseLite.new()
	biome_noise.seed = noise_seed
	biome_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	biome_noise.frequency = 0.085

	var path_noise: FastNoiseLite = FastNoiseLite.new()
	path_noise.seed = noise_seed + 1013
	path_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	path_noise.frequency = 0.055

	# Convert world-space corners to isometric tile bounds with padding.
	var outer_margin: Vector2 = Vector2(192.0, 128.0)
	var scan_half: Vector2 = arena_half_extents + outer_margin
	var tile_range: int = 36

	for ty: int in range(-tile_range, tile_range + 1):
		for tx: int in range(-tile_range, tile_range + 1):
			var cell: Vector2i = Vector2i(tx, ty)
			var local_pos: Vector2 = floor_layer.map_to_local(cell)
			if absf(local_pos.x) > scan_half.x or absf(local_pos.y) > scan_half.y:
				continue

			var inside_arena: bool = (
				absf(local_pos.x) <= arena_half_extents.x
				and absf(local_pos.y) <= arena_half_extents.y
			)
			if not inside_arena:
				floor_layer.set_cell(cell, 0, TILE_GRAVEYARD_SOIL)
				if wall_layer != null:
					wall_layer.set_cell(cell, 0, TILE_WATER)
				continue

			var floor_atlas: Vector2i = _pick_floor_tile(local_pos, biome_noise, path_noise, cell)
			floor_layer.set_cell(cell, 0, floor_atlas)


static func _pick_floor_tile(
	local_pos: Vector2,
	biome_noise: FastNoiseLite,
	path_noise: FastNoiseLite,
	cell: Vector2i
) -> Vector2i:
	# Central cobblestone plaza around player spawn.
	if local_pos.length() < 150.0:
		return TILE_COBBLESTONE

	var p_val: float = absf(path_noise.get_noise_2d(float(cell.x), float(cell.y)))
	if p_val < 0.085:
		return TILE_COBBLESTONE
	if p_val < 0.145:
		return TILE_DIRT

	var b_val: float = biome_noise.get_noise_2d(float(cell.x), float(cell.y))
	if b_val > 0.24:
		return TILE_GRASS
	if b_val < -0.28:
		return TILE_DIRT
	return TILE_GRAVEYARD_SOIL


static func _generate_props(
	world: Node2D,
	rng: RandomNumberGenerator,
	arena_half_extents: Vector2,
	prop_count: int,
	brazier_count: int,
	min_prop_spacing: float,
	spawn_safe_radius: float
) -> void:
	if world == null:
		return

	var placed_positions: Array[Vector2] = []
	var prop_margin: Vector2 = Vector2(90.0, 70.0)
	var usable_extents: Vector2 = Vector2(
		maxf(120.0, arena_half_extents.x - prop_margin.x),
		maxf(120.0, arena_half_extents.y - prop_margin.y)
	)
	var prop_index: int = 1

	# Place braziers in angular sectors so warm light is spread across the arena.
	var safe_brazier_count: int = maxi(0, brazier_count)
	for i: int in range(safe_brazier_count):
		var angle_base: float = (TAU / float(maxi(1, safe_brazier_count))) * float(i)
		var pos: Vector2 = _find_valid_position_in_sector(
			rng,
			placed_positions,
			usable_extents,
			spawn_safe_radius,
			min_prop_spacing,
			angle_base,
			TAU / float(maxi(1, safe_brazier_count))
		)
		if pos != Vector2.INF:
			placed_positions.append(pos)
			_spawn_prop(world, pos, BRAZIER_TEXTURE, true, "PropBlock%d" % prop_index)
			prop_index += 1

	# Place varied graveyard/ruin obstacles.
	var safe_prop_count: int = maxi(0, prop_count)
	for _i: int in range(safe_prop_count):
		var pos: Vector2 = _find_valid_position(
			rng,
			placed_positions,
			usable_extents,
			spawn_safe_radius,
			min_prop_spacing
		)
		if pos == Vector2.INF:
			break
		placed_positions.append(pos)
		var tex: Texture2D = PROP_TEXTURES[rng.randi_range(0, PROP_TEXTURES.size() - 1)]
		_spawn_prop(world, pos, tex, false, "PropBlock%d" % prop_index)
		prop_index += 1


static func _find_valid_position_in_sector(
	rng: RandomNumberGenerator,
	placed: Array[Vector2],
	extents: Vector2,
	safe_radius: float,
	min_spacing: float,
	angle_start: float,
	angle_span: float
) -> Vector2:
	for _attempt: int in range(24):
		var angle: float = angle_start + rng.randf_range(0.0, angle_span)
		var dist_ratio: float = rng.randf_range(0.32, 0.85)
		var candidate: Vector2 = Vector2(
			cos(angle) * extents.x * dist_ratio,
			sin(angle) * extents.y * dist_ratio
		)
		if _is_position_valid(candidate, placed, extents, safe_radius, min_spacing):
			return candidate
	return _find_valid_position(rng, placed, extents, safe_radius, min_spacing)


static func _find_valid_position(
	rng: RandomNumberGenerator,
	placed: Array[Vector2],
	extents: Vector2,
	safe_radius: float,
	min_spacing: float
) -> Vector2:
	for _attempt: int in range(32):
		var candidate: Vector2 = Vector2(
			rng.randf_range(-extents.x, extents.x),
			rng.randf_range(-extents.y, extents.y)
		)
		if _is_position_valid(candidate, placed, extents, safe_radius, min_spacing):
			return candidate
	return Vector2.INF


static func _is_position_valid(
	candidate: Vector2,
	placed: Array[Vector2],
	extents: Vector2,
	safe_radius: float,
	min_spacing: float
) -> bool:
	if absf(candidate.x) > extents.x or absf(candidate.y) > extents.y:
		return false
	if candidate.length() < safe_radius:
		return false
	var min_sq: float = min_spacing * min_spacing
	for existing: Vector2 in placed:
		if candidate.distance_squared_to(existing) < min_sq:
			return false
	return true


static func _spawn_prop(
	world: Node2D,
	pos: Vector2,
	tex: Texture2D,
	with_torch: bool,
	node_name: String
) -> void:
	var prop: StaticBody2D = PROP_BLOCK_SCENE.instantiate() as StaticBody2D
	if prop == null:
		return
	prop.name = node_name
	prop.position = pos
	prop.add_to_group("generated_props")

	var sprite: Sprite2D = prop.get_node_or_null("Sprite2D") as Sprite2D
	if sprite != null and tex != null:
		sprite.texture = tex
		sprite.offset = Vector2(0.0, -float(tex.get_height()) * 0.42)

	if with_torch:
		var light: PointLight2D = PointLight2D.new()
		light.name = "TorchLight"
		light.position = Vector2(0.0, -44.0)
		light.color = Color(1.0, 0.62, 0.25, 1.0)
		light.energy = 1.15
		light.texture = LIGHT_TEXTURE
		light.texture_scale = 2.1
		light.set_script(BRAZIER_LIGHT_SCRIPT)
		prop.add_child(light)

	world.add_child(prop)
