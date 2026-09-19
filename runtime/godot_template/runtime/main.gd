extends Node2D

const VIEW_SIZE := Vector2(640, 480)
const PROJECT_ROOT := "res://drs_project"

var project_data: Dictionary = {}
var scene_data: Dictionary = {}
var room_root: Node2D

func _ready() -> void:
	project_data = _read_json(PROJECT_ROOT.path_join("project.json"))
	var scene_path: String = project_data.get("mainScene", "scenes/main/scene.json")
	scene_data = _read_json(PROJECT_ROOT.path_join(scene_path))
	RenderingServer.set_default_clear_color(Color.BLACK)
	room_root = Node2D.new()
	room_root.name = "Room"
	add_child(room_root)
	_add_scene_visuals()
	_add_runtime_label()
	DRS.register_runtime(self)
	_run_entry_script.call_deferred()

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
	if not runner.has_method("run"):
		push_error("DRS entry script must define func run() -> void")
		return
	runner.call("run")

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
	var background: Variant = scene_data.get("background")
	if typeof(background) == TYPE_STRING and not String(background).is_empty():
		_add_sprite(String(background), {
			"type": "background",
			"x": VIEW_SIZE.x / 2.0,
			"y": VIEW_SIZE.y / 2.0,
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
		_number_value(object, "x", VIEW_SIZE.x / 2.0),
		_number_value(object, "y", VIEW_SIZE.y / 2.0)
	)
	sprite.z_index = _render_z(object)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_apply_sprite_size(sprite, texture, object)
	if _string_value(object, "type") == "character":
		_add_character(sprite, position, object)
	else:
		sprite.position = position
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
	room_root.add_child(area)
	_add_rect_shape(area, object)
	area.body_entered.connect(_on_door_body_entered.bind(area))

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
	if not body.is_in_group("drs_character"):
		return
	var target_room := String(door.get_meta("target_room", ""))
	if target_room.is_empty():
		return
	_change_room(
		target_room,
		String(door.get_meta("target_spawn", "")),
		body as CharacterBody2D
	)

func _change_room(
	room_path: String,
	spawn_id: String,
	traveler: CharacterBody2D
) -> void:
	var next_scene := _read_json(PROJECT_ROOT.path_join(room_path))
	if next_scene.is_empty():
		return
	var traveler_id := ""
	if traveler != null:
		traveler_id = String(traveler.get_meta("object_id", ""))
		room_root.remove_child(traveler)
	for child in room_root.get_children():
		room_root.remove_child(child)
		child.queue_free()
	scene_data = next_scene
	_add_scene_visuals()
	var target := _find_runtime_character(traveler_id)
	if target == null and traveler != null:
		room_root.add_child(traveler)
		target = traveler
	elif traveler != null:
		traveler.queue_free()
	if target != null:
		_apply_spawn(spawn_id, target)

func _apply_spawn(spawn_id: String, character: CharacterBody2D) -> void:
	var spawn := _find_spawn(spawn_id)
	if spawn.is_empty():
		return
	character.position = Vector2(
		_number_value(spawn, "x", VIEW_SIZE.x / 2.0),
		_number_value(spawn, "y", VIEW_SIZE.y / 2.0)
	)
	character.set_meta("facing", _string_value(spawn, "facing"))

func _find_runtime_character(object_id: String) -> CharacterBody2D:
	for child in room_root.get_children():
		if child is CharacterBody2D:
			if String(child.get_meta("object_id", "")) == object_id:
				return child
	return null

func drs_find_character(object_id: String) -> CharacterBody2D:
	return _find_runtime_character(object_id)

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
		_update_character_animation(body, "walk", facing, animation_elapsed)
		if body.position.distance_to(previous) < 0.01:
			stalled += delta
			if stalled >= 0.35:
				break
		else:
			stalled = 0.0
	body.velocity = Vector2.ZERO
	if body.position.distance_to(target) <= 2.0:
		body.position = target
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
	_change_room(room_path, spawn_id, traveler)
	await get_tree().process_frame

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
	for animation_variant in animations:
		if animation_variant is Dictionary:
			var animation: Dictionary = animation_variant
			if (
				_string_value(animation, "name") == animation_name
				and _string_value(animation, "direction") == direction
			):
				return animation
	return {}

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
