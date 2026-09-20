extends Node

signal room_changed(room_path: String)
signal interacted(object_id: String)
signal game_saved(slot: int)
signal game_loaded(slot: int)

const PROJECT_ROOT := "res://drs_project"
const DIALOGUE_STYLE_LIGHT := "light_world"
const DIALOGUE_STYLE_DARK := "dark_world"
const LIGHT_DIALOGUE_TEXTURE_PATH := "res://runtime/dialogue/light_world.png"
const DARK_DIALOGUE_TEXTURE_PATH := "res://runtime/dialogue/dark_world.png"

var _runtime: Node
var _bgm_player: AudioStreamPlayer
var _secondary_bgm_player: AudioStreamPlayer
var _dialogue_layer: CanvasLayer
var _dialogue_box: TextureRect
var _dialogue_label: Label
var _light_dialogue_texture: Texture2D
var _dark_dialogue_texture: Texture2D
var _controlled_character_id := ""
var _control_speed := -1.0
var _control_suspended := false
var _dialogue_active := false
var _interaction_character_id := ""
var _interaction_distance := 48.0
var _interactables: Dictionary = {}
var _interaction_counts: Dictionary = {}
var _flags: Dictionary = {}
var _values: Dictionary = {}
var _dialogue_portrait: TextureRect
var _overlay_layer: CanvasLayer
var _overlay_image: TextureRect
var _effect_layer: CanvasLayer
var _effect_rect: ColorRect
var _registered_save_points: Array[String] = []

func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGM"
	add_child(_bgm_player)
	_secondary_bgm_player = AudioStreamPlayer.new()
	_secondary_bgm_player.name = "BGMSecondary"
	add_child(_secondary_bgm_player)

func register_runtime(runtime: Node) -> void:
	_runtime = runtime
	refresh_save_points()

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

func _process(_delta: float) -> void:
	if _dialogue_active or _interaction_character_id.is_empty():
		return
	if Input.is_action_just_pressed("ui_accept"):
		_try_interaction()

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

func teleport(character_id: String, position: Vector2) -> void:
	var host := await _runtime_host()
	host.drs_teleport_character(character_id, position)

func set_animation(
	character_id: String,
	animation_name: String,
	direction: String = ""
) -> void:
	var host := await _runtime_host()
	host.drs_set_character_animation(character_id, animation_name, direction)

func clear_animation(character_id: String) -> void:
	var host := await _runtime_host()
	host.drs_clear_character_animation(character_id)

func set_expression(
	character_id: String,
	expression_name: String,
	duration: float = 0.0
) -> void:
	await set_animation(character_id, expression_name)
	if duration > 0.0:
		await wait(duration)
		await clear_animation(character_id)

func set_character_visible(character_id: String, visible: bool) -> void:
	var host := await _runtime_host()
	host.drs_set_character_visible(character_id, visible)

func follow(follower_id: String, target_id: String, distance: float = 48.0) -> void:
	var host := await _runtime_host()
	host.drs_follow(follower_id, target_id, distance)

func stop_follow(follower_id: String) -> void:
	var host := await _runtime_host()
	host.drs_stop_follow(follower_id)

func enable_player_control(character_id: String, speed: float = -1.0) -> void:
	if character(character_id) == null:
		push_error("DRS character was not found: " + character_id)
		return
	_controlled_character_id = character_id
	_control_speed = speed
	if _interaction_character_id.is_empty():
		enable_interaction(character_id)

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
	await _show_dialogue(
		text,
		auto_close_seconds,
		characters_per_second,
		style,
		""
	)

func say_portrait(
	text: String,
	portrait_asset: String,
	style: String = DIALOGUE_STYLE_DARK,
	auto_close_seconds: float = 0.0,
	characters_per_second: float = 40.0
) -> void:
	await _show_dialogue(
		text,
		auto_close_seconds,
		characters_per_second,
		style,
		portrait_asset
	)

func _show_dialogue(
	text: String,
	auto_close_seconds: float,
	characters_per_second: float,
	style: String,
	portrait_asset: String
) -> void:
	_ensure_dialogue()
	_apply_dialogue_style(style)
	_apply_dialogue_portrait(portrait_asset)
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
	_apply_dialogue_portrait("")

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

