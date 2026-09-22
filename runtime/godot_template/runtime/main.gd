extends Node2D
const PROJECT_ROOT := "res://drs_project"
const DEBUG_OVERLAY_SCRIPT := preload("res://runtime/debug_overlay.gd")
const VARIABLE_DEBUGGER_SCRIPT := preload("res://runtime/variable_debugger.gd")
const PROJECT_CONTENT_RUNTIME_SCRIPT := preload("res://runtime/project_content_runtime.gd")
var project_data: Dictionary = {}
var scene_data: Dictionary = {}
var room_root: Node2D
var _room_changing := false
var _runtime_camera: Camera2D
var _camera_position := Vector2(320, 240)
var _camera_follow_id := ""
var _camera_shake_strength := 0.0
var _camera_shake_remaining := 0.0
var _camera_shake_elapsed := 0.0
var _follow_rules: Dictionary = {}
var _follow_paths: Dictionary = {}
var _current_scene_path := ""
var _view_size := Vector2(640, 480)
var _content_runtime: Node
var _project_script_runner: Node
func _ready() -> void:
	project_data = _read_json(PROJECT_ROOT.path_join("project.json"))
	var game_settings: Dictionary = project_data.get("gameSettings", {})
	_view_size = Vector2(
		maxf(float(game_settings.get("viewportWidth", 640)), 1.0),
		maxf(float(game_settings.get("viewportHeight", 480)), 1.0)
	)
	_camera_position = _view_size / 2.0
	var scene_path: String = project_data.get("mainScene", "scenes/main/scene.json")
	_current_scene_path = scene_path
	scene_data = _read_json(PROJECT_ROOT.path_join(scene_path))
	RenderingServer.set_default_clear_color(Color.BLACK)
	room_root = Node2D.new()
	room_root.name = "Room"
	add_child(room_root)
	_content_runtime = PROJECT_CONTENT_RUNTIME_SCRIPT.new()
	add_child(_content_runtime)
	_content_runtime.setup(self)
	_runtime_camera = Camera2D.new()
	_runtime_camera.name = "RuntimeCamera"
	_runtime_camera.position = _camera_position
	_runtime_camera.enabled = true
	add_child(_runtime_camera)
	_add_scene_visuals()
	_add_runtime_label()
	DRS.register_runtime(self)
	DRS.refresh_scene_interactables()
	var debug_overlay := DEBUG_OVERLAY_SCRIPT.new()
	debug_overlay.name = "DebugOverlay"
	add_child(debug_overlay)
	debug_overlay.setup(self)
	var variable_debugger := VARIABLE_DEBUGGER_SCRIPT.new()
	variable_debugger.name = "VariableDebugger"
	add_child(variable_debugger)
	variable_debugger.setup()
	_run_entry_script.call_deferred()
func drs_current_room() -> String:
	return _current_scene_path

func drs_debug_character_positions() -> Dictionary:
	var characters := {}
	for child in room_root.get_children():
		if child is CharacterBody2D:
			var object_id := String(child.get_meta("object_id", child.name))
			characters[object_id] = {
				"x": child.position.x,
				"y": child.position.y,
				"facing": child.get_meta("facing", "down"),
			}
	return characters

func _process(delta: float) -> void:
	_update_forced_animations(delta)
	_update_runtime_camera(delta)

func _physics_process(delta: float) -> void:
	_update_followers(delta)

func _run_entry_script() -> void:
	var entry_script := String(project_data.get("entryScript", ""))
	if entry_script.is_empty():
		return
	var script_path := PROJECT_ROOT.path_join(entry_script)
	if not ResourceLoader.exists(script_path):
		push_error("DRS entry script was not found: " + entry_script)
		return
	var script := load(script_path) as Script
	if script == null:
		push_error("DRS entry script could not be loaded: " + entry_script)
		return
	var runner := Node.new()
	runner.name = "ProjectScript"
	runner.set_script(script)
	add_child(runner)
	_project_script_runner = runner
	if not runner.has_method("run"):
		push_error("DRS entry script must define func run() -> void")
		return
	runner.call("run")

