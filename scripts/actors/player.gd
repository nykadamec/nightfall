class_name Player
extends CharacterBody2D
## Playable character controlled via Input Map actions in isometric 2D space.

@export var move_speed: float = 185.0
@export var acceleration: float = 1350.0
@export var friction: float = 1650.0
@export var iso_y_scale: float = 0.75
@export var invuln_duration: float = 0.6
@export var camera_look_ahead: float = 24.0
@export var camera_look_smooth: float = 4.5

var _invuln_timer: float = 0.0
var _is_dead: bool = false
var _facing_back: bool = false
var _last_step_frame: int = -1
var _bob_phase: float = 0.0
var _shake_strength: float = 0.0

@onready var _anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _shadow: Sprite2D = get_node_or_null("Shadow") as Sprite2D
@onready var _camera: Camera2D = get_node_or_null("Camera2D") as Camera2D
@onready var _hurtbox: Area2D = $Hurtbox


func _ready() -> void:
	add_to_group("player")
	if _hurtbox != null:
		_hurtbox.area_entered.connect(_on_hurtbox_area_entered)


func _physics_process(delta: float) -> void:
	if _invuln_timer > 0.0:
		_invuln_timer = maxf(0.0, _invuln_timer - delta)

	if not _is_dead:
		var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		apply_move(input_dir, delta)
		_update_visual(input_dir, delta)
		_update_camera(delta)
		_check_overlapping_hitboxes()


## Applies isometric-scaled acceleration/friction and calls move_and_slide().
func apply_move(direction: Vector2, delta: float) -> void:
	if direction == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		_last_step_frame = -1
	else:
		var dir: Vector2 = direction.normalized()
		var target_vel: Vector2 = Vector2(dir.x, dir.y * iso_y_scale) * move_speed
		velocity = velocity.move_toward(target_vel, acceleration * delta)
	move_and_slide()


## Helper for headless CI tests to move the player without real input events.
func apply_move_for_test(direction: Vector2, delta: float) -> void:
	apply_move(direction, delta)


## Applies contact damage if not currently invulnerable or dead.
func take_damage(amount: int) -> void:
	if _is_dead or _invuln_timer > 0.0 or amount <= 0:
		return

	_invuln_timer = invuln_duration
	var run_state: Node = get_tree().root.get_node_or_null("RunState")
	var event_bus: Node = get_tree().root.get_node_or_null("EventBus")
	if run_state == null:
		return

	var hp_val: Variant = run_state.get("hp")
	var max_hp_val: Variant = run_state.get("max_hp")
	var current_hp: int = hp_val if hp_val is int else 0
	var max_hp: int = max_hp_val if max_hp_val is int else 100
	current_hp = maxi(0, current_hp - amount)
	run_state.set("hp", current_hp)

	if event_bus != null:
		event_bus.emit_signal("player_hurt", current_hp, max_hp)
	if _anim_sprite != null:
		HitFeedback.flash_node(_anim_sprite, 0.12)
	add_camera_shake(4.5)
	if is_inside_tree():
		HitFeedback.spawn_damage_number(get_tree(), global_position, amount, true)

	if current_hp <= 0:
		_is_dead = true
		velocity = Vector2.ZERO
		if _anim_sprite != null:
			_anim_sprite.stop()
		if event_bus != null:
			event_bus.emit_signal("player_died")


func add_camera_shake(amount: float) -> void:
	_shake_strength = minf(12.0, _shake_strength + maxf(0.0, amount))


func _update_camera(delta: float) -> void:
	if _camera == null:
		return
	var target_offset: Vector2 = Vector2.ZERO
	if velocity.length_squared() > 100.0:
		target_offset = (velocity / move_speed) * camera_look_ahead
	var base_offset: Vector2 = _camera.offset.lerp(target_offset, clampf(camera_look_smooth * delta, 0.0, 1.0))
	if _shake_strength > 0.01:
		_shake_strength = maxf(0.0, _shake_strength - 22.0 * delta)
		var jitter: Vector2 = Vector2(
			randf_range(-_shake_strength, _shake_strength),
			randf_range(-_shake_strength, _shake_strength)
		)
		_camera.offset = base_offset + jitter
	else:
		_shake_strength = 0.0
		_camera.offset = base_offset


