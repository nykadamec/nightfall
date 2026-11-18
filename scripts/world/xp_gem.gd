class_name XpGem
extends Area2D
## XP gem pickup dropped by dead enemies (layer: pickups, mask: player).

@export var xp_value: int = 5
@export var bob_amplitude: float = 2.5
@export var bob_speed: float = 5.0

var pool_key: String = ""
var _collected: bool = false
var _bob_time: float = 0.0
var _base_y: float = 0.0

@onready var _sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D


func _ready() -> void:
	add_to_group("pickups")
	if _sprite != null:
		_base_y = _sprite.position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _sprite != null:
		_bob_time += delta * bob_speed
		_sprite.position.y = _base_y - absf(sin(_bob_time)) * bob_amplitude


func _on_body_entered(body: Node2D) -> void:
	if _collected:
		return
	if body.is_in_group("player"):
		collect()


func collect() -> void:
	if _collected:
		return
	_collected = true
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	var event_bus: Node = get_tree().root.get_node_or_null("EventBus")
	var total_xp: int = xp_value
	if run_state != null:
		if run_state.has_method("add_xp"):
			run_state.call("add_xp", xp_value)
			var xp_val: Variant = run_state.get("xp")
			total_xp = xp_val if xp_val is int else total_xp
		else:
			var cur_val: Variant = run_state.get("xp")
			var cur_xp: int = cur_val if cur_val is int else 0
			total_xp = cur_xp + xp_value
			run_state.set("xp", total_xp)
	if event_bus != null:
		event_bus.emit_signal("xp_collected", xp_value, total_xp)
	var pool: Node = get_tree().root.get_node_or_null("PoolManager")
	if pool != null and not pool_key.is_empty() and pool.has_method("release"):
		pool.call("release", self)
	else:
		queue_free()


func on_acquire() -> void:
	_collected = false
	if not is_in_group("pickups"):
		add_to_group("pickups")


func on_release() -> void:
	_collected = true
	if is_in_group("pickups"):
		remove_from_group("pickups")
