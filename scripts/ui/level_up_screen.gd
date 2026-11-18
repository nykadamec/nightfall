class_name LevelUpScreen
extends Control
## Three-card level-up choice overlay. Pauses the tree while visible.

const ICON_BY_ID: Dictionary = {
	"weapon:whip": "res://assets/ui/components/icon_sword.png",
	"weapon:holy_bolt": "res://assets/ui/components/icon_staff.png",
	"weapon:spirit_aura": "res://assets/ui/components/icon_sun.png",
	"passive:vitality": "res://assets/ui/components/icon_potion.png",
	"passive:swift_boots": "res://assets/ui/components/icon_swirl.png",
	"passive:chronos_tome": "res://assets/ui/components/icon_ring.png",
	"passive:blood_sigil": "res://assets/ui/components/icon_flame.png",
	"whip_damage": "res://assets/ui/components/icon_sword_alt.png",
	"move_speed": "res://assets/ui/components/icon_swirl.png",
	"max_hp": "res://assets/ui/components/icon_potion.png",
	"whip_speed": "res://assets/ui/components/icon_ring.png",
}

const WEAPON_DATAS: Array[WeaponData] = [
	preload("res://resources/weapons/whip.tres"),
	preload("res://resources/weapons/holy_bolt.tres"),
	preload("res://resources/weapons/spirit_aura.tres"),
]

const PASSIVE_DATAS: Array[PassiveData] = [
	preload("res://resources/upgrades/max_hp.tres"),
	preload("res://resources/upgrades/move_speed.tres"),
	preload("res://resources/upgrades/cooldown_reduction.tres"),
	preload("res://resources/upgrades/damage.tres"),
]

const UPGRADE_POOL: Array[Dictionary] = [
	{
		"id": "whip_damage",
		"title": "+25% Whip Damage",
		"desc": "Whip deals 25% more damage.",
	},
	{
		"id": "move_speed",
		"title": "+15% Move Speed",
		"desc": "Move 15% faster across the arena.",
	},
	{
		"id": "max_hp",
		"title": "+20 Max HP",
		"desc": "Gain +20 Max HP and heal 20 HP.",
	},
	{
		"id": "whip_speed",
		"title": "+15% Attack Speed",
		"desc": "Whip strikes 15% more often.",
	},
]

var _current_choices: Array[Dictionary] = []

