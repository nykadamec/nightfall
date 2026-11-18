class_name BossVampireLord
extends EnemyBase
## Vampire Lord boss spawned at boss_spawn_time_sec. Emits boss bar signals.

@export var boss_name: String = "Vampire Lord"


func _ready() -> void:
	super._ready()
	add_to_group("bosses")
	if data != null and not data.display_name.is_empty():
		boss_name = data.display_name
	var bus: Node = get_tree().root.get_node_or_null("EventBus")
	if bus != null:
		bus.emit_signal("boss_spawned", boss_name, max_hp)


func take_damage(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	var prev_hp: int = hp
	super.take_damage(amount)
	if hp != prev_hp:
		var bus: Node = get_tree().root.get_node_or_null("EventBus")
		if bus != null:
			bus.emit_signal("boss_hp_changed", hp, max_hp)


func _die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	var bus: Node = get_tree().root.get_node_or_null("EventBus")
	if bus != null:
		bus.emit_signal("enemy_died", global_position, xp_value)
		bus.emit_signal("boss_died")
	queue_free()
