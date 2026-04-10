extends Control

signal puzzle_completed

const NORTH_ANGLE := 0.0
const TOLERANCE := 15.0

## Cores do tema
const COLOR_GOLD := Color(0.88, 0.75, 0.45, 1)
const COLOR_GOLD_DIM := Color(0.65, 0.55, 0.35, 1)
const COLOR_TEXT := Color(0.75, 0.68, 0.55, 1)
const COLOR_CORRECT := Color(0.45, 0.85, 0.4, 1)
const COLOR_SLOT_ACTIVE := Color(0.82, 0.68, 0.38, 1)
const COLOR_SLOT_FILLED := Color(0.7, 0.62, 0.4, 1)

var compass_angle := 45.0
var wind_slots := {"alisios": "", "contra_alisios": "", "moncoes": ""}
var correct_winds := {"alisios": "NE", "contra_alisios": "SW", "moncoes": "SE"}
var compass_solved := false
var winds_solved := false
var _dragging_wind: String = ""
var _rotating := false

@onready var compass_needle: Sprite2D = $MainPanel/MarginContainer/VBox/ContentHBox/CompassFrame/CompassArea/CompassNeedle
@onready var result_label: Label = $MainPanel/MarginContainer/VBox/ResultLabel
@onready var back_button: Button = $MainPanel/MarginContainer/VBox/BottomBar/BackButton
@onready var wind_slots_container: VBoxContainer = $MainPanel/MarginContainer/VBox/ContentHBox/WindPanel/WindMargin/WindVBox/WindSlots
@onready var wind_options: HBoxContainer = $MainPanel/MarginContainer/VBox/ContentHBox/WindPanel/WindMargin/WindVBox/WindOptions


func _ready() -> void:
	back_button.pressed.connect(_on_back)
	result_label.text = ""
	compass_needle.rotation_degrees = compass_angle
	_setup_wind_buttons()


func _setup_wind_buttons() -> void:
	var directions := ["NE", "SW", "SE", "NW"]
	for dir in directions:
		var btn := Button.new()
		btn.text = dir
		btn.custom_minimum_size = Vector2(44, 28)
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", COLOR_TEXT)
		btn.add_theme_color_override("font_hover_color", COLOR_GOLD)
		_apply_option_style(btn)
		btn.pressed.connect(_on_wind_option_pressed.bind(dir))
		wind_options.add_child(btn)

	var slot_names := ["Alísios", "Contra-Alísios", "Monções"]
	var slot_keys := ["alisios", "contra_alisios", "moncoes"]
	for i in slot_names.size():
		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)

		var label := Label.new()
		label.text = slot_names[i] + ":"
		label.add_theme_font_size_override("font_size", 11)
		label.add_theme_color_override("font_color", COLOR_TEXT)
		label.custom_minimum_size = Vector2(100, 0)
		hbox.add_child(label)

		var slot_btn := Button.new()
		slot_btn.text = "  —  "
		slot_btn.name = slot_keys[i]
		slot_btn.custom_minimum_size = Vector2(52, 26)
		slot_btn.add_theme_font_size_override("font_size", 11)
		slot_btn.add_theme_color_override("font_color", COLOR_GOLD_DIM)
		slot_btn.add_theme_color_override("font_hover_color", COLOR_GOLD)
		_apply_slot_style(slot_btn)
		slot_btn.pressed.connect(_on_slot_pressed.bind(slot_keys[i]))
		hbox.add_child(slot_btn)

		wind_slots_container.add_child(hbox)


func _apply_option_style(btn: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.2, 0.16, 0.1, 1)
	normal.border_color = Color(0.5, 0.4, 0.25, 0.6)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(5)
	normal.set_content_margin_all(6)
	btn.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = Color(0.3, 0.24, 0.14, 1)
	hover.border_color = COLOR_GOLD
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.38, 0.3, 0.16, 1)
	pressed.border_color = COLOR_GOLD
	pressed.set_border_width_all(2)
	btn.add_theme_stylebox_override("pressed", pressed)


