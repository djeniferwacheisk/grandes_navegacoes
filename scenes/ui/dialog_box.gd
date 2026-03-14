extends CanvasLayer

signal dialog_finished

const CHAR_DELAY := 0.03

var _dialog_lines: Array = []
var _current_line := 0
var _is_typing := false
var _full_text := ""

@onready var panel: NinePatchRect = $Panel
@onready var speaker_label: Label = $Panel/SpeakerLabel
@onready var text_label: RichTextLabel = $Panel/TextLabel
@onready var continue_indicator: Label = $Panel/ContinueIndicator
@onready var portrait_rect: TextureRect = $Panel/PortraitRect


func _ready() -> void:
	visible = false
	continue_indicator.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		if _is_typing:
			_finish_typing()
		else:
			_advance_dialog()
		get_viewport().set_input_as_handled()


func start_dialog(dialog_id: String) -> void:
	var data := _load_dialog(dialog_id)
	if data.is_empty():
		return

	_dialog_lines = data
	_current_line = 0
	visible = true
	get_tree().paused = false

	if has_node("/root/Main/Player"):
		var player = get_node("/root/Main/Player")
		if player.has_method("set_state"):
			player.set_state(1) # IN_DIALOG -- can't reference enum across scripts easily

	_show_line()


func start_dialog_direct(lines: Array) -> void:
	_dialog_lines = lines
	_current_line = 0
	visible = true
	_show_line()


func _load_dialog(dialog_id: String) -> Array:
	var file := FileAccess.open("res://data/dialogs/fase1.json", FileAccess.READ)
	if not file:
		return []
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return []
	var data: Dictionary = json.data
	if data.has(dialog_id):
		return data[dialog_id]
	return []


func _show_line() -> void:
	if _current_line >= _dialog_lines.size():
		_end_dialog()
		return

	var line: Dictionary = _dialog_lines[_current_line]
	speaker_label.text = line.get("speaker", "")
	_full_text = line.get("text", "")
	text_label.text = ""
	continue_indicator.visible = false
	portrait_rect.visible = line.get("portrait", "") != ""
	_is_typing = true
	_type_text()


func _type_text() -> void:
	var line_index := _current_line
	for i in _full_text.length():
		if not _is_typing or _current_line != line_index:
			return
		text_label.text = _full_text.substr(0, i + 1)
		await get_tree().create_timer(CHAR_DELAY).timeout

	if _current_line == line_index:
		_is_typing = false
		continue_indicator.visible = true


func _finish_typing() -> void:
	_is_typing = false
	text_label.text = _full_text
	continue_indicator.visible = true


func _advance_dialog() -> void:
	_current_line += 1
	_show_line()


func _end_dialog() -> void:
	visible = false
	dialog_finished.emit()