func choice(
	options: Array[String],
	style: String = DIALOGUE_STYLE_LIGHT
) -> int:
	if options.is_empty():
		return -1
	_ensure_dialogue()
	_apply_dialogue_style(style)
	_apply_dialogue_portrait("")
	_dialogue_active = true
	_dialogue_layer.visible = true
	var selected := 0
	while true:
		_dialogue_label.text = _choice_text(options, selected)
		_dialogue_label.visible_characters = -1
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_up"):
			selected = wrapi(selected - 1, 0, options.size())
		elif Input.is_action_just_pressed("ui_down"):
			selected = wrapi(selected + 1, 0, options.size())
		elif Input.is_action_just_pressed("ui_accept"):
			break
	_dialogue_layer.visible = false
	_dialogue_active = false
	return selected

func _choice_text(options: Array[String], selected: int) -> String:
	var lines: Array[String] = []
	for index in range(options.size()):
		lines.append(("> " if index == selected else "  ") + options[index])
	return "\n".join(lines)

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

func camera_follow(object_id: String) -> void:
	var host := await _runtime_host()
	host.drs_camera_follow(object_id)

func camera_focus(target: Vector2, duration: float = 0.0) -> void:
	var host := await _runtime_host()
	await host.drs_camera_focus(target, duration)

func camera_zoom(scale: float, duration: float = 0.0) -> void:
	var host := await _runtime_host()
	await host.drs_camera_zoom(scale, duration)

func camera_shake(strength: float, duration: float) -> void:
	var host := await _runtime_host()
	await host.drs_camera_shake(strength, duration)

func camera_reset() -> void:
	var host := await _runtime_host()
	host.drs_camera_reset()

func show(object_id: String) -> void:
	var host := await _runtime_host()
	host.drs_set_object_visible(object_id, true)

func hide(object_id: String) -> void:
	var host := await _runtime_host()
	host.drs_set_object_visible(object_id, false)

func remove(object_id: String) -> void:
	var host := await _runtime_host()
	host.drs_remove_object(object_id)

func set_texture(object_id: String, asset: String) -> void:
	var host := await _runtime_host()
	host.drs_set_object_texture(object_id, asset)

func move_object(object_id: String, target: Vector2, speed: float = 160.0) -> void:
	var host := await _runtime_host()
	await host.drs_move_object(object_id, target, speed)

func set_door_enabled(object_id: String, enabled: bool) -> void:
	var host := await _runtime_host()
	host.drs_set_door_enabled(object_id, enabled)

func set_trigger_enabled(object_id: String, enabled: bool) -> void:
	var host := await _runtime_host()
	host.drs_set_trigger_enabled(object_id, enabled)

func set_flag(name: String, enabled: bool = true) -> void:
	_flags[name] = enabled

func flag(name: String) -> bool:
	return bool(_flags.get(name, false))

func set_value(name: String, value: Variant) -> void:
	_values[name] = value

func value(name: String, fallback: Variant = null) -> Variant:
	return _values.get(name, fallback)

func add_value(name: String, amount: float) -> float:
	var result := float(_values.get(name, 0.0)) + amount
	_values[name] = result
	return result

func debug_state() -> Dictionary:
	var state := {
		"flags": _flags.duplicate(true),
		"values": _values.duplicate(true),
	}
	if is_instance_valid(_runtime):
		if _runtime.has_method("drs_current_room"):
			state["room"] = _runtime.call("drs_current_room")
		if _runtime.has_method("drs_debug_character_positions"):
			state["characters"] = _runtime.call("drs_debug_character_positions")
	return state

