class_name EnemyBase
extends CharacterBody2D
## Base class for chasing enemies. Moves toward the player in world space.

const BOB_SPEED: float = 8.0
const BOB_AMPLITUDE: float = 3.0

@export var data: EnemyData = null:
	set(value):
		data = value
		if is_node_ready() and data != null:
			apply_data(data)
@export var data_path: String = ""
@export var move_speed: float = 95.0
@export var max_hp: int = 10
@export var xp_value: int = 5
@export var target: Node2D = null

var hp: int = 10
var is_dead: bool = false
var pool_key: String = ""
var _bob_time: float = 0.0
var _base_sprite_y: float = 0.0
var _knockback_vel: Vector2 = Vector2.ZERO

@onready var _sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D


func _ready() -> void:
	add_to_group("enemies")
	if data == null and not data_path.is_empty():
		var loaded: Resource = load(data_path)
		if loaded is EnemyData:
			data = loaded as EnemyData
	if data != null:
		apply_data(data)
	else:
		hp = max_hp
	if _sprite != null:
		_base_sprite_y = _sprite.position.y
	if target == null:
		target = get_tree().get_first_node_in_group("player") as Node2D


func apply_data(enemy_data: EnemyData) -> void:
	if enemy_data == null:
		return
	move_speed = enemy_data.move_speed
	max_hp = enemy_data.max_hp
	xp_value = enemy_data.xp_value
	hp = max_hp
	var hitbox: Node = get_node_or_null("Hitbox")
	if hitbox != null and "damage" in hitbox:
		hitbox.set("damage", enemy_data.contact_damage)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node2D
		if target == null:
			velocity = Vector2.ZERO
			return

	var to_target: Vector2 = target.global_position - global_position
	var chase_vel: Vector2 = Vector2.ZERO
	if to_target.length_squared() >= 1.0:
		chase_vel = to_target.normalized() * move_speed
	_knockback_vel = _knockback_vel.move_toward(Vector2.ZERO, 900.0 * delta)
	velocity = chase_vel + _knockback_vel
	move_and_slide()
	_update_visual(to_target, delta)


## Applies damage to the enemy and triggers death when HP reaches zero.
func take_damage(amount: int) -> void:
	if is_dead or amount <= 0:
		return

	hp = maxi(0, hp - amount)
	if target != null and is_instance_valid(target):
		var away: Vector2 = global_position - target.global_position
		if away.length_squared() > 0.01:
			_knockback_vel = away.normalized() * 140.0
	if _sprite != null:
		HitFeedback.flash_node(_sprite, 0.1)
	if is_inside_tree():
		HitFeedback.spawn_damage_number(get_tree(), global_position, amount, false)
		var audio: Node = get_tree().root.get_node_or_null("AudioManager")
		if audio != null and audio.has_method("play_sfx"):
			audio.call("play_sfx", "hit")
	if hp <= 0:
		_die()


func _die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	var event_bus: Node = get_tree().root.get_node_or_null("EventBus")
	if event_bus != null:
		event_bus.emit_signal("enemy_died", global_position, xp_value)
	var pool: Node = get_tree().root.get_node_or_null("PoolManager")
	if pool != null and not pool_key.is_empty() and pool.has_method("release"):
		pool.call("release", self)
	else:
		queue_free()


func on_acquire() -> void:
	is_dead = false
	hp = max_hp
	velocity = Vector2.ZERO
	_knockback_vel = Vector2.ZERO
	if _sprite != null:
		_sprite.modulate = Color.WHITE
	if not is_in_group("enemies"):
		add_to_group("enemies")
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node2D if get_tree() != null else null


func on_release() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	if is_in_group("enemies"):
		remove_from_group("enemies")


func _update_visual(to_target: Vector2, delta: float) -> void:
	if _sprite == null:
		return
	_bob_time += delta * BOB_SPEED
	var flap: float = sin(_bob_time)
	_sprite.position.y = _base_sprite_y - absf(flap) * BOB_AMPLITUDE
	_sprite.scale = Vector2(1.0 + flap * 0.06, 1.0 - flap * 0.08)
	if absf(to_target.x) > 4.0:
		_sprite.flip_h = to_target.x > 0.0
