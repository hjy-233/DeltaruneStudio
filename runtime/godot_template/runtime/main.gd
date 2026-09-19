extends Node2D

const VIEW_SIZE := Vector2(640, 480)
const PROJECT_ROOT := "res://drs_project"

var project_data: Dictionary = {}
var scene_data: Dictionary = {}

func _ready() -> void:
	project_data = _read_json(PROJECT_ROOT.path_join("project.json"))
	var scene_path: String = project_data.get("mainScene", "scenes/main/scene.json")
	scene_data = _read_json(PROJECT_ROOT.path_join(scene_path))
	RenderingServer.set_default_clear_color(Color.BLACK)
	_add_scene_visuals()
	_add_runtime_label()

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
		var current_z := _z_index(current)
		var position := index - 1
		while position >= 0 and _z_index(result[position]) > current_z:
			result[position + 1] = result[position]
			position -= 1
		result[position + 1] = current
	return result

func _z_index(value: Variant) -> int:
	if value is Dictionary:
		return int(value.get("zIndex", 0))
	return 0

func _add_sprite(asset: String, object: Dictionary) -> void:
	var texture := _load_texture(asset)
	if texture == null:
		push_error("DRS asset could not be loaded: " + asset)
		return
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = Vector2(
		_number_value(object, "x", VIEW_SIZE.x / 2.0),
		_number_value(object, "y", VIEW_SIZE.y / 2.0)
	)
	sprite.z_index = _z_index(object)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_apply_sprite_size(sprite, texture, object)
	add_child(sprite)

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
