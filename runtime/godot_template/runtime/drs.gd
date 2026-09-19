extends Node

signal room_changed(room_path: String)

const PROJECT_ROOT := "res://drs_project"
const DIALOGUE_STYLE_LIGHT := "light_world"
const DIALOGUE_STYLE_DARK := "dark_world"
const LIGHT_DIALOGUE_TEXTURE_PATH := "res://runtime/dialogue/light_world.png"
const DARK_DIALOGUE_TEXTURE_PATH := "res://runtime/dialogue/dark_world.png"

var _runtime: Node
var _bgm_player: AudioStreamPlayer
var _dialogue_layer: CanvasLayer
var _dialogue_box: TextureRect
var _dialogue_label: Label
var _light_dialogue_texture: Texture2D
var _dark_dialogue_texture: Texture2D
var _controlled_character_id := ""
var _control_speed := -1.0
var _control_suspended := false
var _dialogue_active := false

func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGM"
	add_child(_bgm_player)

func register_runtime(runtime: Node) -> void:
	_runtime = runtime

func _physics_process(delta: float) -> void:
	if _runtime == null or _controlled_character_id.is_empty():
		return
	var direction := Vector2.ZERO
	if not _control_suspended and not _dialogue_active:
		direction = _player_input_direction()
	_runtime.drs_control_character(
		_controlled_character_id,
		direction,
		_control_speed,
		delta
	)

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
	var suspend_control := character_id == _controlled_character_id
	if suspend_control:
		_control_suspended = true
	await host.drs_move_character(character_id, target, speed)
	if suspend_control:
		_control_suspended = false

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

func enable_player_control(character_id: String, speed: float = -1.0) -> void:
	if character(character_id) == null:
		push_error("DRS character was not found: " + character_id)
		return
	_controlled_character_id = character_id
	_control_speed = speed

func disable_player_control() -> void:
	if _runtime != null and not _controlled_character_id.is_empty():
		_runtime.drs_control_character(
			_controlled_character_id,
			Vector2.ZERO,
			_control_speed,
			0.0
		)
	_controlled_character_id = ""
	_control_speed = -1.0

func is_player_control_enabled() -> bool:
	return not _controlled_character_id.is_empty()

func controlled_character_id() -> String:
	return _controlled_character_id

func set_player_control_speed(speed: float) -> void:
	_control_speed = speed

func say(
	text: String,
	auto_close_seconds: float = 0.0,
	characters_per_second: float = 40.0,
	style: String = DIALOGUE_STYLE_LIGHT
) -> void:
	_ensure_dialogue()
	_apply_dialogue_style(style)
	_dialogue_active = true
	_dialogue_layer.visible = true
	_dialogue_label.text = text
	_dialogue_label.visible_characters = 0
	var character_count := text.length()
	var delay := 1.0 / maxf(characters_per_second, 1.0)
	var index := 0
	while index < character_count:
		if Input.is_action_just_pressed("ui_accept"):
			_dialogue_label.visible_characters = -1
			break
		index += 1
		_dialogue_label.visible_characters = index
		await get_tree().create_timer(delay).timeout
	if auto_close_seconds > 0.0:
		await get_tree().create_timer(auto_close_seconds).timeout
	else:
		await _wait_for_accept()
	_dialogue_layer.visible = false
	_dialogue_active = false

func say_light(
	text: String,
	auto_close_seconds: float = 0.0,
	characters_per_second: float = 40.0
) -> void:
	await say(
		text,
		auto_close_seconds,
		characters_per_second,
		DIALOGUE_STYLE_LIGHT
	)

func say_dark(
	text: String,
	auto_close_seconds: float = 0.0,
	characters_per_second: float = 40.0
) -> void:
	await say(
		text,
		auto_close_seconds,
		characters_per_second,
		DIALOGUE_STYLE_DARK
	)

func hide_dialogue() -> void:
	if _dialogue_layer != null:
		_dialogue_layer.visible = false
	_dialogue_active = false

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
	_dialogue_box = TextureRect.new()
	_dialogue_box.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_dialogue_box.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_dialogue_box.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_dialogue_layer.add_child(_dialogue_box)
	_dialogue_label = Label.new()
	_dialogue_label.position = Vector2(58, 326)
	_dialogue_label.size = Vector2(524, 96)
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_label.add_theme_font_size_override("font_size", 22)
	_dialogue_label.add_theme_color_override("font_color", Color.WHITE)
	_dialogue_layer.add_child(_dialogue_label)
	_dialogue_layer.visible = false

func _apply_dialogue_style(style: String) -> void:
	var dark := style == DIALOGUE_STYLE_DARK or style == "dark"
	if dark:
		if _dark_dialogue_texture == null:
			_dark_dialogue_texture = _load_runtime_texture(DARK_DIALOGUE_TEXTURE_PATH)
		_dialogue_box.texture = _dark_dialogue_texture
		_dialogue_box.position = Vector2(23, 296)
		_dialogue_box.size = Vector2(594, 168)
		_dialogue_label.position = Vector2(58, 326)
		return
	if _light_dialogue_texture == null:
		_light_dialogue_texture = _load_runtime_texture(LIGHT_DIALOGUE_TEXTURE_PATH)
	_dialogue_box.texture = _light_dialogue_texture
	_dialogue_box.position = Vector2(31, 304)
	_dialogue_box.size = Vector2(578, 152)
	_dialogue_label.position = Vector2(58, 326)

func _player_input_direction() -> Vector2:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_physical_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_W):
		direction.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		direction.y += 1.0
	return direction.normalized() if direction.length_squared() > 1.0 else direction

func _load_runtime_texture(resource_path: String) -> Texture2D:
	var file_path := ProjectSettings.globalize_path(resource_path)
	var image := Image.load_from_file(file_path)
	if image == null or image.is_empty():
		push_error("DRS runtime texture could not be loaded: " + resource_path)
		return null
	return ImageTexture.create_from_image(image)

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
