class_name DamageNumber
extends Node2D
## Pooled floating damage text that drifts upward and fades out.

const LIFETIME_SEC: float = 0.45

var pool_key: String = ""
var _elapsed: float = 0.0
var _velocity: Vector2 = Vector2(0.0, -40.0)
var _active: bool = false

@onready var _label: Label = $Label


func _ready() -> void:
	set_process(false)


func setup(amount: int, is_player_hit: bool = false) -> void:
	_elapsed = 0.0
	_velocity = Vector2(randf_range(-14.0, 14.0), -42.0)
	_active = true
	modulate = Color.WHITE
	if _label != null:
		_label.text = str(amount)
		_label.modulate = Color(1.0, 0.35, 0.35, 1.0) if is_player_hit else Color(1.0, 0.94, 0.72, 1.0)
	visible = true
	set_process(true)


func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed += delta
	global_position += _velocity * delta
	var t: float = clampf(_elapsed / LIFETIME_SEC, 0.0, 1.0)
	modulate.a = 1.0 - t
	if _elapsed >= LIFETIME_SEC:
		_finish()


func _finish() -> void:
	_active = false
	set_process(false)
	var pool: Node = get_tree().root.get_node_or_null("PoolManager") if is_inside_tree() else null
	if pool != null and not pool_key.is_empty() and pool.has_method("release"):
		pool.call("release", self)
	else:
		queue_free()


func on_acquire() -> void:
	_elapsed = 0.0
	modulate = Color.WHITE
	visible = true


func on_release() -> void:
	_active = false
	set_process(false)
	visible = false
	modulate = Color.WHITE