func _update_visual(input_dir: Vector2, delta: float) -> void:
	if _anim_sprite == null:
		return

	if input_dir.y < -0.1:
		_facing_back = true
	elif input_dir.y > 0.1:
		_facing_back = false

	if absf(input_dir.x) > 0.1:
		_anim_sprite.flip_h = input_dir.x < 0.0

	var speed_ratio: float = clampf(velocity.length() / move_speed, 0.0, 1.0)
	var is_moving: bool = input_dir != Vector2.ZERO or speed_ratio > 0.08
	var target_anim: StringName
	if not is_moving:
		target_anim = &"idle_ne" if _facing_back else &"idle_se"
		_anim_sprite.speed_scale = 1.0
		_anim_sprite.rotation = lerpf(_anim_sprite.rotation, 0.0, clampf(12.0 * delta, 0.0, 1.0))
		_anim_sprite.scale = _anim_sprite.scale.lerp(Vector2.ONE, clampf(12.0 * delta, 0.0, 1.0))
		if _shadow != null:
			_shadow.scale = _shadow.scale.lerp(Vector2(0.85, 0.75), clampf(12.0 * delta, 0.0, 1.0))
	else:
		target_anim = &"walk_ne" if _facing_back else &"walk_se"
		_anim_sprite.speed_scale = clampf(speed_ratio * 1.1, 0.45, 1.15)
		_bob_phase += delta * (10.0 * speed_ratio + 4.0)
		var target_tilt: float = (velocity.x / move_speed) * 0.045
		_anim_sprite.rotation = lerpf(_anim_sprite.rotation, target_tilt, clampf(10.0 * delta, 0.0, 1.0))
		var squash: float = sin(_bob_phase * 2.0) * 0.03 * speed_ratio
		_anim_sprite.scale = Vector2(1.0 - squash, 1.0 + squash)
		var frame_idx: int = _anim_sprite.frame
		if _shadow != null:
			var stride_squash: float = 0.07 if (frame_idx == 1 or frame_idx == 3) else 0.0
			_shadow.scale = Vector2(0.85 - stride_squash, 0.75 - stride_squash * 0.5)
		if (frame_idx == 0 or frame_idx == 2) and frame_idx != _last_step_frame:
			_last_step_frame = frame_idx
			_spawn_footstep_dust()

	if _anim_sprite.animation != target_anim:
		_anim_sprite.play(target_anim)


func _spawn_footstep_dust() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return
	var puff := Polygon2D.new()
	puff.polygon = PackedVector2Array([
		Vector2(-4, -2),
		Vector2(0, -4),
		Vector2(4, -2),
		Vector2(0, 1),
	])
	puff.color = Color(0.72, 0.68, 0.62, 0.35)
	puff.global_position = global_position + Vector2(randf_range(-5.0, 5.0), randf_range(-2.0, 2.0))
	puff.z_index = -1
	parent_node.add_child(puff)
	var tween: Tween = puff.create_tween()
	tween.set_parallel(true)
	tween.tween_property(puff, "scale", Vector2(1.8, 1.5), 0.28)
	tween.tween_property(puff, "modulate:a", 0.0, 0.28)
	tween.chain().tween_callback(puff.queue_free)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		var hitbox: Hitbox = area as Hitbox
		take_damage(hitbox.damage)


func _check_overlapping_hitboxes() -> void:
	if _invuln_timer > 0.0 or _hurtbox == null:
		return
	for area: Area2D in _hurtbox.get_overlapping_areas():
		if area is Hitbox:
			var hitbox: Hitbox = area as Hitbox
			take_damage(hitbox.damage)
			return