func save_game(slot: int = -1) -> bool:
	var host := await _runtime_host()
	var resolved_slot := _resolved_save_slot(slot)
	var data := {
		"formatVersion": 1,
		"flags": _flags,
		"values": _values,
		"controlledCharacter": _controlled_character_id,
		"runtime": host.drs_capture_save_state(),
	}
	var directory := _save_directory(host.drs_project_id())
	var absolute_directory := ProjectSettings.globalize_path(directory)
	var error := DirAccess.make_dir_recursive_absolute(absolute_directory)
	if error != OK:
		push_error("DRS save directory could not be created: %s" % error_string(error))
		return false
	var file := FileAccess.open(_save_path(host.drs_project_id(), resolved_slot), FileAccess.WRITE)
	if file == null:
		push_error("DRS save file could not be opened: %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(data, "  "))
	game_saved.emit(resolved_slot)
	return true

func load_game(slot: int = -1) -> bool:
	var host := await _runtime_host()
	var resolved_slot := _resolved_save_slot(slot)
	var path := _save_path(host.drs_project_id(), resolved_slot)
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is not Dictionary:
		push_error("DRS save file is invalid: " + path)
		return false
	var data: Dictionary = parsed
	_flags = data.get("flags", {}).duplicate(true)
	_values = data.get("values", {}).duplicate(true)
	await host.drs_restore_save_state(data.get("runtime", {}))
	_controlled_character_id = String(data.get("controlledCharacter", ""))
	if not _controlled_character_id.is_empty():
		_interaction_character_id = _controlled_character_id
	game_loaded.emit(resolved_slot)
	return true

func has_save(slot: int = -1) -> bool:
	if _runtime == null:
		return false
	return FileAccess.file_exists(
		_save_path(_runtime.drs_project_id(), _resolved_save_slot(slot))
	)

func delete_save(slot: int = -1) -> bool:
	if _runtime == null:
		return false
	var path := _save_path(_runtime.drs_project_id(), _resolved_save_slot(slot))
	if not FileAccess.file_exists(path):
		return true
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK

func refresh_save_points() -> void:
	if _runtime == null:
		return
	for object_id in _registered_save_points:
		unregister_interactable(object_id)
	_registered_save_points.clear()
	for node in get_tree().get_nodes_in_group("drs_save_point"):
		var object_id := String(node.get_meta("object_id", ""))
		if object_id.is_empty():
			continue
		var slot := clampi(int(node.get_meta("save_slot", 1)), 1, 3)
		register_interactable(object_id, _save_from_point.bind(slot), 56.0, false)
		_registered_save_points.append(object_id)

func _save_from_point(slot: int) -> void:
	if await save_game(slot):
		await flash(Color(1.0, 0.9, 0.35, 0.65), 0.12)

func _save_directory(project_id: String) -> String:
	return "user://saves/" + project_id.validate_filename()

func _save_path(project_id: String, slot: int) -> String:
	return _save_directory(project_id).path_join("slot_%d.json" % slot)

func _resolved_save_slot(slot: int) -> int:
	if slot > 0:
		return clampi(slot, 1, 3)
	if is_instance_valid(_runtime):
		var settings: Dictionary = _runtime.project_data.get("gameSettings", {})
		return clampi(int(settings.get("defaultSaveSlot", 1)), 1, 3)
	return 1

func enable_interaction(character_id: String, distance: float = 48.0) -> void:
	if character(character_id) == null:
		push_error("DRS character was not found: " + character_id)
		return
	_interaction_character_id = character_id
	_interaction_distance = maxf(distance, 1.0)

func disable_interaction() -> void:
	_interaction_character_id = ""

func register_interactable(
	object_id: String,
	callback: Callable,
	distance: float = -1.0,
	require_facing: bool = false
) -> void:
	_interactables[object_id] = {
		"callback": callback,
		"distance": distance,
		"require_facing": require_facing,
	}

func unregister_interactable(object_id: String) -> void:
	_interactables.erase(object_id)

func wait_for_interaction(object_id: String) -> void:
	var initial_count := int(_interaction_counts.get(object_id, 0))
	while int(_interaction_counts.get(object_id, 0)) == initial_count:
		await get_tree().process_frame

func _try_interaction() -> void:
	if _runtime == null:
		return
	var character_node := character(_interaction_character_id)
	if character_node == null:
		return
	var best_id := ""
	var best_distance := INF
	for object_variant in _interactables.keys():
		var object_id := String(object_variant)
		var position: Vector2 = _runtime.drs_object_position(object_id)
		if not position.is_finite():
			continue
		var settings: Dictionary = _interactables[object_id]
		var maximum := float(settings.get("distance", -1.0))
		if maximum <= 0.0:
			maximum = _interaction_distance
		var distance := character_node.position.distance_to(position)
		if distance > maximum or distance >= best_distance:
			continue
		if bool(settings.get("require_facing", false)):
			if not _is_facing_position(character_node, position):
				continue
		best_id = object_id
		best_distance = distance
	if best_id.is_empty():
		return
	_interaction_counts[best_id] = int(_interaction_counts.get(best_id, 0)) + 1
	interacted.emit(best_id)
	var callback: Callable = _interactables[best_id].get("callback", Callable())
	if callback.is_valid():
		callback.call()

func _is_facing_position(character_node: CharacterBody2D, target: Vector2) -> bool:
	var offset := target - character_node.position
	var facing := String(character_node.get_meta("facing", "down"))
	return match_facing(offset, facing)

func match_facing(offset: Vector2, facing: String) -> bool:
	if offset.is_zero_approx():
		return true
	if absf(offset.x) > absf(offset.y):
		return facing == ("right" if offset.x > 0.0 else "left")
	return facing == ("down" if offset.y > 0.0 else "up")

func fade_out(duration: float = 0.25, color: Color = Color.BLACK) -> void:
	_ensure_effect_layers()
	_effect_rect.color = Color(color.r, color.g, color.b, 0.0)
	_effect_rect.visible = true
	await _tween_effect_alpha(color.a, duration)

func fade_in(duration: float = 0.25) -> void:
	_ensure_effect_layers()
	_effect_rect.visible = true
	if _effect_rect.color.a <= 0.0:
		_effect_rect.color.a = 1.0
	await _tween_effect_alpha(0.0, duration)
	_effect_rect.visible = false

func flash(color: Color = Color.WHITE, duration: float = 0.15) -> void:
	_ensure_effect_layers()
	_effect_rect.color = color
	_effect_rect.visible = true
	await _tween_effect_alpha(0.0, duration)
	_effect_rect.visible = false

func show_image(
	asset: String,
	duration: float = 0.0,
	position: Vector2 = Vector2.ZERO,
	size: Vector2 = Vector2.ZERO
) -> void:
	_ensure_effect_layers()
	var texture := _load_project_texture(asset)
	if texture == null:
		return
	_overlay_image.texture = texture
	var resolved_size := size
	if resolved_size.x <= 0.0 or resolved_size.y <= 0.0:
		resolved_size = Vector2(texture.get_width(), texture.get_height())
	_overlay_image.size = resolved_size
	_overlay_image.position = position if position != Vector2.ZERO else (
		Vector2(320, 240) - resolved_size / 2.0
	)
	_overlay_image.visible = true
	if duration > 0.0:
		await wait(duration)
		hide_image()

func hide_image() -> void:
	if _overlay_image != null:
		_overlay_image.visible = false

func _ensure_effect_layers() -> void:
	if _overlay_layer != null:
		return
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 800
	add_child(_overlay_layer)
	_overlay_image = TextureRect.new()
	_overlay_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_overlay_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_overlay_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_overlay_image.visible = false
	_overlay_layer.add_child(_overlay_image)
	_effect_layer = CanvasLayer.new()
	_effect_layer.layer = 1200
	add_child(_effect_layer)
	_effect_rect = ColorRect.new()
	_effect_rect.position = Vector2.ZERO
	_effect_rect.size = Vector2(640, 480)
	_effect_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_effect_rect.visible = false
	_effect_layer.add_child(_effect_rect)

func _tween_effect_alpha(alpha: float, duration: float) -> void:
	if duration <= 0.0:
		_effect_rect.color.a = alpha
		return
	var tween := create_tween()
	tween.tween_property(_effect_rect, "color:a", alpha, duration)
	await tween.finished

func play_bgm(
	asset: String,
	volume_db: float = 0.0,
	fade_seconds: float = 0.0
) -> void:
	var stream := _load_audio(asset)
	if stream == null:
		return
	_set_loop(stream, true)
	_bgm_player.stop()
	_bgm_player.stream = stream
	_bgm_player.volume_db = -60.0 if fade_seconds > 0.0 else volume_db
	_bgm_player.play()
	if fade_seconds > 0.0:
		var tween := create_tween()
		tween.tween_property(_bgm_player, "volume_db", volume_db, fade_seconds)

func crossfade_bgm(
	asset: String,
	duration: float = 1.0,
	volume_db: float = 0.0
) -> void:
	var stream := _load_audio(asset)
	if stream == null:
		return
	_set_loop(stream, true)
	_secondary_bgm_player.stop()
	_secondary_bgm_player.stream = stream
	_secondary_bgm_player.volume_db = -60.0
	_secondary_bgm_player.play()
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_bgm_player, "volume_db", -60.0, duration)
	tween.tween_property(_secondary_bgm_player, "volume_db", volume_db, duration)
	await tween.finished
	_bgm_player.stop()
	var previous := _bgm_player
	_bgm_player = _secondary_bgm_player
	_secondary_bgm_player = previous

