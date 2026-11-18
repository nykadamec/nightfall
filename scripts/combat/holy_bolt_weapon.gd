class_name HolyBoltWeapon
extends Node2D
## Auto-firing holy projectile weapon owned by WeaponController.

const BOLT_SCENE: PackedScene = preload("res://scenes/weapons/holy_bolt_projectile.tscn")
const DEFAULT_DATA_PATH: String = "res://resources/weapons/holy_bolt.tres"

@export var data: WeaponData = null:
	set(value):
		data = value
		if is_node_ready():
			_apply_data()
@export var damage: int = 14
@export var cooldown: float = 1.4:
	set(value):
		cooldown = value
		if not _applying_data:
			_cooldown_overridden = true
		_cooldown_timer = minf(_cooldown_timer, cooldown)
@export var projectile_speed: float = 340.0
@export var projectile_lifetime: float = 1.8

var _cooldown_timer: float = 0.0
var _controller: WeaponController = null
var _applying_data: bool = false
var _cooldown_overridden: bool = false


func _ready() -> void:
	if data == null:
		data = load(DEFAULT_DATA_PATH) as WeaponData
	_apply_data()
	_cooldown_timer = cooldown


func _apply_data() -> void:
	if data == null:
		return
	_applying_data = true
	damage = data.damage
	if not _cooldown_overridden:
		cooldown = data.cooldown
	if data.duration > 0.0:
		projectile_lifetime = data.duration
	_applying_data = false


func set_controller(controller: WeaponController) -> void:
	_controller = controller


func upgrade() -> void:
	damage = maxi(roundi(float(damage) * 1.25), damage + 4)
	cooldown = maxf(0.35, cooldown * 0.88)


func _physics_process(delta: float) -> void:
	var cd_mult: float = _controller.cooldown_multiplier if _controller != null else 1.0
	var effective_cd: float = maxf(0.2, cooldown * cd_mult)
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		_cooldown_timer = effective_cd
		fire()


func fire() -> HolyBoltProjectile:
	var dir: Vector2 = _pick_direction()
	var dmg_mult: float = _controller.damage_multiplier if _controller != null else 1.0
	var final_dmg: int = maxi(1, roundi(float(damage) * dmg_mult))
	var spawn_pos: Vector2 = global_position + Vector2(0.0, -24.0) + dir * 18.0
	var bolt: HolyBoltProjectile = null
	var pool: Node = get_tree().root.get_node_or_null("PoolManager") if get_tree() != null else null
	if pool != null and pool.has_method("acquire"):
		var pooled_v: Variant = pool.call("acquire", "holy_bolt")
		bolt = pooled_v if pooled_v is HolyBoltProjectile else null
	if bolt == null:
		bolt = BOLT_SCENE.instantiate() as HolyBoltProjectile
		var world_parent: Node = get_tree().current_scene.get_node_or_null("World") if get_tree() != null and get_tree().current_scene != null else null
		if world_parent != null:
			world_parent.add_child(bolt)
		elif get_tree() != null:
			get_tree().root.add_child(bolt)
	bolt.setup(spawn_pos, dir, final_dmg, projectile_speed, projectile_lifetime)
	return bolt


func _pick_direction() -> Vector2:
	var nearest: Node2D = _find_nearest_enemy()
	if nearest != null:
		var delta_vec: Vector2 = nearest.global_position - global_position
		if delta_vec.length_squared() > 0.01:
			return delta_vec.normalized()
	return Vector2.RIGHT


func _find_nearest_enemy() -> Node2D:
	var tree: SceneTree = get_tree()
	if tree == null:
		return null
	var best: Node2D = null
	var best_d2: float = INF
	for node: Node in tree.get_nodes_in_group("enemies"):
		if node is Node2D and is_instance_valid(node):
			var n2d: Node2D = node as Node2D
			var d2: float = global_position.distance_squared_to(n2d.global_position)
			if d2 < best_d2:
				best_d2 = d2
				best = n2d
	return best
