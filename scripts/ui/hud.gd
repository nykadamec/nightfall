class_name Hud
extends Control
## Gameplay HUD displaying run timer, player HP, and XP/level progress.

@onready var _timer_label: Label = $TopBar/TimerLabel
@onready var _hp_bar: ProgressBar = $TopBar/HpBox/HpBar
@onready var _hp_label: Label = $TopBar/HpBox/HpLabel
@onready var _level_label: Label = $TopBar/XpBox/LevelLabel
@onready var _xp_bar: ProgressBar = $TopBar/XpBox/XpBar
@onready var _gold_label: Label = $TopBar/GoldChip/GoldLabel
@onready var _boss_box: Control = $BossBox
@onready var _boss_label: Label = $BossBox/BossLabel
@onready var _boss_bar: ProgressBar = $BossBox/BossBar


func _ready() -> void:
	var bus: Node = get_tree().root.get_node_or_null("EventBus")
	if bus != null:
		bus.connect("player_hurt", _on_player_hurt)
		bus.connect("xp_collected", _on_xp_collected)
		bus.connect("level_up", _on_level_up)
		bus.connect("gold_collected", _on_gold_collected)
		bus.connect("run_started", _refresh_all)
		bus.connect("boss_spawned", _on_boss_spawned)
		bus.connect("boss_hp_changed", _on_boss_hp_changed)
		bus.connect("boss_died", _on_boss_died)
	if _boss_box != null:
		_boss_box.visible = false
	_refresh_all()


func _process(_delta: float) -> void:
	_refresh_timer()


func _refresh_all() -> void:
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	if run_state == null:
		return
	var hp_v: Variant = run_state.get("hp")
	var max_v: Variant = run_state.get("max_hp")
	var cur_hp: int = hp_v if hp_v is int else 100
	var max_hp: int = max_v if max_v is int else 100
	_update_hp(cur_hp, max_hp)
	_refresh_xp()
	_refresh_gold()
	_refresh_timer()


func _refresh_gold() -> void:
	if _gold_label == null:
		return
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	var g: int = 0
	if run_state != null:
		var g_v: Variant = run_state.get("gold")
		g = g_v if g_v is int else 0
	_gold_label.text = str(g)


func _on_gold_collected(_amount: int, total_gold: int) -> void:
	if _gold_label != null:
		_gold_label.text = str(total_gold)


func _refresh_timer() -> void:
	if _timer_label == null:
		return
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	var t: float = 0.0
	if run_state != null:
		var t_v: Variant = run_state.get("time_sec")
		t = t_v if t_v is float else 0.0
	var total_sec: int = maxi(0, floori(t))
	var mins: int = total_sec / 60
	var secs: int = total_sec % 60
	_timer_label.text = "%02d:%02d" % [mins, secs]


func _update_hp(current_hp: int, max_hp: int) -> void:
	if _hp_bar != null:
		_hp_bar.max_value = float(maxi(1, max_hp))
		_hp_bar.value = float(maxi(0, current_hp))
	if _hp_label != null:
		_hp_label.text = "HP %d / %d" % [maxi(0, current_hp), maxi(1, max_hp)]


func _refresh_xp() -> void:
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	if run_state == null:
		return
	var lvl_v: Variant = run_state.get("level")
	var xp_v: Variant = run_state.get("xp")
	var lvl: int = lvl_v if lvl_v is int else 1
	var cur_xp: int = xp_v if xp_v is int else 0
	var need: int = 10 * lvl
	if run_state.has_method("xp_needed_for"):
		var need_v: Variant = run_state.call("xp_needed_for", lvl)
		need = need_v if need_v is int else need
	if _level_label != null:
		_level_label.text = "LV %d" % lvl
	if _xp_bar != null:
		_xp_bar.max_value = float(maxi(1, need))
		_xp_bar.value = float(clampi(cur_xp, 0, need))


func _on_player_hurt(current_hp: int, max_hp: int) -> void:
	_update_hp(current_hp, max_hp)


func _on_xp_collected(_amount: int, _total_xp: int) -> void:
	_refresh_xp()


func _on_level_up(_new_level: int) -> void:
	_refresh_xp()


func _on_boss_spawned(boss_name: String, max_hp: int) -> void:
	if _boss_box != null:
		_boss_box.visible = true
	if _boss_label != null:
		_boss_label.text = boss_name
	if _boss_bar != null:
		_boss_bar.max_value = float(maxi(1, max_hp))
		_boss_bar.value = float(maxi(1, max_hp))


func _on_boss_hp_changed(current_hp: int, max_hp: int) -> void:
	if _boss_bar != null:
		_boss_bar.max_value = float(maxi(1, max_hp))
		_boss_bar.value = float(maxi(0, current_hp))


func _on_boss_died() -> void:
	if _boss_box != null:
		_boss_box.visible = false
