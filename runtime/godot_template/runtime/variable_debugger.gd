extends CanvasLayer

var _panel: PanelContainer
var _state_view: TextEdit
var _key_input: LineEdit
var _value_input: LineEdit

func setup() -> void:
	layer = 101
	_build_ui()
	_panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F4:
		_panel.visible = not _panel.visible
		if _panel.visible:
			_refresh()
		get_viewport().set_input_as_handled()

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.position = Vector2(20, 20)
	_panel.size = Vector2(420, 400)
	add_child(_panel)
	var layout := VBoxContainer.new()
	_panel.add_child(layout)
	var title := Label.new()
	title.text = "Runtime variables (F4)"
	layout.add_child(title)
	_state_view = TextEdit.new()
	_state_view.custom_minimum_size = Vector2(396, 250)
	_state_view.editable = false
	_state_view.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	layout.add_child(_state_view)
	_key_input = LineEdit.new()
	_key_input.placeholder_text = "Variable name"
	layout.add_child(_key_input)
	_value_input = LineEdit.new()
	_value_input.placeholder_text = "JSON value, for example 12 or \"text\""
	layout.add_child(_value_input)
	var buttons := HBoxContainer.new()
	layout.add_child(buttons)
	_add_button(buttons, "Set value", _set_value)
	_add_button(buttons, "Flag true", _set_flag_true)
	_add_button(buttons, "Flag false", _set_flag_false)
	_add_button(buttons, "Refresh", _refresh)

func _add_button(parent: Control, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(callback)
	parent.add_child(button)

func _set_value() -> void:
	var key := _key_input.text.strip_edges()
	if key.is_empty():
		return
	var value: Variant = JSON.parse_string(_value_input.text)
	if value == null and _value_input.text.strip_edges() != "null":
		value = _value_input.text
	DRS.set_value(key, value)
	_refresh()

func _set_flag_true() -> void:
	_set_flag(true)

func _set_flag_false() -> void:
	_set_flag(false)

func _set_flag(enabled: bool) -> void:
	var key := _key_input.text.strip_edges()
	if key.is_empty():
		return
	DRS.set_flag(key, enabled)
	_refresh()

func _refresh() -> void:
	_state_view.text = JSON.stringify(DRS.debug_state(), "  ")
