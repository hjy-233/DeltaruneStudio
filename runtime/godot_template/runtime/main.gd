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
	_add_background()
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

func _add_background() -> void:
	var background: Variant = scene_data.get("background")
	if typeof(background) != TYPE_STRING or String(background).is_empty():
		return
	var texture := load(PROJECT_ROOT.path_join(String(background))) as Texture2D
	if texture == null:
		push_error("DRS background could not be loaded: " + background)
		return
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = VIEW_SIZE / 2.0
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)

func _add_runtime_label() -> void:
	var label := Label.new()
	label.position = Vector2(16, 16)
	label.text = str(project_data.get("name", "Deltarune Studio"))
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	add_child(label)
