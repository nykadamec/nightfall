class_name ChickenPickup
extends Area2D
## Roast chicken pickup that heals the player up to max_hp.

@export var heal_amount: int = 30

var pool_key: String = ""
var _collected: bool = false


func _ready() -> void:
	add_to_group("pickups")
	body_entered.connect(_on_body_entered)


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
	var bus: Node = get_tree().root.get_node_or_null("EventBus")
	if run_state != null:
		var hp_v: Variant = run_state.get("hp")
		var max_v: Variant = run_state.get("max_hp")
		var cur_hp: int = hp_v if hp_v is int else 100
		var max_hp: int = max_v if max_v is int else 100
		var new_hp: int = mini(cur_hp + heal_amount, max_hp)
		run_state.set("hp", new_hp)
		if bus != null:
			bus.emit_signal("player_hurt", new_hp, max_hp)
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
