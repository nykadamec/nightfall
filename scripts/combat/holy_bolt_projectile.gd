class_name HolyBoltProjectile
extends Area2D
## Moving projectile fired by HolyBoltWeapon (layer: player_hit, mask: enemies).

var damage: int = 14
var speed: float = 340.0
var direction: Vector2 = Vector2.RIGHT
var lifetime: float = 1.8
var pool_key: String = ""

var _timer: float = 0.0
var _consumed: bool = false


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)


func setup(spawn_pos: Vector2, dir: Vector2, dmg: int, proj_speed: float = 340.0, life: float = 1.8) -> void:
	global_position = spawn_pos
	direction = dir.normalized() if dir.length_squared() > 0.0001 else Vector2.RIGHT
	rotation = direction.angle()
	damage = dmg
	speed = proj_speed
	lifetime = life
	_timer = 0.0
	_consumed = false


func _physics_process(delta: float) -> void:
	if _consumed:
		return
	global_position += direction * speed * delta
	_timer += delta
	if _timer >= lifetime:
		_despawn()


func _on_area_entered(area: Area2D) -> void:
	if _consumed:
		return
	var target: Node = area
	if not target.has_method("take_damage") and target.get_parent() != null and target.get_parent().has_method("take_damage"):
		target = target.get_parent()
	if target.has_method("take_damage"):
		_consumed = true
		target.call("take_damage", damage)
		_despawn()


func _on_body_entered(body: Node2D) -> void:
	if _consumed:
		return
	if body.has_method("take_damage"):
		_consumed = true
		body.call("take_damage", damage)
		_despawn()


func _despawn() -> void:
	var pool: Node = get_tree().root.get_node_or_null("PoolManager") if get_tree() != null else null
	if pool != null and not pool_key.is_empty() and pool.has_method("release"):
		pool.call("release", self)
	else:
		queue_free()
