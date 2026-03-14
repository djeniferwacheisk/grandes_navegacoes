extends Control

const STAR_COUNT := 3
const TOLERANCE := 12.0 # pixels

var stars_aligned := 0
var _current_star := 0
var _crosshair_pos := Vector2(160, 90)
var _star_positions: Array[Vector2] = []
var _star_targets: Array[Vector2] = []
var _completed := false

@onready var crosshair: Sprite2D = $SkyArea/Crosshair
@onready var result_label: Label = $ResultLabel
@onready var hint_label: Label = $HintLabel
@onready var back_button: Button = $BackButton
@onready var sky_area: Control = $SkyArea
@onready var star_counter: Label = $StarCounter


func _ready() -> void:
	back_button.pressed.connect(_on_back)
	result_label.text = ""

	# Star positions in the sky (visual)
	_star_positions = [
		Vector2(80, 40),
		Vector2(200, 55),
		Vector2(140, 30),
	]

	# Target alignment positions for the astrolabe crosshair
	_star_targets = _star_positions.duplicate()

	_draw_stars()
	_update_hint()
	_update_counter()


func _draw_stars() -> void:
	for i in STAR_COUNT:
		var star := ColorRect.new()
		star.name = "Star" + str(i)
		star.size = Vector2(4, 4)
		star.position = _star_positions[i] - Vector2(2, 2)
		star.color = Color.YELLOW if i >= stars_aligned else Color.GREEN
		sky_area.add_child(star)

		var label := Label.new()
		label.text = "★"
		label.position = _star_positions[i] - Vector2(4, 6)
		label.add_theme_font_size_override("font_size", 6)
		label.modulate = Color.YELLOW if i >= stars_aligned else Color.GREEN
		label.name = "StarLabel" + str(i)
		sky_area.add_child(label)


func _process(_delta: float) -> void:
	if _completed:
		return

	# Move crosshair with mouse or WASD
	var input := Vector2.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")

	if input != Vector2.ZERO:
		_crosshair_pos += input * 1.5
		_crosshair_pos.x = clampf(_crosshair_pos.x, 10, 310)
		_crosshair_pos.y = clampf(_crosshair_pos.y, 10, 140)
		crosshair.position = _crosshair_pos


func _input(event: InputEvent) -> void:
	if _completed:
		return

	if event is InputEventMouseMotion:
		var local_pos := sky_area.get_local_mouse_position()
		_crosshair_pos = local_pos
		_crosshair_pos.x = clampf(_crosshair_pos.x, 10, 310)
		_crosshair_pos.y = clampf(_crosshair_pos.y, 10, 140)
		crosshair.position = _crosshair_pos

	if event.is_action_pressed("interact") or (event is InputEventMouseButton and event.pressed):
		_try_align()

	if event.is_action_pressed("pause"):
		_on_back()


func _try_align() -> void:
	if _current_star >= STAR_COUNT:
		return

	var target: Vector2 = _star_targets[_current_star]
	var dist := _crosshair_pos.distance_to(target)

	if dist <= TOLERANCE:
		stars_aligned += 1
		_current_star += 1

		# Turn aligned star green
		var star_label := sky_area.get_node_or_null("StarLabel" + str(_current_star - 1))
		if star_label:
			star_label.modulate = Color.GREEN
		var star_rect := sky_area.get_node_or_null("Star" + str(_current_star - 1))
		if star_rect:
			star_rect.color = Color.GREEN

		result_label.text = "Estrela alinhada!"
		_update_counter()
		_update_hint()

		if stars_aligned >= STAR_COUNT:
			_complete_puzzle()
	else:
		result_label.text = "Tente novamente..."
		await get_tree().create_timer(0.5).timeout
		if not _completed:
			result_label.text = ""


func _update_hint() -> void:
	if _current_star < STAR_COUNT:
		hint_label.text = "Mova a mira ate a estrela " + str(_current_star + 1) + " e pressione [E]"
	else:
		hint_label.text = ""


func _update_counter() -> void:
	star_counter.text = "Estrelas: " + str(stars_aligned) + "/" + str(STAR_COUNT)


func _complete_puzzle() -> void:
	_completed = true
	result_label.text = "Latitude determinada! Rota calculada!"
	hint_label.text = ""

	# Show route map animation
	var map_rect := ColorRect.new()
	map_rect.size = Vector2(0, 0)
	map_rect.position = Vector2(160, 90)
	map_rect.color = Color(0.8, 0.7, 0.4, 0.9)
	sky_area.add_child(map_rect)

	var map_label := Label.new()
	map_label.text = "ROTA MARITIMA"
	map_label.add_theme_font_size_override("font_size", 6)
	map_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_label.visible = false
	map_rect.add_child(map_label)

	var tween := create_tween()
	tween.tween_property(map_rect, "size", Vector2(120, 80), 1.0)
	tween.parallel().tween_property(map_rect, "position", Vector2(100, 50), 1.0)
	await tween.finished

	map_label.visible = true
	map_label.position = Vector2(10, 30)

	GameManager.complete_objective(1, "astrolabio")
	await get_tree().create_timer(2.0).timeout
	SceneManager.change_scene("res://scenes/levels/fase1_sagres.tscn")


func _on_back() -> void:
	SceneManager.change_scene("res://scenes/levels/fase1_sagres.tscn")