func drs_call_project_function(function_name: String) -> void:
	if _project_script_runner == null or not is_instance_valid(_project_script_runner):
		return
	if not _project_script_runner.has_method(function_name):
		push_error("DRS project function was not found: " + function_name)
		return
	_project_script_runner.call(function_name)

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("DRS project file not found: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("DRS project file could not be opened: " + path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}

func _add_scene_visuals() -> void:
	_content_runtime.add_tile_map(scene_data, room_root)
	var background: Variant = scene_data.get("background")
	if typeof(background) == TYPE_STRING and not String(background).is_empty():
		_add_sprite(String(background), {
			"type": "background",
			"x": _view_size.x / 2.0,
			"y": _view_size.y / 2.0,
			"width": _view_size.x,
			"height": _view_size.y,
			"zIndex": -1000
		})

	var objects: Array = scene_data.get("objects", [])
	var sorted_objects := _sort_objects(objects)
	for object_variant in sorted_objects:
		if object_variant is Dictionary:
			var object := _resolve_character_object(object_variant)
			if not _layer_visible(object):
				continue
			var object_type := _string_value(object, "type")
			if object_type == "collision":
				_add_collision(object)
				continue
			if object_type == "door":
				_add_door(object)
				continue
			if object_type == "savePoint":
				_add_save_point(object)
				continue
			if object_type == "spawn":
				continue
			var asset := _string_value(object, "asset")
			if asset.is_empty():
				asset = _string_value(object, "resource")
			if not asset.is_empty():
				_add_sprite(asset, object)

func _resolve_character_object(object: Dictionary) -> Dictionary:
	var character_path := _string_value(object, "character")
	if character_path.is_empty():
		return object
	var definition := _read_json(PROJECT_ROOT.path_join(character_path))
	if definition.is_empty():
		return object
	var resolved: Dictionary = object.duplicate(true)
	var frame := _character_preview_frame(definition)
	if not frame.is_empty():
		resolved["asset"] = frame
	if _number_value(resolved, "width", -1.0) <= 0.0:
		resolved["width"] = _number_value(definition, "defaultWidth", -1.0)
	if _number_value(resolved, "height", -1.0) <= 0.0:
		resolved["height"] = _number_value(definition, "defaultHeight", -1.0)
	resolved["collision"] = definition.get("collision", {})
	resolved["moveSpeed"] = definition.get("moveSpeed", 160.0)
	resolved["definition"] = definition
	return resolved

func _character_preview_frame(definition: Dictionary) -> String:
	for animation_name in ["idle", "walk"]:
		var frame := _animation_frame(definition, animation_name, "down")
		if not frame.is_empty():
			return frame
	var animations: Array = definition.get("animations", [])
	for animation_variant in animations:
		if animation_variant is Dictionary:
			var animation: Dictionary = animation_variant
			if _string_value(animation, "direction") == "down":
				var frames: Array = animation.get("frames", [])
				if not frames.is_empty() and frames[0] is String:
					return frames[0]
	for animation_variant in animations:
		if animation_variant is Dictionary:
			var frames: Array = animation_variant.get("frames", [])
			if not frames.is_empty() and frames[0] is String:
				return frames[0]
	return ""

func _animation_frame(
	definition: Dictionary,
	animation_name: String,
	direction: String
) -> String:
	var animations: Array = definition.get("animations", [])
	for animation_variant in animations:
		if animation_variant is Dictionary:
			var animation: Dictionary = animation_variant
			if (
				_string_value(animation, "name") == animation_name
				and _string_value(animation, "direction") == direction
			):
				var frames: Array = animation.get("frames", [])
				if not frames.is_empty() and frames[0] is String:
					return frames[0]
	return ""

func _sort_objects(objects: Array) -> Array:
	var result: Array = []
	for object in objects:
		result.append(object)
	for index in range(1, result.size()):
		var current = result[index]
		var current_z := _render_z(current)
		var position := index - 1
		while position >= 0 and _render_z(result[position]) > current_z:
			result[position + 1] = result[position]
			position -= 1
		result[position + 1] = current
	return result

func _z_index(value: Variant) -> int:
	if value is Dictionary:
		return int(value.get("zIndex", 0))
	return 0

func _render_z(value: Variant) -> int:
	if value is not Dictionary:
		return 0
	var object: Dictionary = value
	var layer_id := _string_value(object, "layer")
	var layers: Array = scene_data.get("layers", [])
	for layer_variant in layers:
		if layer_variant is Dictionary:
			var layer: Dictionary = layer_variant
			if _string_value(layer, "id") == layer_id:
				return int(layer.get("order", 0)) * 1000 + _z_index(object)
	return _z_index(object)

func _layer_visible(object: Dictionary) -> bool:
	var layer_id := _string_value(object, "layer")
	var layers: Array = scene_data.get("layers", [])
	for layer_variant in layers:
		if layer_variant is Dictionary:
			var layer: Dictionary = layer_variant
			if _string_value(layer, "id") == layer_id:
				return bool(layer.get("visible", true))
	return true

func _add_sprite(asset: String, object: Dictionary) -> void:
	var texture := _load_texture(asset)
	if texture == null:
		push_error("DRS asset could not be loaded: " + asset)
		return
	var sprite := Sprite2D.new()
	sprite.texture = texture
	var position := Vector2(
		_number_value(object, "x", _view_size.x / 2.0),
		_number_value(object, "y", _view_size.y / 2.0)
	)
	sprite.z_index = _render_z(object)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_apply_sprite_size(sprite, texture, object)
	if _string_value(object, "type") == "character":
		_add_character(sprite, position, object)
	else:
		sprite.position = position
		if object.get("collision") is Dictionary:
			_content_runtime.add_collidable_sprite(sprite, object, position, room_root)
		else:
			_register_runtime_object(sprite, object)
			room_root.add_child(sprite)

func _add_character(sprite: Sprite2D, position: Vector2, object: Dictionary) -> void:
	var body := CharacterBody2D.new()
	body.name = _string_value(object, "name")
	body.position = position
	body.z_index = _render_z(object)
	body.add_to_group("drs_character")
	body.set_meta("object_id", _string_value(object, "id"))
	body.set_meta("move_speed", _number_value(object, "moveSpeed", 160.0))
	body.set_meta("definition", object.get("definition", {}))
	body.set_meta("facing", _string_value(object, "facing") if object.has("facing") else "down")
	body.set_meta("source_visible", true)
	room_root.add_child(body)
	sprite.z_index = 0
	body.add_child(sprite)
	var collision: Variant = object.get("collision", {})
	if collision is Dictionary:
		_add_collision_shape(body, collision)

func _add_collision(object: Dictionary) -> void:
	var body := StaticBody2D.new()
	body.name = _string_value(object, "name")
	body.position = _rect_center(object)
	room_root.add_child(body)
	_add_rect_shape(body, object)

func _add_door(object: Dictionary) -> void:
	var area := Area2D.new()
	area.name = _string_value(object, "name")
	area.position = _rect_center(object)
	area.set_meta("target_room", _string_value(object, "targetRoom"))
	area.set_meta("target_spawn", _string_value(object, "targetSpawn"))
	area.set_meta("transition_color", _string_value(object, "transitionColor"))
	area.set_meta("fade_out", _number_value(object, "fadeOutSeconds", 0.15))
	area.set_meta("fade_in", _number_value(object, "fadeInSeconds", 0.15))
	_register_runtime_object(area, object)
	area.add_to_group("drs_door")
	room_root.add_child(area)
	_add_rect_shape(area, object)
	area.body_entered.connect(_on_door_body_entered.bind(area))

func _add_save_point(object: Dictionary) -> void:
	_content_runtime.add_save_point(object, room_root)

func _register_runtime_object(node: Node2D, object: Dictionary) -> void:
	var object_id := _string_value(object, "id")
	if object_id.is_empty():
		return
	node.set_meta("object_id", object_id)
	node.set_meta("interaction", object.get("interaction", {}))
	node.add_to_group("drs_object")

func _add_collision_shape(parent: Node2D, collision: Dictionary) -> void:
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(
		maxf(_number_value(collision, "width", 20.0), 1.0),
		maxf(_number_value(collision, "height", 12.0), 1.0)
	)
	shape_node.shape = shape
	shape_node.position = Vector2(
		_number_value(collision, "x", 0.0) + shape.size.x / 2.0,
		_number_value(collision, "y", 0.0) + shape.size.y / 2.0
	)
	parent.add_child(shape_node)

func _add_rect_shape(parent: Node2D, object: Dictionary) -> void:
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(
		maxf(_number_value(object, "width", 32.0), 1.0),
		maxf(_number_value(object, "height", 32.0), 1.0)
	)
	shape_node.shape = shape
	parent.add_child(shape_node)

func _rect_center(object: Dictionary) -> Vector2:
	return Vector2(
		_number_value(object, "x", 0.0) + _number_value(object, "width", 0.0) / 2.0,
		_number_value(object, "y", 0.0) + _number_value(object, "height", 0.0) / 2.0
	)

func _on_door_body_entered(body: Node2D, door: Area2D) -> void:
	if _room_changing or not body.is_in_group("drs_character"):
		return
	var target_room := String(door.get_meta("target_room", ""))
	if target_room.is_empty():
		return
	_transition_room(
		target_room,
		String(door.get_meta("target_spawn", "")),
		body as CharacterBody2D,
		String(door.get_meta("transition_color", "#FF000000")),
		float(door.get_meta("fade_out", 0.15)),
		float(door.get_meta("fade_in", 0.15))
	)

func _transition_room(
	room_path: String,
	spawn_id: String,
	traveler: CharacterBody2D,
	color_value: String,
	fade_out_seconds: float,
	fade_in_seconds: float
) -> void:
	var color := Color.from_string(color_value, Color.BLACK)
	await DRS.fade_out(maxf(fade_out_seconds, 0.0), color)
	await _change_room(room_path, spawn_id, traveler)
	await DRS.fade_in(maxf(fade_in_seconds, 0.0))

func _change_room(
	room_path: String,
	spawn_id: String,
	traveler: CharacterBody2D
) -> void:
	if _room_changing:
		return
	_room_changing = true
	await get_tree().process_frame
	var next_scene := _read_json(PROJECT_ROOT.path_join(room_path))
	if next_scene.is_empty():
		_room_changing = false
		return
	if traveler != null and not is_instance_valid(traveler):
		traveler = null
	var traveler_id := ""
	if traveler != null:
		traveler_id = String(traveler.get_meta("object_id", ""))
		room_root.remove_child(traveler)
	for child in room_root.get_children():
		room_root.remove_child(child)
		child.queue_free()
	scene_data = next_scene
	_current_scene_path = room_path
	_add_scene_visuals()
	DRS.refresh_save_points()
	DRS.refresh_scene_interactables()
	var target := _find_runtime_character(traveler_id)
	if target == null and traveler != null:
		room_root.add_child(traveler)
		target = traveler
	elif traveler != null:
		traveler.queue_free()
	if target != null:
		_apply_spawn(spawn_id, target)
	_reset_follow_paths()
	_room_changing = false

func drs_hot_reload_current_room() -> void:
	await _change_room(_current_scene_path, "", null)

func _reset_follow_paths() -> void:
	_follow_paths.clear()
	for follower_variant in _follow_rules.keys():
		var follower_id := String(follower_variant)
		var rule: Dictionary = _follow_rules[follower_id]
		var target_id := String(rule.get("target", ""))
		var follower := _find_runtime_character(follower_id)
		var target := _find_runtime_character(target_id)
		if follower != null and target != null:
			_follow_paths[target_id] = [follower.position, target.position]

func _apply_spawn(spawn_id: String, character: CharacterBody2D) -> void:
	var spawn := _find_spawn(spawn_id)
	if spawn.is_empty():
		return
	character.position = _rect_center(spawn)
	character.set_meta("facing", _string_value(spawn, "facing"))

func _find_runtime_character(object_id: String) -> CharacterBody2D:
	for child in room_root.get_children():
		if child is CharacterBody2D:
			if String(child.get_meta("object_id", "")) == object_id:
				return child
	return null

func drs_find_character(object_id: String) -> CharacterBody2D:
	return _find_runtime_character(object_id)

func drs_find_object(object_id: String) -> Node2D:
	var character := _find_runtime_character(object_id)
	if character != null:
		return character
	for child in room_root.get_children():
		if child is Node2D and String(child.get_meta("object_id", "")) == object_id:
			return child
	return null

func drs_object_position(object_id: String) -> Vector2:
	var object := drs_find_object(object_id)
	if object == null:
		return Vector2.INF
	return object.position

func drs_character_facing(object_id: String) -> String:
	var body := _find_runtime_character(object_id)
	return String(body.get_meta("facing", "down")) if body != null else ""

func drs_teleport_character(object_id: String, position: Vector2) -> void:
	var body := _find_runtime_character(object_id)
	if body == null:
		push_error("DRS character was not found: " + object_id)
		return
	body.position = position
	body.velocity = Vector2.ZERO

func drs_set_character_visible(object_id: String, visible: bool) -> void:
	var body := _find_runtime_character(object_id)
	if body == null:
		push_error("DRS character was not found: " + object_id)
		return
	body.visible = visible

func drs_set_character_animation(
	object_id: String,
	animation_name: String,
	direction: String = ""
) -> void:
	var body := _find_runtime_character(object_id)
	if body == null:
		push_error("DRS character was not found: " + object_id)
		return
	body.set_meta("forced_animation", animation_name)
	body.set_meta("forced_animation_direction", direction)
	body.set_meta("forced_animation_elapsed", 0.0)

func drs_clear_character_animation(object_id: String) -> void:
	var body := _find_runtime_character(object_id)
	if body == null:
		return
	body.remove_meta("forced_animation")
	body.remove_meta("forced_animation_direction")
	body.remove_meta("forced_animation_elapsed")
	_update_character_animation(
		body,
		"idle",
		String(body.get_meta("facing", "down")),
		0.0
	)

func drs_follow(follower_id: String, target_id: String, distance: float) -> void:
	var follower := _find_runtime_character(follower_id)
	if follower == null:
		push_error("DRS follower was not found: " + follower_id)
		return
	var target := _find_runtime_character(target_id)
	if target == null:
		push_error("DRS follow target was not found: " + target_id)
		return
	_follow_rules[follower_id] = {
		"target": target_id,
		"distance": maxf(distance, 0.0),
	}
	_follow_paths[target_id] = [follower.position, target.position]

func drs_stop_follow(follower_id: String) -> void:
	_follow_rules.erase(follower_id)
	var body := _find_runtime_character(follower_id)
	if body != null:
		_stop_controlled_character(body)

func drs_move_character(
	object_id: String,
	target: Vector2,
	speed: float = -1.0
) -> void:
	var body := _find_runtime_character(object_id)
	if body == null:
		push_error("DRS character was not found: " + object_id)
		return
	var move_speed := speed
	if move_speed <= 0.0:
		move_speed = float(body.get_meta("move_speed", 160.0))
	var animation_elapsed := 0.0
	var stalled := 0.0
	while body.position.distance_to(target) > 1.0:
		await get_tree().physics_frame
		if not is_instance_valid(body):
			return
		var delta := get_physics_process_delta_time()
		var offset := target - body.position
		var direction := offset.normalized()
		var facing := _movement_facing(direction)
		body.set_meta("facing", facing)
		var frame_speed := minf(move_speed, offset.length() / maxf(delta, 0.0001))
		body.velocity = direction * frame_speed
		var previous := body.position
		body.move_and_slide()
		animation_elapsed += delta
		if not body.has_meta("forced_animation"):
			_update_character_animation(body, "walk", facing, animation_elapsed)
		if body.position.distance_to(previous) < 0.01:
			stalled += delta
			if stalled >= 0.35:
				break
		else:
			stalled = 0.0
	if not is_instance_valid(body):
		return
	body.velocity = Vector2.ZERO
	if body.position.distance_to(target) <= 2.0:
		body.position = target
	if not body.has_meta("forced_animation"):
		_update_character_animation(
			body,
			"idle",
			String(body.get_meta("facing", "down")),
			0.0
		)

func drs_control_character(
	object_id: String,
	direction: Vector2,
	speed: float,
	delta: float
) -> void:
	var body := _find_runtime_character(object_id)
	if body == null:
		return
	if direction.is_zero_approx():
		_stop_controlled_character(body)
		return
	var move_speed := speed
	if move_speed <= 0.0:
		move_speed = float(body.get_meta("move_speed", 160.0))
	var normalized_direction := direction.normalized()
	var facing := _movement_facing(normalized_direction)
	body.set_meta("facing", facing)
	body.set_meta("player_moving", true)
	body.velocity = normalized_direction * move_speed
	body.move_and_slide()
	var elapsed := float(body.get_meta("player_animation_elapsed", 0.0)) + delta
	body.set_meta("player_animation_elapsed", elapsed)
	if not body.has_meta("forced_animation"):
		_update_character_animation(body, "walk", facing, elapsed)

func _stop_controlled_character(body: CharacterBody2D) -> void:
	body.velocity = Vector2.ZERO
	if not bool(body.get_meta("player_moving", false)):
		return
	body.set_meta("player_moving", false)
	body.set_meta("player_animation_elapsed", 0.0)
	if not body.has_meta("forced_animation"):
		_update_character_animation(
			body,
			"idle",
			String(body.get_meta("facing", "down")),
			0.0
		)

func drs_face_character(object_id: String, direction: String) -> void:
	var body := _find_runtime_character(object_id)
	if body == null:
		push_error("DRS character was not found: " + object_id)
		return
	var facing := direction if direction in ["up", "down", "left", "right"] else "down"
	body.set_meta("facing", facing)
	if not body.has_meta("forced_animation"):
		_update_character_animation(body, "idle", facing, 0.0)

func drs_change_room(
	room_path: String,
	spawn_id: String = "",
	traveler_id: String = ""
) -> void:
	var traveler := _find_runtime_character(traveler_id)
	if traveler == null:
		for child in room_root.get_children():
			if child is CharacterBody2D:
				traveler = child
				break
	await _change_room(room_path, spawn_id, traveler)

func drs_project_id() -> String:
	return String(project_data.get("id", "project"))

func drs_capture_save_state() -> Dictionary:
	var characters: Array[Dictionary] = []
	for child in room_root.get_children():
		if child is CharacterBody2D:
			characters.append({
				"id": String(child.get_meta("object_id", "")),
				"x": child.position.x,
				"y": child.position.y,
				"facing": String(child.get_meta("facing", "down")),
			})
	return {
		"room": _current_scene_path,
		"characters": characters,
	}

func drs_restore_save_state(state: Dictionary) -> void:
	var room_path := String(state.get("room", _current_scene_path))
	if room_path != _current_scene_path:
		await _change_room(room_path, "", null)
	var characters: Array = state.get("characters", [])
	for character_variant in characters:
		if character_variant is not Dictionary:
			continue
		var character: Dictionary = character_variant
		var body := _find_runtime_character(String(character.get("id", "")))
		if body == null:
			continue
		body.position = Vector2(
			float(character.get("x", body.position.x)),
			float(character.get("y", body.position.y))
		)
		body.set_meta("facing", String(character.get("facing", "down")))
	_reset_follow_paths()

func _update_forced_animations(delta: float) -> void:
	for child in room_root.get_children():
		if child is not CharacterBody2D or not child.has_meta("forced_animation"):
			continue
		var animation_name := String(child.get_meta("forced_animation", ""))
		var direction := String(child.get_meta("forced_animation_direction", ""))
		if direction.is_empty():
			direction = String(child.get_meta("facing", "down"))
		var elapsed := float(child.get_meta("forced_animation_elapsed", 0.0)) + delta
		child.set_meta("forced_animation_elapsed", elapsed)
		_update_character_animation(child, animation_name, direction, elapsed)

func _update_followers(delta: float) -> void:
	for follower_variant in _follow_rules.keys():
		var follower_id := String(follower_variant)
		var rule: Dictionary = _follow_rules[follower_id]
		var target_id := String(rule.get("target", ""))
		var follower := _find_runtime_character(follower_id)
		var target := _find_runtime_character(target_id)
		if follower == null or target == null:
			continue
		var path := _record_follow_path(target_id, target.position)
		var follow_position := _position_behind(path, float(rule.get("distance", 48.0)))
		_move_follower_step(follower, target, follow_position, delta)

func _record_follow_path(target_id: String, position: Vector2) -> Array:
	var path: Array = _follow_paths.get(target_id, [])
	if path.is_empty() or Vector2(path[-1]).distance_to(position) >= 2.0:
		path.append(position)
	while path.size() > 600:
		path.pop_front()
	_follow_paths[target_id] = path
	return path

func _position_behind(path: Array, distance: float) -> Vector2:
	if path.is_empty():
		return Vector2.ZERO
	var remaining := distance
	for index in range(path.size() - 1, 0, -1):
		var end := Vector2(path[index])
		var start := Vector2(path[index - 1])
		var segment_length := start.distance_to(end)
		if segment_length >= remaining and segment_length > 0.0:
			return end.lerp(start, remaining / segment_length)
		remaining -= segment_length
	return Vector2(path[0])

func _move_follower_step(
	follower: CharacterBody2D,
	target: CharacterBody2D,
	follow_position: Vector2,
	delta: float
) -> void:
	var offset := follow_position - follower.position
	if offset.length() <= 2.0:
		_stop_controlled_character(follower)
		return
	var follower_speed := float(follower.get_meta("move_speed", 160.0))
	var target_speed := float(target.get_meta("move_speed", follower_speed))
	var speed := minf(follower_speed, target_speed)
	var direction := offset.normalized()
	var facing := _movement_facing(direction)
	follower.set_meta("facing", facing)
	follower.set_meta("player_moving", true)
	follower.velocity = direction * speed
	follower.move_and_slide()
	var elapsed := float(follower.get_meta("player_animation_elapsed", 0.0)) + delta
	follower.set_meta("player_animation_elapsed", elapsed)
	if not follower.has_meta("forced_animation"):
		_update_character_animation(follower, "walk", facing, elapsed)

func _movement_facing(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x >= 0.0 else "left"
	return "down" if direction.y >= 0.0 else "up"

func _update_character_animation(
	body: CharacterBody2D,
	animation_name: String,
	direction: String,
	elapsed: float
) -> void:
	var definition: Variant = body.get_meta("definition", {})
	if definition is not Dictionary:
		return
	var animation := _find_animation(definition, animation_name, direction)
	if animation.is_empty() and animation_name == "idle":
		animation = _find_animation(definition, "walk", direction)
	if animation.is_empty():
		return
	var frames: Array = animation.get("frames", [])
	if frames.is_empty():
		return
	var fps := maxf(_number_value(animation, "fps", 8.0), 1.0)
	var frame_index := int(floor(elapsed * fps)) % frames.size()
	_set_character_frame(body, String(frames[frame_index]))

func _find_animation(
	definition: Dictionary,
	animation_name: String,
	direction: String
) -> Dictionary:
	var animations: Array = definition.get("animations", [])
	var direction_fallback: Dictionary = {}
	for animation_variant in animations:
		if animation_variant is Dictionary:
			var animation: Dictionary = animation_variant
			if _string_value(animation, "name") == animation_name:
				direction_fallback = animation
			if (
				_string_value(animation, "name") == animation_name
				and _string_value(animation, "direction") == direction
			):
				return animation
	return direction_fallback

func _set_character_frame(body: CharacterBody2D, asset: String) -> void:
	if String(body.get_meta("frame_asset", "")) == asset:
		return
	var texture := _load_texture(asset)
	if texture == null:
		return
	for child in body.get_children():
		if child is Sprite2D:
			child.texture = texture
			body.set_meta("frame_asset", asset)
			return

func drs_set_object_visible(object_id: String, visible: bool) -> void:
	var object := drs_find_object(object_id)
	if object == null:
		push_error("DRS object was not found: " + object_id)
		return
	object.visible = visible

func drs_remove_object(object_id: String) -> void:
	var object := drs_find_object(object_id)
	if object == null:
		return
	object.queue_free()

func drs_create_save_point(
	object_id: String,
	position: Vector2,
	slot: int = 1
) -> Area2D:
	var existing := drs_find_object(object_id)
	if existing is Area2D:
		return existing
	var save_point := _content_runtime.create_save_point(
		object_id, position, slot, room_root
	) as Area2D
	DRS.refresh_save_points()
	return save_point

func drs_set_object_texture(object_id: String, asset: String) -> void:
	var object := drs_find_object(object_id)
	if object == null:
		push_error("DRS object was not found: " + object_id)
		return
	var sprite := object as Sprite2D
	if sprite == null:
		for child in object.get_children():
			if child is Sprite2D:
				sprite = child
				break
	if sprite == null:
		push_error("DRS object has no sprite: " + object_id)
		return
	var texture := _load_texture(asset)
	if texture != null:
		sprite.texture = texture

func drs_move_object(
	object_id: String,
	target: Vector2,
	speed: float
) -> void:
	var object := drs_find_object(object_id)
	if object == null:
		push_error("DRS object was not found: " + object_id)
		return
	var duration := object.position.distance_to(target) / maxf(speed, 1.0)
	if duration <= 0.0:
		object.position = target
		return
	var tween := create_tween()
	tween.tween_property(object, "position", target, duration)
	await tween.finished

func drs_set_door_enabled(object_id: String, enabled: bool) -> void:
	var object := drs_find_object(object_id)
	if object is Area2D and object.is_in_group("drs_door"):
		object.set_deferred("monitoring", enabled)
		object.visible = enabled

func drs_set_trigger_enabled(object_id: String, enabled: bool) -> void:
	var object := drs_find_object(object_id)
	if object is Area2D:
		object.set_deferred("monitoring", enabled)

func drs_camera_follow(object_id: String) -> void:
	_camera_follow_id = object_id

func drs_camera_focus(target: Vector2, duration: float) -> void:
	_camera_follow_id = ""
	if duration <= 0.0:
		_camera_position = target
		return
	var tween := create_tween()
	tween.tween_property(self, "_camera_position", target, duration)
	await tween.finished

func drs_camera_zoom(scale: float, duration: float) -> void:
	var target := Vector2.ONE * maxf(scale, 0.05)
	if duration <= 0.0:
		_runtime_camera.zoom = target
		return
	var tween := create_tween()
	tween.tween_property(_runtime_camera, "zoom", target, duration)
	await tween.finished

func drs_camera_shake(strength: float, duration: float) -> void:
	_camera_shake_strength = maxf(strength, 0.0)
	_camera_shake_remaining = maxf(duration, 0.0)
	_camera_shake_elapsed = 0.0
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout

func drs_camera_reset() -> void:
	_camera_follow_id = ""
	_camera_position = _view_size / 2.0
	_runtime_camera.position = _camera_position
	_runtime_camera.zoom = Vector2.ONE
	_camera_shake_remaining = 0.0

func _update_runtime_camera(delta: float) -> void:
	if not _camera_follow_id.is_empty():
		var target := drs_find_object(_camera_follow_id)
		if target != null:
			_camera_position = target.position
	var offset := Vector2.ZERO
	if _camera_shake_remaining > 0.0:
		_camera_shake_remaining = maxf(_camera_shake_remaining - delta, 0.0)
		_camera_shake_elapsed += delta
		offset = Vector2(
			sin(_camera_shake_elapsed * 71.0),
			cos(_camera_shake_elapsed * 53.0)
		) * _camera_shake_strength
	_runtime_camera.position = _camera_position + offset

func _find_spawn(spawn_id: String) -> Dictionary:
	var fallback: Dictionary = {}
	var objects: Array = scene_data.get("objects", [])
	for object_variant in objects:
		if object_variant is Dictionary:
			var object: Dictionary = object_variant
			if _string_value(object, "type") != "spawn":
				continue
			if _string_value(object, "id") == spawn_id:
				return object
			if bool(object.get("defaultSpawn", false)):
				fallback = object
	return fallback

func _load_texture(asset: String) -> Texture2D:
	var resource_path := PROJECT_ROOT.path_join(asset)
	if ResourceLoader.exists(resource_path):
		var texture := load(resource_path) as Texture2D
		if texture != null:
			return texture
	var absolute_path := ProjectSettings.globalize_path(resource_path)
	var image := Image.load_from_file(absolute_path)
	if image != null and not image.is_empty():
		return ImageTexture.create_from_image(image)
	return load(resource_path) as Texture2D

func _apply_sprite_size(sprite: Sprite2D, texture: Texture2D, object: Dictionary) -> void:
	var scale_x := _number_value(object, "scaleX", 1.0)
	var scale_y := _number_value(object, "scaleY", 1.0)
	var width := _number_value(object, "width", -1.0)
	var height := _number_value(object, "height", -1.0)
	if width > 0.0:
		scale_x = width / texture.get_width()
	if height > 0.0:
		scale_y = height / texture.get_height()
	sprite.scale = Vector2(scale_x, scale_y)

func _string_value(object: Dictionary, key: String) -> String:
	var value: Variant = object.get(key, "")
	return value if value is String else ""

func _number_value(object: Dictionary, key: String, fallback: float) -> float:
	var value: Variant = object.get(key, fallback)
	return float(value) if value is float or value is int else fallback

func _add_runtime_label() -> void:
	var label := Label.new()
	label.position = Vector2(16, 16)
	label.text = str(project_data.get("name", "Deltarune Studio"))
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	add_child(label)
