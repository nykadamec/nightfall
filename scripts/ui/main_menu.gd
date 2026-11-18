class_name MainMenu
extends Control
## Gothic main menu with Play, Options (stub until Phase 5), and Quit.

const ARENA_SCENE_PATH: String = "res://scenes/world/main.tscn"

@onready var _play_button: Button = $CenterContainer/Panel/Margin/VBox/PlayButton
@onready var _unlocks_button: Button = $CenterContainer/Panel/Margin/VBox/UnlocksButton
@onready var _options_button: Button = $CenterContainer/Panel/Margin/VBox/OptionsButton
@onready var _quit_button: Button = $CenterContainer/Panel/Margin/VBox/QuitButton
@onready var _gold_label: Label = $TopRight/GoldChip/GoldLabel
@onready var _unlocks_screen: Control = get_node_or_null("UnlocksScreen") as Control
@onready var _options_menu: Control = get_node_or_null("OptionsMenu") as Control


func _ready() -> void:
	get_tree().paused = false
	if _play_button != null:
		_play_button.pressed.connect(play)
		_play_button.grab_focus()
	if _unlocks_button != null:
		_unlocks_button.pressed.connect(open_unlocks)
	if _options_button != null:
		_options_button.disabled = false
		_options_button.pressed.connect(open_options)
	if _quit_button != null:
		_quit_button.pressed.connect(quit_game)
	if _unlocks_screen != null and _unlocks_screen.has_signal("closed"):
		_unlocks_screen.connect("closed", _on_overlay_closed)
	if _options_menu != null and _options_menu.has_signal("closed"):
		_options_menu.connect("closed", _on_overlay_closed)
	_refresh_gold()
	var audio: Node = get_tree().root.get_node_or_null("AudioManager")
	if audio != null and audio.has_method("play_music"):
		audio.call("play_music", "menu")


func _refresh_gold() -> void:
	if _gold_label != null:
		var save_mgr: Node = get_tree().root.get_node_or_null("SaveManager")
		var g: int = 0
		if save_mgr != null:
			var g_v: Variant = save_mgr.get("meta_gold")
			g = g_v if g_v is int else 0
		_gold_label.text = str(g)


func open_unlocks() -> void:
	if _unlocks_screen != null and _unlocks_screen.has_method("open"):
		_unlocks_screen.call("open")


func open_options() -> void:
	if _options_menu != null and _options_menu.has_method("open_menu"):
		_options_menu.call("open_menu")


func _on_overlay_closed() -> void:
	_refresh_gold()
	var audio: Node = get_tree().root.get_node_or_null("AudioManager")
	if audio != null and audio.has_method("play_music"):
		audio.call("play_music", "menu")
	if _play_button != null:
		_play_button.grab_focus()


func play() -> void:
	var audio: Node = get_tree().root.get_node_or_null("AudioManager")
	if audio != null and audio.has_method("play_sfx"):
		audio.call("play_sfx", "click", 0.0)
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	if run_state != null and run_state.has_method("reset"):
		run_state.call("reset")
	get_tree().change_scene_to_file(ARENA_SCENE_PATH)


func quit_game() -> void:
	get_tree().quit()
