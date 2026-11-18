class_name UnlocksScreen
extends Control
## Meta progression unlock shop (Holy Bolt & Spirit Aura) backed by SaveManager.

signal closed

const UNLOCK_ITEMS: Array[Dictionary] = [
	{"id": "holy_bolt", "name": "Holy Bolt", "price": 25},
	{"id": "spirit_aura", "name": "Spirit Aura", "price": 40},
]

@onready var _gold_label: Label = $CenterContainer/Panel/Margin/VBox/GoldLabel
@onready var _bolt_btn: Button = $CenterContainer/Panel/Margin/VBox/ItemsRow/HolyBoltBtn
@onready var _aura_btn: Button = $CenterContainer/Panel/Margin/VBox/ItemsRow/SpiritAuraBtn
@onready var _back_btn: Button = $CenterContainer/Panel/Margin/VBox/BackBtn


func _ready() -> void:
	visible = false
	if _bolt_btn != null:
		_bolt_btn.pressed.connect(_on_buy_pressed.bind(0))
	if _aura_btn != null:
		_aura_btn.pressed.connect(_on_buy_pressed.bind(1))
	if _back_btn != null:
		_back_btn.pressed.connect(close)
	refresh()


func open() -> void:
	refresh()
	visible = true
	if _back_btn != null:
		_back_btn.grab_focus()


func close() -> void:
	visible = false
	closed.emit()


func refresh() -> void:
	var save_mgr: Node = get_tree().root.get_node_or_null("SaveManager")
	var gold: int = 0
	if save_mgr != null:
		var g_v: Variant = save_mgr.get("meta_gold")
		gold = g_v if g_v is int else 0
	if _gold_label != null:
		_gold_label.text = "Gold: %d" % gold

	var btns: Array[Button] = [_bolt_btn, _aura_btn]
	for i: int in range(mini(UNLOCK_ITEMS.size(), btns.size())):
		var btn: Button = btns[i]
		if btn == null:
			continue
		var item: Dictionary = UNLOCK_ITEMS[i]
		var wid: String = str(item.get("id", ""))
		var wname: String = str(item.get("name", ""))
		var price_v: Variant = item.get("price", 0)
		var price: int = price_v if price_v is int else 0
		var owned: bool = false
		if save_mgr != null and save_mgr.has_method("is_unlocked"):
			owned = save_mgr.call("is_unlocked", wid) == true
		if owned:
			btn.text = "%s\nOwned" % wname
			btn.disabled = true
		else:
			btn.text = "%s\n%d Gold" % [wname, price]
			btn.disabled = gold < price


func _on_buy_pressed(index: int) -> void:
	if index < 0 or index >= UNLOCK_ITEMS.size():
		return
	var save_mgr: Node = get_tree().root.get_node_or_null("SaveManager")
	if save_mgr == null:
		return
	var item: Dictionary = UNLOCK_ITEMS[index]
	var wid: String = str(item.get("id", ""))
	var price_v: Variant = item.get("price", 0)
	var price: int = price_v if price_v is int else 0
	if save_mgr.call("try_purchase_unlock", wid, price) == true:
		refresh()