@onready var _title_label: Label = $CenterContainer/Panel/Margin/VBox/TitleLabel
@onready var _reroll_button: Button = $CenterContainer/Panel/Margin/VBox/ActionsRow/RerollButton
@onready var _skip_button: Button = $CenterContainer/Panel/Margin/VBox/ActionsRow/SkipButton
@onready var _card_buttons: Array[Button] = [
	$CenterContainer/Panel/Margin/VBox/CardsRow/Card1,
	$CenterContainer/Panel/Margin/VBox/CardsRow/Card2,
	$CenterContainer/Panel/Margin/VBox/CardsRow/Card3,
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false
	for i: int in range(_card_buttons.size()):
		var btn: Button = _card_buttons[i]
		btn.pressed.connect(_on_card_pressed.bind(i))
	if _reroll_button != null:
		_reroll_button.pressed.connect(reroll)
	if _skip_button != null:
		_skip_button.pressed.connect(skip)
	var bus: Node = get_tree().root.get_node_or_null("EventBus")
	if bus != null:
		bus.connect("level_up", _on_level_up)


func _on_level_up(new_level: int) -> void:
	open_for_level(new_level)


func open_for_level(new_level: int) -> void:
	if _title_label != null:
		_title_label.text = "LEVEL %d — CHOOSE AN UPGRADE" % new_level
	_roll_choices()
	_update_action_buttons()
	visible = true
	get_tree().paused = true
	if not _card_buttons.is_empty():
		_card_buttons[0].grab_focus()


func _roll_choices() -> void:
	var candidates: Array[Dictionary] = _build_candidate_pool()
	candidates.shuffle()
	_current_choices.clear()
	for i: int in range(mini(3, candidates.size())):
		var choice: Dictionary = candidates[i]
		_current_choices.append(choice)
		var btn: Button = _card_buttons[i]
		var choice_id: String = str(choice.get("id", ""))
		var title_str: String = str(choice.get("title", "Upgrade"))
		var desc_str: String = str(choice.get("desc", ""))
		btn.text = ""
		var title_lbl: Label = btn.get_node_or_null("Body/CardTitle") as Label
		var desc_lbl: Label = btn.get_node_or_null("Body/CardDesc") as Label
		var icon_rect: TextureRect = btn.get_node_or_null("Body/Icon") as TextureRect
		if title_lbl != null:
			title_lbl.text = title_str
		if desc_lbl != null:
			desc_lbl.text = desc_str
		if icon_rect != null:
			var icon_path: String = str(ICON_BY_ID.get(choice_id, "res://assets/ui/components/icon_sword.png"))
			if ResourceLoader.exists(icon_path):
				icon_rect.texture = load(icon_path) as Texture2D


func _build_candidate_pool() -> Array[Dictionary]:
	var pool: Array[Dictionary] = []
	var player: Node = get_tree().get_first_node_in_group("player")
	var ctrl: WeaponController = player.get_node_or_null("WeaponController") as WeaponController if player != null else null
	var save_mgr: Node = get_tree().root.get_node_or_null("SaveManager")
	for wd: WeaponData in WEAPON_DATAS:
		if wd == null:
			continue
		if save_mgr != null and save_mgr.has_method("is_unlocked"):
			if save_mgr.call("is_unlocked", wd.id) != true:
				continue
		if ctrl != null and ctrl.has_weapon(wd.id):
			if ctrl.can_upgrade_weapon(wd.id):
				var next_lvl: int = ctrl.get_weapon_level(wd.id) + 1
				pool.append({
					"id": "weapon:" + wd.id,
					"weapon_data": wd,
					"title": "%s Lv.%d" % [wd.display_name, next_lvl],
					"desc": "Upgrade %s (+damage & speed)." % wd.display_name,
				})
		elif wd.weapon_scene != null:
			pool.append({
				"id": "weapon:" + wd.id,
				"weapon_data": wd,
				"title": "New: %s" % wd.display_name,
				"desc": wd.description,
			})
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	for pd: PassiveData in PASSIVE_DATAS:
		if pd == null:
			continue
		var cur_lvl: int = 0
		if run_state != null and run_state.has_method("get_passive_level"):
			var lvl_v: Variant = run_state.call("get_passive_level", pd.id)
			cur_lvl = lvl_v if lvl_v is int else 0
		if cur_lvl < pd.max_level:
			pool.append({
				"id": "passive:" + pd.id,
				"passive_data": pd,
				"title": "%s Lv.%d" % [pd.display_name, cur_lvl + 1],
				"desc": pd.description,
			})
	for item: Dictionary in UPGRADE_POOL:
		if pool.size() >= 3:
			break
		pool.append(item)
	return pool


func get_current_choice_ids() -> Array[String]:
	var ids: Array[String] = []
	for choice: Dictionary in _current_choices:
		ids.append(str(choice.get("id", "")))
	return ids


func choose_card(index: int) -> void:
	if index < 0 or index >= _current_choices.size():
		return
	var choice: Dictionary = _current_choices[index]
	var choice_id: String = str(choice.get("id", ""))
	if choice_id.begins_with("weapon:"):
		var wd_v: Variant = choice.get("weapon_data", null)
		var wd: WeaponData = wd_v if wd_v is WeaponData else null
		_apply_weapon_choice(wd)
	elif choice_id.begins_with("passive:"):
		var pd_v: Variant = choice.get("passive_data", null)
		var pd: PassiveData = pd_v if pd_v is PassiveData else null
		var run_state: Node = get_tree().root.get_node_or_null("RunState")
		var player: Node = get_tree().get_first_node_in_group("player")
		if run_state != null and pd != null:
			run_state.call("apply_passive", pd, player)
	else:
		_apply_upgrade(choice_id)
	_close()


func _apply_weapon_choice(wd: WeaponData) -> void:
	if wd == null:
		return
	var player: Node = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var ctrl: WeaponController = player.get_node_or_null("WeaponController") as WeaponController
	if ctrl != null:
		ctrl.equip_weapon(wd)


func _on_card_pressed(index: int) -> void:
	choose_card(index)


func reroll() -> void:
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	if run_state == null:
		return
	var left_v: Variant = run_state.get("rerolls_left")
	var left: int = left_v if left_v is int else 0
	if left <= 0:
		_update_action_buttons()
		return
	run_state.set("rerolls_left", left - 1)
	_roll_choices()
	_update_action_buttons()


func skip() -> void:
	_close()


func _update_action_buttons() -> void:
	if _reroll_button == null:
		return
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	var left: int = 0
	if run_state != null:
		var left_v: Variant = run_state.get("rerolls_left")
		left = left_v if left_v is int else 0
	_reroll_button.text = "Reroll (%d)" % left
	_reroll_button.disabled = left <= 0


func _close() -> void:
	visible = false
	get_tree().paused = false


func _apply_upgrade(upgrade_id: String) -> void:
	var player: Node = get_tree().get_first_node_in_group("player")
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	var bus: Node = get_tree().root.get_node_or_null("EventBus")
	match upgrade_id:
		"whip_damage":
			if player != null:
				var whip: Node = player.get_node_or_null("WhipWeapon")
				if whip != null:
					var dmg_val: Variant = whip.get("damage")
					var cur_dmg: int = dmg_val if dmg_val is int else 10
					whip.set("damage", maxi(roundi(float(cur_dmg) * 1.25), cur_dmg + 3))
		"move_speed":
			if player != null:
				var spd_val: Variant = player.get("move_speed")
				var cur_spd: float = spd_val if spd_val is float else 185.0
				player.set("move_speed", cur_spd * 1.15)
		"max_hp":
			if run_state != null:
				var max_val: Variant = run_state.get("max_hp")
				var hp_val: Variant = run_state.get("hp")
				var base_max: int = max_val if max_val is int else 100
				var base_hp: int = hp_val if hp_val is int else 100
				var new_max: int = base_max + 20
				var new_hp: int = mini(base_hp + 20, new_max)
				run_state.set("max_hp", new_max)
				run_state.set("hp", new_hp)
				if bus != null:
					bus.emit_signal("player_hurt", new_hp, new_max)
		"whip_speed":
			if player != null:
				var whip: Node = player.get_node_or_null("WhipWeapon")
				if whip != null:
					var cd_val: Variant = whip.get("cooldown")
					var cur_cd: float = cd_val if cd_val is float else 1.2
					whip.set("cooldown", maxf(0.25, cur_cd * 0.85))
