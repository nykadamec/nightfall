extends Node
## Persistent meta-progression and settings saved in user:// via ConfigFile.
## Schema:
##   [meta]
##     gold: int (total persistent gold across runs)
##     unlocks: Array[String] (weapon IDs unlocked; "whip" is always unlocked)
##   [settings]
##     fullscreen: bool
##     master_volume: float (0.0 .. 1.0)

const DEFAULT_SAVE_PATH: String = "user://save_data.cfg"
const DEFAULT_UNLOCKS: Array[String] = ["whip"]

var save_path: String = DEFAULT_SAVE_PATH
var meta_gold: int = 0
var unlocks: Array[String] = DEFAULT_UNLOCKS.duplicate()
var fullscreen: bool = false
var master_volume: float = 1.0

var _run_banked: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_data()
	apply_settings()
	var bus: Node = get_tree().root.get_node_or_null("EventBus")
	if bus != null:
		bus.connect("run_started", _on_run_started)
		bus.connect("player_died", _bank_run_gold)
		bus.connect("boss_died", _bank_run_gold)


func reset_to_defaults() -> void:
	meta_gold = 0
	unlocks = DEFAULT_UNLOCKS.duplicate()
	fullscreen = false
	master_volume = 1.0


func load_data(path: String = "") -> bool:
	var target: String = save_path if path.is_empty() else path
	reset_to_defaults()
	var cfg := ConfigFile.new()
	var err: Error = cfg.load(target)
	if err != OK:
		return false

	var gold_v: Variant = cfg.get_value("meta", "gold", 0)
	var raw_gold: int = gold_v if gold_v is int else 0
	meta_gold = maxi(0, raw_gold)

	var unlocks_v: Variant = cfg.get_value("meta", "unlocks", DEFAULT_UNLOCKS)
	var loaded_unlocks: Array[String] = ["whip"]
	if unlocks_v is Array:
		var u_arr: Array = unlocks_v
		for item: Variant in u_arr:
			var s: String = str(item)
			if not s.is_empty() and not loaded_unlocks.has(s):
				loaded_unlocks.append(s)
	unlocks = loaded_unlocks

	var fs_v: Variant = cfg.get_value("settings", "fullscreen", false)
	fullscreen = fs_v if fs_v is bool else false

	var vol_v: Variant = cfg.get_value("settings", "master_volume", 1.0)
	var raw_vol: float = 1.0
	if vol_v is float:
		raw_vol = vol_v
	elif vol_v is int:
		var iv: int = vol_v
		raw_vol = float(iv)
	master_volume = clampf(raw_vol, 0.0, 1.0)
	return true


func save_data(path: String = "") -> Error:
	var target: String = save_path if path.is_empty() else path
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "gold", maxi(0, meta_gold))
	cfg.set_value("meta", "unlocks", unlocks)
	cfg.set_value("settings", "fullscreen", fullscreen)
	cfg.set_value("settings", "master_volume", clampf(master_volume, 0.0, 1.0))
	return cfg.save(target)


func add_meta_gold(amount: int) -> void:
	if amount <= 0:
		return
	meta_gold += amount
	save_data()


func is_unlocked(weapon_id: String) -> bool:
	return unlocks.has(weapon_id)


func try_purchase_unlock(weapon_id: String, price: int) -> bool:
	if weapon_id.is_empty() or is_unlocked(weapon_id):
		return false
	if price < 0 or meta_gold < price:
		return false
	meta_gold -= price
	unlocks.append(weapon_id)
	save_data()
	return true


func apply_settings() -> void:
	master_volume = clampf(master_volume, 0.0, 1.0)
	var master_idx: int = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		var db: float = -80.0 if master_volume <= 0.001 else linear_to_db(master_volume)
		AudioServer.set_bus_volume_db(master_idx, db)
		AudioServer.set_bus_mute(master_idx, master_volume <= 0.001)
	if not DisplayServer.get_name().contains("headless"):
		var mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
		DisplayServer.window_set_mode(mode)


func _on_run_started() -> void:
	_run_banked = false


func _bank_run_gold() -> void:
	if _run_banked:
		return
	_run_banked = true
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	if run_state == null:
		return
	var g_v: Variant = run_state.get("gold")
	var run_gold: int = g_v if g_v is int else 0
	if run_gold > 0:
		add_meta_gold(run_gold)
