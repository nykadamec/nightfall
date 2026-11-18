extends Node
## Holds transient state for the current run and resets cleanly on new runs.

const DEFAULT_MAX_HP: int = 100
const DEFAULT_LEVEL: int = 1
const DEFAULT_REROLLS: int = 3

var time_sec: float = 0.0
var xp: int = 0
var level: int = DEFAULT_LEVEL
var hp: int = DEFAULT_MAX_HP
var max_hp: int = DEFAULT_MAX_HP
var gold: int = 0
var rerolls_left: int = DEFAULT_REROLLS
var passives: Dictionary = {}


func _ready() -> void:
	reset()


func reset() -> void:
	time_sec = 0.0
	xp = 0
	level = DEFAULT_LEVEL
	max_hp = DEFAULT_MAX_HP
	hp = max_hp
	gold = 0
	rerolls_left = DEFAULT_REROLLS
	passives.clear()


func get_passive_level(passive_id: String) -> int:
	var lvl_v: Variant = passives.get(passive_id, 0)
	return lvl_v if lvl_v is int else 0


func apply_passive(passive: PassiveData, player: Node) -> bool:
	if passive == null or passive.id.is_empty():
		return false
	var cur_lvl: int = get_passive_level(passive.id)
	if cur_lvl >= passive.max_level:
		return false
	passives[passive.id] = cur_lvl + 1

	var bus: Node = get_tree().root.get_node_or_null("EventBus") if get_tree() != null else null
	var ctrl: Node = player.get_node_or_null("WeaponController") if player != null else null
	match passive.stat_type:
		PassiveData.StatType.MAX_HP:
			var bonus: int = maxi(1, roundi(passive.amount_per_level))
			max_hp += bonus
			hp = mini(hp + bonus, max_hp)
			if bus != null:
				bus.emit_signal("player_hurt", hp, max_hp)
		PassiveData.StatType.MOVE_SPEED:
			if player != null:
				var spd_v: Variant = player.get("move_speed")
				var cur_spd: float = spd_v if spd_v is float else 185.0
				player.set("move_speed", cur_spd * (1.0 + passive.amount_per_level))
		PassiveData.StatType.COOLDOWN_REDUCTION:
			if ctrl != null:
				var cd_v: Variant = ctrl.get("cooldown_multiplier")
				var cur_cd: float = cd_v if cd_v is float else 1.0
				ctrl.set("cooldown_multiplier", maxf(0.4, cur_cd - passive.amount_per_level))
		PassiveData.StatType.DAMAGE:
			if ctrl != null:
				var dmg_v: Variant = ctrl.get("damage_multiplier")
				var cur_dmg: float = dmg_v if dmg_v is float else 1.0
				ctrl.set("damage_multiplier", cur_dmg + passive.amount_per_level)
	return true


func xp_needed_for(target_level: int) -> int:
	return 10 * maxi(target_level, 1)


func add_xp(amount: int) -> void:
	if amount <= 0:
		return
	xp += amount
	var bus: Node = get_tree().root.get_node_or_null("EventBus") if get_tree() != null else null
	while xp >= xp_needed_for(level):
		xp -= xp_needed_for(level)
		level += 1
		if bus != null:
			bus.emit_signal("level_up", level)
