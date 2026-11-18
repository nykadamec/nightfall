class_name WeaponController
extends Node2D
## Manages equipped weapons on the player, equipping new WeaponData and upgrading existing ones.

@export var starting_weapons: Array[WeaponData] = []

var damage_multiplier: float = 1.0
var cooldown_multiplier: float = 1.0

var _weapons: Dictionary = {} # String id -> Node2D
var _levels: Dictionary = {}  # String id -> int
var _datas: Dictionary = {}   # String id -> WeaponData


func _ready() -> void:
	# Register any pre-placed sibling WhipWeapon on Player for backwards compatibility.
	var parent_node: Node = get_parent()
	if parent_node != null:
		var whip: Node2D = parent_node.get_node_or_null("WhipWeapon") as Node2D
		if whip != null:
			var w_data_v: Variant = whip.get("data")
			var w_data: WeaponData = w_data_v if w_data_v is WeaponData else null
			var w_id: String = w_data.id if w_data != null and not w_data.id.is_empty() else "whip"
			_weapons[w_id] = whip
			_levels[w_id] = 1
			if w_data != null:
				_datas[w_id] = w_data
			if whip.has_method("set_controller"):
				whip.call("set_controller", self)

	for data: WeaponData in starting_weapons:
		if data != null and not has_weapon(data.id):
			equip_weapon(data)


func has_weapon(weapon_id: String) -> bool:
	return _weapons.has(weapon_id)


func get_weapon(weapon_id: String) -> Node2D:
	var w_v: Variant = _weapons.get(weapon_id, null)
	return w_v if w_v is Node2D else null


func get_weapon_level(weapon_id: String) -> int:
	var lvl_v: Variant = _levels.get(weapon_id, 0)
	return lvl_v if lvl_v is int else 0


func can_upgrade_weapon(weapon_id: String) -> bool:
	if not has_weapon(weapon_id):
		return false
	var data_v: Variant = _datas.get(weapon_id, null)
	var data: WeaponData = data_v if data_v is WeaponData else null
	var max_lvl: int = data.max_level if data != null else 5
	return get_weapon_level(weapon_id) < max_lvl


func equip_weapon(data: WeaponData) -> Node2D:
	if data == null or data.id.is_empty():
		return null
	if has_weapon(data.id):
		upgrade_weapon(data.id)
		return get_weapon(data.id)
	if data.weapon_scene == null:
		return null
	var weapon_node: Node2D = data.weapon_scene.instantiate() as Node2D
	if weapon_node == null:
		return null
	weapon_node.name = data.id.to_pascal_case() + "Weapon"
	if weapon_node.get("data") != null or "data" in weapon_node:
		weapon_node.set("data", data)
	if weapon_node.has_method("set_controller"):
		weapon_node.call("set_controller", self)
	add_child(weapon_node)
	_weapons[data.id] = weapon_node
	_levels[data.id] = 1
	_datas[data.id] = data
	return weapon_node


func upgrade_weapon(weapon_id: String) -> bool:
	if not can_upgrade_weapon(weapon_id):
		return false
	var weapon_node: Node2D = get_weapon(weapon_id)
	var new_lvl: int = get_weapon_level(weapon_id) + 1
	_levels[weapon_id] = new_lvl
	if weapon_node != null and weapon_node.has_method("upgrade"):
		weapon_node.call("upgrade")
	return true
