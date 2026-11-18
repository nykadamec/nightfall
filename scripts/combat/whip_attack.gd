class_name WhipAttack
extends Area2D
## Short-lived melee slash volume for the whip weapon (layer: player_hit).

signal hit_target(target: Node, amount: int)

var damage: int = 10
var duration: float = 0.2
var _timer: float = 0.0
var _hit_targets: Dictionary = {}

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _visual_outer: Polygon2D = $VisualOuter
@onready var _visual_core: Polygon2D = $VisualCore


func setup(attack_damage: int, attack_duration: float, attack_size: Vector2, facing_right: bool) -> void:
	damage = attack_damage
	duration = attack_duration
	scale.x = 1.0 if facing_right else -1.0
	if _collision_shape != null and _collision_shape.shape is RectangleShape2D:
		var rect: RectangleShape2D = (_collision_shape.shape as RectangleShape2D).duplicate() as RectangleShape2D
		rect.size = attack_size
		_collision_shape.shape = rect
	var hw: float = attack_size.x * 0.5
	var hh: float = attack_size.y * 0.5
	if _visual_outer != null:
		_visual_outer.polygon = PackedVector2Array([
			Vector2(-hw, -hh * 0.18),
			Vector2(0.0, -hh * 0.85),
			Vector2(hw * 0.88, -hh * 0.65),
			Vector2(hw, 0.0),
			Vector2(hw * 0.88, hh * 0.65),
			Vector2(0.0, hh * 0.85),
			Vector2(-hw, hh * 0.18),
		])
	if _visual_core != null:
		_visual_core.polygon = PackedVector2Array([
			Vector2(-hw * 0.75, -hh * 0.08),
			Vector2(hw * 0.75, -hh * 0.35),
			Vector2(hw * 0.94, 0.0),
			Vector2(hw * 0.75, hh * 0.35),
			Vector2(-hw * 0.75, hh * 0.08),
		])


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_timer += delta
	var alpha: float = clampf(1.0 - (_timer / maxf(duration, 0.001)), 0.0, 1.0)
	modulate.a = alpha
	if _timer >= duration:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		_apply_hit(area)
	elif area.get_parent() != null and area.get_parent().has_method("take_damage"):
		_apply_hit(area.get_parent())


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		_apply_hit(body)


func _apply_hit(target: Node) -> void:
	var id: int = target.get_instance_id()
	if _hit_targets.has(id):
		return
	_hit_targets[id] = true
	hit_target.emit(target, damage)
	target.call("take_damage", damage)
