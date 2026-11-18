class_name HitFeedback
extends RefCounted
## Lightweight combat juice helpers: sprite hit flash and pooled floating damage numbers.

const DAMAGE_NUMBER_SCENE_PATH: String = "res://scenes/vfx/damage_number.tscn"


static func flash_node(visual: CanvasItem, duration: float = 0.1) -> void:
	if visual == null or not is_instance_valid(visual) or not visual.is_inside_tree():
		return
	visual.modulate = Color(2.2, 2.2, 2.2, 1.0)
	var tween: Tween = visual.create_tween()
	tween.tween_property(visual, "modulate", Color.WHITE, duration)


static func spawn_damage_number(
	tree: SceneTree,
	world_pos: Vector2,
	amount: int,
	is_player_hit: bool = false
) -> Node2D:
	if tree == null or tree.current_scene == null:
		return null
	var parent: Node = tree.current_scene.get_node_or_null("World")
	if parent == null:
		parent = tree.current_scene

	var node: Node = null
	var pool: Node = tree.root.get_node_or_null("PoolManager")
	if pool != null and pool.has_method("acquire"):
		var acq_v: Variant = pool.call("acquire", "damage_number", parent)
		if acq_v is Node:
			node = acq_v
	if node == null:
		var packed: PackedScene = load(DAMAGE_NUMBER_SCENE_PATH) as PackedScene
		if packed != null:
			node = packed.instantiate()
			parent.add_child(node)

	if node is Node2D:
		var dmg_node: Node2D = node as Node2D
		dmg_node.global_position = world_pos + Vector2(0.0, -26.0)
		if dmg_node.has_method("setup"):
			dmg_node.call("setup", amount, is_player_hit)
		return dmg_node
	return null
