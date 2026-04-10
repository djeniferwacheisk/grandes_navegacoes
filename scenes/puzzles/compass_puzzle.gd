extends Control

signal puzzle_completed

const NORTH_ANGLE := 0.0
const TOLERANCE := 15.0

var compass_angle := 45.0
var wind_slots := {"alisios": "", "contra_alisios": "", "moncoes": ""}
var correct_winds := {"alisios": "NE", "contra_alisios": "SW", "moncoes": "SE"}
var compass_solved := false
var winds_solved := false
var _dragging_wind: String = ""

@onready var compass_sprite: Sprite2D = $CompassArea/CompassNeedle
@onready var result_label: Label = $ResultLabel
@onready var back_button: Button = $BackButton
@onready var wind_slots_container: VBoxContainer = $WindSlots
@onready var wind_options: HBoxContainer = $WindOptions


func _ready() -> void:
	back_button.pressed.connect(_on_back)
	result_label.text = ""
	_update_compass_visual()
	_setup_wind_buttons()


func _setup_wind_buttons() -> void:
	var directions := ["NE", "SW", "SE", "NW"]
	for dir in directions:
		var btn := Button.new()
		btn.text = dir
		btn.custom_minimum_size = Vector2(30, 16)
		btn.add_theme_font_size_override("font_size", 6)
		btn.pressed.connect(_on_wind_option_pressed.bind(dir))
		wind_options.add_child(btn)

	var slot_names := ["Alisios", "Contra-alisios", "Moncoes"]
	var slot_keys := ["alisios", "contra_alisios", "moncoes"]
	for i in slot_names.size():
		var hbox := HBoxContainer.new()
		var label := Label.new()
		label.text = slot_names[i] + ": "
		label.add_theme_font_size_override("font_size", 5)
		hbox.add_child(label)

		var slot_btn := Button.new()
		slot_btn.text = "---"
		slot_btn.name = slot_keys[i]
		slot_btn.custom_minimum_size = Vector2(30, 14)
		slot_btn.add_theme_font_size_override("font_size", 5)
		slot_btn.pressed.connect(_on_slot_pressed.bind(slot_keys[i]))
		hbox.add_child(slot_btn)
		wind_slots_container.add_child(hbox)


func _on_slot_pressed(slot_key: String) -> void:
	_dragging_wind = slot_key


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
	_dragging_wind = ""
	_check_winds()


func _find_slot_button(key: String) -> Button:
	for hbox in wind_slots_container.get_children():
		for child in hbox.get_children():
			if child is Button and child.name == key:
				return child
	return null


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var compass_center: Vector2 = $CompassArea.global_position + Vector2(40, 40)
		var dist: float = event.global_position.distance_to(compass_center)
		if dist < 45:
			compass_angle = fmod(compass_angle + 15.0, 360.0)
			_update_compass_visual()
			_check_compass()

	if event.is_action_pressed("pause"):
		_on_back()


func _update_compass_visual() -> void:
	if compass_sprite:
		compass_sprite.rotation_degrees = compass_angle


func _check_compass() -> void:
	if abs(compass_angle - NORTH_ANGLE) < TOLERANCE or abs(compass_angle - 360.0) < TOLERANCE:
		compass_solved = true
		result_label.text = "Bussola alinhada ao Norte!"
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
		result_label.text += "\nVentos corretos!"
	_check_complete()


func _check_complete() -> void:
	if compass_solved and winds_solved:
		result_label.text = "Excelente! Puzzle completo!"
		GameManager.add_item("Astrolabio do Mestre", "Instrumento de navegacao estelar")
		GameManager.complete_objective(1, "bussola_ventos")
		GameManager.save_game()
		await get_tree().create_timer(1.5).timeout
		SceneManager.change_scene("res://scenes/levels/fase1_sagres.tscn")


func _on_back() -> void:
	SceneManager.change_scene("res://scenes/levels/fase1_sagres.tscn")
