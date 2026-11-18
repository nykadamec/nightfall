class_name WhipWeapon
extends Node2D
## Auto-attacking whip owned by the player. Swings on cooldown toward nearest enemy or alternates sides.

const WHIP_ATTACK_SCENE: PackedScene = preload("res://scenes/weapons/whip_attack.tscn")
const DEFAULT_WHIP_DATA: WeaponData = preload("res://resources/weapons/whip.tres")

@export var data: WeaponData = DEFAULT_WHIP_DATA:
	set(value):
		data = value
		if is_node_ready():
			_apply_data()
@export var damage: int = 10
@export var cooldown: float = 1.2:
	set(value):
		cooldown = value
		if not _applying_data:
			_cooldown_overridden = true
		_cooldown_timer = minf(_cooldown_timer, cooldown)
@export var duration: float = 0.2
@export var attack_size: Vector2 = Vector2(110.0, 44.0)
@export var reach_offset: float = 64.0

var _cooldown_timer: float = 0.0
var _alternate_right: bool = true
var _controller: WeaponController = null
var _applying_data: bool = false
var _cooldown_overridden: bool = false


func _ready() -> void:
	_apply_data()
	_cooldown_timer = cooldown


func _apply_data() -> void:
	if data == null:
		return
	_applying_data = true
	damage = data.damage
	if not _cooldown_overridden:
		cooldown = data.cooldown
	duration = data.duration
	attack_size = data.attack_size
	reach_offset = data.reach_offset
	_applying_data = false


func set_controller(controller: WeaponController) -> void:
	_controller = controller


func upgrade() -> void:
	damage = maxi(roundi(float(damage) * 1.25), damage + 3)
	cooldown = maxf(0.25, cooldown * 0.9)


func _physics_process(delta: float) -> void:
	var cd_mult: float = _controller.cooldown_multiplier if _controller != null else 1.0
	var effective_cd: float = maxf(0.15, cooldown * cd_mult)
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		_cooldown_timer = effective_cd
		swing()


func swing() -> WhipAttack:
	var facing_right: bool = _choose_facing_right()
	var attack: WhipAttack = WHIP_ATTACK_SCENE.instantiate() as WhipAttack
	var dir_sign: float = 1.0 if facing_right else -1.0
	var dmg_mult: float = _controller.damage_multiplier if _controller != null else 1.0
	var final_damage: int = maxi(1, roundi(float(damage) * dmg_mult))
	attack.position = Vector2(dir_sign * reach_offset, -28.0)
	add_child(attack)
	attack.setup(final_damage, duration, attack_size, facing_right)
	return attack


func _choose_facing_right() -> bool:
	var nearest: Node2D = _find_nearest_enemy()
	if nearest != null:
		return nearest.global_position.x >= global_position.x
	var side: bool = _alternate_right
	_alternate_right = not _alternate_right
	return side


func _find_nearest_enemy() -> Node2D:
	var tree: SceneTree = get_tree()
	if tree == null:
		return null
	var enemies: Array[Node] = tree.get_nodes_in_group("enemies")
	var best: Node2D = null
	var best_dist_sq: float = INF
	for node: Node in enemies:
		if node is Node2D and is_instance_valid(node):
			var n2d: Node2D = node as Node2D
			var d2: float = global_position.distance_squared_to(n2d.global_position)
			if d2 < best_dist_sq:
				best_dist_sq = d2
				best = n2d
	return best
