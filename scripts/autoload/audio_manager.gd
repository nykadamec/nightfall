extends Node
## Global SFX and music manager. Uses synthesized placeholder AudioStreamWAV tones
## until real CC0/licensed WAV assets are placed in res://assets/audio/.

const SFX_POOL_SIZE: int = 8
const SAMPLE_RATE: int = 22050

var _sfx_streams: Dictionary = {}
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx_idx: int = 0
var _music_streams: Dictionary = {}
var _music_player: AudioStreamPlayer = null
var _current_music: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_sfx_pool()
	_build_music_player()
	_build_placeholder_sfx()
	_build_placeholder_music()
	_connect_event_bus()


func _build_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = &"Master"
	_music_player.volume_db = -14.0
	add_child(_music_player)


func _build_sfx_pool() -> void:
	for i: int in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.bus = &"Master"
		player.volume_db = -8.0
		add_child(player)
		_sfx_players.append(player)


func _build_placeholder_sfx() -> void:
	_sfx_streams["hit"] = _make_tone(220.0, 120.0, 0.08, 0.35)
	_sfx_streams["death"] = _make_tone(180.0, 75.0, 0.18, 0.35)
	_sfx_streams["gem"] = _make_tone(660.0, 990.0, 0.09, 0.25)
	_sfx_streams["level_up"] = _make_tone(440.0, 880.0, 0.28, 0.35)
	_sfx_streams["click"] = _make_tone(520.0, 420.0, 0.04, 0.22)
	_sfx_streams["hurt"] = _make_tone(150.0, 85.0, 0.14, 0.4)
	_sfx_streams["boss"] = _make_tone(95.0, 65.0, 0.42, 0.45)


func _build_placeholder_music() -> void:
	_music_streams["menu"] = _make_loop_drone(110.0, 165.0, 2.0, 0.16)
	_music_streams["run"] = _make_loop_drone(130.81, 196.0, 2.0, 0.18)


func _connect_event_bus() -> void:
	var bus: Node = get_tree().root.get_node_or_null("EventBus")
	if bus == null:
		return
	bus.connect("run_started", _on_run_started)
	bus.connect("xp_collected", _on_xp_collected)
	bus.connect("level_up", _on_level_up)
	bus.connect("player_hurt", _on_player_hurt)
	bus.connect("player_died", _on_player_died)
	bus.connect("enemy_died", _on_enemy_died)
	bus.connect("boss_spawned", _on_boss_spawned)


func play_sfx(sfx_name: String, pitch_jitter: float = 0.05) -> void:
	if not _sfx_streams.has(sfx_name) or _sfx_players.is_empty():
		return
	var stream_v: Variant = _sfx_streams[sfx_name]
	var stream: AudioStream = stream_v if stream_v is AudioStream else null
	if stream == null:
		return
	var player: AudioStreamPlayer = _sfx_players[_next_sfx_idx]
	_next_sfx_idx = (_next_sfx_idx + 1) % _sfx_players.size()
	player.stream = stream
	player.pitch_scale = randf_range(1.0 - pitch_jitter, 1.0 + pitch_jitter)
	player.play()


func has_sfx(sfx_name: String) -> bool:
	return _sfx_streams.has(sfx_name)


func play_music(track_name: String) -> void:
	if _music_player == null or not _music_streams.has(track_name):
		return
	if _current_music == track_name and _music_player.playing:
		return
	var stream_v: Variant = _music_streams[track_name]
	var stream: AudioStream = stream_v if stream_v is AudioStream else null
	if stream == null:
		return
	_current_music = track_name
	_music_player.stream = stream
	_music_player.play()


func stop_music() -> void:
	_current_music = ""
	if _music_player != null:
		_music_player.stop()


func get_current_music() -> String:
	return _current_music


func _on_run_started() -> void:
	play_music("run")


func _on_xp_collected(_amount: int, _total_xp: int) -> void:
	play_sfx("gem", 0.08)


func _on_level_up(_new_level: int) -> void:
	play_sfx("level_up", 0.0)


func _on_player_hurt(_hp: int, _max_hp: int) -> void:
	play_sfx("hurt", 0.04)


func _on_player_died() -> void:
	play_sfx("death", 0.0)


func _on_enemy_died(_pos: Vector2, _xp: int) -> void:
	play_sfx("death", 0.08)


func _on_boss_spawned(_boss_name: String, _max_hp: int) -> void:
	play_sfx("boss", 0.0)


func _make_tone(freq_start: float, freq_end: float, duration_sec: float, gain: float) -> AudioStreamWAV:
	var sample_count: int = maxi(1, int(duration_sec * float(SAMPLE_RATE)))
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var phase: float = 0.0
	for i: int in range(sample_count):
		var t: float = float(i) / float(sample_count)
		var freq: float = lerpf(freq_start, freq_end, t)
		phase += TAU * freq / float(SAMPLE_RATE)
		var env: float = (1.0 - t) * gain
		var sample_f: float = sin(phase) * env
		var sample_i: int = clampi(int(sample_f * 32767.0), -32767, 32767)
		data.encode_s16(i * 2, sample_i)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = data
	return wav


func _make_loop_drone(root_hz: float, fifth_hz: float, duration_sec: float, gain: float) -> AudioStreamWAV:
	var sample_count: int = maxi(1, int(duration_sec * float(SAMPLE_RATE)))
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var root_cycles: float = maxf(1.0, roundf(root_hz * duration_sec))
	var fifth_cycles: float = maxf(1.0, roundf(fifth_hz * duration_sec))
	for i: int in range(sample_count):
		var t: float = float(i) / float(sample_count)
		var pulse: float = 0.7 + 0.3 * sin(TAU * 2.0 * t)
		var sample_f: float = (
			0.65 * sin(TAU * root_cycles * t)
			+ 0.35 * sin(TAU * fifth_cycles * t)
		) * pulse * gain
		var sample_i: int = clampi(int(sample_f * 32767.0), -32767, 32767)
		data.encode_s16(i * 2, sample_i)

	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = sample_count
	wav.data = data
	return wav
