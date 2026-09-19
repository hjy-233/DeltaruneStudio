extends Node

signal room_changed(room_path: String)

const PROJECT_ROOT := "res://drs_project"

var _runtime: Node
var _bgm_player: AudioStreamPlayer
var _dialogue_layer: CanvasLayer
var _dialogue_label: Label

func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGM"
	add_child(_bgm_player)

func register_runtime(runtime: Node) -> void:
	_runtime = runtime

func character(character_id: String) -> CharacterBody2D:
	if _runtime == null:
		return null
	return _runtime.drs_find_character(character_id)

func wait(seconds: float) -> void:
	if seconds <= 0.0:
		await get_tree().process_frame
		return
	await get_tree().create_timer(seconds).timeout

func move(
	character_id: String,
	target: Vector2,
	speed: float = -1.0
) -> void:
	var host := await _runtime_host()
	await host.drs_move_character(character_id, target, speed)

func move_by(
	character_id: String,
	offset: Vector2,
	speed: float = -1.0
) -> void:
	var body := character(character_id)
	if body == null:
		push_error("DRS character was not found: " + character_id)
		return
	await move(character_id, body.position + offset, speed)

func face(character_id: String, direction: String) -> void:
	var host := await _runtime_host()
	host.drs_face_character(character_id, direction)

func say(
	text: String,
	auto_close_seconds: float = 0.0,
	characters_per_second: float = 40.0
) -> void:
	_ensure_dialogue()
	_dialogue_layer.visible = true
	_dialogue_label.text = text
	_dialogue_label.visible_characters = 0
	var character_count := text.length()
	var delay := 1.0 / maxf(characters_per_second, 1.0)
	for index in range(character_count):
		_dialogue_label.visible_characters = index + 1
		await get_tree().create_timer(delay).timeout
	if auto_close_seconds > 0.0:
		await get_tree().create_timer(auto_close_seconds).timeout
	else:
		await _wait_for_accept()
	_dialogue_layer.visible = false

func hide_dialogue() -> void:
	if _dialogue_layer != null:
		_dialogue_layer.visible = false

func change_room(
	room_path: String,
	spawn_id: String = "",
	traveler_id: String = ""
) -> void:
	var host := await _runtime_host()
	await host.drs_change_room(room_path, spawn_id, traveler_id)
	room_changed.emit(room_path)

func play_bgm(asset: String, volume_db: float = 0.0) -> void:
	var stream := _load_audio(asset)
	if stream == null:
		return
	_set_loop(stream, true)
	_bgm_player.stop()
	_bgm_player.stream = stream
	_bgm_player.volume_db = volume_db
	_bgm_player.play()

func stop_bgm(fade_seconds: float = 0.0) -> void:
	if not _bgm_player.playing:
		return
	if fade_seconds <= 0.0:
		_bgm_player.stop()
		return
	var start_volume := _bgm_player.volume_db
	var elapsed := 0.0
	while elapsed < fade_seconds and _bgm_player.playing:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		_bgm_player.volume_db = lerpf(start_volume, -60.0, elapsed / fade_seconds)
	_bgm_player.stop()
	_bgm_player.volume_db = start_volume

func play_sound(asset: String, volume_db: float = 0.0) -> void:
	var stream := _load_audio(asset)
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func _runtime_host() -> Node:
	while _runtime == null:
		await get_tree().process_frame
	return _runtime

func _wait_for_accept() -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			return

func _ensure_dialogue() -> void:
	if _dialogue_layer != null:
		return
	_dialogue_layer = CanvasLayer.new()
	_dialogue_layer.layer = 1000
	add_child(_dialogue_layer)
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_left = 24.0
	panel.offset_top = -150.0
	panel.offset_right = -24.0
	panel.offset_bottom = -24.0
	var style := StyleBoxFlat.new()
	style.bg_color = Color.BLACK
	style.border_color = Color.WHITE
	style.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", style)
	_dialogue_layer.add_child(panel)
	_dialogue_label = Label.new()
	_dialogue_label.position = Vector2(24, 20)
	_dialogue_label.size = Vector2(544, 80)
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_label.add_theme_font_size_override("font_size", 22)
	panel.add_child(_dialogue_label)
	_dialogue_layer.visible = false

func _load_audio(asset: String) -> AudioStream:
	var path := PROJECT_ROOT.path_join(asset)
	var stream: AudioStream
	if ResourceLoader.exists(path):
		stream = load(path) as AudioStream
	else:
		stream = _load_audio_file(path)
	if stream == null:
		push_error("DRS audio resource could not be loaded: " + asset)
	return stream

func _load_audio_file(resource_path: String) -> AudioStream:
	var file_path := ProjectSettings.globalize_path(resource_path)
	if not FileAccess.file_exists(file_path):
		return null
	match file_path.get_extension().to_lower():
		"wav":
			return AudioStreamWAV.load_from_file(file_path)
		"mp3":
			return AudioStreamMP3.load_from_file(file_path)
		"ogg":
			return AudioStreamOggVorbis.load_from_file(file_path)
	return null

func _set_loop(stream: AudioStream, enabled: bool) -> void:
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if enabled else AudioStreamWAV.LOOP_DISABLED
	elif stream is AudioStreamMP3:
		stream.loop = enabled
	elif stream is AudioStreamOggVorbis:
		stream.loop = enabled
