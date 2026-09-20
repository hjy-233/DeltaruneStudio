extends Node2D

var _runtime: Node
var _enabled := false

func setup(runtime: Node) -> void:
	_runtime = runtime
	z_index = 4095
	set_process_unhandled_key_input(true)

func _process(_delta: float) -> void:
	if _enabled:
		queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			_enabled = not _enabled
			visible = _enabled
			queue_redraw()

func _draw() -> void:
	if not _enabled or _runtime == null:
		return
	var objects: Array = _runtime.scene_data.get("objects", [])
	for object_variant in objects:
		if object_variant is Dictionary:
			_draw_source_object(object_variant)
	for child in _runtime.room_root.get_children():
		if child is Node2D:
			var object_id := String(child.get_meta("object_id", ""))
			if not object_id.is_empty():
				draw_string(
					ThemeDB.fallback_font,
					child.position + Vector2(6, -6),
					object_id,
					HORIZONTAL_ALIGNMENT_LEFT,
					-1,
					12,
					Color.WHITE
				)

func _draw_source_object(object: Dictionary) -> void:
	var type := String(object.get("type", ""))
	if type not in ["collision", "door", "spawn", "savePoint"]:
		return
	var position := Vector2(
		float(object.get("x", 0.0)),
		float(object.get("y", 0.0))
	)
	var size := Vector2(
		maxf(float(object.get("width", 24.0)), 1.0),
		maxf(float(object.get("height", 24.0)), 1.0)
	)
	var color := Color.CYAN
	if type == "door":
		color = Color.ORANGE
	elif type == "spawn":
		color = Color.GREEN
	elif type == "savePoint":
		color = Color.YELLOW
	draw_rect(Rect2(position, size), color, false, 1.0)