func set_bgm_volume(volume_db: float) -> void:
	_bgm_player.volume_db = volume_db

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

func play_sound_at(
	asset: String,
	position: Vector2,
	volume_db: float = 0.0
) -> void:
	var stream := _load_audio(asset)
	if stream == null:
		return
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.position = position
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
	_dialogue_portrait = TextureRect.new()
	_dialogue_portrait.position = Vector2(58, 322)
	_dialogue_portrait.size = Vector2(88, 104)
	_dialogue_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_dialogue_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_dialogue_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_dialogue_layer.add_child(_dialogue_portrait)
	_dialogue_label = Label.new()
	_dialogue_label.position = Vector2(58, 326)
	_dialogue_label.size = Vector2(524, 96)
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_label.add_theme_font_size_override("font_size", 22)
	_dialogue_label.add_theme_color_override("font_color", Color.WHITE)
	_dialogue_layer.add_child(_dialogue_label)
	_dialogue_layer.visible = false

func _apply_dialogue_portrait(asset: String) -> void:
	if asset.is_empty():
		_dialogue_portrait.texture = null
		_dialogue_portrait.visible = false
		_dialogue_label.position = Vector2(58, 326)
		_dialogue_label.size = Vector2(524, 96)
		return
	_dialogue_portrait.texture = _load_project_texture(asset)
	_dialogue_portrait.visible = _dialogue_portrait.texture != null
	_dialogue_label.position = Vector2(160, 326)
	_dialogue_label.size = Vector2(422, 96)

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
	var settings: Dictionary = {}
	if is_instance_valid(_runtime):
		settings = _runtime.project_data.get("gameSettings", {})
	var direction := Vector2.ZERO
	if bool(settings.get("enableArrowKeys", true)):
		direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if bool(settings.get("enableWasd", true)) and Input.is_physical_key_pressed(KEY_A):
		direction.x -= 1.0
	if bool(settings.get("enableWasd", true)) and Input.is_physical_key_pressed(KEY_D):
		direction.x += 1.0
	if bool(settings.get("enableWasd", true)) and Input.is_physical_key_pressed(KEY_W):
		direction.y -= 1.0
	if bool(settings.get("enableWasd", true)) and Input.is_physical_key_pressed(KEY_S):
		direction.y += 1.0
	return direction.normalized() if direction.length_squared() > 1.0 else direction

func _load_runtime_texture(resource_path: String) -> Texture2D:
	if ResourceLoader.exists(resource_path):
		var texture := load(resource_path) as Texture2D
		if texture != null:
			return texture
	var file_path := ProjectSettings.globalize_path(resource_path)
	var image := Image.load_from_file(file_path)
	if image == null or image.is_empty():
		push_error("DRS runtime texture could not be loaded: " + resource_path)
		return null
	return ImageTexture.create_from_image(image)

func _load_project_texture(asset: String) -> Texture2D:
	return _load_runtime_texture(PROJECT_ROOT.path_join(asset))

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
