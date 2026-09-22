extends Node

const PROJECT_ROOT := "res://drs_project"
const SAVE_POINT_FRAME_PATHS := [
	"res://runtime/save_point/save_point_0.png",
	"res://runtime/save_point/save_point_1.png",
	"res://runtime/save_point/save_point_2.png",
	"res://runtime/save_point/save_point_3.png",
	"res://runtime/save_point/save_point_4.png",
	"res://runtime/save_point/save_point_5.png",
]

var _runtime: Node
var _reload_marker_time := 0
var _poll_elapsed := 0.0
var _reloading := false

func setup(runtime: Node) -> void:
	_runtime = runtime
	_reload_marker_time = _marker_time()

func _process(delta: float) -> void:
	_poll_elapsed += delta
	if _poll_elapsed < 0.35 or _reloading:
		return
	_poll_elapsed = 0.0
	var next_time := _marker_time()
	if next_time <= _reload_marker_time:
		return
	_reload_marker_time = next_time
	_reloading = true
	await _runtime.drs_hot_reload_current_room()
	_reloading = false

func add_tile_map(scene_data: Dictionary, room_root: Node2D) -> void:
	var tile_map: Dictionary = scene_data.get("tileMap", {})
	var tile_width := maxf(float(tile_map.get("tileWidth", 32.0)), 1.0)
	var tile_height := maxf(float(tile_map.get("tileHeight", 32.0)), 1.0)
	var cells: Array = tile_map.get("cells", [])
	for cell_variant in cells:
		if cell_variant is not Dictionary:
			continue
		var cell: Dictionary = cell_variant
		var center := Vector2(
			(float(cell.get("column", 0)) + 0.5) * tile_width,
			(float(cell.get("row", 0)) + 0.5) * tile_height
		)
		if String(cell.get("kind", "ground")) == "collision":
			_add_tile_collision(room_root, center, Vector2(tile_width, tile_height))
		else:
			_add_tile_sprite(room_root, center, Vector2(tile_width, tile_height), cell)

func add_collidable_sprite(
	sprite: Sprite2D,
	object: Dictionary,
	position: Vector2,
	room_root: Node2D
) -> void:
	var body := StaticBody2D.new()
	body.name = String(object.get("name", "Object"))
	body.position = position
	body.z_index = int(object.get("zIndex", 0))
	body.set_meta("object_id", String(object.get("id", "")))
	body.set_meta("interaction", object.get("interaction", {}))
	body.add_to_group("drs_object")
	room_root.add_child(body)
	sprite.position = Vector2.ZERO
	sprite.z_index = 0
	body.add_child(sprite)
	_add_collision_shape(body, object.get("collision", {}))

func add_save_point(object: Dictionary, room_root: Node2D) -> Area2D:
	var object_width := maxf(float(object.get("width", 20.0)), 1.0)
	var object_height := maxf(float(object.get("height", 19.0)), 1.0)
	var collision_size := Vector2(20, 19)
	var area := Area2D.new()
	area.name = String(object.get("name", "Save Point"))
	area.position = Vector2(
		float(object.get("x", 0.0)) + object_width / 2.0,
		float(object.get("y", 0.0)) + object_height / 2.0
	)
	area.set_meta("object_id", String(object.get("id", "")))
	area.set_meta("interaction", object.get("interaction", {}))
	area.set_meta("save_slot", clampi(int(object.get("saveSlot", 1)), 1, 3))
	area.add_to_group("drs_object")
	area.add_to_group("drs_save_point")
	room_root.add_child(area)
	_add_rect_collision(area, collision_size)
	var frames := SpriteFrames.new()
	frames.add_animation("sparkle")
	frames.set_animation_speed("sparkle", 4.0)
	frames.set_animation_loop("sparkle", true)
	for path in SAVE_POINT_FRAME_PATHS:
		var texture := _load_runtime_texture(path)
		if texture != null:
			frames.add_frame("sparkle", texture)
	var marker := AnimatedSprite2D.new()
	marker.sprite_frames = frames
	marker.animation = "sparkle"
	marker.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	area.add_child(marker)
	marker.play()
	return area

func create_save_point(
	object_id: String,
	position: Vector2,
	slot: int,
	room_root: Node2D
) -> Area2D:
	var size := Vector2(20, 19)
	return add_save_point({
		"id": object_id,
		"type": "savePoint",
		"name": object_id,
		"x": position.x - size.x / 2.0,
		"y": position.y - size.y / 2.0,
		"width": size.x,
		"height": size.y,
		"saveSlot": clampi(slot, 1, 3),
	}, room_root)

func _add_tile_sprite(
	room_root: Node2D,
	center: Vector2,
	size: Vector2,
	cell: Dictionary
) -> void:
	var asset := String(cell.get("asset", ""))
	var texture := _load_texture(asset)
	if texture == null:
		return
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = center
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(
		size.x / maxf(texture.get_width(), 1.0),
		size.y / maxf(texture.get_height(), 1.0)
	)
	sprite.z_index = -500 if String(cell.get("kind", "ground")) == "ground" else -400
	room_root.add_child(sprite)

func _add_tile_collision(room_root: Node2D, center: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = center
	room_root.add_child(body)
	_add_rect_collision(body, size)

func _add_rect_collision(parent: Node2D, size: Vector2) -> void:
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	shape_node.shape = shape
	parent.add_child(shape_node)

func _add_collision_shape(parent: Node2D, collision: Dictionary) -> void:
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(
		maxf(float(collision.get("width", 1.0)), 1.0),
		maxf(float(collision.get("height", 1.0)), 1.0)
	)
	shape_node.shape = shape
	shape_node.position = Vector2(
		float(collision.get("x", 0.0)) + shape.size.x / 2.0,
		float(collision.get("y", 0.0)) + shape.size.y / 2.0
	)
	parent.add_child(shape_node)

func _load_texture(asset: String) -> Texture2D:
	if asset.is_empty():
		return null
	var path := PROJECT_ROOT.path_join(asset)
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	return null if image == null or image.is_empty() else ImageTexture.create_from_image(image)

func _load_runtime_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var image := Image.new()
	if image.load_png_from_buffer(file.get_buffer(file.get_length())) != OK:
		return null
	return ImageTexture.create_from_image(image)

func _marker_time() -> int:
	var path := PROJECT_ROOT.path_join(".hot_reload")
	if not FileAccess.file_exists(path):
		return 0
	return int(FileAccess.get_file_as_string(path))
