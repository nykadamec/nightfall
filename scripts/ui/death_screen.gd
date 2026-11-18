class_name DeathScreen
extends Control
## Run summary overlay shown on death or victory, with Retry and Menu buttons.

const MAIN_MENU_SCENE_PATH: String = "res://ui/main_menu/main_menu.tscn"

@onready var _title_label: Label = $CenterContainer/Panel/Margin/VBox/TitleLabel
@onready var _summary_label: Label = $CenterContainer/Panel/Margin/VBox/SummaryLabel
@onready var _retry_button: Button = $CenterContainer/Panel/Margin/VBox/RetryButton
@onready var _menu_button: Button = $CenterContainer/Panel/Margin/VBox/MenuButton

var last_cause: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false
	if _retry_button != null:
		_retry_button.pressed.connect(retry)
	if _menu_button != null:
		_menu_button.pressed.connect(go_to_menu)
	var bus: Node = get_tree().root.get_node_or_null("EventBus")
	if bus != null:
		bus.connect("player_died", _on_player_died)
		bus.connect("boss_died", _on_boss_died)


func _on_player_died() -> void:
	_show_summary("YOU DIED", Color(0.92, 0.28, 0.3, 1.0), "death")


func _on_boss_died() -> void:
	_show_summary("VICTORY!", Color(0.96, 0.84, 0.48, 1.0), "victory")


func _show_summary(title_text: String, title_color: Color, cause: String) -> void:
	last_cause = cause
	if _title_label != null:
		_title_label.text = title_text
		_title_label.add_theme_color_override("font_color", title_color)
	var time_sec: float = 0.0
	var level: int = 1
	var gold: int = 0
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	if run_state != null:
		var t_v: Variant = run_state.get("time_sec")
		var l_v: Variant = run_state.get("level")
		var g_v: Variant = run_state.get("gold")
		time_sec = t_v if t_v is float else 0.0
		level = l_v if l_v is int else 1
		gold = g_v if g_v is int else 0
	var total_sec: int = maxi(0, floori(time_sec))
	var mins: int = total_sec / 60
	var secs: int = total_sec % 60
	if _summary_label != null:
		_summary_label.text = "Survived %02d:%02d  ·  Level %d  ·  Gold +%d\nCause: %s" % [mins, secs, level, gold, cause]
	visible = true
	get_tree().paused = true
	if _retry_button != null:
		_retry_button.grab_focus()


func retry() -> void:
	visible = false
	get_tree().paused = false
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	if run_state != null and run_state.has_method("reset"):
		run_state.call("reset")
	if get_tree().current_scene != null:
		get_tree().reload_current_scene()


func go_to_menu() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