func _apply_slot_style(btn: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.13, 0.1, 0.07, 1)
	normal.border_color = Color(0.4, 0.32, 0.2, 0.5)
	normal.set_border_width_all(1)
	normal.border_width_bottom = 2
	normal.set_corner_radius_all(4)
	normal.set_content_margin_all(5)
	btn.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = Color(0.2, 0.16, 0.1, 1)
	hover.border_color = Color(0.6, 0.5, 0.3, 0.8)
	btn.add_theme_stylebox_override("hover", hover)


func _on_slot_pressed(slot_key: String) -> void:
	_dragging_wind = slot_key
	_highlight_active_slot()


func _highlight_active_slot() -> void:
	for hbox in wind_slots_container.get_children():
		for child in hbox.get_children():
			if child is Button:
				if child.name == _dragging_wind:
					child.add_theme_color_override("font_color", COLOR_SLOT_ACTIVE)
				elif wind_slots.get(child.name, "") != "":
					child.add_theme_color_override("font_color", COLOR_SLOT_FILLED)
				else:
					child.add_theme_color_override("font_color", COLOR_GOLD_DIM)


func _on_wind_option_pressed(direction: String) -> void:
	if _dragging_wind == "":
		for key in wind_slots:
			if wind_slots[key] == "":
				_dragging_wind = key
				break
	if _dragging_wind == "":
		return

	wind_slots[_dragging_wind] = direction
	var slot_btn := _find_slot_button(_dragging_wind)
	if slot_btn:
		slot_btn.text = direction
		slot_btn.add_theme_color_override("font_color", COLOR_SLOT_FILLED)
	_dragging_wind = ""
	_highlight_active_slot()
	_check_winds()


func _find_slot_button(key: String) -> Button:
	for hbox in wind_slots_container.get_children():
		for child in hbox.get_children():
			if child is Button and child.name == key:
				return child
	return null


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not _rotating:
		var compass_area := $MainPanel/MarginContainer/VBox/ContentHBox/CompassFrame/CompassArea as Control
		var compass_center: Vector2 = compass_area.global_position + Vector2(80, 80)
		var dist: float = event.global_position.distance_to(compass_center)
		if dist < 60:
			_rotate_needle(15.0)

	if event.is_action_pressed("pause"):
		_on_back()


func _rotate_needle(amount: float) -> void:
	_rotating = true
	var target := fmod(compass_angle + amount, 360.0)
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(compass_needle, "rotation_degrees", target, 0.25)
	tween.finished.connect(func():
		compass_angle = target
		_rotating = false
		_check_compass()
	)


func _check_compass() -> void:
	var normalized := fmod(compass_angle, 360.0)
	if normalized < TOLERANCE or normalized > (360.0 - TOLERANCE):
		compass_solved = true
		result_label.text = "Bússola alinhada ao Norte!"
		result_label.add_theme_color_override("font_color", COLOR_CORRECT)
		_check_complete()
	else:
		compass_solved = false
		result_label.text = ""


func _check_winds() -> void:
	winds_solved = true
	for key in correct_winds:
		if wind_slots[key] != correct_winds[key]:
			winds_solved = false
			break

	if winds_solved:
		if compass_solved:
			_check_complete()
		else:
			result_label.text = "Ventos corretos! Agora alinhe a bússola."
			result_label.add_theme_color_override("font_color", COLOR_GOLD)
	_check_complete()


func _check_complete() -> void:
	if compass_solved and winds_solved:
		result_label.text = "Excelente! Puzzle completo!"
		result_label.add_theme_color_override("font_color", Color(1, 0.92, 0.4, 1))

		# Animação de feedback
		var tween := create_tween()
		tween.tween_property(result_label, "scale", Vector2(1.1, 1.1), 0.15)
		tween.tween_property(result_label, "scale", Vector2(1.0, 1.0), 0.15)

		GameManager.add_item("Astrolabio do Mestre", "Instrumento de navegacao estelar")
		GameManager.complete_objective(1, "bussola_ventos")
		GameManager.save_game()
		await get_tree().create_timer(1.8).timeout
		SceneManager.change_scene("res://scenes/levels/fase1_sagres.tscn")


func _on_back() -> void:
	SceneManager.change_scene("res://scenes/levels/fase1_sagres.tscn")
