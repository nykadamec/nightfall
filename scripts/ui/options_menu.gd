class_name OptionsMenu
extends Control

## Options overlay for fullscreen toggle and master volume persisted via SaveManager.

signal closed

@onready var _fullscreen_check: CheckBox = $CenterContainer/Panel/Margin/VBox/FullscreenRow/FullscreenCheck
@onready var _volume_slider: HSlider = $CenterContainer/Panel/Margin/VBox/VolumeRow/VolumeSlider
@onready var _volume_value_label: Label = $CenterContainer/Panel/Margin/VBox/VolumeRow/VolumeValueLabel
@onready var _back_button: Button = $CenterContainer/Panel/Margin/VBox/BackButton

var _syncing_ui: bool = false


func _ready() -> void:
	visible = false
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	_volume_slider.value_changed.connect(_on_volume_changed)
	_back_button.pressed.connect(close_menu)
	_sync_from_save()


func open_menu() -> void:
	_sync_from_save()
	visible = true


func close_menu() -> void:
	visible = false
	closed.emit()


func set_fullscreen(enabled: bool) -> void:
	SaveManager.fullscreen = enabled
	SaveManager.apply_settings()
	SaveManager.save_data()
	_sync_from_save()


func set_master_volume(volume: float) -> void:
	var clamped: float = clampf(volume, 0.0, 1.0)
	SaveManager.master_volume = clamped
	SaveManager.apply_settings()
	SaveManager.save_data()
	_sync_from_save()


func _sync_from_save() -> void:
	_syncing_ui = true
	_fullscreen_check.button_pressed = SaveManager.fullscreen
	var clamped_vol: float = clampf(SaveManager.master_volume, 0.0, 1.0)
	_volume_slider.value = clamped_vol
	var pct: int = roundi(clamped_vol * 100.0)
	_volume_value_label.text = "%d%%" % pct
	_syncing_ui = false


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if _syncing_ui:
		return
	set_fullscreen(toggled_on)


func _on_volume_changed(value: float) -> void:
	if _syncing_ui:
		return
	set_master_volume(value)
