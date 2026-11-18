class_name CoinPickup
extends Area2D
## Gold coin pickup that increments RunState.gold.

@export var gold_value: int = 1

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
	var total_gold: int = gold_value
	if run_state != null:
		var gold_v: Variant = run_state.get("gold")
		var cur_gold: int = gold_v if gold_v is int else 0
		total_gold = cur_gold + gold_value
		run_state.set("gold", total_gold)
	if bus != null:
		bus.emit_signal("gold_collected", gold_value, total_gold)
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
