class_name SpiritAuraWeapon
extends Area2D
## Orbiting/pulsing spirit aura around the player that damages overlapping enemies on tick.

const DEFAULT_DATA_PATH: String = "res://resources/weapons/spirit_aura.tres"

@export var data: WeaponData = null:
	set(value):
		data = value
		if is_node_ready():
			_apply_data()
@export var damage: int = 6
@export var cooldown: float = 0.7:
	set(value):
		cooldown = value
		if not _applying_data:
			_cooldown_overridden = true
		_tick_timer = minf(_tick_timer, cooldown)
@export var radius: float = 78.0

var _tick_timer: float = 0.0
var _controller: WeaponController = null
var _applying_data: bool = false
var _cooldown_overridden: bool = false

@onready var _shape: CollisionShape2D = $CollisionShape2D
@onready var _ring: Polygon2D = $RingVisual


func _ready() -> void:
	if data == null:
		data = load(DEFAULT_DATA_PATH) as WeaponData
	_apply_data()
	_tick_timer = cooldown
	_update_radius()


func _apply_data() -> void:
	if data == null:
		return
	_applying_data = true
	damage = data.damage
	if not _cooldown_overridden:
		cooldown = data.cooldown
	if data.attack_size.x > 0.0:
		radius = data.attack_size.x
	_applying_data = false
	if is_node_ready():
		_update_radius()


func _update_radius() -> void:
	if _shape != null and _shape.shape is CircleShape2D:
		var c: CircleShape2D = (_shape.shape as CircleShape2D).duplicate() as CircleShape2D
		c.radius = radius
		_shape.shape = c
	if _ring != null:
		var pts: PackedVector2Array = PackedVector2Array()
		var steps: int = 24
		for i: int in range(steps):
			var a: float = (float(i) / float(steps)) * TAU
			pts.append(Vector2(cos(a) * radius, sin(a) * radius * 0.65))
		_ring.polygon = pts


func set_controller(controller: WeaponController) -> void:
	_controller = controller


func upgrade() -> void:
	damage = maxi(roundi(float(damage) * 1.3), damage + 3)
	radius += 12.0
	cooldown = maxf(0.3, cooldown * 0.9)
	_update_radius()


func _physics_process(delta: float) -> void:
	if _ring != null:
		_ring.rotation += delta * 1.4
	var cd_mult: float = _controller.cooldown_multiplier if _controller != null else 1.0
	var effective_cd: float = maxf(0.2, cooldown * cd_mult)
	_tick_timer -= delta
	if _tick_timer <= 0.0:
		_tick_timer = effective_cd
		pulse_damage()


func pulse_damage() -> int:
	var dmg_mult: float = _controller.damage_multiplier if _controller != null else 1.0
	var final_dmg: int = maxi(1, roundi(float(damage) * dmg_mult))
	var hit_count: int = 0
	var hit_targets: Dictionary = {}
	for area: Area2D in get_overlapping_areas():
		var target: Node = area
		if not target.has_method("take_damage") and area.get_parent() != null and area.get_parent().has_method("take_damage"):
			target = area.get_parent()
		if target.has_method("take_damage") and not hit_targets.has(target):
			hit_targets[target] = true
			target.call("take_damage", final_dmg)
			hit_count += 1
	for body: Node2D in get_overlapping_bodies():
		if body.has_method("take_damage") and not hit_targets.has(body):
			hit_targets[body] = true
			body.call("take_damage", final_dmg)
			hit_count += 1
	return hit_count
